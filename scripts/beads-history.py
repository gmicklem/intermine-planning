#!/usr/bin/env python3
"""beads-history.py - append the current beads counts to status/beads-history.csv, or backfill it.

Columns (one row per sample):
  ts_utc      ISO timestamp of the sample (minute resolution)
  source      live      = counted from `bd list --all --json` at that moment
              backfill  = reconstructed from each issue's created_at / started_at / closed_at
  <P>_open, <P>_in_progress, <P>_closed for P in P0..P4 (tasks, bugs, etc.; epics excluded)
  epics_open, epics_closed
  total, open, in_progress, closed  (non-epic totals)

Blocked and deferred issues are counted under `open` (none have been used in this sprint).
Backfilled rows cannot know when an issue was blocked/deferred, and know `in_progress` only
through started_at, so they are an approximation; live rows are exact.

Usage:
  beads-history.py append [--planning DIR]          # one live row (what the hourly runner calls)
  beads-history.py backfill [--planning DIR] [--step-minutes 60] [--from ISO] [--to ISO]
      # rewrites the backfill rows (keeps live rows), hourly samples from the first issue to now

Gos asked for the counts per priority to be logged over time so they can be graphed at the end
(scripts/plot-beads-history.py).
"""
import argparse
import csv
import datetime as dt
import json
import os
import subprocess
import sys

PRIS = ["P0", "P1", "P2", "P3", "P4"]
STATES = ["open", "in_progress", "closed"]
FIELDS = (["ts_utc", "source"]
          + ["%s_%s" % (p, s) for p in PRIS for s in STATES]
          + ["epics_open", "epics_closed", "total", "open", "in_progress", "closed"])


def parse_ts(s):
    if not s:
        return None
    s = s.replace("Z", "+00:00")
    try:
        d = dt.datetime.fromisoformat(s)
    except ValueError:
        return None
    if d.tzinfo is None:
        d = d.replace(tzinfo=dt.timezone.utc)
    return d.astimezone(dt.timezone.utc)


def load_issues(planning):
    out = subprocess.run(["bd", "list", "--all", "--json"], cwd=planning, capture_output=True,
                         text=True, timeout=60)
    if out.returncode != 0:
        sys.exit("bd list failed: " + out.stderr.strip()[:200])
    return json.loads(out.stdout)


def pri_key(i):
    p = i.get("priority")
    try:
        p = int(p)
    except (TypeError, ValueError):
        return None
    return "P%d" % p if 0 <= p <= 4 else None


def count(issues, at=None):
    """Counts at time `at` (None = now, using the live status fields)."""
    row = {f: 0 for f in FIELDS[2:]}
    for i in issues:
        created = parse_ts(i.get("created_at"))
        if at is not None and (created is None or created > at):
            continue
        if at is None:
            st = i.get("status") or "open"
            if st in ("blocked", "deferred"):
                st = "open"
        else:
            closed = parse_ts(i.get("closed_at"))
            started = parse_ts(i.get("started_at"))
            if i.get("status") == "closed" and closed is not None and closed <= at:
                st = "closed"
            elif started is not None and started <= at:
                st = "in_progress"
            else:
                st = "open"
        if i.get("issue_type") == "epic":
            row["epics_closed" if st == "closed" else "epics_open"] += 1
            continue
        pk = pri_key(i)
        if pk is not None:
            row["%s_%s" % (pk, st)] += 1
        row[st] += 1
        row["total"] += 1
    return row


def read_rows(path):
    if not os.path.exists(path):
        return []
    with open(path, newline="") as f:
        return list(csv.DictReader(f))


def write_rows(path, rows):
    rows.sort(key=lambda r: (r["ts_utc"], 0 if r["source"] == "backfill" else 1))
    tmp = path + ".tmp"
    with open(tmp, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=FIELDS)
        w.writeheader()
        for r in rows:
            w.writerow({k: r.get(k, "") for k in FIELDS})
    os.replace(tmp, path)


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["append", "backfill"])
    ap.add_argument("--planning", default=os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    ap.add_argument("--step-minutes", type=int, default=60)
    ap.add_argument("--from", dest="start")
    ap.add_argument("--to", dest="end")
    a = ap.parse_args(argv)
    path = os.path.join(a.planning, "status", "beads-history.csv")
    issues = load_issues(a.planning)
    rows = read_rows(path)
    now = dt.datetime.now(dt.timezone.utc).replace(second=0, microsecond=0)
    if a.mode == "append":
        r = count(issues)
        r.update(ts_utc=now.strftime("%Y-%m-%dT%H:%MZ"), source="live")
        rows.append(r)
        write_rows(path, rows)
        print("beads-history: appended live row %s (open %d, in progress %d, closed %d of %d)" % (
            r["ts_utc"], r["open"], r["in_progress"], r["closed"], r["total"]))
        return
    rows = [r for r in rows if r.get("source") != "backfill"]
    first = min((parse_ts(i.get("created_at")) for i in issues if parse_ts(i.get("created_at"))), default=now)
    start = parse_ts(a.start) if a.start else first.replace(minute=0, second=0, microsecond=0)
    end = parse_ts(a.end) if a.end else now
    t = start
    n = 0
    while t <= end:
        r = count(issues, at=t)
        r.update(ts_utc=t.strftime("%Y-%m-%dT%H:%MZ"), source="backfill")
        rows.append(r)
        n += 1
        t += dt.timedelta(minutes=a.step_minutes)
    write_rows(path, rows)
    print("beads-history: wrote %d backfill rows from %s to %s (%d live rows kept)" % (
        n, start.strftime("%Y-%m-%dT%H:%MZ"), end.strftime("%Y-%m-%dT%H:%MZ"), len(rows) - n))


if __name__ == "__main__":
    main()
