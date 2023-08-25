prompt_and_execute() {
  local prompt_message="$1"
  local function_to_run="$2"
  
  read -p "$prompt_message (y/n): " choice

  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    "$function_to_run"
  else
    echo "Step skipped..."
  fi
}

print_test_msg() {
  echo "****Test msg****"
}

bold=$(tput bold)
yellow=$(tput setaf 3)
reset=$(tput sgr0)
