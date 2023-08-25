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