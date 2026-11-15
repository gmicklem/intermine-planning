#!/usr/bin/env python3
"""Append one agent run to status/agent-runs.csv, pulling token usage from the agent's log.

Usage: record-run.py <beads-id> <label> <model> <outcome> [notes] [--log PATH]
If --log is given (a Claude Code subagent .output JSONL), tokens and start/end are read from it;
otherwise zeros are recorded with the current time.
"""
import csv, json, os, sys
from datetime import datetime, timezone
P = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
args = sys.argv[1:]
log = None
if "--log" in args:
    i = args.index("--log"); log = args[i+1]; del args[i:i+2]
bid, label, model, outcome = args[:4]; notes = args[4] if len(args) > 4 else ""
start = end = datetime.now(timezone.utc).isoformat(timespec="seconds")
tok = {"input_tokens":0,"cache_read_input_tokens":0,"cache_creation_input_tokens":0,"output_tokens":0}
if log and os.path.exists(log):
    seen = {}
    first = last = None
    for line in open(log, errors="replace"):
        try: r = json.loads(line)
        except Exception: continue
        ts = r.get("timestamp")
        if ts: first = first or ts; last = ts
        m = r.get("message") or {}
        if m.get("usage"): seen[m.get("id") or ts] = m["usage"]
    for u in seen.values():
        for k in tok: tok[k] += u.get(k, 0) or 0
    start, end = first or start, last or end
with open(os.path.join(P, "status", "agent-runs.csv"), "a", newline="") as f:
    csv.writer(f).writerow([start, end, bid, label, model, tok["input_tokens"], tok["cache_read_input_tokens"], tok["cache_creation_input_tokens"], tok["output_tokens"], outcome, notes])
print("recorded", bid, label, outcome, tok)
