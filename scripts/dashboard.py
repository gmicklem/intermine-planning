#!/usr/bin/env python3
"""Progress dashboard for the multi-agent InterMine maintenance sprint.

Usage:  python3 -I scripts/dashboard.py [--planning-repo PATH] [--stall-minutes 10]

Writes status/STATUS.md and status/index.html (same content) under the planning
repo.  Standard library only.  Read-only with respect to everything except those
two output files: beads is queried with `bd list --json` / `bd status --json`
only, git with read-only plumbing, Claude Code logs are only read.

Agent state heuristic (subagent logs, "*.output" files, usually symlinks to
agent-*.jsonl):
  * Assistant records are streamed: one API message appears as several records
    sharing message.id.  Records are de-duplicated per message.id (the record
    with the highest output_tokens wins; the final one carries the real
    usage) so token totals are not inflated.
  * "completed" = the last assistant message (by log order) has no tool_use
    block and a stop_reason other than "tool_use" (normally "end_turn").
  * running  : not completed and file mtime is younger than --stall-minutes
               (default 10).
  * stalled  : not completed and mtime is --stall-minutes or older.  (The task
               brief limits "stalled" to 10-60 min; anything unfinished older
               than 60 min is also reported as stalled, with the age shown,
               rather than being mislabelled as finished.)
  * finished : completed (regardless of mtime).
The main session is shown as "running" if written to within the stall window,
otherwise "idle" (it has no completion marker).
"""
import argparse
import csv
import glob
import html
import json
import os
import subprocess
import sys
from datetime import datetime, timezone, timedelta

HOME_REPOS = "/Users/gos/claude_projects/update_intermine_planning/repos"
DEFAULT_PLANNING = HOME_REPOS + "/intermine-planning"
DEFAULT_MAIN_DIR = "/home/agent/.claude/projects/-Users-gos-claude-projects-update-intermine-planning-repos"
DEFAULT_TASKS_GLOB = "/tmp/claude-1000/-Users-gos-claude-projects-update-intermine-planning-repos/*/tasks/*.output"
REPO_NAMES = ["intermine", "bluegenes", "imcljs", "im-tables-3", "bluegenes-tool-store"]

NOW = datetime.now(timezone.utc)


# ----------------------------------------------------------------- helpers
def parse_ts(s):
    if not s or not isinstance(s, str):
        return None
    try:
        s = s.strip()
        if s.endswith("Z"):
            s = s[:-1] + "+00:00"
        d = datetime.fromisoformat(s)
        if d.tzinfo is None:
            d = d.replace(tzinfo=timezone.utc)
        return d.astimezone(timezone.utc)
    except Exception:
        return None


def london(dt):
    try:
        from zoneinfo import ZoneInfo
        return dt.astimezone(ZoneInfo("Europe/London"))
    except Exception:
        # fallback: UK summer time = last Sun Mar 01:00 UTC .. last Sun Oct 01:00 UTC
        def last_sunday(year, month):
            d = datetime(year, month, 31, 1, tzinfo=timezone.utc)
            return d - timedelta(days=(d.weekday() + 1) % 7)
        bst = last_sunday(dt.year, 3) <= dt < last_sunday(dt.year, 10)
        return dt.astimezone(timezone(timedelta(hours=1 if bst else 0), "BST" if bst else "GMT"))


def fmt_dt(dt):
    """Short UTC timestamp: HH:MM today, else MM-DD HH:MM."""
    if not dt:
        return "-"
    if dt.date() == NOW.date():
        return dt.strftime("%H:%M")
    return dt.strftime("%m-%d %H:%M")


