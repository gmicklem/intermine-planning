# STATUS 2026-11-15 02:46 UTC

Generated 2026-11-15 02:46 UTC / 2026-11-15 02:46 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 5 running, 0 stalled, 13 finished.

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-1 | running | 11-14 22:38 | 02:46 | 1.8k | 12.26M | 110.9k |
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
| bluegenes weak-dependency removals | sonnet-5-5 | running | 02:24 | 02:45 | 66 | 2.21M | 14.0k |
| imcljs to deps.edn and shadow-cljs | sonnet-5-5 | running | 02:25 | 02:45 | 118 | 7.20M | 50.6k |
| bluegenes-tool-store to deps.edn | sonnet-5-5 | finished | 02:25 | 02:36 | 66 | 3.37M | 32.2k |
| B1 Gradle 4.9 to 6.9.4 for intermine | opus-5-5 | running | 02:45 | 02:46 | 20 | 664.5k | 2.5k |
| C1+C2 intermine JDBC, Hikari, Jackson bumps | sonnet-5-5 | running | 02:46 | 02:46 | 16 | 382.5k | 1.6k |
| C7 intermine weak-dependency removals | sonnet-5-5 | running | 02:46 | 02:46 | 6 | 155.4k | 735 |

Note: 18 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-1 | 74 | 1.8k | 11.98M | 276.6k | 110.9k |
| subagents | opus-5-5 | 305 | 610 | 38.55M | 1.53M | 326.2k |
| subagents | sonnet-5-5 | 416 | 832 | 50.09M | 1.28M | 450.9k |

Tokens are de-duplicated per API message (streamed records share one message id).

## Beads summary

bd status: total 55, open 38, in progress 7, blocked 13, ready 25, deferred 0, closed 10.

| Status | Count |
|---|---|
| closed | 10 |
| in_progress | 7 |
| open | 38 |

