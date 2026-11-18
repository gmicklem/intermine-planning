# Project Instructions for AI Agents

This file provides instructions and context for AI coding agents working on this project.

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:1105d646 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/core-concepts/sync-concepts.md for details and anti-patterns.

## Agent Context Profiles

The managed Beads block is task-tracking guidance, not permission to override repository, user, or orchestrator instructions.

- **Conservative (default)**: Use `bd` for task tracking. Do not run git commits, git pushes, or Dolt remote sync unless explicitly asked. At handoff, report changed files, validation, and suggested next commands.
- **Minimal**: Keep tool instruction files as pointers to `bd prime`; use the same conservative git policy unless active instructions say otherwise.
- **Team-maintainer**: Only when the repository explicitly opts in, agents may close beads, run quality gates, commit, and push as part of session close. A current "do not commit" or "do not push" instruction still wins.

## Session Completion

This protocol applies when ending a Beads implementation workflow. It is subordinate to explicit user, repository, and orchestrator instructions.

1. **File issues for remaining work** - Create beads for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **Handle git/sync by active profile**:
   ```bash
   # Conservative/minimal/default: report status and proposed commands; wait for approval.
   git status

   # Team-maintainer opt-in only, unless current instructions forbid it:
   git pull --rebase
   git push
   git status
   ```
5. **Hand off** - Summarize changes, validation, issue status, and any blocked sync/commit/push step

**Critical rules:**
- Explicit user or orchestrator instructions override this Beads block.
- Do not commit or push without clear authority from the active profile or the current user request.
- If a required sync or push is blocked, stop and report the exact command and error.
<!-- END BEADS INTEGRATION -->


## How this repo is used (orchestrator conventions)

- This is the planning repo for the 2026 InterMine + BlueGenes maintenance sprint. The master plan is `plans/00-overview.md`; per-area plans are `plans/10..40`.
- **Only the orchestrator session writes to beads.** Worker agents receive their issue text in the prompt, never run `bd` write commands, and report back in their final message. (This overrides the generic Beads guidance above.)
- Worker agents never commit in this repo; the orchestrator commits and pushes at checkpoints.
- Worker prompts must say: write `rm` with absolute paths that match the allow rules in repos/.claude/settings.local.json (a relative path after `cd` hits a permission prompt nobody can answer and hangs the worker for ever; 78 min lost 15 Nov), and start long jobs with the Bash tool's run_in_background rather than `nohup ... &` plus sleep. Allow rules match the command prefix, so never put `env VAR=x`, `VAR=x`, `cd dir &&`, `time`, `sudo` or `nice` in front of an allowed command (`docker compose`, `rm -rf /abs/path`, `psql`, `dropdb`, `pkill`): export variables on their own line first, then run the plain command (a worker lost 20 min on `env ... docker compose down` 15 Nov). Never use command substitution or variables inside an `rm` call (`rm -rf $(cat list)`, `rm -rf "$DIR"/*`): the rule matcher sees the literal text, so it prompts; a worker hung 25 min on that 16 Nov. List the absolute paths literally.
- Code work happens in git worktrees under `../../worktrees/<repo>/<beads-id>-<slug>` created with `scripts/worktree.sh`, on branches `maint/<beads-id>-<slug>` from `maint-2026`.
- Gate scripts: `scripts/gate-intermine.sh`, `scripts/gate-bluegenes.sh`, `scripts/gate-im-tables.sh`, `scripts/gate-tool-store.sh`; test isolation: `scripts/im-testenv.sh <task-id> create|env|destroy --src DIR` (per-task Postgres databases, `~/.intermine` properties and `GRADLE_USER_HOME` with shared caches; `--role`/`--role-ci` non-superuser modes). Workers must `eval "$(scripts/im-testenv.sh <id> env)"` before any Gradle run: the gate refuses the shared Gradle home. Never `gradle --stop` with another task's env (and a `--stop` with your own env aborts your running gate).
- **Session close (Gos, 18 Nov 2026, permanent policy):** before a session ends, and before any sandbox restart, the orchestrator (1) runs `scripts/save-agent-memory.sh`, which copies its memory notes into `agent-memory/` (the sandbox home is lost when the sandbox is recreated; restore in a new sandbox with `cp agent-memory/*.md <memory dir>/`), (2) writes a checkpoint in `status/LOG.md`, (3) removes the session scratch area `repos/.sandbox-disk/scratch/` and merged worktrees, (4) commits and pushes this repository. The hourly status loop also saves the memory notes, so at most an hour can be lost.
- Scratch space (Gos, 18 Nov 2026): the sandbox root disk is 20 GB and fills up. Large scratch goes under `repos/.sandbox-disk/scratch/<task-id>/` (the host mount, 590 GB), never under `/tmp`, `/home/agent` or a worktree, and is removed at session close. Worker briefs must say so.
- Research log (Gos, 18 Nov 2026): questions that need investigation before anyone can decide or build go in `docs/TO_INVESTIGATE.md` (numbered entries: question, why it matters, what is known, what a good answer contains; file a bead when someone starts; move to "Answered" when done). It is separate from beads (tasks) and from `docs/EXPERT_TO_CHECK.md` (changes already made that an expert should review).
- Statistics: `python3 -I scripts/statistics.py` writes `status/STATISTICS.md` (hourly jobs by model and commits; run by the hourly loop). In STATUS.md the beads and epic summaries come before the agent list (Gos, 18 Nov 2026).
- Dashboard: `python3 -I scripts/dashboard.py` writes `status/STATUS.md`, `status/index.html`, `status/artifact.html` and `status/sprint-dashboard-3.html` (the latter is the file published as the Claude artifact https://claude.ai/code/artifact/05b16eb4-91fb-45af-9601-1db800c8d9b5).
- Sprint report: `python3 -I scripts/sprint-report.py [--prices FILE] [--since DATE]` regenerates `status/sprint-report.md` (cost and delivery per model, from agent-runs.csv, session logs, beads and git).
- Transcript: `scripts/transcript.py` regenerates `../transcript.md` (i.e. `repos/transcript.md`, which is on the host mount and visible on the Mac; `../../transcript.md` is a symlink to it) from the session log.
- Sandbox layout warning: only `repos/` is the host mount (641 GB). `worktrees/`, `/home/agent` and `/var/lib/docker` are on the 20 GB sandbox root overlay; large scratch data goes under `repos/.sandbox-disk/`.
- Test mines (Gos): prefer the local rdfc2im demo mine, then public HumanMine (read-only); FlyMine only when a test is about Drosophila data or multi-mine switching.
- Dependency rules (Gos): remove weak dependencies rather than upgrade; vet any replacement package and log it in `decisions/package-vetting.md`; prefer task input/output wiring over explicit Gradle `dependsOn`.
- Hourly beads report (Gos, 15 Nov): `scripts/hourly-status.sh --loop` runs the dashboard, appends `status/beads-history.csv` and commits/pushes `status/` at the top of every hour; the orchestrator starts it once per sandbox session with `nohup scripts/hourly-status.sh --loop >/dev/null 2>&1 &` (check with `pgrep -f hourly-status.sh`; log in `/home/agent/taskhomes/_logs/hourly-status.log`). `scripts/beads-history.py backfill` reconstructs hourly rows from issue timestamps; `/home/agent/venvs/plots/bin/python -I scripts/plot-beads-history.py` draws `status/beads-history*.svg` in the Tufte style (`scripts/tufte-plots/`, Gos's skill).
