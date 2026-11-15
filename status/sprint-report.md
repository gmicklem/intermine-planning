# Sprint report

Generated 2026-11-15 11:38 by `scripts/sprint-report.py` (since 2026-11-14). Regenerate with `python3 -I scripts/sprint-report.py`. All times UTC.

## 1. Headline

Sprint window (first to last timestamp in agent-runs.csv and the orchestrator log): 2026-11-14 22:38:30 UTC to 2026-11-15 11:38:26 UTC, elapsed 12:59:56.

Total agent runs recorded: 41 (3 of them resumptions of an earlier agent, charged only for the tokens added since its previous row).

| Model | Runs | Success | Failed | Partial | Other | Input tok | Cache read tok | Cache write tok | Output tok | Wall-clock agent time | Median run |
|---|---|---|---|---|---|---|---|---|---|---|---|
| opus | 17 | 17 | 0 | 0 | 0 | 2,684 | 231,770,135 | 8,183,644 | 1,154,354 | 10:21:56 | 0:35:01 |
| sonnet | 24 | 24 | 0 | 0 | 0 | 2,508 | 158,895,405 | 8,166,327 | 1,117,185 | 19:18:39 | 0:23:58 |
| **all workers** | 41 | 41 | 0 | 0 | 0 | 5,192 | 390,665,540 | 16,349,971 | 2,271,539 | 29:40:35 | 0:28:31 |
| orchestrator (fable) | n/a (320 msgs) | - | - | - | - | 7,850 | 81,239,941 | 735,842 | 309,299 | - | - |

Success = outcome `done`/`success`; failed = outcome starting `fail`/`error`/`abort`/`blocked`; partial = starting `partial`; other = anything else. Wall-clock agent time is the sum of ended minus started per run; agents ran in parallel, so it exceeds elapsed time. The orchestrator is the main Claude Code session (not in agent-runs.csv); its totals come from the session JSONL (1 file(s), de-duplicated per API message id) and cover its whole context re-reads, so cache read is large by nature.

Cross-check (agent-runs.csv / all subagent logs on disk, 39 logs parsed): differences are agents not yet recorded or still running.

| Model | Input | Cache read | Cache write | Output |
|---|---|---|---|---|
| opus | 2,684 / 2,684 | 231,770,135 / 231,770,135 | 8,183,644 / 8,183,644 | 1,154,354 / 1,154,354 |
| sonnet | 2,508 / 2,616 | 158,895,405 / 164,182,467 | 8,166,327 / 8,456,120 | 1,117,185 / 1,157,671 |

## 2. Delivered

### Commits on maint-2026 since 2026-11-14

| Repo | Ref | Commits | Merge commits |
|---|---|---|---|
| intermine-planning | HEAD | 35 | 0 |
| intermine | maint-2026 | 71 | 15 |
| bluegenes | maint-2026 | 52 | 0 |
| imcljs | maint-2026 | 8 | 0 |
| bluegenes-tool-store | maint-2026 | 8 | 0 |
| im-tables-3 | maint-2026 | 0 | 0 |

**intermine merge commits**

- `476353f95d Merge maint/im-ee7.3-plugin-gradle8: plugin on groovy.ant/groovy.xml, layout.buildDirectory, = assignment, resolvable-only configurations [im-ee7.3]`
- `7e9227efaa merge: maint-2026 (ROOTS+TESTRES batch) into the plugin branch [im-ee7.3]`
- `7cdc8efb9e Merge maint/im-ee7.3-roots-testres: providers.exec, java {} block, = assignment, version catalog [im-ee7.3]`
- `11f73cb204 Merge maint/im-ee7.2-gradle-76-flip: Gradle 7.6.6 wrapper, checkstyle classpath on Gradle 7, TestReport 7.4+ API [im-ee7.2][im-ee7.17][im-ee7.18]`
- `a794507af1 Merge maint/im-bdy.3-docs: BUILDING, TESTING, UPGRADING-build docs; README fixes [im-bdy.3]`
- `567bb18dd7 Merge maint/im-89g.5-ci-actions: GitHub Actions current majors [im-89g.5]`
- `d178eb5cbe Merge maint/im-89g.3-maven-publish: maven-publish, centralBundle, RELEASING.md [im-89g.3]`
- `0d1016ae71 Merge maint/im-ee7.2-batch-bio: bio builds on Gradle 7 configurations [im-ee7.2]`
- `ccad4270c8 Merge branch 'maint-2026' into maint/im-ee7.2-batch-bio`
- `c1a158f511 Merge maint/im-jqz.8-flaky-tests: deterministic testBatchesCache; DataTracker.clear() thread-safe [im-jqz.8][im-ee7.9]`
- `70d2644cf1 Merge maint/im-ee7.2-batch-sources: bio/sources and testmine build files on Gradle 7 configurations [im-ee7.2]`
- `3774b2af7a Merge maint/im-ee7.2-batch-intermine: intermine/** build files on Gradle 7 configurations [im-ee7.2]`
- `742f3c9c4d Merge maint/im-jqz.7-weak-deps: remove 14 weak dependency declarations, dead HttpClient, commons-httpclient [im-jqz.7]`
- `42e105197e Merge maint/im-ee7.2-plugin-gradle7: plugin lazy tasks, no init tasks, input wiring [im-ee7.2]`
- `31d15fa725 Merge maint/im-ee7.1-gradle-6: Gradle 6.9.4 across all builds [im-ee7.1]`

