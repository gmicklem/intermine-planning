# InterMine + BlueGenes maintenance planning (2026)

Planning, status and decision records for the maintenance effort on
[InterMine](https://github.com/intermine/intermine) (Java back end) and
[BlueGenes](https://github.com/intermine/bluegenes) (ClojureScript front end),
executed largely by coding agents coordinated from a single orchestrator session.

| Directory | Contents |
|---|---|
| `plans/` | Human-readable plan. `00-overview.md` is the approved master plan; numbered files break it down per area. |
| `decisions/` | Decision records (ADRs) and the package-vetting log. |
| `baselines/` | Measured state of builds and tests before any change. |
| `inventory/` | Dependency, CVE and dependency-usage inventories. |
| `scripts/` | Gate scripts, worktree and test-environment helpers, dashboard and transcript generators. |
| `status/` | Generated: `STATUS.md`, `index.html`, `agent-runs.csv`, `LOG.md`. |
| `.beads/` | beads issue database (Dolt, embedded). Only the orchestrator writes to it. |

Work branches: `maint-2026` in each code repo under `gmicklem/*`; task branches `maint/<beads-id>-<slug>`.
