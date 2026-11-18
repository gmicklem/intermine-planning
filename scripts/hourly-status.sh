#!/usr/bin/env bash
# hourly-status.sh - regenerate the dashboard (STATUS.md, index.html, artifact pages), append a
# beads-history row, commit the status/ directory and push the planning repo.
#
# Usage:
#   hourly-status.sh            one run
#   hourly-status.sh --loop     run now and then every hour, for ever (start with nohup; the
#                               orchestrator starts it once per sandbox session, see CLAUDE.md)
#
# Gos asked (15 Nov 2026) for the beads report in STATUS.md every hour and for the counts per
# priority to be logged over time. Logs: /home/agent/taskhomes/_logs/hourly-status.log.
set -u
PLANNING=$(cd "$(dirname "$0")/.." && pwd)
LOG=/home/agent/taskhomes/_logs/hourly-status.log
mkdir -p "$(dirname "$LOG")"

run_once() {
  cd "$PLANNING" || return 1
  echo "== $(date -u +%Y-%m-%dT%H:%MZ) hourly-status" >> "$LOG"
  python3 -I scripts/dashboard.py >> "$LOG" 2>&1 || echo "dashboard failed" >> "$LOG"
  scripts/save-agent-memory.sh >> "$LOG" 2>&1 || echo "save-agent-memory failed" >> "$LOG"
  python3 -I scripts/statistics.py >> "$LOG" 2>&1 || echo "statistics failed" >> "$LOG"
  python3 -I scripts/beads-history.py append >> "$LOG" 2>&1 || echo "beads-history failed" >> "$LOG"
  /home/agent/venvs/plots/bin/python -I scripts/plot-beads-history.py >> "$LOG" 2>&1 || echo "beads plots failed" >> "$LOG"
  /home/agent/venvs/plots/bin/python -I scripts/plot-commits.py >> "$LOG" 2>&1 || echo "commits plot failed" >> "$LOG"
  if [ -n "$(git status --porcelain status/ agent-memory/)" ]; then
    git add status/ agent-memory/ && git commit -q -m "status: hourly beads report $(date -u +%H:%MZ) [im-8dd.2]

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>" >> "$LOG" 2>&1
    # push only when the token still belongs to gmicklem (sprint rule)
    if [ "$(gh api user --jq .login 2>/dev/null)" = gmicklem ]; then
      git push -q origin main >> "$LOG" 2>&1 || echo "push failed" >> "$LOG"
    else
      echo "push skipped: token is not gmicklem" >> "$LOG"
    fi
  else
    echo "no status change" >> "$LOG"
  fi
}

if [ "${1:-}" = "--loop" ]; then
  while true; do
    run_once
    # sleep to the next top of the hour
    sleep $(( 3600 - $(date -u +%s) % 3600 ))
  done
else
  run_once
fi
