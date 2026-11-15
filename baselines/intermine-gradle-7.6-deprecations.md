# InterMine on Gradle 7.6.6: deprecation warnings (im-ee7.2, step 2b)

This file lists every Gradle deprecation warning that the InterMine builds print on Gradle 7.6.6. Gradle 7.6 warns about what Gradle 8.0 removes or turns into an error, so this is the input for step 3a in `decisions/gradle-upgrade-path.md` (section 3.3). It has the same layout as `intermine-gradle-6.9.4-deprecations.md`.

**Source.** The full gate on branch `maint/im-ee7.2-gradle-76-flip` at `cfe3025c18` (Gradle 7.6.6, JDK 8, PG18, `GATE_CLEAN=1`, `--warning-mode all --stacktrace`, 15 Nov 2026). I read every `.gate-logs/*.log`: clean, publishToMavenLocal, build and checkstyleMain in plugin, intermine, bio, bio/sources, bio/postprocess and bio/postprocess-test. testmine is not part of the gate, so I ran it separately: `tasks --all`, `:webapp:war :dbmodel:loadsadata --dry-run`, and a real `:webapp:war`. The flymine smoke copy is covered at the end.

**How to read the counts.** The "printed" column counts the Gradle invocations that printed the message. Each invocation prints a message once, at the first site it hits. The "sites" column comes from a grep over the tracked `*.gradle` files and `plugin/src`. That grep leaves out the orphan modules `bio/sources/uberon` and `bio/sources/example-sources`.

## Gradle deprecations printed on the final tree

| # | Category (message) | Printed (invocations) | Sites (static) | Representative file:line | Removed in | Planned fix (3.3 row) |
|---|---|---:|---|---|---|---|
| 1 | Implicit dependency: "Task ':intermine-objectstore:sourcesJar' uses this output of task ':intermine-objectstore:generateGrammarSource' without declaring an explicit or implicit dependency" | 2 (`intermine-build`, `intermine-publishToMavenLocal`) | 1 task; the cause is shared by both antlr modules | `intermine/objectstore/build.gradle:1` (antlr plugin) with `config/gradle/publishing.gradle:25` (`java { withSourcesJar() }`) | error in 8.0 | 3a, row 18 (and the 3b "withSourcesJar() combined with antlr" expected failure). The 7.6 antlr plugin adds `build/generated-src/antlr/main` to `sourceSets.main.java` as a plain directory, so `sourcesJar` does not know about the producer. Wire it as an input/output link (`sourceSets.main.java.srcDir(tasks.named('generateGrammarSource'))`), not with `dependsOn`. Check on 8.14 first: the 8.x antlr plugin may already wire it **(verify)** |
| 2 | Same as row 1, for `:intermine-pathquery:sourcesJar` / `:intermine-pathquery:generateGrammarSource` | 2 (same invocations) | 1 task | `intermine/pathquery/build.gradle:1` with `config/gradle/publishing.gradle:25` | error in 8.0 | same fix as row 1 |

Gradle also prints the summary line "Deprecated Gradle features were used in this build, making it incompatible with Gradle 8.0" in those two invocations. It is not a separate category.

**Count: 2 distinct deprecation messages on the final tree**, both of one kind (row 18, implicit dependency), in 2 of 20 gate invocations. The other 18 invocations print no Gradle deprecation. That includes the whole plugin build (Groovy 3 compile included), every bio build, and all clean and checkstyle runs.

## Printed on 7.6.6 and already fixed in this task

| Category | Printed before the fix | Sites | Fixed by |
|---|---:|---|---|
| `TestReport.destinationDir` (use `destinationDirectory`) | 14 (every invocation of the five roots that define `testReport`) | 5 roots | `cfe3025c18` (im-ee7.18) |
| `TestReport.reportOn(Object...)` (use `testResults`) | 14 | 5 roots | `cfe3025c18` (im-ee7.18) |

These counts come from the gate on the flip commit `6d3533fee6`. Those intermine and bio `build` runs stopped early at checkstyle (im-ee7.17), so the counts are a lower bound.

## Not printed in the gate, but expected to warn on 7.6.6

- **testmine.** `tasks --all` and `:webapp:war :dbmodel:loadsadata --dry-run` configure without a warning. A real `:webapp:war` stops in `:webapp:mergeProperties`, because `testmine/dbmodel/build/resources/main/intermine.properties` does not exist. That file is written by `copyMineProperties`, which only the dbmodel DB tasks depend on. `testmine/setup.sh` runs `loadsadata` before `war`, so this is a missing task dependency, not a Gradle 7 change (see Follow-ups). As a result, the execution-time warnings of the testmine Ant tasks (`loadsadata`, `buildDB`, cargo) were not collected. Cargo 2.9.0 uses `convention` and `conventionMapping` (R6). Those uses warn from 8.x, not on 7.6.
- **Untracked outputs.** `copyMineProperties` in `bio/sources/build.gradle:152`, `bio/postprocess/build.gradle:122` and `bio/postprocess-test/build.gradle:119` copy into `sourceSets.main.output.resourcesDir` with `project.copy` inside `doLast`. They declare no outputs, so neither 7.6 nor 8.x sees the overlap. Fold them into `processResources` once the plugin's `DBModelUtils.mineProperties` no longer looks them up by name (row 18).

## What 7.6.6 does not warn about (do not read the table as complete for 8.x/9.x)

