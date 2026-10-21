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

add_line_to_zshrc_if_not_exists() {
  local line="$1"
  # -xF: match the whole line literally, so lines with regex characters aren't added twice
  if grep -qxF "$line" "$ZSHRC_PATH"; then
    echo "Already in $ZSHRC_PATH: $line"
  else
    echo "$line" >> "$ZSHRC_PATH"
    echo "Added to $ZSHRC_PATH: $line"
  fi
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed."
  else
    # Clone instead of running the official installer, which would replace ~/.zshrc
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" || return $?
  fi

  # Oh My Zsh has to load first, so it goes at the top of ~/.zshrc
  local line="source $DOTFILES_PATH/oh_my_zsh.sh"
  if grep -qxF "$line" "$ZSHRC_PATH"; then
    echo "Already in $ZSHRC_PATH: $line"
  else
    { echo "$line"; cat "$ZSHRC_PATH"; } > "$ZSHRC_PATH.tmp" && mv "$ZSHRC_PATH.tmp" "$ZSHRC_PATH"
    echo "Added to the top of $ZSHRC_PATH: $line"
  fi
}
