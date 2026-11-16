# STATUS 2026-11-16 07:00 UTC

Generated 2026-11-16 07:00 UTC / 2026-11-16 07:00 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 1 running, 2 stalled, 116 finished.

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-1 | running | 11-14 22:38 | 06:59 | 27.0k | 368.01M | 913.6k |
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
| Fix missing window.React for BlueGenes tools | sonnet-5-5 | finished | 11-15 17:11 | 06:15 | 114 | 4.17M | 23.8k |
| Bundle imjs global for BlueGenes tools | sonnet-5-5 | finished | 11-15 17:35 | 11-15 17:52 | 102 | 3.96M | 29.7k |
| C6 JUnit 4.13.2, xmlunit, mocks, vendored j… | sonnet-5-5 | finished | 11-15 17:37 | 11-15 18:49 | 190 | 12.19M | 60.3k |
| F4 Cypress specs for the demo mine | sonnet-5-5 | finished | 11-15 17:54 | 04:23 | 464 | 55.31M | 164.8k |
| B5 deployer migration: humanmine, flymine, … | sonnet-5-5 | finished | 11-15 17:59 | 04:23 | 228 | 17.91M | 99.6k |
| Plugin deployer fixes: webtasks POM, SO pat… | sonnet-5-5 | finished | 11-15 18:49 | 11-15 19:37 | 204 | 16.14M | 83.7k |
| commons-lang 2.6 to lang3 migration | sonnet-5-5 | finished | 11-15 18:52 | 11-15 19:39 | 192 | 10.79M | 59.2k |
| Backport security fixes to 5.1.1 candidate | sonnet-5-5 | finished | 11-15 19:41 | 11-15 20:38 | 124 | 6.38M | 42.2k |
| Deployer re-check on new plugin: humanmine,… | sonnet-5-5 | finished | 11-15 19:57 | 11-15 20:15 | 112 | 5.77M | 37.6k |
| BlueGenes P1 bugs: ids case, search submit | sonnet-5-5 | finished | 11-15 20:18 | 11-15 21:53 | 268 | 22.84M | 94.5k |
| Siblings: imcljs pin for im-tables and tool… | sonnet-5-5 | finished | 11-15 20:19 | 11-15 20:24 | 38 | 1.31M | 16.1k |
| Testbed: 5.1.1 candidate stack + smoke tests | sonnet-5-5 | stalled 9.0h | 11-15 20:40 | 11-15 22:00 | 32 | 956.0k | 9.4k |
| BlueGenes controlled inputs fix | opus-5-5 | finished | 11-15 21:56 | 11-15 23:15 | 254 | 18.13M | 86.3k |
| intermine docs final pass | sonnet-5-5 | finished | 11-15 21:57 | 11-15 22:08 | 126 | 9.15M | 51.4k |
| Testbed: 5.1.1 stack relaunch + smoke | sonnet-5-5 | finished | 11-15 22:01 | 11-15 22:25 | 144 | 6.17M | 32.0k |
| 5.1.1 candidate deployer guide backport | sonnet-5-5 | finished | 11-15 22:10 | 11-15 22:15 | 62 | 2.92M | 28.3k |
| intermine CI bio DB name alignment | sonnet-5-5 | finished | 11-15 22:17 | 11-15 22:18 | 10 | 225.8k | 3.8k |
| beanutils 1.11.0 bump + Struts smoke | sonnet-5-5 | finished | 11-15 22:27 | 11-15 22:54 | 186 | 10.61M | 48.3k |
| intermine JSP EL reserved-word bugs | sonnet-5-5 | finished | 11-15 22:56 | 11-15 23:12 | 140 | 6.50M | 39.4k |
| 5.1.1 backport of JSP EL fixes | sonnet-5-5 | finished | 11-15 23:14 | 11-15 23:23 | 38 | 964.4k | 12.3k |
| BlueGenes CDN leftovers + sibling pins | sonnet-5-5 | finished | 11-15 23:17 | 04:23 | 94 | 3.66M | 19.3k |
| rdfc2im testbed fixes for maint-2026 | sonnet-5-5 | stalled 7.2h | 11-15 23:24 | 11-15 23:47 | 30 | 1.11M | 13.5k |
| rdfc2im testbed fixes for maint-2026 (retry) | sonnet-5-5 | finished | 11-15 23:48 | 00:01 | 62 | 1.95M | 13.6k |
| BlueGenes nightly Cypress in GitHub Actions | opus-5-5 | finished | 11-15 23:51 | 01:23 | 248 | 19.84M | 66.2k |
| intermine dead JSPs + abbreviate.tag | sonnet-5-5 | finished | 00:03 | 00:14 | 88 | 3.14M | 23.5k |
| intermine weak-dependency batch | sonnet-5-5 | finished | 00:03 | 00:13 | 36 | 809.6k | 6.0k |
| rdfc2im offline cached-data build | sonnet-5-5 | finished | 00:04 | 00:55 | 118 | 7.33M | 44.5k |
| noop | haiku-5-5 | finished | 00:11 | 00:11 | 2 | 9.4k | 112 |
| intermine war duplicate jars (5.1.1 + 6.0) | sonnet-5-5 | finished | 00:16 | 00:37 | 134 | 6.25M | 44.5k |
| intermine: remove dead cdn.intermine.org | sonnet-5-5 | finished | 00:19 | 00:47 | 212 | 14.30M | 67.7k |
| UPGRADING docs: EL keywords, dead CDN | sonnet-5-5 | finished | 00:19 | 00:21 | 28 | 733.9k | 10.9k |
| BlueGenes default mine → HumanMine | sonnet-5-5 | finished | 00:23 | 04:23 | 80 | 2.13M | 10.5k |
| 5.1.1 backport: war duplicates | sonnet-5-5 | finished | 00:40 | 01:06 | 110 | 6.02M | 42.2k |
| 5.1.1 backport: dead CDN removal | sonnet-5-5 | finished | 00:50 | 00:58 | 74 | 2.11M | 15.0k |
| intermine: remaining dead external hosts | sonnet-5-5 | finished | 01:00 | 04:23 | 174 | 9.21M | 54.6k |
| im-tables: drop dead cdn.intermine.org | sonnet-5-5 | finished | 01:01 | 01:11 | 60 | 1.65M | 13.6k |
| BlueGenes im-tables pin bump | sonnet-5-5 | finished | 01:13 | 01:52 | 132 | 4.21M | 22.7k |
| intermine widget NPE chromosome distribution | sonnet-5-5 | finished | 01:14 | 04:23 | 132 | 5.29M | 25.9k |
| rdfc2im: cached mode must not imply offline | sonnet-5-5 | finished | 01:31 | 01:36 | 60 | 2.11M | 19.6k |
| 5.1.1 backport: logo + external hosts | sonnet-5-5 | finished | 01:37 | 01:44 | 36 | 714.3k | 4.4k |
| intermine plugin task inputs/outputs batch | opus-5-5 | finished | 01:46 | 03:17 | 316 | 37.57M | 139.5k |
| intermine webapp orphan sweep | sonnet-5-5 | finished | 01:54 | 02:36 | 212 | 15.25M | 65.5k |
| Date input end-to-end on HumanMine | sonnet-5-5 | finished | 02:39 | 03:24 | 298 | 27.12M | 125.0k |
| bio-sources repos to the 6.0 line | sonnet-5-5 | finished | 03:19 | 04:05 | 244 | 19.42M | 81.3k |
| intermine build hygiene batch | sonnet-5-5 | finished | 03:25 | 03:55 | 184 | 11.93M | 59.1k |
| UPGRADING notes for plugin wiring + docs ba… | sonnet-5-5 | finished | 03:57 | 04:09 | 208 | 16.03M | 69.8k |
| intermine DELETE /service/user NPE | sonnet-5-5 | finished | 04:07 | 04:34 | 164 | 7.56M | 40.4k |
| 5.1.1 candidate docs port | sonnet-5-5 | finished | 04:11 | 04:14 | 50 | 1.83M | 17.6k |
| intermine webapp hardening batch | sonnet-5-5 | finished | 04:15 | 05:01 | 224 | 12.71M | 65.9k |
| 5.1.1 backport: api fixes (user delete, tag… | sonnet-5-5 | finished | 04:35 | 05:11 | 60 | 1.44M | 8.8k |
| rdfc2im demo data quality fixes | sonnet-5-5 | finished | 05:03 | 05:26 | 260 | 22.07M | 88.4k |
| im-tables dropdown and static-toolbar bugs | sonnet-5-5 | finished | 05:13 | 05:35 | 144 | 6.93M | 55.0k |
| tool-store path safety fix | sonnet-5-5 | finished | 05:28 | 05:31 | 36 | 1.11M | 13.3k |
| psi-complexes converter loses participants | sonnet-5-5 | finished | 05:32 | 06:09 | 196 | 10.24M | 54.1k |
| BlueGenes sibling pin bumps + Cypress | sonnet-5-5 | finished | 05:36 | 05:50 | 102 | 3.00M | 15.6k |
| Cypress specs for the corrected demo data | sonnet-5-5 | finished | 05:48 | 06:03 | 104 | 3.59M | 24.6k |
| intermine Solr facet filter quoting | sonnet-5-5 | finished | 06:05 | 06:22 | 106 | 3.79M | 28.8k |
| BlueGenes dev build goog.isBoolean | sonnet-5-5 | finished | 06:10 | 06:18 | 82 | 2.48M | 16.8k |
| 5.1.1 backport: psi-complexes JAXB fix | sonnet-5-5 | finished | 06:21 | 06:45 | 70 | 2.52M | 15.5k |
| intermine userprofile id collision (P1) | opus-5-5 | finished | 06:24 | 06:47 | 180 | 9.30M | 55.2k |
| 5.1.1 backport: Solr facet fix | sonnet-5-5 | finished | 06:46 | 06:56 | 26 | 523.7k | 3.4k |
| 5.1.1 backport: id allocation + profile load | sonnet-5-5 | finished | 06:49 | 06:56 | 32 | 682.7k | 4.6k |
| BlueGenes chart, upload dropdown, GO widget… | sonnet-5-5 | running | 06:58 | 07:00 | 50 | 1.49M | 8.9k |

Note: 419 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-1 | 1061 | 27.0k | 366.00M | 2.01M | 913.6k |
| subagents | haiku-5-5 | 1 | 2 | 0 | 9.4k | 112 |
| subagents | opus-5-5 | 2640 | 5.3k | 451.37M | 22.20M | 2.02M |
| subagents | sonnet-5-5 | 5548 | 11.1k | 641.33M | 28.70M | 3.80M |

Tokens are de-duplicated per API message (streamed records share one message id).

## Beads summary

bd status: total 250, open 85, in progress 4, blocked 0, ready 85, deferred 0, closed 161.

| Status | Count |
|---|---|
| closed | 161 |
| in_progress | 4 |
| open | 85 |

### By priority (tasks and bugs; epics counted apart)

| Priority | open | in progress | blocked | deferred | closed | total | closed % | epics |
|---|---|---|---|---|---|---|---|---|
| P0 | 0 | 1 | 0 | 0 | 14 | 15 | 93% | 2 |
| P1 | 2 | 1 | 0 | 0 | 54 | 57 | 95% | 5 |
| P2 | 17 | 2 | 0 | 0 | 83 | 102 | 81% | 2 |
| P3 | 57 | 0 | 0 | 0 | 10 | 67 | 15% | 0 |
| all | 76 | 4 | 0 | 0 | 161 | 241 | 67% | 9 |

### im-28e Epic F: BlueGenes tests and CI [open, 9/13 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-28e.8 | tests: default public mine is HumanMine (Gos): im… | open | 2 | bluegenes,epic,im-tables,tests |
| im-28e.10 | bluegenes docs/building.md Cypress section still … | open | 3 | epic |
| im-28e.11 | bluegenes cypress: add a spec for the results-tab… | open | 3 | epic |
| im-28e.13 | bluegenes nightly: re-pin RDFC2IM_REF to rdfc2im … | open | 3 | epic |

### im-7os Epic E: BlueGenes toolchain modernisation [open, 34/48 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.33 | HUMAN (Gos): release imcljs 1.7.0, im-tables 0.16… | open | 1 | epic |
| im-7os.32 | [bug] bluegenes: chromosome chart throws unhandle… | in_progress | 2 | epic |
| im-7os.12 | tool-store: clj-http 'Invalid cookie header' warn… | open | 3 | epic,followup,tool-store |
| im-7os.14 | bluegenes viz/cases.cljs uses deprecated vega-lit… | open | 3 | bluegenes,epic |
| im-7os.16 | bluegenes dev advisories needing majors: Cypress … | open | 3 | bluegenes,epic,security |
| im-7os.20 | bluegenes: replace 11 uses of deprecated reagent.… | open | 3 | epic |
| im-7os.21 | im-tables: drop cljs-time (single use in error.cl… | open | 3 | epic |
| im-7os.23 | im-tables codegen: pass an explicit language-<nam… | open | 3 | epic |
| im-7os.29 | bluegenes: imjs 4.0.0 unmaintained since 2020 (no… | open | 3 | epic |
| im-7os.39 | bluegenes lists: default list name has 1-second r… | open | 3 | epic |
| im-7os.41 | bluegenes cypress: drop the remaining {delay:100}… | open | 3 | epic |
| im-7os.45 | bluegenes/im-tables: confirm date constraints aga… | open | 3 | epic |
| im-7os.47 | tool-store: require https for the registry tarbal… | open | 3 | epic |
| im-7os.48 | bluegenes: transit-cljs 0.8.256's com.cognitect.t… | open | 3 | epic |

### im-89g Epic D: intermine CI and release pipeline [open, 18/25 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-89g.7 | D3 follow-up: test real Central Portal upload (ce… | open | 1 | epic,followup,human,intermine |
| im-89g.10 | release 6.0.0: change humanmine/flymine fork pins… | open | 2 | epic |
| im-89g.24 | release/5.1.1-candidate: backport the Solr facet … | in_progress | 2 | epic |
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

### im-bdy Epic H: Docs and governance [open, 5/7 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-bdy.4 | intermine README: depsy.org badge likely dead; de… | open | 3 | docs,epic,intermine |
| im-bdy.8 | docs/tools/README-el-sweep.md (both lines): the r… | open | 3 | epic |

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 43/59 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.14 | plugin/build.gradle: maven -> maven-publish, clas… | open | 2 | epic |
| im-ee7.23 | D3 follow-up: confirm bio/sources POM scope chang… | open | 2 | deployer,epic,followup,intermine |
| im-ee7.51 | plugin: add Gradle TestKit tests for unwarBioWebA… | open | 2 | epic |
| im-ee7.31 | intermine/testresources/.gitignore still ignores … | open | 3 | epic,intermine |
| im-ee7.32 | plugin addStrutsConfig hard-codes build/resources… | open | 3 | epic,gradle,intermine |
| im-ee7.33 | intermine: move org.intermine:* imVersion coordin… | open | 3 | epic,gradle,intermine |
| im-ee7.40 | intermine: buildscript blocks can read the catalo… | open | 3 | epic,gradle,intermine |
| im-ee7.42 | mine template / deployer guide: drop commons-logg… | open | 3 | epic |
| im-ee7.43 | intermine: remove the com.sun.xml.internal proper… | open | 3 | epic |
| im-ee7.44 | testmine Cargo writes Tomcat config to /tmp/cargo… | open | 3 | epic |
| im-ee7.45 | intermine checkstyle 9.3: @throws-per-checked-exc… | open | 3 | epic |
| im-ee7.54 | plugin: warn when the mine war contains two versi… | open | 3 | epic |
| im-ee7.56 | plugin/build follow-ups from im-ee7.6: runAccepta… | open | 3 | epic |
| im-ee7.58 | intermine cleanup: intermine/resources/log4j2.pro… | open | 3 | epic |
| im-ee7.60 | flymine-bio-sources: 2 tests fail on stale test d… | open | 3 | epic |
| im-ee7.61 | plugin: a mine's createSoModel does not get the b… | open | 3 | epic |

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 30/55 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.10 | intermine: HikariCP 5.x once JDK 11+ baseline lan… | open | 2 | epic |
| im-jqz.12 | sandbox: Postgres max_connections=100 nearly exha… | open | 2 | epic |
| im-jqz.29 | intermine: replace cglib 3.1 (needs --add-opens j… | open | 2 | epic |
| im-jqz.32 | intermine: replace torque-3.2-dev, torque-gen-3.2… | open | 2 | epic |
| im-jqz.35 | Decision for Gos: commons-lang 2.6 reaches a mine… | open | 2 | epic |
| im-jqz.5 | C5 Jena 4.x, solrj latest 8.x, Lucene 3 stance | open | 2 | epic |
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
| im-jqz.47 | intermine webapp: remove the last third-party scr… | open | 3 | epic |
| im-jqz.49 | intermine webapp: remaining orphans from the im-j… | open | 3 | epic |
| im-jqz.52 | intermine webapp dwr.xml hardening: remove the ja… | open | 3 | epic |
| im-jqz.54 | bio/sources after im-jqz.51: verify on JDK 17 at … | open | 3 | epic |
| im-jqz.56 | intermine webapp follow-ups from im-jqz.53: Keywo… | open | 3 | epic |
| im-jqz.57 | [bug] intermine api: two concurrent uploads of th… | open | 3 | epic |

### im-ore Epic G: Whole-system testbed [open, 11/16 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ore.7 | rdfc2im follow-ups from G1: per-stack data dir in… | open | 2 | epic,rdfc2im,testbed |
| im-ore.8 | rdfc2im/BlueGenes stack: /favicon.ico redirects t… | open | 2 | bluegenes,epic,rdfc2im,testbed |
| im-ore.15 | rdfc2im --intermine-src: when the InterMine catal… | open | 3 | epic |
| im-ore.18 | rdfc2im demo mine data, next steps (BUILD.md 'Wha… | open | 3 | epic |
| im-ore.9 | mine-tests [mines.local]: gene object id (1000940… | open | 3 | epic,mine-tests,testbed |

### im-rkn Epic A: Environment and baseline [open, 8/10 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-rkn.8 | im-testenv.sh: offer a non-superuser test role mo… | open | 2 | epic |
| im-rkn.10 | sandbox: Cypress Electron needs Xvfb+GTK; worker … | open | 3 | epic,sandbox |

## Repos and branches

| Repo | WT | Branch | Last commit | vs dev \| subject |
|---|---|---|---|---|
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint-2026 | 06:47 (12m) | ahead 206 vs dev \| Merge maint/im-jqz.55-userprofile-ids: … |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-89g.1-ci-actions | 11-15 04:45 (26.2h) | - \| docs: update README badges, PR template… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-89g.1-ci-fix | 11-15 06:28 (24.5h) | - \| ci: stop using sudo -E -u postgres; con… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-89g.1-ci-fix2 | 11-15 06:54 (24.1h) | - \| ci: fix PostgreSQL 15+ public schema pr… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-89g.24-511-solr | 06:57 (2m) | - \| Merge release/5.1.1-candidate (id-colli… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-89g.3-maven-publish | 11-15 09:40 (21.3h) | - \| docs: add RELEASING.md (version bump, b… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-89g.5-ci-actions | 11-15 09:55 (21.1h) | - \| ci: bump GitHub Actions to current majo… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-ee7.1-gradle-6 | 11-15 03:57 (27.0h) | - \| build: default to Gradle 6.9.4 and veri… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-ee7.2-batch-bio | 11-15 09:32 (21.5h) | - \| build(bio): fold copyMineProperties int… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-ee7.2-batch-intermine | 11-15 06:21 (24.6h) | - \| intermine: convert all build files to G… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-ee7.2-batch-sources | 11-15 07:16 (23.7h) | - \| testmine: convert build files to Gradle… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-ee7.2-gradle-76-flip | 11-15 10:27 (20.5h) | - \| build: root testReport tasks use the Gr… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-ee7.2-plugin-gradle7 | 11-15 05:06 (25.9h) | - \| build(plugin): lazy tasks, no init task… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-ee7.3-catalog-modules | 11-15 11:52 (19.1h) | - \| docs: describe the version catalog; the… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-ee7.3-gradle-814-flip | 11-15 13:27 (17.5h) | - \| build(plugin): addStrutsConfig no longe… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-ee7.3-plugin-gradle8 | 11-15 11:34 (19.4h) | - \| merge: maint-2026 (ROOTS+TESTRES batch)… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-ee7.3-roots-testres | 11-15 11:09 (19.8h) | - \| build: version catalog gradle/libs.vers… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-jqz.1-jdbc-jackson | 11-15 03:31 (27.5h) | - \| deps: drop duplicate commons-math3 3.0 … |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-jqz.7-weak-deps | 11-15 05:51 (25.1h) | - \| deps: remove orphan vendored bobo-brows… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-jqz.8-flaky-tests | 11-15 07:24 (23.6h) | - \| integrate: make DataTracker.clear() saf… |
| intermine | 5 (im-89g.12-511-tes…, im-89g.24-511-solr, im-ore.14-testbed…...) | maint/im-rkn.3-baseline | 06-12 11:01 (156d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 2 (im-7os.32-chart-u…) | maint-2026 | 06:19 (41m) | ahead 119 vs dev \| Merge maint/im-7os.37-dev-build: oops 0… |
| bluegenes | 2 (im-7os.32-chart-u…) | maint/im-28e.2-cypress-13 | 11-15 11:09 (19.8h) | - \| docs, cypress: how to run the suite; ta… |
| bluegenes | 2 (im-7os.32-chart-u…) | maint/im-28e.3-gh-actions | 11-15 05:31 (25.5h) | - \| docs: CI badge and Continuous integrati… |
| bluegenes | 2 (im-7os.32-chart-u…) | maint/im-7os.1-shadow-cljs | 11-15 05:17 (25.7h) | - \| comments: drop stale lein/figwheel refe… |
| bluegenes | 2 (im-7os.32-chart-u…) | maint/im-7os.10-npm-advisories | 11-15 11:58 (19.0h) | - \| deps: override qs to 6.17.1 (same major… |
| bluegenes | 2 (im-7os.32-chart-u…) | maint/im-7os.18-sibling-deps | 11-15 12:49 (18.2h) | - \| docs: how the sibling libraries are pin… |
| bluegenes | 2 (im-7os.32-chart-u…) | maint/im-7os.32-chart-upload | 06:19 (41m) | - \| Merge maint/im-7os.37-dev-build: oops 0… |
| bluegenes | 2 (im-7os.32-chart-u…) | maint/im-7os.4-cdn-sri | 11-15 11:48 (19.2h) | - \| script: cdn-sri.sh prints SRI hashes fo… |
| bluegenes | 2 (im-7os.32-chart-u…) | maint/im-7os.5-removals | 11-15 02:59 (28.0h) | - \| npm: remove unused clipboardy [im-7os.5] |
| bluegenes | 2 (im-7os.32-chart-u…) | maint/im-89g.5-ci-actions | 11-15 09:55 (21.1h) | - \| ci: bump GitHub Actions to current majo… |
| bluegenes | 2 (im-7os.32-chart-u…) | maint/im-rkn.4-baseline | 01-26 21:58 (658d) | - \| dynamic favicon slows down dx |
| imcljs | 1 | maint-2026 | 00:35 (6.4h) | ahead 10 vs dev \| Merge maint/im-7os.26-default-humanmine… |
| imcljs | 1 | maint/im-7os.3-imcljs-deps-edn | 11-15 02:46 (28.2h) | - \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| im-tables-3 | 1 | maint-2026 | 05:36 (84m) | ahead 29 vs dev \| Merge maint/im-7os.44-dropdown-bugs: ni… |
| im-tables-3 | 1 | maint/im-7os.3-im-tables-deps-edn | 11-15 12:05 (18.9h) | - \| test: lein kaocha honours IM_TABLES_SER… |
| bluegenes-tool-store | 1 | maint-2026 | 05:31 (88m) | ahead 13 vs master \| Merge maint/im-7os.11-path-safety: real… |
| bluegenes-tool-store | 1 | maint/im-7os.3-tool-store-deps-edn | 11-15 02:33 (28.4h) | - \| deps: remove unused ring/ring-defaults … |
| bluegenes-tool-store | 1 | maint/im-7os.6-tool-store-fixes | 11-15 09:48 (21.2h) | - \| deps: bump commons-compress 1.19 -> 1.2… |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

| Start | Bead | Agent | Model | In | Cache | Out | Outcome | Notes |
|---|---|---|---|---|---|---|---|---|
| 06:49 | im-89g.25 | 5.1.1 backport: id allocati… | sonnet | 32 | 682.7k | 4.6k | success | 3 commits pushed, candidate = 85ffd5cc0… |
| 06:24 | im-jqz.55 | userprofile id collision: a… | opus | 180 | 9.30M | 55.2k | success | 6725c6de24 + 8203f6a6fc merged as 194dc… |
| 06:21 | im-89g.23 | 5.1.1 backport: psi-complex… | sonnet | 70 | 2.52M | 15.5k | success | c67a8caedc pushed, candidate = c67a8cae… |
| 06:10 | im-7os.37 | BlueGenes dev build: oops 0… | sonnet | 82 | 2.48M | 16.8k | success | 3a6ec8da merged as 89169e30; oops 0.7.0… |
| 06:05 | im-jqz.53 | Solr facet filter quoting (… | sonnet | 106 | 3.79M | 28.8k | success | 4e1ec37ef2 merged; facet filters now fa… |
| 05:48 | im-28e.12 | Cypress specs for the corre… | sonnet | 104 | 3.59M | 24.6k | success | aa139119 merged; 4 enrichment tests der… |
| 05:36 | im-7os.46 | BlueGenes sibling pins (im-… | sonnet | 102 | 3.00M | 15.6k | success | 0bd56ad6 + 63fd1354 merged; one of each… |
| 05:32 | im-jqz.51 | psi-complexes: JAXB runtime… | sonnet | 196 | 10.24M | 54.1k | success | 443d49bdda merged; cause bedb1094d3 (20… |
| 05:28 | im-7os.11 | tool-store path containment… | sonnet | 36 | 1.11M | 13.3k | success | 79ec629 + 1596b3a merged; inside-dir? r… |
| 05:13 | im-7os.44 | im-tables: nil-safe dropdow… | sonnet | 144 | 6.93M | 55.0k | success | 342cd35 + 14af85a merged; two separate … |
| 05:03 | im-ore.16 | rdfc2im demo data: organism… | sonnet | 260 | 22.07M | 88.4k | success | 4 commits pushed (d169a7f); ut rebuilt … |
| 04:35 | im-89g.22 | 5.1.1 backport: api fixes (… | sonnet | 60 | 1.44M | 8.8k | success | 3 commits pushed, candidate = 00cd59a79… |
| 04:15 | im-jqz.28 | webapp hardening batch (reg… | sonnet | 224 | 12.71M | 65.9k | success | 2a5355e967 f034052342 68c33b3e67 merged… |
| 04:11 | im-89g.21 | 5.1.1 candidate: docs port … | sonnet | 50 | 1.83M | 17.6k | success | 2 docs commits pushed, candidate = d3ee… |
| 04:07 | im-jqz.36 | DELETE /service/user 500 + … | sonnet | 164 | 7.56M | 40.4k | success | ca862be955 + e298df6dad merged; cause w… |
| 03:57 | im-ee7.57 | UPGRADING 6.0.0 plugin-wiri… | sonnet | 208 | 16.03M | 69.8k | success | 3 docs commits merged; humanmine/flymin… |
| 03:25 | im-ee7.36 | build hygiene batch (Ant lo… | sonnet | 184 | 11.93M | 59.1k | success | 5ed18a4955 + 4c451a450e merged; No-appe… |
| 03:19 | im-ee7.49 | humanmine-bio-sources + fly… | sonnet | 244 | 19.42M | 81.3k | success | 7 commits pushed to the gmicklem forks'… |
| 02:39 | im-7os.22 | date constraints end to end… | sonnet | 298 | 27.12M | 125.0k | success | 3ec8d4fb + c17d9aa5 merged; no public m… |
| 01:54 | im-jqz.41 | webapp orphan sweep after t… | sonnet | 212 | 15.25M | 65.5k | success | 62c1918d5b 5c3f75c47a 72bda6a301 merged… |

Showing the 20 most recent of 119 runs.
