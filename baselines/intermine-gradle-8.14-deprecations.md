# InterMine on Gradle 8.14.6: deprecation warnings (im-ee7.3, step 3b)

This file lists every Gradle deprecation warning that the InterMine builds print on Gradle 8.14.6. Gradle 8.14 warns about what Gradle 9.0 (and 10.0) removes, so this is the input for the 9.x step in `decisions/gradle-upgrade-path.md` (section 3.4). It has the same layout as `intermine-gradle-7.6-deprecations.md`.

**Source.** The full gate on branch `maint/im-ee7.3-gradle-814-flip` at `c58f5e79cd` (and again at `28a0714e4c`, same result) (Gradle 8.14.6, JDK 8, PG18, `GATE_CLEAN=1`, `--warning-mode all --stacktrace`, 15 Nov 2026), 20 Gradle invocations: clean, publishToMavenLocal, build and checkstyleMain in plugin, intermine, bio, bio/sources, bio/postprocess and bio/postprocess-test. I read every log. testmine is not in the gate, so I ran it separately with the 8.14.6 distribution and a private Gradle home: `tasks --all`, `:webapp:war :dbmodel:loadsadata --dry-run`, a real `:dbmodel:loadsadata`, `:dbmodel:insertUserData`, `:webapp:war` and `:webapp:cargoRunLocal` (Tomcat 9 started, the webapp answered `/service/version` and a query). The flymine smoke copy is covered at the end.

**How to read the counts.** "Printed" counts the Gradle invocations that printed the message. With `--warning-mode all` each site prints once per invocation. "Sites" comes from a grep over the tracked `*.gradle` files and `plugin/src`, leaving out the orphan modules `bio/sources/uberon` and `bio/sources/example-sources`.

## Gradle deprecations printed on the final tree

| # | Category (message) | Printed (invocations) | Sites (static) | Representative file:line | Removed in | Planned fix |
|---|---|---:|---|---|---|---|
| 1 | "Executing Gradle on JVM versions 16 and lower has been deprecated. This will fail with an error in Gradle 9.0. Use JVM 17 or greater to execute Gradle." | 20 of 20 (every invocation), and every testmine and flymine run | none: it is the JVM that runs the daemon (JDK 8), not a script | `config/ci/run.sh` / `gate-intermine.sh` (`JAVA_HOME` = JDK 8) | 9.0 | B4: run Gradle on JDK 17. Toolchains can keep compile/test on 8, but the plugin's Ant tasks run inside the daemon, so B4 means the InterMine runtime on 17 (section 3.4) |

**Count: 1 distinct deprecation message, and none comes from our scripts or plugin.** The plugin build itself (Groovy 3 compile included), every bio build, all clean and checkstyle runs, and testmine print nothing else. Cargo 2.9.0 (third party) prints no deprecation on 8.14.6, at configuration or at `cargoRunLocal`: its `conventionMapping` uses are internal API that Gradle 8 does not nag about. It still breaks on 9.0 (risk R6).

Gradle also prints the summary line "Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0" in every invocation, because of row 1. It is not a separate category.

## Printed on 8.14.6 and already fixed in this task

