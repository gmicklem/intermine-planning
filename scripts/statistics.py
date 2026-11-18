#!/usr/bin/env python3
"""statistics.py - hourly counts of agent jobs by model and of commits; writes status/STATISTICS.md.

Jobs come from status/agent-runs.csv (one row per worker run, counted in the hour it started, by its
model column). Commits come from the integration branches of every repository, by author date:
non-merge commits (what the workers wrote) and merge commits (the orchestrator's gated merges) are
counted separately. The branch list is the one scripts/plot-commits.py uses; keep the two in step.
The planning repository is left out (its commits are status bookkeeping), and so is
release/5.1.1-candidate (cherry-picks of maint-2026 commits).

  python3 -I scripts/statistics.py [--planning DIR] [--since 2026-11-14T22:00:00Z]
"""
import argparse
import csv
import datetime as dt
import os
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))  # .../update_intermine_planning
BRANCHES = [  # (path relative to ROOT, ref) - same list as scripts/plot-commits.py
    ("worktrees/intermine/merge-maint-2026", "maint-2026"),
    ("repos/bluegenes", "maint-2026"),
    ("repos/im-tables-3", "maint-2026"),
    ("repos/imcljs", "maint-2026"),
    ("repos/bluegenes-tool-store", "maint-2026"),
    ("repos/mine-tests", "maint-2026"),
    ("worktrees/rdfc2im/im-ore.1-intermine-src", "maint/im-ore.1-intermine-src"),
    ("repos/humanmine", "maint-2026"),
    ("repos/flymine", "maint-2026"),
    ("repos/humanmine-bio-sources", "maint-2026"),
    ("repos/flymine-bio-sources", "maint-2026"),
]
MODELS = ["fable", "opus", "sonnet", "haiku"]


def parse_ts(s):
    """ISO timestamp (with Z or an offset) -> naive UTC datetime, or None."""
    try:
        t = dt.datetime.fromisoformat((s or "").strip().replace("Z", "+00:00"))
    except ValueError:
        return None
    if t.tzinfo is not None:
        t = t.astimezone(dt.timezone.utc).replace(tzinfo=None)
    return t


def hour(t):
    return t.replace(minute=0, second=0, microsecond=0)


def model_key(m):
    m = (m or "").strip().lower()
    for k in MODELS:
        if k in m:
            return k
    return "other"


def read_jobs(planning, since):
    """[(start hour, model key)] for every recorded run that started at or after `since`."""
    path = os.path.join(planning, "status", "agent-runs.csv")
    out = []
    if not os.path.isfile(path):
        return out
    with open(path, newline="", encoding="utf-8", errors="replace") as fh:
        for r in csv.DictReader(fh):
            t = parse_ts(r.get("started_utc"))
            if t is not None and t >= since:
                out.append((hour(t), model_key(r.get("model"))))
    return out


def read_commits(since):
    """[(author hour, is_merge)] over the integration branches."""
    out = []
    for rel, ref in BRANCHES:
        p = os.path.join(ROOT, rel)
        if not os.path.isdir(p):
            continue
        r = subprocess.run(["git", "-C", p, "log", ref, "--since=" + since.isoformat() + "Z", "--format=%aI %P"],
                           capture_output=True, text=True)
        if r.returncode != 0:
            continue
        for line in r.stdout.splitlines():
            parts = line.split()
            t = parse_ts(parts[0])
            if t is not None and t >= since:
                out.append((hour(t), len(parts) - 1 > 1))
    return out


def tally(jobs, commits):
    """{hour: {model...: n, 'other': n, 'commits': n, 'merges': n}}, only hours with something in them."""
    rows = {}
    blank = lambda: dict({k: 0 for k in MODELS}, other=0, commits=0, merges=0)  # noqa: E731
    for h, m in jobs:
        rows.setdefault(h, blank())[m] += 1
    for h, merge in commits:
        rows.setdefault(h, blank())["merges" if merge else "commits"] += 1
    return rows


def render(rows, since, now):
    cols = MODELS + ["other", "commits", "merges"]
    head = "| Hour (UTC) | Fable | Opus | Sonnet | Haiku | Other | Commits | Merges |"
    sep = "|---|---:|---:|---:|---:|---:|---:|---:|"

    def line(label, d):
        return "| %s | %s |" % (label, " | ".join(str(d[c]) if d[c] else "" for c in cols))

    def total(keys):
        return {c: sum(rows[k][c] for k in keys) for c in cols}

    out = ["# STATISTICS %s UTC" % now.strftime("%Y-%m-%d %H:%M"), "",
           "Jobs are worker runs recorded in `status/agent-runs.csv`, counted in the hour they started, by "
           "model. The orchestrator is one long Fable session and is not a job, so the Fable column counts "
           "only runs recorded with that model; the orchestrator's work shows in the Merges column. Commits "
           "are non-merge commits on the integration branches of the eleven code repositories and rdfc2im, "
           "by author time; the planning repository is left out. Hours with nothing in them are not shown. "
           "Written by `scripts/statistics.py` (hourly, with STATUS.md); since %s UTC."
           % since.strftime("%Y-%m-%d %H:%M"), ""]
    hours = sorted(rows)
    if not hours:
        return "\n".join(out + ["No jobs or commits recorded.", ""])
    days = sorted({h.date() for h in hours})
    out += ["## Totals by day", "", head.replace("Hour (UTC)", "Day (UTC)"), sep]
    for d in days:
        out.append(line(d.isoformat(), total([h for h in hours if h.date() == d])))
    out.append(line("**All**", total(hours)))
    out.append("")
    for d in reversed(days):
        out += ["## %s, by hour" % d.isoformat(), "", head, sep]
        for h in [h for h in hours if h.date() == d]:
            out.append(line(h.strftime("%H:00"), rows[h]))
        out.append("")
    return "\n".join(out)


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--planning", default=os.path.dirname(HERE))
    ap.add_argument("--since", default="2026-11-14T22:00:00Z")
    a = ap.parse_args(argv)
    since = parse_ts(a.since)
    now = dt.datetime.now(dt.timezone.utc).replace(tzinfo=None)
    rows = tally(read_jobs(a.planning, since), read_commits(since))
    path = os.path.join(a.planning, "status", "STATISTICS.md")
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        fh.write(render(rows, since, now))
    os.replace(tmp, path)
    print("statistics: wrote status/STATISTICS.md (%d hours with activity)" % len(rows))


if __name__ == "__main__":
    main()
