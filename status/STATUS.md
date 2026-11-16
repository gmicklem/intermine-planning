# STATUS 2026-11-16 17:00 UTC

Generated 2026-11-16 17:00 UTC / 2026-11-16 17:00 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 3 running, 2 stalled, 150 finished.

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-1 | running | 11-14 22:38 | 17:00 | 34.2k | 537.69M | 1.17M |
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
| Testbed: 5.1.1 candidate stack + smoke tests | sonnet-5-5 | stalled 19.0h | 11-15 20:40 | 11-15 22:00 | 32 | 956.0k | 9.4k |
| BlueGenes controlled inputs fix | opus-5-5 | finished | 11-15 21:56 | 11-15 23:15 | 254 | 18.13M | 86.3k |
| intermine docs final pass | sonnet-5-5 | finished | 11-15 21:57 | 11-15 22:08 | 126 | 9.15M | 51.4k |
| Testbed: 5.1.1 stack relaunch + smoke | sonnet-5-5 | finished | 11-15 22:01 | 11-15 22:25 | 144 | 6.17M | 32.0k |
| 5.1.1 candidate deployer guide backport | sonnet-5-5 | finished | 11-15 22:10 | 11-15 22:15 | 62 | 2.92M | 28.3k |
| intermine CI bio DB name alignment | sonnet-5-5 | finished | 11-15 22:17 | 11-15 22:18 | 10 | 225.8k | 3.8k |
| beanutils 1.11.0 bump + Struts smoke | sonnet-5-5 | finished | 11-15 22:27 | 11-15 22:54 | 186 | 10.61M | 48.3k |
| intermine JSP EL reserved-word bugs | sonnet-5-5 | finished | 11-15 22:56 | 11-15 23:12 | 140 | 6.50M | 39.4k |
| 5.1.1 backport of JSP EL fixes | sonnet-5-5 | finished | 11-15 23:14 | 11-15 23:23 | 38 | 964.4k | 12.3k |
| BlueGenes CDN leftovers + sibling pins | sonnet-5-5 | finished | 11-15 23:17 | 04:23 | 94 | 3.66M | 19.3k |
| rdfc2im testbed fixes for maint-2026 | sonnet-5-5 | stalled 17.2h | 11-15 23:24 | 11-15 23:47 | 30 | 1.11M | 13.5k |
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
| BlueGenes chart, upload dropdown, GO widget… | sonnet-5-5 | finished | 06:58 | 07:30 | 224 | 13.16M | 56.1k |
| intermine Jena 4.x, solrj 8.x, Lucene stance | sonnet-5-5 | finished | 07:05 | 07:44 | 244 | 13.96M | 64.7k |
| rdfc2im stack: host-name leak, per-stack da… | sonnet-5-5 | finished | 07:06 | 07:11 | 86 | 3.27M | 30.7k |
| im-tables demo configs on HumanMine | sonnet-5-5 | finished | 07:13 | 07:33 | 54 | 1.48M | 15.7k |
| Rebuild the default rdfc2im stack | sonnet-5-5 | finished | 07:34 | 07:43 | 72 | 2.21M | 13.9k |
| 5.1.1 backport: Jena narrowing + solrj excl… | sonnet-5-5 | finished | 07:44 | 07:58 | 84 | 2.85M | 22.1k |
| BlueGenes: nightly re-pin + im-tables pin | sonnet-5-5 | finished | 07:45 | 08:05 | 36 | 885.1k | 7.1k |
| intermine plugin TestKit tests | opus-5-5 | finished | 08:00 | 08:23 | 188 | 12.77M | 73.4k |
| intermine dwr.xml hardening + gate testmine | sonnet-5-5 | finished | 08:12 | 08:21 | 94 | 3.56M | 23.9k |
| 5.1.1 backport: DWR settings + dwr.xml | sonnet-5-5 | finished | 08:25 | 08:52 | 144 | 6.37M | 34.5k |
| intermine plugin publishing cleanup | sonnet-5-5 | finished | 08:54 | 09:16 | 100 | 4.00M | 23.8k |
| tool-store: tarball URL and integrity checks | sonnet-5-5 | finished | 09:01 | 09:04 | 48 | 1.49M | 20.1k |
| intermine: Google Charts shim for list-widg… | sonnet-5-5 | finished | 09:19 | 09:41 | 150 | 6.84M | 48.7k |
| gate/testenv: per-task Gradle daemons, PG r… | sonnet-5-5 | finished | 09:19 | 09:30 | 74 | 3.33M | 30.5k |
| intermine webapp orphan sweep, second pass | sonnet-5-5 | finished | 09:32 | 09:46 | 156 | 9.08M | 45.8k |
| rdfc2im: per-stack artifacts + ut rebuild | sonnet-5-5 | finished | 09:43 | 09:56 | 56 | 1.88M | 17.8k |
| intermine: RDF/XML 500 on ontology URIs | sonnet-5-5 | finished | 11:39 | 12:10 | 108 | 4.21M | 29.3k |
| intermine: replace cglib (6.0 line) | opus-5-5 | finished | 11:40 | 12:50 | 340 | 32.47M | 108.8k |
| bluegenes follow-up batch | sonnet-5-5 | finished | 11:40 | 12:37 | 236 | 15.36M | 60.8k |
| 5.1.1 backport: RDF export fix | sonnet-5-5 | finished | 11:59 | 12:15 | 58 | 1.44M | 9.2k |
| intermine 6.0: drop commons-lang 2, forks t… | sonnet-5-5 | finished | 13:19 | 14:03 | 148 | 8.04M | 47.2k |
| im-tables: save list from results fails | sonnet-5-5 | finished | 13:19 | 13:43 | 208 | 11.62M | 48.8k |
| humanmine/flymine: dangling class references | sonnet-5-5 | finished | 13:20 | 13:24 | 90 | 2.99M | 19.9k |
| bluegenes: reagent 2.0.1 keystroke experime… | sonnet-5-5 | finished | 13:21 | 14:02 | 166 | 8.72M | 47.3k |
| sibling pin bumps: im-tables, bluegenes | sonnet-5-5 | finished | 13:45 | 15:17 | 150 | 4.93M | 16.6k |
| intermine 6.0: replace vendored torque DDL | opus-5-5 | finished | 15:02 | 16:19 | 300 | 24.66M | 88.5k |
| intermine webapp/api bug batch | sonnet-5-5 | finished | 15:03 | 16:13 | 410 | 42.20M | 121.2k |
| intermine build/CI/cleanup batch | sonnet-5-5 | finished | 15:03 | 16:18 | 390 | 51.48M | 155.0k |
| bluegenes batch: regions debounce, vega par… | sonnet-5-5 | finished | 15:04 | 15:58 | 166 | 7.86M | 35.7k |
| im-tables batch: dispatch bug, cljs-time, c… | sonnet-5-5 | finished | 15:04 | 16:02 | 166 | 8.05M | 45.1k |
| intermine small cleanups batch | sonnet-5-5 | finished | 15:33 | 16:14 | 158 | 8.37M | 50.6k |
| testbed: mine-tests gene id, demo template … | sonnet-5-5 | finished | 15:33 | 15:42 | 136 | 6.03M | 43.8k |
| 5.1.1 backports: webapp bugs, DataTracker | sonnet-5-5 | finished | 16:16 | 16:28 | 62 | 1.63M | 11.6k |
| intermine: version catalog consolidation | sonnet-5-5 | running | 16:31 | 17:00 | 188 | 12.05M | 54.1k |
| intermine plugin batch: war duplicates, pat… | sonnet-5-5 | finished | 16:31 | 16:59 | 250 | 22.06M | 94.7k |
| intermine bio batch: xalan, JAXB, ChEBI, fo… | sonnet-5-5 | running | 16:32 | 16:56 | 286 | 25.44M | 102.5k |
| bluegenes batch 3: transit-js, Date values,… | sonnet-5-5 | running | 16:33 | 16:59 | 126 | 5.52M | 34.6k |

