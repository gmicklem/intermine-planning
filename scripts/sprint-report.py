#!/usr/bin/env python3
"""Generate status/sprint-report.md: what the sprint cost and delivered, per model.

Usage:  python3 -I scripts/sprint-report.py [--out status/sprint-report.md]
                                            [--prices FILE] [--since 2026-11-14]
                                            [--planning-repo PATH]

Inputs (all read-only):
  status/agent-runs.csv        one row per recorded worker run (see scripts/record-run.py)
  bd list/status --json        beads issues (run in the planning repo root)
  Claude Code session logs     orchestrator tokens (main session JSONL) and, as a
                               cross-check, every subagent *.output log
  git log                      this repo plus the code repos, commits since --since

Standard library only.  Every missing input degrades to a warning on stderr and a
"not available" section; the script still writes a report.  Parsing helpers for
the Claude Code logs are reused from scripts/dashboard.py (imported by path).

Notes on the data:
  * A worker resumed with SendMessage is recorded again with the same started_utc and
    cumulative token counts.  Such rows are de-cumulated (each row is charged only the
    increase over the previous row of its chain) so tokens are not counted twice.
  * Prices are applied only when --prices FILE is given:
      {"opus": {"input": 15, "cache_read": 1.5, "cache_write": 18.75, "output": 75}, ...}
    (USD per million tokens, keyed by model family name; nothing is assumed).
"""
import argparse
import csv
import glob
import importlib.util
import json
import os
import re
import statistics
import subprocess
import sys
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULT_PLANNING = os.path.dirname(HERE)
DEFAULT_MAIN_DIR = "/home/agent/.claude/projects/-Users-gos-claude-projects-update-intermine-planning-repos"
DEFAULT_TASKS_GLOB = ("/tmp/claude-1000/-Users-gos-claude-projects-update-intermine-planning-repos/"
                      "0492e8a9-74f1-4807-9fab-46d9cc2516dd/tasks/*.output")
CODE_REPOS = ["intermine", "bluegenes", "imcljs", "bluegenes-tool-store", "im-tables-3"]
TOK = ["input", "cache_read", "cache_write", "output"]
TOK_LABEL = {"input": "Input", "cache_read": "Cache read", "cache_write": "Cache write", "output": "Output"}
FAMILIES = ["opus", "sonnet", "haiku", "fable"]
SUCCESS = {"done", "success", "succeeded", "ok", "complete", "completed", "passed", "pass"}
WARNINGS = []


def warn(msg):
    WARNINGS.append(msg)
    print("sprint-report: warning: " + msg, file=sys.stderr)


# --------------------------------------------------------------- helpers
def load_dashboard():
    """Import scripts/dashboard.py by path (python -I keeps the script dir off sys.path)."""
    try:
        spec = importlib.util.spec_from_file_location("sprint_dashboard", os.path.join(HERE, "dashboard.py"))
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        return mod
    except Exception as e:
        warn("could not import scripts/dashboard.py log parser: %s" % e)
        return None


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


def to_int(x):
    try:
        return int(float(x))
    except Exception:
        return 0


def family(model):
    """Short family name: opus / sonnet / haiku / fable, else the lower-cased input."""
    m = (model or "?").strip().lower()
    for f in FAMILIES:
        if f in m:
            return f
    return m or "?"


def classify(outcome):
    o = (outcome or "").strip().lower()
    if o in SUCCESS:
        return "success"
    if o.startswith(("fail", "error", "abort", "abandon", "blocked")):
        return "failed"
    if o.startswith("partial"):
        return "partial"
    return "other"


def fmt_n(n):
    return "{:,}".format(int(round(n)))


def fmt_dur(sec):
    sec = int(round(sec))
    h, rem = divmod(sec, 3600)
    m, s = divmod(rem, 60)
    return "%d:%02d:%02d" % (h, m, s)


def fmt_dt(dt):
    return dt.strftime("%Y-%m-%d %H:%M:%S UTC") if dt else "n/a"


def cell(s):
    return str(s).replace("|", "\\|").replace("\n", " ")


def md_table(headers, rows):
    out = ["| " + " | ".join(cell(h) for h in headers) + " |", "|" + "|".join("---" for _ in headers) + "|"]
    for r in rows:
        out.append("| " + " | ".join(cell(c) for c in r) + " |")
    return out


def run(cmd, cwd=None, timeout=60):
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=timeout)
        return p.returncode, p.stdout, p.stderr
    except Exception as e:
        return 127, "", str(e)


