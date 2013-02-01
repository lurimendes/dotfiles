#!/usr/bin/env python
# ftp.py - manage ftp uploads of snapshots with mercurial
#
# Copyright 2009 Andre Klitzing <andre@incubo.de>
#
# This software may be used and distributed according to the terms
# of the GNU General Public License, incorporated herein by reference.

"""upload and delete files on FTP server"""

from mercurial.i18n import gettext as _
from mercurial import commands, util, node, ignore
import os, ftplib
try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO


# backwards compatibility

# url handling
try:
    # 924c82157d46
    _url = util.url
except AttributeError:
    from mercurial import url as hg_url
    try:
        # before b23a8dd36a21
        _netlocsplit = hg_url.netlocsplit

        import urlparse
        class _url(object):
            def __init__(self, url):
                url = urlparse.urlsplit(url)
                netloc = _netlocsplit(url[1])
                self.host, self.port, self.user, self.passwd = netloc
                self.scheme = url[0]
                self.path = url[2]

    except AttributeError:
        # between b23a8dd36a21 and 924c82157d46
        _url = hg_url.url

# matchfiles moved to scmutil in a90131b85fd8
_matchfiles = None
try:
    from mercurial import scmutil
    try:
        _matchfiles = scmutil.matchfiles
    except AttributeError:
        pass
except ImportError:
    pass
if _matchfiles is None:
    from mercurial import cmdutil
    _matchfiles = cmdutil.matchfiles


class FtpManager(object):
    def __init__(self, ui, repo, dest, opts):
        """Read options and load settings from hgrc"""

        if not repo.local:
            raise util.Abort(_('Repository "%s" is not local') % repo.root)

        self.ui = ui
        self.repo = repo
        self.opts = opts
        self.ctx = repo[dest]
        self.uploaded = None
        self.selected = None

        self.chmod_file = self.opts.get('file') or self.ui.config('ftp', 'chmod_file')
        self.chmod_dir = self.opts.get('dir') or self.ui.config('ftp', 'chmod_dir')

        self.url = self.ui.config('paths', dest) or dest or self.ui.config('paths', 'ftp')
        if not self.url:
            raise util.Abort(_('no ftp destination given'))
        self.url = _url(self.url)

        if self.url.scheme != 'ftp':
            raise util.Abort(_('Only "ftp" scheme is supported'))
        if not self.url.host:
            raise util.Abort(_('No host given'))

        self.useGlobal = self.opts.get('global') or self.ui.configbool('ftp', 'global_tags')

        self.tagname = self.opts.get('tag')
        if not self.tagname:
            prefix = self.ui.config('ftp', 'prefix_tags') or _('uploaded@')
            self.tagname = prefix + self.url.host

        ftp_ignore_file = os.path.join(self.repo.root, '.hgftpignore')
        self._match_ignored_file = ignore.ignore(self.repo.root, [ftp_ignore_file], ui.warn)

    def _set_changesets(self):
        """Search the tag of that host and select revisions (root and child)"""
        if self.opts.get('rev'):
            self.selected = self.repo[self.opts.get('rev')]
        else:
            self.selected = self.repo[None].parents()[0]

        tags = self.repo.tags()
        if self.tagname in tags:
            self.uploaded = self.repo[tags[self.tagname]]

        if self.uploaded is None:
            self.ui.write(_('Tag %s not found\n') % self.tagname)
        else:
            self.ui.write(_('Tag %s on changeset %d:%s (branch: %s) found\n') %
                (self.tagname, self.uploaded, self.uploaded, self.uploaded.branch()) )

    def _check_changed(self):
        """Test if there is an uncommitted merge or .hgtags is changed if global tags are used"""
        if self.repo.dirstate.parents()[1] != node.nullid:
            raise util.Abort(_('outstanding uncommitted merge'))

        if self.opts.get('upload') and self.useGlobal and not self.opts.get('only'):
            status = self.repo.status('.', None, _matchfiles(self.repo, ['.hgtags']))
            if max(status):
                raise util.Abort(_('outstanding uncommitted .hgtags'))

    def _filter_ignored_files(self, files):
        valid_files = []
        for f in files:
            if not self._match_ignored_file(f):
                valid_files.append(f)
        return valid_files

    def _get_files(self, exclude_ignored=True):
        """Return changed files of found revisions"""
        self._set_changesets()

        if self.uploaded is None or self.opts.get('all'):
            self.ui.write(_('Upload every file of changeset %d:%s\n') %
                    (self.selected, self.selected))

            retval = (self.selected.manifest(), [])
        else:
            if self.selected not in self.uploaded.descendants():
                raise util.Abort(_('Changeset %d:%s is not a descendant of changeset %d:%s' %
                    (self.selected, self.selected, self.uploaded, self.uploaded)))

            files = self.repo.status(self.uploaded, self.selected)
            files_up = files[0] + files[1]
            files_up.sort()
            retval = (files_up, files[2])

        if exclude_ignored:
            return (self._filter_ignored_files(retval[0]), self._filter_ignored_files(retval[1]))

        return retval

    def run(self):
        self._check_changed()
        upload, remove = self._get_files()

        if self.opts.get('show'):
            self.ui.write(_('Upload files:\n'))
            for f in upload:
                self.ui.write('\t%s\n' % f)
            self.ui.write(_('\nDelete files:\n'))
            for f in remove:
                self.ui.write('\t%s\n' % f)

        self.ui.write(_('Upload files: %s, delete files: %s\n') %
                (len(upload), len(remove)) )

        if self.opts.get('upload'):
            if upload or remove:
                self._ftp(upload, remove)

            if not self.opts.get('only'):
                commands.tag(self.ui, self.repo, self.tagname,
                        local=not self.useGlobal,
                        rev=str(self.selected),
                        force=True)

                self.ui.write(_('Added tag %s for changeset %d:%s\n') %
                        (self.tagname, self.selected, self.selected))

    def _ftp(self, files_up, files_rm):
        """Get login/password and connect to server to upload/remove files"""
        ftp = ftplib.FTP()
        try:
            if self.url.port:
                ftp.connect(self.url.host, self.url.port)
            else:
                ftp.connect(self.url.host)

            user = self.url.user or self.ui.prompt('login:')
            psw = self.url.passwd or self.ui.getpass()

            ftp.login(user, psw)
        except ftplib.all_errors, error:
            raise util.Abort(_('Cannot login: %s') % error)

        if self.url.path:
            base = '/%s' % self.url.path
        else:
            base = ftp.pwd()

        if files_up:
            self.ftp_store(ftp, files_up, base)
        if files_rm:
            self.ftp_rm(ftp, files_rm, base)

        self.ui.write(_('Upload of changeset %d:%s to %s finished\n') %
                (self.selected, self.selected, self.url.host))

        ftp.close()

    def ftp_mkd(self, ftp, pathname, base):
        """Create non-existing directories on server"""
        ftp.cwd(base)
        for folder in pathname.split(os.sep):
            if folder != "":
                try:
                    ftp.cwd(folder)
                except ftplib.error_perm:
                    try:
                        ftp.mkd(folder)
                    except ftplib.all_errors, error:
                        raise util.Abort(_('Cannot create dir "%s": %s') %
                                (pathname, error))

                    if self.chmod_dir:
                        try:
                            ftp.voidcmd('SITE CHMOD %s %s' %
                                    (self.chmod_dir, folder))
                        except ftplib.all_errors, error:
                            self.ui.warn(_('Cannot CHMOD dir "%s": %s') %
                                    (pathname, error))
                    ftp.cwd(folder)

    def ftp_store(self, ftp, files, base):
        """Upload given files to server and create needed directories"""
        try:
            ftp.cwd(base)
        except ftplib.all_errors, error:
            raise util.Abort(_('Cannot change to basedir "%s": %s') %
                    (base, error))

        numberOfFiles = len(files)
        pos = 0
        for f in files:
            file = self.selected[f]
            pathname, filename = os.path.split( os.path.normpath(file.path()) )

            try:
                ftp.cwd(base + '/' + pathname)
            except ftplib.error_perm, error:
                self.ftp_mkd(ftp, pathname, base)

            try:
                filedata = StringIO(file.data())

                if util.binary(file.data()):
                    ftp.storbinary('STOR %s' % filename, filedata)
                else:
                    ftp.storlines('STOR %s' % filename, filedata)

                if self.chmod_file:
                    try:
                        ftp.voidcmd('SITE CHMOD %s %s' %
                                (self.chmod_file, filename))
                    except ftplib.all_errors, error:
                        self.ui.warn(_('Cannot CHMOD file "%s": %s') %
                                (file, error))

                filedata.close()
                pos += 1
                self.ui.progress(_('uploading'), pos, unit=_('files'), total=numberOfFiles)
            except ftplib.all_errors, error:
                raise util.Abort(_('Cannot upload file "%s": %s') %
                        (filename, error))
        self.ui.progress(_('uploading'), None)

    def ftp_rm(self, ftp, files, base):
        """Remove given files from server"""
        try:
            ftp.cwd(base)
        except ftplib.all_errors, error:
            raise util.Abort(_('Cannot change to basedir "%s": %s') %
                    (base, error))

        numberOfFiles = len(files)
        pos = 0
        for f in files:
            try:
                ftp.delete(base + '/' + f)
                pos += 1
                self.ui.progress(_('removing'), pos, unit=_('files'), total=numberOfFiles)
            except ftplib.all_errors, error:
                self.ui.warn(_('Cannot remove file "%s": %s\n') % (f, error))
        self.ui.progress(_('removing'), None)



