#!/bin/bash

source ./utils.sh
source ./brew_utils.sh

echo "${yellow}${bold}Dotfile workstation setup scripts${reset}"

ZSHRC_PATH=~/.zshrc
DOTFILES_PATH=~/dotfiles

source ./dota_scripts.sh

scripts_to_source=(
  "$DOTFILES_PATH/dota_scripts.sh"
  "$DOTFILES_PATH/jasmin_utils.sh"
  # Add more script paths here
  # "$DOTFILES_PATH/work_utils.sh"
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

aliases=(
  "alias gs=\"git status\""
  "alias gcm=\"gcmsg\""
  "alias gco-=\"gco -\""
  "alias gbl=\"git branch --sort=-committerdate\""
  "alias listening=\"sudo lsof -iTCP -sTCP:LISTEN -n -P\""
)

add_aliases_to_zshrc() {
  for alias_line in "${aliases[@]}"; do
    if ! grep -q "$alias_line" "$ZSHRC_PATH"; then
      echo "Adding alias: $alias_line"
      echo "$alias_line" >> "$ZSHRC_PATH"
    else
      echo "Alias already exists: $alias_line"
    fi
  done
}

add_aliases_to_zshrc

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

remove_all_dock_pinned_apps() {
  # Disable the Dock
  defaults write com.apple.dock autohide -bool true

  # Remove all Dock icons
  defaults write com.apple.dock persistent-apps -array
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
  prompt_and_execute "Do you want to remove all pinned apps from dock?" "remove_all_dock_pinned_apps"
  restart_dock
}

remmove_all_icons_from_dock() {
  defaults write com.apple.dock persistent-apps -array
}

prompt_set_doc_config() {
  prompt_and_execute "Do you want to set the preferred doc configurations?" "set_mac_dock_config"
}

prompt_install_brew_and_casks() {
  prompt_and_execute "Do you want to install Brew?" "install_brew"
  
  if ! is_brew_installed; then
    return
  fi

  prompt_and_execute "Do you want to install Brew casks and formula?" "install_brew_cask_formula"
}

prompt_set_doc_config
prompt_install_brew_and_casks
add_zsh_plugin_if_not_exists 'z'
