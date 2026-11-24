# STATUS 2026-11-24 23:00 UTC

Generated 2026-11-24 23:00 UTC / 2026-11-24 23:00 GMT. Sprint dashboard for the InterMine and BlueGenes maintenance effort.

Times are UTC. Agent state: running = unfinished and written to in the last 10 min; stalled = unfinished and silent for 10 min or more; finished = last message ended its turn (no tool call pending).

Subagents: 0 running, 2 stalled, 257 finished.

## Beads summary

bd status: total 386, open 45, in progress 7, blocked 0, ready 45, deferred 0, closed 334.

| Status | Count |
|---|---|
| closed | 334 |
| in_progress | 7 |
| open | 45 |

### By priority (tasks and bugs; epics counted apart)

| Priority | open | in progress | blocked | deferred | closed | total | closed % | epics |
|---|---|---|---|---|---|---|---|---|
| P0 | 0 | 2 | 0 | 0 | 14 | 16 | 88% | 2 |
| P1 | 2 | 0 | 0 | 0 | 62 | 64 | 97% | 5 |
| P2 | 10 | 4 | 0 | 0 | 158 | 172 | 92% | 3 |
| P3 | 23 | 1 | 0 | 0 | 100 | 124 | 81% | 0 |
| all | 35 | 7 | 0 | 0 | 334 | 376 | 89% | 10 |

### im-28e Epic F: BlueGenes tests and CI [open, 13/13 closed]

No open child issues.

