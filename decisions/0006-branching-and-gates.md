# 0006. Branching model, remotes and gate scripts

Status: Accepted, 2026-11-15, decided by Gos Micklem with Claude.

## Context

Facts from `plans/40-agent-execution.md`, `plans/00-overview.md` and the repo plans:

- Many agents work in parallel on `repos/intermine` (default branch `dev`) and `repos/bluegenes`
  (`dev`), plus the sibling libraries.
- Intermine CI today: `.github/workflows/im-build.yml`, push-only trigger, `ignoreFailures=true`, with
  pass/fail decided by `config/lib/parse_test_report.py`. BlueGenes CI is CircleCI only.
- Intermine tests need Postgres (10 fixed DB names) and `~/.intermine/` property files, so parallel runs
  need isolation (`scripts/im-testenv.sh <id>`).
- The sandbox has 15 GB RAM: at most 2 concurrent intermine test runs, or 1 intermine run plus 1
  BlueGenes advanced compile; the rdfc2im stack (9 GB peak) runs alone.
- The GitHub token authenticates as `gmicklem`; `workflow` scope is needed for `.github/workflows/*`.
- Upstream is `intermine/*`; Gos wants no pushes there.

## Decision

Strategy decisions 5 and 6:

- Per repo, a long-lived integration branch `maint-2026` is cut from `dev`.
- Each agent task works in its own git worktree on `maint/<beads-id>-<slug>`, branched from
  `maint-2026`, created with `scripts/worktree.sh`.
- The orchestrator merges a task branch only after the repo's gate script passes on the merged result,
  then pushes `maint-2026` at every checkpoint.
- All remotes are under `gmicklem/` (`gmicklem/intermine` as remote `fork`, `gmicklem/bluegenes`,
  `gmicklem/imcljs`, `gmicklem/im-tables-3`, `gmicklem/bluegenes-tool-store`, `gmicklem/humanmine` and
  `gmicklem/flymine` as needed, `gmicklem/intermine-planning`). Nothing is pushed to `intermine/*` or
  `intermineorg/*`. The orchestrator checks `gh api user` reports `gmicklem` before each remote operation.
- "Each commit tested": the worker runs the gate script before committing and the orchestrator re-runs
  it on the merge result. Gate scripts `scripts/gate-intermine.sh` and `scripts/gate-bluegenes.sh` are the
  single definition of done.
- Commit messages: `<area>: <summary> [bd-xxxx]`.
- Later, PRs `gmicklem:maint-2026 -> intermine:dev` per the contribution guide, squashed into reviewable
  chunks.

## Consequences

Positive:
- Isolated worktrees allow parallel agents without stepping on each other.
- A green, pushed `maint-2026` at every checkpoint; baselines in `baselines/` allow a no-regression rule.
- Upstream is protected until a deliberate PR.

Negative:
- Gate runs are heavy, so concurrency is capped by RAM.
- Squashing into reviewable chunks later loses per-task history in the upstream PRs.
- Merges are serialised through the orchestrator.

Follow-ups:
- Intermine gate: `./gradlew install` for upstream builds, `build` for touched builds, `checkstyleMain`,
  parsed by `config/lib/parse_test_report.py`. BlueGenes gate: `cljfmt check`, kaocha and the prod build;
  Cypress at merge time.
- Once workstream G lands, merges to intermine `maint-2026` also run `rdfc2im/tools/full-build.sh
  --intermine-src`, `make test-live` and `mine-tests`.

## Alternatives considered

- **Push directly to `intermine/*`.** Rejected by Gos: all GitHub work is under `gmicklem/*`.
- **Agents commit straight to `maint-2026`.** Rejected: merges happen only after the gate passes on the
  merged result, and workers do not touch `maint-2026` or remotes.
- **Rely on existing CI as the gate.** Rejected: CI is push-only with `ignoreFailures=true` and BlueGenes
  has only CircleCI; the planning-repo gate scripts are the definition of done.

## Review trigger

Revisit if the gate takes too long to run per task, if merge conflicts between task branches become
frequent, if upstream maintainers ask for a different PR structure, or when the PRs to `intermine:dev`
are prepared.
