# InterMine on Gradle 6.9.4: deprecation warnings (im-ee7.1)

This is the list of every Gradle deprecation warning that the InterMine builds print on Gradle 6.9.4. It is the input for the Step 2 batches in `decisions/gradle-upgrade-path.md` (section 3.2).

**Source.** The full gate on branch `maint/im-ee7.1-gradle-6` at `eeab271c22` (Gradle 6.9.4, JDK 8, PG18, `GATE_CLEAN=1`, `--warning-mode all --stacktrace`, 15 Nov 2026). Every `.gate-logs/*.log` was read: clean, install, build and checkstyleMain in plugin, intermine, bio, bio/sources, bio/postprocess and bio/postprocess-test. testmine is not part of the gate, so it was run separately (`tasks --all`, then `:webapp:war :dbmodel:loadsadata --dry-run`). The flymine smoke copy is covered at the end.

**How to read the counts.** Gradle 6 prints each distinct deprecation message only once per build invocation, at its first occurrence. So the "printed" column counts the Gradle invocations that printed the message, and the location shown is the first site Gradle hit. The real number of sites is the "sites" column, which comes from a grep over the tracked `*.gradle` files. That grep leaves out the orphan modules `bio/sources/uberon` and `bio/sources/example-sources`.

## Gradle deprecations printed

| # | Category (message) | Printed (invocations) | Sites (static) | Representative file:line | Removed in | Planned fix step |
|---|---|---:|---|---|---|---|
| 1 | `compile` configuration used for dependency declaration | 20 | 316 lines in 88 files | `bio/build.gradle:52`, `intermine/build.gradle:31`, `bio/sources/build.gradle:103`, `bio/postprocess/build.gradle:95`, `bio/postprocess-test/build.gradle:92`, `plugin/build.gradle:18`, `testmine/build.gradle:61` | 7.0 | 2a: `api` / `implementation` split (design decision 5), per batch P, IM-core, IM-web+testmine, BIO-core, SRC-1..3, PP |
| 2 | `maven` plugin (use `maven-publish`) | 20 | 6 `apply plugin: 'maven'` + 5 `uploadArchives` | `plugin/build.gradle:3`, `intermine/build.gradle:6`, `bio/build.gradle:6`, `bio/sources/build.gradle:34`, `bio/postprocess/build.gradle:35`, `bio/postprocess-test/build.gradle:36` | 7.0 | 1b: S1b-publish (D3); `install` becomes `publishToMavenLocal` in install_intermine.py, testmine/setup.sh, config/ci/run.sh, gate-intermine.sh |
| 3 | `testCompile` configuration used for dependency declaration | 18 | 46 lines in 14 files | `intermine/build.gradle:34`, `bio/build.gradle:54`, `bio/sources/build.gradle:118`, `bio/postprocess/build.gradle:109`, `bio/postprocess-test/build.gradle:104` | 7.0 | 2a: `testImplementation`, same batches as row 1 |
| 4 | `IvyArtifactRepository.layout(String, Closure)` (use `patternLayout`) | 16 (14 gate + 2 testmine) | 10 sites in 7 files | `bio/build.gradle:35`, `bio/sources/build.gradle:7`, `bio/postprocess/build.gradle:7`, `bio/postprocess-test/build.gradle:7`, `testmine/build.gradle:37` (also `bio/core/build.gradle:7`, `bio/model/build.gradle:7`, `bio/sources/build.gradle:76`) | 7.0 | 1 (S1-clean): `patternLayout { artifact '...' }`. It was added in Gradle 5.0, which is fine now: the core builds run on 6.9.4 only, and the 4.9 constraint applies only to the plugin and deployers |
| 5 | `runtime` configuration used for dependency declaration | 14 (12 gate + 2 testmine) | 21 lines in 9 files | `intermine/pathquery/build.gradle:31`, `bio/core/build.gradle:77`, `bio/sources/chado-db/build.gradle:23`, `testmine/webapp/build.gradle:46` | 7.0 | 2a: `runtimeOnly` |
| 6 | `testCompile` configuration resolved (use `testCompileClasspath`) | 2 | 5 sites in 1 file | `intermine/testresources/build.gradle:24` (`testCompile.asPath` in the Ant `buildDB`/`insertModel` classpaths) | 7.0 | 2a IM-core: `sourceSets.test.runtimeClasspath` / `testRuntimeClasspath` |
| 7 | Duplicate path in an archive with the default duplicates strategy: `META-INF/LICENSE.txt` | 1 | the fat jars | `:intermine-objectstore:jar` (the `provided` jars zip-merged at `intermine/objectstore/build.gradle:44-50`) | error in 7.0 | 2a IM-core: `bundled` + explicit `duplicatesStrategy`, checked with an artifact-listing diff (design row 17, risk R10) |
| 8 | Duplicate path in a copy with the default duplicates strategy: `intermine.properties` | 1 | 1 task | `:intermine-testresources:processTestResources`, after `copyDefaultProperties` (`intermine/testresources/build.gradle:70`) | error in 7.0 | 2a IM-core: fold `copyDefaultProperties` into `processTestResources` (census row `intermine/testresources:70`) |

