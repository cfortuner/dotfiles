# Use homebrew installations rather than OS default 
export PATH=/usr/local/bin:"${PATH}"

# ITerm2
# Set CLICOLOR if you want Ansi Colors in iTerm2 
export CLICOLOR=1
export TERM=xterm-256color

# Go
export GOPATH="${HOME}/code/go"
export GOROOT=/usr/local/Cellar/go/1.11.5/libexec
export PATH=$PATH:$(go env GOPATH)/bin

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

# Aliases 
alias ll="ls -al"
alias dgit='git --git-dir ~/.dotfiles/.git --work-tree=$HOME'

# Functions
declare -A ECHOCOLORS=(
                        ["black"]=0
                        ["red"]=1
                        ["green"]=2
                        ["yellow"]=3
                        ["blue"]=4
                        ["magenta"]=5
                        ["cyan"]=6
                        ["white"]=7)

echocolor() {
  local color value

  if [[ $# -eq 0 ]]; then
    echocolor "red" "Must provide a color."
    exit 1
  fi

  color="$1"
  value=${ECHOCOLORS["$color"]}
  echo $value

  tput setaf value 
  echo "${@:2}"  
}

echo.green() {
  tput setaf 2 
  echo $@
}

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*


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

awscredspls() {
  local account oldid newid
  account=$1

  oldid=$(echo "$AWS_ACCESS_KEY_ID")

  mwinit
  getMidwayCreds() "$1"

  newid=$(echo "$AWS_ACCESS_KEY_ID")

  if [!"$oldid" == "$newid"]; then
    echo.red "Error fetching temporary aws credentials."
  else
    echo.green "Success! Now authenticated with:"
    echo "$account"
  fi
}


# Aliases

alias awswhoami="aws iam list-account-aliases | jq .AccountAliases[0]"