Note: 669 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-1 | 1374 | 34.2k | 534.96M | 2.72M | 1.17M |
| subagents | haiku-5-5 | 1 | 2 | 0 | 9.4k | 112 |
| subagents | opus-5-5 | 3035 | 6.1k | 519.04M | 24.43M | 2.29M |
| subagents | sonnet-5-5 | 8072 | 16.2k | 951.11M | 39.81M | 5.27M |

Tokens are de-duplicated per API message (streamed records share one message id).

## Beads summary

bd status: total 284, open 30, in progress 18, blocked 0, ready 30, deferred 0, closed 236.

| Status | Count |
|---|---|
| closed | 236 |
| in_progress | 18 |
| open | 30 |

### By priority (tasks and bugs; epics counted apart)

| Priority | open | in progress | blocked | deferred | closed | total | closed % | epics |
|---|---|---|---|---|---|---|---|---|
| P0 | 0 | 1 | 0 | 0 | 14 | 15 | 93% | 2 |
| P1 | 2 | 1 | 0 | 0 | 56 | 59 | 95% | 5 |
| P2 | 4 | 0 | 0 | 0 | 109 | 113 | 96% | 2 |
| P3 | 15 | 16 | 0 | 0 | 57 | 88 | 65% | 0 |
| all | 21 | 18 | 0 | 0 | 236 | 275 | 86% | 9 |

