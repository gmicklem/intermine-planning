# STATUS 2026-11-16 00:00 UTC

Generated 2026-11-16 00:00 UTC / 2026-11-16 00:00 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 2 running, 2 stalled, 76 finished.

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-1 | running | 11-14 22:38 | 11-15 23:59 | 18.6k | 184.72M | 659.7k |
| Survey intermine build/test state | opus-5-5 | finished | 11-15 00:18 | 11-15 00:20 | 42 | 1.05M | 9.0k |
| Survey bluegenes build/test state | opus-5-5 | finished | 11-15 00:18 | 11-15 00:20 | 22 | 347.5k | 8.3k |
| Survey rdfc2im, docker_template, mine-tests… | opus-5-5 | finished | 11-15 00:18 | 11-15 00:21 | 26 | 863.6k | 7.5k |
| intermine dependency census and CVE invento… | sonnet-5-5 | finished | 11-15 01:47 | 11-15 02:07 | 182 | 16.47M | 133.5k |
| bluegenes dependency census and inventory | sonnet-5-5 | finished | 11-15 01:47 | 11-15 02:04 | 162 | 12.90M | 113.7k |
| Write dashboard generator script | sonnet-5-5 | finished | 11-15 01:48 | 11-15 01:50 | 28 | 807.1k | 22.9k |
| Split master plan into per-area plan docs | sonnet-5-5 | finished | 11-15 01:48 | 11-15 01:49 | 10 | 238.7k | 15.2k |
| A3 intermine baseline build and tests | opus-5-5 | finished | 11-15 01:51 | 11-15 02:44 | 206 | 14.29M | 77.7k |
| A4 bluegenes baseline build and tests | sonnet-5-5 | finished | 11-15 01:51 | 11-15 02:23 | 164 | 7.26M | 55.7k |
| Gradle upgrade path design for intermine | opus-5-5 | finished | 11-15 01:54 | 11-15 02:18 | 168 | 15.81M | 132.1k |
| shadow-cljs migration design for BlueGenes | opus-5-5 | finished | 11-15 01:55 | 11-15 02:10 | 126 | 7.05M | 89.0k |
| Write decision records from the plan | sonnet-5-5 | finished | 11-15 01:55 | 11-15 01:56 | 14 | 365.6k | 10.9k |
| bluegenes weak-dependency removals | sonnet-5-5 | finished | 11-15 02:24 | 11-15 03:02 | 100 | 3.83M | 25.6k |
| imcljs to deps.edn and shadow-cljs | sonnet-5-5 | finished | 11-15 02:25 | 11-15 02:47 | 122 | 7.56M | 53.9k |
| bluegenes-tool-store to deps.edn | sonnet-5-5 | finished | 11-15 02:25 | 11-15 02:36 | 66 | 3.37M | 32.2k |
| B1 Gradle 4.9 to 6.9.4 for intermine | opus-5-5 | finished | 11-15 02:45 | 11-15 04:01 | 208 | 16.97M | 71.3k |
| C1+C2 intermine JDBC, Hikari, Jackson bumps | sonnet-5-5 | finished | 11-15 02:46 | 11-15 03:32 | 88 | 3.70M | 23.1k |
| C7 intermine weak-dependency removals | sonnet-5-5 | finished | 11-15 02:46 | 11-15 05:52 | 206 | 12.20M | 51.7k |
| E1 bluegenes shadow-cljs build migration | opus-5-5 | finished | 11-15 03:03 | 11-15 05:22 | 498 | 77.69M | 223.4k |
| im-tables-3 to deps.edn and shadow-cljs | sonnet-5-5 | finished | 11-15 03:33 | 11-15 04:23 | 162 | 12.96M | 79.2k |
| B2 batch P: plugin rewrite for Gradle 7 | opus-5-5 | finished | 11-15 04:16 | 11-15 05:07 | 202 | 23.89M | 151.4k |
| D1+D2 intermine GitHub Actions and dependab… | sonnet-5-5 | finished | 11-15 04:16 | 11-15 06:54 | 172 | 10.09M | 66.6k |
| Review E1 bluegenes shadow-cljs branch | opus-5-5 | finished | 11-15 04:42 | 11-15 04:50 | 92 | 4.29M | 36.5k |
| F3 bluegenes GitHub Actions workflow | sonnet-5-5 | finished | 11-15 05:23 | 11-15 05:31 | 54 | 2.20M | 32.7k |
| D3 intermine maven-publish and Central Port… | sonnet-5-5 | finished | 11-15 05:24 | 11-15 09:40 | 260 | 25.10M | 106.6k |
| B2 batch I: intermine build files to Gradle… | sonnet-5-5 | finished | 11-15 06:00 | 11-15 06:35 | 164 | 11.43M | 71.2k |
| B2 batch B: bio build files to Gradle 7 con… | sonnet-5-5 | finished | 11-15 06:00 | 11-15 09:43 | 264 | 21.38M | 91.4k |
| B2 batch S: bio/sources and testmine build … | sonnet-5-5 | finished | 11-15 06:36 | 11-15 07:16 | 154 | 9.55M | 60.0k |
| Fix two flaky intermine test classes | opus-5-5 | finished | 11-15 07:04 | 11-15 07:31 | 112 | 5.52M | 37.5k |
| tool-store fixes im-7os.6-9 | sonnet-5-5 | finished | 11-15 09:44 | 11-15 09:48 | 32 | 836.1k | 13.0k |
| A5 rdfc2im testbed baseline | opus-5-5 | finished | 11-15 09:47 | 11-15 10:21 | 218 | 17.94M | 59.9k |
| B2 flip: intermine to Gradle 7.6 | opus-5-5 | finished | 11-15 09:51 | 11-15 10:30 | 250 | 18.88M | 86.0k |
| H1 intermine docs: build/test/upgrade | sonnet-5-5 | finished | 11-15 09:53 | 11-15 09:57 | 64 | 3.67M | 33.4k |
| CI actions major bumps both repos | sonnet-5-5 | finished | 11-15 09:54 | 11-15 09:55 | 24 | 610.7k | 5.9k |
| I5 sprint-report generator script | sonnet-5-5 | finished | 11-15 09:59 | 11-15 10:01 | 16 | 543.9k | 18.9k |
| F2 Cypress 13 migration for bluegenes | opus-5-5 | finished | 11-15 10:17 | 11-15 11:09 | 238 | 16.22M | 82.5k |
| B3 P3: plugin ready for Gradle 8/9 | opus-5-5 | finished | 11-15 10:34 | 11-15 11:36 | 168 | 12.51M | 44.2k |
| B3 ROOTS+TESTRES: root builds for Gradle 8 | opus-5-5 | finished | 11-15 10:34 | 11-15 11:09 | 108 | 6.62M | 38.0k |
| B3 CATALOG: module coords to version catalog | sonnet-5-5 | finished | 11-15 11:13 | 11-15 11:52 | 134 | 7.66M | 48.8k |
| E4 bluegenes CDN assets pinned with SRI | sonnet-5-5 | finished | 11-15 11:39 | 11-15 11:49 | 54 | 1.73M | 21.7k |
| im-tables gate against local demo mine | opus-5-5 | finished | 11-15 11:51 | 11-15 12:05 | 88 | 3.62M | 29.0k |
| bluegenes npm dev advisories | sonnet-5-5 | finished | 11-15 11:51 | 11-15 11:59 | 42 | 1.01M | 8.6k |
| B3 3b: flip intermine to Gradle 8.14.6 | opus-5-5 | finished | 11-15 11:54 | 11-15 13:28 | 370 | 33.21M | 100.4k |
| G1 rdfc2im build from local intermine artef… | opus-5-5 | finished | 11-15 12:01 | 11-15 13:08 | 254 | 26.91M | 120.8k |
| S5 bluegenes on sibling git deps | opus-5-5 | finished | 11-15 12:07 | 11-15 12:49 | 148 | 8.78M | 41.2k |
| E2 BlueGenes + im-tables library bumps | opus-5-5 | finished | 11-15 12:51 | 11-15 14:34 | 382 | 40.91M | 98.8k |
| Check 5.1.1 candidate plugin on Gradle 4.9 | sonnet-5-5 | finished | 11-15 13:11 | 11-15 13:21 | 74 | 2.57M | 16.5k |
| G2 mine-tests local demo mine fixtures | sonnet-5-5 | finished | 11-15 13:22 | 11-15 13:30 | 72 | 2.83M | 26.8k |
| B4 intermine on JDK 17 (and 21) | opus-5-5 | finished | 11-15 13:30 | 11-15 16:45 | 356 | 35.34M | 123.4k |
| C3 commons, ant, org.json cleanup | sonnet-5-5 | finished | 11-15 13:31 | 11-15 15:02 | 178 | 10.92M | 58.0k |
| E-hljs: highlight.js 9 to 11 | sonnet-5-5 | finished | 11-15 14:47 | 11-15 16:43 | 146 | 7.70M | 42.3k |
| Jar hygiene: credentials, duplicate libs | sonnet-5-5 | finished | 11-15 15:04 | 11-15 15:54 | 134 | 7.75M | 55.6k |
| Webapp libs: log4j 2.5, stale jars, Jersey | sonnet-5-5 | finished | 11-15 15:55 | 11-15 16:32 | 134 | 5.89M | 42.7k |
| C4 Tier 2 CVE check: bcprov, oltu, JOpenId,… | sonnet-5-5 | finished | 11-15 16:46 | 11-15 17:36 | 118 | 5.40M | 36.0k |
| HumanMine as default test mine | sonnet-5-5 | finished | 11-15 16:48 | 11-15 17:09 | 120 | 5.65M | 38.8k |
| R7 checkstyle 7.8.1 to 10.x, delete bridge | sonnet-5-5 | finished | 11-15 17:08 | 11-15 17:41 | 118 | 5.14M | 35.7k |
| Fix missing window.React for BlueGenes tools | sonnet-5-5 | finished | 11-15 17:11 | 11-15 17:34 | 112 | 4.06M | 23.4k |
| Bundle imjs global for BlueGenes tools | sonnet-5-5 | finished | 11-15 17:35 | 11-15 17:52 | 102 | 3.96M | 29.7k |
| C6 JUnit 4.13.2, xmlunit, mocks, vendored j… | sonnet-5-5 | finished | 11-15 17:37 | 11-15 18:49 | 190 | 12.19M | 60.3k |
| F4 Cypress specs for the demo mine | sonnet-5-5 | finished | 11-15 17:54 | 11-15 20:16 | 462 | 54.91M | 164.6k |
| B5 deployer migration: humanmine, flymine, … | sonnet-5-5 | finished | 11-15 17:59 | 11-15 18:43 | 226 | 17.65M | 99.4k |
| Plugin deployer fixes: webtasks POM, SO pat… | sonnet-5-5 | finished | 11-15 18:49 | 11-15 19:37 | 204 | 16.14M | 83.7k |
| commons-lang 2.6 to lang3 migration | sonnet-5-5 | finished | 11-15 18:52 | 11-15 19:39 | 192 | 10.79M | 59.2k |
| Backport security fixes to 5.1.1 candidate | sonnet-5-5 | finished | 11-15 19:41 | 11-15 20:38 | 124 | 6.38M | 42.2k |
| Deployer re-check on new plugin: humanmine,… | sonnet-5-5 | finished | 11-15 19:57 | 11-15 20:15 | 112 | 5.77M | 37.6k |
| BlueGenes P1 bugs: ids case, search submit | sonnet-5-5 | finished | 11-15 20:18 | 11-15 21:53 | 268 | 22.84M | 94.5k |
| Siblings: imcljs pin for im-tables and tool… | sonnet-5-5 | finished | 11-15 20:19 | 11-15 20:24 | 38 | 1.31M | 16.1k |
| Testbed: 5.1.1 candidate stack + smoke tests | sonnet-5-5 | stalled 2.0h | 11-15 20:40 | 11-15 22:00 | 32 | 956.0k | 9.4k |
| BlueGenes controlled inputs fix | opus-5-5 | finished | 11-15 21:56 | 11-15 23:15 | 254 | 18.13M | 86.3k |
| intermine docs final pass | sonnet-5-5 | finished | 11-15 21:57 | 11-15 22:08 | 126 | 9.15M | 51.4k |
| Testbed: 5.1.1 stack relaunch + smoke | sonnet-5-5 | finished | 11-15 22:01 | 11-15 22:25 | 144 | 6.17M | 32.0k |
| 5.1.1 candidate deployer guide backport | sonnet-5-5 | finished | 11-15 22:10 | 11-15 22:15 | 62 | 2.92M | 28.3k |
| intermine CI bio DB name alignment | sonnet-5-5 | finished | 11-15 22:17 | 11-15 22:18 | 10 | 225.8k | 3.8k |
| beanutils 1.11.0 bump + Struts smoke | sonnet-5-5 | finished | 11-15 22:27 | 11-15 22:54 | 186 | 10.61M | 48.3k |
| intermine JSP EL reserved-word bugs | sonnet-5-5 | finished | 11-15 22:56 | 11-15 23:12 | 140 | 6.50M | 39.4k |
| 5.1.1 backport of JSP EL fixes | sonnet-5-5 | finished | 11-15 23:14 | 11-15 23:23 | 38 | 964.4k | 12.3k |
| BlueGenes CDN leftovers + sibling pins | sonnet-5-5 | finished | 11-15 23:17 | 11-15 23:46 | 92 | 3.55M | 19.1k |
| rdfc2im testbed fixes for maint-2026 | sonnet-5-5 | stalled 12m | 11-15 23:24 | 11-15 23:47 | 30 | 1.11M | 13.5k |
| rdfc2im testbed fixes for maint-2026 (retry) | sonnet-5-5 | running | 11-15 23:48 | 11-15 23:50 | 48 | 1.40M | 8.4k |
| BlueGenes nightly Cypress in GitHub Actions | opus-5-5 | running | 11-15 23:51 | 11-15 23:59 | 114 | 6.78M | 35.5k |