These are silent on 7.6.6 and start to warn in 8.x (one major ahead of their removal in 9.0 or 10). Step 3b has to collect them again with `--warning-mode all` on 8.14.6. Static counts are from the final tree.

| Item | Warns from | Static sites | Representative file:line | Planned fix (3.3) |
|---|---|---|---|---|
| `Project.exec { }` in build scripts | 8.11 | 14 calls in 2 files (intermine/testresources 11, bio/testresources 3) | `intermine/testresources/build.gradle:98`, `bio/testresources/build.gradle:4` | TESTRES batch, row 25: `providers.exec { }` (7.5+) or an injected `ExecOperations` |
| `buildDir` / `getBuildDir()` | 8.3 | 20 lines in 5 scripts; 38 lines in 8 plugin classes | `testmine/webapp/build.gradle`, `bio/webapp/build.gradle`, `intermine/testresources/build.gradle`; `DBModelUtils.groovy`, `IntegrateUtils.groovy` | P3 (plugin) and opportunistic (scripts), row 27: `layout.buildDirectory` |
| Project-level `sourceCompatibility` / `targetCompatibility` (convention access) | 8.x (convention deprecations) | 13 lines in 7 files | `intermine/build.gradle:9-10`, `bio/build.gradle:8-9`, `plugin/build.gradle:7`, `testmine/build.gradle:12-13` | ROOTS batch, row 26: `java { sourceCompatibility = JavaVersion.VERSION_1_8 }` |
| Groovy space-assignment (`description "x"`, `toolVersion '7.8.1'`, `url ...`) | 8.14 (UG8:494-509) | at least 32 script lines (description 21, toolVersion 6, url 5; the regex is approximate) and about 34 plugin lines | `intermine/build.gradle:61` (`toolVersion '7.8.1'`) | ROOTS and P3, row 28: the upgrade guide's `sed` |
| `new AntBuilder()` / `new XmlParser()` from `groovy.util` | Groovy 4, so 9.0 (not a Gradle deprecation in 8) | 31 | all plugin classes | P3, row 23 |
| Checkstyle tool version 7.8.1 | not a deprecation; runs on 7.6.6 through `config/gradle/checkstyle-classpath.gradle` (im-ee7.17) | 6 `toolVersion` lines in 5 files | `intermine/build.gradle:61` | keep for 8.14 **(verify that the Ant call works on 8.14)**; R7 bump removes the shim |

Checked and not found on the final tree: `classifier =` on Jar tasks, `reports.html.enabled`, `TestReport.destinationDir` / `reportOn`, `JavaExec.main` and `mainClassName` in core, `archivesBaseName`, any `convention` use in scripts or plugin, `artifacts { archives ... }`, custom `Test` tasks, `jcenter()`. Every plugin-created configuration already sets `canBeConsumed = false` (the 8.0 "identical consumable configurations" error).

## javac deprecation notes (code, not build; unchanged from 6.9.4)

`ConstraintValueParser.java`, `DelimitedFileConfiguration.java`, `DatabaseTest.java`, `TokenRoundTripTest.java` and `bio/sources/delimited/.../DelimitedConfiguration.java` each print "uses or overrides a deprecated API", as on 4.9 and 6.9.4. testmine adds `testmine/webapp/.../EmployeeExporter.java`.

## Deployer (flymine smoke copy on 7.6.6)

Run from `/home/agent/taskhomes/im-ee7.2-flip/flymine-smoke` (a copy of `repos/flymine` at `a507ed84`) with the 7.6.6 wrapper and the gate's locally published 5.1.1 artefacts (`-Dmaven.repo.local=$HOME/.m2-intermine/repository`, `imVersion`/`bioVersion` pinned to 5.1.1). `:dbmodel:tasks` configures, and `:webapp:compileJava` gets through configuration and runs `:dbmodel:createSoModel`. It stops in `:dbmodel:mergeModels`, because the flymine-specific sources (`bio-source-drosophila-homology:4.2.0`, `bio-source-rnai`, `bio-source-flyatlas` and 15 more) are not in any reachable repository. That is data, not Gradle.

| Category | Site | Planned fix |
|---|---|---|
| `JavaExec.main` (removed in 8.0) | `flymine/webapp/build.gradle:138` (`blueGenesStart`; humanmine `webapp/build.gradle:127`) | `mainClass = 'bluegenes.core'` (works on 7.6 and 8.x) |

Before it would configure on 7.6, the copy needed these edits. A deployer makes the same edits for 6.0.0 (B5):
1. Delete `inputs.sourceFiles.stopExecutionIfEmpty()` (`build.gradle:50`).
2. Delete `apply plugin: 'maven'` (`build.gradle:22`). Gradle 7 removed the plugin.
3. Change `compile` to `implementation` and `testCompile` to `testImplementation`: `build.gradle:38-40`, `dbmodel/build.gradle` (4 lines) and `webapp/build.gradle` (5 lines). Gradle 7 removed `compile`.
4. Delete `jcenter()` (`build.gradle:30`): it warns on 7.x and is removed in 9.0.
5. Delete the gretty `apply from:` (`webapp/build.gradle:2`) and the `gretty { }` block: jcenter returns 403 and gretty is unmaintained.
6. Regenerate the wrapper for the new Gradle version.

The 5.1.1 plugin itself printed no deprecation in the mine. Cargo 2.8.0 configures on 7.6.6 without a warning.