def find_bd():
    cands = ["bd"]
    rc, out, _ = run(["bash", "-l", "-c", "which bd"], timeout=20)
    if rc == 0 and out.strip():
        cands.append(out.strip().splitlines()[-1])
    cands.append(None)  # npx fallback
    for c in cands:
        cmd = [c] if c else ["npx", "-y", "@beads/bd"]
        rc, _, _ = run(cmd + ["--version"], timeout=60 if c is None else 20)
        if rc == 0:
            return cmd
    return None


def bd_json(bd, args, cwd):
    rc, out, err = run(bd + args, cwd=cwd, timeout=60)
    if rc != 0:
        raise RuntimeError("bd %s failed (rc=%s): %s" % (" ".join(args), rc, (err or out).strip()[:200]))
    data = json.loads(out)
    if isinstance(data, dict) and "data" in data and "schema_version" in data:
        data = data["data"]
    return data


def git(repo, *args):
    rc, out, _ = run(["git", "-c", "safe.directory=*", "-C", repo] + list(args), timeout=60)
    return out.strip() if rc == 0 else None


# ------------------------------------------------------------ data: runs
def load_runs(planning):
    path = os.path.join(planning, "status", "agent-runs.csv")
    if not os.path.isfile(path):
        warn("status/agent-runs.csv not found")
        return None
    try:
        with open(path, newline="", encoding="utf-8", errors="replace") as fh:
            rows = [r for r in csv.DictReader(fh) if any((v or "").strip() for v in r.values() if isinstance(v, str))]
    except Exception as e:
        warn("agent-runs.csv unreadable: %s" % e)
        return None
    runs = []
    for r in rows:
        st, en = parse_ts(r.get("started_utc")), parse_ts(r.get("ended_utc"))
        runs.append({
            "start": st, "end": en, "bead": (r.get("beads_id") or "").strip(),
            "label": (r.get("agent_label") or "").strip(), "model": family(r.get("model")),
            "raw_model": (r.get("model") or "").strip(),
            "tok": {"input": to_int(r.get("input_tokens")), "cache_read": to_int(r.get("cache_read_tokens")),
                    "cache_write": to_int(r.get("cache_write_tokens")), "output": to_int(r.get("output_tokens"))},
            "outcome": (r.get("outcome") or "").strip(), "notes": (r.get("notes") or "").strip(),
            "start_raw": r.get("started_utc") or "",
        })
    # de-cumulate resumed agents (same started_utc, token counts that only grow)
    chains = {}
    for r in runs:
        chains.setdefault((r["start_raw"], r["model"]), []).append(r)
    nchain = 0
    for key, ch in chains.items():
        r0 = ch[0]
        for r in ch:
            r["cum_tok"] = dict(r["tok"])
            r["dur"] = (r["end"] - r["start"]).total_seconds() if r["start"] and r["end"] else None
        if len(ch) < 2 or not key[0]:
            continue
        ch.sort(key=lambda r: r["end"] or datetime.max.replace(tzinfo=timezone.utc))
        if all(all(b["cum_tok"][k] >= a["cum_tok"][k] for k in TOK) for a, b in zip(ch, ch[1:])):
            nchain += len(ch) - 1
            for a, b in zip(ch, ch[1:]):
                b["tok"] = {k: b["cum_tok"][k] - a["cum_tok"][k] for k in TOK}
                b["dur"] = (b["end"] - a["end"]).total_seconds() if a["end"] and b["end"] else None
                b["resumed"] = True
    return {"runs": runs, "n_resumed": nchain}


# ---------------------------------------------------------- data: logs
def log_totals(analysis):
    t = {}
    for a in analysis:
        for m, d in a["models"].items():
            x = t.setdefault(family(m), {"msgs": 0, "input": 0, "cache_read": 0, "cache_write": 0, "output": 0, "ids": set()})
            x["msgs"] += d["msgs"]
            x["input"] += d["in"]
            x["cache_read"] += d["cr"]
            x["cache_write"] += d["cw"]
            x["output"] += d["out"]
            x["ids"].add(m)
    return t


