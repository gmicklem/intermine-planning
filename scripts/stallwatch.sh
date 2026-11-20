#!/bin/bash
# Exit (notifying the orchestrator) when a listed agent transcript's last timestamped entry is older
# than 15 min. File mtime is unreliable here, so the JSONL timestamps are used.
# Usage: stallwatch.sh label=path ...
while true; do
  for a in "$@"; do
    l=${a%%=*}; f=${a#*=}
    [ -f "$f" ] || continue
    age=$(tail -n 5 "$f" | python3 -c '
import sys,json,datetime
t=None
for line in sys.stdin:
    try: ts=json.loads(line).get("timestamp")
    except Exception: ts=None
    if ts: t=ts
if t:
    d=datetime.datetime.fromisoformat(t.replace("Z","+00:00"))
    print(int((datetime.datetime.now(datetime.timezone.utc)-d).total_seconds()))
else: print(0)')
    if [ "${age:-0}" -ge 900 ]; then echo "STALL? $l last entry ${age}s ago at $(date -u +%T)"; ps -eo etimes,args | grep -E "drive-ut|full-build|cypress run|docker build|gradle" | grep -v grep | cut -c1-120 | head -5; free -g | awk '/Mem:/{print "avail GB " $7}'; df -h / | tail -1; exit 0; fi
  done
  sleep 60
done
