# STATUS 2026-11-15 16:47 UTC

Generated 2026-11-15 16:47 UTC / 2026-11-15 16:47 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 1 running, 0 stalled, 53 finished.

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-1 | running | 11-14 22:38 | 16:47 | 11.6k | 115.58M | 428.9k |
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
| E2 BlueGenes + im-tables library bumps | opus-5-5 | finished | 12:51 | 14:34 | 382 | 40.91M | 98.8k |
| Check 5.1.1 candidate plugin on Gradle 4.9 | sonnet-5-5 | finished | 13:11 | 13:21 | 74 | 2.57M | 16.5k |
| G2 mine-tests local demo mine fixtures | sonnet-5-5 | finished | 13:22 | 13:30 | 72 | 2.83M | 26.8k |
| B4 intermine on JDK 17 (and 21) | opus-5-5 | finished | 13:30 | 16:45 | 356 | 35.34M | 123.4k |
| C3 commons, ant, org.json cleanup | sonnet-5-5 | finished | 13:31 | 15:02 | 178 | 10.92M | 58.0k |
| E-hljs: highlight.js 9 to 11 | sonnet-5-5 | finished | 14:47 | 16:43 | 146 | 7.70M | 42.3k |
| Jar hygiene: credentials, duplicate libs | sonnet-5-5 | finished | 15:04 | 15:54 | 134 | 7.75M | 55.6k |
| Webapp libs: log4j 2.5, stale jars, Jersey | sonnet-5-5 | finished | 15:55 | 16:32 | 134 | 5.89M | 42.7k |
| C4 Tier 2 CVE check: bcprov, oltu, JOpenId,… | sonnet-5-5 | running | 16:46 | 16:47 | 14 | 323.6k | 3.1k |

Note: 161 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-1 | 459 | 11.6k | 114.54M | 1.04M | 428.9k |
| subagents | opus-5-5 | 2141 | 4.3k | 372.14M | 16.59M | 1.67M |
| subagents | sonnet-5-5 | 1744 | 3.5k | 203.89M | 11.56M | 1.44M |

Tokens are de-duplicated per API message (streamed records share one message id).

## Beads summary

bd status: total 152, open 86, in progress 5, blocked 0, ready 86, deferred 0, closed 61.

| Status | Count |
|---|---|
| closed | 61 |
| in_progress | 5 |
| open | 86 |