def load_logs(dash, main_dir, tasks_glob):
    res = {"main": None, "subs": None, "main_files": 0, "main_first": None, "main_last": None}
    if dash is None:
        return res
    files = sorted(p for p in glob.glob(os.path.join(main_dir, "*.jsonl")) if os.path.isfile(p))
    if not files:
        warn("no orchestrator session log under %s" % main_dir)
    else:
        logs = []
        for p in files:
            try:
                a = dash.analyse_log(p)
                if a:
                    logs.append(a)
            except Exception as e:
                warn("could not parse %s: %s" % (os.path.basename(p), e))
        if logs:
            res["main"] = log_totals(logs)
            res["main_files"] = len(logs)
            firsts = [a["first"] for a in logs if a["first"]]
            lasts = [a["last"] for a in logs if a["last"]]
            res["main_first"] = min(firsts) if firsts else None
            res["main_last"] = max(lasts) if lasts else None
    outs = sorted(glob.glob(tasks_glob))
    if not outs:
        warn("no subagent output logs match %s" % tasks_glob)
    else:
        subs, seen, skipped = [], set(), 0
        for p in outs:
            rp = os.path.realpath(p)
            if rp in seen:
                continue
            seen.add(rp)
            try:
                a = dash.analyse_log(p)
            except Exception:
                a = None
            if a:
                subs.append(a)
            else:
                skipped += 1
        res["subs"] = log_totals(subs)
        res["subs_n"] = len(subs)
        res["subs_skipped"] = skipped
    return res


# ----------------------------------------------------------- data: beads
def load_beads(planning):
    bd = find_bd()
    if not bd:
        warn("bd not available (tried PATH, login shell, npx); beads sections omitted")
        return None
    try:
        try:
            issues = bd_json(bd, ["list", "--json", "--all", "--flat", "-n", "0"], planning)
        except Exception:
            issues = bd_json(bd, ["list", "--json"], planning)
        issues = [i for i in issues if isinstance(i, dict)]
    except Exception as e:
        warn("bd list failed: %s" % e)
        return None
    summary = None
    try:
        st = bd_json(bd, ["status", "--json"], planning)
        summary = st.get("summary", st) if isinstance(st, dict) else None
    except Exception as e:
        warn("bd status failed: %s" % e)
    return {"issues": issues, "summary": summary}


def epic_of(i):
    """Epic id for an issue: first dotted segment of its id (im-ee7.2 -> im-ee7); epics have no dot."""
    iid = str(i.get("id", ""))
    if "." in iid:
        return iid.split(".", 1)[0]
    return None


# -------------------------------------------------------------- data: git
def git_section(planning, repos_dir, since):
    rows = []
    targets = [("intermine-planning", planning)] + [(n, os.path.join(repos_dir, n)) for n in CODE_REPOS]
    for name, path in targets:
        if not os.path.isdir(path):
            rows.append({"name": name, "ok": False})
            continue
        has = git(path, "rev-parse", "--verify", "-q", "refs/heads/maint-2026")
        ref = "maint-2026" if has else "HEAD"
        log = git(path, "log", ref, "--since=" + since, "--format=%h %s")
        merges = git(path, "log", ref, "--since=" + since, "--merges", "--format=%h %s")
        authors = git(path, "log", ref, "--since=" + since, "--format=%an")
        row = {"name": name, "ok": log is not None, "ref": ref,
               "count": len(log.splitlines()) if log else 0,
               "merges": merges.splitlines() if merges else [], "unmerged": []}
        if row["ok"] and has:
            brs = git(path, "for-each-ref", "--format=%(refname:short)", "refs/heads/maint/*") or ""
            for b in brs.splitlines():
                ahead = git(path, "rev-list", "--count", "maint-2026.." + b)
                if ahead and int(ahead) > 0:
                    subj = git(path, "log", "-1", "--format=%h %s", b) or ""
                    row["unmerged"].append((b, int(ahead), subj))
        rows.append(row)
    return rows


# ---------------------------------------------------------------- pricing
def load_prices(path):
    if not path:
        return None
    try:
        with open(path, encoding="utf-8") as fh:
            raw = json.load(fh)
        prices = {}
        for k, v in raw.items():
            prices[family(k)] = {t: float(v.get(t, 0) or 0) for t in TOK}
        return prices
    except Exception as e:
        warn("could not read prices file %s: %s" % (path, e))
        return None


def cost(tok, price):
    return sum(tok.get(k, 0) * price[k] for k in TOK) / 1e6