### im-7os Epic E: BlueGenes toolchain modernisation [open, 60/64 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-7os.33 | HUMAN (Gos): release imcljs 1.7.0, im-tables 0.16… | open | 1 | epic |
| im-7os.62 | bluegenes: reagent upstream fixed the keystroke l… | open | 2 | epic |
| im-7os.16 | bluegenes dev advisories needing majors: Cypress … | open | 3 | bluegenes,epic,security |
| im-7os.29 | bluegenes: imjs 4.0.0 unmaintained since 2020 (no… | open | 3 | epic |

### im-89g Epic D: intermine CI and release pipeline [open, 31/32 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-89g.7 | D3 follow-up: test real Central Portal upload (ce… | open | 1 | epic,followup,human,intermine |

### im-8dd Epic I: Planning repo, beads, dashboard [open, 11/12 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-8dd.2 | I2 Dashboard generator (STATUS.md, index.html) an… | in_progress | 0 | epic |

### im-9n4 EPIC: hybrid HumanMine testbed: rdfc2im (RDF-port… [open, 44/58 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-9n4.18 | T1.14 Reinstate repos/sequence-alignment-service … | open | 2 |  |
| im-9n4.32 | T1.1b Hybrid: MSA viewer works for panel genes: m… | in_progress | 2 |  |
| im-9n4.42 | Data-source status pages: per-build manifest (URL… | in_progress | 2 |  |
| im-9n4.45 | Licences: record the licence each data source sta… | in_progress | 2 |  |
| im-9n4.24 | T2.5 Ask Genomics England whether they would publ… | open | 3 |  |
| im-9n4.25 | T3.1 Prepare the DBCLS server (about 256 GB RAM) … | open | 3 |  |
| im-9n4.28 | T3.4 Converter fixes found by current upstream fi… | in_progress | 3 |  |
| im-9n4.29 | T3.5 Decide replaced-or-stock per overlapping sou… | open | 3 |  |
| im-9n4.30 | T3.6 First full build on the DBCLS server; watch,… | open | 3 |  |
| im-9n4.31 | T3.7 Count comparison against public HumanMine, p… | open | 3 |  |
| im-9n4.33 | intermine ncbi-gff (NcbiGffGFF3RecordHandler), fo… | open | 3 |  |
| im-9n4.51 | Stock converters that cannot be given a DataSet l… | open | 3 |  |
| im-9n4.53 | protein2ipr: refetch so NCBIfam matches load (abo… | open | 3 |  |
| im-9n4.58 | [bug] intermine GtexConverter always stores the D… | open | 3 |  |

### im-bdy Epic H: Docs and governance [open, 15/22 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-bdy.10 | intermine.org hosting (docs/INTERMINE_ORG_HOSTING… | open | 2 | epic |
| im-bdy.13 | InterMine Registry migration off Heroku-16 (EOL):… | in_progress | 2 | epic |
| im-bdy.19 | registry: logo cache fell back to AquaMine's favi… | open | 2 | epic |
| im-bdy.9 | Expert review queue: docs/EXPERT_TO_CHECK.md in t… | open | 2 | epic |
| im-bdy.23 | registry: docker-compose.example.yml publishes 30… | open | 3 | epic |
| im-bdy.24 | registry: instances.edn header and README say PRs… | open | 3 | epic |
| im-bdy.25 | docs: INTERMINE_ORG_HOSTING.md still recommends M… | open | 3 | epic |

### im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> … [open, 66/68 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ee7.69 | intermine after a release with the StAX flush fix… | open | 3 | epic |
| im-ee7.71 | bio-sources forks: humanmine/flymine wars carry c… | open | 3 | epic |

### im-jqz Epic C: intermine Tier 1 dependency upgrades and … [open, 61/67 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-jqz.10 | intermine: HikariCP 5.x once JDK 11+ baseline lan… | open | 2 | epic |
| im-jqz.14 | intermine: JAXB/annotation shims (inventory R14) … | open | 3 | epic |
| im-jqz.23 | intermine: drop commons-io once build is on JDK 1… | open | 3 | epic |
| im-jqz.59 | 6.0 Java 17 baseline follow-ups from im-jqz.5: Je… | open | 3 | epic |
| im-jqz.61 | HUMAN: check whether metabolicmine.org and esyn.o… | open | 3 | epic |
| im-jqz.65 | bio-source-chado-db SequenceProcessor lines ~1028… | open | 3 | epic |

### im-ore Epic G: Whole-system testbed [open, 20/21 closed]

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ore.18 | rdfc2im demo mine data, next steps (BUILD.md 'Wha… | open | 3 | epic |

### im-rkn Epic A: Environment and baseline [open, 10/10 closed]

No open child issues.

### No parent epic

| ID | Title | Status | P | Labels |
|---|---|---|---|---|
| im-ct0 | Embargoed maintenance item (details held locally,… | in_progress | 0 |  |
| im-4sz | Add SECURITY.md to intermine/intermine (how to re… | open | 2 |  |
| im-dh5 | Work through docs/PROJECT-ACCESS.md: regain acces… | open | 2 |  |
| im-pg7 | Enable private vulnerability reporting on intermi… | open | 2 |  |
| im-rj1 | supply-chain screening for automated bumps (docs/… | open | 2 |  |
| im-v51 | bluegenes: config switch to fetch non-production … | open | 3 |  |

## Agents

| Agent | Model | State | Started | Last | In | Cache | Out |
|---|---|---|---|---|---|---|---|
| main session | fable-5-2 | idle | 22:09 | 22:16 | 40 | 1.62M | 8.9k |
| Read-only survey of the InterMine Java back… | opus-5-5 | finished | 11-15 00:18 | 11-15 00:20 | 42 | 1.05M | 9.0k |
| Read-only survey of BlueGenes, the ClojureS… | opus-5-5 | finished | 11-15 00:18 | 11-15 00:20 | 22 | 347.5k | 8.3k |
| Read-only survey of four repos under /Users… | opus-5-5 | finished | 11-15 00:18 | 11-15 00:21 | 26 | 863.6k | 7.5k |
| You are a worker in a multi-agent maintenan… | sonnet-5-5 | finished | 11-15 01:47 | 11-15 02:07 | 182 | 16.47M | 133.5k |
| You are a worker in a multi-agent maintenan… | sonnet-5-5 | finished | 11-15 01:47 | 11-15 02:04 | 162 | 12.90M | 113.7k |
| Write a Python 3 script `/Users/gos/claude_… | sonnet-5-5 | finished | 11-15 01:48 | 11-15 01:50 | 28 | 807.1k | 22.9k |
| In /Users/gos/claude_projects/update_interm… | sonnet-5-5 | finished | 11-15 01:48 | 11-15 01:49 | 10 | 238.7k | 15.2k |
| You are a worker in a multi-agent maintenan… | opus-5-5 | finished | 11-15 01:51 | 11-15 02:44 | 206 | 14.29M | 77.7k |
| You are a worker in a multi-agent maintenan… | sonnet-5-5 | finished | 11-15 01:51 | 11-15 02:23 | 164 | 7.26M | 55.7k |
| You are a worker in a multi-agent maintenan… | opus-5-5 | finished | 11-15 01:54 | 11-15 02:18 | 168 | 15.81M | 132.1k |
| You are a worker in a multi-agent maintenan… | opus-5-5 | finished | 11-15 01:55 | 11-15 02:10 | 126 | 7.05M | 89.0k |
| In /Users/gos/claude_projects/update_interm… | sonnet-5-5 | finished | 11-15 01:55 | 11-15 01:56 | 14 | 365.6k | 10.9k |
| Worker task for beads issue im-7os.5 in the… | sonnet-5-5 | finished | 11-15 02:24 | 11-15 03:02 | 100 | 3.83M | 25.6k |
| Worker task for beads issue im-7os.3 (sibli… | sonnet-5-5 | finished | 11-15 02:25 | 11-15 02:47 | 122 | 7.56M | 53.9k |
| Worker task for beads issue im-7os.3 (sibli… | sonnet-5-5 | finished | 11-15 02:25 | 11-15 02:36 | 66 | 3.37M | 32.2k |
| Worker task for beads issue im-ee7.1 (B1: G… | opus-5-5 | finished | 11-15 02:45 | 11-15 04:01 | 208 | 16.97M | 71.3k |
| Worker task for beads issues im-jqz.1 (Post… | sonnet-5-5 | finished | 11-15 02:46 | 11-15 03:32 | 88 | 3.70M | 23.1k |
| Worker task for beads issue im-jqz.7 (C7: w… | sonnet-5-5 | finished | 11-15 02:46 | 11-15 05:52 | 206 | 12.20M | 51.7k |
| Worker task for beads issue im-7os.1 (E1: B… | opus-5-5 | finished | 11-15 03:03 | 11-15 05:22 | 498 | 77.69M | 223.4k |
| Worker task for beads issue im-7os.3 (sibli… | sonnet-5-5 | finished | 11-15 03:33 | 11-15 04:23 | 162 | 12.96M | 79.2k |
| Worker task for beads issue im-ee7.2, batch… | opus-5-5 | finished | 11-15 04:16 | 11-15 05:07 | 202 | 23.89M | 151.4k |
| Worker task for beads issues im-89g.1 (D1: … | sonnet-5-5 | finished | 11-15 04:16 | 11-15 06:54 | 172 | 10.09M | 66.6k |
| You are the pre-merge reviewer for a multi-… | opus-5-5 | finished | 11-15 04:42 | 11-15 04:50 | 92 | 4.29M | 36.5k |
| Worker task for beads issue im-28e.3 (F3: G… | sonnet-5-5 | finished | 11-15 05:23 | 11-15 05:31 | 54 | 2.20M | 32.7k |
| Worker task for beads issue im-89g.3 (D3: i… | sonnet-5-5 | finished | 11-15 05:24 | 11-15 09:40 | 260 | 25.10M | 106.6k |
| Worker task for beads issue im-ee7.2, batch… | sonnet-5-5 | finished | 11-15 06:00 | 11-15 06:35 | 164 | 11.43M | 71.2k |
| Worker task for beads issue im-ee7.2, batch… | sonnet-5-5 | finished | 11-15 06:00 | 11-15 09:43 | 264 | 21.38M | 91.4k |
| Worker task for beads issue im-ee7.2, batch… | sonnet-5-5 | finished | 11-15 06:36 | 11-15 07:16 | 154 | 9.55M | 60.0k |
| Worker task for beads issues im-jqz.8 and i… | opus-5-5 | finished | 11-15 07:04 | 11-15 07:31 | 112 | 5.52M | 37.5k |
| You are a worker agent on the InterMine/Blu… | sonnet-5-5 | finished | 11-15 09:44 | 11-15 09:48 | 32 | 836.1k | 13.0k |
| You are a worker agent on the InterMine/Blu… | opus-5-5 | finished | 11-15 09:47 | 11-15 10:21 | 218 | 17.94M | 59.9k |
| You are a worker agent on the InterMine 202… | opus-5-5 | finished | 11-15 09:51 | 11-15 10:30 | 250 | 18.88M | 86.0k |
| You are a worker agent on the InterMine 202… | sonnet-5-5 | finished | 11-15 09:53 | 11-15 09:57 | 64 | 3.67M | 33.4k |
| You are a worker agent on the InterMine/Blu… | sonnet-5-5 | finished | 11-15 09:54 | 11-15 09:55 | 24 | 610.7k | 5.9k |
| You are a worker agent on the InterMine/Blu… | sonnet-5-5 | finished | 11-15 09:59 | 11-15 10:01 | 16 | 543.9k | 18.9k |
| You are a worker agent on the BlueGenes 202… | opus-5-5 | finished | 11-15 10:17 | 11-15 11:09 | 238 | 16.22M | 82.5k |
| You are a worker agent on the InterMine 202… | opus-5-5 | finished | 11-15 10:34 | 11-15 11:36 | 168 | 12.51M | 44.2k |
| You are a worker agent on the InterMine 202… | opus-5-5 | finished | 11-15 10:34 | 11-15 11:09 | 108 | 6.62M | 38.0k |
| You are a worker agent on the InterMine 202… | sonnet-5-5 | finished | 11-15 11:13 | 11-15 11:52 | 134 | 7.66M | 48.8k |
| You are a worker agent on the BlueGenes 202… | sonnet-5-5 | finished | 11-15 11:39 | 11-15 11:49 | 54 | 1.73M | 21.7k |
| You are a worker agent on the BlueGenes 202… | opus-5-5 | finished | 11-15 11:51 | 11-15 12:05 | 88 | 3.62M | 29.0k |
| You are a worker agent on the BlueGenes 202… | sonnet-5-5 | finished | 11-15 11:51 | 11-15 11:59 | 42 | 1.01M | 8.6k |
| You are a worker agent on the InterMine 202… | opus-5-5 | finished | 11-15 11:54 | 11-15 13:28 | 370 | 33.21M | 100.4k |
| You are a worker agent on the InterMine 202… | opus-5-5 | finished | 11-15 12:01 | 11-15 13:08 | 254 | 26.91M | 120.8k |
| You are a worker agent on the BlueGenes 202… | opus-5-5 | finished | 11-15 12:07 | 11-15 12:49 | 148 | 8.78M | 41.2k |
| You are a worker agent on the BlueGenes 202… | opus-5-5 | finished | 11-15 12:51 | 11-15 14:34 | 382 | 40.91M | 98.8k |
| You are a worker agent on the InterMine 202… | sonnet-5-5 | finished | 11-15 13:11 | 11-15 13:21 | 74 | 2.57M | 16.5k |
| You are a worker agent on the InterMine 202… | sonnet-5-5 | finished | 11-15 13:22 | 11-15 13:30 | 72 | 2.83M | 26.8k |
| You are a worker agent on the InterMine 202… | opus-5-5 | finished | 11-15 13:30 | 11-15 16:45 | 356 | 35.34M | 123.4k |
| You are a worker agent on the InterMine 202… | sonnet-5-5 | finished | 11-15 13:31 | 11-15 15:02 | 178 | 10.92M | 58.0k |
| You are a worker agent in the InterMine/Blu… | sonnet-5-5 | finished | 11-15 14:47 | 11-15 16:43 | 146 | 7.70M | 42.3k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | finished | 11-15 15:04 | 11-15 15:54 | 134 | 7.75M | 55.6k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | finished | 11-15 15:55 | 11-15 16:32 | 134 | 5.89M | 42.7k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | finished | 11-15 16:46 | 11-15 17:36 | 118 | 5.40M | 36.0k |
| You are a worker agent in the InterMine/Blu… | sonnet-5-5 | finished | 11-15 16:48 | 11-15 17:09 | 120 | 5.65M | 38.8k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | finished | 11-15 17:08 | 11-15 17:41 | 118 | 5.14M | 35.7k |
| You are a worker agent in the BlueGenes mai… | sonnet-5-5 | finished | 11-15 17:11 | 11-16 06:15 | 114 | 4.17M | 23.8k |
| You are a worker agent in the BlueGenes mai… | sonnet-5-5 | finished | 11-15 17:35 | 11-15 17:52 | 102 | 3.96M | 29.7k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | finished | 11-15 17:37 | 11-15 18:49 | 190 | 12.19M | 60.3k |
| You are a worker agent in the BlueGenes mai… | sonnet-5-5 | finished | 11-15 17:54 | 11-16 04:23 | 464 | 55.31M | 164.8k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | finished | 11-15 17:59 | 11-16 04:23 | 228 | 17.91M | 99.6k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | finished | 11-15 18:49 | 11-15 19:37 | 204 | 16.14M | 83.7k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | finished | 11-15 18:52 | 11-15 19:39 | 192 | 10.79M | 59.2k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | finished | 11-15 19:41 | 11-15 20:38 | 124 | 6.38M | 42.2k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | finished | 11-15 19:57 | 11-15 20:15 | 112 | 5.77M | 37.6k |
| You are a worker agent in the BlueGenes mai… | sonnet-5-5 | finished | 11-15 20:18 | 11-15 21:53 | 268 | 22.84M | 94.5k |
| You are a worker agent in the BlueGenes mai… | sonnet-5-5 | finished | 11-15 20:19 | 11-15 20:24 | 38 | 1.31M | 16.1k |
| You are a worker agent in the InterMine mai… | sonnet-5-5 | stalled 9d | 11-15 20:40 | 11-15 22:00 | 32 | 956.0k | 9.4k |
| You are a worker in the InterMine/BlueGenes… | opus-5-5 | finished | 11-15 21:56 | 11-15 23:15 | 254 | 18.13M | 86.3k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-15 21:57 | 11-15 22:08 | 126 | 9.15M | 51.4k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-15 22:01 | 11-15 22:25 | 144 | 6.17M | 32.0k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-15 22:10 | 11-15 22:15 | 62 | 2.92M | 28.3k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-15 22:17 | 11-15 22:18 | 10 | 225.8k | 3.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-15 22:27 | 11-15 22:54 | 186 | 10.61M | 48.3k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-15 22:56 | 11-15 23:12 | 140 | 6.50M | 39.4k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-15 23:14 | 11-15 23:23 | 38 | 964.4k | 12.3k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-15 23:17 | 11-16 04:23 | 94 | 3.66M | 19.3k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | stalled 8d | 11-15 23:24 | 11-15 23:47 | 30 | 1.11M | 13.5k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-15 23:48 | 11-16 00:01 | 62 | 1.95M | 13.6k |
| You are a worker in the InterMine/BlueGenes… | opus-5-5 | finished | 11-15 23:51 | 11-16 01:23 | 248 | 19.84M | 66.2k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 00:03 | 11-16 00:14 | 88 | 3.14M | 23.5k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 00:03 | 11-16 00:13 | 36 | 809.6k | 6.0k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 00:04 | 11-16 00:55 | 118 | 7.33M | 44.5k |
| noop | haiku-5-5 | finished | 11-16 00:11 | 11-16 00:11 | 2 | 9.4k | 112 |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 00:16 | 11-16 00:37 | 134 | 6.25M | 44.5k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 00:19 | 11-16 00:47 | 212 | 14.30M | 67.7k |
| Embargoed item | sonnet-5-5 | finished | 11-16 00:19 | 11-16 00:21 | 28 | 733.9k | 10.9k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 00:23 | 11-17 23:38 | 80 | 2.13M | 10.5k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 00:40 | 11-17 23:38 | 110 | 6.02M | 42.2k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 00:50 | 11-16 00:58 | 74 | 2.11M | 15.0k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 01:00 | 11-16 04:23 | 174 | 9.21M | 54.6k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 01:01 | 11-16 01:11 | 60 | 1.65M | 13.6k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 01:13 | 11-17 23:38 | 132 | 4.21M | 22.7k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 01:14 | 11-16 04:23 | 132 | 5.29M | 25.9k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 01:31 | 11-16 01:36 | 60 | 2.11M | 19.6k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 01:37 | 11-17 23:38 | 36 | 714.3k | 4.4k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-16 01:46 | 11-16 03:17 | 316 | 37.57M | 139.5k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 01:54 | 11-16 02:36 | 212 | 15.25M | 65.5k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 02:39 | 11-16 03:24 | 298 | 27.12M | 125.0k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 03:19 | 11-16 04:05 | 244 | 19.42M | 81.3k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 03:25 | 11-16 03:55 | 184 | 11.93M | 59.1k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 03:57 | 11-16 04:09 | 208 | 16.03M | 69.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 04:07 | 11-16 04:34 | 164 | 7.56M | 40.4k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 04:11 | 11-16 04:14 | 50 | 1.83M | 17.6k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 04:15 | 11-17 23:38 | 224 | 12.71M | 65.9k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 04:35 | 11-17 23:38 | 60 | 1.44M | 8.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 05:03 | 11-16 05:26 | 260 | 22.07M | 88.4k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 05:13 | 11-16 05:35 | 144 | 6.93M | 55.0k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 05:28 | 11-16 05:31 | 36 | 1.11M | 13.3k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 05:32 | 11-17 23:38 | 196 | 10.24M | 54.1k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 05:36 | 11-16 05:50 | 102 | 3.00M | 15.6k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 05:48 | 11-16 06:03 | 104 | 3.59M | 24.6k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 06:05 | 11-16 06:22 | 106 | 3.79M | 28.8k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 06:10 | 11-16 06:18 | 82 | 2.48M | 16.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 06:21 | 11-17 23:38 | 70 | 2.52M | 15.5k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-16 06:24 | 11-16 06:47 | 180 | 9.30M | 55.2k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 06:46 | 11-17 23:38 | 26 | 523.7k | 3.4k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 06:49 | 11-16 06:56 | 32 | 682.7k | 4.6k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 06:58 | 11-16 07:30 | 224 | 13.16M | 56.1k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 07:05 | 11-16 07:44 | 244 | 13.96M | 64.7k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 07:06 | 11-16 07:11 | 86 | 3.27M | 30.7k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 07:13 | 11-16 07:33 | 54 | 1.48M | 15.7k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 07:34 | 11-16 07:43 | 72 | 2.21M | 13.9k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 07:44 | 11-16 07:58 | 84 | 2.85M | 22.1k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 07:45 | 11-16 08:05 | 36 | 885.1k | 7.1k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-16 08:00 | 11-16 08:23 | 188 | 12.77M | 73.4k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 08:12 | 11-17 23:38 | 94 | 3.56M | 23.9k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 08:25 | 11-17 23:38 | 144 | 6.37M | 34.5k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 08:54 | 11-16 09:16 | 100 | 4.00M | 23.8k |
| You are a worker in the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-16 09:01 | 11-16 09:04 | 48 | 1.49M | 20.1k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 09:19 | 11-16 09:41 | 150 | 6.84M | 48.7k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 09:19 | 11-16 09:30 | 74 | 3.33M | 30.5k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 09:32 | 11-16 09:46 | 156 | 9.08M | 45.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 09:43 | 11-16 09:56 | 56 | 1.88M | 17.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 11:39 | 11-16 12:10 | 108 | 4.21M | 29.3k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-16 11:40 | 11-16 12:50 | 340 | 32.47M | 108.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 11:40 | 11-16 12:37 | 236 | 15.36M | 60.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 11:59 | 11-16 12:15 | 58 | 1.44M | 9.2k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 13:19 | 11-17 23:38 | 148 | 8.04M | 47.2k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 13:19 | 11-16 13:43 | 208 | 11.62M | 48.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 13:20 | 11-16 13:24 | 90 | 2.99M | 19.9k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 13:21 | 11-16 14:02 | 166 | 8.72M | 47.3k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 13:45 | 11-17 23:38 | 150 | 4.93M | 16.6k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-16 15:02 | 11-16 16:19 | 300 | 24.66M | 88.5k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 15:03 | 11-16 16:13 | 410 | 42.20M | 121.2k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 15:03 | 11-16 16:18 | 390 | 51.48M | 155.0k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 15:04 | 11-17 23:38 | 166 | 7.86M | 35.7k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 15:04 | 11-16 16:02 | 166 | 8.05M | 45.1k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 15:33 | 11-16 16:14 | 158 | 8.37M | 50.6k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 15:33 | 11-16 15:42 | 136 | 6.03M | 43.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 16:16 | 11-16 16:28 | 62 | 1.63M | 11.6k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 16:31 | 11-16 17:33 | 200 | 13.22M | 58.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 16:31 | 11-16 16:59 | 250 | 22.06M | 94.7k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 16:32 | 11-16 17:10 | 348 | 35.22M | 128.4k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 16:33 | 11-17 23:38 | 136 | 6.15M | 37.5k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 17:35 | 11-17 23:38 | 158 | 7.78M | 36.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 17:36 | 11-16 18:12 | 552 | 50.47M | 99.3k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 17:41 | 11-16 18:00 | 104 | 4.82M | 31.4k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 18:01 | 11-16 18:21 | 114 | 4.97M | 27.6k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-16 18:02 | 11-16 18:33 | 220 | 21.46M | 130.7k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 18:03 | 11-16 18:10 | 58 | 2.07M | 30.5k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 18:14 | 11-16 18:56 | 104 | 4.41M | 28.9k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 18:22 | 11-16 18:38 | 64 | 2.12M | 16.4k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 18:24 | 11-16 18:33 | 76 | 2.51M | 10.4k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 18:34 | 11-17 23:38 | 62 | 1.79M | 12.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 18:36 | 11-16 18:40 | 60 | 2.94M | 25.7k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 18:53 | 11-16 18:54 | 24 | 709.0k | 11.2k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 18:58 | 11-16 19:12 | 244 | 23.07M | 73.8k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 19:14 | 11-16 19:24 | 110 | 4.67M | 33.2k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 20:16 | 11-16 20:18 | 44 | 1.20M | 9.9k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 20:28 | 11-16 21:11 | 162 | 8.73M | 40.4k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-16 23:40 | 11-17 00:01 | 56 | 1.59M | 11.0k |
| concerning the homebrew installations for h… | fable-5-1 | finished | 11-17 01:28 | 11-17 01:28 | 4 | 716.4k | 428 |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-17 02:18 | 11-17 02:36 | 152 | 10.94M | 94.9k |
| You are a worker on the new InterMine Regis… | sonnet-5-5 | finished | 11-17 02:44 | 11-17 02:49 | 58 | 2.61M | 37.1k |
| You are a worker on the new InterMine Regis… | sonnet-5-5 | finished | 11-17 02:51 | 11-17 02:59 | 84 | 5.04M | 58.7k |
| You are a worker on the InterMine Registry … | opus-5-5 | finished | 11-17 09:06 | 11-17 09:18 | 114 | 7.70M | 46.3k |
| You are a worker on the InterMine Registry … | opus-5-5 | finished | 11-17 09:43 | 11-17 09:50 | 80 | 4.30M | 31.2k |
| You are a worker on the InterMine Registry … | opus-5-5 | finished | 11-17 10:29 | 11-17 10:40 | 108 | 6.50M | 53.7k |
| You are a worker on the InterMine Registry … | sonnet-5-5 | finished | 11-17 11:43 | 11-17 11:47 | 42 | 1.46M | 14.9k |
| You are a worker on the BlueGenes (ClojureS… | opus-5-5 | finished | 11-17 11:59 | 11-17 13:56 | 118 | 4.43M | 27.2k |
| You are a worker on the BlueGenes (ClojureS… | opus-5-5 | finished | 11-17 14:44 | 11-17 15:03 | 128 | 6.00M | 35.9k |
| You are a worker on the InterMine Registry … | sonnet-5-5 | finished | 11-17 14:46 | 11-17 14:47 | 16 | 355.7k | 5.5k |
| You are a technical writer-engineer on the … | opus-5-5 | finished | 11-17 14:47 | 11-17 14:58 | 54 | 2.50M | 66.8k |
| You are a worker on the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-17 17:03 | 11-17 17:11 | 42 | 930.9k | 8.4k |
| You are a worker on the InterMine (Java/Gra… | sonnet-5-5 | finished | 11-17 18:38 | 11-17 18:41 | 32 | 861.2k | 15.3k |
| You are a worker on the BlueGenes (ClojureS… | sonnet-5-5 | finished | 11-17 18:38 | 11-17 18:48 | 80 | 3.67M | 32.2k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-17 18:39 | 11-17 18:48 | 108 | 5.38M | 35.9k |
| You are a planning analyst on the InterMine… | opus-5-5 | finished | 11-17 20:58 | 11-17 22:03 | 242 | 22.15M | 115.1k |
| READ-ONLY task. Do not modify any file, do … | opus-5-5 | finished | 11-17 21:04 | 11-17 21:06 | 28 | 846.7k | 13.0k |
| READ-ONLY task. Do not modify any file, do … | opus-5-5 | finished | 11-17 21:04 | 11-17 21:11 | 126 | 4.59M | 31.6k |
| READ-ONLY task. Do not modify any file. `bd… | opus-5-5 | finished | 11-17 21:04 | 11-17 21:06 | 20 | 381.0k | 10.7k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-17 22:02 | 11-17 22:07 | 16 | 309.7k | 7.5k |
| You are a technical writer on the InterMine… | sonnet-5-5 | finished | 11-17 22:02 | 11-17 22:05 | 12 | 493.2k | 24.8k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-17 23:46 | 11-17 23:51 | 46 | 1.73M | 39.8k |
| You are a worker on the InterMine maintenan… | opus-5-5 | finished | 11-17 23:46 | 11-18 00:23 | 282 | 34.60M | 135.3k |
| You are a worker on the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-17 23:47 | 11-18 00:05 | 90 | 3.50M | 17.8k |
| You are a worker on the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-17 23:48 | 11-17 23:59 | 82 | 3.47M | 33.6k |
| Read-only research, medium thoroughness. Fo… | opus-5-5 | finished | 11-17 23:50 | 11-17 23:55 | 64 | 1.67M | 20.2k |
| You are a worker on the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-17 23:57 | 11-18 00:01 | 52 | 1.52M | 14.7k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 00:24 | 11-18 00:32 | 92 | 5.22M | 42.1k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 00:25 | 11-18 01:26 | 248 | 9.41M | 25.5k |
| You are a worker on the InterMine maintenan… | opus-5-5 | finished | 11-18 00:34 | 11-18 02:08 | 450 | 48.74M | 103.3k |
| You are a worker on the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-18 01:27 | 11-18 01:34 | 48 | 1.81M | 21.4k |
| You are a worker on the InterMine maintenan… | opus-5-5 | finished | 11-18 02:10 | 11-18 03:11 | 404 | 61.11M | 134.2k |
| You are a worker on the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-18 02:11 | 11-18 02:27 | 138 | 8.02M | 50.8k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 02:11 | 11-18 02:21 | 180 | 11.96M | 54.2k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 02:23 | 11-18 02:29 | 132 | 7.25M | 44.7k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 03:13 | 11-18 04:07 | 368 | 36.67M | 109.1k |
| You are a worker on the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-18 03:14 | 11-18 03:33 | 244 | 19.73M | 61.7k |
| You are a worker on the InterMine maintenan… | opus-5-5 | finished | 11-18 04:09 | 11-18 04:59 | 434 | 63.66M | 136.8k |
| You are a worker on the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-18 04:10 | 11-18 04:17 | 98 | 3.88M | 28.8k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 05:02 | 11-18 06:23 | 576 | 70.58M | 110.8k |
| You are a worker on the InterMine maintenan… | opus-5-5 | finished | 11-18 06:27 | 11-18 09:27 | 864 | 178.36M | 238.6k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 09:30 | 11-18 10:30 | 304 | 17.31M | 61.5k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 09:31 | 11-18 10:01 | 308 | 26.73M | 120.6k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 10:32 | 11-18 10:54 | 132 | 10.86M | 86.1k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 11:31 | 11-18 12:10 | 178 | 8.65M | 33.4k |
| Can you find the url of the github issue th… | fable-5-2 | finished | 11-18 11:55 | 11-18 11:55 | 6 | 1.33M | 313 |
| You are a worker on the InterMine maintenan… | opus-5-5 | finished | 11-18 11:59 | 11-18 12:56 | 366 | 55.37M | 167.5k |
| You are helping with task im-9n4.42 (InterM… | opus-5-5 | finished | 11-18 12:06 | 11-18 12:35 | 180 | 18.22M | 69.8k |
| You are helping with task im-9n4.42 (InterM… | opus-5-5 | finished | 11-18 12:06 | 11-18 12:13 | 66 | 3.71M | 42.5k |
| You are helping with task im-9n4.42 (InterM… | opus-5-5 | finished | 11-18 12:07 | 11-18 12:33 | 108 | 10.28M | 68.7k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 12:50 | 11-18 12:56 | 60 | 2.06M | 13.2k |
| I guess you must have updated/created new C… | fable-5-2 | finished | 11-18 19:13 | 11-18 19:14 | 6 | 1.45M | 1.0k |
| You are a worker on the InterMine/BlueGenes… | sonnet-5-5 | finished | 11-18 19:17 | 11-18 19:26 | 172 | 11.63M | 52.9k |
| You are a worker on the InterMine maintenan… | opus-5-5 | finished | 11-18 21:17 | 11-18 21:45 | 238 | 18.85M | 72.5k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 21:18 | 11-18 21:38 | 230 | 21.70M | 116.1k |
| You are a research worker on the InterMine/… | opus-5-5 | finished | 11-18 21:37 | 11-18 21:53 | 206 | 14.16M | 50.3k |
| You are a worker on the InterMine maintenan… | opus-5-5 | finished | 11-18 21:43 | 11-18 23:03 | 494 | 80.75M | 169.4k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-18 21:54 | 11-18 22:12 | 210 | 13.16M | 76.1k |
| Embargoed item | opus-5-5 | finished | 11-19 16:45 | 11-19 17:34 | 362 | 34.28M | 130.7k |
| Embargoed item | opus-5-5 | finished | 11-19 17:36 | 11-19 18:53 | 638 | 92.29M | 206.4k |
| Embargoed item | opus-5-5 | finished | 11-19 17:41 | 11-19 17:55 | 170 | 14.91M | 67.1k |
| Embargoed item | opus-5-5 | finished | 11-19 18:54 | 11-19 19:56 | 340 | 32.96M | 90.9k |
| Embargoed item | sonnet-5-5 | finished | 11-19 21:46 | 11-19 21:54 | 44 | 1.12M | 6.3k |
| Embargoed item | opus-5-5 | finished | 11-19 23:01 | 11-19 23:32 | 228 | 25.64M | 142.8k |
| Embargoed item | opus-5-5 | finished | 11-19 23:44 | 11-20 00:12 | 160 | 9.82M | 37.2k |
| Embargoed item | sonnet-5-5 | finished | 11-19 23:44 | 11-19 23:45 | 28 | 781.2k | 7.0k |
| Embargoed item | opus-5-5 | finished | 11-19 23:45 | 11-20 00:05 | 192 | 18.43M | 119.1k |
| Embargoed item | opus-5-5 | finished | 11-20 00:34 | 11-20 02:24 | 320 | 16.45M | 51.2k |
| Embargoed item | opus-5-5 | finished | 11-20 02:22 | 11-20 03:07 | 610 | 80.05M | 168.3k |
| You are a worker on the InterMine maintenan… | opus-5-5 | finished | 11-20 02:30 | 11-20 03:02 | 400 | 55.65M | 152.4k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-20 03:06 | 11-20 03:14 | 106 | 4.59M | 27.1k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-20 03:09 | 11-20 05:06 | 574 | 87.51M | 194.0k |
| Embargoed item | sonnet-5-5 | finished | 11-20 05:09 | 11-20 05:30 | 270 | 18.60M | 72.3k |
| You are a worker on the InterMine maintenan… | sonnet-5-5 | finished | 11-20 05:33 | 11-20 06:50 | 412 | 43.55M | 112.7k |
| You are a worker in the InterMine maintenan… | sonnet-5-5 | finished | 11-20 09:00 | 11-20 09:46 | 234 | 14.47M | 46.1k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-20 09:01 | 11-20 09:23 | 306 | 36.86M | 114.2k |
| Fetch https://docs.github.com/en/authentica… | haiku-5-5 | finished | 11-20 09:06 | 11-20 09:06 | 4 | 13.1k | 1.5k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-20 09:50 | 11-20 12:19 | 580 | 81.40M | 171.3k |
| You are finding, for several biological dat… | opus-5-5 | finished | 11-20 10:37 | 11-20 10:42 | 92 | 3.77M | 11.9k |
| You are finding, for several biological dat… | opus-5-5 | finished | 11-20 10:37 | 11-20 10:42 | 106 | 3.27M | 13.9k |
| You are finding, for several biological dat… | opus-5-5 | finished | 11-20 10:38 | 11-20 10:47 | 142 | 7.34M | 33.1k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-20 12:55 | 11-20 13:10 | 202 | 16.95M | 82.0k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-20 14:25 | 11-20 15:46 | 440 | 65.41M | 149.8k |
| You are a worker in the InterMine maintenan… | opus-5-5 | finished | 11-20 15:11 | 11-20 15:59 | 288 | 23.87M | 73.1k |
| You are a worker on the InterMine/BlueGenes… | opus-5-5 | finished | 11-20 17:46 | 11-20 18:20 | 194 | 10.27M | 35.7k |
| Embargoed item | fable-5-2 | finished | 11-23 21:42 | 11-23 21:45 | 14 | 549.7k | 19.7k |

Note: 1431 non-agent .output file(s) skipped (empty or plain-text task output)

## Totals by model

| Scope | Model | Msgs | In | Cache rd | Cache wr | Out |
|---|---|---|---|---|---|---|
| main | fable-5-2 | 18 | 40 | 1.54M | 82.2k | 8.9k |
| subagents | fable-5-1 | 1 | 4 | 712.4k | 3.9k | 428 |
| subagents | fable-5-2 | 11 | 26 | 2.54M | 793.9k | 21.0k |
| subagents | haiku-5-5 | 3 | 6 | 3.5k | 19.0k | 1.6k |
| subagents | opus-5-5 | 8567 | 17.4k | 1.81B | 42.38M | 6.20M |
| subagents | sonnet-5-5 | 12026 | 24.4k | 1.56B | 52.96M | 7.73M |

Tokens are de-duplicated per API message (streamed records share one message id).

## Repos and branches

| Repo | WT | Branch | Last commit | vs dev \| subject |
|---|---|---|---|---|
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint-2026 | 11-23 22:29 (24.5h) | ahead 323 vs dev \| Merge maint/im-jqz.69-esyn-release-note… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-89g.1-ci-actions | 11-15 04:45 (9d) | - \| docs: update README badges, PR template… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-89g.1-ci-fix | 11-15 06:28 (9d) | - \| ci: stop using sudo -E -u postgres; con… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-89g.1-ci-fix2 | 11-15 06:54 (9d) | - \| ci: fix PostgreSQL 15+ public schema pr… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-89g.3-maven-publish | 11-15 09:40 (9d) | - \| docs: add RELEASING.md (version bump, b… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-89g.5-ci-actions | 11-15 09:55 (9d) | - \| ci: bump GitHub Actions to current majo… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-9n4.28-protein2ipr-ncbifam | 11-20 05:15 (4d) | - \| [im-9n4.28] protein2ipr: cover NCBIfam … |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-9n4.28-update-data-sources-keys | 11-20 05:21 (4d) | - \| [im-9n4.28] update-data-sources: add th… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-9n4.45-converter-licence-stamps | 11-20 05:26 (4d) | - \| [im-9n4.45] interpro-go: DataSet licenc… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-9n4.46-converter-fixes | 11-18 21:43 (6d) | - \| [im-9n4.46] psi: IntAct DataSet licence… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-9n4.56-rebuild-fixes | 11-20 10:04 (4d) | - \| [im-9n4.54] interpro and go-annotation … |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-ee7.1-gradle-6 | 11-15 03:57 (9d) | - \| build: default to Gradle 6.9.4 and veri… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-ee7.2-batch-bio | 11-15 09:32 (9d) | - \| build(bio): fold copyMineProperties int… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-ee7.2-batch-intermine | 11-15 06:21 (9d) | - \| intermine: convert all build files to G… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-ee7.2-batch-sources | 11-15 07:16 (9d) | - \| testmine: convert build files to Gradle… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-ee7.2-gradle-76-flip | 11-15 10:27 (9d) | - \| build: root testReport tasks use the Gr… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-ee7.2-plugin-gradle7 | 11-15 05:06 (9d) | - \| build(plugin): lazy tasks, no init task… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-ee7.3-catalog-modules | 11-15 11:52 (9d) | - \| docs: describe the version catalog; the… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-ee7.3-gradle-814-flip | 11-15 13:27 (9d) | - \| build(plugin): addStrutsConfig no longe… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-ee7.3-plugin-gradle8 | 11-15 11:34 (9d) | - \| merge: maint-2026 (ROOTS+TESTRES batch)… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-ee7.3-roots-testres | 11-15 11:09 (9d) | - \| build: version catalog gradle/libs.vers… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-jqz.1-jdbc-jackson | 11-15 03:31 (9d) | - \| deps: drop duplicate commons-math3 3.0 … |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-jqz.7-weak-deps | 11-15 05:51 (9d) | - \| deps: remove orphan vendored bobo-brows… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-jqz.8-flaky-tests | 11-15 07:24 (9d) | - \| integrate: make DataTracker.clear() saf… |
| intermine | 18 (im-89g.12-511-tes…, im-9n4.56-rebuild…, (withheld)...) | maint/im-rkn.3-baseline | 06-12 11:01 (165d) | - \| Merge pull request #2460 from intermine… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint-2026 | 11-20 18:56 (4d) | ahead 156 vs dev \| Merge maint/im-9n4.61-pubmed-link-pin: … |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-28e.2-cypress-13 | 11-15 11:09 (9d) | - \| docs, cypress: how to run the suite; ta… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-28e.3-gh-actions | 11-15 05:31 (9d) | - \| docs: CI badge and Continuous integrati… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-7os.1-shadow-cljs | 11-15 05:17 (9d) | - \| comments: drop stale lein/figwheel refe… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-7os.10-npm-advisories | 11-15 11:58 (9d) | - \| deps: override qs to 6.17.1 (same major… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-7os.18-sibling-deps | 11-15 12:49 (9d) | - \| docs: how the sibling libraries are pin… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-7os.4-cdn-sri | 11-15 11:48 (9d) | - \| script: cdn-sri.sh prints SRI hashes fo… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-7os.5-removals | 11-15 02:59 (9d) | - \| npm: remove unused clipboardy [im-7os.5] |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-7os.62-reagent-pr690 | 11-17 18:15 (7d) | - \| renovate: use the shared gmicklem prese… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-7os.63-reagent-snap2 | 11-16 18:40 (8d) | - \| Merge maint/im-89g.30-changelog: CHANGE… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-89g.5-ci-actions | 11-15 09:55 (9d) | - \| ci: bump GitHub Actions to current majo… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-9n4.44-demo-data | 11-18 19:27 (6d) | - \| [im-9n4.44] nightly: pin rdfc2im to be8… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-9n4.61-pubmed-link-pin | 11-20 18:04 (4d) | - \| [im-9n4.61] im-tables b70e43c: a PubMed… |
| bluegenes | 4 (im-9n4.61-pubmed-…, im-7os.62-reagent…, im-7os.63-reagent…) | maint/im-rkn.4-baseline | 01-26 21:58 (667d) | - \| dynamic favicon slows down dx |
| imcljs | 1 | maint-2026 | 11-17 18:48 (7d) | ahead 15 vs dev \| Merge maint/im-8dd.11-ci: GitHub Action… |
| imcljs | 1 | maint/im-7os.3-imcljs-deps-edn | 11-15 02:46 (9d) | - \| deps: bump clj-http 3.10.0 to 3.13.0 [i… |
| im-tables-3 | 2 (im-9n4.61-pubmed-…) | maint-2026 | 11-23 21:58 (25.0h) | ahead 51 vs dev \| Merge maint/im-jqz.69-esyn-removal: rem… |
| im-tables-3 | 2 (im-9n4.61-pubmed-…) | maint/im-7os.3-im-tables-deps-edn | 11-15 12:05 (9d) | - \| test: lein kaocha honours IM_TABLES_SER… |
| im-tables-3 | 2 (im-9n4.61-pubmed-…) | maint/im-9n4.61-pubmed-link | 11-20 17:53 (4d) | - \| [im-9n4.61] A Publication.pubMedId cell… |
| bluegenes-tool-store | 1 | maint-2026 | 11-17 18:48 (7d) | ahead 22 vs master \| Merge maint/im-8dd.11-ci: GitHub Action… |
| bluegenes-tool-store | 1 | maint/im-7os.3-tool-store-deps-edn | 11-15 02:33 (9d) | - \| deps: remove unused ring/ring-defaults … |
| bluegenes-tool-store | 1 | maint/im-7os.6-tool-store-fixes | 11-15 09:48 (9d) | - \| deps: bump commons-compress 1.19 -> 1.2… |

WT = number of git worktrees (extra ones named). Branches shown: maint-2026 and maint/*.

## Recent agent runs

| Start | Bead | Agent | Model | In | Cache | Out | Outcome | Notes |
|---|---|---|---|---|---|---|---|---|
| 11-23 21:42 | im-ct0 | Embargoed item | opus-5.5 | 14 | 549.7k | 19.7k | done |  |
| 11-20 18:06 | im-9n4.61 | PubMed id cell links to Pub… | opus | 0 | 0 | 0 | success | [tokens: 166763 total from the task not… |
| 11-20 15:46 | im-9n4.59 | Ensembl and GWAS panel by c… | opus | 0 | 0 | 0 | success | [tokens: 451420 total from the task not… |
| 11-20 15:24 | im-9n4.60 | All data sources template, … | opus | 0 | 0 | 0 | success | [tokens: 216923 total from the task not… |
| 11-20 13:10 | im-9n4.55 | Ensembl joined by cross-ref… | opus | 0 | 0 | 0 | success | [tokens: 252852 total from the task not… |
| 11-20 12:19 | im-9n4.56 | citation run | opus | 0 | 0 | 0 | success | [tokens: 465547 cumulative] run 2,126 s… |
| 11-20 10:56 | im-9n4.56 | blockers fixed, Pfam, citat… | opus | 0 | 0 | 0 | success | [tokens: 428339 total from the task not… |
| 11-20 09:46 | im-9n4.27 | E-utilities sources added t… | sonnet | 0 | 0 | 0 | success | [tokens: 183337 total from the task not… |
| 11-20 09:23 | im-9n4.52 | data-set versions from the … | opus | 0 | 0 | 0 | success | [tokens: 363593 total from the task not… |
| 11-20 06:53 | im-9n4.50 | drop workarounds, licence p… | sonnet | 0 | 0 | 0 | success | [tokens: 359214 total from the task not… |
| 11-20 05:32 | im-9n4.28 | T3.4 converter fixes + lice… | sonnet | 0 | 0 | 0 | success | [tokens: 217072 total from the task not… |
| 11-20 05:08 | im-9n4.27 | T3.3 remaining sources + im… | sonnet | 0 | 0 | 0 | success | [tokens: 521111 total from the task not… |
| 11-20 03:16 | im-9n4.45 | licences: Ensembl, DepMap, … | sonnet | 0 | 0 | 0 | success | [tokens: 120359 total from the task not… |
| 11-20 03:08 | im-ct0 | Embargoed item | opus | 0 | 0 | 0 | success |  |
| 11-20 03:05 | im-9n4.48 | cited-PMID set, scope full,… | opus | 0 | 0 | 0 | success | [tokens: 462989 total from the task not… |
| 11-20 02:50 | im-ct0 | Embargoed item | opus | 0 | 0 | 0 | success |  |
| 11-20 02:25 | im-ct0 | Embargoed item | opus | 0 | 0 | 0 | success |  |
| 11-20 00:12 | im-ct0 | Embargoed item | opus | 0 | 0 | 0 | success |  |
| 11-20 00:06 | im-ct0 | Embargoed item | opus | 0 | 0 | 0 | success |  |
| 11-19 23:46 | im-z8j | remove PhytoMine from regis… | sonnet | 0 | 0 | 0 | success | [tokens: 71213 total from the task noti… |

Showing the 20 most recent of 248 runs.