### im-28e Epic F: BlueGenes tests and CI [open, 0/3 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-28e.1 | F1 kaocha unit tests green on new toolchain | open | 1 | epic |
| im-28e.2 | F2 Cypress 13+ migration targeting the rdfc2im mi… | open | 1 | epic |
| im-28e.3 | F3 GitHub Actions for bluegenes (cljfmt, kaocha, … | open | 2 | epic |

### im-7os Epic E: BlueGenes toolchain modernisation [open, 0/9 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.1 | E1 shadow-cljs + deps.edn build reproducing dev/p… | open | 0 | epic |
| im-7os.2 | E2 Library bumps: ClojureScript, re-frame 1.4, re… | open | 1 | epic |
| im-7os.3 | E3 imcljs / im-tables-3 / bluegenes-tool-store on… | in_progress | 1 | epic |
| im-7os.5 | E5 npm security: ws, wait-on, xmlhttprequest; npm… | in_progress | 1 | epic |
| im-7os.4 | E4 CDN assets pinned with SRI or bundled; vega bu… | open | 2 | epic |
| im-7os.6 | commons-compress 1.19 -> 1.27.1 in tool-store/blu… | open | 2 | epic |
| im-7os.7 | tool-store: replace dead api.npms.io discovery wi… | open | 2 | epic |
| im-7os.8 | tool-store: sanitise ../ in tar entry names (zip-… | open | 2 | epic |
| im-7os.9 | tool-store: SERVER_PORT env var parsed as Long ->… | open | 2 | epic |

### im-89g Epic D: intermine CI and release pipeline [open, 0/4 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-89g.1 | D1 GitHub Actions: pull_request trigger, setup-ja… | open | 1 | epic |
| im-89g.3 | D3 maven-publish + Central Portal publishing; doc… | open | 1 | epic |
| im-89g.2 | D2 .github/dependabot.yml (gradle, github-actions) | open | 2 | epic |
| im-89g.4 | D4 PR template, CONTRIBUTING.md, README badges | open | 3 | epic |

### im-8dd Epic I: Planning repo, beads, dashboard [open, 3/5 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-8dd.2 | I2 Dashboard generator (STATUS.md, index.html) an… | in_progress | 0 | epic |
| im-8dd.5 | I5 Sprint report for renewal decision (tokens/tim… | open | 1 | epic |

### im-bdy Epic H: Docs and governance [open, 1/2 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-bdy.3 | H1 intermine docs: building, local testing, upgra… | open | 2 | epic |

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 0/6 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.1 | B1 Gradle 4.9 -> 6.9.4 across all seven builds an… | in_progress | 0 | epic |
| im-ee7.2 | B2 Gradle 7.6.4: compile->implementation/api, mav… | open | 0 | epic |
| im-ee7.3 | B3 Gradle 8.14, remove com.sun.xml.internal prope… | open | 1 | epic |
| im-ee7.4 | B4 JDK 17 build and test run; JDK 21 verification | open | 1 | epic |
| im-ee7.5 | B5 Deployer migration: update humanmine/flymine b… | open | 1 | epic |
| im-ee7.6 | intermine plugin: tasks without declared outputs … | open | 2 | epic |

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 0/8 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.1 | C1 Postgres JDBC 42.7.x + HikariCP | in_progress | 0 | epic |
| im-jqz.2 | C2 Jackson 2.17+, org.json, everit json-schema | in_progress | 0 | epic |
| im-jqz.3 | C3 commons-* (collections, io, lang, fileupload, … | open | 0 | epic |
| im-jqz.4 | C4 bcprov, oltu, JOpenId, DWR CVE check (Tier 2 m… | open | 1 | epic |
| im-jqz.6 | C6 JUnit 4.13.2, xmlunit, mockobjects/easymock cl… | open | 1 | epic |
| im-jqz.7 | C7 Weak-dependency removals from the usage census | in_progress | 1 | epic |
| im-jqz.5 | C5 Jena 4.x, solrj latest 8.x, Lucene 3 stance | open | 2 | epic |
| im-jqz.8 | intermine: flaky testBatchesCache in FlatMode/Wit… | open | 2 | epic |

### im-ore Epic G: Whole-system testbed [open, 0/2 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ore.1 | G1 rdfc2im --intermine-src: consume local org.int… | open | 1 | epic |
| im-ore.2 | G2 mine-tests fixtures for the local demo mine (m… | open | 2 | epic |

### im-rkn Epic A: Environment and baseline [open, 6/7 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-rkn.5 | Baseline: rdfc2im full-build + make test-live + m… | open | 1 | baseline,epic |

## Repos and branches

| Repo | WT | Branch | Last commit | vs dev \| subject |
|---|---|---|---|---|
| intermine | 5 (im-ee7.1-gradle-6, im-jqz.1-jdbc-jac…, im-jqz.7-weak-deps...) | maint-2026 | 06-12 11:01 (155d) | level vs dev \| Merge pull request #2460 from intermine… |
| intermine | 5 (im-ee7.1-gradle-6, im-jqz.1-jdbc-jac…, im-jqz.7-weak-deps...) | maint/im-ee7.1-gradle-6 | 06-12 11:01 (155d) | - \| Merge pull request #2460 from intermine… |
| intermine | 5 (im-ee7.1-gradle-6, im-jqz.1-jdbc-jac…, im-jqz.7-weak-deps...) | maint/im-jqz.1-jdbc-jackson | 06-12 11:01 (155d) | - \| Merge pull request #2460 from intermine… |
| intermine | 5 (im-ee7.1-gradle-6, im-jqz.1-jdbc-jac…, im-jqz.7-weak-deps...) | maint/im-jqz.7-weak-deps | 06-12 11:01 (155d) | - \| Merge pull request #2460 from intermine… |
| intermine | 5 (im-ee7.1-gradle-6, im-jqz.1-jdbc-jac…, im-jqz.7-weak-deps...) | maint/im-rkn.3-baseline | 06-12 11:01 (155d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 3 (im-7os.5-removals, im-rkn.4-baseline) | maint-2026 | 01-26 21:58 (657d) | level vs dev \| dynamic favicon slows down dx |
| bluegenes | 3 (im-7os.5-removals, im-rkn.4-baseline) | maint/im-7os.5-removals | 02:44 (2m) | - \| build: drop nonexistent src/cljc and sr… |
| bluegenes | 3 (im-7os.5-removals, im-rkn.4-baseline) | maint/im-rkn.4-baseline | 01-26 21:58 (657d) | - \| dynamic favicon slows down dx |
| imcljs | 2 (im-7os.3-imcljs-d…) | maint-2026 | 04-07 12:42 (1682d) | level vs dev \| Bump version to 1.6.0 |
| imcljs | 2 (im-7os.3-imcljs-d…) | maint/im-7os.3-imcljs-deps-edn | 02:45 (65s) | - \| deps: bump cheshire 5.8.1 to 5.13.0 [im… |
| im-tables-3 | 1 | maint-2026 | 11-28 17:19 (1447d) | level vs dev \| Bump version to 0.15.0 |
| bluegenes-tool-store | 2 (im-7os.3-tool-sto…) | maint-2026 | 02:33 (13m) | ahead 4 vs master \| deps: remove unused ring/ring-defaults … |
| bluegenes-tool-store | 2 (im-7os.3-tool-sto…) | maint/im-7os.3-tool-store-deps-edn | 02:33 (13m) | - \| deps: remove unused ring/ring-defaults … |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

| Start | Bead | Agent | Model | In | Cache | Out | Outcome | Notes |
|---|---|---|---|---|---|---|---|---|
| 02:25 | im-7os.3 | tool-store deps.edn migrati… | sonnet | 66 | 3.37M | 32.2k | done | 4 commits, gate pass |
| 01:55 | im-bdy.2 | Decision records 0001-0006 | sonnet | 14 | 365.6k | 10.9k | done |  |
| 01:55 | im-7os.1 | shadow-cljs migration desig… | opus | 126 | 7.05M | 89.0k | done | decisions/bluegenes-build-migration.md |
| 01:54 | im-ee7 | Gradle upgrade path design … | opus | 168 | 15.81M | 132.1k | done | decisions/gradle-upgrade-path.md |
| 01:51 | im-rkn.4 | A4 bluegenes baseline | sonnet | 164 | 7.26M | 55.7k | done | kaocha 27/27 pass; Debian lein broken; … |
| 01:51 | im-rkn.3 | A3 intermine baseline | opus | 206 | 14.29M | 77.7k | done | 2279 tests pass; gate ~8 min; peak 3.2 … |
| 01:48 | im-8dd.4 | Split plan into per-area do… | sonnet | 10 | 238.7k | 15.2k | done |  |
| 01:48 | im-8dd.2 | Write dashboard generator | sonnet | 28 | 807.1k | 22.9k | done |  |
| 01:47 | im-rkn.7 | bluegenes dependency census… | sonnet | 162 | 12.90M | 113.7k | done | 38 removal candidates, 65 GHSA ids |
| 01:47 | im-rkn.6 | intermine dependency census… | sonnet | 182 | 16.47M | 133.5k | done | 79 coords, 21 vulnerable, 153 advisorie… |
| 00:18 | im-rkn | Survey rdfc2im/docker_templ… | opus | 26 | 863.6k | 7.5k | done |  |
| 00:18 | im-rkn | Survey bluegenes build/test… | opus | 22 | 347.5k | 8.3k | done |  |
| 00:18 | im-rkn | Survey intermine build/test… | opus | 42 | 1.05M | 9.0k | done |  |
