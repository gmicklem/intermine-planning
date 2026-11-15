# InterMine back end: maintenance plan

This document covers the maintenance plan for the InterMine Java back end (Gradle 4.9, JDK 8, Postgres), covering what was found in the repository, the strategy decisions that apply to it, the work to be done on the build toolchain, dependencies, CI and release, and the rules for verifying each change. The guiding stance is "keep the lights on": security updates, toolchain modernisation, green tests, modern CI and releasable artefacts, with no deep refactoring. It is written for a maintainer who has not read the master overview (`00-overview.md`).

Related: [00-overview.md](00-overview.md) (master plan), [20-bluegenes.md](20-bluegenes.md), [30-testbed.md](30-testbed.md) (whole-system acceptance test), [40-agent-execution.md](40-agent-execution.md) (branching, gates, agents, schedule).

## Context

InterMine has had almost no maintenance since 2022, apart from one person reviving its CI on the old toolchain during 2025-26. The grant application (APP77434, "Scaling InterMine and AllianceMine") sets the feature direction: replace Postgres with QLever (SPARQL), move lists/templates to static files, retire the user-profile DB, web services and ORM, and relicense to Apache 2. Because of that direction, the back end does not get deep refactoring. The work is limited to security updates, toolchain modernisation, green tests, modern CI and releasable artefacts, which is also what benefits other InterMine deployers now.

## Findings

Repository `repos/intermine`, branch `dev`, HEAD 77cf7068da. Version 5.1.1 was never released; the last release was 5.1.0 in Aug 2022.

- Seven separate Gradle builds (`plugin/`, `intermine/`, `bio/`, `bio/sources/`, `bio/postprocess/`, `bio/postprocess-test/`, `testmine/`) are wired together through local ivy dirs and a generated `gradle.properties` (`config/lib/install_intermine.py`). The wrapper is Gradle **4.9** and is not committed.
- Gradle 7+ removes what the build relies on: `compile` (321 lines in 92 files), `testCompile`, `runtime`, and the `maven` plugin with `uploadArchives` (5 files). The custom Groovy plugin `plugin/src/main/groovy/org/intermine/plugin/**` calls `configurations.getByName("compile")` about 30 times. That plugin is also what every deployer's mine build uses (humanmine and flymine `gradle.properties` pin `imVersion=5.0.+`).
- Ancient dependencies: Struts 1.3.10 (170 Java files, 207 JSPs), log4j-1.x API via reload4j (351 files), Lucene 3.0.2 plus solrj 8.11.4, Jackson 2.2.3, commons-collections 3.2, commons-fileupload 1.2.2, commons-httpclient 3.0, Postgres JDBC 42.2.2, JUnit 4.8.2 (221 files on the JUnit 3 API), bcprov 1.50, DWR 2.0.1. The `javax.*` namespace is used throughout, on a Tomcat 9 runtime (no Jakarta migration yet).
- Tests need Postgres (10 fixed DB names: `unittest`, `truncunittest`, ..., `bio-test`) and property files in `~/.intermine/`. CI (`.github/workflows/im-build.yml`, push-only trigger, `setup-java@v1`, postgres:14) uses `config/ci/init.sh` and `run.sh`, with `ignoreFailures=true` and pass/fail decided by `config/lib/parse_test_report.py`. There are about 330 test classes.
- Publishing targets the dead OSSRH; it must move to Central Portal plus `maven-publish`.
- There is no dependabot config in the repo. The GitHub API from the sandbox originally returned "Bad credentials", so the dependabot alert list was not readable at first; the token has since been set up (see the overview). If dependabot alert reading on `intermine/intermine` is unavailable (it needs `security_events` and admin/security access), the CVE inventory uses the GitHub Advisory DB and build-file versions instead.

## Strategy decisions

