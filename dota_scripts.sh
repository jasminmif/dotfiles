setBottomMissionControl() {
  defaults write com.apple.dock wvous-br-corner -int 2
  killall Dock
  echo "+ Bottom right set to Mission Control"
}

removeAllMissionControlConfigs() {
  defaults write com.apple.dock wvous-br-corner -int 0
  killall Dock
  echo "- Removed all hot corners"
}

openStream() {
  open -a "Steam"
}

start_dota() {
  removeAllMissionControlConfigs
  openStream
}

exit_dota() {
  setBottomMissionControl
}



# This is used if we want to use this file as script check if the "action" argument is "remove"
# if [ "$1" == "remove" ]; then
#   removeAllMissionControlConfigs
#   openStream
# else
#   setBottomMissionControl
# fi
