export ARCHFLAGS="-arch i386 -arch x86_64"


# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

function parse_svn_revision() {
  local DIRTY REV=$(svn info 2>/dev/null | grep Revision | sed -e 's/Revision: //')
  [ "$REV" ] || return
  #[ "$(svn st | grep -e '^ \?[M?] ')" ] && DIRTY='*'
  echo "(r$REV$DIRTY)"
}

function parse_git_branch() {
  local DIRTY STATUS
  STATUS=$(git status --porcelain 2>/dev/null)
  [ $? -eq 128 ] && return
  [ -z "$(echo "$STATUS" | grep -e '^ M')"    ] || DIRTY="*"
  [ -z "$(echo "$STATUS" | grep -e '^[MDA]')" ] || DIRTY="${DIRTY}+"
  [ -z "$(git stash list)" ]                    || DIRTY="${DIRTY}^"
  echo "($(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* //')$DIRTY)"
}

export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]$(parse_git_branch)$(parse_svn_revision)\[\033[01;34m\]\[\033[00m\]\$ '
export CLICOLOR=1

eval "`pip completion --bash`"
