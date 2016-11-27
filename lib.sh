# For pretty output
color () {
  tput setaf $2
  echo $1
  tput sgr0
}

red () {
  color "$1" 1
}

green () {
  color "$1" 2
}

blue () {
  color "$1" 4
}

# The return value of Bash function is the exit status of their last command;
# therefore, you can do things like [if is_osx; then ...].
is_osx () {
  [[ $(uname) == "Darwin" ]]
}

is_windows () {
  [[ $OS == "Windows_NT" ]]
}

# If a command [cmd] is not found in path, then [success_or cmd msg] prints
# [msg] if non-empty, then aborts with a non-zero exit status.
success_or ()
{
  if ! command -v $1 >/dev/null 2>&1; then
    red "ERROR: $1 not found"
    if [[ $2 != "" ]]; then
      echo "Hint: $2"
    fi
    exit 1
  fi
  echo ... $1 found
}

# [if_yes cmd] prompts the user, and runs [cmd] if user approved, and aborts
# otherwise
if_yes ()
{
  echo "Do you want to run: $1? [Y/n]"
  read ans
  case "$ans" in
    [Yy]|"")
      $1
      ;;

    *)
      exit 1
      ;;
  esac
}
