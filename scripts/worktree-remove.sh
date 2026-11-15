#!/usr/bin/env bash
# Remove a task worktree after its branch has been merged. Usage: worktree-remove.sh <repo-name> <beads-id> <slug> [--delete-branch]
set -euo pipefail
ROOT=/Users/gos/claude_projects/update_intermine_planning
repo=$1; id=$2; slug=$3; del=${4:-}
src=$ROOT/repos/$repo; dest=$ROOT/worktrees/$repo/$id-$slug
git -C "$src" worktree remove --force "$dest"
[ "$del" = "--delete-branch" ] && git -C "$src" branch -D "maint/$id-$slug" || true