**Not printed in the gate, but known to be there.** The 10 `configurations.compile.asPath` Ant classpaths in `testmine/dbmodel/build.gradle:65-208` and `testmine/webapp/build.gradle:96` warn only when those tasks run (`loadsadata`, `buildDB`, and so on), and the gate does not run them. They are planned for batch 2a IM-web+testmine (`runtimeClasspath`). In the same way, `intermine/api`, `intermine/objectstore` and `bio/core` resolve `configurations.runtime` in `jar { dependsOn ... }` (3 sites). That is not reported as a deprecation, and it is planned for 2a (delete it).

**Gone since the 4.9 baseline:**
- The annotation-processor warning (log4j `PluginProcessor` on the bio compile classpath). Gradle 5+ ignores processors on the compile classpath without warning. No bio module defines log4j2 plugins, and the jar listings are unchanged.
- Resolving `compile` from the custom plugin. That code now uses `runtimeClasspath` (commit `066787e9a8`), and neither the gate nor the flymine smoke shows a plugin-originated warning.

## What 6.9.4 does not warn about (do not read the table as complete for 7.x/8.x)

On 6.9.4 these are silent, although the design inventory says they break later: `classifier =` on Jar tasks (15 lines, removed 8.0), `test.reports.html.enabled` (removed 8.0), `TestReport.destinationDir` / `reportOn` (warns 7.x), overlapping outputs into `sourceSets.main.output.resourcesDir` and missing implicit dependencies (warn 7.x, error 8.0; rows 18 and 19), `Project.exec`, `$buildDir`, Groovy space-assignment, and project-level `sourceCompatibility` (all 8.x). The Step 2b and 3b gates have to collect those again with `--warning-mode all`.

## javac deprecation notes (code, not build; unchanged from 4.9)

`ConstraintValueParser.java`, `DelimitedFileConfiguration.java`, `DatabaseTest.java`, `TokenRoundTripTest.java` and `bio/sources/delimited/.../DelimitedConfiguration.java` each print "uses or overrides a deprecated API". The generic notes appear in intermine install/build, bio install and bio/sources install.

## Deployer (flymine smoke copy on 6.9.4)

Run from `/home/agent/scratch/flymine-smoke` with the 5.1.1 plugin. Two edits were needed first: the deletion described below (without it the build does not configure), and the gretty removal described under Notes.

| Category | Site | Planned fix |
|---|---|---|
| `inputs.sourceFiles.stopExecutionIfEmpty()` **error** (the build does not configure on 5.0+) | `flymine/build.gradle:50` (humanmine `build.gradle:53`) | delete the line. This is the only edit a deployer needs to configure on 6.9.4 |
| `maven` plugin | `flymine/build.gradle:22` | deployer guide B5: drop it |
| `RepositoryHandler.jcenter()` (removed in 8.0) | `flymine/build.gradle:30` | drop it |
| `compile` / `testCompile` declarations | `flymine/build.gradle:38,40` (+ dbmodel and webapp) | `implementation` / `testImplementation` (6.0.0 deployer guide) |

Notes:
- The gretty `apply from: https://raw.githubusercontent.com/akhikhl/gretty/...` script in `flymine/webapp/build.gradle:2` cannot configure on any Gradle in this sandbox. Its buildscript resolves `org.akhikhl.gretty:gretty:2.0.0` from jcenter, which returns 403. This is not a Gradle-version issue. It was removed in the smoke copy, as section 2.3 step 5 of the design prescribes.
- The `--dry-run` listings of `tasks --all` print the `components` / `model` / `dependentComponents` help tasks as "[deprecated]". That is Gradle's own software-model help, and nothing here needs to change for it.