# ------------------------------------------------------------- the report
def build(args):
    planning = os.path.abspath(args.planning_repo)
    repos_dir = args.repos_dir or os.path.dirname(planning)
    dash = load_dashboard()
    rd = load_runs(planning)
    logs = load_logs(dash, args.main_log_dir, args.tasks_glob)
    beads = load_beads(planning)
    gitrows = git_section(planning, repos_dir, args.since)
    prices = load_prices(args.prices)
    now = datetime.now(timezone.utc)
    L = ["# Sprint report", "",
         "Generated %s by `scripts/sprint-report.py` (since %s). Regenerate with "
         "`python3 -I scripts/sprint-report.py`. All times UTC." % (now.strftime("%Y-%m-%d %H:%M"), args.since), ""]
    runs = rd["runs"] if rd else None
    models = sorted({r["model"] for r in runs}) if runs else []

    # ---- 1 headline
    L += ["## 1. Headline", ""]
    stamps = []
    if runs:
        for r in runs:
            stamps += [t for t in (r["start"], r["end"]) if t]
    if logs["main_first"]:
        stamps += [logs["main_first"], logs["main_last"]]
    if stamps:
        w0, w1 = min(stamps), max(stamps)
        L += ["Sprint window (first to last timestamp in agent-runs.csv and the orchestrator log): "
              "%s to %s, elapsed %s." % (fmt_dt(w0), fmt_dt(w1), fmt_dur((w1 - w0).total_seconds())), ""]
    if not runs:
        L += ["Agent runs: not available.", ""]
    else:
        L += ["Total agent runs recorded: %d (%d of them resumptions of an earlier agent, charged only for the "
              "tokens added since its previous row)." % (len(runs), rd["n_resumed"]), ""]
        rows = []
        for m in models:
            rs = [r for r in runs if r["model"] == m]
            c = {k: sum(1 for r in rs if classify(r["outcome"]) == k) for k in ("success", "failed", "partial", "other")}
            tk = {k: sum(r["tok"][k] for r in rs) for k in TOK}
            durs = [r["dur"] for r in rs if r["dur"] is not None]
            rows.append([m, len(rs), c["success"], c["failed"], c["partial"], c["other"]] +
                        [fmt_n(tk[k]) for k in TOK] + [fmt_dur(sum(durs)),
                                                      fmt_dur(statistics.median(durs)) if durs else "n/a"])
        alld = [r["dur"] for r in runs if r["dur"] is not None]
        tk = {k: sum(r["tok"][k] for r in runs) for k in TOK}
        rows.append(["**all workers**", len(runs)] +
                    [sum(1 for r in runs if classify(r["outcome"]) == k) for k in ("success", "failed", "partial", "other")] +
                    [fmt_n(tk[k]) for k in TOK] + [fmt_dur(sum(alld)), fmt_dur(statistics.median(alld)) if alld else "n/a"])
        om = logs["main"]
        if om:
            for m in sorted(om):
                d = om[m]
                rows.append(["orchestrator (%s)" % m, "n/a (%d msgs)" % d["msgs"], "-", "-", "-", "-"] +
                            [fmt_n(d[k]) for k in TOK] + ["-", "-"])
        else:
            rows.append(["orchestrator", "not available", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-"])
        L += md_table(["Model", "Runs", "Success", "Failed", "Partial", "Other"] + [TOK_LABEL[k] + " tok" for k in TOK] +
                      ["Wall-clock agent time", "Median run"], rows)
        L += ["",
              "Success = outcome `done`/`success`; failed = outcome starting `fail`/`error`/`abort`/`blocked`; "
              "partial = starting `partial`; other = anything else. Wall-clock agent time is the sum of "
              "ended minus started per run; agents ran in parallel, so it exceeds elapsed time. "
              "The orchestrator is the main Claude Code session (not in agent-runs.csv); its totals come from "
              "the session JSONL (%d file(s), de-duplicated per API message id) and cover its whole context "
              "re-reads, so cache read is large by nature." % logs["main_files"], ""]
        if logs["subs"] is not None:
            sub = logs["subs"]
            csvt = {m: {k: sum(r["tok"][k] for r in runs if r["model"] == m) for k in TOK} for m in models}
            xr = []
            for m in sorted(set(sub) | set(csvt)):
                s = sub.get(m, {k: 0 for k in TOK})
                c = csvt.get(m, {k: 0 for k in TOK})
                xr.append([m] + ["%s / %s" % (fmt_n(c[k]), fmt_n(s[k])) for k in TOK])
            L += ["Cross-check (agent-runs.csv / all subagent logs on disk, %d logs parsed): " % logs.get("subs_n", 0) +
                  "differences are agents not yet recorded or still running.", ""]
            L += md_table(["Model"] + [TOK_LABEL[k] for k in TOK], xr) + [""]

    # ---- 2 delivered
    L += ["## 2. Delivered", "", "### Commits on maint-2026 since %s" % args.since, ""]
    grows = []
    for g in gitrows:
        if not g["ok"]:
            grows.append([g["name"], "not available", "-", "-"])
        else:
            grows.append([g["name"], g["ref"], g["count"], len(g["merges"])])
    L += md_table(["Repo", "Ref", "Commits", "Merge commits"], grows) + [""]
    for g in gitrows:
        if g["ok"] and g["merges"]:
            L += ["**%s merge commits**" % g["name"], ""] + ["- `%s`" % m for m in g["merges"]] + [""]
        if g["ok"] and g["unmerged"]:
            L += ["**%s unmerged maint/* branches ahead of maint-2026**" % g["name"], ""]
            L += ["- `%s`: %d commit(s), tip `%s`" % u for u in g["unmerged"]] + [""]
    L += ["### Beads", ""]
    if beads is None:
        L += ["Not available (bd could not be run).", ""]
    else:
        iss = beads["issues"]
        s = beads["summary"]
        if s:
            L += ["`bd status`: total %s, open %s, in progress %s, blocked %s, ready %s, closed %s." % (
                s.get("total_issues", "?"), s.get("open_issues", "?"), s.get("in_progress_issues", "?"),
                s.get("blocked_issues", "?"), s.get("ready_issues", "?"), s.get("closed_issues", "?")), ""]
        epics = sorted([i for i in iss if "." not in str(i.get("id", ""))], key=lambda i: str(i["id"]))
        erows = []
        for e in epics:
            kids = [i for i in iss if epic_of(i) == e["id"]]
            cnt = lambda st: sum(1 for k in kids if k.get("status") == st)
            erows.append([e["id"], e.get("title", ""), e.get("status", ""), len(kids), cnt("open"),
                          cnt("in_progress"), cnt("closed")])
        L += md_table(["Epic", "Title", "Epic status", "Children", "Open", "In progress", "Closed"], erows) + [""]
        L += ["#### Closed issues by epic", ""]
        for e in epics:
            closed = sorted([i for i in iss if epic_of(i) == e["id"] and i.get("status") == "closed"],
                            key=lambda i: str(i["id"]))
            if e.get("status") == "closed":
                closed = [e] + closed
            if closed:
                L += ["**%s %s**" % (e["id"], e.get("title", "")), ""] + \
                     ["- `%s` %s" % (i["id"], i.get("title", "")) for i in closed] + [""]
        if not any(i.get("status") == "closed" for i in iss):
            L += ["No closed issues.", ""]
    # ---- 3 cost per outcome
    L += ["## 3. Cost per outcome", ""]
    if not runs:
        L += ["Not available (no agent runs).", ""]
    else:
        rows = []
        for m in models:
            for cls in ("success", "failed", "partial", "other"):
                rs = [r for r in runs if r["model"] == m and classify(r["outcome"]) == cls]
                if rs:
                    rows.append([m, cls, len(rs)] + [fmt_n(sum(r["tok"][k] for r in rs) / len(rs)) for k in TOK])
                elif cls in ("success", "failed"):
                    rows.append([m, cls, 0] + ["-"] * 4)
        L += ["Mean tokens per run, by model and outcome class:", ""]
        L += md_table(["Model", "Outcome class", "Runs"] + ["Mean " + TOK_LABEL[k].lower() for k in TOK], rows) + [""]
        if prices:
            key = lambda r: cost(r["tok"], prices[r["model"]]) if r["model"] in prices else -1
            how = "ranked by approximate cost at the supplied prices"
        else:
            key = lambda r: (r["tok"]["output"], r["tok"]["cache_write"])
            how = "ranked by output tokens, then cache write tokens (no prices supplied)"
        top = sorted(runs, key=key, reverse=True)[:5]
        L += ["Five most expensive runs, %s:" % how, ""]
        L += md_table(["Run", "Bead", "Model", "Output tok", "Cache write tok", "Outcome"],
                      [[r["label"], r["bead"], r["model"], fmt_n(r["tok"]["output"]), fmt_n(r["tok"]["cache_write"]),
                        r["outcome"]] for r in top]) + [""]

    # ---- 4 usage pattern
    L += ["## 4. Model usage pattern", ""]
    if not runs:
        L += ["Not available.", ""]
    else:
        for m in models:
            rs = sorted([r for r in runs if r["model"] == m], key=lambda r: r["start"] or now)
            L += ["**%s** (%d runs)" % (m, len(rs)), ""]
            L += ["- %s (`%s`)" % (r["label"], r["bead"] or "-") for r in rs] + [""]

    # ---- 5 notes
    L += ["## 5. Notes", ""]
    if prices:
        parts, tot = [], 0.0
        rows = []
        for m in models:
            tk = {k: sum(r["tok"][k] for r in runs if r["model"] == m) for k in TOK}
            rows.append((m, tk))
        om = logs["main"] or {}
        for m in sorted(om):
            rows.append(("orchestrator (%s)" % m, {k: om[m][k] for k in TOK}))
        crow = []
        missing = []
        for label, tk in rows:
            fam = family(label.split("(")[-1].rstrip(")")) if label.startswith("orchestrator") else label
            if fam in prices:
                c = cost(tk, prices[fam])
                tot += c
                crow.append([label, "%.2f" % c])
            else:
                missing.append(label)
                crow.append([label, "no price supplied"])
        L += ["Approximate pricing: list prices from `%s` (USD per million tokens) applied to the token totals "
              "above; this ignores batch/priority tiers, long-context premiums and any subscription or plan "
              "allowances, so treat it as indicative only." % args.prices, ""]
        L += md_table(["Model", "Approx. USD"], crow + [["**total (priced rows)**", "%.2f" % tot]]) + [""]
        if missing:
            L += ["No price was supplied for: %s." % ", ".join(missing), ""]
    else:
        L += ["Approximate pricing: not applied. Token totals are shown without prices; pass "
              "`--prices prices.json` (model name to per-million-token prices for input, cache_read, "
              "cache_write, output) to add an approximate cost.", ""]
    L += ["Token counts are de-duplicated per API message id. Runs that resume an earlier agent are charged "
          "for the increase over the previous row of that agent (same started_utc).", ""]
    if WARNINGS:
        L += ["Warnings while generating:", ""] + ["- " + w for w in WARNINGS] + [""]

    # ---- 6 open items
    L += ["## 6. Open items / blockers", ""]
    if beads is None:
        L += ["Not available (bd could not be run).", ""]
    else:
        hits = []
        for i in beads["issues"]:
            if i.get("status") == "closed":
                continue
            labs = [str(x).lower() for x in (i.get("labels") or [])]
            title = str(i.get("title", "")).lower()
            why = []
            if "human" in labs:
                why.append("label human")
            if "blocked" in labs:
                why.append("label blocked")
            if i.get("status") == "blocked":
                why.append("status blocked")
            if re.search(r"\bblocked\b", title):
                why.append("title mentions blocked")
            if re.search(r"\bhuman\b", title):
                why.append("title mentions human")
            if why:
                hits.append([i["id"], i.get("title", ""), i.get("status", ""), ", ".join(why)])
        if hits:
            L += md_table(["Issue", "Title", "Status", "Why listed"], sorted(hits)) + [""]
        else:
            L += ["No open issue carries the label `human` or `blocked` or mentions either word in its title.", ""]
        s = beads["summary"]
        if s and s.get("blocked_issues") is not None:
            L += ["`bd status` also counts %s issue(s) as blocked by unfinished dependencies (see `bd blocked`)." %
                  s["blocked_issues"], ""]
    return "\n".join(L).rstrip() + "\n"


def main(argv=None):
    ap = argparse.ArgumentParser(description="Generate the sprint report (status/sprint-report.md).")
    ap.add_argument("--planning-repo", default=DEFAULT_PLANNING)
    ap.add_argument("--out", default=None, help="output file (default: <planning-repo>/status/sprint-report.md)")
    ap.add_argument("--prices", default=None, help="JSON file: model -> {input, cache_read, cache_write, output} USD per Mtok")
    ap.add_argument("--since", default="2026-11-14", help="count commits since this date (default 2026-11-14)")
    ap.add_argument("--repos-dir", default=None, help="dir holding the code repos (default: parent of planning repo)")
    ap.add_argument("--main-log-dir", default=DEFAULT_MAIN_DIR)
    ap.add_argument("--tasks-glob", default=DEFAULT_TASKS_GLOB)
    args = ap.parse_args(argv)
    out = args.out or os.path.join(os.path.abspath(args.planning_repo), "status", "sprint-report.md")
    if not os.path.isabs(out):
        out = os.path.join(os.path.abspath(args.planning_repo), out)
    text = build(args)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    tmp = out + ".tmp"
    with open(tmp, "w", encoding="utf-8") as fh:
        fh.write(text)
    os.replace(tmp, out)
    print("sprint-report: wrote %s (%d lines, %d warning(s))" % (out, text.count("\n"), len(WARNINGS)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
