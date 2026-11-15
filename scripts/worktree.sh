#!/usr/bin/env bash
# Create (or print) an isolated git worktree for one task.
# Usage: worktree.sh <repo-name> <beads-id> <slug>
#   repo-name: intermine | bluegenes | imcljs | im-tables-3 | bluegenes-tool-store | humanmine | flymine | rdfc2im | mine-tests
# Creates branch maint/<beads-id>-<slug> from maint-2026 (or dev/main if maint-2026 is absent)
# at ../worktrees/<repo-name>/<beads-id>-<slug> and prints the path.
set -euo pipefail
ROOT=/Users/gos/claude_projects/update_intermine_planning
repo=$1; id=$2; slug=$3
src=$ROOT/repos/$repo
dest=$ROOT/worktrees/$repo/$id-$slug
branch=maint/$id-$slug
[ -d "$src/.git" ] || { echo "no repo at $src" >&2; exit 1; }
if [ -d "$dest" ]; then echo "$dest"; exit 0; fi
base=maint-2026
git -C "$src" show-ref --verify --quiet refs/heads/$base || base=$(git -C "$src" symbolic-ref --short HEAD)
mkdir -p "$(dirname "$dest")"
if git -C "$src" show-ref --verify --quiet refs/heads/$branch; then
  git -C "$src" worktree add -q "$dest" "$branch"
else
  git -C "$src" worktree add -q -b "$branch" "$dest" "$base"
fi
echo "$dest"
