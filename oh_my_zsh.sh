# Oh My Zsh setup, shared by all Macs. install.sh sources this at the top of ~/.zshrc,
# so aliases defined later in ~/.zshrc override the plugins' ones (e.g. gbl).
# Change the theme or plugins here, push, and every Mac gets them on `dotsync pull`.

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  history
  z
)

source "$ZSH/oh-my-zsh.sh"
