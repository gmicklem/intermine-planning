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
- Worker prompts must say: write `rm` with absolute paths that match the allow rules in repos/.claude/settings.local.json (a relative path after `cd` hits a permission prompt nobody can answer and hangs the worker for ever; 78 min lost 15 Nov), and start long jobs with the Bash tool's run_in_background rather than `nohup ... &` plus sleep.
- Code work happens in git worktrees under `../../worktrees/<repo>/<beads-id>-<slug>` created with `scripts/worktree.sh`, on branches `maint/<beads-id>-<slug>` from `maint-2026`.
- Gate scripts: `scripts/gate-intermine.sh`, `scripts/gate-bluegenes.sh`; test isolation: `scripts/im-testenv.sh <task-id>`.
- Dashboard: `python3 -I scripts/dashboard.py` writes `status/STATUS.md`, `status/index.html`, `status/artifact.html` and `status/sprint-dashboard.html` (the latter is the file published as the Claude artifact https://claude.ai/code/artifact/cd45aac8-c4af-484d-99d6-58067cfdb478).
- Sprint report: `python3 -I scripts/sprint-report.py [--prices FILE] [--since DATE]` regenerates `status/sprint-report.md` (cost and delivery per model, from agent-runs.csv, session logs, beads and git).
- Transcript: `scripts/transcript.py` regenerates `../transcript.md` (i.e. `repos/transcript.md`, which is on the host mount and visible on the Mac; `../../transcript.md` is a symlink to it) from the session log.
- Sandbox layout warning: only `repos/` is the host mount (641 GB). `worktrees/`, `/home/agent` and `/var/lib/docker` are on the 20 GB sandbox root overlay; large scratch data goes under `repos/.sandbox-disk/`.
- Test mines (Gos): prefer the local rdfc2im demo mine, then public HumanMine (read-only); FlyMine only when a test is about Drosophila data or multi-mine switching.
- Dependency rules (Gos): remove weak dependencies rather than upgrade; vet any replacement package and log it in `decisions/package-vetting.md`; prefer task input/output wiring over explicit Gradle `dependsOn`.
- Hourly beads report (Gos, 15 Nov): `scripts/hourly-status.sh --loop` runs the dashboard, appends `status/beads-history.csv` and commits/pushes `status/` at the top of every hour; the orchestrator starts it once per sandbox session with `nohup scripts/hourly-status.sh --loop >/dev/null 2>&1 &` (check with `pgrep -f hourly-status.sh`; log in `/home/agent/taskhomes/_logs/hourly-status.log`). `scripts/beads-history.py backfill` reconstructs hourly rows from issue timestamps; `/home/agent/venvs/plots/bin/python -I scripts/plot-beads-history.py` draws `status/beads-history*.svg` in the Tufte style (`scripts/tufte-plots/`, Gos's skill).
