# Agent execution model and sprint schedule

This document describes how the InterMine + BlueGenes maintenance work is executed by many coding agents in parallel: the branching scheme, the gate scripts that define "done", how beads (Dolt-backed issue tracker) is used, which models do which work, the concurrency limits imposed by a 15 GB sandbox, the orchestrator/worker/reviewer roles, the checkpoint routine, the sprint schedule, and the dashboard and transcript that let Gos follow progress. It ends with the decisions Gos has confirmed. The sprint runs for the ~46 hours before 23:00 UK Mon 16 Nov 2026, and its measurements (tokens, time, outcomes per model) inform the Claude subscription renewal on 17 Nov.

Related: [00-overview.md](00-overview.md) (master plan), [10-intermine-backend.md](10-intermine-backend.md), [20-bluegenes.md](20-bluegenes.md), [30-testbed.md](30-testbed.md).

## Context: beads

`repos/beads` is a Dolt-backed issue tracker for agents. Install with `npm install -g @beads/bd` or `make build` from the checkout. Embedded mode (`bd init`) is single-writer (file lock); server mode (`bd init --server`) needs a `dolt sql-server`. The core loop is `bd create/ready/update --claim/close/dep add/show/list --json`, with `bd status` for stats. It has no web UI and no token tracking. `.beads/` is shared by all worktrees of a repo.

## Execution decisions