1. **Upgrade Gradle, do not switch build systems.** The custom plugin is the deployer-facing build tool; switching to Maven would break every mine and require rewriting the plugin from scratch. Path: 4.9 -> 6.9.4 (still accepts `compile`, shows every deprecation with `--warning-mode all`) -> 7.6.4 (`compile` -> `implementation`/`api`, `maven` -> `maven-publish`) -> 8.14 -> later 9.x. Why it aged so fast: Gradle 4->7 (2018-2021) was an unusually breaking stretch (configuration rename, jcenter shutdown, plugin rewrite). Since 7, breakage per major is far smaller, a version catalog plus dependabot/renovate makes bumps routine, and Gradle warns one major ahead. Expect a modest upgrade every ~2 years, not another rewrite.
2. **JDK target: run on 17 (verify 21), keep Tomcat 9 / javax.** Jakarta migration (Tomcat 10+) is a separate later item. Struts 1 is retired by the grant direction, so do not replace it, only patch around it.
3. **Two tiers of back-end dependency work.**
   - Tier 1 (do now, non-breaking for deployers' Java code): Postgres JDBC, Jackson, commons-*, bcprov, Jena, solrj, JUnit 4.13, HikariCP; servlet-api stays 3.1/4.0.
   - Tier 2 (the grant will retire these): Struts, DWR, Lucene 3, profile DB. Only CVE-driven minimal patches.
5b. **Dependency hygiene rules (Gos's requests).**
   - *Weak-dependency census first*: for every third-party library in intermine (Java), and in the other repos, count the files that import it and the distinct APIs used (`inventory/dependency-usage.md`). A library used in one place, or only for something the JDK provides, is removed by inlining or substituting rather than upgraded. If it is used in several places but removal is easy, use judgement and remove; otherwise upgrade. Each removal is its own commit so it can be reverted alone.
   - *Vetting replacements*: whenever a package is swapped for a different one (not merely bumped), the worker fetches its source, checks the maintainer and release history, and reads the code for malware indicators (network calls, eval/reflection on untrusted input, obfuscation, install scripts, binary blobs) and for convoluted code that would be a maintenance liability. The result, verdict and reasons go in `decisions/package-vetting.md` even when judged safe, flagged "for discussion with Gos". A failed vet blocks the swap.
   - *Gradle `dependsOn`*: when touching a build file, replace explicit `dependsOn` with implicit wiring through task inputs/outputs (`tasks.named(...)`, `outputs.files`, `sourceSets` outputs, lazy `Provider`s) where the relationship is really a data dependency. Keep explicit `dependsOn` only for genuine lifecycle ordering (for example test DB creation before `test`) and note each remaining one with a comment. This is done progressively through B1-B3, not as a separate pass.

## Baselines and inventories (Epic A, intermine parts)

These involve no code changes and provide the reference for the verification rules below.

- Baseline intermine: run the `config/ci/init.sh` and `run.sh` equivalents locally on JDK 8 / Gradle 4.9 / Postgres 18 (and 14 if 18 fails). Record pass/fail per subproject, wall time and peak RSS in `baselines/intermine-2026-11-15.md`.
- Dependency and CVE inventory for intermine (from build files and the GitHub advisory DB; dependabot alerts once the GitHub token works) in `inventory/dependencies.md`. Each CVE-bearing dependency becomes a Tier 1 or Tier 2 issue.
- Dependency usage census (rule 5b): per library, files importing it and APIs used, in `inventory/dependency-usage.md`. Libraries used once or trivially replaceable become "remove" issues rather than "upgrade" issues.

## Workstreams

Each workstream is a beads epic; bullets become issues.

### B. intermine build toolchain

- **B1** Gradle 4.9 -> 6.9.4 across all seven builds and the plugin; commit wrapper properties; build and tests green on JDK 8. (Opus spike, then Sonnet batches.)
- **B2** Gradle 7.6.4: `compile`/`testCompile`/`runtime` -> `implementation`/`api`/`testImplementation`/`runtimeOnly` (batched by build: intermine/*, bio/*, bio/sources, bio/postprocess*, testmine); plugin `getByName("compile")` -> configuration-aware code; `maven` -> `maven-publish`; `classifier`/`destinationDir`/`reports.html.enabled` fixes.
- **B3** Gradle 8.14; remove the `com.sun.xml.internal` property; version catalog `gradle/libs.versions.toml` shared via generated properties.
- **B4** JDK 17 build and test run (toolchains), then 21 verification; fix `--illegal-access` fallout (reflection in objectstore/torque, antlr 2 caching jar).
- **B5** Update humanmine and flymine `gradle.properties`/`build.gradle` as deployer examples, plus a `docs/UPGRADING-build.md` migration guide for deployers.

### C. intermine dependencies (Tier 1 security)

- Postgres JDBC 42.7.x, HikariCP 5, Jackson 2.17+, commons-collections4 / commons-io 2.16 / commons-lang3 where the API allows or a minimal patch otherwise, commons-fileupload 1.5, bcprov 1.78, Jena 4.x (check RDF export tests), solrj 9 only if Solr server bumps are acceptable (else the latest 8.11.x), JUnit 4.13.2, xmlunit, remove the duplicate commons-math3, drop vendored jars where a Maven artefact exists.
- One issue per dependency group; the gate is the full test suite.

### D. intermine CI and release

- GitHub Actions: `pull_request` trigger, `setup-java@v4` matrix {8 (until B4), 17, 21} x postgres {14, 16}, Gradle cache, concurrency groups; migrate the ideas from the `speed-up-solr-in-workflow` branch (Docker Solr).
- `.github/dependabot.yml` for gradle and github-actions.
- Publishing: `maven-publish` plus the Central Portal plugin, signing via environment variables; document the release steps in `docs/RELEASING.md`. The actual 5.1.1/6.0.0 release is a human step that needs Sonatype credentials.
- Fix the PR template and CONTRIBUTING.md (link to the guide, branch rules), and the README badges.

### H. Docs and governance (intermine parts)

- `docs/` in intermine: building, testing locally (new `scripts/`), upgrading Gradle/JDK for deployers, release process.
- Decision records (`decisions/*.md`, kept in the planning repo) relevant to the back end: Gradle upgrade versus switch, JDK target, Struts stance. Other records (BlueGenes build tool, beads usage, branching) are covered in the other documents.

## Deployer impact

- The Gradle plugin in `plugin/` is what every deployer's mine build uses. The humanmine and flymine `gradle.properties` files pin `imVersion=5.0.+`, so changes to the plugin reach deployers directly. This is why decision 1 upgrades Gradle rather than switching to Maven.
- B5 updates the humanmine and flymine `gradle.properties`/`build.gradle` as deployer examples, and adds `docs/UPGRADING-build.md` as a migration guide for deployers.
- Tier 1 dependency bumps are chosen to be non-breaking for deployers' Java code.
- Fallback if B2 proves slow (B1-B3 together are the critical path and the largest single risk): ship Gradle 6.9.4 plus Tier 1 dependency bumps plus modern CI as **5.1.1**, which still helps deployers, with Gradle 8 / JDK 17 as **6.0**.
- Gos's decision (15 Nov 2026): breaking changes for deployers are acceptable once Tier 1 security plus Gradle 6.9.4 is landable as a non-breaking 5.1.1.
- The actual release is a human step with Sonatype credentials.

## Verification (intermine)

- **Every task**: the gate script passes in the worktree. For intermine that is `./gradlew install` for upstream builds, `build` for touched builds, and `checkstyleMain`, with results parsed by `config/lib/parse_test_report.py`. The gate script is `scripts/gate-intermine.sh` in the planning repo.
- **Every merge to `maint-2026`**: the full gate on the merged tree; once workstream G lands (see [30-testbed.md](30-testbed.md)), also `rdfc2im/tools/full-build.sh --intermine-src` plus `make test-live` plus `mine-tests`.
- **Baselines** in `baselines/` are the reference: no regression in passing test count relative to baseline is allowed.
- **End of sprint**: `maint-2026` of the repo is pushed and CI is green on GitHub Actions for the integration branch.