Note: 228 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-1 | 726 | 18.6k | 183.18M | 1.54M | 659.7k |
| subagents | opus-5-5 | 2325 | 4.7k | 396.22M | 17.42M | 1.79M |
| subagents | sonnet-5-5 | 3384 | 6.8k | 411.09M | 19.79M | 2.53M |

Tokens are de-duplicated per API message (streamed records share one message id).

## Beads summary

bd status: total 203, open 96, in progress 6, blocked 0, ready 96, deferred 0, closed 101.

| Status | Count |
|---|---|
| closed | 101 |
| in_progress | 6 |
| open | 96 |

### By priority (tasks and bugs; epics counted apart)

| Priority | open | in progress | blocked | deferred | closed | total | closed % | epics |
|---|---|---|---|---|---|---|---|---|
| P0 | 0 | 1 | 0 | 0 | 14 | 15 | 93% | 2 |
| P1 | 4 | 2 | 0 | 0 | 47 | 53 | 89% | 5 |
| P2 | 45 | 2 | 0 | 0 | 38 | 85 | 45% | 2 |
| P3 | 38 | 1 | 0 | 0 | 2 | 41 | 5% | 0 |
| all | 87 | 6 | 0 | 0 | 101 | 194 | 52% | 9 |

### im-28e Epic F: BlueGenes tests and CI [open, 6/9 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-28e.3 | F3 GitHub Actions for bluegenes (cljfmt, kaocha, … | in_progress | 2 | epic |
| im-28e.7 | bluegenes: enable nightly-cypress.yml with npm ru… | in_progress | 2 | bluegenes,ci,epic |
| im-28e.8 | tests: default public mine is HumanMine (Gos): im… | open | 2 | bluegenes,epic,im-tables,tests |