### im-28e Epic F: BlueGenes tests and CI [open, 3/8 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-28e.5 | F4 re-record Cypress specs and fixtures for the r… | open | 1 | bluegenes,epic,tests |
| im-28e.3 | F3 GitHub Actions for bluegenes (cljfmt, kaocha, … | in_progress | 2 | epic |
| im-28e.6 | bluegenes cypress: user_account_test.js has 4 ups… | open | 2 | bluegenes,epic,tests |
| im-28e.7 | bluegenes: enable nightly-cypress.yml with npm ru… | open | 2 | bluegenes,ci,epic |
| im-28e.8 | tests: default public mine is HumanMine (Gos): im… | open | 2 | bluegenes,epic,im-tables,tests |

### im-7os Epic E: BlueGenes toolchain modernisation [open, 13/24 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.19 | siblings before release: im-tables deps.edn still… | open | 1 | bluegenes,epic,human,release |
| im-7os.11 | tool-store: delete-dir uses string/starts-with? o… | open | 2 | epic,followup,tool-store |
| im-7os.13 | bluegenes nav.cljs loads the logo from dead cdn.r… | open | 2 | bluegenes,epic |
| im-7os.22 | bluegenes/im-tables: test the new browser date in… | open | 2 | epic |
| im-7os.24 | bluegenes/im-tables/imcljs tests: HumanMine as th… | open | 2 | epic |
| im-7os.12 | tool-store: clj-http 'Invalid cookie header' warn… | open | 3 | epic,followup,tool-store |
| im-7os.14 | bluegenes viz/cases.cljs uses deprecated vega-lit… | open | 3 | bluegenes,epic |
| im-7os.16 | bluegenes dev advisories needing majors: Cypress … | open | 3 | bluegenes,epic,security |
| im-7os.20 | bluegenes: replace 11 uses of deprecated reagent.… | open | 3 | epic |
| im-7os.21 | im-tables: drop cljs-time (single use in error.cl… | open | 3 | epic |
| im-7os.23 | im-tables codegen: pass an explicit language-<nam… | open | 3 | epic |

### im-89g Epic D: intermine CI and release pipeline [open, 5/9 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-89g.7 | D3 follow-up: test real Central Portal upload (ce… | open | 1 | epic,followup,human,intermine |
| im-89g.6 | D3 follow-up: drop legacy-runtime fix-up in confi… | open | 2 | epic,followup,intermine |
| im-89g.8 | intermine CI: config/ci-bio.properties names data… | open | 2 | ci,epic,intermine |
| im-89g.9 | intermine: central-bundle.gradle header says <bui… | open | 3 | docs,epic,intermine |

### im-8dd Epic I: Planning repo, beads, dashboard [open, 3/6 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-8dd.2 | I2 Dashboard generator (STATUS.md, index.html) an… | in_progress | 0 | epic |
| im-8dd.5 | I5 Sprint report for renewal decision (tokens/tim… | in_progress | 1 | epic |
| im-8dd.6 | gate-intermine.sh counts javac 'deprecated' lines… | open | 3 | epic |

### im-bdy Epic H: Docs and governance [open, 1/3 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-bdy.3 | H1 intermine docs: building, local testing, upgra… | open | 2 | epic |
| im-bdy.4 | intermine README: depsy.org badge likely dead; de… | open | 3 | docs,epic,intermine |

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 17/44 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.26 | R7 checkstyle bump: 7.8.1 -> 9.3 (Gradle 8.14 def… | open | 1 | epic,for-gos,gradle,intermine |
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
| im-ee7.41 | intermine plugin/testmine: Copy tasks that unwar … | open | 2 | epic |
| im-ee7.6 | intermine plugin: tasks without declared outputs … | open | 2 | epic |
| im-ee7.8 | intermine: test-only files leak into bio-source/p… | open | 2 | epic |
| im-ee7.31 | intermine/testresources/.gitignore still ignores … | open | 3 | epic,intermine |
| im-ee7.32 | plugin addStrutsConfig hard-codes build/resources… | open | 3 | epic,gradle,intermine |
| im-ee7.33 | intermine: move org.intermine:* imVersion coordin… | open | 3 | epic,gradle,intermine |
| im-ee7.40 | intermine: buildscript blocks can read the catalo… | open | 3 | epic,gradle,intermine |
| im-ee7.42 | mine template / deployer guide: drop commons-logg… | open | 3 | epic |
| im-ee7.43 | intermine: remove the com.sun.xml.internal proper… | open | 3 | epic |
| im-ee7.44 | testmine Cargo writes Tomcat config to /tmp/cargo… | open | 3 | epic |

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 8/30 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.21 | intermine: commons-beanutils 1.9.4 -> 1.11.0 (cle… | open | 1 | epic |
| im-jqz.22 | intermine: runtime smoke test of Struts multipart… | open | 1 | epic |
| im-jqz.4 | C4 bcprov, oltu, JOpenId, DWR CVE check (Tier 2 m… | in_progress | 1 | epic |
| im-jqz.6 | C6 JUnit 4.13.2, xmlunit, mockobjects/easymock cl… | open | 1 | epic |
| im-jqz.10 | intermine: HikariCP 5.x once JDK 11+ baseline lan… | open | 2 | epic |
| im-jqz.12 | sandbox: Postgres max_connections=100 nearly exha… | open | 2 | epic |
| im-jqz.19 | bio/sources/psi-complexes now mixes jami-core 3.2… | open | 2 | bio-sources,epic,intermine |
| im-jqz.20 | intermine: commons-lang 2.6 -> commons-lang3 migr… | open | 2 | epic |
| im-jqz.28 | intermine webapp: registry lookup in SemanticMark… | open | 2 | epic |
| im-jqz.29 | intermine: replace cglib 3.1 (needs --add-opens j… | open | 2 | epic |
| im-jqz.5 | C5 Jena 4.x, solrj latest 8.x, Lucene 3 stance | open | 2 | epic |
| im-jqz.9 | intermine: ant 1.7.0 -> 1.10.x (3 advisories); te… | open | 2 | epic |
| im-jqz.13 | intermine: pathquery and model rely on org.json v… | open | 3 | epic |
| im-jqz.14 | intermine: JAXB/annotation shims (inventory R14) … | open | 3 | epic |
| im-jqz.15 | intermine: objenesis redundant with easymock; rem… | open | 3 | epic |
| im-jqz.16 | intermine: xalan removal verified only by unit te… | open | 3 | epic |
| im-jqz.17 | intermine DataTracker: 'broken' flag never reset … | open | 3 | epic |
| im-jqz.18 | intermine DataTrackingTest.testWrongOrderBug leak… | open | 3 | epic |
| im-jqz.23 | intermine: drop commons-io once build is on JDK 1… | open | 3 | epic |
| im-jqz.24 | intermine: commons-logging is a hidden runtime de… | open | 3 | epic |
| im-jqz.27 | intermine: default.intermine.properties in bio-mo… | open | 3 | epic |
| im-jqz.30 | bio-source-psi-complexes: ChEBI lookup uses a SOA… | open | 3 | epic |

### im-ore Epic G: Whole-system testbed [open, 4/9 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ore.3 | rdfc2im: make --use-cached-data fully offline (en… | open | 1 | epic,rdfc2im,testbed |
| im-ore.4 | rdfc2im: pass -Duser.home/GRADLE_USER_HOME explic… | open | 2 | epic,rdfc2im,testbed |
| im-ore.7 | rdfc2im follow-ups from G1: per-stack data dir in… | open | 2 | epic,rdfc2im,testbed |
| im-ore.8 | rdfc2im/BlueGenes stack: /favicon.ico redirects t… | open | 2 | bluegenes,epic,rdfc2im,testbed |
| im-ore.9 | mine-tests [mines.local]: gene object id (1000940… | open | 3 | epic,mine-tests,testbed |

### im-rkn Epic A: Environment and baseline [open, 7/10 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-rkn.9 | sandbox/human: approve cdn.jsdelivr.net and cdn.i… | open | 1 | blocked,epic,human,testbed |
| im-rkn.8 | im-testenv.sh: offer a non-superuser test role mo… | open | 2 | epic |
| im-rkn.10 | sandbox: Cypress Electron needs Xvfb+GTK; worker … | open | 3 | epic,sandbox |

## Repos and branches

| Repo | WT | Branch | Last commit | vs dev \| subject |
|---|---|---|---|---|
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint-2026 | 16:45 (2m) | ahead 111 vs dev \| Merge maint/im-ee7.4-jdk17: builds and … |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-89g.1-ci-actions | 04:45 (12.0h) | - \| docs: update README badges, PR template… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-89g.1-ci-fix | 06:28 (10.3h) | - \| ci: stop using sudo -E -u postgres; con… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-89g.1-ci-fix2 | 06:54 (9.9h) | - \| ci: fix PostgreSQL 15+ public schema pr… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-89g.3-maven-publish | 09:40 (7.1h) | - \| docs: add RELEASING.md (version bump, b… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-89g.5-ci-actions | 09:55 (6.9h) | - \| ci: bump GitHub Actions to current majo… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-bdy.3-docs | 09:57 (6.8h) | - \| docs: README bootstrap command and deve… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.1-gradle-6 | 03:57 (12.8h) | - \| build: default to Gradle 6.9.4 and veri… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.2-batch-bio | 09:32 (7.3h) | - \| build(bio): fold copyMineProperties int… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.2-batch-intermine | 06:21 (10.4h) | - \| intermine: convert all build files to G… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.2-batch-sources | 07:16 (9.5h) | - \| testmine: convert build files to Gradle… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.2-gradle-76-flip | 10:27 (6.3h) | - \| build: root testReport tasks use the Gr… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.2-plugin-gradle7 | 05:06 (11.7h) | - \| build(plugin): lazy tasks, no init task… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.3-catalog-modules | 11:52 (4.9h) | - \| docs: describe the version catalog; the… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.3-gradle-814-flip | 13:27 (3.3h) | - \| build(plugin): addStrutsConfig no longe… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.3-plugin-gradle8 | 11:34 (5.2h) | - \| merge: maint-2026 (ROOTS+TESTRES batch)… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.3-roots-testres | 11:09 (5.6h) | - \| build: version catalog gradle/libs.vers… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-ee7.4-jdk17 | 16:44 (3m) | - \| ci, docs: CI on JDK {8, 17} x PostgreSQ… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-jqz.1-jdbc-jackson | 03:31 (13.3h) | - \| deps: drop duplicate commons-math3 3.0 … |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-jqz.4-tier2-cves | 16:34 (13m) | - \| Merge maint/im-jqz.25-webapp-libs: no l… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-jqz.7-weak-deps | 05:51 (10.9h) | - \| deps: remove orphan vendored bobo-brows… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-jqz.8-flaky-tests | 07:24 (9.4h) | - \| integrate: make DataTracker.clear() saf… |
| intermine | 4 (im-ee7.4-jdk17, im-jqz.4-tier2-cv…, merge-maint-2026) | maint/im-rkn.3-baseline | 06-12 11:01 (156d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 2 (im-7os.23-humanmi…) | maint-2026 | 16:43 (4m) | ahead 73 vs dev \| deps: pin im-tables 782b448 (highlight.… |
| bluegenes | 2 (im-7os.23-humanmi…) | maint/im-28e.2-cypress-13 | 11:09 (5.6h) | - \| docs, cypress: how to run the suite; ta… |
| bluegenes | 2 (im-7os.23-humanmi…) | maint/im-28e.3-gh-actions | 05:31 (11.3h) | - \| docs: CI badge and Continuous integrati… |
| bluegenes | 2 (im-7os.23-humanmi…) | maint/im-7os.1-shadow-cljs | 05:17 (11.5h) | - \| comments: drop stale lein/figwheel refe… |
| bluegenes | 2 (im-7os.23-humanmi…) | maint/im-7os.10-npm-advisories | 11:58 (4.8h) | - \| deps: override qs to 6.17.1 (same major… |
| bluegenes | 2 (im-7os.23-humanmi…) | maint/im-7os.18-sibling-deps | 12:49 (4.0h) | - \| docs: how the sibling libraries are pin… |
| bluegenes | 2 (im-7os.23-humanmi…) | maint/im-7os.23-humanmine-default | 16:43 (4m) | - \| deps: pin im-tables 782b448 (highlight.… |
| bluegenes | 2 (im-7os.23-humanmi…) | maint/im-7os.4-cdn-sri | 11:48 (5.0h) | - \| script: cdn-sri.sh prints SRI hashes fo… |
| bluegenes | 2 (im-7os.23-humanmi…) | maint/im-7os.5-removals | 02:59 (13.8h) | - \| npm: remove unused clipboardy [im-7os.5] |
| bluegenes | 2 (im-7os.23-humanmi…) | maint/im-89g.5-ci-actions | 09:55 (6.9h) | - \| ci: bump GitHub Actions to current majo… |
| bluegenes | 2 (im-7os.23-humanmi…) | maint/im-rkn.4-baseline | 01-26 21:58 (657d) | - \| dynamic favicon slows down dx |
| imcljs | 1 | maint-2026 | 02:46 (14.0h) | ahead 8 vs dev \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| imcljs | 1 | maint/im-7os.3-imcljs-deps-edn | 02:46 (14.0h) | - \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| im-tables-3 | 2 (im-7os.23-humanmi…) | maint-2026 | 16:43 (4m) | ahead 19 vs dev \| Merge maint/im-7os.15-hljs11: highlight… |
| im-tables-3 | 2 (im-7os.23-humanmi…) | maint/im-7os.23-humanmine-default | 16:43 (4m) | - \| Merge maint/im-7os.15-hljs11: highlight… |
| im-tables-3 | 2 (im-7os.23-humanmi…) | maint/im-7os.3-im-tables-deps-edn | 12:05 (4.7h) | - \| test: lein kaocha honours IM_TABLES_SER… |
| bluegenes-tool-store | 1 | maint-2026 | 09:48 (7.0h) | ahead 8 vs master \| deps: bump commons-compress 1.19 -> 1.2… |
| bluegenes-tool-store | 1 | maint/im-7os.3-tool-store-deps-edn | 02:33 (14.2h) | - \| deps: remove unused ring/ring-defaults … |
| bluegenes-tool-store | 1 | maint/im-7os.6-tool-store-fixes | 09:48 (7.0h) | - \| deps: bump commons-compress 1.19 -> 1.2… |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

| Start | Bead | Agent | Model | In | Cache | Out | Outcome | Notes |
|---|---|---|---|---|---|---|---|---|
| 15:55 | im-jqz.25 | webapp libs: log4j 2.5 out,… | sonnet | 134 | 5.89M | 42.7k | success | 3 commits for im-jqz.25/26/11; clean ga… |
| 15:04 | im-ee7.24 | jar hygiene: credentials ou… | sonnet | 134 | 7.75M | 55.6k | success | 5 commits for im-ee7.24/39/35; clean ga… |
| 14:47 | im-7os.15 | highlight.js 9 -> 11 (blueg… | sonnet | 146 | 7.70M | 42.3k | success | im-tables 2ba1e6c, bluegenes 7ac90064; … |
| 13:31 | im-jqz.3 | C3 commons-*, ant, org.json… | sonnet | 178 | 10.92M | 58.0k | success | 7 commits; beanutils+codec removed, col… |
| 13:30 | im-ee7.4 | B4 JDK 17 build and tests; … | opus | 356 | 35.34M | 123.4k | success | 7 commits; gates PASS on JDK 8/17/21 wi… |
| 13:22 | im-ore.2 | G2 mine-tests local mine en… | sonnet | 72 | 2.83M | 26.8k | success | 4 commits; local service 13/2/13, brows… |
| 13:11 | im-ee7.34 | 5.1.1 candidate plugin on G… | sonnet | 74 | 2.57M | 16.5k | success | works on 4.9 and 6.9.4 (configure + tas… |
| 12:51 | im-7os.2 | E2 bluegenes+im-tables libr… | opus | 382 | 40.91M | 98.8k | success | 9 bluegenes + 4 im-tables commits; Reac… |
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

Showing the 20 most recent of 56 runs.
