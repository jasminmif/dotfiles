alias listening="sudo lsof -iTCP -sTCP:LISTEN -n -P"

if [ -f "$HOME/dotfiles/run_ros_branch_tests.sh" ]; then
  source "$HOME/dotfiles/run_ros_branch_tests.sh"
fi


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

ros_path="$HOME/GitHub/ros"

r() {
  cd "$ros_path" || return
}

rtests() {
  r
  run_ros_branch_tests "$@"
}

rtestsweb() {
  r
  run_ros_branch_tests web "$@"
}

rtestsapi() {
  r
  run_ros_branch_tests api "$@"
}

rtestsall() {
  r
  run_ros_branch_tests all "$@"
}

gpull() {
  r
  BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$BRANCH" = "main" ]; then
    git pull --tags
  else
    git pull --tags --rebase origin main
  fi
}

gpushreview() {
  r || return
  local ret
  (
    export ENABLE_PUSH_REVIEW=true
    git push "$@"
  )
  ret=$?
  export ENABLE_PUSH_REVIEW=false
  return "$ret"
}

gpush () {
	BRANCH="$(git rev-parse --abbrev-ref HEAD)"
	if [ -z "$BRANCH" ]
	then
		echo "not on valid branch; select valid branch to push"
	elif [ $BRANCH = "master" ]
	then
		git push
	elif [ $BRANCH = "HEAD" ]
	then
		echo "cannot push, you're probably in a detatched head state"
	else
		git push -u origin $BRANCH || {
			echo "Push failed, force pushing to remote..."
			git push -fu origin $BRANCH
		}
	fi
}

gpushempty () {
	git commit --allow-empty -m "Trigger Tests" -n && gpush
}

rdev() {
  r
  npm run dev -- default api,web 
}

rmigrate() {
  npm run api db:migrate
}

rrollback() {
  npm run api db:rollback
}

ros-is-pr-deployed() {
  local PR=$1
  local ENV=${2:-prod}
  if [[ -z "$PR" ]]; then
    echo "Usage: ros-is-pr-deployed <pr-number> [prod|staging]"
    return 1
  fi
  # Map env -> ROS API base url (see ros-auto-github/lib/ros.ts ROSConfig)
  local API_URL ENV_LABEL
  case "$ENV" in
    prod|production|Prod|PROD)      API_URL="https://api.ros.rbx.com";     ENV_LABEL="production" ;;
    stg|staging|Staging|STAGING)    API_URL="https://api.ros-stg.rbx.com"; ENV_LABEL="staging" ;;
    *) echo "Error: unknown env '$ENV' (use 'prod' or 'staging')"; return 1 ;;
  esac
  # Squash-merge commits on main end with "(#<PR>)". The parens anchor the match
  # so #123 doesn't also match #1234.
  local PR_COMMIT
  PR_COMMIT=$(git log --pretty=format:'%H %s' origin/main \
    | grep -E "\(#${PR}\)( |$)" | head -1 | cut -d' ' -f1)
  [[ -z "$PR_COMMIT" ]] && { echo "Error: can't find PR #${PR} on origin/main"; return 1; }
  # Deployed commit sha comes from the env's /ping endpoint (short sha).
  local DEPLOYED_SHA
  DEPLOYED_SHA=$(curl -fsS "${API_URL}/ping" | grep -oE '"commitSha":"[^"]+"' | cut -d'"' -f4)
  [[ -z "$DEPLOYED_SHA" ]] && { echo "Error: can't read deployed commit from ${API_URL}/ping"; return 1; }
  # The deployed sha may not exist locally if main is behind — fetch quietly so
  # git merge-base can resolve it.
  git cat-file -e "${DEPLOYED_SHA}^{commit}" 2>/dev/null || git fetch origin main --quiet
  local PR_MSG="PR #${PR} (${PR_COMMIT:0:9})"
  if git merge-base --is-ancestor "$PR_COMMIT" "$DEPLOYED_SHA" 2>/dev/null; then
    echo "✅ YES!, $PR_MSG HAS been deployed to $ENV_LABEL (deployed: $DEPLOYED_SHA)"
    return 0
  else
    echo "❌ NO, $PR_MSG has NOT been deployed to $ENV_LABEL (deployed: $DEPLOYED_SHA)"
    return 1
  fi
}