def main(ui, repo, dest=None, **opts):
    """Manage snapshots on FTP server

    Upload snapshots of a revision to one or more FTP server.

    It will upload all files of a revision and set a (local) tag like
    "uploaded@host". If it will find an existing tag for that host it
    will remove vanished files and upload only the difference between
    that revision and the new one.

    Notes:
    If an error happens on server-side on deleting or CHMODing a file
    it will only print a warning about that but it will abort if it can't
    upload a file or create a directory.
    Since Mercurial doesn't track directories it won't delete existing
    directories on server even there is no file anymore.


    Possible settings in hgrc:

    [paths]
    ftp = ftp://[user[:pass]@]host[:port]/[path]
        ('ftp' will be used if DEST is not given)

    [ftp]
    chmod_file  = 644
    chmod_dir   = 755
    global_tags = False
    prefix_tags = uploaded@
    """

    obj = FtpManager(ui, repo, dest, opts)
    obj.run()


cmdtable = {
    'ftp': (main,
    [
        ('a', 'all', None, _('upload all files of a changeset; do not use the difference')),
        ('d', 'dir', '', _('CHMOD new directories to given mode')),
        ('f', 'file', '', _('CHMOD new/changed files to given mode')),
        ('g', 'global', None, _('make the tag global')),
        ('o', 'only', None, _('only upload or remove files; do not set a tag')),
        ('r', 'rev', '', _('revision that will be uploaded')),
        ('s', 'show', None, _('show files that will be uploaded or deleted')),
        ('t', 'tag', '', _('use another tag name')),
        ('u', 'upload', None, _('start uploading or removing changed files'))
    ],
    _('hg ftp [OPTION] [DEST]')),
}

# vim:set ts=4 sw=4 et:
