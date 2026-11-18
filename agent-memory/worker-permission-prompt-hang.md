---
name: worker-permission-prompt-hang
description: Subagent workers hang silently and for ever when a Bash call hits a permission prompt (relative-path rm -rf); require absolute paths and run_in_background
metadata:
  type: feedback
---

A worker agent's Bash call that needs a permission the allow rules do not cover (seen: `rm -rf trial_home_ut/humanmine ...` relative to a `cd` into repos/.sandbox-disk/rdfc2im) waits on a prompt nobody answers. The agent produces no transcript writes, no completion notification, and no processes run underneath it; the dashboard shows it as "stalled". 78 minutes were lost on 15 Nov 2026 before I noticed.

**Why:** Gos is often away; the allow rules in repos/.claude/settings.local.json match command text with absolute path prefixes, so relative paths fall through to a prompt.

**How to apply:** Every worker prompt says: use absolute paths in `rm` (under repos/.sandbox-disk/, /home/agent/taskhomes/, /tmp/claude-1000/, worktrees/), and start long jobs with run_in_background rather than `nohup ... &` plus sleep. When the dashboard shows a worker stalled (no log write for 10 min) and `ps` shows nothing running for it, read the last transcript entry; a tool_use with no tool_result means a hung call: TaskStop and relaunch with the on-disk state it left. See [[intermine-maintenance-sprint]] and [[sandbox-environment-notes]].

**Second instance (15 Nov 23:26Z):** `env PG_PORT=... docker compose -f ... down` blocked for 20 min although `docker compose` is allowed: the allow rules match the command prefix, so any leading `env VAR=`, `VAR=`, `cd x &&`, `time`, `sudo`, `nice` defeats them. Worker prompts now say: export variables on their own line, then run the plain command.

**Third instance (16 Nov 02:11Z):** `cd $B && mkdir -p newjar && cd newjar && rm -rf ./* && jar xf ...` inside the worker's own /home/agent/taskhomes dir; 20 min lost. Even with the rule in the brief, workers write relative rm inside their scratch dirs. Recovery that worked: TaskStop the agent, then SendMessage to the same id (it resumes with its context) telling it which call hung and to redo it with absolute paths.

- 5th instance 16 Nov 18:30 UTC (im-jqz.67): `rm -rf $(cat .../builddirs.txt)` after the gate had finished; 25 min lost. Rule added to CLAUDE.md: no command substitution or variables in rm calls; literal absolute paths only.

- 6th instance 18 Nov 2026 01:09 UTC (im-9n4.5): a read-only compound call hung 15 min:
  `S=...; bash $S/counts.sh | tee ...; cd <wt>; grep ...; curl ...; for c in ...; do p=$([ $c ...`. No rm
  involved: `cd dir;` plus `$(...)` inside a loop is enough. Briefs should say: one simple command per
  Bash call, absolute paths, no `cd x;` prefix, no `$(...)`/loops building commands. Stall watch must
  read the transcript's last JSONL timestamp (file mtime is unreliable) and drop finished agents;
  recovery (TaskStop then SendMessage to the same id naming the hung call) worked again.
- Servers a worker starts with run_in_background get SIGTERM when that worker finishes: lasting
  servers must be started `setsid nohup ... &` (found 17 Nov with the BlueGenes jar on :15001).
