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

add_zsh_plugin_if_not_exists() {
  plugin_name="$1"
  if grep -q "plugins=([^)]*${plugin_name}[^)]*)" "$ZSHRC_PATH"; then
    echo "Plugin '$plugin_name' is already in the plugins array."
  else
    # Add the plugin to the plugins array
    sed -i.bak '/^plugins=(/ s/)/ '"$plugin_name"')/' "$ZSHRC_PATH"
    echo "Plugin '$plugin_name' has been added to the plugins array in your ~/.zshrc file."
  fi
}

bold=$(tput bold)
yellow=$(tput setaf 3)
reset=$(tput sgr0)