5. **Branching.** Per repo there is a long-lived integration branch `maint-2026` cut from `dev`. Each agent task works in its own git worktree on `maint/<beads-id>-<slug>` branched from `maint-2026`. The orchestrator merges a task branch only after the repo's gate script passes on the merged result, then pushes `maint-2026` to the remote at every checkpoint.
   - **All remotes are under `gmicklem/`** (Gos's decision): `gmicklem/intermine` (a fork of intermine/intermine, created with `gh repo fork --clone=false` if absent and added as remote `fork`), `gmicklem/bluegenes` (existing), `gmicklem/imcljs`, `gmicklem/im-tables-3`, `gmicklem/bluegenes-tool-store`, `gmicklem/humanmine` and `gmicklem/flymine` as needed, and the planning repo `gmicklem/intermine-planning`.
   - Nothing is pushed to intermine/* or intermineorg/*.
   - Final step, later: PRs `gmicklem:maint-2026 -> intermine:dev` following the contribution guide, squashed into reviewable chunks.
6. **"Each commit tested"** means the worker must run the gate script before committing, and the orchestrator re-runs it on the merge result. The gate scripts live in the planning repo (`scripts/gate-intermine.sh`, `scripts/gate-bluegenes.sh`) and are the single definition of done for a commit.
7. **Beads: adopt it, embedded mode, orchestrator is the only writer.** Workers receive the issue text in their prompt and return a structured result; the orchestrator updates beads. This avoids the single-writer lock problem without running a Dolt server, and keeps the task graph consistent. Switch to `bd init --server` only if multiple Claude Code sessions need to write concurrently. Issues map to plan items; mechanical batches (for example "convert build.gradle files in bio/sources, batch 2/4") are one issue each with a checklist, labelled `batch`.
8. **Models.** Fable (the orchestrating session) orchestrates, writes plans and reviews merges. Opus is for judgement-heavy work: the Gradle plugin port, the shadow-cljs migration, diagnosing test failures with unclear causes, and code review before merge. Sonnet is for mechanical work with a clear gate: build-file conversions, dependency bumps, CI YAML, docs, and test fixes with a clear failing message. The model is set per agent via the Agent tool's `model` parameter (or per `agent()` call in a Workflow script).
9. **Concurrency limits (15 GB RAM).** At most 2 concurrent intermine test runs (each Gradle `-Xmx4g` plus forked tests), or 1 intermine run plus 1 BlueGenes advanced compile; the rdfc2im stack (9 GB peak) runs alone. Light tasks (docs, YAML, inventories, reviews) are unlimited. For per-task Postgres isolation, each worktree gets its own `HOME` with `~/.intermine/*.properties` pointing at DB names suffixed by the task id, created by `scripts/im-testenv.sh <id>`. The `~/.gradle` and `~/.m2` caches are shared.

## Execution model in practice

- **Orchestrator**: the Fable session. It owns beads, merges, pushes, the dashboard, the transcript and the plan docs. It never runs long builds itself; it delegates.
- **Workers**: Agent tool subagents (`model: sonnet|opus`) for single tasks. Each is given the beads issue text, the worktree path, the gate command, the commit-message convention (`<area>: <summary> [bd-xxxx]`), and the instruction to return a short structured report (what changed, gate result, follow-ups discovered). For fan-out batches (for example build-file conversion across 90 files) a Workflow script runs the batch with a verify step. Workers do not touch beads, `maint-2026` or remotes.
- **Reviewer**: an Opus agent reviews each task branch diff against the issue before merge, for anything beyond a mechanical bump.
- **Checkpoints** every ~3 hours while unattended: merge green branches, push, regenerate STATUS.md and the transcript, republish the artifact, and write a 5-line summary into `status/LOG.md`.
- **What Gos sees**: `status/STATUS.md` on GitHub, the artifact dashboard, and `/tasks` in Claude Code when online. Token totals per model and per task type feed the renewal decision in `status/sprint-report.md` on Monday.

## Sprint schedule (48 hours, UK time)

- **Sat 00:30-01:30 (Gos online)**: approve the plan; Gos runs the host commands; the orchestrator sets up the toolchain, planning repo and beads, and baselines kick off.
- **Sat 01:30-10:30 (Gos offline)**: Epic A entirely (baselines, inventories, testbed build), the B1 (Gradle 6.9.4) spike and batches, the E1 spike (shadow-cljs build of current code), and the dependency inventory. Checkpoints at ~04:30, ~07:30 and ~10:30 with a pushed STATUS.md.
- **Sat 10:30-23:00**: review with Gos; land B1, start B2 (Gradle 7.6) in batches; Tier 1 dependency bumps that are independent of the Gradle version; BlueGenes E1/E2; CI workflows (D).
- **Sun**: B2/B3 (Gradle 8), B4 (JDK 17), the remaining C, F (Cypress migration), and G (testbed consuming local artefacts).
- **Mon until 23:00**: stabilise; full gates on `maint-2026` for both repos; the deployer migration guide (B5); and `status/sprint-report.md` with a per-model token/time/outcome table and recommendations for next month.

Realism note: B1-B3 together are the critical path and the largest single risk. If B2 proves slow, the fallback that still helps deployers is Gradle 6.9.4 plus Tier 1 dependency bumps plus modern CI, shipped as 5.1.1, with Gradle 8 / JDK 17 as 6.0 (see [10-intermine-backend.md](10-intermine-backend.md)).

## Workstream I. Planning repo, beads, dashboard

- **Planning repo**: `repos/intermine-planning` (GitHub: `gmicklem/intermine-planning`). Layout: `README.md`, `plans/00-overview.md`, `plans/10-intermine-backend.md`, `plans/20-bluegenes.md`, `plans/30-testbed.md`, `plans/40-agent-execution.md`, `decisions/`, `baselines/`, `inventory/`, `scripts/` (gate scripts, `im-testenv.sh`, `worktree.sh`, `dashboard.py`, `transcript.py`), `status/STATUS.md` (generated), `status/agent-runs.csv` (one row per agent run: beads id, model, start, end, tokens in/out/cache, outcome), and `.beads/`.
- **Dashboard**: `scripts/dashboard.py` reads `bd list --json` and `bd status --json`, `git worktree list` plus last commit times, and the Claude Code session logs (`~/.claude/projects/<proj>/*.jsonl` and the scratchpad `tasks/*.output`, which carry per-message `usage`) to compute per-agent tokens and liveness (stalled = no log write for 10 minutes). It writes `status/STATUS.md` (committed and pushed, readable from a phone on GitHub) and `status/index.html`; the orchestrator also republishes it as a Claude artifact at each checkpoint. Beads does not provide this on its own.
- **Transcript**: `scripts/transcript.py` converts the orchestrating session's JSONL (`/home/agent/.claude/projects/-Users-gos-claude-projects-update-intermine-planning-repos/0492e8a9-74f1-4807-9fab-46d9cc2516dd.jsonl`) to `/Users/gos/claude_projects/update_intermine_planning/transcript.md` (user and assistant text, tool calls summarised one line each). It is regenerated at every checkpoint.

## Sprint-level verification

- Every task and every merge is gated as described in the decisions above (decision 6) and in the repo documents ([10-intermine-backend.md](10-intermine-backend.md), [20-bluegenes.md](20-bluegenes.md)).
- End of sprint: `maint-2026` of both repos is pushed, CI is green on GitHub Actions for the integration branch, `status/STATUS.md` and `status/sprint-report.md` are committed, and `transcript.md` is current.

## Decisions confirmed by Gos (15 Nov 2026)

- All GitHub work under `gmicklem/*`; planning repo `gmicklem/intermine-planning`; non-default branches pushed to `gmicklem/intermine`.
- Cloning the BlueGenes sibling repos and installing the beads/dolt tooling: approved.
- Public HumanMine/FlyMine read-only for tests: approved.
- Breaking changes for deployers are acceptable once Tier 1 security plus Gradle 6.9.4 is landable as a non-breaking 5.1.1.
- Dependency hygiene rules in 5b (weak-dependency removal, replacement vetting log, reduced explicit `dependsOn`); see [10-intermine-backend.md](10-intermine-backend.md).