| Category | Printed before the fix | Sites | Fixed by |
|---|---:|---|---|
| Implicit dependency: `:intermine-objectstore:sourcesJar` / `:intermine-pathquery:sourcesJar` use `generateGrammarSource` output (the two 7.6.6 rows; an error from 8.0) | fixed on 7.6.6 before the flip | 2 | `037c1710d6`: java `srcDirs = ['src/main/java', tasks.named('generateGrammarSource')]`. The 8.14.6 antlr plugin still adds the plain directory (checked in `gradle-antlr-8.14.6.jar`), so this stays needed |
| Groovy space assignment ("Properties should be assigned using the 'propName = value' syntax", removed in 10.0): `url x`, `description x` | 8 (`url`: bio and bio/postprocess invocations; `description`: 4 bio invocations) | 6 in gated builds: `bio/core/build.gradle:6,16`, `bio/model/build.gradle:6,15`, `bio/postprocess/create-R2RML-mapping/build.gradle:14`, `bio/webapp/build.gradle:54` | `20cd354e1d` |
| "Invocation of Task.project at execution time has been deprecated" (error in 10.0; blocks the configuration cache) | 1 (`intermine-publishToMavenLocal`) | `intermine/testresources/build.gradle:45` (`project.delete` in `generateTestModel` doLast) | `20cd354e1d`: `File.deleteDir()` |
| testmine: space assignment (`url`, `group`, `description`) | every testmine run | 19 in `testmine/dbmodel`, `testmine/webapp` | `c58f5e79cd` |
| testmine: "The org.gradle.api.plugins.WarPluginConvention type has been deprecated" (removed in 9.0) | every testmine run | `testmine/webapp/build.gradle:88` (`webAppDirName`) | `c58f5e79cd`: `war.webAppDirectory` |
| Plugin, mine webapps: implicit-dependency **error** (a 7.6 warning, reported from the testbed): "Task ':webapp:addStrutsConfig' uses this output of task ':webapp:copyWebappContent'" and, with a 5.x-style mine build file, "... of task ':webapp:copyMineProperties'" | reproduced on the flymine smoke copy with `:webapp:copyMineProperties :webapp:copyWebappContent :webapp:addStrutsConfig` | `WebAppPlugin.groovy` addStrutsConfig, `DBModelUtils.processedResources` | `28a0714e4c`: addStrutsConfig no longer declares build/explodedWebApp (which it edits in place) as an input, keeps `dependsOn 'unwarBioWebApp'`; processedResources is also built by the project's copyMineProperties |
| testmine: implicit-dependency **error**: `:webapp:cargoStartLocal` uses `build/libs/webapp.war`, written by `:webapp:warTestModelWebApp`, without a dependency | `cargoStartLocal` / `cargoRunLocal` failed | 1 | `c58f5e79cd`: both depend on `war` and `warTestModelWebApp` |

None of the other expected 3b failures happened: no removed API was left (rows 13 and 15 were done in step 2; row 36 is deployer-only), there was no implicit-dependency error in the gated builds after the antlr fix, the identical-consumable-configuration check passes (every plugin configuration is resolvable-only), and the version catalog accessors (`libs.versions.x.get()`) are unchanged.

Also fixed although 8.14.6 does not print them yet:
- `copyMineProperties` in `bio/sources`, `bio/postprocess`, `bio/postprocess-test` (`f1e5a1d126`) and `copyMineProperties`, `copyDefaultProperties`, `copyTestModel` in testmine (`c58f5e79cd`) wrote into `build/resources/main` from outside `processResources`. The bio ones declared no outputs, so Gradle could not see the overlap. They are now Copy tasks into `build/im/...` that `processResources` takes with `from()`, as batch B did for bio/core and bio/model.
- `buildDir` (`Project.getBuildDir()`, deprecated since 8.3, not nagged in 8.14): the 2 lines in gated builds (`bio/webapp`, `bio/sources/chado-db`) and the 16 in testmine now use `layout.buildDirectory`. No `buildDir` is left in the scripts or the plugin.

## Checkstyle bridge on 8.14.6

`config/gradle/checkstyle-classpath.gradle` (checkstyle 7.8.1 through the Ant task with the module classpath) works unchanged on 8.14.6: 0 violations over the same 1,409 files, and a negative test (deleting `@throws ObjectStoreException` in `intermine/api/.../Profile.java:292`) fails `:intermine-api:checkstyleMain` with `Expected @throws tag for 'ObjectStoreException'. [JavadocMethod]`, which needs the classpath. It prints no deprecation. The bridge uses `XmlSlurper` from the default `groovy.util` import, which Groovy 4 (Gradle 9) removes; the R7 bump deletes the file before that matters.

## Not printed on 8.14.6, but needed for 9.x (section 3.4)

