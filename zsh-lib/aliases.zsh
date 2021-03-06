alias reload-shell="source $HOME/.zshrc"
alias rezsh="source $HOME/.zshrc"

title() {
  echo -ne "\033]0;"$*"\007"
}

ecr-login() {
  if [[ ! -z $1 ]]; then
    profile="$1"
  elif [[ ! -z $AWS_PROFILE ]]; then
    profile="$AWS_PROFILE"
  else
    profile=""
  fi

  # get account id
  sts=$(aws --profile="$profile" sts get-caller-identity)
  account=$(echo "$sts" | jq -r '.Account')

  env AWS_PROFILE="$profile" aws ecr get-login-password | docker login --username AWS --password-stdin "${account}.dkr.ecr.us-east-1.amazonaws.com"
}

amis() {
  if [[ ! -z $AWS_PROFILE ]]; then
    profile="$AWS_PROFILE"
  else
    profile="prod-admin"
  fi



  if [[ ! -z "$1" ]]; then
    name="$1"
  else
    name="*"
  fi

  output=$(env AWS_PROFILE="$profile" aws ec2 describe-images --owners self --filters Name=tag:ami_name,Values=$name)

  echo "$output" | jq -S '.Images | [.[] | (.Tags | .[] | select(.Key == "ami_name") | .Value) as $name | (.Tags | .[] | select(.Key == "ami_version") | .Value) as $version | .ImageId as $id | {($name): {($version): $id}}] | reduce .[] as $n ({}; . * $n)'
}
