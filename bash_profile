NORMAL="\[\033[0m\]"
YELLOW="\[\033[33;1m\]"
RED="\[\033[31;1m\]"
WHITE="\[\033[37;1m\]"
PURPLE="\[\033[35;1m\]"
BLUE="\[\033[34;1m\]"
GREEN="\[\033[32;1m\]"

source $HOME/.bin/git-prompt.sh

export PS1="${__pyenv_ps1}${debian_chroot:+($debian_chroot)}${GREEN}\u@\h${NORMAL}:${BLUE}\w${PURPLE}\$(__git_ps1)${NORMAL}$ "

pyenv_prompt() {
  [ -z "$PYENV_VIRTUALENV_ORIGINAL_PS1" ] && export PYENV_VIRTUALENV_ORIGINAL_PS1="$PS1"
  # Cache the global pyenv env name to speed things up.
  [ -z "$PYENV_VIRTUALENV_GLOBAL_NAME" ] && export PYENV_VIRTUALENV_GLOBAL_NAME="$(pyenv global)"
  VENV_NAME="$(pyenv version-name)"
  VENV_NAME="${VENV_NAME##*/}"

  PS1="$PYENV_VIRTUALENV_ORIGINAL_PS1"
  if [[ "${PYENV_VIRTUALENV_GLOBAL_NAME}" != "${VENV_NAME}" ]]; then
    PS1="$YELLOW(${VENV_NAME})$NORMAL$PYENV_VIRTUALENV_ORIGINAL_PS1"
  fi
  export PS1
}
export PROMPT_COMMAND="$PROMPT_COMMAND pyenv_prompt;"
