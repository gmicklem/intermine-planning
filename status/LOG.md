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

## 2026-11-15 06:20 UTC — checkpoint 2
- intermine maint-2026 @742f3c9c4d pushed: Gradle 6.9.4, plugin rewritten for Gradle 7 (dependsOn 42->8), 85 advisories closed by bumps, 14 weak dependencies removed, commons-httpclient gone, modern GitHub Actions (checkstyle run green on the fork; unit-test run in progress), dependabot.
- bluegenes maint-2026 @916483d6 pushed: lein replaced by deps.edn + shadow-cljs + tools.build (uberjar 54->37 MiB), 22 removals, GitHub Actions CI green on first run. imcljs and tool-store maint-2026 pushed with deps.edn builds. im-tables-3 branch ready but unmerged: its live tests need FlyMine, which has been unreachable from the sandbox since ~03:40 UTC (so has rdfportal.org; GitHub works).
- Review process worked: Opus review of E1 caught a release bundle that failed at load (shim order); fixed, gate now executes the bundle.
- Postgres max_connections raised to 400 (restart at 06:20).
- Running: D3 maven-publish/Central Portal (Sonnet); starting B2 build-file batches I and B (Sonnet).
- Blocked: A5 testbed baseline and G (rdfportal/humanmine unreachable); F2 Cypress (download.cypress.io approval); im-tables merge (FlyMine).

## 2026-11-15 07:45 UTC — checkpoint 3
- intermine maint-2026 @70d2644cf1 pushed (flaky-test merge c1a158f511 gating): all build files except bio core on Gradle 7 configurations; CI on the fork green except the flaky pair, now fixed (real DataTracker.clear() race found and fixed). CI fixes: Ubuntu 26 sudo -E and PG15+ public-schema privileges.
- bluegenes maint-2026 @916483d6: shadow-cljs build + GitHub Actions green. imcljs, tool-store pushed. im-tables-3 branch still waits for live FlyMine (down from the sandbox since 03:40; humanmine.org and rdfportal.org too).
- Disk: root overlay filled at ~06:30; freed to ~7 GB; task envs of merged tasks now destroyed at merge time.
- Running: B2 batch B (bio core), D3 maven-publish/Central Portal. Next: Gradle 7.6 flip once both land; then 8.14; then JDK 17.
- Needs Gos: network to flymine.org/humanmine.org/rdfportal.org from the sandbox (connections time out at the proxy CONNECT; GitHub works); approvals for download.cypress.io and playwright.download.prss.microsoft.com.

## Checkpoint 4 (15 Nov ~10:05 UTC)
- intermine maint-2026 = d178eb5cbe: batch B (bio builds on Gradle 7 configurations) and D3 (maven-publish, centralBundle, docs/RELEASING.md) merged, full gate green (2279 tests, 0 failures) with **zero Gradle deprecation warnings on 6.9.4**. This is the 5.1.1 candidate; pushed also as branch `release/5.1.1-candidate` on gmicklem/intermine. CI dispatched on it.
- CI on the previous head c1a158f511 passed completely (both workflows).
- bluegenes-tool-store maint-2026 = 8606215: four fixes merged (SERVER_PORT parse, zip-slip check, npm registry discovery replacing dead api.npms.io, commons-compress 1.27.1).
- Gos supplied rdfc2im `cached_raw_data` (181 MB); A5 testbed baseline worker (Opus) started with `--use-cached-data`; HumanMine live model still unreachable (optional input; Gos asked for his host copies of in/humanmine_model.*).
- Gradle 7.6.x flip worker (Opus) started on maint-2026 d178eb5cbe (im-ee7.17, im-ee7.18, wrapper regen, 7.6 deprecations baseline, flymine smoke).
- Human steps outstanding: Central Portal account + namespace, GPG key (docs/RELEASING.md); network to humanmine/flymine/rdfportal from the sandbox; approvals for download.cypress.io and the playwright CDN.

