# STATUS 2026-11-15 13:29 UTC

Generated 2026-11-15 13:29 UTC / 2026-11-15 13:29 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 2 running, 0 stalled, 46 finished.

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-1 | running | 11-14 22:38 | 13:29 | 9.4k | 103.33M | 372.6k |
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
| B3 CATALOG: module coords to version catalog | sonnet-5-5 | finished | 11:13 | 11:52 | 134 | 7.66M | 48.8k |
| E4 bluegenes CDN assets pinned with SRI | sonnet-5-5 | finished | 11:39 | 11:49 | 54 | 1.73M | 21.7k |
| im-tables gate against local demo mine | opus-5-5 | finished | 11:51 | 12:05 | 88 | 3.62M | 29.0k |
| bluegenes npm dev advisories | sonnet-5-5 | finished | 11:51 | 11:59 | 42 | 1.01M | 8.6k |
| B3 3b: flip intermine to Gradle 8.14.6 | opus-5-5 | finished | 11:54 | 13:28 | 370 | 33.21M | 100.4k |
| G1 rdfc2im build from local intermine artef… | opus-5-5 | finished | 12:01 | 13:08 | 254 | 26.91M | 120.8k |
| S5 bluegenes on sibling git deps | opus-5-5 | finished | 12:07 | 12:49 | 148 | 8.78M | 41.2k |
| E2 BlueGenes + im-tables library bumps | opus-5-5 | running | 12:51 | 13:28 | 182 | 13.31M | 41.1k |
| Check 5.1.1 candidate plugin on Gradle 4.9 | sonnet-5-5 | finished | 13:11 | 13:21 | 74 | 2.57M | 16.5k |
| G2 mine-tests local demo mine fixtures | sonnet-5-5 | running | 13:22 | 13:28 | 68 | 2.63M | 24.7k |

Note: 140 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-1 | 380 | 9.4k | 102.49M | 840.0k | 372.6k |
| subagents | opus-5-5 | 1863 | 3.7k | 313.79M | 11.99M | 1.49M |
| subagents | sonnet-5-5 | 1439 | 2.9k | 173.62M | 9.04M | 1.24M |

Tokens are de-duplicated per API message (streamed records share one message id).

## Beads summary

bd status: total 129, open 74, in progress 7, blocked 0, ready 74, deferred 0, closed 48.

| Status | Count |
|---|---|
| closed | 48 |
| in_progress | 7 |
| open | 74 |

