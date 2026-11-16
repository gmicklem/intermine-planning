#!/usr/bin/env python3
"""Convert a Claude Code session JSONL log into a readable Markdown transcript.

Usage: transcript.py SESSION.jsonl OUT.md [TASKS_DIR]
Keeps user and assistant text in full, summarises each tool call on one line,
and appends token totals per model (main session plus subagent task logs).
"""
import json
import os, re, sys, glob, os
from collections import defaultdict
from datetime import datetime, timezone

def clean_user_text(t):
    t = re.sub(r"<system-reminder>.*?</system-reminder>", "", t, flags=re.S)
    t = re.sub(r"<local-command-caveat>.*?</local-command-caveat>", "", t, flags=re.S)
    t = re.sub(r"<local-command-stdout>.*?</local-command-stdout>", "", t, flags=re.S)
    t = re.sub(r"<command-(name|message|args)>.*?</command-\1>", "", t, flags=re.S)
    t = re.sub(r"\[SYSTEM NOTIFICATION - NOT USER INPUT\].*", "", t, flags=re.S)
    t = re.sub(r"<task-notification>.*?</task-notification>", "", t, flags=re.S)
    return t.strip()

def summarise_tool(block):
    name = block.get("name", "?"); inp = block.get("input", {}) or {}
    if name == "Bash":
        return f"`Bash`: {inp.get('description') or inp.get('command','')[:120]}"
    if name == "Agent":
        return f"`Agent` ({inp.get('subagent_type','general')}, model={inp.get('model','default')}): {inp.get('description','')}"
    if name in ("Read", "Write", "Edit"):
        return f"`{name}`: {inp.get('file_path','')}"
    if name == "WebFetch":
        return f"`WebFetch`: {inp.get('url','')}"
    if name == "AskUserQuestion":
        qs = inp.get("questions", [])
        return "`AskUserQuestion`: " + " | ".join(q.get("question","") for q in qs)
    s = json.dumps(inp)[:120]
    return f"`{name}`: {s}"

def fmt_ts(ts):
    try:
        return datetime.fromisoformat(ts.replace("Z", "+00:00")).astimezone(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    except Exception:
        return ts or ""

def usage_from(path, per_model):
    if not os.path.exists(path):  # a background task whose output file was cleaned up
        return
    with open(path, errors="replace") as f:
        for line in f:
            try: rec = json.loads(line)
            except Exception: continue
            if not isinstance(rec, dict): continue
            msg = rec.get("message") or {}
            u = msg.get("usage")
            if not u: continue
            m = msg.get("model", "?")
            for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens", "output_tokens"):
                per_model[m][k] += u.get(k, 0) or 0

def main():
    src, out = sys.argv[1], sys.argv[2]
    tasks_dir = sys.argv[3] if len(sys.argv) > 3 else None
    lines = ["# Session transcript", "", f"Source: `{os.path.basename(src)}`. Generated {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}.",
             "User and assistant text are verbatim; tool calls are summarised one per line; tool outputs are omitted.", ""]
    with open(src, errors="replace") as f:
        for line in f:
            try: rec = json.loads(line)
            except Exception: continue
            if not isinstance(rec, dict): continue
            typ = rec.get("type"); msg = rec.get("message") or {}
            content = msg.get("content")
            ts = fmt_ts(rec.get("timestamp", ""))
            if typ == "user":
                texts = []
                if isinstance(content, str): texts.append(content)
                elif isinstance(content, list):
                    for b in content:
                        if b.get("type") == "text": texts.append(b.get("text", ""))
                t = clean_user_text("\n".join(texts))
                if t:
                    lines += [f"## Gos ({ts})", "", t, ""]
            elif typ == "assistant" and isinstance(content, list):
                texts, tools = [], []
                for b in content:
                    if b.get("type") == "text" and b.get("text", "").strip(): texts.append(b["text"].strip())
                    elif b.get("type") == "tool_use": tools.append(summarise_tool(b))
                if texts: lines += [f"## Claude ({ts})", ""] + texts + [""]
                if tools: lines += [f"- {t}" for t in tools] + [""]
    per_model = defaultdict(lambda: defaultdict(int))
    usage_from(src, per_model)
    sub = defaultdict(lambda: defaultdict(int))
    if tasks_dir:
        for p in glob.glob(os.path.join(tasks_dir, "*.output")):
            usage_from(p, sub)
    lines += ["## Token usage", "", "| Scope | Model | Input | Cache write | Cache read | Output |", "|---|---|---:|---:|---:|---:|"]
    for scope, d in (("main session", per_model), ("subagents", sub)):
        for m, u in sorted(d.items()):
            if m.startswith("<"): continue
            lines.append(f"| {scope} | {m} | {u['input_tokens']:,} | {u['cache_creation_input_tokens']:,} | {u['cache_read_input_tokens']:,} | {u['output_tokens']:,} |")
    with open(out, "w") as f: f.write("\n".join(lines) + "\n")
    print(f"wrote {out}: {len(lines)} lines")

if __name__ == "__main__":
    main()
