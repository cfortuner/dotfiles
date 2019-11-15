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
  echo "Found aws creds."
  source "$HOME/.awscreds"
fi


#-----------------
## Twitch Specific
#-----------------

# Isengard AWS Creds

getMidwayCreds() {
  # Get account id and role, generate json payload
  JSONBITS=$(curl -Ls -b ~/.midway/cookie -c ~/.midway/cookie -H "x-amz-target: com.amazon.isengard.coral.IsengardService.GetPermissionsForUser" --header "Content-Encoding: amz-1.0" -X POST https://isengard-service.amazon.com/ | jq -r '.PermissionsForUserList[] | select(.AWSAccountMoniker.Status == "ACTIVE") | if .AWSAccountMoniker.Alias != null then .ProfileName = [.AWSAccountMoniker.Alias] else .ProfileName = .AWSAccountMoniker.Email / "@" end | select(.ProfileName[0] == "'$1'") | {AWSAccountID: .AWSAccountID, IAMRoleName: .IAMRoleNameList[0]}')

  # Using said JSON payload, get the variables to assume the roles, and then display them in shell variable form
  # You can also $(eval getMidwayCreds)
  # This is ugly because nested JSON.
  curl -Ls -b ~/.midway/cookie -c ~/.midway/cookie -H "x-amz-target: com.amazon.isengard.coral.IsengardService.GetAssumeRoleCredentials" --data-binary "${JSONBITS}" --header "Content-Encoding: amz-1.0" --header "Content-type: application/json" -X POST https://isengard-service.amazon.com/ | jq -r . | jq -r .AssumeRoleResult | jq -r '"export AWS_ACCESS_KEY_ID=\(.credentials.accessKeyId)\nexport AWS_SECRET_ACCESS_KEY=\(.credentials.secretAccessKey)\nexport AWS_SESSION_TOKEN=\(.credentials.sessionToken)"'

}

awscredsreset() {
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SECRET_KEY_ID
  unset AWS_SESSION_ID
  unset AWS_PROFILE

  # removing the .awscreds file
  touch ~/.awscreds
  rm ~/.awscreds

  echo_color_green "ok...done"
}

awscredspls() {
  local account

  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SECRET_KEY_ID
  unset AWS_SESSION_ID
  unset AWS_PROFILE

  if [[ $# -eq 0 ]]; then
    set --
    echo_color_red "Must provide an account"
    return 1
  fi

  account=$1
  set --

  mwinit --aea
  eval $(getMidwayCreds "$account")

  if [ -z $AWS_ACCESS_KEY_ID ]; then
    echo_color_red "Error fetching credentials."
    return 1
  fi

  # Saving to file so we can access them in other tabs/windows
  echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"           > ~/.awscreds
  echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"  >> ~/.awscreds
  echo "export AWS_SECRET_KEY_ID=$AWS_SECRET_KEY_ID"          >> ~/.awscreds
  echo "export AWS_SESSION_ID=$AWS_SESSION_ID"                >> ~/.awscreds
  echo "export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN"          >> ~/.awscreds

  echo_color_green "Now authenticated with:"
  echo "$account"
}


# Aliases

alias awswhoami='aws iam list-account-aliases | jq .AccountAliases[0]'
