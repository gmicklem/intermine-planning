# STATUS 2026-11-15 06:00 UTC

Generated 2026-11-15 06:00 UTC / 2026-11-15 06:00 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 0 running, 1 stalled, 24 finished.

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-1 | running | 11-14 22:38 | 05:59 | 3.4k | 35.36M | 159.8k |
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
| D1+D2 intermine GitHub Actions and dependab… | sonnet-5-5 | finished | 04:16 | 04:45 | 104 | 4.96M | 41.6k |
| Review E1 bluegenes shadow-cljs branch | opus-5-5 | finished | 04:42 | 04:50 | 92 | 4.29M | 36.5k |
| F3 bluegenes GitHub Actions workflow | sonnet-5-5 | finished | 05:23 | 05:31 | 54 | 2.20M | 32.7k |
| D3 intermine maven-publish and Central Port… | sonnet-5-5 | stalled 31m | 05:24 | 05:29 | 68 | 3.67M | 35.0k |

Note: 51 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-1 | 143 | 3.4k | 34.97M | 386.6k | 159.8k |
| subagents | opus-5-5 | 795 | 1.6k | 157.56M | 4.70M | 806.3k |
| subagents | sonnet-5-5 | 765 | 1.5k | 87.91M | 4.59M | 726.8k |

Tokens are de-duplicated per API message (streamed records share one message id).

## Beads summary

bd status: total 76, open 52, in progress 5, blocked 9, ready 43, deferred 0, closed 19.

| Status | Count |
|---|---|
| closed | 19 |
| in_progress | 5 |
| open | 52 |