### im-7os Epic E: BlueGenes toolchain modernisation [open, 23/41 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.33 | HUMAN (Gos): release imcljs 1.7.0, im-tables 0.16… | open | 1 | epic |
| im-7os.11 | tool-store: delete-dir uses string/starts-with? o… | open | 2 | epic,followup,tool-store |
| im-7os.22 | bluegenes/im-tables: test the new browser date in… | open | 2 | epic |
| im-7os.26 | Decision for Gos: switch BlueGenes product defaul… | open | 2 | epic |
| im-7os.32 | [bug] bluegenes: chromosome chart throws unhandle… | open | 2 | epic |
| im-7os.36 | bluegenes gate-bluegenes.sh: also run 'npm run te… | open | 2 | epic |
| im-7os.37 | bluegenes dev build (shadow-cljs compile app) fai… | open | 2 | epic |
| im-7os.40 | im-tables: toolbar renders as static HTML until t… | open | 2 | epic |
| im-7os.12 | tool-store: clj-http 'Invalid cookie header' warn… | open | 3 | epic,followup,tool-store |
| im-7os.14 | bluegenes viz/cases.cljs uses deprecated vega-lit… | open | 3 | bluegenes,epic |
| im-7os.16 | bluegenes dev advisories needing majors: Cypress … | open | 3 | bluegenes,epic,security |
| im-7os.20 | bluegenes: replace 11 uses of deprecated reagent.… | open | 3 | epic |
| im-7os.21 | im-tables: drop cljs-time (single use in error.cl… | open | 3 | epic |
| im-7os.23 | im-tables codegen: pass an explicit language-<nam… | open | 3 | epic |
| im-7os.29 | bluegenes: imjs 4.0.0 unmaintained since 2020 (no… | open | 3 | epic |
| im-7os.38 | bluegenes profile page: preferences response over… | open | 3 | epic |
| im-7os.39 | bluegenes lists: default list name has 1-second r… | open | 3 | epic |
| im-7os.41 | bluegenes cypress: drop the remaining {delay:100}… | open | 3 | epic |

### im-89g Epic D: intermine CI and release pipeline [open, 10/17 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-89g.7 | D3 follow-up: test real Central Portal upload (ce… | open | 1 | epic,followup,human,intermine |
| im-89g.10 | release 6.0.0: change humanmine/flymine fork pins… | open | 2 | epic |
| im-89g.16 | mine war duplicates on the 5.1.1 line: ant-1.6.5 … | open | 2 | epic |
| im-89g.6 | D3 follow-up: drop legacy-runtime fix-up in confi… | open | 2 | epic,followup,intermine |
| im-89g.13 | intermine release checklist: plugin/build.gradle … | open | 3 | epic |
| im-89g.15 | intermine: the bio-fulldata-test objectstore is d… | open | 3 | epic |
| im-89g.9 | intermine: central-bundle.gradle header says <bui… | open | 3 | docs,epic,intermine |

### im-8dd Epic I: Planning repo, beads, dashboard [open, 3/8 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-8dd.2 | I2 Dashboard generator (STATUS.md, index.html) an… | in_progress | 0 | epic |
| im-8dd.5 | I5 Sprint report for renewal decision (tokens/tim… | in_progress | 1 | epic |
| im-8dd.7 | gate/testenv: task homes share ~/.gradle via syml… | open | 2 | epic |
| im-8dd.8 | sprint infra: worker agents hang for ever when a … | open | 2 | epic |
| im-8dd.6 | gate-intermine.sh counts javac 'deprecated' lines… | open | 3 | epic |

### im-bdy Epic H: Docs and governance [open, 2/4 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-bdy.5 | docs/UPGRADING-build.md: warn deployers that Tomc… | open | 2 | epic |
| im-bdy.4 | intermine README: depsy.org badge likely dead; de… | open | 3 | docs,epic,intermine |

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 31/53 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.12 | intermine plugin: runtime-resources dir so test-o… | open | 2 | epic |
| im-ee7.13 | bio/model: mergeModels edits processResources out… | open | 2 | epic |
| im-ee7.14 | plugin/build.gradle: maven -> maven-publish, clas… | open | 2 | epic |
| im-ee7.19 | intermine: jsonassert declared api in model but o… | open | 2 | epic |
| im-ee7.20 | bio/sources psi-complexes: chebiWS-client-2.4.jar… | open | 2 | epic |
| im-ee7.21 | bio/sources delimited: biojava-core declared but … | open | 2 | epic |
| im-ee7.23 | D3 follow-up: confirm bio/sources POM scope chang… | open | 2 | deployer,epic,followup,intermine |
| im-ee7.27 | intermine: sourcesJar in objectstore and pathquer… | open | 2 | epic,gradle,intermine |
| im-ee7.28 | testmine :webapp:war alone fails in mergeProperti… | open | 2 | epic,gradle,intermine |
| im-ee7.36 | plugin: Ant task logging lost under Gradle 7 (log… | open | 2 | epic,gradle,intermine |
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

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 15/40 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.10 | intermine: HikariCP 5.x once JDK 11+ baseline lan… | open | 2 | epic |
| im-jqz.12 | sandbox: Postgres max_connections=100 nearly exha… | open | 2 | epic |
| im-jqz.19 | bio/sources/psi-complexes now mixes jami-core 3.2… | open | 2 | bio-sources,epic,intermine |
| im-jqz.28 | intermine webapp: registry lookup in SemanticMark… | open | 2 | epic |
| im-jqz.29 | intermine: replace cglib 3.1 (needs --add-opens j… | open | 2 | epic |
| im-jqz.31 | intermine webapp web.xml: DwrServlet runs with de… | open | 2 | epic |
| im-jqz.32 | intermine: replace torque-3.2-dev, torque-gen-3.2… | open | 2 | epic |
| im-jqz.35 | Decision for Gos: commons-lang 2.6 reaches a mine… | open | 2 | epic |
| im-jqz.36 | [bug] intermine webservice: DELETE /service/user … | open | 2 | epic |
| im-jqz.39 | intermine webapp: WEB-INF/tags/abbreviate.tag fai… | open | 2 | epic |
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
| im-jqz.40 | intermine webapp: Tomcat logs 'Cannot deserialize… | open | 3 | epic |

### im-ore Epic G: Whole-system testbed [open, 4/12 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ore.14 | rdfc2im full-build.sh --intermine-src on maint-20… | in_progress | 1 | epic |
| im-ore.3 | rdfc2im: make --use-cached-data fully offline (en… | open | 1 | epic,rdfc2im,testbed |
| im-ore.10 | rdfc2im demo mine data: Organism.name/shortName n… | open | 2 | epic |
| im-ore.4 | rdfc2im: pass -Duser.home/GRADLE_USER_HOME explic… | open | 2 | epic,rdfc2im,testbed |
| im-ore.7 | rdfc2im follow-ups from G1: per-stack data dir in… | open | 2 | epic,rdfc2im,testbed |
| im-ore.8 | rdfc2im/BlueGenes stack: /favicon.ico redirects t… | open | 2 | bluegenes,epic,rdfc2im,testbed |
| im-ore.11 | testbed: mine-tests venv at /home/agent/venvs/min… | in_progress | 3 | epic |
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
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint-2026 | 11-15 23:13 (47m) | ahead 158 vs dev \| Merge maint/im-jqz.37-jsp-el: JSP EL no… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-89g.1-ci-actions | 11-15 04:45 (19.2h) | - \| docs: update README badges, PR template… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-89g.1-ci-fix | 11-15 06:28 (17.5h) | - \| ci: stop using sudo -E -u postgres; con… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-89g.1-ci-fix2 | 11-15 06:54 (17.1h) | - \| ci: fix PostgreSQL 15+ public schema pr… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-89g.3-maven-publish | 11-15 09:40 (14.3h) | - \| docs: add RELEASING.md (version bump, b… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-89g.5-ci-actions | 11-15 09:55 (14.1h) | - \| ci: bump GitHub Actions to current majo… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-ee7.1-gradle-6 | 11-15 03:57 (20.0h) | - \| build: default to Gradle 6.9.4 and veri… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-ee7.2-batch-bio | 11-15 09:32 (14.5h) | - \| build(bio): fold copyMineProperties int… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-ee7.2-batch-intermine | 11-15 06:21 (17.6h) | - \| intermine: convert all build files to G… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-ee7.2-batch-sources | 11-15 07:16 (16.7h) | - \| testmine: convert build files to Gradle… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-ee7.2-gradle-76-flip | 11-15 10:27 (13.5h) | - \| build: root testReport tasks use the Gr… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-ee7.2-plugin-gradle7 | 11-15 05:06 (18.9h) | - \| build(plugin): lazy tasks, no init task… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-ee7.3-catalog-modules | 11-15 11:52 (12.1h) | - \| docs: describe the version catalog; the… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-ee7.3-gradle-814-flip | 11-15 13:27 (10.5h) | - \| build(plugin): addStrutsConfig no longe… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-ee7.3-plugin-gradle8 | 11-15 11:34 (12.4h) | - \| merge: maint-2026 (ROOTS+TESTRES batch)… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-ee7.3-roots-testres | 11-15 11:09 (12.8h) | - \| build: version catalog gradle/libs.vers… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-jqz.1-jdbc-jackson | 11-15 03:31 (20.5h) | - \| deps: drop duplicate commons-math3 3.0 … |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-jqz.7-weak-deps | 11-15 05:51 (18.1h) | - \| deps: remove orphan vendored bobo-brows… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-jqz.8-flaky-tests | 11-15 07:24 (16.6h) | - \| integrate: make DataTracker.clear() saf… |
| intermine | 4 (im-89g.12-511-tes…, im-ore.14-testbed…, merge-maint-2026) | maint/im-rkn.3-baseline | 06-12 11:01 (156d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 2 (im-28e.7-nightly) | maint-2026 | 11-15 23:47 (13m) | ahead 97 vs dev \| Merge maint/im-7os.34-cdn-pins: sibling… |
| bluegenes | 2 (im-28e.7-nightly) | maint/im-28e.2-cypress-13 | 11-15 11:09 (12.8h) | - \| docs, cypress: how to run the suite; ta… |
| bluegenes | 2 (im-28e.7-nightly) | maint/im-28e.3-gh-actions | 11-15 05:31 (18.5h) | - \| docs: CI badge and Continuous integrati… |
| bluegenes | 2 (im-28e.7-nightly) | maint/im-28e.7-nightly | 11-15 23:58 (2m) | - \| wip: nightly Cypress against the rdfc2i… |
| bluegenes | 2 (im-28e.7-nightly) | maint/im-7os.1-shadow-cljs | 11-15 05:17 (18.7h) | - \| comments: drop stale lein/figwheel refe… |
| bluegenes | 2 (im-28e.7-nightly) | maint/im-7os.10-npm-advisories | 11-15 11:58 (12.0h) | - \| deps: override qs to 6.17.1 (same major… |
| bluegenes | 2 (im-28e.7-nightly) | maint/im-7os.18-sibling-deps | 11-15 12:49 (11.2h) | - \| docs: how the sibling libraries are pin… |
| bluegenes | 2 (im-28e.7-nightly) | maint/im-7os.4-cdn-sri | 11-15 11:48 (12.2h) | - \| script: cdn-sri.sh prints SRI hashes fo… |
| bluegenes | 2 (im-28e.7-nightly) | maint/im-7os.5-removals | 11-15 02:59 (21.0h) | - \| npm: remove unused clipboardy [im-7os.5] |
| bluegenes | 2 (im-28e.7-nightly) | maint/im-89g.5-ci-actions | 11-15 09:55 (14.1h) | - \| ci: bump GitHub Actions to current majo… |
| bluegenes | 2 (im-28e.7-nightly) | maint/im-rkn.4-baseline | 01-26 21:58 (658d) | - \| dynamic favicon slows down dx |
| imcljs | 1 | maint-2026 | 11-15 02:46 (21.2h) | ahead 8 vs dev \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| imcljs | 1 | maint/im-7os.3-imcljs-deps-edn | 11-15 02:46 (21.2h) | - \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| im-tables-3 | 1 | maint-2026 | 11-15 20:24 (3.6h) | ahead 23 vs dev \| Merge maint/im-7os.19-imcljs-pin: imclj… |
| im-tables-3 | 1 | maint/im-7os.3-im-tables-deps-edn | 11-15 12:05 (11.9h) | - \| test: lein kaocha honours IM_TABLES_SER… |
| bluegenes-tool-store | 1 | maint-2026 | 11-15 20:24 (3.6h) | ahead 10 vs master \| Merge maint/im-7os.19-imcljs-pin: imclj… |
| bluegenes-tool-store | 1 | maint/im-7os.3-tool-store-deps-edn | 11-15 02:33 (21.4h) | - \| deps: remove unused ring/ring-defaults … |
| bluegenes-tool-store | 1 | maint/im-7os.6-tool-store-fixes | 11-15 09:48 (14.2h) | - \| deps: bump commons-compress 1.19 -> 1.2… |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

| Start | Bead | Agent | Model | In | Cache | Out | Outcome | Notes |
|---|---|---|---|---|---|---|---|---|
| 11-15 23:24 | im-ore.14 | rdfc2im testbed fixes for m… | sonnet | 30 | 1.11M | 13.5k | killed | Blocked 20 min at 23:26Z on a permissio… |
| 11-15 23:17 | im-7os.34 | BlueGenes batch: sibling pi… | sonnet | 92 | 3.55M | 19.1k | success | 3 commits merged; one imcljs on the cla… |
| 11-15 23:14 | im-89g.17 | 5.1.1 backport of the JSP E… | sonnet | 32 | 776.5k | 8.0k | success | 4 commits pushed, release/5.1.1-candida… |
| 11-15 22:56 | im-jqz.37 | JSP EL reserved-word fixes … | sonnet | 140 | 6.50M | 39.4k | success | 3 commits merged; root cause Tomcat 8.5… |
| 11-15 22:27 | im-jqz.21 | commons-beanutils 1.11.0 + … | sonnet | 186 | 10.61M | 48.3k | success | f679951adb merged; gate 2125/92/59/12 J… |
| 11-15 22:17 | im-89g.8 | CI bio-fulldata-test databa… | sonnet | 10 | 225.8k | 3.8k | success | config/ci-bio.properties databaseName -… |
| 11-15 22:10 | im-89g.14 | 5.1.1 candidate: deployer g… | sonnet | 62 | 2.92M | 28.3k | success | docs-only e8035a509e pushed as release/… |
| 11-15 22:01 | im-89g.12 | Testbed: 5.1.1 candidate ut… | sonnet | 144 | 6.17M | 32.0k | success | 18 phases 642 s; test-live 17/17; mine-… |
| 11-15 21:57 | im-bdy.3 | intermine docs final pass (… | sonnet | 126 | 9.15M | 51.4k | success | 4 docs-only commits merged as intermine… |
| 11-15 21:56 | im-7os.35 | BlueGenes global fix for dr… | opus | 254 | 18.13M | 86.3k | success | a2894c0d merged; measured matrix: creat… |
| 11-15 20:40 | im-89g.12 | Testbed: 5.1.1 candidate ut… | sonnet | 32 | 956.0k | 9.4k | killed | Hung 78 min in one Bash call (relative-… |
| 11-15 20:19 | im-7os.19 | siblings imcljs git-sha pin… | sonnet | 38 | 1.31M | 16.1k | success | im-tables 1ec5e81, tool-store 2ed02b3; … |
| 11-15 20:18 | im-7os.31 | BlueGenes P1 bugs: ids case… | opus | 268 | 22.84M | 94.5k | success | 3 commits merged as bluegenes 79077194;… |
| 11-15 19:57 | im-ee7.53 | deployer re-check on the fi… | sonnet | 112 | 5.77M | 37.6k | success | humanmine 11e942a, flymine d01940b9, in… |
| 11-15 19:41 | im-89g.11 | 5.1.1 candidate backports (… | sonnet | 124 | 6.38M | 42.2k | success | credentials out of jars, log4j2 exclude… |
| 11-15 18:52 | im-jqz.20 | commons-lang 2.6 -> lang3 3… | sonnet | 192 | 10.79M | 59.2k | success | 5 commits; XmlUtil.escapeXml keeps 2.6 … |
| 11-15 18:49 | im-ee7.46 | plugin deployer fixes: webt… | sonnet | 204 | 16.14M | 83.7k | success | 4 commits; webapp classes jar in POMs (… |
| 11-15 17:59 | im-ee7.5 | B5 deployer migration: huma… | sonnet | 226 | 17.65M | 99.4k | success | intermine 6c15f0c750 docs; humanmine 01… |
| 11-15 17:54 | im-28e.5 | F4 Cypress specs and fixtur… | sonnet | 462 | 54.91M | 164.6k | success | 7 commits; 159 tests: 136 pass, 0 fail,… |
| 11-15 17:37 | im-jqz.6 | C6 JUnit 4.13.2, EasyMock 5… | sonnet | 190 | 12.19M | 60.3k | success | 9 commits; mockobjects/mockrunner/strin… |

Showing the 20 most recent of 81 runs.
