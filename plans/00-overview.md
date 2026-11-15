# InterMine + BlueGenes maintenance: plan and multi-agent execution model

## Context

InterMine (Java back end, Gradle 4.9, JDK 8, Postgres) and BlueGenes (ClojureScript front end, ClojureScript 1.10.520, lein-cljsbuild, Cypress 6) have had almost no maintenance since 2022, apart from one person reviving intermine's CI on the old toolchain during 2025-26. Gos is picking the system up and wants (1) a human-readable maintenance plan as .md files, (2) a realistic assessment of running many coding agents in parallel to execute it, with beads/Dolt for coordination, and (3) as much measurable progress as possible in the ~46 hours before 23:00 UK Mon 16 Nov 2026, to inform the Claude subscription renewal on 17 Nov.

The grant application (APP77434, "Scaling InterMine and AllianceMine") sets the feature direction: replace Postgres with QLever (SPARQL), make BlueGenes generate SPARQL and read LinkML/ShACL models, move lists/templates to static files, retire the user-profile DB, web services and ORM, add TogoStanza tools, relicense to Apache 2. This means:

- **intermine back end is "keep the lights on"**: security updates, toolchain modernisation, green tests, modern CI, releasable artefacts. No deep refactoring. This is also what benefits other InterMine deployers now.
- **BlueGenes is the long-lived asset**: it deserves a real toolchain modernisation (shadow-cljs, current ClojureScript/re-frame/React, Node LTS, current Cypress) because all grant-direction UI work builds on it.
- **rdfc2im + mine-tests is the whole-system testbed**: a working mine in ~5-12 minutes, with live tests, is the acceptance test for back-end changes.

## Key findings that shape the plan

**intermine** (`repos/intermine`, branch `dev`, HEAD 77cf7068da, 5.1.1 never released, last release 5.1.0 Aug 2022):
- Seven separate Gradle builds (`plugin/`, `intermine/`, `bio/`, `bio/sources/`, `bio/postprocess/`, `bio/postprocess-test/`, `testmine/`) wired together through local ivy dirs and a generated `gradle.properties` (`config/lib/install_intermine.py`). Wrapper is Gradle **4.9**, not committed.
- Gradle 7+ removes what the build relies on: `compile` (321 lines/92 files), `testCompile`, `runtime`, `maven` plugin + `uploadArchives` (5 files), and the custom Groovy plugin `plugin/src/main/groovy/org/intermine/plugin/**` calls `configurations.getByName("compile")` ~30 times. The plugin is also what every deployer's mine build uses (humanmine/flymine `gradle.properties` pin `imVersion=5.0.+`).
- Ancient deps: Struts 1.3.10 (170 Java files, 207 JSPs), log4j-1.x API via reload4j (351 files), Lucene 3.0.2 + solrj 8.11.4, Jackson 2.2.3, commons-collections 3.2, commons-fileupload 1.2.2, commons-httpclient 3.0, Postgres JDBC 42.2.2, JUnit 4.8.2 (221 files on JUnit 3 API), bcprov 1.50, DWR 2.0.1. javax.* namespace throughout, Tomcat 9 runtime (no Jakarta migration yet).
- Tests need Postgres (10 fixed DB names: `unittest`, `truncunittest`, ..., `bio-test`) and property files in `~/.intermine/`; CI (`.github/workflows/im-build.yml`, push-only trigger, `setup-java@v1`, postgres:14) uses `config/ci/init.sh` + `run.sh`, `ignoreFailures=true` with pass/fail decided by `config/lib/parse_test_report.py`. ~330 test classes.
- Publishing targets dead OSSRH; must move to Central Portal + `maven-publish`.
- No dependabot config in repo. GitHub API from the sandbox returns "Bad credentials" (token secret not set), so the dependabot alert list is not yet readable from here.

