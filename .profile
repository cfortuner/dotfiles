# Use homebrew installations rather than OS default
export PATH=/usr/local/bin:"${PATH}"

# ITerm2
# Set CLICOLOR if you want Ansi Colors in iTerm2
export CLICOLOR=1
export TERM=xterm-256color

# Go
export GOPATH="${HOME}/code/go"
export PATH=$PATH:$GOPATH/bin

# Protobuf
export PATH=$PATH:$HOME/.protobuf/bin

# Python
eval "$(pyenv init -)"

# Autojump
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.

# Load RVM into a shell session *as a function*

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# BuilderToolbox
export PATH=$HOME/.toolbox/bin:$PATH

# Functions
declare -A ECHOCOLORS
ECHOCOLORS[black]=0
ECHOCOLORS[red]=1
ECHOCOLORS[green]=2
ECHOCOLORS[yellow]=3
ECHOCOLORS[blue]=4
ECHOCOLORS[magenta]=5
ECHOCOLORS[cyan]=6
ECHOCOLORS[white]=7

echocolor() {
  local color value

  if [[ $# -eq 0 ]]; then
    echocolor "red" "Must provide a color."
    return 1
  fi

  color="$1"
  if [ ! ${ECHOCOLORS[$color]+_} ]; then
    echocolor "red" "Invalid color choice."
    return 1
  fi

  value=${ECHOCOLORS[$color]}

  tput setaf "$value"
  echo "${@:2}"
  tput setaf ${ECHOCOLORS[white]}
}

# Aliases
alias ll="ls -al"
alias dgit='git --git-dir ~/.dotfiles/.git --work-tree=$HOME'

alias echo_color_red='echocolor red "$@"'
alias echo_color_green='echocolor green "$@"'


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# Check to see if we have saved awscreds
if [ -f "$HOME/.awscreds" ]; then
  #echo "Found aws creds."
  source "$HOME/.awscreds"
fi

# Aliases

alias awswhoami='aws iam list-account-aliases | jq .AccountAliases[0]'

# Exclude OSX specific files in ZIP archives
alias zip="zip -x *.DS_Store -x *__MACOSX* -x *.AppleDouble*"


export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
