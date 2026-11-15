# STATUS 2026-11-15 22:03 UTC

Generated 2026-11-15 22:03 UTC / 2026-11-15 22:03 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 4 running, 0 stalled, 67 finished.

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-1 | running | 11-14 22:38 | 22:03 | 16.1k | 161.90M | 580.0k |
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
| C4 Tier 2 CVE check: bcprov, oltu, JOpenId,… | sonnet-5-5 | finished | 16:46 | 17:36 | 118 | 5.40M | 36.0k |
| HumanMine as default test mine | sonnet-5-5 | finished | 16:48 | 17:09 | 120 | 5.65M | 38.8k |
| R7 checkstyle 7.8.1 to 10.x, delete bridge | sonnet-5-5 | finished | 17:08 | 17:41 | 118 | 5.14M | 35.7k |
| Fix missing window.React for BlueGenes tools | sonnet-5-5 | finished | 17:11 | 17:34 | 112 | 4.06M | 23.4k |
| Bundle imjs global for BlueGenes tools | sonnet-5-5 | finished | 17:35 | 17:52 | 102 | 3.96M | 29.7k |
| C6 JUnit 4.13.2, xmlunit, mocks, vendored j… | sonnet-5-5 | finished | 17:37 | 18:49 | 190 | 12.19M | 60.3k |
| F4 Cypress specs for the demo mine | sonnet-5-5 | finished | 17:54 | 20:16 | 462 | 54.91M | 164.6k |
| B5 deployer migration: humanmine, flymine, … | sonnet-5-5 | finished | 17:59 | 18:43 | 226 | 17.65M | 99.4k |
| Plugin deployer fixes: webtasks POM, SO pat… | sonnet-5-5 | finished | 18:49 | 19:37 | 204 | 16.14M | 83.7k |
| commons-lang 2.6 to lang3 migration | sonnet-5-5 | finished | 18:52 | 19:39 | 192 | 10.79M | 59.2k |
| Backport security fixes to 5.1.1 candidate | sonnet-5-5 | finished | 19:41 | 20:38 | 124 | 6.38M | 42.2k |
| Deployer re-check on new plugin: humanmine,… | sonnet-5-5 | finished | 19:57 | 20:15 | 112 | 5.77M | 37.6k |
| BlueGenes P1 bugs: ids case, search submit | sonnet-5-5 | finished | 20:18 | 21:53 | 268 | 22.84M | 94.5k |
| Siblings: imcljs pin for im-tables and tool… | sonnet-5-5 | finished | 20:19 | 20:24 | 38 | 1.31M | 16.1k |
| Testbed: 5.1.1 candidate stack + smoke tests | sonnet-5-5 | running | 20:40 | 22:00 | 32 | 956.0k | 9.4k |
| BlueGenes controlled inputs fix | opus-5-5 | running | 21:56 | 22:02 | 68 | 2.32M | 19.2k |
| intermine docs final pass | sonnet-5-5 | running | 21:57 | 22:03 | 82 | 4.96M | 23.0k |
| Testbed: 5.1.1 stack relaunch + smoke | sonnet-5-5 | running | 22:01 | 22:03 | 46 | 1.25M | 7.3k |

Note: 195 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-1 | 625 | 16.1k | 160.52M | 1.38M | 580.0k |
| subagents | opus-5-5 | 2175 | 4.3k | 374.37M | 16.68M | 1.69M |
| subagents | sonnet-5-5 | 3010 | 6.0k | 376.01M | 18.48M | 2.30M |

Tokens are de-duplicated per API message (streamed records share one message id).

## Beads summary

bd status: total 189, open 94, in progress 10, blocked 0, ready 94, deferred 0, closed 85.

| Status | Count |
|---|---|
| closed | 85 |
| in_progress | 10 |
| open | 94 |

### By priority (tasks and bugs; epics counted apart)