**bluegenes** (`repos/bluegenes`, fork `gmicklem/bluegenes` dev == upstream `intermine/bluegenes` dev, 9f340692; version 1.4.5; last real change Jan 2025):
- lein-cljsbuild + lein-figwheel 0.5.19, re-frame 0.12, reagent 0.10 (React 16 via cljsjs), less 1.7.5, Node 10 engine pin, Cypress 6.9.1, ws 7.3.1 (known DoS advisories). CI is CircleCI only (`.circleci/config.yml`), no `.github/`.
- Tests: 35 kaocha-cljs unit tests needing a real Chrome; 22 Cypress specs (~151 tests) against a local **Biotestmine** at `localhost:9999/biotestmine` (built via `intermine_boot`) plus live FlyMine.
- Depends on sibling libraries not in the sandbox: `org.intermine/imcljs 1.6.0`, `im-tables 0.15.0`, `bluegenes-tool-store 0.2.3`. A toolchain modernisation must include them.

**rdfc2im / docker_template / mine-tests**:
- `rdfc2im/tools/full-build.sh` (18 phases, `BUILD.md`) builds a HumanMine-style mine from RDF Portal into its own Compose stack (`rdfc2im/trial/docker-compose.yml`): webapp :8090, BlueGenes :5000, Postgres :15432, Solr :8983. Needs JDK 8, Gradle 4.9 zip, Docker Compose v2, Python venv, network to rdfportal.org/togovar/NLM/reactome. ~5 min warm, ~12 min fresh cache, 9 GB peak RAM. It consumes **published** `org.intermine` 5.0.8 artefacts from Maven, so testing *our* back-end changes requires pointing it at locally built artefacts (mavenLocal) and our webapp war.
- docker_template is the production deployment template (HumanMine/FlyMine), not the 5-minute path. mine-tests (pytest + Playwright 1.58) tests a deployed mine by URL (`mines.toml`, `--url-override`).

**Sandbox environment**: Ubuntu 26.04 arm64 VM, 10 cores, **15 GB RAM** (not the Mac's 32), 653 GB free on the project mount, passwordless sudo, Docker 29, Go 1.27, Node 22, Python 3.14, JDK 25 only. apt has openjdk-8/11/17/21, postgresql-18, leiningen 2.11.2, chromium. Network: GitHub, clojars, repo.maven.apache.org, plugins.gradle.org, services.gradle.org, npm, PyPI, Ubuntu apt, Docker Hub, rdfportal.org, humanmine.org, flymine.org all reachable. **Blocked pending approval**: `repo1.maven.org` (intermine's configured Maven Central URL), `intermine.org` (contribution guide), `download.clojure.org`, `api.adoptium.net`, `oss.sonatype.org`, `jitpack.io`.

**beads** (`repos/beads`): Dolt-backed issue tracker for agents. `npm install -g @beads/bd` or `make build` from the checkout. Embedded mode (`bd init`) is single-writer (file lock); server mode (`bd init --server`) needs a `dolt sql-server`. Core loop: `bd create/ready/update --claim/close/dep add/show/list --json`, `bd status` for stats. No web UI, no token tracking. `.beads/` is shared by all worktrees of a repo.

## Strategy decisions (recommended, with rationale)

