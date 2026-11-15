# 0005. Beads in embedded mode, with the orchestrator as the only writer

Status: Accepted, 2026-11-15, decided by Gos Micklem with Claude.

## Context

Facts from `plans/40-agent-execution.md` and `plans/00-overview.md`:

- `repos/beads` is a Dolt-backed issue tracker for agents. Install with `npm install -g @beads/bd` or
  `make build` from the checkout.
- Embedded mode (`bd init`) is single-writer, guarded by a file lock. Server mode (`bd init --server`)
  needs a `dolt sql-server`.
- Core loop: `bd create/ready/update --claim/close/dep add/show/list --json`, with `bd status` for
  stats. It has no web UI and no token tracking.
- `.beads/` is shared by all worktrees of a repo.
- Work is done by many parallel agents in separate git worktrees, with concurrency limited by the 15 GB
  sandbox.
- Installing the beads/dolt tooling was approved by Gos on 15 Nov 2026.

## Decision

Strategy decision 7: adopt beads, in **embedded mode**, with the **orchestrator as the only writer**.

- Workers receive the issue text in their prompt and return a structured result (what changed, gate
  result, follow-ups discovered). The orchestrator updates beads.
- Workers do not touch beads, `maint-2026` or remotes, and do not commit in the planning repo.
- Issues map to plan items. Mechanical batches (for example "convert build.gradle files in
  bio/sources, batch 2/4") are one issue each with a checklist, labelled `batch`.
- Switch to `bd init --server` only if multiple Claude Code sessions need to write concurrently.
- Because beads provides no dashboard or token tracking, `scripts/dashboard.py` and
  `status/agent-runs.csv` fill that gap.

## Consequences

Positive:
- Avoids the single-writer lock problem without running a Dolt server.
- Keeps the task graph consistent, with one source of truth.
- Workers stay simple and cannot corrupt tracker state.

Negative:
- The orchestrator is a bottleneck and single point of failure for task bookkeeping.
- Workers cannot create follow-up issues directly; they report them, and the orchestrator files them.
- Per-agent tokens and liveness must be computed from Claude Code session logs, not from beads.

Follow-ups:
- Orchestrator writes a 5-line summary to `status/LOG.md` at each checkpoint (every ~3 hours while
  unattended) and regenerates STATUS.md.
- `status/agent-runs.csv` records one row per agent run (beads id, model, start, end, tokens, outcome).

## Alternatives considered

- **Server mode (`bd init --server`) with concurrent worker writes.** Rejected for now: it needs a
  `dolt sql-server`, and the orchestrator-only approach avoids the lock problem without it.
- **Workers write to embedded beads directly.** Rejected: the single-writer file lock would be contended
  by parallel workers across worktrees that share `.beads/`.
- **No tracker (markdown TODO lists).** Rejected: the repo conventions require `bd` for task tracking,
  and the plan maps issues to epics and plan items.

## Review trigger

Revisit if multiple Claude Code sessions need to write concurrently, if orchestrator bookkeeping becomes
the limiting factor on throughput, or if embedded mode's lock causes failures in practice.