### im-28e Epic F: BlueGenes tests and CI [open, 0/4 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-28e.1 | F1 kaocha unit tests green on new toolchain | open | 1 | epic |
| im-28e.2 | F2 Cypress 13+ migration targeting the rdfc2im mi… | open | 1 | epic |
| im-28e.4 | bluegenes gate: smoke must execute the JS bundle,… | open | 1 | epic |
| im-28e.3 | F3 GitHub Actions for bluegenes (cljfmt, kaocha, … | in_progress | 2 | epic |

### im-7os Epic E: BlueGenes toolchain modernisation [open, 2/10 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.10 | bluegenes: remaining npm advisories (7 critical, … | open | 1 | epic |
| im-7os.2 | E2 Library bumps: ClojureScript, re-frame 1.4, re… | open | 1 | epic |
| im-7os.3 | E3 imcljs / im-tables-3 / bluegenes-tool-store on… | in_progress | 1 | epic |
| im-7os.4 | E4 CDN assets pinned with SRI or bundled; vega bu… | open | 2 | epic |
| im-7os.6 | commons-compress 1.19 -> 1.27.1 in tool-store/blu… | open | 2 | epic |
| im-7os.7 | tool-store: replace dead api.npms.io discovery wi… | open | 2 | epic |
| im-7os.8 | tool-store: sanitise ../ in tar entry names (zip-… | open | 2 | epic |
| im-7os.9 | tool-store: SERVER_PORT env var parsed as Long ->… | open | 2 | epic |

### im-89g Epic D: intermine CI and release pipeline [open, 3/5 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-89g.3 | D3 maven-publish + Central Portal publishing; doc… | in_progress | 1 | epic |
| im-89g.5 | ci (both repos): bump actions/setup-java to v5 an… | open | 3 | epic |

### im-8dd Epic I: Planning repo, beads, dashboard [open, 3/5 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-8dd.2 | I2 Dashboard generator (STATUS.md, index.html) an… | in_progress | 0 | epic |
| im-8dd.5 | I5 Sprint report for renewal decision (tokens/tim… | open | 1 | epic |

### im-bdy Epic H: Docs and governance [open, 1/2 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-bdy.3 | H1 intermine docs: building, local testing, upgra… | open | 2 | epic |

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 1/16 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.2 | B2 Gradle 7.6.4: compile->implementation/api, mav… | in_progress | 0 | epic |
| im-ee7.3 | B3 Gradle 8.14, remove com.sun.xml.internal prope… | open | 1 | epic |
| im-ee7.4 | B4 JDK 17 build and test run; JDK 21 verification | open | 1 | epic |
| im-ee7.5 | B5 Deployer migration: update humanmine/flymine b… | open | 1 | epic |
| im-ee7.10 | B5 deployer guide: deployers must delete stopExec… | open | 2 | epic |
| im-ee7.11 | gate-intermine.sh header still says default Gradl… | open | 2 | epic |
| im-ee7.12 | intermine plugin: runtime-resources dir so test-o… | open | 2 | epic |
| im-ee7.13 | bio/model: mergeModels edits processResources out… | open | 2 | epic |
| im-ee7.14 | plugin/build.gradle: maven -> maven-publish, clas… | open | 2 | epic |
| im-ee7.15 | plugin: unwarBioWebApp + addStrutsConfig -> Sync … | open | 2 | epic |
| im-ee7.16 | build files: compileTestJava.dependsOn -> test.de… | open | 2 | epic |
| im-ee7.6 | intermine plugin: tasks without declared outputs … | open | 2 | epic |
| im-ee7.7 | intermine: regenerate the seven gradlew scripts a… | open | 2 | epic |
| im-ee7.8 | intermine: test-only files leak into bio-source/p… | open | 2 | epic |
| im-ee7.9 | intermine: flaky IntegrationWriterDataTrackingImp… | open | 2 | epic |

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 3/16 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.3 | C3 commons-* (collections, io, lang, fileupload, … | open | 0 | epic |
| im-jqz.4 | C4 bcprov, oltu, JOpenId, DWR CVE check (Tier 2 m… | open | 1 | epic |
| im-jqz.6 | C6 JUnit 4.13.2, xmlunit, mockobjects/easymock cl… | open | 1 | epic |
| im-jqz.10 | intermine: HikariCP 5.x once JDK 11+ baseline lan… | open | 2 | epic |
| im-jqz.11 | intermine: remove jersey-media-json-jackson + Jer… | open | 2 | epic |
| im-jqz.12 | sandbox: Postgres max_connections=100 nearly exha… | open | 2 | epic |
| im-jqz.5 | C5 Jena 4.x, solrj latest 8.x, Lucene 3 stance | open | 2 | epic |
| im-jqz.8 | intermine: flaky testBatchesCache in FlatMode/Wit… | open | 2 | epic |
| im-jqz.9 | intermine: ant 1.7.0 -> 1.10.x (3 advisories); te… | open | 2 | epic |
| im-jqz.13 | intermine: pathquery and model rely on org.json v… | open | 3 | epic |
| im-jqz.14 | intermine: JAXB/annotation shims (inventory R14) … | open | 3 | epic |
| im-jqz.15 | intermine: objenesis redundant with easymock; rem… | open | 3 | epic |
| im-jqz.16 | intermine: xalan removal verified only by unit te… | open | 3 | epic |

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
| intermine | 10 (baseline-wt, im-89g.1-ci-actio…, im-89g.3-maven-pu…...) | maint-2026 | 05:53 (7m) | ahead 29 vs dev \| Merge maint/im-jqz.7-weak-deps: remove … |
| intermine | 10 (baseline-wt, im-89g.1-ci-actio…, im-89g.3-maven-pu…...) | maint/im-89g.1-ci-actions | 04:45 (75m) | - \| docs: update README badges, PR template… |
| intermine | 10 (baseline-wt, im-89g.1-ci-actio…, im-89g.3-maven-pu…...) | maint/im-89g.3-maven-publish | 05:07 (53m) | - \| Merge maint/im-ee7.2-plugin-gradle7: pl… |
| intermine | 10 (baseline-wt, im-89g.1-ci-actio…, im-89g.3-maven-pu…...) | maint/im-ee7.1-gradle-6 | 03:57 (2.0h) | - \| build: default to Gradle 6.9.4 and veri… |
| intermine | 10 (baseline-wt, im-89g.1-ci-actio…, im-89g.3-maven-pu…...) | maint/im-ee7.2-plugin-gradle7 | 05:06 (53m) | - \| build(plugin): lazy tasks, no init task… |
| intermine | 10 (baseline-wt, im-89g.1-ci-actio…, im-89g.3-maven-pu…...) | maint/im-jqz.1-jdbc-jackson | 03:31 (2.5h) | - \| deps: drop duplicate commons-math3 3.0 … |
| intermine | 10 (baseline-wt, im-89g.1-ci-actio…, im-89g.3-maven-pu…...) | maint/im-jqz.7-weak-deps | 05:51 (9m) | - \| deps: remove orphan vendored bobo-brows… |
| intermine | 10 (baseline-wt, im-89g.1-ci-actio…, im-89g.3-maven-pu…...) | maint/im-rkn.3-baseline | 06-12 11:01 (155d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 5 (im-28e.3-gh-actio…, im-7os.1-shadow-c…, im-7os.5-removals...) | maint-2026 | 05:31 (29m) | ahead 44 vs dev \| docs: CI badge and Continuous integrati… |
| bluegenes | 5 (im-28e.3-gh-actio…, im-7os.1-shadow-c…, im-7os.5-removals...) | maint/im-28e.3-gh-actions | 05:31 (29m) | - \| docs: CI badge and Continuous integrati… |
| bluegenes | 5 (im-28e.3-gh-actio…, im-7os.1-shadow-c…, im-7os.5-removals...) | maint/im-7os.1-shadow-cljs | 05:17 (42m) | - \| comments: drop stale lein/figwheel refe… |
| bluegenes | 5 (im-28e.3-gh-actio…, im-7os.1-shadow-c…, im-7os.5-removals...) | maint/im-7os.5-removals | 02:59 (3.0h) | - \| npm: remove unused clipboardy [im-7os.5] |
| bluegenes | 5 (im-28e.3-gh-actio…, im-7os.1-shadow-c…, im-7os.5-removals...) | maint/im-rkn.4-baseline | 01-26 21:58 (657d) | - \| dynamic favicon slows down dx |
| imcljs | 2 (im-7os.3-imcljs-d…) | maint-2026 | 02:46 (3.2h) | ahead 8 vs dev \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| imcljs | 2 (im-7os.3-imcljs-d…) | maint/im-7os.3-imcljs-deps-edn | 02:46 (3.2h) | - \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| im-tables-3 | 2 (im-7os.3-im-table…) | maint-2026 | 11-28 17:19 (1447d) | level vs dev \| Bump version to 0.15.0 |
| im-tables-3 | 2 (im-7os.3-im-table…) | maint/im-7os.3-im-tables-deps-edn | 04:23 (1.6h) | - \| docs: README section for the deps.edn /… |
| bluegenes-tool-store | 2 (im-7os.3-tool-sto…) | maint-2026 | 02:33 (3.4h) | ahead 4 vs master \| deps: remove unused ring/ring-defaults … |
| bluegenes-tool-store | 2 (im-7os.3-tool-sto…) | maint/im-7os.3-tool-store-deps-edn | 02:33 (3.4h) | - \| deps: remove unused ring/ring-defaults … |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

| Start | Bead | Agent | Model | In | Cache | Out | Outcome | Notes |
|---|---|---|---|---|---|---|---|---|
| 05:23 | im-28e.3 | F3 bluegenes GitHub Actions | sonnet | 54 | 2.20M | 32.7k | done | 6 commits; actionlint clean |
| 04:42 | im-7os.1 | E1 pre-merge review | opus | 92 | 4.29M | 36.5k | done | DO NOT MERGE: shim load order breaks bo… |
| 04:16 | im-89g.1 | D1+D2+D4 GitHub Actions, de… | sonnet | 104 | 4.96M | 41.6k | done | 3 commits; actionlint clean |
| 04:16 | im-ee7.2 | B2 batch P plugin rewrite | opus | 202 | 23.89M | 151.4k | done | 1 commit; dependsOn 42->8 stmts; works … |
| 03:33 | im-7os.3 | im-tables-3 deps.edn + shad… | sonnet | 162 | 12.96M | 79.2k | done | 9 commits; tests unverified: FlyMine un… |
| 03:03 | im-7os.1 | E1 bluegenes shadow-cljs mi… | opus | 402 | 54.92M | 177.7k | done | 9 commits; 27/132 tests; uberjar 54->37… |
| 03:03 | im-7os.1 | E1 review fixes | opus | 498 | 77.69M | 223.4k | done | 7 commits; bundle-load gate; determinis… |
| 02:46 | im-jqz.7 | C7 intermine weak-dependenc… | sonnet | 206 | 12.20M | 51.7k | done | 12 commits; 14 declarations removed; ht… |
| 02:46 | im-jqz.1 | C1+C2 JDBC/Hikari/Jackson/j… | sonnet | 88 | 3.70M | 23.1k | done | 6 commits, 85 advisories closed, gate g… |
| 02:45 | im-ee7.1 | B1 Gradle 4.9->6.9.4 | opus | 208 | 16.97M | 71.3k | done | 3 commits; 2277/2279 (flaky pair); depl… |
| 02:25 | im-7os.3 | tool-store deps.edn migrati… | sonnet | 66 | 3.37M | 32.2k | done | 4 commits, gate pass |
| 02:25 | im-7os.3 | imcljs deps.edn + shadow-cl… | sonnet | 122 | 7.56M | 53.9k | done | 8 commits, gate pass, 4 lib bumps beyon… |
| 02:24 | im-7os.5 | bluegenes weak-dependency r… | sonnet | 100 | 3.83M | 25.6k | done | 22 removal commits; npm audit 45->35 |
| 01:55 | im-bdy.2 | Decision records 0001-0006 | sonnet | 14 | 365.6k | 10.9k | done |  |
| 01:55 | im-7os.1 | shadow-cljs migration desig… | opus | 126 | 7.05M | 89.0k | done | decisions/bluegenes-build-migration.md |
| 01:54 | im-ee7 | Gradle upgrade path design … | opus | 168 | 15.81M | 132.1k | done | decisions/gradle-upgrade-path.md |
| 01:51 | im-rkn.4 | A4 bluegenes baseline | sonnet | 164 | 7.26M | 55.7k | done | kaocha 27/27 pass; Debian lein broken; … |
| 01:51 | im-rkn.3 | A3 intermine baseline | opus | 206 | 14.29M | 77.7k | done | 2279 tests pass; gate ~8 min; peak 3.2 … |
| 01:48 | im-8dd.4 | Split plan into per-area do… | sonnet | 10 | 238.7k | 15.2k | done |  |
| 01:48 | im-8dd.2 | Write dashboard generator | sonnet | 28 | 807.1k | 22.9k | done |  |

Showing the 20 most recent of 25 runs.
