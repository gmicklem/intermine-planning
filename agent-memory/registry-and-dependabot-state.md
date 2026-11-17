---
name: registry-and-dependabot-state
description: "17 Nov 2026 state of the registry rewrite, the reagent #676 thread, and Dependabot on the gmicklem forks (scans default branch only)"
metadata:
  node_type: memory
  type: project
  originSessionId: 0492e8a9-74f1-4807-9fab-46d9cc2516dd
  modified: 2026-11-17T16:08:16.668Z
---

**Registry (gmicklem/intermine-registry maint-2026, 683c4a6 on 17 Nov 2026):** Clojure rewrite is
feature-complete for now: per-logo tile shades, theme switch, logo overrides (PlanMine), /map,
TargetMine re-added as Unreachable (server under repair; icon = "golden hexagon" Gos saw somewhere on
mizuguchilab.org, not found yet; ask him for the URL), "test mines" wording. Demo: sandbox port 3300
(restart recipe in /home/agent/taskhomes/im-bg-serve/README.txt, admin token demo-refresh-3300).
Decision 0008 records Gos's six answers. docs/REGISTRY-DEPLOYMENT.md (1184 lines, VPS+Caddy
recommended) is drafted and NOT yet walked through with Gos; he asked for it after the reagent reply.

**Reagent #676:** reply with build-2 numbers and the variant posted 17 Nov
(issuecomment-6951981693). BlueGenes keeps its patch until a reagent *release* passes the
upload-after-report probe without it. Measurement recipe: reference/reagent-2.1.0-snapshot-build2-measurement.md.

**Dependabot:** alerts were disabled on every gmicklem fork; enabled 17 Nov via
`gh api -X PUT repos/gmicklem/<r>/vulnerability-alerts`. Alerts scan the DEFAULT branch (dev = old
code), so first counts (bluegenes 57, im-tables-3 23, registry 16, npm only) describe the old
lockfiles; Gradle repos show 0 (no lockfile). Gos agreed 17 Nov: every fork's default branch is now maint-2026 (rdfc2im stays main); revert with
`gh api -X PATCH repos/gmicklem/<r> -f default_branch=dev`. Side effect: bluegenes' nightly Cypress
schedule now fires by itself. Only bluegenes has dependabot.yml. Sprint profile: dependency/security beads
median 28 min (Sonnet). Gos wants a daily maintenance cron design (Actions gate on Dependabot PRs
first, scheduled agent second).

**Renovate (installed by Gos 17 Nov, 'Renovate Only', 'Scan and Alert', for ALL repos by mistake):**
Renovate skips forks under an all-repos install unless the repo's own renovate.json has
`forkProcessing: enabled`; pushed `{"extends": ["local>gmicklem/renovate-config"], "forkProcessing": "enabled"}`
to all eleven forks' maint-2026 on 17 Nov, and `{"enabled": false}` to intermine-planning, rdfc2im,
renovate-config. Preset: gmicklem/renovate-config (master copy renovate/default.json in planning).
Schedule is Monday before 06:00 UK, security bumps any time. Gos should deselect his other repos
(vMine, intermine-docker-template, maintenance_pages, gmicklem.github.io, bluegenes4sparql,
flymine-openapi-spec, bh24-using-discovered-schema) on the Configure page.

**CI failure emails:** Gos receives GitHub "Run failed" mails; all 16-17 Nov ones were known and
since fixed. Idea: scripts/ci-failures.sh in the hourly status to list non-green latest runs.

**Why:** these are the open threads when Gos paused on 17 Nov ~16:10 UTC.
**How to apply:** on "back", confirm the checkpoint push went through, redo the latest-run CI scan,
then raise the default-branch question before any Dependabot work. Related: [[intermine-maintenance-sprint]], [[gos-working-preferences]].
