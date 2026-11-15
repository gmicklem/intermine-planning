# STATUS 2026-11-15 11:38 UTC

Generated 2026-11-15 11:38 UTC / 2026-11-15 11:38 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 1 running, 0 stalled, 38 finished.

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-1 | running | 11-14 22:38 | 11:38 | 7.8k | 81.98M | 309.3k |
| Survey intermine build/test state | opus-5-5 | finished | 00:18 | 00:20 | 42 | 1.05M | 9.0k |
| Survey bluegenes build/test state | opus-5-5 | finished | 00:18 | 00:20 | 22 | 347.5k | 8.3k |
| Survey rdfc2im, docker_template, mine-tests… | opus-5-5 | finished | 00:18 | 00:21 | 26 | 863.6k | 7.5k |
| intermine dependency census and CVE invento… | sonnet-5-5 | finished | 01:47 | 02:07 | 182 | 16.47M | 133.5k |
| bluegenes dependency census and inventory | sonnet-5-5 | finished | 01:47 | 02:04 | 162 | 12.90M | 113.7k |
| Write dashboard generator script | sonnet-5-5 | finished | 01:48 | 01:50 | 28 | 807.1k | 22.9k |
| Split master plan into per-area plan docs | sonnet-5-5 | finished | 01:48 | 01:49 | 10 | 238.7k | 15.2k |
| A3 intermine baseline build and tests | opus-5-5 | finished | 01:51 | 02:44 | 206 | 14.29M | 77.7k |
| A4 bluegenes baseline build and tests | sonnet-5-5 | finished | 01:51 | 02:23 | 164 | 7.26M | 55.7k |
| Gradle upgrade path design for intermine | opus-5-5 | finished | 01:54 | 02:18 | 168 | 15.81M | 132.1k |
| shadow-cljs migration design for BlueGenes | opus-5-5 | finished | 01:55 | 02:10 | 126 | 7.05M | 89.0k |
| Write decision records from the plan | sonnet-5-5 | finished | 01:55 | 01:56 | 14 | 365.6k | 10.9k |
| bluegenes weak-dependency removals | sonnet-5-5 | finished | 02:24 | 03:02 | 100 | 3.83M | 25.6k |
| imcljs to deps.edn and shadow-cljs | sonnet-5-5 | finished | 02:25 | 02:47 | 122 | 7.56M | 53.9k |
| bluegenes-tool-store to deps.edn | sonnet-5-5 | finished | 02:25 | 02:36 | 66 | 3.37M | 32.2k |
| B1 Gradle 4.9 to 6.9.4 for intermine | opus-5-5 | finished | 02:45 | 04:01 | 208 | 16.97M | 71.3k |
| C1+C2 intermine JDBC, Hikari, Jackson bumps | sonnet-5-5 | finished | 02:46 | 03:32 | 88 | 3.70M | 23.1k |
| C7 intermine weak-dependency removals | sonnet-5-5 | finished | 02:46 | 05:52 | 206 | 12.20M | 51.7k |
| E1 bluegenes shadow-cljs build migration | opus-5-5 | finished | 03:03 | 05:22 | 498 | 77.69M | 223.4k |
| im-tables-3 to deps.edn and shadow-cljs | sonnet-5-5 | finished | 03:33 | 04:23 | 162 | 12.96M | 79.2k |
| B2 batch P: plugin rewrite for Gradle 7 | opus-5-5 | finished | 04:16 | 05:07 | 202 | 23.89M | 151.4k |
| D1+D2 intermine GitHub Actions and dependab… | sonnet-5-5 | finished | 04:16 | 06:54 | 172 | 10.09M | 66.6k |
| Review E1 bluegenes shadow-cljs branch | opus-5-5 | finished | 04:42 | 04:50 | 92 | 4.29M | 36.5k |
| F3 bluegenes GitHub Actions workflow | sonnet-5-5 | finished | 05:23 | 05:31 | 54 | 2.20M | 32.7k |
| D3 intermine maven-publish and Central Port… | sonnet-5-5 | finished | 05:24 | 09:40 | 260 | 25.10M | 106.6k |
| B2 batch I: intermine build files to Gradle… | sonnet-5-5 | finished | 06:00 | 06:35 | 164 | 11.43M | 71.2k |
| B2 batch B: bio build files to Gradle 7 con… | sonnet-5-5 | finished | 06:00 | 09:43 | 264 | 21.38M | 91.4k |
| B2 batch S: bio/sources and testmine build … | sonnet-5-5 | finished | 06:36 | 07:16 | 154 | 9.55M | 60.0k |
| Fix two flaky intermine test classes | opus-5-5 | finished | 07:04 | 07:31 | 112 | 5.52M | 37.5k |
| tool-store fixes im-7os.6-9 | sonnet-5-5 | finished | 09:44 | 09:48 | 32 | 836.1k | 13.0k |
| A5 rdfc2im testbed baseline | opus-5-5 | finished | 09:47 | 10:21 | 218 | 17.94M | 59.9k |
| B2 flip: intermine to Gradle 7.6 | opus-5-5 | finished | 09:51 | 10:30 | 250 | 18.88M | 86.0k |
| H1 intermine docs: build/test/upgrade | sonnet-5-5 | finished | 09:53 | 09:57 | 64 | 3.67M | 33.4k |
| CI actions major bumps both repos | sonnet-5-5 | finished | 09:54 | 09:55 | 24 | 610.7k | 5.9k |
| I5 sprint-report generator script | sonnet-5-5 | finished | 09:59 | 10:01 | 16 | 543.9k | 18.9k |
| F2 Cypress 13 migration for bluegenes | opus-5-5 | finished | 10:17 | 11:09 | 238 | 16.22M | 82.5k |
| B3 P3: plugin ready for Gradle 8/9 | opus-5-5 | finished | 10:34 | 11:36 | 168 | 12.51M | 44.2k |
| B3 ROOTS+TESTRES: root builds for Gradle 8 | opus-5-5 | finished | 10:34 | 11:09 | 108 | 6.62M | 38.0k |
| B3 CATALOG: module coords to version catalog | sonnet-5-5 | running | 11:13 | 11:36 | 108 | 5.58M | 40.5k |

