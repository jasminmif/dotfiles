
#!/bin/bash

is_brew_installed() {
  if command -v brew > /dev/null 2>&1; then
    return 0  # Homebrew is installed
  else
    return 1  # Homebrew is not installed
  fi
}

install_brew() {
  if ! is_brew_installed; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" || return $?

    if [ -e /opt/homebrew/bin/brew ]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  else
    echo "You already have Homebrew installed...good job!"
  fi
}

# List of casks to install
casks=(
  "rectangle"
  "visual-studio-code"
  "obsidian"
  "iterm2"
  "alfred"
  "ngrok"
  "spotify"
  "blackhole-2ch"
  "flipper"
  "steam"
  "firefox"
  "opera"

  # "slack"
  # "ngrok"
  # "dbeaver-community"
  # Add more casks here
)

# List of formulas to install
formulas=(
#   "git"
#   "node"
  # Add more formulas here
)

install_brew_cask_formula() {
  # Install casks
  for cask in "${casks[@]}"; do
    if brew list --cask "$cask" > /dev/null 2>&1; then
      echo "Cask \"$cask\" is already installed."
    else
      brew install --cask "$cask"
    fi
  done
  
  # Install formulas
  for formula in "${formulas[@]}"; do
    if brew list "$formula" > /dev/null 2>&1; then
      echo "Formula $formula is already installed."
    else
      brew install "$formula"
    fi
  done
  
  echo "Brew cask and formulas installation complete."
}


