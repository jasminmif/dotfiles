_ros_branch_tests_usage() {
  cat <<'EOF'
Usage:
  run_ros_branch_tests <web|api|all> <branch>
  run_ros_branch_tests <branch> <web|api|all>

Examples:
  run_ros_branch_tests web example
  run_ros_branch_tests example all
EOF
}

_ros_branch_tests_is_suite() {
  case "$1" in
    web | api | all) return 0 ;;
    *) return 1 ;;
  esac
}

_ros_branch_tests_parse_args() {
  if [[ $# -ne 2 ]]; then
    _ros_branch_tests_usage
    return 1
  fi

  if _ros_branch_tests_is_suite "$1"; then
    test_suite="$1"
    branch_name="$2"
  elif _ros_branch_tests_is_suite "$2"; then
    branch_name="$1"
    test_suite="$2"
  else
    echo "Expected one argument to be web, api, or all." >&2
    _ros_branch_tests_usage
    return 1
  fi
}

_ros_branch_tests_set_repo_root() {
  if declare -f r >/dev/null 2>&1; then
    ros_repo_root="$(
      (
        r >/dev/null 2>&1 || exit 1
        pwd
      )
    )"

    if [[ -n "$ros_repo_root" ]]; then
      return 0
    fi
  fi

  ros_repo_root="${ROS_REPO_ROOT:-${ros_path:-$HOME/GitHub/ros}}"
  [[ -n "$ros_repo_root" ]]
}

_ros_branch_tests_in_repo() {
  if declare -f r >/dev/null 2>&1; then
    (
      r >/dev/null 2>&1 || exit 1
      "$@"
    )
    return $?
  fi

  (
    cd "$ros_repo_root" || exit 1
    "$@"
  )
}

_ros_branch_tests_validate_repo() {
  if [[ ! -d "$ros_repo_root" ]]; then
    echo "ROS repo root does not exist: $ros_repo_root" >&2
    return 1
  fi

  if ! _ros_branch_tests_in_repo git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repo: $ros_repo_root" >&2
    return 1
  fi
}

_ros_branch_tests_fetch_origin() {
  echo "Fetching latest changes from origin"
  _ros_branch_tests_in_repo git fetch origin --prune
}

_ros_branch_tests_validate_branch() {
  if ! _ros_branch_tests_in_repo git show-ref --verify --quiet "refs/heads/$branch_name" &&
     ! _ros_branch_tests_in_repo git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
    echo "Branch '$branch_name' was not found locally or on origin." >&2
    return 1
  fi
}

_ros_branch_tests_set_worktree_paths() {
  repo_parent="$(cd -- "${ros_repo_root}/.." && pwd)"
  repo_name="$(basename "$ros_repo_root")"
  sanitized_branch="$(printf '%s' "$branch_name" | tr '/:@' '---')"
  worktree_base="${ROS_WORKTREE_BASE:-${repo_parent}/${repo_name}-worktrees}"
  worktree_path="${worktree_base}/${sanitized_branch}-${test_suite}-tests"
}

_ros_branch_tests_worktree_exists() {
  local line

  while IFS= read -r line; do
    if [[ "$line" == "worktree $worktree_path" ]]; then
      return 0
    fi
  done < <(_ros_branch_tests_in_repo git worktree list --porcelain)

  return 1
}

_ros_branch_tests_prepare_worktree() {
  if _ros_branch_tests_worktree_exists; then
    echo "Reusing existing worktree: $worktree_path"
    return 0
  fi

  if [[ -e "$worktree_path" ]]; then
    echo "Path already exists but is not a registered git worktree: $worktree_path" >&2
    return 1
  fi

  if _ros_branch_tests_in_repo git show-ref --verify --quiet "refs/heads/$branch_name"; then
    _ros_branch_tests_in_repo git worktree add --force "$worktree_path" "$branch_name"
    return $?
  fi

  _ros_branch_tests_in_repo git worktree add -b "$branch_name" "$worktree_path" "origin/$branch_name"
}

_ros_branch_tests_pull_latest_changes() {
  if ! _ros_branch_tests_in_repo git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
    return 0
  fi

  (
    cd "$worktree_path" || exit 1

    if [[ -n "$(git status --porcelain)" ]]; then
      echo "Worktree has local changes; skipping pull from origin/$branch_name" >&2
      return 0
    fi

    echo "Pulling latest changes from origin/$branch_name"
    git pull --ff-only origin "$branch_name"
  )
}

_ros_branch_tests_link_dependencies() {
  if [[ -d "${ros_repo_root}/node_modules" && ! -e "${worktree_path}/node_modules" ]]; then
    ln -s "${ros_repo_root}/node_modules" "${worktree_path}/node_modules"
  fi
}

_ros_branch_tests_run_suite() {
  (
    cd "$worktree_path" || exit 1

    case "$test_suite" in
      web)
        echo "Running web tests in $worktree_path"
        npm run web test
        ;;
      api)
        echo "Running api tests in $worktree_path"
        npm run api test
        ;;
      all)
        echo "Running all tests in $worktree_path"
        npm run web test && npm run api test
        ;;
    esac
  )
}

_ros_branch_tests_cleanup() {
  _ros_branch_tests_in_repo git worktree remove --force "$worktree_path" &&
    _ros_branch_tests_in_repo git worktree prune
}

_ros_branch_tests_wait_for_fix() {
  local response

  while true; do
    echo
    echo "Tests are still failing."
    echo "Worktree kept at: $worktree_path"
    echo "Fix the code there, then rerun from this prompt."
    printf "Press Enter to rerun, type 'shell' to open a shell there, or 'abort' to keep the worktree and exit: "
    IFS= read -r response

    case "$response" in
      "" | rerun)
        if _ros_branch_tests_run_suite; then
          return 0
        fi
        ;;
      shell)
        (
          cd "$worktree_path" || exit 1
          "${SHELL:-/bin/bash}"
        )
        ;;
      abort | exit | quit)
        echo "Leaving worktree in place: $worktree_path"
        return 1
        ;;
      *)
        echo "Unknown option: $response"
        ;;
    esac
  done
}

run_ros_branch_tests() {
  local test_suite branch_name ros_repo_root repo_parent repo_name sanitized_branch
  local worktree_base worktree_path

  _ros_branch_tests_parse_args "$@" || return 1
  _ros_branch_tests_set_repo_root || return 1
  _ros_branch_tests_validate_repo || return 1
  _ros_branch_tests_fetch_origin || return 1
  _ros_branch_tests_validate_branch || return 1
  _ros_branch_tests_set_worktree_paths

  mkdir -p "$worktree_base"

  _ros_branch_tests_prepare_worktree || return 1
  _ros_branch_tests_pull_latest_changes || return 1
  _ros_branch_tests_link_dependencies

  if _ros_branch_tests_run_suite; then
    echo "Tests passed. Removing worktree: $worktree_path"
    _ros_branch_tests_cleanup
    return $?
  fi

  if _ros_branch_tests_wait_for_fix; then
    echo "Tests passed after rerun. Removing worktree: $worktree_path"
    _ros_branch_tests_cleanup
    return $?
  fi

  return 1
}
