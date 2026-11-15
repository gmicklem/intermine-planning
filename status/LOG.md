# Orchestrator checkpoint log

Newest first. One entry per checkpoint (about every 3 hours while unattended).

## 2026-11-15 02:05 UTC — checkpoint 0 (setup)
- Toolchain installed (JDK 8/11/17/21, Postgres 18 running with CI users, lein 2.11.2, bd 1.3.4). chromium from apt is a snap stub; headless browser still open.
- Repos: imcljs, im-tables-3, bluegenes-tool-store cloned; gmicklem/intermine fork created and added as remote `fork`; maint-2026 branches created in intermine and bluegenes.
- Planning repo created and pushed to gmicklem/intermine-planning; beads initialised with 9 epics / 40 tasks; dashboard, transcript and worktree scripts in place.
- Agents running: A3 intermine baseline (Opus), A4 bluegenes baseline (Sonnet), A6 intermine inventory (Sonnet), A7 bluegenes inventory (Sonnet).
- Blockers: none. Note: GitHub rejects commits with the gmail address (email privacy), so commits use the noreply address.

## 2026-11-15 04:35 UTC — checkpoint 1
- Baselines done: intermine 2279/2279 tests green on JDK 8 / Gradle 4.9 / Postgres 18 (gate ~8 min, 3 GB peak); bluegenes 27/27 kaocha tests, uberjar serves. Debian lein is broken (drops transitive deps); upstream lein installed under /home/agent/tools/lein.
- Inventories: intermine 79 coordinates, 21 vulnerable (153 advisories), 26 removal rows; bluegenes+siblings 38 removal candidates, 65 advisories. Design studies: decisions/gradle-upgrade-path.md, decisions/bluegenes-build-migration.md; ADRs 0001-0006.
- Merged to maint-2026 and pushed: tool-store (deps.edn, tests, 2 removals), imcljs (deps.edn/shadow/tools.build, 2 removals, 4 bumps), bluegenes (22 removals, npm audit 45->35), intermine C1/C2 (postgresql 42.7.14, HikariCP 4.0.3, jackson 2.18.12, org.json, everit 1.14.6, ant/math3 dedup; 85 advisories closed).
- Running: B1 Gradle 6.9.4 (Opus), C7 intermine weak-dep removals (Sonnet), E1 bluegenes shadow-cljs (Opus), im-tables-3 deps.edn (Sonnet).
- Pending: Postgres max_connections 100->400 needs a restart at a quiet moment; rdfc2im testbed baseline (A5) waits for memory; Cypress/Playwright need network approvals (download.cypress.io, playwright.download.prss.microsoft.com).
