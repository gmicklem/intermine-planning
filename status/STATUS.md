# STATUS 2026-11-15 01:53 UTC

Generated 2026-11-15 01:53 UTC / 2026-11-15 01:53 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 4 running, 0 stalled, 5 finished.

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-1 | running | 11-14 22:38 | 01:53 | 1.1k | 5.91M | 80.0k |
| Survey intermine build/test state | opus-5-5 | finished | 00:18 | 00:20 | 42 | 1.05M | 9.0k |
| Survey bluegenes build/test state | opus-5-5 | finished | 00:18 | 00:20 | 22 | 347.5k | 8.3k |
| Survey rdfc2im, docker_template, mine-tests… | opus-5-5 | finished | 00:18 | 00:21 | 26 | 863.6k | 7.5k |
| intermine dependency census and CVE invento… | sonnet-5-5 | running | 01:47 | 01:53 | 56 | 2.32M | 28.5k |
| bluegenes dependency census and inventory | sonnet-5-5 | running | 01:47 | 01:53 | 68 | 3.01M | 31.7k |
| Write dashboard generator script | sonnet-5-5 | finished | 01:48 | 01:50 | 28 | 807.1k | 22.9k |
| Split master plan into per-area plan docs | sonnet-5-5 | finished | 01:48 | 01:49 | 10 | 238.7k | 15.2k |
| A3 intermine baseline build and tests | opus-5-5 | running | 01:51 | 01:53 | 40 | 1.30M | 7.8k |
| A4 bluegenes baseline build and tests | sonnet-5-5 | running | 01:51 | 01:52 | 18 | 390.3k | 3.5k |

Note: 3 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-1 | 48 | 1.1k | 5.69M | 213.4k | 80.0k |
| subagents | opus-5-5 | 65 | 130 | 3.26M | 305.1k | 32.6k |
| subagents | sonnet-5-5 | 90 | 180 | 6.36M | 398.9k | 101.8k |

Tokens are de-duplicated per API message (streamed records share one message id).

## Beads summary

bd status: total 49, open 41, in progress 4, blocked 24, ready 17, deferred 0, closed 4.

| Status | Count |
|---|---|
| closed | 4 |
| in_progress | 4 |
| open | 41 |

