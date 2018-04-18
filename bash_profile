YELLOW="\[\033[33;1m\]"
NORMAL="\[\033[0m\]"

source $HOME/scripts/git-prompt.sh

export PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]${YELLOW}\$(__git_ps1)${NORMAL}$ "