| Item | Why | Sites | Planned fix |
|---|---|---|---|
| Daemon JVM 17 | row 1 above; 9.0 refuses JDK 8 to 16 | CI, gate, every deployer | B4 first: the InterMine runtime (cglib 3.1, torque, JAXB, antlr 2) must run on 17, because the plugin's Ant tasks run inside the daemon |
| Groovy 4 | `groovy.util.XmlSlurper` (checkstyle bridge), `is`-prefixed boolean properties and closure delegation in the plugin need a check | 1 + plugin | R7 deletes the bridge; plugin 7.0.0 review |
| Conventions removed | cargo 2.9.0 (last release, 2022) uses `conventionMapping` | `testmine/webapp/build.gradle:14`, deployers | replace cargo (risk R6) |
| `jcenter()` removed | deployers only (flymine, humanmine) | 2 deployers | delete it (already in the 5.1.1 deployer steps) |
| Implicit `archives` artifacts removed | none found in core | 0 | none |
| Configuration mutation after observation (error in 9.0) | 8.14.6 prints no warning for it in the gate, testmine or the flymine copy | 0 printed | re-check on 9.x |
| Project isolation / cross-project model access | `project(':x').sourceSets...`, `subprojects*.test` (row 29) | 4 + 2 + 5 | `java-test-fixtures` or consumable configurations, later |

## javac deprecation notes (code, not build; unchanged from 6.9.4 and 7.6.6)

`ConstraintValueParser.java`, `DelimitedFileConfiguration.java`, `DatabaseTest.java`, `TokenRoundTripTest.java` and `bio/sources/delimited/.../DelimitedConfiguration.java` each print "uses or overrides a deprecated API". testmine adds `testmine/webapp/.../EmployeeExporter.java`.

## Deployer (flymine smoke copy on 8.14.6)

Run from `/home/agent/taskhomes/im-ee7.3-flip/flymine-smoke` (a copy of `repos/flymine` at `a507ed84`) with the 8.14.6 wrapper files, the plugin and InterMine artifacts that the gate published as 5.1.1 (`systemProp.maven.repo.local` in the copy's `gradle.properties` pointing at the task's private repository; checked that the plugin jar came from there), and `imVersion`/`bioVersion` pinned to 5.1.1. `project.xml` was cut from 67 to the 47 sources whose `bio-source-*` artifacts the gate publishes (the 20 flymine-specific ones are in no reachable repository).

Result (plugin from `28a0714e4c`): `:dbmodel:tasks` and `:webapp:war :dbmodel:buildDB --dry-run` configure; `:dbmodel:jar` runs `createSoModel`, `mergeModels`, `generateModel` and `compileJava`. `:webapp:compileJava` stops at classes from the removed sources (`MicroArrayAssay`), which is data. `:webapp:copyMineProperties :webapp:copyWebappContent :webapp:addStrutsConfig` runs, also with a 5.x-style copyMineProperties (a second copy of the smoke tree), and the struts includes are applied. The plugin printed no deprecation; only row 1 remains once the mine's scripts are fixed.

What 8.14.6 needs in the mine beyond the 7.6 list (all now in `docs/UPGRADING-build.md`):

| Category | Site (flymine copy) | Fix |
|---|---|---|
| `JavaExec.main` (removed in 8.0) | `webapp/build.gradle:138` | `mainClass = 'bluegenes.core'` (already known from 7.6) |
| Implicit-dependency **error**: "Task ':dbmodel:jar' uses this output of task ':dbmodel:copyMineProperties' without declaring an explicit or implicit dependency" | `build.gradle:43-50` (`copyMineProperties` Copy into `sourceSets.main.output.resourcesDir`, `dependsOn 'processResources'`) | keep the task name (the plugin's tasks name it as the producer), copy into `layout.buildDirectory.dir('im/mine-properties')`, add `processResources { from copyMineProperties }`, drop the `dependsOn` |
| `JavaPluginConvention` deprecated (removed in 9.0) | `build.gradle:23-24` (project-level `sourceCompatibility`/`targetCompatibility`) | `java { sourceCompatibility = JavaVersion.VERSION_1_8; targetCompatibility = ... }` |
| Space assignment (removed in 10.0) | `build.gradle:29,31` (`url '...'`), `build.gradle:43` and `webapp/build.gradle:37` and others (`description "..."`) | `url = ...`, `description = ...` |
| Wrapper | `gradle/wrapper/*` | `./gradlew wrapper --gradle-version 8.14.6 --distribution-type bin --gradle-distribution-sha256-sum 7988ed07...` while still on the old Gradle |

Cargo 2.8.0 (flymine) configures on 8.14.6; it was not run. Cargo 2.9.0 runs on 8.14.6 (testmine).
