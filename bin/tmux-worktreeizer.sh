#!/usr/bin/env bash

set -euo pipefail

REPOS_DIR="$HOME/dev/repos"
WORKTREES_DIR="$REPOS_DIR/worktrees"

# -------------------------------------------------------------------
# Docker-style random names
# -------------------------------------------------------------------

adjectives=(
  brave calm clever eager fancy gentle happy jolly kind lucky
  nifty proud quiet rapid sharp silly sleepy sunny tiny wild
)

names=(
  badger beaver bison cobra dolphin eagle falcon fox gecko
  heron koala lemur otter panda raven sloth tiger turtle wolf
)

random_name() {
  local adjective name
  adjective="${adjectives[$RANDOM % ${#adjectives[@]}]}"
  name="${names[$RANDOM % ${#names[@]}]}"
  echo "${adjective}_${name}"
}

# -------------------------------------------------------------------
# Pick project
# -------------------------------------------------------------------

if [[ $# -eq 1 ]]; then
  selected="$1"
else
  selected="$(
    find "$REPOS_DIR" \
      -mindepth 1 \
      -maxdepth 1 \
      -type d \
      ! -name "worktrees" \
      | fzf --prompt="Project: "
  )"
fi

[[ -z "${selected:-}" ]] && exit 0

if ! git -C "$selected" rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "Not a Git repository: $selected"
  read -rp "Press enter to exit..."
  exit 1
fi

project_root="$(git -C "$selected" rev-parse --show-toplevel)"
project_name="$(basename "$project_root")"

# -------------------------------------------------------------------
# Enter branch name
# -------------------------------------------------------------------

read -rp "New branch name: " branch_name

if [[ -z "$branch_name" ]]; then
  echo "Branch name cannot be empty."
  read -rp "Press enter to exit..."
  exit 1
fi

# Optional safety: prevent accidental duplicate branch names
if git -C "$project_root" show-ref --verify --quiet "refs/heads/$branch_name"; then
  echo "Local branch already exists: $branch_name"
  read -rp "Press enter to exit..."
  exit 1
fi

# -------------------------------------------------------------------
# Select base branch
# -------------------------------------------------------------------

base_branch="$(
  git -C "$project_root" branch --all --format="%(refname:short)" \
    | sed 's#^origin/##' \
    | grep -v HEAD \
    | sort -u \
    | fzf --prompt="Base branch: "
)"

[[ -z "$base_branch" ]] && exit 0

# Prefer local branch if it exists, otherwise use origin/<branch>
if git -C "$project_root" show-ref --verify --quiet "refs/heads/$base_branch"; then
  start_point="$base_branch"
elif git -C "$project_root" show-ref --verify --quiet "refs/remotes/origin/$base_branch"; then
  start_point="origin/$base_branch"
else
  echo "Could not find base branch: $base_branch"
  read -rp "Press enter to exit..."
  exit 1
fi

# -------------------------------------------------------------------
# Create worktree path
# -------------------------------------------------------------------

worktree_name="$(random_name)"
worktree_dir="$WORKTREES_DIR/$project_name/$worktree_name"

while [[ -e "$worktree_dir" ]]; do
  worktree_name="$(random_name)"
  worktree_dir="$WORKTREES_DIR/$project_name/$worktree_name"
done

mkdir -p "$(dirname "$worktree_dir")"

echo
echo "Project:    $project_name"
echo "Base:       $start_point"
echo "Branch:     $branch_name"
echo "Worktree:   $worktree_dir"
echo

git -C "$project_root" fetch --all --prune

git -C "$project_root" worktree add \
  -b "$branch_name" \
  "$worktree_dir" \
  "$start_point"

# -------------------------------------------------------------------
# Create tmux session layout
# -------------------------------------------------------------------

safe_branch_name="$(echo "$branch_name" | tr '/.' '__')"
session_name="${project_name}:${safe_branch_name}"
tmux_running="$(pgrep tmux || true)"

if tmux has-session -t "$session_name" 2>/dev/null; then
  echo "tmux session already exists: $session_name"
  read -rp "Press enter to exit..."
  exit 1
fi

if [[ -z "${TMUX:-}" ]] && [[ -z "$tmux_running" ]]; then
  target_window="$(tmux new-session -d -P -F '#{window_id}' -s "$session_name" -c "$worktree_dir")"
else
  target_window="$(tmux new-session -d -P -F '#{window_id}' -s "$session_name" -c "$worktree_dir")"
fi

# Pane 0: opencode
tmux send-keys -t "$target_window.0" "opencode" C-m

# Pane 1: lazygit on the right
tmux split-window -t "$target_window.0" -h -p 50 -c "$worktree_dir"
tmux send-keys -t "$target_window.1" "lazygit" C-m

# Pane 2: clean terminal below opencode
tmux select-pane -t "$target_window.0"
tmux split-window -t "$target_window.0" -v -p 50 -c "$worktree_dir"

tmux select-pane -t "$target_window.2"

if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$session_name"
else
  exec tmux attach-session -t "$session_name"
fi