| Priority | open | in progress | blocked | deferred | closed | total | closed % | epics |
|---|---|---|---|---|---|---|---|---|
| P0 | 0 | 1 | 0 | 0 | 14 | 15 | 93% | 2 |
| P1 | 5 | 4 | 0 | 0 | 40 | 49 | 82% | 5 |
| P2 | 46 | 5 | 0 | 0 | 29 | 80 | 36% | 2 |
| P3 | 34 | 0 | 0 | 0 | 2 | 36 | 6% | 0 |
| all | 85 | 10 | 0 | 0 | 85 | 180 | 47% | 9 |

### im-28e Epic F: BlueGenes tests and CI [open, 5/9 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-28e.3 | F3 GitHub Actions for bluegenes (cljfmt, kaocha, … | in_progress | 2 | epic |
| im-28e.6 | bluegenes cypress: user_account_test.js has 4 ups… | open | 2 | bluegenes,epic,tests |
| im-28e.7 | bluegenes: enable nightly-cypress.yml with npm ru… | open | 2 | bluegenes,ci,epic |
| im-28e.8 | tests: default public mine is HumanMine (Gos): im… | open | 2 | bluegenes,epic,im-tables,tests |

### im-7os Epic E: BlueGenes toolchain modernisation [open, 19/39 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.33 | HUMAN (Gos): release imcljs 1.7.0, im-tables 0.16… | open | 1 | epic |
| im-7os.35 | bluegenes: ~90 remaining reagent controlled input… | in_progress | 1 | epic |
| im-7os.11 | tool-store: delete-dir uses string/starts-with? o… | open | 2 | epic,followup,tool-store |
| im-7os.13 | bluegenes nav.cljs loads the logo from dead cdn.r… | open | 2 | bluegenes,epic |
| im-7os.22 | bluegenes/im-tables: test the new browser date in… | open | 2 | epic |
| im-7os.26 | Decision for Gos: switch BlueGenes product defaul… | open | 2 | epic |
| im-7os.28 | bluegenes: jQuery 3.1.0 still loaded from code.jq… | open | 2 | epic |
| im-7os.32 | [bug] bluegenes: chromosome chart throws unhandle… | open | 2 | epic |
| im-7os.34 | bluegenes: bump the tool-store pin to 1029320 and… | open | 2 | epic |
| im-7os.36 | bluegenes gate-bluegenes.sh: also run 'npm run te… | open | 2 | epic |
| im-7os.37 | bluegenes dev build (shadow-cljs compile app) fai… | open | 2 | epic |
| im-7os.12 | tool-store: clj-http 'Invalid cookie header' warn… | open | 3 | epic,followup,tool-store |
| im-7os.14 | bluegenes viz/cases.cljs uses deprecated vega-lit… | open | 3 | bluegenes,epic |
| im-7os.16 | bluegenes dev advisories needing majors: Cypress … | open | 3 | bluegenes,epic,security |
| im-7os.20 | bluegenes: replace 11 uses of deprecated reagent.… | open | 3 | epic |
| im-7os.21 | im-tables: drop cljs-time (single use in error.cl… | open | 3 | epic |
| im-7os.23 | im-tables codegen: pass an explicit language-<nam… | open | 3 | epic |
| im-7os.29 | bluegenes: imjs 4.0.0 unmaintained since 2020 (no… | open | 3 | epic |
| im-7os.38 | bluegenes profile page: preferences response over… | open | 3 | epic |
| im-7os.39 | bluegenes lists: default list name has 1-second r… | open | 3 | epic |

### im-89g Epic D: intermine CI and release pipeline [open, 6/12 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-89g.12 | 5.1.1 candidate ecabf7f66c: re-verify a Gradle 4.… | in_progress | 1 | epic |
| im-89g.7 | D3 follow-up: test real Central Portal upload (ce… | open | 1 | epic,followup,human,intermine |
| im-89g.10 | release 6.0.0: change humanmine/flymine fork pins… | open | 2 | epic |
| im-89g.6 | D3 follow-up: drop legacy-runtime fix-up in confi… | open | 2 | epic,followup,intermine |
| im-89g.8 | intermine CI: config/ci-bio.properties names data… | open | 2 | ci,epic,intermine |
| im-89g.9 | intermine: central-bundle.gradle header says <bui… | open | 3 | docs,epic,intermine |

### im-8dd Epic I: Planning repo, beads, dashboard [open, 3/8 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-8dd.2 | I2 Dashboard generator (STATUS.md, index.html) an… | in_progress | 0 | epic |
| im-8dd.5 | I5 Sprint report for renewal decision (tokens/tim… | in_progress | 1 | epic |
| im-8dd.7 | gate/testenv: task homes share ~/.gradle via syml… | open | 2 | epic |
| im-8dd.8 | sprint infra: worker agents hang for ever when a … | open | 2 | epic |
| im-8dd.6 | gate-intermine.sh counts javac 'deprecated' lines… | open | 3 | epic |

### im-bdy Epic H: Docs and governance [open, 1/3 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-bdy.3 | H1 intermine docs: building, local testing, upgra… | in_progress | 2 | epic |
| im-bdy.4 | intermine README: depsy.org badge likely dead; de… | open | 3 | docs,epic,intermine |

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 29/53 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.10 | B5 deployer guide: deployers must delete stopExec… | in_progress | 2 | epic |
| im-ee7.12 | intermine plugin: runtime-resources dir so test-o… | open | 2 | epic |
| im-ee7.13 | bio/model: mergeModels edits processResources out… | open | 2 | epic |
| im-ee7.14 | plugin/build.gradle: maven -> maven-publish, clas… | open | 2 | epic |
| im-ee7.19 | intermine: jsonassert declared api in model but o… | open | 2 | epic |
| im-ee7.20 | bio/sources psi-complexes: chebiWS-client-2.4.jar… | open | 2 | epic |
| im-ee7.21 | bio/sources delimited: biojava-core declared but … | open | 2 | epic |
| im-ee7.23 | D3 follow-up: confirm bio/sources POM scope chang… | in_progress | 2 | deployer,epic,followup,intermine |
| im-ee7.27 | intermine: sourcesJar in objectstore and pathquer… | open | 2 | epic,gradle,intermine |
| im-ee7.28 | testmine :webapp:war alone fails in mergeProperti… | open | 2 | epic,gradle,intermine |
| im-ee7.36 | plugin: Ant task logging lost under Gradle 7 (log… | open | 2 | epic,gradle,intermine |
| im-ee7.38 | docs/UPGRADING-build.md: 5.1.1 verified on a Grad… | in_progress | 2 | deployer,docs,epic,intermine |
| im-ee7.49 | deployer sources: convert intermine/humanmine-bio… | open | 2 | epic |
| im-ee7.51 | plugin: add Gradle TestKit tests for unwarBioWebA… | open | 2 | epic |
| im-ee7.6 | intermine plugin: tasks without declared outputs … | open | 2 | epic |
| im-ee7.8 | intermine: test-only files leak into bio-source/p… | open | 2 | epic |
| im-ee7.31 | intermine/testresources/.gitignore still ignores … | open | 3 | epic,intermine |
| im-ee7.32 | plugin addStrutsConfig hard-codes build/resources… | open | 3 | epic,gradle,intermine |
| im-ee7.33 | intermine: move org.intermine:* imVersion coordin… | open | 3 | epic,gradle,intermine |
| im-ee7.40 | intermine: buildscript blocks can read the catalo… | open | 3 | epic,gradle,intermine |
| im-ee7.42 | mine template / deployer guide: drop commons-logg… | open | 3 | epic |
| im-ee7.43 | intermine: remove the com.sun.xml.internal proper… | open | 3 | epic |
| im-ee7.44 | testmine Cargo writes Tomcat config to /tmp/cargo… | open | 3 | epic |
| im-ee7.45 | intermine checkstyle 9.3: @throws-per-checked-exc… | open | 3 | epic |

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 11/36 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.21 | intermine: commons-beanutils 1.9.4 -> 1.11.0 (cle… | open | 1 | epic |
| im-jqz.22 | intermine: runtime smoke test of Struts multipart… | in_progress | 1 | epic |
| im-jqz.10 | intermine: HikariCP 5.x once JDK 11+ baseline lan… | open | 2 | epic |
| im-jqz.12 | sandbox: Postgres max_connections=100 nearly exha… | open | 2 | epic |
| im-jqz.19 | bio/sources/psi-complexes now mixes jami-core 3.2… | open | 2 | bio-sources,epic,intermine |
| im-jqz.28 | intermine webapp: registry lookup in SemanticMark… | open | 2 | epic |
| im-jqz.29 | intermine: replace cglib 3.1 (needs --add-opens j… | open | 2 | epic |
| im-jqz.31 | intermine webapp web.xml: DwrServlet runs with de… | open | 2 | epic |
| im-jqz.32 | intermine: replace torque-3.2-dev, torque-gen-3.2… | open | 2 | epic |
| im-jqz.35 | Decision for Gos: commons-lang 2.6 reaches a mine… | open | 2 | epic |
| im-jqz.36 | [bug] intermine webservice: DELETE /service/user … | open | 2 | epic |
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
| im-jqz.33 | psi-complexes: restore small-molecule names via C… | open | 3 | epic |
| im-jqz.34 | intermine: exclude commons-lang 2.6 from solr-sol… | open | 3 | epic |

### im-ore Epic G: Whole-system testbed [open, 4/10 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ore.3 | rdfc2im: make --use-cached-data fully offline (en… | open | 1 | epic,rdfc2im,testbed |
| im-ore.10 | rdfc2im demo mine data: Organism.name/shortName n… | open | 2 | epic |
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
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint-2026 | 20:15 (1.8h) | ahead 145 vs dev \| Merge maint/im-ee7.53-deployer-recheck:… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-89g.1-ci-actions | 04:45 (17.3h) | - \| docs: update README badges, PR template… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-89g.1-ci-fix | 06:28 (15.6h) | - \| ci: stop using sudo -E -u postgres; con… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-89g.1-ci-fix2 | 06:54 (15.1h) | - \| ci: fix PostgreSQL 15+ public schema pr… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-89g.3-maven-publish | 09:40 (12.4h) | - \| docs: add RELEASING.md (version bump, b… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-89g.5-ci-actions | 09:55 (12.1h) | - \| ci: bump GitHub Actions to current majo… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-bdy.3-docs | 20:15 (1.8h) | - \| Merge maint/im-ee7.53-deployer-recheck:… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-ee7.1-gradle-6 | 03:57 (18.1h) | - \| build: default to Gradle 6.9.4 and veri… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-ee7.2-batch-bio | 09:32 (12.5h) | - \| build(bio): fold copyMineProperties int… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-ee7.2-batch-intermine | 06:21 (15.7h) | - \| intermine: convert all build files to G… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-ee7.2-batch-sources | 07:16 (14.8h) | - \| testmine: convert build files to Gradle… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-ee7.2-gradle-76-flip | 10:27 (11.6h) | - \| build: root testReport tasks use the Gr… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-ee7.2-plugin-gradle7 | 05:06 (16.9h) | - \| build(plugin): lazy tasks, no init task… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-ee7.3-catalog-modules | 11:52 (10.2h) | - \| docs: describe the version catalog; the… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-ee7.3-gradle-814-flip | 13:27 (8.6h) | - \| build(plugin): addStrutsConfig no longe… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-ee7.3-plugin-gradle8 | 11:34 (10.5h) | - \| merge: maint-2026 (ROOTS+TESTRES batch)… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-ee7.3-roots-testres | 11:09 (10.9h) | - \| build: version catalog gradle/libs.vers… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-jqz.1-jdbc-jackson | 03:31 (18.5h) | - \| deps: drop duplicate commons-math3 3.0 … |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-jqz.7-weak-deps | 05:51 (16.2h) | - \| deps: remove orphan vendored bobo-brows… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-jqz.8-flaky-tests | 07:24 (14.7h) | - \| integrate: make DataTracker.clear() saf… |
| intermine | 4 (im-89g.12-511-tes…, im-bdy.3-docs, merge-maint-2026) | maint/im-rkn.3-baseline | 06-12 11:01 (156d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 2 (im-7os.35-control…) | maint-2026 | 21:54 (9m) | ahead 91 vs dev \| Merge maint/im-7os.33-p1-bugs: ids case… |
| bluegenes | 2 (im-7os.35-control…) | maint/im-28e.2-cypress-13 | 11:09 (10.9h) | - \| docs, cypress: how to run the suite; ta… |
| bluegenes | 2 (im-7os.35-control…) | maint/im-28e.3-gh-actions | 05:31 (16.5h) | - \| docs: CI badge and Continuous integrati… |
| bluegenes | 2 (im-7os.35-control…) | maint/im-7os.1-shadow-cljs | 05:17 (16.8h) | - \| comments: drop stale lein/figwheel refe… |
| bluegenes | 2 (im-7os.35-control…) | maint/im-7os.10-npm-advisories | 11:58 (10.1h) | - \| deps: override qs to 6.17.1 (same major… |
| bluegenes | 2 (im-7os.35-control…) | maint/im-7os.18-sibling-deps | 12:49 (9.2h) | - \| docs: how the sibling libraries are pin… |
| bluegenes | 2 (im-7os.35-control…) | maint/im-7os.35-controlled-inputs | 21:54 (9m) | - \| Merge maint/im-7os.33-p1-bugs: ids case… |
| bluegenes | 2 (im-7os.35-control…) | maint/im-7os.4-cdn-sri | 11:48 (10.2h) | - \| script: cdn-sri.sh prints SRI hashes fo… |
| bluegenes | 2 (im-7os.35-control…) | maint/im-7os.5-removals | 02:59 (19.1h) | - \| npm: remove unused clipboardy [im-7os.5] |
| bluegenes | 2 (im-7os.35-control…) | maint/im-89g.5-ci-actions | 09:55 (12.1h) | - \| ci: bump GitHub Actions to current majo… |
| bluegenes | 2 (im-7os.35-control…) | maint/im-rkn.4-baseline | 01-26 21:58 (658d) | - \| dynamic favicon slows down dx |
| imcljs | 1 | maint-2026 | 02:46 (19.3h) | ahead 8 vs dev \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| imcljs | 1 | maint/im-7os.3-imcljs-deps-edn | 02:46 (19.3h) | - \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| im-tables-3 | 1 | maint-2026 | 20:24 (1.6h) | ahead 23 vs dev \| Merge maint/im-7os.19-imcljs-pin: imclj… |
| im-tables-3 | 1 | maint/im-7os.3-im-tables-deps-edn | 12:05 (10.0h) | - \| test: lein kaocha honours IM_TABLES_SER… |
| bluegenes-tool-store | 1 | maint-2026 | 20:24 (1.6h) | ahead 10 vs master \| Merge maint/im-7os.19-imcljs-pin: imclj… |
| bluegenes-tool-store | 1 | maint/im-7os.3-tool-store-deps-edn | 02:33 (19.5h) | - \| deps: remove unused ring/ring-defaults … |
| bluegenes-tool-store | 1 | maint/im-7os.6-tool-store-fixes | 09:48 (12.2h) | - \| deps: bump commons-compress 1.19 -> 1.2… |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

| Start | Bead | Agent | Model | In | Cache | Out | Outcome | Notes |
|---|---|---|---|---|---|---|---|---|
| 20:40 | im-89g.12 | Testbed: 5.1.1 candidate ut… | sonnet | 32 | 956.0k | 9.4k | killed | Hung 78 min in one Bash call (relative-… |
| 20:19 | im-7os.19 | siblings imcljs git-sha pin… | sonnet | 38 | 1.31M | 16.1k | success | im-tables 1ec5e81, tool-store 2ed02b3; … |
| 20:18 | im-7os.31 | BlueGenes P1 bugs: ids case… | opus | 268 | 22.84M | 94.5k | success | 3 commits merged as bluegenes 79077194;… |
| 19:57 | im-ee7.53 | deployer re-check on the fi… | sonnet | 112 | 5.77M | 37.6k | success | humanmine 11e942a, flymine d01940b9, in… |
| 19:41 | im-89g.11 | 5.1.1 candidate backports (… | sonnet | 124 | 6.38M | 42.2k | success | credentials out of jars, log4j2 exclude… |
| 18:52 | im-jqz.20 | commons-lang 2.6 -> lang3 3… | sonnet | 192 | 10.79M | 59.2k | success | 5 commits; XmlUtil.escapeXml keeps 2.6 … |
| 18:49 | im-ee7.46 | plugin deployer fixes: webt… | sonnet | 204 | 16.14M | 83.7k | success | 4 commits; webapp classes jar in POMs (… |
| 17:59 | im-ee7.5 | B5 deployer migration: huma… | sonnet | 226 | 17.65M | 99.4k | success | intermine 6c15f0c750 docs; humanmine 01… |
| 17:54 | im-28e.5 | F4 Cypress specs and fixtur… | sonnet | 462 | 54.91M | 164.6k | success | 7 commits; 159 tests: 136 pass, 0 fail,… |
| 17:37 | im-jqz.6 | C6 JUnit 4.13.2, EasyMock 5… | sonnet | 190 | 12.19M | 60.3k | success | 9 commits; mockobjects/mockrunner/strin… |
| 17:35 | im-7os.27 | window.imjs for tools (bund… | sonnet | 102 | 3.96M | 29.7k | success | 22971a08; vetted imjs 4.0.0; xmldom ove… |
| 17:11 | im-7os.25 | window.React/ReactDOM globa… | sonnet | 112 | 4.06M | 23.4k | success | f19dd6e4; gate PASS; @external report t… |
| 17:08 | im-ee7.26 | R7 checkstyle 7.8.1 -> 9.3,… | sonnet | 118 | 5.14M | 35.7k | success | 3 commits; plain Gradle checkstyle plug… |
| 16:48 | im-7os.24 | HumanMine as default test m… | sonnet | 120 | 5.65M | 38.8k | success | im-tables a83c053, bluegenes f098dd32; … |
| 16:46 | im-jqz.4 | C4 Tier 2 CVE check: bcprov… | sonnet | 118 | 5.40M | 36.0k | success | 4 commits; bcprov removed (JDK-only cer… |
| 15:55 | im-jqz.25 | webapp libs: log4j 2.5 out,… | sonnet | 134 | 5.89M | 42.7k | success | 3 commits for im-jqz.25/26/11; clean ga… |
| 15:04 | im-ee7.24 | jar hygiene: credentials ou… | sonnet | 134 | 7.75M | 55.6k | success | 5 commits for im-ee7.24/39/35; clean ga… |
| 14:47 | im-7os.15 | highlight.js 9 -> 11 (blueg… | sonnet | 146 | 7.70M | 42.3k | success | im-tables 2ba1e6c, bluegenes 7ac90064; … |
| 13:31 | im-jqz.3 | C3 commons-*, ant, org.json… | sonnet | 178 | 10.92M | 58.0k | success | 7 commits; beanutils+codec removed, col… |
| 13:30 | im-ee7.4 | B4 JDK 17 build and tests; … | opus | 356 | 35.34M | 123.4k | success | 7 commits; gates PASS on JDK 8/17/21 wi… |

Showing the 20 most recent of 71 runs.
