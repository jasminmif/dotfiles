alias listening="sudo lsof -iTCP -sTCP:LISTEN -n -P"

scroll_up() {
  adb shell input swipe 500 500 1000 3800
}

scroll_down() {
  adb shell input swipe 500 1000 500 0 50
}

scroll_down_slow() {
  adb shell input swipe 500 1000 500 800 50
}

scroll_up_slow() {
  adb shell input swipe 500 500 500 1000
}

scroll_up_down() {
  scroll_up
  sleep 3
  scroll_up_slow
  sleep 2
  scroll_up
  sleep 2
  scroll_up

  sleep 3

  scroll_down
  sleep 3
  scroll_down_slow
  sleep 2
  scroll_down
}

gnbuildalert() {
  gnbuild && afplay /System/Library/PrivateFrameworks/ScreenReader.framework/Versions/A/Resources/Sounds/AnimationFlyToDownloads.aiff &
}

open_sim_link() {
  xcrun simctl openurl booted "guildeddev://localhost:8000/?r=lo4PRzmR"
}

adb_reverse() {
  adb reverse tcp:8081 tcp:8081
}

jgnbuild() {
  ggn
  if [[ "$PLATFORM" == "android" ]]; then
    WEBPACK_VERBOSE=$verbose yarn run bundle-android "$@"
  else
    WEBPACK_VERBOSE=$verbose yarn run bundle-ios "$@"
  fi
}

jgndev() {
  ggn && yarn run start-dev-server "$@"
}

jgndevandroid() {
  export ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
  export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
  export ANDROID_AVD_HOME="${ANDROID_AVD_HOME:-$HOME/.android/avd}"

  emulator_avd_name="$($ANDROID_SDK_ROOT/emulator/emulator -list-avds | sed -n '2 p')"
  echo -e "${YELLOW}[guilded_profile.sh]${RESET_COLOR}📱 Starting Default Android Emulator with AVD name: ${CYAN}$emulator_avd_name${RESET_COLOR}
  ${LIGHT_GRAY}(this is just the first one in your AVD list; you can change this by reorganizing your list in Android Studio)${RESET_COLOR}"
    $ANDROID_SDK_ROOT/emulator/emulator -avd "$emulator_avd_name" &

  ggn
  echo -e "${YELLOW}[guilded_profile.sh]${RESET_COLOR} Uninstalling previous build of app" &&
    adb shell "pm uninstall com.guilded.guildedapp.debug" >/dev/null
  echo -e "${YELLOW}[guilded_profile.sh]${RESET_COLOR} Clearing previous install data" &&
    adb shell "rm -rf /data/app/com.guilded.guildedapp.debug*" >/dev/null

  ./node_modules/.bin/react-native run-android --appIdSuffix debug --active-arch-only "$@"
}