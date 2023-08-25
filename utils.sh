bold=`tput bold`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr0`

prompt_and_execute() {
  local prompt_message="$1"
  local function_to_run="$2"
  
  read -p "${green}$prompt_message (y/n): ${reset}" choice

  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    "$function_to_run"
  else
    echo "Step skipped..."
  fi
}

print_test_msg() {
  echo "****Test msg****"
}