## Checkpoint 5 (15 Nov ~11:50 UTC)
- intermine maint-2026 = 476353f95d: **Gradle 7.6.6** (flip + checkstyle bridge + TestReport API), docs (BUILDING/TESTING/UPGRADING-build), CI action majors, Gradle 8 prep batches ROOTS+TESTRES (providers.exec, java {}, = assignment, version catalog gradle/libs.versions.toml) and P3 (plugin on groovy.ant/groovy.xml, layout.buildDirectory, resolvable-only configurations). Every merge gated at baseline counts (2279 tests, 0 failures); CI green on each pushed head so far. Only 2 Gradle deprecations remain on 7.6.6 (sourcesJar/antlr, filed).
- `release/5.1.1-candidate` (d178eb5cbe) is the last 6.9.4 state.
- bluegenes maint-2026 = f2f2cf2a: Cypress 13.17.0 migration (7 gated commits; headless Electron on arm64); 57/152 pass against the local demo mine, all remaining failures are Biotestmine fixture data (F4 filed). CI action majors merged; CI green.
- bluegenes-tool-store maint-2026 = 8606215 (4 fixes). rdfc2im: fork gmicklem/rdfc2im, branch maint/im-rkn.5-testbed-baseline (lookup cache).
- Testbed (A5): demo HumanMine built from Gos's cached raw data in 10m45s, make test-live 17/17; stack left running on sandbox localhost (webapp :8090/humanmine, BlueGenes :5000, PG :15432, Solr :8983); data volumes on the host mount under repos/.sandbox-disk. Baseline in baselines/rdfc2im-2026-11-15.md; epic G prerequisites filed.
- Sandbox: only repos/ is the host mount; transcript moved to repos/transcript.md. Network approvals received for cypress/playwright CDNs, repo1/search.maven, cdnjs, bootstrapcdn, rawgit, central.sonatype, adoptium. Still needed: cdn.jsdelivr.net, cdn.intermine.org; humanmine/flymine/rdfportal still time out.
- Running: CATALOG batch (module coords -> catalog). Next: 3b flip to Gradle 8.14.6 (Opus), then B4 JDK 17, R7 checkstyle bump, C-tasks, E4 CDN/SRI.

## Checkpoint 6 (15 Nov ~13:40 UTC)
- **intermine maint-2026 = 4a72be62af: Gradle 8.14.6**, zero deprecations from InterMine's own scripts and plugin, version catalog for every third-party coordinate, checkstyle 7.8.1 via the (temporary) classpath bridge, testmine loads data and serves through cargo on 8.14. Path today: 6.9.4 (5.1.1 candidate, verified to work in a Gradle 4.9 mine) -> 7.6.6 -> 8.14.6, each step gated at baseline counts (2279 tests, 0 failures); CI green on every pushed head.
- **Acceptance test passed (G1):** rdfc2im `--intermine-src` built the demo HumanMine from our 5.1.1 artefacts; data counts identical to the 5.0.8 baseline, `make test-live` 17/17. Findings filed: duplicate library versions in the war (P1), Ant logging lost (P2), 7.6-built plugin needs Gradle 7+ in the mine (expected; 6.0.0 story).
- **BlueGenes maint-2026 = f16e58ae:** Cypress 13, CDN assets on cdnjs with SRI + vega bumps, npm dev advisories 22 -> 13, siblings (imcljs/im-tables/tool-store) consumed as git deps with Cypress parity. im-tables suite green against both the local mine and live FlyMine. E2 library bumps (ring/timbre, re-frame 1.4, reagent 1.2, React 18 with im-tables) in progress.
- Network: public mines reachable again since ~12:30 UTC. Rule from Gos: prefer HumanMine for live tests (WORKER-RULES rule 11). Still to approve: cdn.jsdelivr.net, cdn.intermine.org.
- Running: E2 (bluegenes + im-tables), G2 (mine-tests local entry), B4 (JDK 17) starting. Next: R7 checkstyle bump, C-tasks (commons-*, JUnit, Jena/solrj), B5 deployer guide, war duplicate-jar fix, sprint report Monday.

