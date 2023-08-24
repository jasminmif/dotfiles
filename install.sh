#!/bin/bash

bold=$(tput bold)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

echo "${yellow}${bold}Dotfile workstation setup scripts${reset}"

ZSHRC_PATH=~/.zshrc
DOTFILES_PATH=~/dotfiles

source ./dota_scripts.sh

scripts_to_source=(
  "$DOTFILES_PATH/dota_scripts.sh",
  "$DOTFILES_PATH/jasmin_utils.sh"
  # Add more script paths here
)

for script_path in "${scripts_to_source[@]}"; do
  # Check if the script is already sourced
  if grep -q "source $script_path" "$ZSHRC_PATH"; then
    echo "The script $script_path is already sourced in $ZSHRC_PATH"
  else
    # If not sourced, append the sourcing line to .zshrc
    echo "source $script_path" >> "$ZSHRC_PATH"
    echo "Sourced $script_path in $ZSHRC_PATH"
  fi
done


set_dock_orientation_to_left() {
  echo "Set the dock orientation to the left"
  defaults write com.apple.dock orientation -string left
}

set_dock_auto_hide() {
  echo "Enable auto-hide for the dock"
  defaults write com.apple.dock autohide -bool true
}

set_prefered_dock_size() {
  tilesize=57
  echo "Set dock icon tilesize to $tilesize"
  defaults write com.apple.dock "tilesize" -int "$tilesize"
}

restart_dock() {
  echo "Restarting the Dock to apply changes"
  killall Dock
}

set_mac_dock_config() {
  echo "Settings dock preferred configurations"
  setBottomMissionControl
  set_dock_orientation_to_left
  set_dock_auto_hide
  set_prefered_dock_size
  restart_dock
}

remmove_all_icons_from_dock() {
  defaults write com.apple.dock persistent-apps -array
}

print_test_msg() {
  echo "****Test msg****"
}

prompt_and_execute() {
  local prompt_message="$1"
  local function_to_run="$2"
  
  read -p "$prompt_message (y/n): " choice

  if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    "$function_to_run"
  else
    echo "Function not executed."
  fi
}

prompt_set_doc_config() {
  prompt_and_execute "Do you want to set the preferred doc configurations?" "set_mac_dock_config"
}

prompt_set_doc_config
