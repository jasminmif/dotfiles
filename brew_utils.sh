
#!/bin/bash

install_brew() {
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" || return $?
  else
    echo "You already have Homebrew installed...good job!"
  fi
}

# List of casks to install
casks=(
  "rectangle"
  "visual-studio-code"
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