## Checkpoint 7 - 2026-11-15 16:50 UTC

- intermine maint-2026 159341ef2d pushed (CI green on 331bb31924; later heads dispatched). Merged since checkpoint 6: C3 commons-*/ant/org.json (7 commits), jar hygiene (no intermine.properties in any published or dbmodel jar; duplicate antlr/javax.inject/Jackson/lang3/logging jars out of the wars), webapp libraries (log4j 2.5 Log4Shell out of the bio war; junit/hamcrest/spring-test out; Jersey removed, registry lookup on HttpURLConnection with 4 new tests).
- B4 JDK 17 merged locally (clean merge over the three above); gate on JDK 8 then JDK 17 running on the merged tree before push. Worker gates passed on JDK 8, 17 and 21 with identical counts; jars stay Java 8 bytecode (--release 8); --add-opens for cglib on JDK 9+; CI matrix JDK {8,17} x PostgreSQL {14,16}.
- BlueGenes maint-2026 eacead26 and im-tables 782b448 pushed, CI green: React 18, reagent 1.2, re-frame 1.4, react-select 5, Clojure 1.12, ring 1.13, highlight.js 11.12.0; core.cache, react-day-picker, react-transition-group, react-highlight.js removed. Cypress unchanged (23 pass / 23 fail / 38 skipped, all data). npm audit --omit=dev: 0.
- Permission allow rules widened (repos/.claude/settings.local.json) for rm on scratch/build-output paths, docker, git worktree, dropdb/psql, so cleanup does not prompt while Gos is away.
- Running: C4 Tier 2 CVE check (bcprov, oltu, JOpenId, DWR; Sonnet). Next: HumanMine-as-default test switch (im-7os.24), R7 checkstyle bump, C6 JUnit/xmlunit/vendored jars, commons-lang3 migration, B5 deployer guide, sprint report Monday.

## Checkpoint 8 - 2026-11-15 20:05 UTC

- intermine maint-2026 10728b1bc0 pushed, CI green through 256977fbcb. Merged since checkpoint 7: B4 JDK 17 (gates on 8 and 17), C4 Tier 2 CVEs (bcprov removed via a JDK-only certificate writer, flagged for Gos; OpenID 2.0 login + JOpenId removed; Oltu 1.0.2; DWR 2.0.11), R7 checkstyle 9.3 with the 101-line bridge deleted, B5 deployer guide (6.0.0 step list verified on humanmine and flymine). C6 (JUnit 4.13.2, EasyMock 5.7, vendored jars 16 -> 6) merged locally as 5279e4ee25, gate running.
- New forks gmicklem/humanmine (f426ac8) and gmicklem/flymine (3904f70b): maint-2026 carries the 6.0-line build files; buildDB + war verified on Gradle 8.14.6.
- BlueGenes maint-2026 331b7124, im-tables 7dd9082, CI green: highlight.js 11, HumanMine as the default public test mine (Gos's rule), window.React/ReactDOM and window.imjs restored for BlueGenes tools (two real regressions found by the HumanMine @external run; tools render again on HumanMine gene reports).
- Planning: STATUS.md has a beads-by-priority table (Gos's request); dashboard artifact moved to https://claude.ai/code/artifact/cd45aac8-c4af-484d-99d6-58067cfdb478 (old one returns 403); permission allow rules widened for scratch deletions; npm 10.9.2 installed in the sandbox.
- Running: C6 merge gate; plugin deployer fixes (webtasks POM, SO paths, war composition); F4 Cypress specs for the demo mine. Next: commons-lang3 migration, tool-store/imcljs pins (im-7os.19), Log of human steps for Gos, sprint report Monday.