Note: 103 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-1 | 320 | 7.8k | 81.24M | 735.8k | 309.3k |
| subagents | opus-5-5 | 1342 | 2.7k | 231.77M | 8.18M | 1.15M |
| subagents | sonnet-5-5 | 1307 | 2.6k | 164.18M | 8.46M | 1.16M |

Tokens are de-duplicated per API message (streamed records share one message id).

## Beads summary

bd status: total 111, open 68, in progress 5, blocked 4, ready 64, deferred 0, closed 38.

| Status | Count |
|---|---|
| closed | 38 |
| in_progress | 5 |
| open | 68 |

### im-28e Epic F: BlueGenes tests and CI [open, 2/7 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-28e.1 | F1 kaocha unit tests green on new toolchain | open | 1 | epic |
| im-28e.5 | F4 re-record Cypress specs and fixtures for the r… | open | 1 | bluegenes,epic,tests |
| im-28e.3 | F3 GitHub Actions for bluegenes (cljfmt, kaocha, … | in_progress | 2 | epic |
| im-28e.6 | bluegenes cypress: user_account_test.js has 4 ups… | open | 2 | bluegenes,epic,tests |
| im-28e.7 | bluegenes: enable nightly-cypress.yml with npm ru… | open | 2 | bluegenes,ci,epic |

### im-7os Epic E: BlueGenes toolchain modernisation [open, 6/12 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.10 | bluegenes: remaining npm advisories (7 critical, … | open | 1 | epic |
| im-7os.2 | E2 Library bumps: ClojureScript, re-frame 1.4, re… | open | 1 | epic |
| im-7os.3 | E3 imcljs / im-tables-3 / bluegenes-tool-store on… | in_progress | 1 | epic |
| im-7os.11 | tool-store: delete-dir uses string/starts-with? o… | open | 2 | epic,followup,tool-store |
| im-7os.4 | E4 CDN assets pinned with SRI or bundled; vega bu… | open | 2 | epic |
| im-7os.12 | tool-store: clj-http 'Invalid cookie header' warn… | open | 3 | epic,followup,tool-store |

### im-89g Epic D: intermine CI and release pipeline [open, 5/9 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-89g.7 | D3 follow-up: test real Central Portal upload (ce… | open | 1 | epic,followup,human,intermine |
| im-89g.6 | D3 follow-up: drop legacy-runtime fix-up in confi… | open | 2 | epic,followup,intermine |
| im-89g.8 | intermine CI: config/ci-bio.properties names data… | open | 2 | ci,epic,intermine |
| im-89g.9 | intermine: central-bundle.gradle header says <bui… | open | 3 | docs,epic,intermine |

### im-8dd Epic I: Planning repo, beads, dashboard [open, 3/5 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-8dd.2 | I2 Dashboard generator (STATUS.md, index.html) an… | in_progress | 0 | epic |
| im-8dd.5 | I5 Sprint report for renewal decision (tokens/tim… | in_progress | 1 | epic |

### im-bdy Epic H: Docs and governance [open, 1/3 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-bdy.3 | H1 intermine docs: building, local testing, upgra… | open | 2 | epic |
| im-bdy.4 | intermine README: depsy.org badge likely dead; de… | open | 3 | docs,epic,intermine |

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 10/32 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.24 | intermine bio/model jar ships the test intermine.… | open | 1 | epic,intermine,security |
| im-ee7.26 | R7 checkstyle bump: 7.8.1 -> 9.3 (Gradle 8.14 def… | open | 1 | epic,for-gos,gradle,intermine |
| im-ee7.3 | B3 Gradle 8.14, remove com.sun.xml.internal prope… | in_progress | 1 | epic |
| im-ee7.30 | B3 CATALOG batch: move the 50 module-file coordin… | open | 1 | epic,gradle,intermine |
| im-ee7.4 | B4 JDK 17 build and test run; JDK 21 verification | open | 1 | epic |
| im-ee7.5 | B5 Deployer migration: update humanmine/flymine b… | open | 1 | epic |
| im-ee7.10 | B5 deployer guide: deployers must delete stopExec… | open | 2 | epic |
| im-ee7.12 | intermine plugin: runtime-resources dir so test-o… | open | 2 | epic |
| im-ee7.13 | bio/model: mergeModels edits processResources out… | open | 2 | epic |
| im-ee7.14 | plugin/build.gradle: maven -> maven-publish, clas… | open | 2 | epic |
| im-ee7.19 | intermine: jsonassert declared api in model but o… | open | 2 | epic |
| im-ee7.20 | bio/sources psi-complexes: chebiWS-client-2.4.jar… | open | 2 | epic |
| im-ee7.21 | bio/sources delimited: biojava-core declared but … | open | 2 | epic |
| im-ee7.23 | D3 follow-up: confirm bio/sources POM scope chang… | open | 2 | deployer,epic,followup,intermine |
| im-ee7.25 | B5 input: deployer changes seen in flymine smoke … | open | 2 | deployer,epic,intermine |
| im-ee7.27 | intermine: sourcesJar in objectstore and pathquer… | open | 2 | epic,gradle,intermine |
| im-ee7.28 | testmine :webapp:war alone fails in mergeProperti… | open | 2 | epic,gradle,intermine |
| im-ee7.29 | B5 deployer list from 7.6.6 flymine smoke: delete… | open | 2 | deployer,epic,intermine |
| im-ee7.6 | intermine plugin: tasks without declared outputs … | open | 2 | epic |
| im-ee7.8 | intermine: test-only files leak into bio-source/p… | open | 2 | epic |
| im-ee7.31 | intermine/testresources/.gitignore still ignores … | open | 3 | epic,intermine |
| im-ee7.32 | plugin addStrutsConfig hard-codes build/resources… | open | 3 | epic,gradle,intermine |

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 4/18 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.3 | C3 commons-* (collections, io, lang, fileupload, … | open | 0 | epic |
| im-jqz.4 | C4 bcprov, oltu, JOpenId, DWR CVE check (Tier 2 m… | open | 1 | epic |
| im-jqz.6 | C6 JUnit 4.13.2, xmlunit, mockobjects/easymock cl… | open | 1 | epic |
| im-jqz.10 | intermine: HikariCP 5.x once JDK 11+ baseline lan… | open | 2 | epic |
| im-jqz.11 | intermine: remove jersey-media-json-jackson + Jer… | open | 2 | epic |
| im-jqz.12 | sandbox: Postgres max_connections=100 nearly exha… | open | 2 | epic |
| im-jqz.5 | C5 Jena 4.x, solrj latest 8.x, Lucene 3 stance | open | 2 | epic |
| im-jqz.9 | intermine: ant 1.7.0 -> 1.10.x (3 advisories); te… | open | 2 | epic |
| im-jqz.13 | intermine: pathquery and model rely on org.json v… | open | 3 | epic |
| im-jqz.14 | intermine: JAXB/annotation shims (inventory R14) … | open | 3 | epic |
| im-jqz.15 | intermine: objenesis redundant with easymock; rem… | open | 3 | epic |
| im-jqz.16 | intermine: xalan removal verified only by unit te… | open | 3 | epic |
| im-jqz.17 | intermine DataTracker: 'broken' flag never reset … | open | 3 | epic |
| im-jqz.18 | intermine DataTrackingTest.testWrongOrderBug leak… | open | 3 | epic |

### im-ore Epic G: Whole-system testbed [open, 0/6 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ore.1 | G1 rdfc2im --intermine-src: consume local org.int… | open | 1 | epic |
| im-ore.3 | rdfc2im: make --use-cached-data fully offline (en… | open | 1 | epic,rdfc2im,testbed |
| im-ore.6 | G1 prerequisites for --intermine-src (from A5 bas… | open | 1 | epic,intermine,rdfc2im,testbed |
| im-ore.2 | G2 mine-tests fixtures for the local demo mine (m… | open | 2 | epic |
| im-ore.4 | rdfc2im: pass -Duser.home/GRADLE_USER_HOME explic… | open | 2 | epic,rdfc2im,testbed |
| im-ore.5 | mine-tests: add a 'local' mine entry; skip JBrows… | open | 2 | epic,mine-tests,testbed |

### im-rkn Epic A: Environment and baseline [open, 7/10 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-rkn.9 | sandbox/human: approve cdn.jsdelivr.net and cdn.i… | open | 1 | blocked,epic,human,testbed |
| im-rkn.8 | im-testenv.sh: offer a non-superuser test role mo… | open | 2 | epic |
| im-rkn.10 | sandbox: Cypress Electron needs Xvfb+GTK; worker … | open | 3 | epic,sandbox |

## Repos and branches

| Repo | WT | Branch | Last commit | vs dev \| subject |
|---|---|---|---|---|
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint-2026 | 11:37 (59s) | ahead 71 vs dev \| Merge maint/im-ee7.3-plugin-gradle8: pl… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-89g.1-ci-actions | 04:45 (6.9h) | - \| docs: update README badges, PR template… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-89g.1-ci-fix | 06:28 (5.2h) | - \| ci: stop using sudo -E -u postgres; con… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-89g.1-ci-fix2 | 06:54 (4.7h) | - \| ci: fix PostgreSQL 15+ public schema pr… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-89g.3-maven-publish | 09:40 (2.0h) | - \| docs: add RELEASING.md (version bump, b… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-89g.5-ci-actions | 09:55 (1.7h) | - \| ci: bump GitHub Actions to current majo… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-bdy.3-docs | 09:57 (1.7h) | - \| docs: README bootstrap command and deve… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-ee7.1-gradle-6 | 03:57 (7.7h) | - \| build: default to Gradle 6.9.4 and veri… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-ee7.2-batch-bio | 09:32 (2.1h) | - \| build(bio): fold copyMineProperties int… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-ee7.2-batch-intermine | 06:21 (5.3h) | - \| intermine: convert all build files to G… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-ee7.2-batch-sources | 07:16 (4.4h) | - \| testmine: convert build files to Gradle… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-ee7.2-gradle-76-flip | 10:27 (71m) | - \| build: root testReport tasks use the Gr… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-ee7.2-plugin-gradle7 | 05:06 (6.5h) | - \| build(plugin): lazy tasks, no init task… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-ee7.3-catalog-modules | 11:35 (3m) | - \| build(intermine): third-party coordinat… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-ee7.3-plugin-gradle8 | 11:34 (4m) | - \| merge: maint-2026 (ROOTS+TESTRES batch)… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-ee7.3-roots-testres | 11:09 (29m) | - \| build: version catalog gradle/libs.vers… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-jqz.1-jdbc-jackson | 03:31 (8.1h) | - \| deps: drop duplicate commons-math3 3.0 … |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-jqz.7-weak-deps | 05:51 (5.8h) | - \| deps: remove orphan vendored bobo-brows… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-jqz.8-flaky-tests | 07:24 (4.2h) | - \| integrate: make DataTracker.clear() saf… |
| intermine | 3 (im-ee7.3-catalog-…, merge-maint-2026) | maint/im-rkn.3-baseline | 06-12 11:01 (156d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 1 | maint-2026 | 11:09 (29m) | ahead 52 vs dev \| docs, cypress: how to run the suite; ta… |
| bluegenes | 1 | maint/im-28e.2-cypress-13 | 11:09 (29m) | - \| docs, cypress: how to run the suite; ta… |
| bluegenes | 1 | maint/im-28e.3-gh-actions | 05:31 (6.1h) | - \| docs: CI badge and Continuous integrati… |
| bluegenes | 1 | maint/im-7os.1-shadow-cljs | 05:17 (6.3h) | - \| comments: drop stale lein/figwheel refe… |
| bluegenes | 1 | maint/im-7os.5-removals | 02:59 (8.6h) | - \| npm: remove unused clipboardy [im-7os.5] |
| bluegenes | 1 | maint/im-89g.5-ci-actions | 09:55 (1.7h) | - \| ci: bump GitHub Actions to current majo… |
| bluegenes | 1 | maint/im-rkn.4-baseline | 01-26 21:58 (657d) | - \| dynamic favicon slows down dx |
| imcljs | 1 | maint-2026 | 02:46 (8.9h) | ahead 8 vs dev \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| imcljs | 1 | maint/im-7os.3-imcljs-deps-edn | 02:46 (8.9h) | - \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| im-tables-3 | 2 (im-7os.3-im-table…) | maint-2026 | 11-28 17:19 (1447d) | level vs dev \| Bump version to 0.15.0 |
| im-tables-3 | 2 (im-7os.3-im-table…) | maint/im-7os.3-im-tables-deps-edn | 04:23 (7.3h) | - \| docs: README section for the deps.edn /… |
| bluegenes-tool-store | 1 | maint-2026 | 09:48 (1.8h) | ahead 8 vs master \| deps: bump commons-compress 1.19 -> 1.2… |
| bluegenes-tool-store | 1 | maint/im-7os.3-tool-store-deps-edn | 02:33 (9.1h) | - \| deps: remove unused ring/ring-defaults … |
| bluegenes-tool-store | 1 | maint/im-7os.6-tool-store-fixes | 09:48 (1.8h) | - \| deps: bump commons-compress 1.19 -> 1.2… |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

| Start | Bead | Agent | Model | In | Cache | Out | Outcome | Notes |
|---|---|---|---|---|---|---|---|---|
| 10:34 | im-ee7.3 | B3 ROOTS+TESTRES: providers… | opus | 108 | 6.62M | 38.0k | success | 3 gated commits; POMs byte-identical; m… |
| 10:34 | im-ee7.3 | B3 P3: plugin ready for Gra… | opus | 168 | 12.51M | 44.2k | success | 5 gated commits + merge; flymine smoke:… |
| 10:17 | im-28e.2 | F2 Cypress 13 migration | opus | 238 | 16.22M | 82.5k | success | 7 gated commits; Electron headless on a… |
| 09:59 | im-8dd.5 | I5 sprint-report generator | sonnet | 16 | 543.9k | 18.9k | success | scripts/sprint-report.py + status/sprin… |
| 09:54 | im-89g.5 | CI actions major bumps (bot… | sonnet | 24 | 610.7k | 5.9k | success | actionlint clean; merged both; CI dispa… |
| 09:53 | im-bdy.3 | H1 intermine docs: BUILDING… | sonnet | 64 | 3.67M | 33.4k | success | 2 commits, docs only, merged |
| 09:51 | im-ee7.2 | B2 flip: Gradle 7.6.6 + che… | opus | 250 | 18.88M | 86.0k | success | 3 commits (1st red by design), gate gre… |
| 09:47 | im-rkn.5 | A5 rdfc2im testbed baseline… | opus | 218 | 17.94M | 59.9k | success | mine up in 10m45s; test-live 17/17; min… |
| 09:44 | im-7os.6 | tool-store fixes im-7os.6-9 | sonnet | 32 | 836.1k | 13.0k | success | 4 gated commits, merged ff, pushed |
| 07:04 | im-jqz.8 | Fix flaky testBatchesCache … | opus | 112 | 5.52M | 37.5k | done | 2 commits; real DataTracker race fixed |
| 06:36 | im-ee7.2 | B2 batch S bio/sources + te… | sonnet | 154 | 9.55M | 60.0k | done | 3 commits; gate green; testmine builds |
| 06:00 | im-ee7.2 | B2 batch B: bio core/postpr… | sonnet | 264 | 21.38M | 91.4k | success | 5 commits, gate green on merged tree; 7… |
| 06:00 | im-ee7.2 | B2 batch I intermine build … | sonnet | 164 | 11.43M | 71.2k | done | 1 commit; gate green; 7.6.4 compiles; c… |
| 05:24 | im-89g.3 | D3 maven-publish + Central … | sonnet | 260 | 25.10M | 106.6k | success | 2 commits, gate passed, nmcp vetted not… |
| 05:23 | im-28e.3 | F3 bluegenes GitHub Actions | sonnet | 54 | 2.20M | 32.7k | done | 6 commits; actionlint clean |
| 04:42 | im-7os.1 | E1 pre-merge review | opus | 92 | 4.29M | 36.5k | done | DO NOT MERGE: shim load order breaks bo… |
| 04:16 | im-89g.1 | D1+D2+D4 GitHub Actions, de… | sonnet | 104 | 4.96M | 41.6k | done | 3 commits; actionlint clean |
| 04:16 | im-89g.1 | CI fix: drop sudo -E for Po… | sonnet | 130 | 6.76M | 52.2k | done | 1 commit; gate green |
| 04:16 | im-89g.1 | CI fix2: PG15+ public schem… | sonnet | 172 | 10.09M | 66.6k | done | 1 commit; gate green on non-superuser P… |
| 04:16 | im-ee7.2 | B2 batch P plugin rewrite | opus | 202 | 23.89M | 151.4k | done | 1 commit; dependsOn 42->8 stmts; works … |

Showing the 20 most recent of 41 runs.
