#!/usr/bin/env python3
"""plot-beads-history.py - graph status/beads-history.csv in the house (Tufte) style.

Reads the CSV written by beads-history.py and writes two SVGs into status/:
  beads-history.svg          open / in progress / closed non-epic issues over time (one panel)
  beads-history-priority.svg small multiples, one panel per priority: open and closed over time

Backfilled rows (reconstructed from issue timestamps) and live rows (sampled hourly) are
plotted alike; the CSV's `source` column says which is which.

Run with a Python that has matplotlib (the sandbox venv /home/agent/venvs/plots/bin/python):
  /home/agent/venvs/plots/bin/python -I scripts/plot-beads-history.py [--planning DIR]
Style helpers come from scripts/tufte-plots/style.py (Gos's tufte-plots skill, copied in).
"""
import argparse
import csv
import datetime as dt
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "tufte-plots"))

import matplotlib  # noqa: E402
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from style import apply_tufte, finish_axes, ordinal_colors, place_legend  # noqa: E402

PRIS = ["P0", "P1", "P2", "P3"]


def load(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f))
    # one row per timestamp: prefer live over backfill
    by_ts = {}
    for r in rows:
        k = r["ts_utc"]
        if k not in by_ts or r["source"] == "live":
            by_ts[k] = r
    rows = [by_ts[k] for k in sorted(by_ts)]
    ts = [dt.datetime.strptime(r["ts_utc"], "%Y-%m-%dT%H:%MZ") for r in rows]
    return ts, rows


def col(rows, name):
    return [int(r.get(name) or 0) for r in rows]


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--planning", default=os.path.dirname(HERE))
    a = ap.parse_args(argv)
    status_dir = os.path.join(a.planning, "status")
    ts, rows = load(os.path.join(status_dir, "beads-history.csv"))
    if len(ts) < 2:
        sys.exit("plot-beads-history: need at least two rows")
    apply_tufte()

    # Panel 1: the three states over time. Ordered levels (open -> in progress -> closed).
    states = ["open", "in_progress", "closed"]
    names = {"open": "Open", "in_progress": "In progress", "closed": "Closed"}
    colors, _ = ordinal_colors(states)
    fig, ax = plt.subplots(figsize=(5, 3))
    for s, c in zip(states, colors):
        ax.plot(ts, col(rows, s), linewidth=1.0, color=c, label=names[s])
    ax.set_xlabel("Time (UTC)")
    ax.set_ylabel("Issues (tasks and bugs)")
    place_legend(ax)
    finish_axes(ax, box_aspect=3 / 5)
    fig.savefig(os.path.join(status_dir, "beads-history.svg"), facecolor="white")
    plt.close(fig)

    # Panel 2: small multiples per priority, open and closed.
    fig, axes = plt.subplots(1, len(PRIS), sharey=True, figsize=(len(PRIS) * 1.6, 1.9))
    two, _ = ordinal_colors(["open", "closed"])
    for ax, p in zip(axes, PRIS):
        ax.plot(ts, col(rows, p + "_open"), linewidth=1.0, color=two[0], label="Open")
        ax.plot(ts, col(rows, p + "_closed"), linewidth=1.0, color=two[1], label="Closed")
        ax.set_title(p)
        finish_axes(ax, box_aspect=None)
    fig.supxlabel("Time (UTC)")
    fig.supylabel("Issues")
    place_legend(axes[-1])
    fig.savefig(os.path.join(status_dir, "beads-history-priority.svg"), facecolor="white")
    plt.close(fig)
    print("plot-beads-history: wrote status/beads-history.svg and status/beads-history-priority.svg (%d samples)" % len(ts))


if __name__ == "__main__":
    main()
