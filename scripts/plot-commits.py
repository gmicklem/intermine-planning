#!/usr/bin/env python3
"""plot-commits.py - commits per hour and cumulative commits across the sprint's integration branches,
in the house (Tufte) style, next to the cumulative count of closed beads.

Counts non-merge commits (what the workers wrote) and merge commits (the orchestrator's gated merges)
separately, by author date, on every repo's integration branch. release/5.1.1-candidate is left out
because its commits are cherry-picks of maint-2026 commits; the planning repo is left out because its
commits are status bookkeeping. Writes status/commits-per-hour.svg.

  /home/agent/venvs/plots/bin/python -I scripts/plot-commits.py [--planning DIR] [--since 2026-11-14]
"""
import argparse
import csv
import datetime as dt
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "tufte-plots"))
import matplotlib  # noqa: E402
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import matplotlib.dates as mdates  # noqa: E402
from style import apply_tufte, finish_axes, ordinal_colors, place_legend  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))  # .../update_intermine_planning
BRANCHES = [  # (path relative to ROOT, ref)
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


def commits(path, ref, since):
    out = subprocess.run(["git", "-C", path, "log", ref, "--since=" + since, "--format=%aI %P"],
                         capture_output=True, text=True, check=True).stdout
    rows = []
    for line in out.splitlines():
        parts = line.split()
        when = dt.datetime.fromisoformat(parts[0]).astimezone(dt.timezone.utc).replace(tzinfo=None)
        rows.append((when, len(parts) - 1 > 1))  # (author time, is_merge)
    return rows


def hour(t):
    return t.replace(minute=0, second=0, microsecond=0)


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--planning", default=os.path.dirname(HERE))
    ap.add_argument("--since", default="2026-11-14T22:00:00Z")
    a = ap.parse_args(argv)
    status_dir = os.path.join(a.planning, "status")
    allc = []
    for rel, ref in BRANCHES:
        p = os.path.join(ROOT, rel)
        if os.path.isdir(p):
            allc += commits(p, ref, a.since)
    if not allc:
        sys.exit("plot-commits: no commits found")
    allc.sort()
    hours = {}
    for when, merge in allc:
        h = hour(when)
        d = hours.setdefault(h, [0, 0])
        d[1 if merge else 0] += 1
    first, last = hour(allc[0][0]), hour(allc[-1][0])
    xs = []
    h = first
    while h <= last:
        xs.append(h)
        h += dt.timedelta(hours=1)
    plain = [hours.get(h, [0, 0])[0] for h in xs]
    merges = [hours.get(h, [0, 0])[1] for h in xs]
    cum_plain, cum_all, c1, c2 = [], [], 0, 0
    for p_, m_ in zip(plain, merges):
        c1 += p_
        c2 += p_ + m_
        cum_plain.append(c1)
        cum_all.append(c2)

    # closed beads over time from the hourly history
    bt, bc = [], []
    hist = os.path.join(status_dir, "beads-history.csv")
    if os.path.exists(hist):
        seen = {}
        with open(hist, newline="") as f:
            for r in csv.DictReader(f):
                k = r["ts_utc"]
                if k not in seen or r["source"] == "live":
                    seen[k] = r
        for k in sorted(seen):
            bt.append(dt.datetime.strptime(k, "%Y-%m-%dT%H:%MZ"))
            bc.append(int(seen[k].get("closed") or 0))

    apply_tufte()
    colors, _ = ordinal_colors(["commits", "merges", "beads"])
    fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True, figsize=(5, 4.2),
                                   gridspec_kw={"height_ratios": [1, 1.4], "hspace": 0.25})
    w = 1 / 24 * 0.8
    ax1.bar(xs, plain, width=w, color=colors[0], linewidth=0, label="Commits")
    ax1.bar(xs, merges, width=w, bottom=plain, color=colors[1], linewidth=0, label="Merge commits")
    ax1.set_ylabel("Per hour")
    place_legend(ax1)
    finish_axes(ax1, box_aspect=None)

    ax2.plot(xs, cum_all, linewidth=1.0, color=colors[1], label="Commits incl. merges (cumulative)")
    ax2.plot(xs, cum_plain, linewidth=1.0, color=colors[0], label="Commits (cumulative)")
    if bt:
        ax2.plot(bt, bc, linewidth=1.0, color=colors[2], label="Beads closed (cumulative)")
    ax2.set_ylabel("Cumulative")
    ax2.set_xlabel("Time (UTC)")
    ax2.xaxis.set_major_formatter(mdates.DateFormatter("%a %H:%M"))
    place_legend(ax2)
    finish_axes(ax2, box_aspect=None)
    out = os.path.join(status_dir, "commits-per-hour.svg")
    fig.savefig(out, facecolor="white", bbox_inches="tight")
    plt.close(fig)
    n_plain, n_merge = sum(plain), sum(merges)
    print("plot-commits: wrote status/commits-per-hour.svg (%d commits + %d merges over %d hours, %d branches)"
          % (n_plain, n_merge, len(xs), len(BRANCHES)))


if __name__ == "__main__":
    main()