1. **Upgrade Gradle, do not switch build systems.** The custom plugin is the deployer-facing build tool; switching to Maven would break every mine and require rewriting the plugin from scratch. Path: 4.9 -> 6.9.4 (still accepts `compile`, shows every deprecation with `--warning-mode all`) -> 7.6.4 (`compile`->`implementation`/`api`, `maven`->`maven-publish`) -> 8.14 -> later 9.x. Why it aged so fast: Gradle 4->7 (2018-2021) was an unusually breaking stretch (configuration rename, jcenter shutdown, plugin rewrite). Since 7, breakage per major is far smaller, a version catalog plus dependabot/renovate makes bumps routine, and Gradle warns one major ahead. Expect a modest upgrade every ~2 years, not another rewrite.
2. **JDK target: run on 17 (verify 21), keep Tomcat 9 / javax.** Jakarta migration (Tomcat 10+) is a separate later item; Struts 1 is retired by the grant direction, so do not replace it, only patch around it.
3. **Two tiers of back-end dependency work.** Tier 1 (do now, non-breaking for deployers' Java code): Postgres JDBC, Jackson, commons-*, bcprov, Jena, solrj, JUnit 4.13, HikariCP, servlet-api stays 3.1/4.0. Tier 2 (grant will retire): Struts, DWR, Lucene 3, profile DB; only CVE-driven minimal patches.
4. **BlueGenes: migrate to shadow-cljs + deps.edn**, current ClojureScript, re-frame 1.4/reagent 1.2 (React 18), Node 22, Cypress 13+, GitHub Actions CI with a local mine from the rdfc2im stack (replacing CircleCI + intermine_boot). Upgrade imcljs/im-tables/tool-store in lockstep.
5. **Branching.** Per repo: long-lived integration branch `maint-2026` cut from `dev`. Each agent task works in its own git worktree on `maint/<beads-id>-<slug>` branched from `maint-2026`. The orchestrator merges a task branch only after the repo's gate script passes on the merged result, then pushes `maint-2026` to the remote at every checkpoint. **All remotes are under `gmicklem/`** (Gos's decision): `gmicklem/intermine` (fork of intermine/intermine, created with `gh repo fork --clone=false` if absent, added as remote `fork`), `gmicklem/bluegenes` (existing), `gmicklem/imcljs`, `gmicklem/im-tables-3`, `gmicklem/bluegenes-tool-store`, `gmicklem/humanmine`, `gmicklem/flymine` as needed, and the planning repo `gmicklem/intermine-planning`. Nothing is pushed to intermine/* or intermineorg/*. Final step later: PRs `gmicklem:maint-2026 -> intermine:dev` following the contribution guide, squashed into reviewable chunks.
5b. **Dependency hygiene rules (Gos's requests).**
   - *Weak-dependency census first*: for every third-party library in intermine (Java), bluegenes (Clojure/ClojureScript/npm) and the sibling libs, count the files that import it and the distinct APIs used (`inventory/dependency-usage.md`). A library used in one place, or only for something the JDK/Clojure core provides, is removed by inlining or substituting rather than upgraded. If it is used in several places but removal is easy, use judgement and remove; otherwise upgrade. Each removal is its own commit so it can be reverted alone.
   - *Vetting replacements*: whenever a package is swapped for a different one (not merely bumped), the worker fetches its source, checks the maintainer/release history, and reads the code for malware indicators (network calls, eval/reflection on untrusted input, obfuscation, install scripts, binary blobs) and for convoluted code that would be a maintenance liability. Result, verdict and reasons go in `decisions/package-vetting.md` even when judged safe, flagged "for discussion with Gos". A failed vet blocks the swap.
   - *Gradle `dependsOn`*: when touching a build file, replace explicit `dependsOn` with implicit wiring through task inputs/outputs (`tasks.named(...)`, `outputs.files`, `sourceSets` outputs, lazy `Provider`s) where the relationship is really a data dependency. Keep explicit `dependsOn` only for genuine lifecycle ordering (e.g. test DB creation before `test`) and note each remaining one with a comment. Done progressively through B1-B3, not as a separate pass.
6. **"Each commit tested"** = the worker must run the gate script before committing, and the orchestrator re-runs it on the merge result. The gate scripts live in the planning repo (`scripts/gate-intermine.sh`, `scripts/gate-bluegenes.sh`) and are the single definition of done for a commit.
7. **Beads: adopt it, embedded mode, orchestrator is the only writer.** Workers receive the issue text in their prompt and return a structured result; the orchestrator updates beads. This avoids the single-writer lock problem without running a Dolt server, and keeps the task graph consistent. Switch to `bd init --server` only if multiple Claude Code sessions need to write concurrently. Issues map to plan items; mechanical batches (e.g. "convert build.gradle files in bio/sources, batch 2/4") are one issue each with a checklist, labelled `batch`.
8. **Models.** Fable (this session) orchestrates, writes plans, reviews merges. Opus for judgement-heavy work: Gradle plugin port, shadow-cljs migration, diagnosing test failures with unclear causes, code review before merge. Sonnet for mechanical work with a clear gate: build-file conversions, dependency bumps, CI YAML, docs, test fixes with a clear failing message. Model is set per agent via the Agent tool's `model` parameter (or per `agent()` call in a Workflow script).
9. **Concurrency limits (15 GB RAM).** At most 2 concurrent intermine test runs (each Gradle `-Xmx4g` + forked tests) or 1 intermine run + 1 BlueGenes advanced compile; the rdfc2im stack (9 GB peak) runs alone. Light tasks (docs, YAML, inventories, reviews) are unlimited. Per-task Postgres isolation: each worktree gets its own `HOME` with `~/.intermine/*.properties` pointing at DB names suffixed by the task id, created by `scripts/im-testenv.sh <id>`. Shared `~/.gradle` and `~/.m2` caches.

## Workstreams and beads epics

Each is a beads epic; bullets become issues. Order within the sprint is in the schedule below.

**A. Environment and baseline (no code changes)**
- Install toolchain: apt openjdk-8/11/17/21, postgresql-18 (plus `postgres:14` container for CI parity if needed), leiningen, chromium, poppler-utils, docker compose plugin check; `bd` via npm; gradle-4.9 zip for rdfc2im.
- Clone missing repos into `repos/`: `intermine/imcljs`, `intermine/im-tables-3`, `intermine/bluegenes-tool-store`.
- Baseline intermine: run `config/ci/init.sh` + `run.sh` equivalents locally on JDK 8 / Gradle 4.9 / Postgres 18 (and 14 if 18 fails). Record pass/fail per subproject, wall time, peak RSS -> `baselines/intermine-2026-11-15.md`.
- Baseline bluegenes: `lein cljfmt check`, `lein kaocha` with chromium, `lein prod` uberjar. Record.
- Baseline testbed: `rdfc2im/tools/full-build.sh`, then `make test-live` and `mine-tests` with `--url-override`. Record time and failures. Cache `cached_raw_data/` for reuse.
- Dependency and CVE inventory for intermine and bluegenes (from build files + GitHub advisory DB; dependabot alerts once the GitHub token works) -> `inventory/dependencies.md`, each CVE-bearing dep becomes a Tier 1 or Tier 2 issue.
- Dependency usage census (rule 5b): per library, files importing it and APIs used -> `inventory/dependency-usage.md`; libraries used once or trivially replaceable become "remove" issues rather than "upgrade" issues.

**B. intermine build toolchain**
- B1 Gradle 4.9 -> 6.9.4 across all seven builds and the plugin; commit wrapper properties; build + tests green on JDK 8. (Opus spike, then Sonnet batches)
- B2 Gradle 7.6.4: `compile`/`testCompile`/`runtime` -> `implementation`/`api`/`testImplementation`/`runtimeOnly` (batched by build: intermine/*, bio/*, bio/sources, bio/postprocess*, testmine), plugin `getByName("compile")` -> configuration-aware code, `maven` -> `maven-publish`, `classifier`/`destinationDir`/`reports.html.enabled` fixes.
- B3 Gradle 8.14; remove `com.sun.xml.internal` property; version catalog `gradle/libs.versions.toml` shared via generated properties.
- B4 JDK 17 build and test run (toolchains), then 21 verification; fix `--illegal-access` fallout (reflection in objectstore/torque, antlr 2 caching jar).
- B5 Update humanmine and flymine `gradle.properties`/`build.gradle` as deployer examples + `docs/UPGRADING-build.md` migration guide for deployers.

**C. intermine dependencies (Tier 1 security)**
- Postgres JDBC 42.7.x, HikariCP 5, Jackson 2.17+, commons-collections4 / commons-io 2.16 / commons-lang3 where API allows or minimal patch otherwise, commons-fileupload 1.5, bcprov 1.78, Jena 4.x (check RDF export tests), solrj 9 only if Solr server bumps are acceptable (else 8.11.x latest), JUnit 4.13.2, xmlunit, remove duplicate commons-math3, drop vendored jars where a Maven artefact exists. One issue per dep group; gate = full tests.

**D. intermine CI and release**
- GitHub Actions: `pull_request` trigger, `setup-java@v4` matrix {8 (until B4), 17, 21} x postgres {14, 16}, Gradle cache, concurrency groups; migrate `speed-up-solr-in-workflow` branch ideas (Docker Solr).
- `.github/dependabot.yml` for gradle, github-actions.
- Publishing: `maven-publish` + Central Portal plugin, signing via env; document release steps (`docs/RELEASING.md`). Actual 5.1.1/6.0.0 release is a human step with Sonatype credentials.
- Fix PR template, CONTRIBUTING.md (link to guide, branch rules), README badges.

**E. BlueGenes toolchain**
- E1 shadow-cljs + deps.edn build reproducing `dev`, `prod`, `kaocha` targets; keep `lein` shim or document the switch; Node 22, drop `less 1.7.5` for current lessc; Docker image on temurin 21.
- E2 Library bumps: ClojureScript current, re-frame 1.4.x, reagent 1.2.x (React 18), reitit, cljs-http/clj-http, ring 1.12, timbre; fix breakage.
- E3 imcljs / im-tables-3 / bluegenes-tool-store: same toolchain, release to Clojars (human step) or consume via git deps during the sprint.
- E4 CDN assets: pin versions with SRI or bundle; bump vega/vega-lite.
- E5 Security: ws, wait-on, xmlhttprequest; `npm audit` clean.

**F. BlueGenes tests and CI**
- kaocha unit tests green under new toolchain (headless chromium).
- Cypress 13+ migration (`cy.server/route` -> `cy.intercept`), target the rdfc2im stack's mine instead of Biotestmine (fixtures need re-recording against the demo mine), FlyMine-dependent specs tagged `external`.
- GitHub Actions: cljfmt + kaocha on PR; nightly Cypress using a cached rdfc2im build.

**G. Whole-system testbed**
- Make `rdfc2im/tools/full-build.sh` consume local `org.intermine` artefacts (`mavenLocal()` / `intermine.development.*` dirs) and the webapp war from a given intermine worktree; flag `--intermine-src DIR`.
- Run `mine-tests` against the local stack; add fixtures for the demo mine (`mines.toml` entry `local`).
- This is the end-to-end acceptance test for B/C: "modernised intermine builds the demo mine and mine-tests pass".

**H. Docs and governance**
- `docs/` in intermine: building, testing locally (new `scripts/`), upgrading Gradle/JDK for deployers, release process.
- Decision records (`decisions/*.md`) in the planning repo: Gradle upgrade vs switch, JDK target, Struts stance, BlueGenes build tool, beads usage, branching.

**I. Planning repo, beads, dashboard**
- Create `repos/intermine-planning` (proposed GitHub name: `intermineorg/intermine-planning`; alternative `intermine-maintenance`), layout: `README.md`, `plans/00-overview.md`, `plans/10-intermine-backend.md`, `plans/20-bluegenes.md`, `plans/30-testbed.md`, `plans/40-agent-execution.md`, `decisions/`, `baselines/`, `inventory/`, `scripts/` (gate scripts, `im-testenv.sh`, `worktree.sh`, `dashboard.py`, `transcript.py`), `status/STATUS.md` (generated), `status/agent-runs.csv` (one row per agent run: beads id, model, start, end, tokens in/out/cache, outcome), `.beads/`.
- Dashboard: `scripts/dashboard.py` reads `bd list --json`/`bd status --json`, `git worktree list` + last commit times, and the Claude Code session logs (`~/.claude/projects/<proj>/*.jsonl` and the scratchpad `tasks/*.output`, which carry per-message `usage`) to compute per-agent tokens and liveness (stalled = no log write for 10 min). Writes `status/STATUS.md` (committed and pushed, readable from a phone on GitHub) and `status/index.html`; the orchestrator also republishes it as a Claude artifact at each checkpoint. This is not something beads provides on its own.
- Transcript: `scripts/transcript.py` converts this session's JSONL (`/home/agent/.claude/projects/-Users-gos-claude-projects-update-intermine-planning-repos/0492e8a9-74f1-4807-9fab-46d9cc2516dd.jsonl`) to `/Users/gos/claude_projects/update_intermine_planning/transcript.md` (user and assistant text, tool calls summarised one line each); regenerated at every checkpoint.

## Execution model in practice

- **Orchestrator**: this Fable session. It owns beads, merges, pushes, the dashboard, the transcript, and the plan docs. It never runs long builds itself; it delegates.
- **Workers**: Agent tool subagents (`model: sonnet|opus`) for single tasks, each given: the beads issue text, the worktree path, the gate command, the commit-message convention (`<area>: <summary> [bd-xxxx]`), and the instruction to return a short structured report (what changed, gate result, follow-ups discovered). For fan-out batches (e.g. build-file conversion across 90 files) a Workflow script runs the batch with a verify step. Workers do not touch beads, `maint-2026`, or remotes.
- **Reviewer**: an Opus agent reviews each task branch diff against the issue before merge for anything beyond a mechanical bump.
- **Checkpoints** every ~3 hours while unattended: merge green branches, push, regenerate STATUS.md and transcript, republish the artifact, write a 5-line summary into `status/LOG.md`.
- **What Gos sees**: `status/STATUS.md` on GitHub, the artifact dashboard, and `/tasks` in Claude Code when online. Token totals per model and per task type feed the renewal decision in `status/sprint-report.md` on Monday.

## 48-hour sprint schedule (UK time)

- **Sat 00:30-01:30 (now, Gos online)**: approve plan; Gos runs the host commands below; orchestrator sets up toolchain, planning repo, beads, baselines kick off.
- **Sat 01:30-10:30 (Gos offline)**: Epic A entirely (baselines, inventories, testbed build), B1 (Gradle 6.9.4) spike and batches, E1 spike (shadow-cljs build of current code), dependency inventory. Checkpoints at ~04:30, ~07:30, ~10:30 with pushed STATUS.md.
- **Sat 10:30-23:00**: review with Gos; land B1, start B2 (Gradle 7.6) in batches; Tier 1 dependency bumps that are independent of Gradle version; BlueGenes E1/E2; CI workflows (D).
- **Sun**: B2/B3 (Gradle 8), B4 (JDK 17), remaining C, F (Cypress migration), G (testbed consuming local artefacts).
- **Mon until 23:00**: stabilise, full gates on `maint-2026` for both repos, deployer migration guide (B5), `status/sprint-report.md` with per-model token/time/outcome table and recommendations for next month.

Realism note: B1-B3 together are the critical path and the largest single risk. If B2 proves slow, the fallback that still helps deployers is: Gradle 6.9.4 + Tier 1 dependency bumps + modern CI, shipped as 5.1.1, with Gradle 8/JDK 17 as 6.0.

## Actions needed from Gos on the host

1. Network approvals: done (`sbx policy allow network repo1.maven.org,intermine.org,download.clojure.org`).
2. GitHub token for user gmicklem (sufficient for everything in this plan), set as the sandbox secret. **Verified 15 Nov 2026: the sandbox token authenticates as `gmicklem` with scopes repo, workflow, read:org and push access.** The orchestrator still checks `gh api user` reports `gmicklem` before each remote operation as a safety guard.
   ```bash
   gh auth login            # if the host gh is not logged in yet
   gh auth refresh -h github.com -s repo,workflow,read:org
   sbx secret set github --sandbox claude-repos -t "$(gh auth token)"
   ```
   `workflow` scope is required to push `.github/workflows/*` changes; `repo` covers forks, pushes, PRs and `gh repo create`. Dependabot alert reading on `intermine/intermine` additionally needs `security_events` and admin/security access on that repo; if unavailable, the CVE inventory uses the GitHub Advisory DB and build-file versions instead.
3. Memory: the sandbox VM reports 15 GB. Not changed tonight; concurrency limits in this plan assume 15 GB. If `sbx create --help` shows a memory flag, a new sandbox could be created later, but that would start a fresh session.

## Decisions confirmed by Gos (15 Nov 2026)

- All GitHub work under `gmicklem/*`; planning repo `gmicklem/intermine-planning`; non-default branches pushed to `gmicklem/intermine`.
- Cloning BlueGenes sibling repos and installing beads/dolt tooling: approved.
- Public HumanMine/FlyMine read-only for tests: approved.
- Breaking changes for deployers acceptable once Tier 1 security + Gradle 6.9.4 is landable as a non-breaking 5.1.1.
- Dependency hygiene rules in 5b (weak-dependency removal, replacement vetting log, reduce explicit `dependsOn`).

## Verification

- Every task: gate script passes in the worktree (intermine: `./gradlew install` for upstream builds + `build` for touched builds + `checkstyleMain`, parsed by `config/lib/parse_test_report.py`; bluegenes: `cljfmt check` + kaocha + prod build; cypress at merge time).
- Every merge to `maint-2026`: full gate on the merged tree; for intermine also `rdfc2im/tools/full-build.sh --intermine-src` + `make test-live` + `mine-tests` once G lands.
- Baselines in `baselines/` are the reference: no regression in passing test count relative to baseline is allowed.
- End of sprint: `maint-2026` of both repos pushed, CI green on GitHub Actions for the integration branch, STATUS.md and sprint-report.md committed, transcript.md current.