def fmt_age(dt):
    if not dt:
        return "-"
    s = int((NOW - dt).total_seconds())
    if s < 0:
        s = 0
    if s < 90:
        return "%ds" % s
    if s < 5400:
        return "%dm" % round(s / 60)
    if s < 86400 * 2:
        return "%.1fh" % (s / 3600)
    return "%dd" % (s // 86400)


def fmt_tok(n):
    try:
        n = int(n)
    except Exception:
        return "-"
    if n < 1000:
        return str(n)
    if n < 1000000:
        return "%.1fk" % (n / 1000)
    if n < 1000000000:
        return "%.2fM" % (n / 1e6)
    return "%.2fB" % (n / 1e9)


def short(s, n):
    s = " ".join(str(s or "").split())
    return s if len(s) <= n else s[: n - 1] + "\u2026"


def short_model(m):
    m = m or "?"
    return m[len("claude-"):] if m.startswith("claude-") else m


def to_int(x):
    try:
        return int(x)
    except Exception:
        return 0


def run(cmd, cwd=None, timeout=30):
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return p.returncode, p.stdout, p.stderr
    except Exception as e:  # missing binary, timeout, ...
        return 127, "", str(e)


# ------------------------------------------------------------ agent logs
def read_jsonl(path):
    out = []
    try:
        with open(path, "r", encoding="utf-8", errors="replace") as fh:
            for line in fh:
                line = line.strip()
                if not line or line[0] != "{":
                    continue
                try:
                    out.append(json.loads(line))
                except Exception:
                    pass
    except Exception:
        pass
    return out


def content_blocks(msg):
    c = msg.get("content") if isinstance(msg, dict) else None
    if isinstance(c, list):
        return [b for b in c if isinstance(b, dict)]
    if isinstance(c, str):
        return [{"type": "text", "text": c}]
    return []


def analyse_log(path, tail_dir_mtime=True):
    """Return dict summarising one Claude Code jsonl log, or None if not a log."""
    recs = read_jsonl(path)
    if not recs:
        return None
    msgs = {}      # message id -> dict(model, usage, stop, blocks)
    order = []     # message ids in first-seen order
    first_ts = last_ts = None
    first_user = None
    desc = None
    has_session_records = False
    for r in recs:
        ts = parse_ts(r.get("timestamp"))
        if ts:
            first_ts = ts if not first_ts or ts < first_ts else first_ts
            last_ts = ts if not last_ts or ts > last_ts else last_ts
        t = r.get("type")
        if isinstance(r.get("description"), str) and not desc:
            desc = r["description"]
        if t in ("user", "assistant"):
            has_session_records = True
        if t == "user" and first_user is None:
            m = r.get("message") or {}
            txt = " ".join(b.get("text", "") for b in content_blocks(m) if b.get("type") == "text")
            if txt.strip():
                first_user = txt
        if t == "assistant":
            m = r.get("message") or {}
            mid = m.get("id") or r.get("uuid")
            u = m.get("usage") or {}
            cur = msgs.get(mid)
            if cur is None:
                cur = {"model": m.get("model"), "usage": u, "stop": m.get("stop_reason"), "blocks": []}
                msgs[mid] = cur
                order.append(mid)
            else:
                if to_int(u.get("output_tokens")) >= to_int(cur["usage"].get("output_tokens")):
                    cur["usage"] = u
                if m.get("stop_reason"):
                    cur["stop"] = m.get("stop_reason")
                if m.get("model"):
                    cur["model"] = m.get("model")
            cur["blocks"].extend(content_blocks(m))
    if not has_session_records:
        return None
    by_model = {}
    for mid in order:
        c = msgs[mid]
        model = c["model"] or "?"
        if model.startswith("<") or model == "synthetic":
            continue
        u = c["usage"]
        d = by_model.setdefault(model, {"msgs": 0, "in": 0, "cr": 0, "cw": 0, "out": 0})
        d["msgs"] += 1
        d["in"] += to_int(u.get("input_tokens"))
        d["cr"] += to_int(u.get("cache_read_input_tokens"))
        d["cw"] += to_int(u.get("cache_creation_input_tokens"))
        d["out"] += to_int(u.get("output_tokens"))
    completed = False
    if order:
        last = msgs[order[-1]]
        has_tool = any(b.get("type") == "tool_use" for b in last["blocks"])
        completed = (not has_tool) and bool(last["stop"]) and last["stop"] != "tool_use"
    try:
        mtime = datetime.fromtimestamp(os.stat(path).st_mtime, timezone.utc)
    except Exception:
        mtime = last_ts
    primary = max(by_model.items(), key=lambda kv: kv[1]["msgs"])[0] if by_model else "?"
    return {
        "path": path, "models": by_model, "model": primary, "completed": completed,
        "first": first_ts, "last": last_ts, "mtime": mtime, "first_user": first_user,
        "desc": desc, "nmsgs": len(order), "recs": recs,
    }


def agent_descriptions(main_recs):
    """Map agentId -> description from Agent/Task tool_use + its tool_result in the main log."""
    use_desc = {}
    for r in main_recs:
        if r.get("type") != "assistant":
            continue
        for b in content_blocks(r.get("message")):
            if b.get("type") == "tool_use" and b.get("name") in ("Agent", "Task"):
                inp = b.get("input") or {}
                d = inp.get("description")
                if d:
                    use_desc[b.get("id")] = d
    out = {}
    for r in main_recs:
        if r.get("type") != "user":
            continue
        for b in content_blocks(r.get("message")):
            if b.get("type") != "tool_result" or b.get("tool_use_id") not in use_desc:
                continue
            c = b.get("content")
            text = c if isinstance(c, str) else " ".join(
                x.get("text", "") for x in (c or []) if isinstance(x, dict))
            for tok in text.replace("\n", " ").split("agentId:")[1:]:
                aid = tok.strip().split()[0] if tok.strip() else ""
                if aid:
                    out[aid] = use_desc[b.get("tool_use_id")]
    return out


def collect_agents(main_dir, tasks_glob, stall_min):
    notes = []
    result = {"main": None, "subs": [], "notes": notes}
    main_recs = []
    # main session: newest *.jsonl directly in the project dir
    try:
        cands = [p for p in glob.glob(os.path.join(main_dir, "*.jsonl")) if os.path.isfile(p)]
        if cands:
            newest = max(cands, key=lambda p: os.stat(p).st_mtime)
            m = analyse_log(newest)
            if m:
                m["label"] = "main session"
                result["main"] = m
                main_recs = m["recs"]
            else:
                notes.append("main session log unreadable: " + os.path.basename(newest))
        else:
            notes.append("no main session log found in " + main_dir)
    except Exception as e:
        notes.append("main session scan failed: %s" % e)
    descs = agent_descriptions(main_recs) if main_recs else {}
    seen = set()
    skipped = 0
    for p in sorted(glob.glob(tasks_glob)):
        try:
            rp = os.path.realpath(p)
            if rp in seen:
                continue
            seen.add(rp)
            a = analyse_log(p)
            if not a:
                skipped += 1
                continue
            aid = os.path.splitext(os.path.basename(p))[0]
            label = a["desc"] or descs.get(aid)
            if not label and a["first_user"]:
                label = short(a["first_user"], 60)
            a["label"] = label or os.path.basename(p)
            a["id"] = aid
            ref = a["mtime"] or a["last"]
            age_min = (NOW - ref).total_seconds() / 60 if ref else 1e9
            if a["completed"]:
                a["state"] = "finished"
            elif age_min < stall_min:
                a["state"] = "running"
            else:
                a["state"] = "stalled"
            a["age_min"] = age_min
            result["subs"].append(a)
        except Exception as e:
            notes.append("failed on %s: %s" % (os.path.basename(p), e))
    if skipped:
        notes.append("%d non-agent .output file(s) skipped (empty or plain-text task output)" % skipped)
    if not result["subs"]:
        notes.append("no subagent logs found (%s)" % tasks_glob)
    if result["main"]:
        ref = result["main"]["mtime"] or result["main"]["last"]
        result["main"]["state"] = "running" if ref and (NOW - ref).total_seconds() / 60 < stall_min else "idle"
        result["main"]["age_min"] = (NOW - ref).total_seconds() / 60 if ref else 1e9
    result["subs"].sort(key=lambda a: a["first"] or datetime.min.replace(tzinfo=timezone.utc))
    return result


# ---------------------------------------------------------------- beads
def bd_json(args, cwd):
    rc, out, err = run(["bd"] + args, cwd=cwd, timeout=45)
    if rc != 0:
        return None, "bd %s failed (rc=%s): %s" % (" ".join(args), rc, short(err or out, 160))
    try:
        data = json.loads(out) if out.strip() else None
    except Exception as e:
        return None, "bd %s returned non-JSON: %s" % (" ".join(args), e)
    if isinstance(data, dict) and "data" in data and "schema_version" in data:
        data = data["data"]  # BD_JSON_ENVELOPE=1 form
    return data, None


def collect_beads(planning):
    info = {"issues": None, "summary": None, "errors": []}
    issues, err = bd_json(["list", "--json", "--all", "--flat", "-n", "0"], planning)
    if err:  # older bd without some flags
        issues, err2 = bd_json(["list", "--json"], planning)
        err = err2
    if err:
        info["errors"].append(err)
    elif isinstance(issues, list):
        info["issues"] = [i for i in issues if isinstance(i, dict)]
    else:
        info["errors"].append("bd list returned no issue list")
    st, err = bd_json(["status", "--json"], planning)
    if err:
        info["errors"].append(err)
    elif isinstance(st, dict):
        info["summary"] = st.get("summary", st) if isinstance(st.get("summary", st), dict) else None
    return info


def issue_parent(i):
    p = i.get("parent")
    if isinstance(p, str) and p:
        return p
    for d in i.get("dependencies") or []:
        if isinstance(d, dict) and d.get("type") in ("parent-child", "parent_child"):
            if d.get("issue_id", i.get("id")) == i.get("id") and d.get("depends_on_id"):
                return d["depends_on_id"]
    return None


# ------------------------------------------------------------------ git
def git(repo, *args):
    rc, out, _ = run(["git", "-c", "safe.directory=*", "-C", repo] + list(args), timeout=30)
    return out.strip() if rc == 0 else None


def collect_repos(repos_dir):
    rows = []
    for name in REPO_NAMES:
        path = os.path.join(repos_dir, name)
        info = {"name": name, "path": path, "ok": os.path.isdir(path), "worktrees": [], "branches": [],
                "base": None, "ahead": None, "behind": None, "head": None}
        if info["ok"]:
            info["head"] = git(path, "rev-parse", "--abbrev-ref", "HEAD")
            wt = git(path, "worktree", "list", "--porcelain")
            if wt:
                cur = {}
                for line in wt.splitlines() + [""]:
                    if not line.strip():
                        if cur:
                            info["worktrees"].append(cur)
                        cur = {}
                        continue
                    k, _, v = line.partition(" ")
                    cur[k] = v
            br = git(path, "for-each-ref", "--format=%(refname:short)\t%(committerdate:iso-strict)\t%(subject)",
                     "refs/heads/maint/*", "refs/heads/maint-2026")
            for line in (br or "").splitlines():
                parts = line.split("\t", 2)
                if len(parts) == 3:
                    info["branches"].append({"name": parts[0], "ts": parse_ts(parts[1]), "subject": parts[2]})
            base = None
            for cand in ("dev", "develop", "master", "main"):
                if git(path, "rev-parse", "--verify", "-q", "refs/heads/" + cand):
                    base = cand
                    break
            if not base:
                sym = git(path, "symbolic-ref", "-q", "--short", "refs/remotes/origin/HEAD")
                base = sym
            info["base"] = base
            if base and any(b["name"] == "maint-2026" for b in info["branches"]):
                cnt = git(path, "rev-list", "--left-right", "--count", base + "...maint-2026")
                if cnt:
                    try:
                        behind, ahead = cnt.split()
                        info["ahead"], info["behind"] = int(ahead), int(behind)
                    except Exception:
                        pass
        rows.append(info)
    return rows


# ----------------------------------------------------------------- csv
def collect_runs(planning):
    path = os.path.join(planning, "status", "agent-runs.csv")
    if not os.path.isfile(path):
        return None, "status/agent-runs.csv not found"
    try:
        with open(path, newline="", encoding="utf-8", errors="replace") as fh:
            rows = [r for r in csv.DictReader(fh) if any((v or "").strip() for v in r.values() if isinstance(v, str))]
        return rows, None
    except Exception as e:
        return None, "agent-runs.csv unreadable: %s" % e


# ------------------------------------------------------ document model
# A document is a list of sections: (title, [block...]) with blocks:
#   ("p", text) | ("h3", text) | ("table", headers, rows, row_classes, cell_classes_or_None)
def table(headers, rows, classes=None):
    return ("table", headers, rows, classes or [None] * len(rows))


def build_doc(agents, beads, repos, runs, runs_err, planning, stall_min):
    doc = []
    lon = london(NOW)
    head = [("p", "Generated %s UTC / %s %s. Sprint dashboard for the InterMine and BlueGenes maintenance effort."
             % (NOW.strftime("%Y-%m-%d %H:%M"), lon.strftime("%Y-%m-%d %H:%M"), lon.tzname() or "London")),
            ("p", "Times are UTC. Agent state: running = unfinished and written to in the last %d min; "
                  "stalled = unfinished and silent for %d min or more; finished = last message ended its turn "
                  "(no tool call pending)." % (stall_min, stall_min))]
    running = sum(1 for a in agents["subs"] if a["state"] == "running")
    stalled = sum(1 for a in agents["subs"] if a["state"] == "stalled")
    finished = sum(1 for a in agents["subs"] if a["state"] == "finished")
    head.append(("p", "Subagents: %d running, %d stalled, %d finished." % (running, stalled, finished)))
    doc.append(("STATUS " + NOW.strftime("%Y-%m-%d %H:%M UTC"), head))

    # ---- agents
    blocks = []
    rows, cls = [], []

    def agent_row(a):
        tot = {"in": 0, "cr": 0, "cw": 0, "out": 0}
        for d in a["models"].values():
            for k in tot:
                tot[k] += d[k]
        state = a["state"]
        if state == "stalled":
            state = "stalled %s" % fmt_age(a["mtime"])
        return [short(a["label"], 44), short_model(a["model"]), state, fmt_dt(a["first"]),
                fmt_dt(a["mtime"] or a["last"]), fmt_tok(tot["in"]), fmt_tok(tot["cr"] + tot["cw"]),
                fmt_tok(tot["out"])]
    allrows = ([agents["main"]] if agents["main"] else []) + agents["subs"]
    for a in allrows:
        rows.append(agent_row(a))
        cls.append(a["state"])
    if rows:
        blocks.append(table(["Agent", "Model", "State", "Started", "Last", "In", "Cache", "Out"], rows, cls))
    else:
        blocks.append(("p", "No agent logs found."))
    for n in agents["notes"]:
        blocks.append(("p", "Note: " + n))
    doc.append(("Agents", blocks))

    # ---- totals
    def totals(logs):
        t = {}
        for a in logs:
            for m, d in a["models"].items():
                x = t.setdefault(m, {"msgs": 0, "in": 0, "cr": 0, "cw": 0, "out": 0})
                for k in x:
                    x[k] += d[k]
        return t
    rows = []
    for scope, logs in (("main", [agents["main"]] if agents["main"] else []), ("subagents", agents["subs"])):
        t = totals(logs)
        for m in sorted(t):
            d = t[m]
            rows.append([scope, short_model(m), str(d["msgs"]), fmt_tok(d["in"]), fmt_tok(d["cr"]),
                         fmt_tok(d["cw"]), fmt_tok(d["out"])])
    blocks = []
    if rows:
        blocks.append(table(["Scope", "Model", "Msgs", "In", "Cache rd", "Cache wr", "Out"], rows))
        blocks.append(("p", "Tokens are de-duplicated per API message (streamed records share one message id)."))
    else:
        blocks.append(("p", "No token usage found."))
    doc.append(("Totals by model", blocks))

    # ---- beads
    blocks = []
    if beads["errors"]:
        for e in beads["errors"]:
            blocks.append(("p", "Beads unavailable or degraded: " + e))
    issues = beads["issues"]
    s = beads["summary"]
    if s:
        keys = [("total_issues", "total"), ("open_issues", "open"), ("in_progress_issues", "in progress"),
                ("blocked_issues", "blocked"), ("ready_issues", "ready"), ("deferred_issues", "deferred"),
                ("closed_issues", "closed")]
        blocks.append(("p", "bd status: " + ", ".join("%s %s" % (lbl, s.get(k, 0)) for k, lbl in keys if k in s) + "."))
    if issues is not None:
        counts = {}
        for i in issues:
            counts[i.get("status") or "?"] = counts.get(i.get("status") or "?", 0) + 1
        if counts:
            blocks.append(table(["Status", "Count"], [[k, str(v)] for k, v in sorted(counts.items())]))
            # Priority breakdown (Gos, 15 Nov): P0 critical path, P1 must ship this sprint,
            # P2 should ship, P3 nice to have / post-sprint. Epics are counted separately.
            statuses = ["open", "in_progress", "blocked", "deferred", "closed"]
            pri = {}
            for i in issues:
                pv = to_int(i.get("priority"))
                pk = ("P%d" % pv) if pv is not None else "P?"
                row = pri.setdefault(pk, {"epics": 0, "total": 0})
                if i.get("issue_type") == "epic":
                    row["epics"] += 1
                    continue
                st = i.get("status") or "?"
                row[st] = row.get(st, 0) + 1
                row["total"] += 1
            rows = []
            for pk in sorted(pri):
                r = pri[pk]
                done = r.get("closed", 0)
                pct = ("%d%%" % round(100.0 * done / r["total"])) if r["total"] else "-"
                rows.append([pk] + [str(r.get(st, 0)) for st in statuses] + [str(r["total"]), pct, str(r["epics"])])
            tot = {st: sum(pri[k].get(st, 0) for k in pri) for st in statuses}
            tot_n = sum(pri[k]["total"] for k in pri)
            rows.append(["all"] + [str(tot[st]) for st in statuses] + [str(tot_n),
                        ("%d%%" % round(100.0 * tot["closed"] / tot_n)) if tot_n else "-",
                        str(sum(pri[k]["epics"] for k in pri))])
            blocks.append(("h3", "By priority (tasks and bugs; epics counted apart)"))
            blocks.append(table(["Priority"] + [st.replace("_", " ") for st in statuses] + ["total", "closed %", "epics"], rows))
        else:
            blocks.append(("p", "No issues in the beads database yet."))
        byid = {i.get("id"): i for i in issues}
        openi = [i for i in issues if i.get("status") not in ("closed",)]
        groups = {}
        for i in openi:
            if i.get("issue_type") == "epic":
                groups.setdefault(i.get("id"), [])
        for i in openi:
            if i.get("issue_type") == "epic":
                continue
            groups.setdefault(issue_parent(i), []).append(i)
        for key in sorted(groups, key=lambda k: (k is None, str(k))):
            items = sorted(groups[key], key=lambda i: (to_int(i.get("priority")) if i.get("priority") is not None else 9,
                                                       str(i.get("id"))))
            if key is None:
                title = "No parent epic"
            else:
                e = byid.get(key, {})
                kids = [i for i in issues if issue_parent(i) == key]
                done = sum(1 for i in kids if i.get("status") == "closed")
                title = "%s %s [%s, %d/%d closed]" % (key, short(e.get("title", ""), 50), e.get("status", "?"),
                                                      done, len(kids))
            blocks.append(("h3", title))
            if items:
                blocks.append(table(["ID", "Title", "Status", "P", "Labels"],
                                    [[str(i.get("id", "")), short(i.get("title"), 50), str(i.get("status", "")),
                                      str(i.get("priority", "")), ",".join(i.get("labels") or [])] for i in items],
                                    [("s-" + str(i.get("status"))) for i in items]))
            else:
                blocks.append(("p", "No open child issues."))
        if not openi and counts:
            blocks.append(("p", "No open issues."))
    doc.append(("Beads summary", blocks))

    # ---- repos
    rows, cls = [], []
    for r in repos:
        if not r["ok"]:
            rows.append([r["name"], "-", "missing", "-", "-"])
            cls.append(None)
            continue
        nwt = len(r["worktrees"])
        wt_other = [w for w in r["worktrees"][1:]]
        wt_txt = str(nwt) if not wt_other else "%d (%s)" % (nwt, ", ".join(
            short(os.path.basename(w.get("worktree", "")), 18) for w in wt_other[:3]) + ("..." if len(wt_other) > 3 else ""))
        if not r["branches"]:
            rows.append([r["name"], wt_txt, "no maint branches", "-", "on " + str(r["head"])])
            cls.append(None)
        for b in sorted(r["branches"], key=lambda b: b["name"]):
            ahead = "-"
            if b["name"] == "maint-2026":
                if r["ahead"] is None:
                    ahead = "?"
                else:
                    ahead = ("ahead %d" % r["ahead"]) if r["ahead"] else "level"
                    if r["behind"]:
                        ahead += ", behind %d" % r["behind"]
                    ahead += " vs " + str(r["base"])
            rows.append([r["name"], wt_txt, b["name"], "%s (%s)" % (fmt_dt(b["ts"]), fmt_age(b["ts"])) if b["ts"] else "-",
                         ahead + " | " + short(b["subject"], 40)])
            cls.append(None)
    blocks = [table(["Repo", "WT", "Branch", "Last commit", "vs dev | subject"], rows, cls)]
    blocks.append(("p", "WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*."))
    doc.append(("Repos and branches", blocks))

    # ---- runs
    blocks = []
    if runs is None:
        blocks.append(("p", "Agent runs: " + (runs_err or "unavailable")))
    elif not runs:
        blocks.append(("p", "status/agent-runs.csv has a header but no runs recorded yet."))
    else:
        def key(r):
            return parse_ts(r.get("started_utc")) or datetime.min.replace(tzinfo=timezone.utc)
        recent = sorted(runs, key=key, reverse=True)[:20]
        rows = []
        for r in recent:
            cache = to_int(r.get("cache_read_tokens")) + to_int(r.get("cache_write_tokens"))
            rows.append([fmt_dt(parse_ts(r.get("started_utc"))), r.get("beads_id") or "-",
                         short(r.get("agent_label"), 28), short_model(r.get("model")),
                         fmt_tok(r.get("input_tokens") or 0), fmt_tok(cache), fmt_tok(r.get("output_tokens") or 0),
                         short(r.get("outcome"), 14), short(r.get("notes"), 40)])
        blocks.append(table(["Start", "Bead", "Agent", "Model", "In", "Cache", "Out", "Outcome", "Notes"], rows))
        if len(runs) > len(recent):
            blocks.append(("p", "Showing the %d most recent of %d runs." % (len(recent), len(runs))))
    doc.append(("Recent agent runs", blocks))
    # Gos, 18 Nov 2026: the beads and epic summaries come first, before the agent list.
    order = {"Beads summary": 1}
    doc[1:] = sorted(doc[1:], key=lambda sec: order.get(sec[0], 2))
    return doc


# ------------------------------------------------------------ renderers
def md_cell(s):
    return str(s).replace("|", "\\|").replace("\n", " ")


def render_md(doc):
    out = []
    for n, (title, blocks) in enumerate(doc):
        out.append(("# " if n == 0 else "## ") + title)
        out.append("")
        for b in blocks:
            if b[0] == "p":
                out.append(b[1])
                out.append("")
            elif b[0] == "h3":
                out.append("### " + b[1])
                out.append("")
            else:
                _, headers, rows, _cls = b
                out.append("| " + " | ".join(md_cell(h) for h in headers) + " |")
                out.append("|" + "|".join("---" for _ in headers) + "|")
                for r in rows:
                    out.append("| " + " | ".join(md_cell(c) for c in r) + " |")
                out.append("")
    return "\n".join(out).rstrip() + "\n"


CSS = """
:root{--bg:#fff;--fg:#1d2329;--mut:#5f6b76;--line:#d9dee3;--card:#f6f8fa;
--run:#117a3a;--runbg:#e3f5e9;--stall:#8a5a00;--stallbg:#fff1d1;--fin:#59636e;--finbg:#eceff2;color-scheme:light}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){--bg:#14181c;--fg:#e4e8ec;--mut:#98a4af;
--line:#2e353c;--card:#1c2127;--run:#5fd38a;--runbg:#16301f;--stall:#f0b84a;--stallbg:#3a2c0d;--fin:#a3adb7;--finbg:#232a31;color-scheme:dark}}
body{background:var(--bg);color:var(--fg);margin:0;padding:0 16px;font:14px/1.45 system-ui,-apple-system,Segoe UI,Roboto,sans-serif}
main{max-width:1000px;margin:0 auto;padding-block:12px 32px}
h1{font-size:1.25rem;margin:.5rem 0}h2{font-size:1.05rem;margin:1.6rem 0 .4rem;border-bottom:1px solid var(--line);padding-bottom:.25rem}
h3{font-size:.95rem;margin:1rem 0 .3rem}p{margin:.35rem 0;color:var(--mut)}
.w{overflow-x:auto;border:1px solid var(--line);border-radius:6px;margin:.4rem 0}
table{border-collapse:collapse;width:100%;font-size:12.5px}
th,td{padding:4px 8px;text-align:left;white-space:nowrap;border-bottom:1px solid var(--line)}
th{background:var(--card);color:var(--mut);font-weight:600}tr:last-child td{border-bottom:0}
td.t{white-space:normal;min-width:12em}
tr.running td:nth-child(3),tr.running td:first-child{color:var(--run)}tr.running{background:var(--runbg)}
tr.stalled{background:var(--stallbg)}tr.stalled td:first-child,tr.stalled td:nth-child(3){color:var(--stall)}
tr.finished,tr.idle{background:transparent}tr.finished td,tr.idle td{color:var(--fin)}
.badge{display:inline-block;padding:0 7px;border-radius:9px;font-weight:600;font-size:11.5px}
.badge.running{background:var(--runbg);color:var(--run)}.badge.stalled{background:var(--stallbg);color:var(--stall)}
.badge.finished,.badge.idle{background:var(--finbg);color:var(--fin)}
"""


def render_html(doc):
    parts = ["<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">",
             "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">",
             "<meta http-equiv=\"refresh\" content=\"120\">",
             "<title>%s</title><style>%s</style></head><body><main>" % (html.escape(doc[0][0]), CSS)]
    esc = html.escape
    for n, (title, blocks) in enumerate(doc):
        parts.append("<h%d>%s</h%d>" % (1 if n == 0 else 2, esc(title), 1 if n == 0 else 2))
        for b in blocks:
            if b[0] == "p":
                parts.append("<p>%s</p>" % esc(b[1]))
            elif b[0] == "h3":
                parts.append("<h3>%s</h3>" % esc(b[1]))
            else:
                _, headers, rows, cls = b
                parts.append("<div class=\"w\"><table><thead><tr>%s</tr></thead><tbody>" %
                             "".join("<th>%s</th>" % esc(h) for h in headers))
                for r, c in zip(rows, cls):
                    cells = []
                    for ci, v in enumerate(r):
                        v = str(v)
                        if c in ("running", "stalled", "finished", "idle") and headers[ci] == "State":
                            cells.append("<td><span class=\"badge %s\">%s</span></td>" % (c, esc(v)))
                        elif headers[ci] == "Title":
                            cells.append("<td class=\"t\">%s</td>" % esc(v))
                        else:
                            cells.append("<td>%s</td>" % esc(v))
                    parts.append("<tr%s>%s</tr>" % (" class=\"%s\"" % c if c in ("running", "stalled", "finished", "idle") else "",
                                                    "".join(cells)))
                parts.append("</tbody></table></div>")
    parts.append("</main></body></html>")
    return "".join(parts)


ARTIFACT_CSS = """
/* Layout: one column of stacked panels, summary strip first, tables scroll in their own frame. */
:root{
  --bg:#f6f4ef; --panel:#fffdf8; --ink:#23211c; --muted:#6b6557; --rule:#dcd6c8;
  --accent:#1f5f8b; --ok:#2f7d4f; --warn:#b5741a; --crit:#a63d2f; --idle:#8a8577;
  --font-ui:"IBM Plex Sans",system-ui,-apple-system,"Segoe UI",sans-serif;
  --font-data:"IBM Plex Mono",ui-monospace,SFMono-Regular,Menlo,monospace;
}
@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){
  --bg:#14161a; --panel:#1c1f25; --ink:#e6e3da; --muted:#9a968b; --rule:#333842;
  --accent:#6fb0dc; --ok:#5cb37f; --warn:#d9a24a; --crit:#e0705f; --idle:#7c8290; color-scheme:dark;}}
:root[data-theme="dark"]{
  --bg:#14161a; --panel:#1c1f25; --ink:#e6e3da; --muted:#9a968b; --rule:#333842;
  --accent:#6fb0dc; --ok:#5cb37f; --warn:#d9a24a; --crit:#e0705f; --idle:#7c8290; color-scheme:dark;}
body{background:var(--bg);color:var(--ink);font-family:var(--font-ui);font-size:14px;line-height:1.45;margin:0;
  padding-block:20px 40px;padding-left:max(16px,env(safe-area-inset-left,0px));padding-right:max(16px,env(safe-area-inset-right,0px));}
main{max-width:1100px;margin:0 auto;display:grid;gap:20px;}
h1{font-size:1.35rem;font-weight:600;margin:0;text-wrap:balance;letter-spacing:-0.01em}
h2{font-size:0.8rem;font-weight:600;text-transform:uppercase;letter-spacing:0.08em;color:var(--muted);margin:0 0 8px;border-bottom:1px solid var(--rule);padding-bottom:6px}
h3{font-size:0.95rem;font-weight:600;margin:12px 0 4px}
p{margin:0 0 8px;max-width:70ch;color:var(--muted)}
section{background:var(--panel);border:1px solid var(--rule);border-radius:6px;padding:14px 16px}
.w{overflow-x:auto}
table{border-collapse:collapse;width:100%;font-size:13px;font-variant-numeric:tabular-nums}
th{text-align:left;font-weight:600;color:var(--muted);font-size:0.72rem;text-transform:uppercase;letter-spacing:0.06em;padding:6px 8px;border-bottom:1px solid var(--rule);white-space:nowrap}
td{padding:6px 8px;border-bottom:1px solid var(--rule);vertical-align:top;font-family:var(--font-data);font-size:12.5px}
td.t{font-family:var(--font-ui);font-size:13px}
tr:last-child td{border-bottom:0}
.badge{display:inline-block;padding:1px 8px;border-radius:999px;font-family:var(--font-ui);font-size:11.5px;font-weight:600;color:#fff;background:var(--idle)}
.badge.running{background:var(--ok)}.badge.stalled{background:var(--warn)}.badge.finished{background:var(--idle)}.badge.idle{background:var(--accent)}
tr.stalled td{background:color-mix(in srgb,var(--warn) 10%,transparent)}
.strip{display:flex;flex-wrap:wrap;gap:12px}
.strip div{flex:1 1 140px;border:1px solid var(--rule);border-radius:6px;padding:10px 12px;background:var(--panel)}
.strip b{display:block;font-size:1.5rem;font-weight:600;font-family:var(--font-data);font-variant-numeric:tabular-nums}
.strip span{font-size:0.72rem;text-transform:uppercase;letter-spacing:0.06em;color:var(--muted)}
"""


def render_artifact(doc, agents, beads):
    """Artifact-skeleton HTML: starts with <title>, no html/head/body tags."""
    esc = html.escape
    subs = agents.get("subs", [])
    running = sum(a["state"] == "running" for a in subs)
    stalled = sum(a["state"] == "stalled" for a in subs)
    finished = sum(a["state"] == "finished" for a in subs)
    summ = beads.get("summary") or {}
    def sget(*keys):
        for k in keys:
            if isinstance(summ, dict) and k in summ:
                return summ[k]
        return "?"
    parts = ["<title>InterMine Sprint Board</title>",
             "<meta name=\"claude:viewport-fit-sides\" content=\"cover\">",
             "<link rel=\"stylesheet\" href=\"https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;600&family=IBM+Plex+Mono:wght@400;500&display=swap\">",
             "<style>%s</style><main>" % ARTIFACT_CSS,
             "<h1>%s</h1>" % esc(doc[0][0])]
    strip = [("%d" % running, "agents running"), ("%d" % stalled, "agents stalled"), ("%d" % finished, "agents finished"),
             (str(sget("open_issues", "open")), "beads open"), (str(sget("in_progress_issues", "in_progress")), "in progress"),
             (str(sget("closed_issues", "closed")), "closed")]
    parts.append("<div class=\"strip\">" + "".join("<div><b>%s</b><span>%s</span></div>" % (esc(v), esc(l)) for v, l in strip) + "</div>")
    for n, (title, blocks) in enumerate(doc):
        parts.append("<section>" if n else "<section>")
        if n:
            parts.append("<h2>%s</h2>" % esc(title))
        for b in blocks:
            if b[0] == "p":
                parts.append("<p>%s</p>" % esc(b[1]))
            elif b[0] == "h3":
                parts.append("<h3>%s</h3>" % esc(b[1]))
            else:
                _, headers, rows, cls = b
                parts.append("<div class=\"w\"><table><thead><tr>%s</tr></thead><tbody>" %
                             "".join("<th>%s</th>" % esc(h) for h in headers))
                for r, c in zip(rows, cls):
                    cells = []
                    for ci, v in enumerate(r):
                        v = str(v)
                        if c in ("running", "stalled", "finished", "idle") and headers[ci] == "State":
                            cells.append("<td><span class=\"badge %s\">%s</span></td>" % (c, esc(v)))
                        elif headers[ci] == "Title":
                            cells.append("<td class=\"t\">%s</td>" % esc(v))
                        else:
                            cells.append("<td>%s</td>" % esc(v))
                    parts.append("<tr%s>%s</tr>" % (" class=\"%s\"" % c if c in ("running", "stalled", "finished", "idle") else "", "".join(cells)))
                parts.append("</tbody></table></div>")
        parts.append("</section>")
    parts.append("</main>")
    return "".join(parts)


# ----------------------------------------------------------------- main
def write_atomic(path, text):
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        fh.write(text)
    os.replace(tmp, path)


def main(argv=None):
    ap = argparse.ArgumentParser(description="Generate sprint dashboard (STATUS.md + index.html).")
    ap.add_argument("--planning-repo", default=DEFAULT_PLANNING)
    ap.add_argument("--stall-minutes", type=float, default=10.0)
    ap.add_argument("--repos-dir", default=None, help="dir holding the code repos (default: parent of planning repo)")
    ap.add_argument("--main-log-dir", default=DEFAULT_MAIN_DIR)
    ap.add_argument("--tasks-glob", default=DEFAULT_TASKS_GLOB)
    args = ap.parse_args(argv)
    planning = os.path.abspath(args.planning_repo)
    repos_dir = args.repos_dir or os.path.dirname(planning)
    problems = []

    def safe(fn, default, label):
        try:
            return fn()
        except Exception as e:
            problems.append("%s failed: %s" % (label, e))
            return default

    agents = safe(lambda: collect_agents(args.main_log_dir, args.tasks_glob, args.stall_minutes),
                  {"main": None, "subs": [], "notes": ["agent log collection failed"]}, "agents")
    beads = safe(lambda: collect_beads(planning), {"issues": None, "summary": None,
                                                    "errors": ["beads collection failed"]}, "beads")
    repos = safe(lambda: collect_repos(repos_dir), [], "repos")
    runs, runs_err = safe(lambda: collect_runs(planning), (None, "runs collection failed"), "runs")
    doc = build_doc(agents, beads, repos, runs, runs_err, planning, args.stall_minutes)
    md, page = render_md(doc), render_html(doc)
    outdir = os.path.join(planning, "status")
    try:
        os.makedirs(outdir, exist_ok=True)
        write_atomic(os.path.join(outdir, "STATUS.md"), md)
        write_atomic(os.path.join(outdir, "index.html"), page)
        write_atomic(os.path.join(outdir, "artifact.html"), render_artifact(doc, agents, beads))
        # same page under the file name the current Claude artifact is published from
        # (https://claude.ai/code/artifact/cd45aac8-c4af-484d-99d6-58067cfdb478, since 15 Nov 2026 19:00 UTC;
        # the earlier artifact 15983604-... stopped accepting republishes with HTTP 403)
        write_atomic(os.path.join(outdir, "sprint-dashboard-3.html"), render_artifact(doc, agents, beads))
        wrote = "wrote status/STATUS.md, index.html and artifact.html"
    except Exception as e:
        wrote = "WRITE FAILED: %s" % e
    subs = agents["subs"]
    n_issues = len(beads["issues"]) if beads["issues"] is not None else None
    print("dashboard: agents %d running/%d stalled/%d finished; beads %s; repos %d; runs %s; %s%s" % (
        sum(a["state"] == "running" for a in subs), sum(a["state"] == "stalled" for a in subs),
        sum(a["state"] == "finished" for a in subs),
        ("%d issues" % n_issues) if n_issues is not None else "UNAVAILABLE",
        sum(1 for r in repos if r["ok"]), ("%d" % len(runs)) if runs is not None else "n/a", wrote,
        ("; problems: " + "; ".join(problems)) if problems else ""))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except SystemExit:
        raise
    except Exception as exc:  # never crash noisily
        print("dashboard: failed: %s" % exc)
        sys.exit(0)
