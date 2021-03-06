# ssh.zsh
#
# Because macOS sierra doesn't autoload ssh keys

if [[ $OS == "Darwin" ]]; then
  if ! ssh-add -l &> /dev/null; then
    ssh-add -K &> /dev/null
  fi
fi
