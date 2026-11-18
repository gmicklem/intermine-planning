#!/usr/bin/env bash
# save-agent-memory.sh - copy the orchestrator's memory notes into this repository (agent-memory/).
#
# The notes live in the sandbox's home directory, which is lost when the sandbox is recreated (for
# example when it is restarted with a different memory allocation). Gos, 18 Nov 2026: saving them here
# is permanent session-close policy; the hourly status loop also runs this, so at most an hour of notes
# can be lost. The copy is plain files: restore with `cp agent-memory/*.md <memory dir>/` in a new sandbox.
#
# Usage: scripts/save-agent-memory.sh        (copies; the caller commits and pushes)
set -euo pipefail
PLANNING=$(cd "$(dirname "$0")/.." && pwd)
SRC=${AGENT_MEMORY_DIR:-/home/agent/.claude/projects/-Users-gos-claude-projects-update-intermine-planning-repos/memory}
DEST=$PLANNING/agent-memory
[ -d "$SRC" ] || { echo "save-agent-memory: no memory directory at $SRC" >&2; exit 0; }
mkdir -p "$DEST"
n=0
for f in "$SRC"/*.md; do
  [ -f "$f" ] || continue
  cat "$f" > "$DEST/$(basename "$f")"     # cat, not cp: cp has zero-filled files on this mount
  n=$((n + 1))
done
# a note deleted from memory is deleted from the copy too (README.md belongs to the copy only)
for f in "$DEST"/*.md; do
  b=$(basename "$f")
  [ "$b" = README.md ] && continue
  [ -f "$SRC/$b" ] || rm -f "$f"
done
echo "save-agent-memory: $n notes copied to agent-memory/"