**intermine unmerged maint/* branches ahead of maint-2026**

- `maint/im-ee7.3-catalog-modules`: 1 commit(s), tip `326c0be420 build(intermine): third-party coordinates of the intermine modules move to the version catalog [im-ee7.3]`

**im-tables-3 unmerged maint/* branches ahead of maint-2026**

- `maint/im-7os.3-im-tables-deps-edn`: 9 commit(s), tip `f9aa27b docs: README section for the deps.edn / shadow-cljs build commands [im-7os.3]`

### Beads

`bd status`: total 111, open 68, in progress 5, blocked 4, ready 64, closed 38.

| Epic | Title | Epic status | Children | Open | In progress | Closed |
|---|---|---|---|---|---|---|
| im-28e | Epic F: BlueGenes tests and CI | open | 7 | 4 | 1 | 2 |
| im-7os | Epic E: BlueGenes toolchain modernisation | open | 12 | 5 | 1 | 6 |
| im-89g | Epic D: intermine CI and release pipeline | open | 9 | 4 | 0 | 5 |
| im-8dd | Epic I: Planning repo, beads, dashboard | open | 5 | 0 | 2 | 3 |
| im-bdy | Epic H: Docs and governance | open | 3 | 2 | 0 | 1 |
| im-ee7 | Epic B: intermine build toolchain (Gradle 4.9 -> 8.x, JDK 17) | open | 32 | 21 | 1 | 10 |
| im-jqz | Epic C: intermine Tier 1 dependency upgrades and removals | open | 18 | 14 | 0 | 4 |
| im-ore | Epic G: Whole-system testbed | open | 6 | 6 | 0 | 0 |
| im-rkn | Epic A: Environment and baseline | open | 10 | 3 | 0 | 7 |

#### Closed issues by epic

**im-28e Epic F: BlueGenes tests and CI**

- `im-28e.2` F2 Cypress 13+ migration targeting the rdfc2im mine
- `im-28e.4` bluegenes gate: smoke must execute the JS bundle, not just HTTP 200 (lesson from E1 review)

**im-7os Epic E: BlueGenes toolchain modernisation**

- `im-7os.1` E1 shadow-cljs + deps.edn build reproducing dev/prod/kaocha; Node 22; lessc current
- `im-7os.5` E5 npm security: ws, wait-on, xmlhttprequest; npm audit clean
- `im-7os.6` commons-compress 1.19 -> 1.27.1 in tool-store/bluegenes (needs commons-io 2.16.1 + commons-codec 1.17.1 pins under lein)
- `im-7os.7` tool-store: replace dead api.npms.io discovery with registry.npmjs.org search (:objects, size=250), fail loudly
- `im-7os.8` tool-store: sanitise ../ in tar entry names (zip-slip) in package.clj
- `im-7os.9` tool-store: SERVER_PORT env var parsed as Long -> Integer/parseInt ClassCastException in core.clj:43

**im-89g Epic D: intermine CI and release pipeline**

- `im-89g.1` D1 GitHub Actions: pull_request trigger, setup-java@v4 matrix, Gradle cache
- `im-89g.2` D2 .github/dependabot.yml (gradle, github-actions)
- `im-89g.3` D3 maven-publish + Central Portal publishing; docs/RELEASING.md
- `im-89g.4` D4 PR template, CONTRIBUTING.md, README badges
- `im-89g.5` ci (both repos): bump actions/setup-java to v5 and checkout/setup-node/cache to current majors (Node 24 runtime); or let dependabot do it

**im-8dd Epic I: Planning repo, beads, dashboard**

- `im-8dd.1` I1 Planning repo skeleton, beads init, worktree scripts
- `im-8dd.3` I3 Transcript generator and transcript.md
- `im-8dd.4` I4 Per-area plan docs 10/20/30/40

**im-bdy Epic H: Docs and governance**

- `im-bdy.2` H2 Decision records: gradle-upgrade-vs-switch, jdk-target, struts-stance, bluegenes-build-tool, beads-usage, branching

**im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> 8.x, JDK 17)**

- `im-ee7.1` B1 Gradle 4.9 -> 6.9.4 across all seven builds and plugin; tests green on JDK 8
- `im-ee7.11` gate-intermine.sh header still says default Gradle 4.9; update
- `im-ee7.15` plugin: unwarBioWebApp + addStrutsConfig -> Sync task when the plugin composes the war (P3)
- `im-ee7.16` build files: compileTestJava.dependsOn -> test.dependsOn in bio/core, bio/model, bio/postprocess*; drop redundant mergeModels.inputs.files(processResources) in bio/model
- `im-ee7.17` B2 flip: checkstyle 7.8.1 fails on Gradle 7.x (JavadocMethod 'Unable to get class information for @throws' x7 in intermine-api; 8.45 rejects allowUndeclaredRTE): suppress, fix tags, or bump checkstyle + config
- `im-ee7.18` B2 flip: root testReport task destinationDir->destinationDirectory and reportOn->testResults (7.x-only APIs)
- `im-ee7.2` B2 Gradle 7.6.4: compile->implementation/api, maven->maven-publish, plugin getByName(compile) rework
- `im-ee7.22` plugin: fold copyMineProperties into processResources (needs DBModelUtils.mineProperties() change)
- `im-ee7.7` intermine: regenerate the seven gradlew scripts and wrapper jars for 6.9.4 (S1-wrap)
- `im-ee7.9` intermine: flaky IntegrationWriterDataTrackingImplTest (setUp IllegalArgumentException cascades to 17 failures) under concurrent gates

**im-jqz Epic C: intermine Tier 1 dependency upgrades and removals**

- `im-jqz.1` C1 Postgres JDBC 42.7.x + HikariCP
- `im-jqz.2` C2 Jackson 2.17+, org.json, everit json-schema
- `im-jqz.7` C7 Weak-dependency removals from the usage census
- `im-jqz.8` intermine: flaky testBatchesCache in FlatMode/WithNotXml ObjectStoreInterMineImplTest (test-order dependent result cache)

**im-rkn Epic A: Environment and baseline**

- `im-rkn.1` Install toolchain in sandbox (JDK 8/11/17/21, Postgres 18, lein, chromium, bd)
- `im-rkn.2` Clone sibling repos imcljs, im-tables-3, bluegenes-tool-store
- `im-rkn.3` Baseline: intermine build and tests on JDK 8 / Gradle 4.9 / Postgres 18
- `im-rkn.4` Baseline: bluegenes cljfmt, kaocha (chromium), prod uberjar
- `im-rkn.5` Baseline: rdfc2im full-build + make test-live + mine-tests against local stack
- `im-rkn.6` Inventory: intermine dependencies, CVEs and usage census
- `im-rkn.7` Inventory: bluegenes + sibling libs dependencies, advisories and usage census

## 3. Cost per outcome

Mean tokens per run, by model and outcome class:

| Model | Outcome class | Runs | Mean input | Mean cache read | Mean cache write | Mean output |
|---|---|---|---|---|---|---|
| opus | success | 17 | 158 | 13,633,537 | 481,391 | 67,903 |
| opus | failed | 0 | - | - | - | - |
| sonnet | success | 24 | 104 | 6,620,642 | 340,264 | 46,549 |
| sonnet | failed | 0 | - | - | - | - |

Five most expensive runs, ranked by output tokens, then cache write tokens (no prices supplied):

| Run | Bead | Model | Output tok | Cache write tok | Outcome |
|---|---|---|---|---|---|
| E1 bluegenes shadow-cljs migration | im-7os.1 | opus | 177,729 | 755,011 | done |
| B2 batch P plugin rewrite | im-ee7.2 | opus | 151,358 | 653,034 | done |
| intermine dependency census and CVE inventory | im-rkn.6 | sonnet | 133,496 | 316,367 | done |
| Gradle upgrade path design (read-only) | im-ee7 | opus | 132,117 | 312,803 | done |
| bluegenes dependency census and inventory | im-rkn.7 | sonnet | 113,653 | 253,319 | done |

## 4. Model usage pattern

**opus** (17 runs)

- Survey intermine build/test state (`im-rkn`)
- Survey bluegenes build/test state (`im-rkn`)
- Survey rdfc2im/docker_template/mine-tests/beads (`im-rkn`)
- A3 intermine baseline (`im-rkn.3`)
- Gradle upgrade path design (read-only) (`im-ee7`)
- shadow-cljs migration design (read-only) (`im-7os.1`)
- B1 Gradle 4.9->6.9.4 (`im-ee7.1`)
- E1 bluegenes shadow-cljs migration (`im-7os.1`)
- E1 review fixes (`im-7os.1`)
- B2 batch P plugin rewrite (`im-ee7.2`)
- E1 pre-merge review (`im-7os.1`)
- Fix flaky testBatchesCache + DataTracker.clear race (`im-jqz.8`)
- A5 rdfc2im testbed baseline (cached data) (`im-rkn.5`)
- B2 flip: Gradle 7.6.6 + checkstyle classpath + TestReport API (`im-ee7.2`)
- F2 Cypress 13 migration (`im-28e.2`)
- B3 P3: plugin ready for Gradle 8/Groovy 4 (`im-ee7.3`)
- B3 ROOTS+TESTRES: providers.exec, java{}, = assignment, version catalog (`im-ee7.3`)

**sonnet** (24 runs)

- intermine dependency census and CVE inventory (`im-rkn.6`)
- bluegenes dependency census and inventory (`im-rkn.7`)
- Write dashboard generator (`im-8dd.2`)
- Split plan into per-area docs (`im-8dd.4`)
- A4 bluegenes baseline (`im-rkn.4`)
- Decision records 0001-0006 (`im-bdy.2`)
- bluegenes weak-dependency removals (`im-7os.5`)
- imcljs deps.edn + shadow-cljs migration (`im-7os.3`)
- tool-store deps.edn migration (`im-7os.3`)
- C1+C2 JDBC/Hikari/Jackson/json/everit/ant/math3 bumps (`im-jqz.1`)
- C7 intermine weak-dependency removals (`im-jqz.7`)
- im-tables-3 deps.edn + shadow-cljs migration (`im-7os.3`)
- D1+D2+D4 GitHub Actions, dependabot, docs (`im-89g.1`)
- CI fix: drop sudo -E for Postgres (`im-89g.1`)
- CI fix2: PG15+ public schema grant (`im-89g.1`)
- F3 bluegenes GitHub Actions (`im-28e.3`)
- D3 maven-publish + Central Portal (`im-89g.3`)
- B2 batch I intermine build files (`im-ee7.2`)
- B2 batch B: bio core/postprocess build files to Gradle 7 configs (`im-ee7.2`)
- B2 batch S bio/sources + testmine (`im-ee7.2`)
- tool-store fixes im-7os.6-9 (`im-7os.6`)
- H1 intermine docs: BUILDING/TESTING/UPGRADING-build (`im-bdy.3`)
- CI actions major bumps (both repos) (`im-89g.5`)
- I5 sprint-report generator (`im-8dd.5`)

## 5. Notes

Approximate pricing: not applied. Token totals are shown without prices; pass `--prices prices.json` (model name to per-million-token prices for input, cache_read, cache_write, output) to add an approximate cost.

Token counts are de-duplicated per API message id. Runs that resume an earlier agent are charged for the increase over the previous row of that agent (same started_utc).

## 6. Open items / blockers

| Issue | Title | Status | Why listed |
|---|---|---|---|
| im-89g.7 | D3 follow-up: test real Central Portal upload (central.sonatype.com blocked in sandbox); human: Portal account, org.intermine namespace, GPG key, run docs/RELEASING.md for 5.1.1 | open | label human, title mentions blocked, title mentions human |
| im-rkn.9 | sandbox/human: approve cdn.jsdelivr.net and cdn.intermine.org (BlueGenes loads scripts from them; browser tests against the local stack fail without them); Playwright's own Chromium needs 8 apt libs on Ubuntu 26.04 (PLAYWRIGHT_HOST_PLATFORM_OVERRIDE=ubuntu24.04-arm64) | open | label human, label blocked, title mentions human |

`bd status` also counts 4 issue(s) as blocked by unfinished dependencies (see `bd blocked`).
