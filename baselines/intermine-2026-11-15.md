# InterMine back end baseline, 15 Nov 2026 (im-rkn.3)

This is the measured state of the unmodified InterMine Java back end (`dev` at `77cf7068da`) built and tested the way CI does it, on JDK 8, Gradle 4.9 and PostgreSQL 18 in the sprint sandbox. Every later change is judged against these numbers. The rule from `plans/10-intermine-backend.md` applies: the number of passing tests must not drop below this baseline.

**Result: green.** All 2,279 tests pass. Checkstyle is clean, and the full gate takes 6 to 9 minutes. The two `testBatchesCache` tests in objectstore are **flaky**: they fail in roughly half the runs on PG18 and in 1 of 5 runs on PG14, so treat them as known-flaky rather than as regressions (see [Known problems](#known-problems)).

## Toolchain

| Item | Version |
|---|---|
| Source | `maint/im-rkn.3-baseline` = `maint-2026` = `dev` HEAD `77cf7068da` (unmodified; CI on GitHub was green for this SHA on 12 Jun 2026) |
| Host | Ubuntu 26.04.1 LTS, Linux 7.0.14 aarch64, 10 cores, 15 GB RAM (shared with other agents) |
| JDK | OpenJDK 1.8.0_512 (`/usr/lib/jvm/java-8-openjdk-arm64`, `8u512-b09~us1-0ubuntu1~26.04.1`) |
| Gradle | 4.9 via the wrapper (`gradle-wrapper.properties` generated from `*.in` by `install_intermine.py`); Groovy 2.4.12, Ant 1.9.11 |
| Checkstyle | 7.8.1 (from `build.gradle`) |
| PostgreSQL | 18.6 (Ubuntu package) on localhost:5432, user `test`/`test` (superuser). Comparison run: `postgres:14` (14.25, Debian) in Docker on localhost:15432 |
| Python | 3.14.4, venv `/home/agent/venvs/intermine-ci` with `xunitparser==1.3.4`, `requests` (the pinned `argparse==1.2.1` in `config/lib/requirements.txt` is not needed on Python 3 and was not installed) |
| Network | Gradle, Maven Central, EBI and plugins.gradle.org were all reached through the sandbox proxy (`JAVA_TOOL_OPTIONS` proxy properties). No `~/.gradle/gradle.properties` proxy entries were needed |

## Exact commands

```bash
WT=/Users/gos/claude_projects/update_intermine_planning/worktrees/intermine/im-rkn.3-baseline
scripts/worktree.sh intermine im-rkn.3 baseline           # -> $WT
eval "$(scripts/im-testenv.sh im-rkn.3 create --src "$WT")" # HOME=/home/agent/taskhomes/im-rkn.3, 10 DBs *_im_rkn_3
GATE_CLEAN=1 scripts/gate-intermine.sh "$WT" all          # reference run 6; exit 0
```

What `gate-intermine.sh all` runs (each Gradle call is CI's `run_gradle`: `./gradlew -Dorg.gradle.jvmargs=-Xmx4g --max-workers=4 --no-daemon --warning-mode all --stacktrace <task>`, plus `-Dmaven.repo.local=$HOME/.m2-intermine/repository`, with `LANG=LC_ALL=C.UTF-8` and JDK 8 on `PATH`):

1. `config/lib/install_intermine.py`, with the Gradle install step disabled, generates the `gradle.properties` and wrapper properties. The task's `~/.intermine/*.properties` are left in place.
2. `clean` and `install` in `plugin`, `intermine`, `bio`, `bio/sources`, `bio/postprocess` (`install_intermine.py`'s module list).
3. `build` in `intermine` (CI matrix job "intermine"), then in `bio`, `bio/sources`, `bio/postprocess`, `bio/postprocess-test` (CI matrix job "bio"; `postprocess-test` is cleaned first).
4. `checkstyleMain` in `intermine`, `bio`, `bio/sources`, `bio/postprocess`, then `config/lib/parse_checkstyle_report.py $WT` (as in `checkstyle.yml`).
5. `config/lib/parse_test_report.py` on `intermine`, `bio`, `bio/sources`, `bio/postprocess-test` (as in `config/ci/run.sh`).

## Results per build (reference run 6, PG18, 02:30 UTC)

| Build (CI job) | Gradle | Tests run | Pass | Fail | Error | Skipped | `build` wall | Peak RSS (Gradle tree) |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| intermine (intermine) | OK | 2116 | 2116 | 0 | 0 | 0 | 1:25 | 2.79 GB |
| bio (bio) | OK | 92 | 92 | 0 | 0 | 0 | 0:19 | 1.59 GB |
| bio/sources (bio) | OK | 59 | 59 | 0 | 0 | 0 | 1:20 | 2.36 GB |
| bio/postprocess (bio) | OK | 0 (no tests; they live in postprocess-test) | - | - | - | - | 0:20 | 1.56 GB |
| bio/postprocess-test (bio) | OK | 12 | 12 | 0 | 0 | 0 | 0:42 | 1.49 GB |
| **Total** | | **2279** | **2279** | **0** | **0** | **0** | | |

These counts are identical to the most recent GitHub Actions logs still available (run 39579885304, 21 Oct 2026, branch `speed-up-solr-in-workflow`): intermine 2116; bio 92, 59 and 12. Logs for the `77cf7068da` run itself have expired (HTTP 410).

Per subproject (tests run; no failures, errors or skips anywhere in run 6):

| intermine | n | bio | n | bio/sources | n | bio/postprocess-test | n |
|---|---:|---|---:|---|---:|---|---:|
| objectstore | 1061 | core | 84 | chado-db | 12 | create-chromosome-locations-test | 1 |
| api | 491 | tools | 5 | fasta | 7 | create-gene-flanking-features-test | 1 |
| webapp | 223 | webapp | 3 | go-annotation | 4 | create-intergenic-region-features-test | 2 |
| model | 125 | | | ncbi-gene, pubmed-gene, uniprot | 3 each | create-intron-features-test | 1 |
| pathquery | 110 | | | protein2ipr, reactome | 2 each | create-references-test | 2 |
| integrate | 99 | | | 23 other sources* | 1 each | create-utr-references-test | 1 |
| jbrowse-endpoint | 4 | | | | | make-spanning-locations-test | 1 |
| webtasks | 3 | | | | | transfer-sequences-test | 3 |

\* biogrid, delimited, ensembl-compara, entrez-organism, homologene, interpro, interpro-go, isa, kegg-orthologues, kegg-pathway, mgi-identifiers, ncbi-gff, omim, orthodb, panther, psi, psi-complexes, treefam, uniprot-keywords, update-data-sources, update-publications, vcf, wormbase-identifiers. In total 31 of the 46 source directories under `bio/sources` have test results; the other 15 have no tests.

**Checkstyle:** `checkstyleMain` passed in all four builds, and `parse_checkstyle_report.py` reported 0 violations. `build` already runs `checkstyleMain` through `check` (`ignoreFailures=false`, `maxWarnings=0`), so a checkstyle violation also fails `build`.

## Wall time and memory

Wall time per step for each full gate run, in seconds. Run 6 is the reference. Runs 3 to 6 all used `GATE_CLEAN=1`, with the dependency caches already warm.

| Step | run 3 (PG18) | run 4 (PG18) | run 5 (PG14) | run 6 (PG18, ref) |
|---|---:|---:|---:|---:|
| plugin install | 5 | 6 | 5 | 7 |
| intermine install | 21 | 29 | 26 | 34 |
| bio install | 25 | 14 | 16 | 24 |
| bio/sources install | 104 | 76 | 100 | 135 |
| bio/postprocess install | 13 | 13 | 14 | 18 |
| intermine build | 72 | 57 | 61 | 85 |
| bio build | 18 | 15 | 15 | 19 |
| bio/sources build | 47 | 53 | 51 | 80 |
| bio/postprocess build | 15 | 15 | 17 | 20 |
| bio/postprocess-test build | 34 | 19 | 20 | 42 |
| checkstyleMain x4 + report | 26 | 26 | 26 | 29 |
| **Whole gate** | **6:40** | **5:43** | **6:09** | **8:40** |
| intermine tests failed | 2 (flaky) | 2 (flaky) | 0 | 0 |

- Run 6 ran alongside another agent's BlueGenes baseline JVM (1-minute load average up to 12 on 10 cores), so expect the gate to take 6 to 9 minutes. GitHub's own runners took 5:55 for the intermine job and 7:54 for the bio job on 12 Jun 2026.
- The first run on a cold cache also downloaded Gradle 4.9 and every dependency. That added about 1 minute (plugin install 49 s, intermine install 62 s before it failed in run 1).
- An incremental gate run with no source changes is not fast. `bio/sources install` still takes about 100 s, because the plugin's `initConfig`, `mergeModels`, `copyBioGenomicModel` and `copyGlobalAdditionsFile` tasks declare no outputs. They rerun in all 44 source projects every time and force `jar`, `javadoc` and `javadocJar` to rerun too. This belongs in B1/B2 (the rule about wiring tasks by inputs and outputs). A single-build gate run (`gate-intermine.sh $WT bio/postprocess-test`) took 2:36.
- **Peak memory.** The gate samples the summed RSS of the Gradle client, daemon and test-worker tree every 2 s (`/usr/bin/time` is not installed). The largest value was **3.16 GB in `intermine build`** (2.66 to 3.16 GB across runs). Next were bio/sources build at 2.27 to 2.36 GB and bio/sources install at 1.80 to 1.97 GB; every other step stayed under 1.6 GB. With `-Xmx4g`, two concurrent gate runs fit in the sandbox. Across the whole of run 6, the sandbox had at least 9.4 GB available.

## Disk

- Build outputs in the worktree (every `build/` and project `.gradle/` directory) total **886 to 894 MB**: intermine 348 MB, bio (core, model, tools, webapp, testresources) 128 MB, bio/sources 360 MB, bio/postprocess 24 MB, bio/postprocess-test 39 MB, plugin 2.5 MB. The whole worktree, including sources, is 999 MB.
- Shared caches: `~/.gradle` holds 403 MB (the Gradle 4.9 distribution plus the dependency cache).
- The task-private Maven install repo, `$HOME/.m2-intermine`, holds 129 MB.
- Each task's 10 Postgres databases are small; `unittest` holds 50 tables.

## Deprecation warnings (B1 to-do list)

Gradle 4.9 with `--warning-mode all` printed **exactly one** Gradle deprecation category:

1. **Annotation processors on the compile classpath.** The message reads: "The following annotation processors were detected on the compile classpath: 'org.apache.logging.log4j.core.config.plugins.processor.PluginProcessor'. Detecting annotation processors on the compile classpath is deprecated and Gradle 5.0 will ignore them. Please add them to the annotation processor path instead..." It appears in the `bio` build (`bio-install`, `bio-build`, `bio-checkstyleMain`; 3 times). The processor comes from a transitive log4j-core 2.x on the bio compile classpath. intermine excludes `org.apache.logging.log4j`; bio does not. The same warning is in the GitHub CI log.

Gradle 4.9 does **not** yet warn about most of what B1/B2 will hit: `compile`/`testCompile`/`runtime`, the `maven` plugin and `uploadArchives`, `classifier`, `destinationDir`, `reports.html.enabled`, and so on. Those warnings only appear on Gradle 5.x/6.x. The real B1 to-do list must therefore be collected by running `--warning-mode all` on 6.9.4 (the first B1 step). Do not read this short list as meaning the build is close to modern.

javac `-Xlint:deprecation` notes (code, not build):

- `intermine/pathquery/.../ConstraintValueParser.java`
- `intermine/integrate/.../task/DelimitedFileConfiguration.java`
- `intermine/objectstore/src/test/.../sql/DatabaseTest.java`
- `intermine/webtasks/src/test/.../TokenRoundTripTest.java`
- `bio/sources/delimited/.../DelimitedConfiguration.java`
- Several modules print the generic "Some input files use or override a deprecated API" (intermine install/build, bio install).

Other noise, not deprecations: every JVM prints "Picked up JAVA_TOOL_OPTIONS" (sandbox proxy), and the Ant tasks print log4j "No appenders could be found".

## Known problems

### Environmental (sandbox), fixed in the gate

1. **No UTF-8 locale.** The sandbox has `LANG` unset, so JDK 8 used `file.encoding=ANSI_X3.4-1968`. `intermine-jbrowse-endpoint:javadoc` then failed on the non-ASCII "coördinates" in `Segment.java:98` ("unmappable character for encoding ASCII"). That was run 1, in `intermine install`. GitHub runners use `C.UTF-8`, so the gate now exports `LANG=LC_ALL=C.UTF-8` (override with `GATE_LANG`). An upstream fix would be `options.encoding = 'UTF-8'` on javadoc and `compileJava` (follow-up; outside this baseline).
2. **Cleaning bio before installing intermine.** In run 2 (aborted), `clean` in bio failed because the bio builds cannot even be configured until plugin and intermine are installed: `Could not find org.intermine:plugin:5.1.1` on the buildscript classpath. The gate now cleans each build immediately before its own install/build, in dependency order.
3. **PostgreSQL 18 versus 14: no incompatibility found.** The whole suite passes on PG18 (run 6) and on postgres:14 (run 5, Docker on 15432, `test` superuser). The only difference observed is the flaky test below, which also fails on PG14. The PG14 container `im-rkn3-pg14` and task env `im-rkn.3-pg14` were left in place for reruns. Remove them with `docker rm -f im-rkn3-pg14; scripts/im-testenv.sh im-rkn.3-pg14 destroy`. That `destroy` will not reach the PG14 DBs unless `IM_PG_PORT=15432` is set, and removing the container removes them anyway.

### In the code base (present upstream)

4. **Flaky `testBatchesCache`.** The two failing tests are `org.intermine.objectstore.intermine.FlatModeObjectStoreInterMineImplTest.testBatchesCache` and `org.intermine.objectstore.intermine.WithNotXmlObjectStoreInterMineImplTest.testBatchesCache`. Both fail with `AssertionError` at `ObjectStoreInterMineImplTestCase.java:911` (`assertTrue(!r1.isSingleBatch())`).
   - They always fail together, and only in these two subclasses; the plain `ObjectStoreInterMineImplTest` passes.
   - Tally on PG18: failed in full gate runs 3 and 4, passed in run 6. In `:intermine-objectstore:cleanTest test` reruns, 2 of 6 failed. Run alone, the FlatMode class failed 1 of 1 and the WithNotXml class passed 1 of 1.
   - Tally on PG14: failed 1 of 5 (gate run 5 passed; objectstore-only reruns: pass, fail, pass, pass).
   - Likely cause: test-method order. JUnit 4.8.2 runs methods in JVM reflection order, which is unspecified. Each test class shares one ObjectStore, whose `resultsCache`/`batchesCache` (`CacheMap`) can already hold the Employee batch-size-1000 batch from another test method, so r1 is already "single batch".
   - The C-workstream bump to JUnit 4.13 (deterministic `MethodSorters.DEFAULT`) will make the result stable, either always pass or always fail, so re-check it then.
   - Until then, the gate counts these two as failures. A worker whose gate fails only on these two should rerun once and report it. Suggested follow-up issue: make the test independent of cache state, for example by clearing the caches in `@Before` or using a unique query.
5. **The test run dirties the source tree.** `OboConverterTest` in bio/core writes `bio/core/obo-converter-tgt.xml` into the source tree, and git does not ignore it. The gate lists such files as "untracked files left by the build (do not commit)".
6. **CI database-name mismatch, harmless.** `config/ci/init.sh` and the Gradle `createUnitTestDatabases` tasks use `bio-fulldata-test`, but `config/ci-bio.properties` names the database `biofulldatatest`, so in CI that database is never created. No current test opens it. `im-testenv.sh` creates every name the properties mention, so it exists in task environments.
7. **Hardcoded database creation.** `intermine/testresources` and `bio/testresources` `createUnitTestDatabases` always run `sudo -E -u postgres psql -h localhost -c 'create database "<fixed name>"'` on port 5432. Under `im-testenv.sh` this creates empty, unsuffixed `unittest`, `bio-test`, etc. on PG18 (harmless, ignored: the tests use the suffixed names from `~/.intermine`). It also means the gate needs passwordless `sudo -u postgres` and the `postgres`/`postgres` password on localhost:5432, even when the tests use another server.
8. **`install` writes to Maven local.** The `maven` plugin writes `org.intermine:*:5.1.1` to `~/.m2`, which is shared between tasks. The intermine builds never read `mavenLocal` (they resolve each other through file/ivy repos inside the worktree), but mines and the testbed might. The gate therefore defaults to a task-private `-Dmaven.repo.local=$HOME/.m2-intermine/repository`; `GATE_SHARED_M2=1` gives CI's behaviour. The shared `~/.m2/repository/org/intermine` was written once by runs 1 to 5, before this change.
9. **`user.home` ignores `$HOME`.** Java's `user.home` comes from `/etc/passwd`, not `$HOME`, so Gradle's cache and wrapper live in `/home/agent/.gradle` whatever `HOME` is. The build scripts read `~/.intermine` through `System.env.HOME`, which is why switching `HOME` is enough for DB isolation.

No I/O or fsync errors were seen on the host mount.

## Artefacts

- Scripts: `scripts/im-testenv.sh`, `scripts/gate-intermine.sh` (usage is in each header).
- Logs: `baselines/intermine-2026-11-15-logs.tar.gz`, containing run 6 (reference, with system load samples), run 3 (PG18 with the flaky failures), run 5 (PG14) and run 1 (ASCII-locale failure). Each holds every step log, `steps.tsv`, `summary.txt`, `per-subproject.txt`, `deprecations.txt` and `failed-tests.txt`. The live `.gate-logs/` in the worktree are overwritten by every gate run.
