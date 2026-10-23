# Oh My Zsh setup, shared by all Macs. install.sh sources this at the top of ~/.zshrc,
# so aliases defined later in ~/.zshrc override the plugins' ones (e.g. gbl).
# Change the theme or plugins here, push, and every Mac gets them on `dotsync pull`.

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Plugins that don't ship with Oh My Zsh: name -> git repo.
# A missing one is cloned the first time a shell starts on that Mac.
typeset -A custom_plugins=(
  zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
)

for name repo in "${(@kv)custom_plugins}"; do
  plugin_dir="${ZSH_CUSTOM:-$ZSH/custom}/plugins/$name"
  if [ ! -d "$plugin_dir" ]; then
    echo "Installing zsh plugin $name…"
    git clone --quiet --depth=1 "$repo" "$plugin_dir"
  fi
done
unset name repo plugin_dir

plugins=(
  git
  history
  z
  ${(k)custom_plugins}
)

source "$ZSH/oh-my-zsh.sh"