### im-28e Epic F: BlueGenes tests and CI [open, 3/8 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-28e.5 | F4 re-record Cypress specs and fixtures for the r… | open | 1 | bluegenes,epic,tests |
| im-28e.3 | F3 GitHub Actions for bluegenes (cljfmt, kaocha, … | in_progress | 2 | epic |
| im-28e.6 | bluegenes cypress: user_account_test.js has 4 ups… | open | 2 | bluegenes,epic,tests |
| im-28e.7 | bluegenes: enable nightly-cypress.yml with npm ru… | open | 2 | bluegenes,ci,epic |
| im-28e.8 | tests: default public mine is HumanMine (Gos): im… | open | 2 | bluegenes,epic,im-tables,tests |

### im-7os Epic E: BlueGenes toolchain modernisation [open, 11/19 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.19 | siblings before release: im-tables deps.edn still… | open | 1 | bluegenes,epic,human,release |
| im-7os.2 | E2 Library bumps: ClojureScript, re-frame 1.4, re… | in_progress | 1 | epic |
| im-7os.11 | tool-store: delete-dir uses string/starts-with? o… | open | 2 | epic,followup,tool-store |
| im-7os.13 | bluegenes nav.cljs loads the logo from dead cdn.r… | open | 2 | bluegenes,epic |
| im-7os.15 | bluegenes: highlight.js 9.12.0 + react-highlight.… | open | 2 | bluegenes,epic,security |
| im-7os.12 | tool-store: clj-http 'Invalid cookie header' warn… | open | 3 | epic,followup,tool-store |
| im-7os.14 | bluegenes viz/cases.cljs uses deprecated vega-lit… | open | 3 | bluegenes,epic |
| im-7os.16 | bluegenes dev advisories needing majors: Cypress … | open | 3 | bluegenes,epic,security |

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

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 12/40 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.24 | intermine bio/model jar ships the test intermine.… | open | 1 | epic,intermine,security |
| im-ee7.26 | R7 checkstyle bump: 7.8.1 -> 9.3 (Gradle 8.14 def… | open | 1 | epic,for-gos,gradle,intermine |
| im-ee7.30 | B3 CATALOG batch: move the 50 module-file coordin… | open | 1 | epic,gradle,intermine |
| im-ee7.35 | intermine-webapp war built by the 7.6.6 toolchain… | open | 1 | epic,intermine,release |
| im-ee7.37 | plugin addStrutsConfig uses outputs of copyMinePr… | open | 1 | epic,gradle,intermine |
| im-ee7.39 | 6.0.0 deployer guide + plugin: with the new copyM… | open | 1 | deployer,epic,intermine,security |
| im-ee7.4 | B4 JDK 17 build and test run; JDK 21 verification | in_progress | 1 | epic |
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
| im-ee7.36 | plugin: Ant task logging lost under Gradle 7 (log… | open | 2 | epic,gradle,intermine |
| im-ee7.38 | docs/UPGRADING-build.md: 5.1.1 verified on a Grad… | open | 2 | deployer,docs,epic,intermine |
| im-ee7.6 | intermine plugin: tasks without declared outputs … | open | 2 | epic |
| im-ee7.8 | intermine: test-only files leak into bio-source/p… | open | 2 | epic |
| im-ee7.31 | intermine/testresources/.gitignore still ignores … | open | 3 | epic,intermine |
| im-ee7.32 | plugin addStrutsConfig hard-codes build/resources… | open | 3 | epic,gradle,intermine |
| im-ee7.33 | intermine: move org.intermine:* imVersion coordin… | open | 3 | epic,gradle,intermine |
| im-ee7.40 | intermine: buildscript blocks can read the catalo… | open | 3 | epic,gradle,intermine |

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 4/19 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.3 | C3 commons-* (collections, io, lang, fileupload, … | open | 0 | epic |
| im-jqz.4 | C4 bcprov, oltu, JOpenId, DWR CVE check (Tier 2 m… | open | 1 | epic |
| im-jqz.6 | C6 JUnit 4.13.2, xmlunit, mockobjects/easymock cl… | open | 1 | epic |
| im-jqz.10 | intermine: HikariCP 5.x once JDK 11+ baseline lan… | open | 2 | epic |
| im-jqz.11 | intermine: remove jersey-media-json-jackson + Jer… | open | 2 | epic |
| im-jqz.12 | sandbox: Postgres max_connections=100 nearly exha… | open | 2 | epic |
| im-jqz.19 | bio/sources/psi-complexes now mixes jami-core 3.2… | open | 2 | bio-sources,epic,intermine |
| im-jqz.5 | C5 Jena 4.x, solrj latest 8.x, Lucene 3 stance | open | 2 | epic |
| im-jqz.9 | intermine: ant 1.7.0 -> 1.10.x (3 advisories); te… | open | 2 | epic |
| im-jqz.13 | intermine: pathquery and model rely on org.json v… | open | 3 | epic |
| im-jqz.14 | intermine: JAXB/annotation shims (inventory R14) … | open | 3 | epic |
| im-jqz.15 | intermine: objenesis redundant with easymock; rem… | open | 3 | epic |
| im-jqz.16 | intermine: xalan removal verified only by unit te… | open | 3 | epic |
| im-jqz.17 | intermine DataTracker: 'broken' flag never reset … | open | 3 | epic |
| im-jqz.18 | intermine DataTrackingTest.testWrongOrderBug leak… | open | 3 | epic |

### im-ore Epic G: Whole-system testbed [open, 2/7 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ore.3 | rdfc2im: make --use-cached-data fully offline (en… | open | 1 | epic,rdfc2im,testbed |
| im-ore.2 | G2 mine-tests fixtures for the local demo mine (m… | in_progress | 2 | epic |
| im-ore.4 | rdfc2im: pass -Duser.home/GRADLE_USER_HOME explic… | open | 2 | epic,rdfc2im,testbed |
| im-ore.5 | mine-tests: add a 'local' mine entry; skip JBrows… | in_progress | 2 | epic,mine-tests,testbed |
| im-ore.7 | rdfc2im follow-ups from G1: per-stack data dir in… | open | 2 | epic,rdfc2im,testbed |

### im-rkn Epic A: Environment and baseline [open, 7/10 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-rkn.9 | sandbox/human: approve cdn.jsdelivr.net and cdn.i… | open | 1 | blocked,epic,human,testbed |
| im-rkn.8 | im-testenv.sh: offer a non-superuser test role mo… | open | 2 | epic |
| im-rkn.10 | sandbox: Cypress Electron needs Xvfb+GTK; worker … | open | 3 | epic,sandbox |

## Repos and branches

| Repo | WT | Branch | Last commit | vs dev \| subject |
|---|---|---|---|---|
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint-2026 | 13:28 (54s) | ahead 85 vs dev \| Merge maint/im-ee7.3-gradle-814-flip: G… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-89g.1-ci-actions | 04:45 (8.7h) | - \| docs: update README badges, PR template… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-89g.1-ci-fix | 06:28 (7.0h) | - \| ci: stop using sudo -E -u postgres; con… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-89g.1-ci-fix2 | 06:54 (6.6h) | - \| ci: fix PostgreSQL 15+ public schema pr… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-89g.3-maven-publish | 09:40 (3.8h) | - \| docs: add RELEASING.md (version bump, b… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-89g.5-ci-actions | 09:55 (3.6h) | - \| ci: bump GitHub Actions to current majo… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-bdy.3-docs | 09:57 (3.5h) | - \| docs: README bootstrap command and deve… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.1-gradle-6 | 03:57 (9.5h) | - \| build: default to Gradle 6.9.4 and veri… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.2-batch-bio | 09:32 (4.0h) | - \| build(bio): fold copyMineProperties int… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.2-batch-intermine | 06:21 (7.1h) | - \| intermine: convert all build files to G… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.2-batch-sources | 07:16 (6.2h) | - \| testmine: convert build files to Gradle… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.2-gradle-76-flip | 10:27 (3.0h) | - \| build: root testReport tasks use the Gr… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.2-plugin-gradle7 | 05:06 (8.4h) | - \| build(plugin): lazy tasks, no init task… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.3-catalog-modules | 11:52 (1.6h) | - \| docs: describe the version catalog; the… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.3-gradle-814-flip | 13:27 (2m) | - \| build(plugin): addStrutsConfig no longe… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.3-plugin-gradle8 | 11:34 (1.9h) | - \| merge: maint-2026 (ROOTS+TESTRES batch)… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.3-roots-testres | 11:09 (2.3h) | - \| build: version catalog gradle/libs.vers… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-ee7.4-jdk17 | 13:28 (54s) | - \| Merge maint/im-ee7.3-gradle-814-flip: G… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-jqz.1-jdbc-jackson | 03:31 (10.0h) | - \| deps: drop duplicate commons-math3 3.0 … |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-jqz.7-weak-deps | 05:51 (7.6h) | - \| deps: remove orphan vendored bobo-brows… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-jqz.8-flaky-tests | 07:24 (6.1h) | - \| integrate: make DataTracker.clear() saf… |
| intermine | 3 (im-ee7.4-jdk17, merge-maint-2026) | maint/im-rkn.3-baseline | 06-12 11:01 (156d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint-2026 | 12:49 (40m) | ahead 60 vs dev \| docs: how the sibling libraries are pin… |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint/im-28e.2-cypress-13 | 11:09 (2.3h) | - \| docs, cypress: how to run the suite; ta… |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint/im-28e.3-gh-actions | 05:31 (8.0h) | - \| docs: CI badge and Continuous integrati… |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint/im-7os.1-shadow-cljs | 05:17 (8.2h) | - \| comments: drop stale lein/figwheel refe… |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint/im-7os.10-npm-advisories | 11:58 (1.5h) | - \| deps: override qs to 6.17.1 (same major… |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint/im-7os.18-sibling-deps | 12:49 (40m) | - \| docs: how the sibling libraries are pin… |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint/im-7os.2-lib-bumps | 13:24 (5m) | - \| deps: server libraries: ring 1.13, timb… |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint/im-7os.4-cdn-sri | 11:48 (1.7h) | - \| script: cdn-sri.sh prints SRI hashes fo… |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint/im-7os.5-removals | 02:59 (10.5h) | - \| npm: remove unused clipboardy [im-7os.5] |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint/im-89g.5-ci-actions | 09:55 (3.6h) | - \| ci: bump GitHub Actions to current majo… |
| bluegenes | 2 (im-7os.2-lib-bumps) | maint/im-rkn.4-baseline | 01-26 21:58 (657d) | - \| dynamic favicon slows down dx |
| imcljs | 1 | maint-2026 | 02:46 (10.7h) | ahead 8 vs dev \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| imcljs | 1 | maint/im-7os.3-imcljs-deps-edn | 02:46 (10.7h) | - \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| im-tables-3 | 2 (im-7os.2-lib-bumps) | maint-2026 | 12:05 (85m) | ahead 12 vs dev \| test: lein kaocha honours IM_TABLES_SER… |
| im-tables-3 | 2 (im-7os.2-lib-bumps) | maint/im-7os.2-lib-bumps | 12:05 (85m) | - \| test: lein kaocha honours IM_TABLES_SER… |
| im-tables-3 | 2 (im-7os.2-lib-bumps) | maint/im-7os.3-im-tables-deps-edn | 12:05 (85m) | - \| test: lein kaocha honours IM_TABLES_SER… |
| bluegenes-tool-store | 1 | maint-2026 | 09:48 (3.7h) | ahead 8 vs master \| deps: bump commons-compress 1.19 -> 1.2… |
| bluegenes-tool-store | 1 | maint/im-7os.3-tool-store-deps-edn | 02:33 (10.9h) | - \| deps: remove unused ring/ring-defaults … |
| bluegenes-tool-store | 1 | maint/im-7os.6-tool-store-fixes | 09:48 (3.7h) | - \| deps: bump commons-compress 1.19 -> 1.2… |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

| Start | Bead | Agent | Model | In | Cache | Out | Outcome | Notes |
|---|---|---|---|---|---|---|---|---|
| 13:11 | im-ee7.34 | 5.1.1 candidate plugin on G… | sonnet | 74 | 2.57M | 16.5k | success | works on 4.9 and 6.9.4 (configure + tas… |
| 12:07 | im-7os.18 | S5 bluegenes on sibling git… | opus | 148 | 8.78M | 41.2k | success | 3 gated commits; Cypress identical to m… |
| 12:01 | im-ore.1 | G1 rdfc2im --intermine-src … | opus | 254 | 26.91M | 120.8k | success | 6 gated commits; mine from 5.1.1 up on … |
| 11:54 | im-ee7.3 | B3 3b: flip to Gradle 8.14.6 | opus | 370 | 33.21M | 100.4k | success | 7 gated commits; 0 own deprecations; te… |
| 11:51 | im-7os.10 | bluegenes npm advisories | sonnet | 42 | 1.01M | 8.6k | success | 22 -> 13 (high 10 -> 2); rest need Cypr… |
| 11:51 | im-7os.3 | im-tables deps.edn validati… | opus | 88 | 3.62M | 29.0k | success | 3 commits; old/new trees identical per-… |
| 11:39 | im-7os.4 | E4 CDN assets SRI + vega bu… | sonnet | 54 | 1.73M | 21.7k | success | 3 gated commits (prod gate), all on cdn… |
| 11:13 | im-ee7.3 | B3 CATALOG: module coordina… | sonnet | 134 | 7.66M | 48.8k | success | 3 gated batches + docs; 68 libraries; P… |
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

Showing the 20 most recent of 49 runs.
