NORMAL="\[\033[0m\]"
YELLOW="\[\033[33;1m\]"
RED="\[\033[31;1m\]"
WHITE="\[\033[37;1m\]"
PURPLE="\[\033[35;1m\]"
BLUE="\[\033[34;1m\]"
GREEN="\[\033[32;1m\]"

source $HOME/.bin/git-prompt.sh

export PS1="${debian_chroot:+($debian_chroot)}${GREEN}\u@\h${NORMAL}:${BLUE}\w${PURPLE}\$(__git_ps1)${NORMAL}$ "