### im-28e Epic F: BlueGenes tests and CI [open, 0/3 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-28e.1 | F1 kaocha unit tests green on new toolchain | open | 1 | epic |
| im-28e.2 | F2 Cypress 13+ migration targeting the rdfc2im mi… | open | 1 | epic |
| im-28e.3 | F3 GitHub Actions for bluegenes (cljfmt, kaocha, … | open | 2 | epic |

### im-7os Epic E: BlueGenes toolchain modernisation [open, 0/5 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.1 | E1 shadow-cljs + deps.edn build reproducing dev/p… | open | 0 | epic |
| im-7os.2 | E2 Library bumps: ClojureScript, re-frame 1.4, re… | open | 1 | epic |
| im-7os.3 | E3 imcljs / im-tables-3 / bluegenes-tool-store on… | open | 1 | epic |
| im-7os.5 | E5 npm security: ws, wait-on, xmlhttprequest; npm… | open | 1 | epic |
| im-7os.4 | E4 CDN assets pinned with SRI or bundled; vega bu… | open | 2 | epic |

### im-89g Epic D: intermine CI and release pipeline [open, 0/4 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-89g.1 | D1 GitHub Actions: pull_request trigger, setup-ja… | open | 1 | epic |
| im-89g.3 | D3 maven-publish + Central Portal publishing; doc… | open | 1 | epic |
| im-89g.2 | D2 .github/dependabot.yml (gradle, github-actions) | open | 2 | epic |
| im-89g.4 | D4 PR template, CONTRIBUTING.md, README badges | open | 3 | epic |

### im-8dd Epic I: Planning repo, beads, dashboard [open, 2/5 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-8dd.2 | I2 Dashboard generator (STATUS.md, index.html) an… | in_progress | 0 | epic |
| im-8dd.4 | I4 Per-area plan docs 10/20/30/40 | in_progress | 1 | epic |
| im-8dd.5 | I5 Sprint report for renewal decision (tokens/tim… | open | 1 | epic |

### im-bdy Epic H: Docs and governance [open, 0/2 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-bdy.2 | H2 Decision records: gradle-upgrade-vs-switch, jd… | open | 2 | epic |
| im-bdy.3 | H1 intermine docs: building, local testing, upgra… | open | 2 | epic |

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 0/5 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.1 | B1 Gradle 4.9 -> 6.9.4 across all seven builds an… | open | 0 | epic |
| im-ee7.2 | B2 Gradle 7.6.4: compile->implementation/api, mav… | open | 0 | epic |
| im-ee7.3 | B3 Gradle 8.14, remove com.sun.xml.internal prope… | open | 1 | epic |
| im-ee7.4 | B4 JDK 17 build and test run; JDK 21 verification | open | 1 | epic |
| im-ee7.5 | B5 Deployer migration: update humanmine/flymine b… | open | 1 | epic |

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 0/7 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.1 | C1 Postgres JDBC 42.7.x + HikariCP | open | 0 | epic |
| im-jqz.2 | C2 Jackson 2.17+, org.json, everit json-schema | open | 0 | epic |
| im-jqz.3 | C3 commons-* (collections, io, lang, fileupload, … | open | 0 | epic |
| im-jqz.4 | C4 bcprov, oltu, JOpenId, DWR CVE check (Tier 2 m… | open | 1 | epic |
| im-jqz.6 | C6 JUnit 4.13.2, xmlunit, mockobjects/easymock cl… | open | 1 | epic |
| im-jqz.7 | C7 Weak-dependency removals from the usage census | open | 1 | epic |
| im-jqz.5 | C5 Jena 4.x, solrj latest 8.x, Lucene 3 stance | open | 2 | epic |

### im-ore Epic G: Whole-system testbed [open, 0/2 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ore.1 | G1 rdfc2im --intermine-src: consume local org.int… | open | 1 | epic |
| im-ore.2 | G2 mine-tests fixtures for the local demo mine (m… | open | 2 | epic |

### im-rkn Epic A: Environment and baseline [open, 2/7 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-rkn.3 | Baseline: intermine build and tests on JDK 8 / Gr… | open | 0 | baseline,epic |
| im-rkn.4 | Baseline: bluegenes cljfmt, kaocha (chromium), pr… | open | 0 | baseline,epic |
| im-rkn.6 | Inventory: intermine dependencies, CVEs and usage… | in_progress | 0 | epic,inventory |
| im-rkn.7 | Inventory: bluegenes + sibling libs dependencies,… | in_progress | 0 | epic,inventory |
| im-rkn.5 | Baseline: rdfc2im full-build + make test-live + m… | open | 1 | baseline,epic |

## Repos and branches

| Repo | WT | Branch | Last commit | vs dev \| subject |
|---|---|---|---|---|
| intermine | 2 (im-rkn.3-baseline) | maint-2026 | 06-12 11:01 (155d) | level vs dev \| Merge pull request #2460 from intermine… |
| intermine | 2 (im-rkn.3-baseline) | maint/im-rkn.3-baseline | 06-12 11:01 (155d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 2 (im-rkn.4-baseline) | maint-2026 | 01-26 21:58 (657d) | level vs dev \| dynamic favicon slows down dx |
| bluegenes | 2 (im-rkn.4-baseline) | maint/im-rkn.4-baseline | 01-26 21:58 (657d) | - \| dynamic favicon slows down dx |
| imcljs | 1 | no maint branches | - | on dev |
| im-tables-3 | 1 | no maint branches | - | on dev |
| bluegenes-tool-store | 1 | no maint branches | - | on master |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

status/agent-runs.csv has a header but no runs recorded yet.
