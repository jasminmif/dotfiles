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
  ggn &&
    node \
      --max_old_space_size=12138 \
      --stack_size=4096 \
      ./node_modules/webpack/bin/webpack.js \
      --config ./webpack.config.js "$@"
}

jgndev() {
  ggn &&
    NODE_OPTIONS="--max-old-space-size=8096" npx react-native webpack-start "$@"
}