### im-28e Epic F: BlueGenes tests and CI [open, 13/13 closed]

No open child issues.

### im-7os Epic E: BlueGenes toolchain modernisation [open, 52/59 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.33 | HUMAN (Gos): release imcljs 1.7.0, im-tables 0.16… | open | 1 | epic |
| im-7os.16 | bluegenes dev advisories needing majors: Cypress … | open | 3 | bluegenes,epic,security |
| im-7os.29 | bluegenes: imjs 4.0.0 unmaintained since 2020 (no… | open | 3 | epic |
| im-7os.57 | reagent 2.x readiness (later): im-tables calls re… | open | 3 | epic |
| im-7os.58 | bluegenes: add explicit com.cognitect/transit-js … | in_progress | 3 | epic |
| im-7os.59 | [bug] bluegenes upload page: organism stays 'Any'… | in_progress | 3 | epic |
| im-7os.60 | bluegenes: query builder requests possible values… | in_progress | 3 | epic |

### im-89g Epic D: intermine CI and release pipeline [open, 27/29 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-89g.7 | D3 follow-up: test real Central Portal upload (ce… | open | 1 | epic,followup,human,intermine |
| im-89g.10 | release 6.0.0: change humanmine/flymine fork pins… | open | 2 | epic |

### im-8dd Epic I: Planning repo, beads, dashboard [open, 5/9 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-8dd.2 | I2 Dashboard generator (STATUS.md, index.html) an… | in_progress | 0 | epic |
| im-8dd.5 | I5 Sprint report for renewal decision (tokens/tim… | in_progress | 1 | epic |
| im-8dd.8 | sprint infra: worker agents hang for ever when a … | open | 2 | epic |
| im-8dd.9 | testenv docs: baselines/intermine-2026-11-15.md c… | open | 3 | epic |

### im-bdy Epic H: Docs and governance [open, 7/8 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-bdy.9 | Expert review queue: docs/EXPERT_TO_CHECK.md in t… | open | 2 | epic |

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 53/64 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.32 | plugin addStrutsConfig hard-codes build/resources… | in_progress | 3 | epic,gradle,intermine |
| im-ee7.33 | intermine: move org.intermine:* imVersion coordin… | in_progress | 3 | epic,gradle,intermine |
| im-ee7.40 | intermine: buildscript blocks can read the catalo… | in_progress | 3 | epic,gradle,intermine |
| im-ee7.42 | mine template / deployer guide: drop commons-logg… | open | 3 | epic |
| im-ee7.44 | testmine Cargo writes Tomcat config to /tmp/cargo… | in_progress | 3 | epic |
| im-ee7.45 | intermine checkstyle 9.3: @throws-per-checked-exc… | in_progress | 3 | epic |
| im-ee7.54 | plugin: warn when the mine war contains two versi… | in_progress | 3 | epic |
| im-ee7.56 | plugin/build follow-ups from im-ee7.6: runAccepta… | in_progress | 3 | epic |
| im-ee7.60 | flymine-bio-sources: 2 tests fail on stale test d… | in_progress | 3 | epic |
| im-ee7.66 | intermine leftovers from classrefs: bio/webapp bi… | open | 3 | epic |
| im-ee7.67 | intermine: install_intermine.py should substitute… | in_progress | 3 | epic |

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 51/63 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.10 | intermine: HikariCP 5.x once JDK 11+ baseline lan… | open | 2 | epic |
| im-jqz.14 | intermine: JAXB/annotation shims (inventory R14) … | open | 3 | epic |
| im-jqz.16 | intermine: xalan removal verified only by unit te… | in_progress | 3 | epic |
| im-jqz.23 | intermine: drop commons-io once build is on JDK 1… | open | 3 | epic |
| im-jqz.30 | bio-source-psi-complexes: ChEBI lookup uses a SOA… | in_progress | 3 | epic |
| im-jqz.33 | psi-complexes: restore small-molecule names via C… | in_progress | 3 | epic |
| im-jqz.54 | bio/sources after im-jqz.51: verify on JDK 17 at … | in_progress | 3 | epic |
| im-jqz.59 | 6.0 Java 17 baseline follow-ups from im-jqz.5: Je… | open | 3 | epic |
| im-jqz.61 | HUMAN: check whether metabolicmine.org and esyn.o… | open | 3 | epic |
| im-jqz.63 | humanmine-bio-sources: tests rewrite the tracked … | open | 3 | epic |
| im-jqz.64 | intermine follow-ups from im-jqz.56 batch: LoadQu… | open | 3 | epic |
| im-jqz.65 | bio-source-chado-db SequenceProcessor lines ~1028… | open | 3 | epic |

### im-ore Epic G: Whole-system testbed [open, 19/20 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ore.18 | rdfc2im demo mine data, next steps (BUILD.md 'Wha… | open | 3 | epic |

### im-rkn Epic A: Environment and baseline [open, 9/10 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-rkn.10 | sandbox: Cypress Electron needs Xvfb+GTK; worker … | open | 3 | epic,sandbox |

## Repos and branches

| Repo | WT | Branch | Last commit | vs dev \| subject |
|---|---|---|---|---|
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint-2026 | 16:59 (7s) | ahead 268 vs dev \| Merge maint/im-ee7.54-plugin-batch: war… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-89g.1-ci-actions | 11-15 04:45 (36.2h) | - \| docs: update README badges, PR template… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-89g.1-ci-fix | 11-15 06:28 (34.5h) | - \| ci: stop using sudo -E -u postgres; con… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-89g.1-ci-fix2 | 11-15 06:54 (34.1h) | - \| ci: fix PostgreSQL 15+ public schema pr… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-89g.3-maven-publish | 11-15 09:40 (31.3h) | - \| docs: add RELEASING.md (version bump, b… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-89g.5-ci-actions | 11-15 09:55 (31.1h) | - \| ci: bump GitHub Actions to current majo… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.1-gradle-6 | 11-15 03:57 (37.0h) | - \| build: default to Gradle 6.9.4 and veri… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.2-batch-bio | 11-15 09:32 (31.5h) | - \| build(bio): fold copyMineProperties int… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.2-batch-intermine | 11-15 06:21 (34.6h) | - \| intermine: convert all build files to G… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.2-batch-sources | 11-15 07:16 (33.7h) | - \| testmine: convert build files to Gradle… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.2-gradle-76-flip | 11-15 10:27 (30.5h) | - \| build: root testReport tasks use the Gr… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.2-plugin-gradle7 | 11-15 05:06 (35.9h) | - \| build(plugin): lazy tasks, no init task… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.3-catalog-modules | 11-15 11:52 (29.1h) | - \| docs: describe the version catalog; the… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.3-gradle-814-flip | 11-15 13:27 (27.5h) | - \| build(plugin): addStrutsConfig no longe… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.3-plugin-gradle8 | 11-15 11:34 (29.4h) | - \| merge: maint-2026 (ROOTS+TESTRES batch)… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.3-roots-testres | 11-15 11:09 (29.8h) | - \| build: version catalog gradle/libs.vers… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-ee7.67-versions | 16:56 (3m) | - \| build: org.intermine modules and the Ca… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-jqz.1-jdbc-jackson | 11-15 03:31 (37.5h) | - \| deps: drop duplicate commons-math3 3.0 … |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-jqz.16-bio-batch | 16:55 (5m) | - \| tests: xmlunit only where XML is compar… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-jqz.7-weak-deps | 11-15 05:51 (35.1h) | - \| deps: remove orphan vendored bobo-brows… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-jqz.8-flaky-tests | 11-15 07:24 (33.6h) | - \| integrate: make DataTracker.clear() saf… |
| intermine | 6 (im-89g.12-511-tes…, im-ee7.67-versions, im-jqz.16-bio-bat…...) | maint/im-rkn.3-baseline | 06-12 11:01 (157d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint-2026 | 15:59 (60m) | ahead 138 vs dev \| Merge maint/im-7os.52-bg-batch2: per-in… |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint/im-28e.2-cypress-13 | 11-15 11:09 (29.8h) | - \| docs, cypress: how to run the suite; ta… |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint/im-28e.3-gh-actions | 11-15 05:31 (35.5h) | - \| docs: CI badge and Continuous integrati… |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint/im-7os.1-shadow-cljs | 11-15 05:17 (35.7h) | - \| comments: drop stale lein/figwheel refe… |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint/im-7os.10-npm-advisories | 11-15 11:58 (29.0h) | - \| deps: override qs to 6.17.1 (same major… |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint/im-7os.18-sibling-deps | 11-15 12:49 (28.2h) | - \| docs: how the sibling libraries are pin… |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint/im-7os.4-cdn-sri | 11-15 11:48 (29.2h) | - \| script: cdn-sri.sh prints SRI hashes fo… |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint/im-7os.5-removals | 11-15 02:59 (38.0h) | - \| npm: remove unused clipboardy [im-7os.5] |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint/im-7os.58-bg-batch3 | 16:53 (7m) | - \| upload: default organism re-applied whe… |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint/im-89g.5-ci-actions | 11-15 09:55 (31.1h) | - \| ci: bump GitHub Actions to current majo… |
| bluegenes | 2 (im-7os.58-bg-batc…) | maint/im-rkn.4-baseline | 01-26 21:58 (658d) | - \| dynamic favicon slows down dx |
| imcljs | 1 | maint-2026 | 13:44 (3.3h) | ahead 12 vs dev \| Merge maint/im-7os.51-save-list [im-7os… |
| imcljs | 1 | maint/im-7os.3-imcljs-deps-edn | 11-15 02:46 (38.2h) | - \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| im-tables-3 | 1 | maint-2026 | 16:03 (57m) | ahead 40 vs dev \| Merge maint/im-7os.55-imt-batch: filter… |
| im-tables-3 | 1 | maint/im-7os.3-im-tables-deps-edn | 11-15 12:05 (28.9h) | - \| test: lein kaocha honours IM_TABLES_SER… |
| bluegenes-tool-store | 1 | maint-2026 | 15:39 (80m) | ahead 19 vs master \| Merge maint/im-7os.12-ts-cookies: stand… |
| bluegenes-tool-store | 1 | maint/im-7os.3-tool-store-deps-edn | 11-15 02:33 (38.4h) | - \| deps: remove unused ring/ring-defaults … |
| bluegenes-tool-store | 1 | maint/im-7os.6-tool-store-fixes | 11-15 09:48 (31.2h) | - \| deps: bump commons-compress 1.19 -> 1.2… |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

| Start | Bead | Agent | Model | In | Cache | Out | Outcome | Notes |
|---|---|---|---|---|---|---|---|---|
| 16:16 | im-89g.29 | 5.1.1 backports (webapp bug… | sonnet | 62 | 1.63M | 11.6k | success | 9 commits merged as b9355b129e; conflic… |
| 15:34 | im-7os.12 | tool-store: cookie policy, … | sonnet | 105.2k | 0 | 0 | success | [tokens: 105165 total from the task not… |
| 15:33 | im-jqz.17 | intermine small cleanups ba… | sonnet | 158 | 8.37M | 50.6k | success | 7 commits merged; DataTracker: volatile… |
| 15:04 | im-7os.55 | im-tables batch (dispatch b… | sonnet | 166 | 8.05M | 45.1k | success | 994feda 55205b9 0b41279 63b9b9a merged;… |
| 15:04 | im-7os.52 | bluegenes batch 2 (regions … | sonnet | 166 | 7.86M | 35.7k | success | 5e7496cb 80ff8a92 6c76ef92 8fabbcaa mer… |
| 15:03 | im-ee7.62 | build/CI batch (plugin Test… | sonnet | 390 | 51.48M | 155.0k | success | 6 commits merged; 23 plugin tests (11 n… |
| 15:03 | im-jqz.56 | webapp/api bug batch (facet… | sonnet | 406 | 41.86M | 121.0k | success | 5 commits merged (aff41f85d9 c6cfc200a6… |
| 15:02 | im-jqz.32 | own DDL generator replaces … | opus | 300 | 24.66M | 88.5k | success | e16f6f194d + a554fdc28b (trailers amend… |
| 13:45 | im-7os.54 | sibling pin bumps (imcljs d… | sonnet | 146 | 4.84M | 16.6k | success | im-tables dbf03c7 + bluegenes 0066d9ba … |
| 13:21 | im-7os.53 | reagent 2.0.1 keystroke exp… | sonnet | 166 | 8.72M | 47.3k | success | no commit (experiment); keys lost /1600… |
| 13:20 | im-ee7.65 | humanmine/flymine dangling … | sonnet | 90 | 2.99M | 19.9k | success | flymine a4718bb4 (two Cytoscape actions… |
| 13:19 | im-7os.51 | list save 400 (imcljs query… | sonnet | 208 | 11.62M | 48.8k | success | imcljs 0dabc32 (merged d96a3eb): ->xml … |
| 13:19 | im-jqz.35 | commons-lang 2 off mine cla… | sonnet | 148 | 8.04M | 47.2k | success | 84fb65e70b + ba0eeaaf76 merged; torque … |
| 11:59 | im-89g.28 | 5.1.1 backport: RDF export … | sonnet | 58 | 1.44M | 9.2k | success | 072b62911a cherry-picked (imports confl… |
| 11:40 | im-7os.50 | bluegenes follow-up batch (… | sonnet | 236 | 15.36M | 60.8k | success | 5 commits merged; tool-store pin be4678… |
| 11:40 | im-jqz.29 | Byte Buddy replaces cglib (… | opus | 340 | 32.47M | 108.8k | success | fb900f033f + f7dfc76a7b merged; JDK pro… |
| 11:39 | im-jqz.58 | RDF/XML 500 on ontology ter… | sonnet | 106 | 4.11M | 29.1k | success | b6975f4341 merged; root cause: ModelMer… |
| 09:43 | im-ore.21 | rdfc2im: per-stack artifact… | sonnet | 56 | 1.88M | 17.8k | success | 7780407 pushed; RDFC2IM_ARTIFACTS env i… |
| 09:32 | im-jqz.49 | webapp orphan sweep, second… | sonnet | 156 | 9.08M | 45.8k | success | 8d85bbb075 0530511a01 cf01977f4e merged… |
| 09:19 | im-8dd.7 | gate/testenv: per-task Grad… | sonnet | 74 | 3.33M | 30.5k | success | im-testenv.sh/gate-intermine.sh edited … |

Showing the 20 most recent of 153 runs.
