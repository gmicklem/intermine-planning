# Gradle upgrade path: 4.9 -> 6.9.4 -> 7.6.4 -> 8.14 (then 9.x)

Issues: im-ee7.1 (6.9.4), im-ee7.2 (7.6.4), im-ee7.3 (8.14). Status: design study, read-only, 2026-11-15.
Repo studied: `repos/intermine` (branch `dev`, HEAD `77cf7068da`), deployer examples `repos/humanmine`, `repos/flymine` (branch `master`).
Paths below are relative to `repos/intermine` unless prefixed `humanmine/` or `flymine/`.

Evidence used, beyond the source files:
- Gradle upgrade guides fetched on 2026-11-15: `docs.gradle.org/8.14/userguide/upgrading_version_{4,5,6,7,8}.html` and `docs.gradle.org/current/userguide/upgrading_major_version_9.html`. These are cited as "UG4" (4.x->5.0) through "UG8" (8.x->9.0 deprecations) and "UG9" (the 9.0 guide).
- Gradle source at tags v6.9.4 and v8.14.0 for `AntlrPlugin.java` and `WarPlugin.java`.
- `gradle-cargo-plugin-2.9.0.jar` from plugins.gradle.org (bytecode strings inspected; nothing was executed). Central POMs and metadata for `org.intermine:*` 5.1.0.
- The Gradle release list (services.gradle.org): 6.9.4 (2023-02-22), 7.6.4 (2024-02-05), 7.6.6 (2025-07-04), 8.14.6 (2026-10-08), 8.14.7 (2026-11-11), 9.8.2 (2026-10-19).

Claims I could not confirm from those sources are marked **(verify)**.

## 0. Decisions in brief

1. **Versions.** Use 6.9.4 (the last 6.x). For step 2 use 7.6.4 as the bead says; 7.6.6 is a patch-only bump with fixes and can replace it at no cost. For step 3 use **8.14.6**: 8.14.7 was published four days ago, which breaks the two-week age rule.
2. **Release mapping.** Step 1 ships as **5.1.1**, which must still work for deployers on Gradle 4.9 (Gos, `plans/10-intermine-backend.md:77`). Steps 2 and 3 ship together as **6.0.0**. The 7.6.4 state is an internal checkpoint and is never released. This way deployers move 4.9 -> 8.14 once.
3. **The plugin is coupled to Gradle through its Groovy runtime.** Gradle 4.9 ships Groovy 2.4, 6.9 ships 2.5, 7.6 and 8.14 ship Groovy 3 (UG8 "Upgrade to Groovy 3.0.24"), and 9 ships Groovy 4 (UG9:439). Only old-compiled-on-new-runtime is safe. So plugin 6.0.0 requires Gradle 8.14.x in the mine. `flymine/gradle.properties:1` pins `imVersion=5.1.+`, so any 5.1.x plugin silently reaches that mine and must run on 4.9.
4. **Fix first, then flip.** Every change that both the old and the new Gradle accept is made and gated on the *old* wrapper, in parallel batches. The wrapper is then flipped in one commit. This is required: a single `compile` line anywhere in a build stops the whole build from configuring on 7.x. Parallel per-batch gates are therefore impossible after the flip.
5. **`compile` is split into `api` and `implementation`, not renamed wholesale to `implementation`.** Modules that deployers compile against apply `java-library` and use `api`; everything else uses `implementation`. Renaming everything to `implementation` would change the POM scope from compile to runtime, and Gradle 5+ honours that split when consuming POMs (UG4:573). That would break deployer webapp compiles, for example `humanmine/webapp/build.gradle:27-29`.
6. **`provided` here means "bundled", not "provided".** In `intermine/objectstore/build.gradle:44-50` and `bio/core/build.gradle:95-102` the jars are zip-merged into the module jar. The configuration becomes `bundled` with `implementation.extendsFrom(bundled)`. Using `compileOnly` would drop those jars from the test runtime classpath.
7. **The plugin's configuration named `api` must be renamed** (`DBModelPlugin.groovy:29`) before any project that applies `dbmodel` also applies `java-library`. Since Gradle 7 the `antlr` plugin applies `java-library` itself (`AntlrPlugin.java` v8.14.0 lines 54 and 63).
8. **`dependsOn` count.** There are 94 explicit `dependsOn` uses today: 52 lines in build scripts and 42 in the plugin, 30 of which only order the fake `init*` tasks. Section 4 brings this to about 26, each kept one with a lifecycle reason.

## 1. Inventory of deprecated or removed APIs and features

Counts come from grep over the 95 `build.gradle`, 7 `settings.gradle`, 8 `gradle.properties.in`, 7 wrapper `.in` files, `plugin/src/**` and `config/**`. "Since" is where a feature breaks; "warn" is where Gradle starts warning.

| # | API / feature | Since | Count | Representative paths | Replacement | Step |
|---|---|---|---|---|---|---|
| 1 | `task wrapper(type: Wrapper)` | error 5.0 (UG4:388) | 1 | `testmine/build.gradle:86-88` | delete, or `wrapper { gradleVersion = ... }` | 1, blocks configuration |
| 2 | `inputs.sourceFiles.stopExecutionIfEmpty()` | removed 5.0 (UG4:346) | 1 core + 2 deployer | `testmine/build.gradle:72`, `humanmine/build.gradle:53`, `flymine/build.gradle:50` | delete it (an empty Copy is already NO-SOURCE) | 1, blocks configuration |
| 3 | `task copyGenomicModel(type: Copy, overwrite: true)` replaces a realized plugin task | error 6.0 (UG5:479) | 1 | `bio/model/build.gradle:62` | `tasks.named('copyGenomicModel') { enabled = false }`, plus a `processResources { from('.') { include 'core.xml'; rename { 'genomic_model.xml' } } }` | 1, blocks configuration |
| 4 | Ivy `layout "pattern", { }` | removed 7.0 (UG6:433) | 10 sites, 7 files | `bio/build.gradle:35`, `bio/core/build.gradle:7`, `bio/sources/build.gradle:7,76`, `bio/postprocess*/build.gradle`, `testmine/build.gradle:37` | `patternLayout { artifact '...' }` | 1 |
| 5 | `compile` / `testCompile` / `runtime` declarations | warn 6.x, removed 7.0 (UG6:356) | 321 lines in 92 files; 46 in 14; 21 in 9 | everywhere; `bio/sources/build.gradle:103-127` | `api` or `implementation`, `testImplementation`, `runtimeOnly` (rule in decision 5) | 2a |
| 6 | Resolving `compile` / `testCompile` directly | warn 6.x, removed 7.0 | plugin 29 calls in 7 classes; `testmine/dbmodel/build.gradle` 10; `intermine/testresources/build.gradle` 5 | `DBModelUtils.groovy:51-126`, `IntegrateUtils.groovy:33-298` | `runtimeClasspath`, `testRuntimeClasspath` (both exist in 4.9, so the plugin change can ship in 5.1.1) | 1 (plugin), 2a (scripts) |
| 7 | `configurations { provided; compile.extendsFrom provided }` | `compile` removed 7.0 | 4 files | `intermine/api:22-25` (no dependencies; dead), `intermine/objectstore:14-17`, `bio/core:46-48`, `bio/sources/psi-complexes:20-23` | `bundled` + `implementation.extendsFrom(bundled)`; keep the jar bundling | 2a |
| 8 | `jar { dependsOn configurations.runtime }` | `runtime` removed 7.0 | 3 | `intermine/api:45`, `intermine/objectstore:45`, `bio/core:96` | delete it (the bundled inputs are plain files) | 2a |
| 9 | `apply plugin: 'maven'`, `uploadArchives { mavenDeployer }`, and the `install` task | removed 7.0 (UG6:407-414) | 6 apply, 5 upload | `plugin/build.gradle:3,43`, `intermine/build.gradle:6,128`, `bio/build.gradle`, `bio/sources/build.gradle`, `bio/postprocess/build.gradle`, `bio/postprocess-test/build.gradle:36` (apply only) | `maven-publish`; `publishToMavenLocal` replaces `install` | 1b |
| 10 | Callers of the `install` task | same | 4 | `config/lib/install_intermine.py:137`, `testmine/setup.sh:85-86`, `config/ci/run.sh:31`, `intermine-planning/scripts/gate-intermine.sh:181` | `publishToMavenLocal` | 1b |
| 11 | OSSRH `s01.oss.sonatype.org` URLs and `ossrhUsername` / `ossrhPassword` | OSSRH sunset 2025-06-30 **(verify)** | 5 builds + `gradle.properties.in` | `intermine/build.gradle:133-139` | Central Portal; see risk R11 | 1b |
| 12 | `signing { required { gradle.taskGraph.hasTask("publish") }; sign configurations.archives }` | `hasTask` needs a task *path*, so this is always false and signing is never required; implicit `archives` artifacts removed in 9.0 (UG9:771) | 5 | `intermine/build.gradle:123-126` | `sign publishing.publications.mavenJava`, with `required { !version.endsWith('SNAPSHOT') }` | 1b |
| 13 | `classifier =` on Jar tasks | warn 5.1, removed 8.0 (UG7:387) | 15 lines in 9 files | `intermine/build.gradle:109,114`, `intermine/integrate:13`, `intermine/webapp:76`, `bio/webapp:69` | `archiveClassifier = ...` (5.1+), or `java { withSourcesJar(); withJavadocJar() }` (6.0+) | 1 |
| 14 | `TestReport.destinationDir` and `reportOn subprojects*.test` | warn 7.x (UG7:846) | 5 roots | `intermine/build.gradle:171-175`, `bio/build.gradle:169`, `bio/sources:291`, `bio/postprocess:252`, `bio/postprocess-test:204` | `destinationDirectory = layout.buildDirectory.dir(...)`, `testResults.from(subprojects*.tasks*.named('test')*.map { it.binaryResultsDirectory })` | 3 |
| 15 | `test.reports.html.enabled = true` | removed 8.0 (UG7:356) | 1 | `intermine/build.gradle:90` | `reports.html.required = true` | 2a |
| 16 | `Copy.destinationDir` and `javadoc.destinationDir` | still valid in 8.14 | 3 Copy, 6 javadoc | `bio/model:65`, `bio/webapp:55`, `testmine/webapp:110`; `from javadoc.destinationDir` in 6 roots | prefer `into(...)` and `from(tasks.named('javadoc'))`; the second also removes a `dependsOn` | opportunistic |
| 17 | Duplicate entries in copy specs and archives | error 7.0 (UG6:531) | about 5 tasks | fat jars `intermine/objectstore:44-50`, `bio/core:95-102`; `bio/webapp:58-66`; `testmine/webapp:113-118`; deployer `humanmine/webapp/build.gradle:38-49` | explicit `duplicatesStrategy`, then an artifact-listing diff (section 3) | 2a (property exists in 6.9) |
| 18 | Overlapping outputs and missing implicit dependencies (Copy into `sourceSets.main.output.resourcesDir`; antlr `srcDirs` override) | warn 7.x, error 8.0 | about 12 tasks | `bio/core:86`, `bio/model:56,62`, `testmine/build.gradle:67,75`, `testmine/dbmodel:45`, `testmine/webapp:62`, `intermine/testresources:59`; `intermine/objectstore:5`, `intermine/pathquery:5`; deployer `copyMineProperties` | fold into `processResources.from(...)`; drop the hard-coded `build/generated-src/antlr/main` from `srcDirs` | 2a/3 |
| 19 | `project.task('x') { }` eager creation | not removed | plugin 43, scripts 51 | every plugin class | `tasks.register` (stable since 5.0) | 2a (plugin) |
| 20 | Extensions created inside task configure closures | breaks once tasks are lazy | 3 | `DBModelPlugin.groovy:36`, `WebAppPlugin.groovy:23`, `MineDBModelPlugin.groovy:17` | create them in `apply()` | 2a (do before row 19) |
| 21 | Dependencies added at execution time | "mutating configuration after observation": warn 8.8, error 9.0 (UG8:765-783) | 11 sites | `DBModelPlugin.groovy:39,40,226,353`, `IntegratePlugin.groovy:55,78`, `PostProcessPlugin.groovy:58,93`, `MineDBModelPlugin.groovy:24`, `WebAppPlugin.groovy:27,28`, `DBModelUtils.addBioSourceDependency` | static dependencies at apply time; project.xml-driven ones via `configurations.X.withDependencies { }` | 2a |
| 22 | Plugin-created configurations `api`, `antlr`, `plugin` | clash with `java-library` / `antlr` (decision 7) | 3 | `DBModelPlugin.groovy:29-32` | `imApiJar`, `imAntlr`, `imPlugin`, all with `canBeConsumed = false` | 1 (not visible to deployers) |
| 23 | `new AntBuilder()`, `new XmlParser()` from `groovy.util` | removed in Groovy 4, so Gradle 9 (UG9:444) | 30 + 1 | all plugin classes; `DBModelPlugin.groovy:62` | `groovy.ant.AntBuilder`; `groovy.xml.XmlParser`, or better, reuse `ProjectXmlBinding` | 3 |
| 24 | `import org.gradle.tooling.BuildException` | Tooling API in plugin code; dead code | 1 | `PostProcessPlugin.groovy:6,136` | delete it (Ant's `BuildException` is a `RuntimeException`, already caught by `Exception`) | 2a |
| 25 | `Project.exec { }` in scripts | warn 8.11, removed 9.0 (UG8:636, UG9:983) | 10 calls, 2 files | `intermine/testresources:96-192`, `bio/testresources:4,26` | `providers.exec { }` (7.5+) | 3 |
| 26 | Project-level `sourceCompatibility = 1.8` | convention access, warn 8.x (UG8:1681); conventions removed 9.0 (UG9:869) | 7 + 2 deployers | `intermine/build.gradle:11`, `plugin/build.gradle:8` | `java { sourceCompatibility = JavaVersion.VERSION_1_8 }`, or a toolchain | 3 |
| 27 | `$buildDir`, `getBuildDir()` | warn 8.3, silent (UG8:1375) | 25 lines in 10 scripts; about 35 in plugin | `testmine/webapp:19`, `DBModelUtils.groovy:42` | `layout.buildDirectory` | 3 (plugin), opportunistic |
| 28 | Groovy space-assignment (`description "x"`, `toolVersion '7.8.1'`, `url ...`) | warn 8.12, removed 10 (UG8:494-509) | about 100 script sites + 49 plugin sites | `intermine/build.gradle:59`; `IntegratePlugin.groovy:112` | `prop = value`, using the guide's `sed` | 3 |
| 29 | Cross-project model access (`project(':x').sourceSets.test.output`, `project.parent.project(':dbmodel').sourceSets`, `subprojects*.test`) | works in 8.14; blocks project isolation and composite builds | 4 + 2 + 5 | `intermine/api:40`, `intermine/integrate:7`, `intermine/webapp:67-68`, `testmine/webapp:65,80` | `java-test-fixtures`, or a consumable configuration; copy `minePropertyFile` directly | 3 or later |
| 30 | Classifier and extension artifacts: `testArtifacts`, `testClasses`, `classes`, `@war` | fine through 8.14, but each must be listed explicitly in the `maven-publish` publication | 7 / 2 / 3 / 3 | `intermine/testresources:5-6,260-262`, `intermine/integrate:12-18`, `intermine/webapp:75-83`, `bio/webapp:49`, `WebAppPlugin.groovy:28` | `artifact testClassesJar`, `artifact classesJar`; `components.web` for wars | 1b |
| 31 | `antlr` plugin with flatDir `antlr-2.7.6-caching` (no group, no version) | 6.9.4: `compile.extendsFrom(antlr)`; 7+: applies `java-library` and `api.extendsFrom(antlr)` | 2 modules | `intermine/objectstore:1,41`, `intermine/pathquery:1,30`, `intermine/build.gradle:18-20` | keep the jar out of the published metadata (risk R5) | 2a |
| 32 | `war` plugin, `providedCompile` | fine; 8.14 still wires `implementation.extendsFrom(providedCompile)` (`WarPlugin.java:135`) | 3 files, 12 lines | `intermine/webapp:25,50-55` | none | none |
| 33 | `checkstyle { toolVersion '7.8.1' }` | Gradle defaults are 8.37 (6.9), 8.45.1 (7.6, UG7:924) and 9.3 (8.14); runs in a worker since 7.x (UG7:1025) | 6 lines, 5 files | `intermine/build.gradle:59`, `bio/sources/build.gradle:173,189` | keep 7.8.1 through step 3 if the gate passes; separate bump to 9.3 (risk R7) | 3 |
| 34 | `com.bmuschko:gradle-cargo-plugin` | 2.9.0 is the last release (metadata 2022-02-20); its bytecode uses `convention` and `conventionMapping` (163 refs); conventions are gone in 9.0 | 1 core, 2 deployers (at 2.8.0) | `testmine/webapp/build.gradle:14,17,120-142`, `humanmine/build.gradle:8` | 8.14: keep 2.9.0 **(verify)**; 9.x: replace (risk R6) | 3 / 9 |
| 35 | `jcenter()` | warn 7.0, removed 9.0 (UG9:846) | deployers only | `humanmine/build.gradle:30`, `flymine/build.gradle:30` | delete it | deployer |
| 36 | `JavaExec.main` | removed 8.0 (UG7:364) | deployers only | `humanmine/webapp/build.gradle:127`, `flymine/webapp/build.gradle:138` | `mainClass = ...` | deployer |
| 37 | `apply from: "https://raw.githubusercontent.com/akhikhl/gretty/master/..."` | unpinned remote script; gretty was already dropped from testmine because "it doesn't work with gradle 4.9" (`RELEASE_NOTES:119`) | deployers | `humanmine/webapp/build.gradle:2` | delete it (`cargo` is used for deployment) | deployer |
| 38 | `systemProp.javax.xml.stream.XMLOutputFactory = com.sun.xml.internal...` | JDK-internal class name | 8 `.in` files + deployers | `intermine/gradle.properties.in:4` | remove in B3 | 3 |
| 39 | Wrapper: 7 copies of the 4.9 `gradlew` and jar; one templated URL; no checksum | | 7 | `*/gradle/wrapper/gradle-wrapper.properties.in`, `install_intermine.py:188` | regenerate per step; add `distributionSha256Sum` to the templates | each step |
| 40 | Annotation processors on the compile classpath are ignored | 5.0 (UG4:354) | none found | | watch the compile warnings | 1 |

Not found anywhere: `testRuntime`, `providedRuntime`, `compileOnly`, a `Configuration` used as a dependency (an error since 8.0, UG7:698), or `jcenter()` in core.

Stale modules: `bio/sources/uberon` and `bio/sources/example-sources/kegg-*` have build files but are not in `bio/sources/settings.gradle`. Exclude them from sweeps, or delete them.

## 2. The custom plugin (`plugin/src/main/groovy/org/intermine/plugin/**`, 1,849 lines)

### 2.1 Per-class APIs and their Gradle 7+ rewrite

| Class (lines) | Configuration and task APIs used today | Rewrite for 7.6 / 8.14 |
|---|---|---|
| `DBModelPlugin` (389) | Creates configurations `bioModel`, `bioModelForSOOnly`, `commonResources`, `api`, `mergeSource`, `plugin`, `antlr` (:25-33). 15 eager `project.task` calls. `initConfig` creates the `dbModelConfig` extension in its configure closure (:36) and adds dependencies in `doLast` (:39-40). `getByName("compile")` 5 times. `XmlParser` (:62). zipTree+`renameTo` copies out of the expanded-archive temp dir (:96-106, 120-130, 294-300). `testModel` configuration (:95) is never defined anywhere, so that branch is dead. `compileJava.dependsOn generateModel` (:259). | (1) `def config = project.extensions.create('dbModelConfig', DBModelConfig)` as the first line of `apply()`. (2) `['bioModel','bioModelForSOOnly','commonResources','imApiJar','mergeSource','imPlugin','imAntlr'].each { project.configurations.maybeCreate(it).canBeConsumed = false }`. (3) Constant dependencies (`intermine-resources`, `intermine-api`, `bio-model`, `antlr-complete`) are added at apply time. `mergeSource` uses `withDependencies { parse project.xml via ProjectXmlBinding; add bio-source-* }`, which replaces the `addSourceDependencies` task and the `XmlParser`. (4) A single helper `DBModelUtils.antClasspath(project)` returns `project.configurations.getByName('runtimeClasspath')` (`WarPlugin` puts `providedCompile` into it, so it is a superset of the old `compile`). (5) The copy-* tasks become `tasks.register('copyGenomicModel', Copy) { from({ project.zipTree(project.configurations.bioModel.singleFile) }) { include 'genomic_model.xml'; rename { "${config.modelName}_model.xml" } }; into(layout.buildDirectory.dir('im/resources')) }`, wired with `processResources.from(copyGenomicModel)`. (6) The DB tasks (`buildDB`, `buildUnitTestDB`, `createUserDB`, `runIQLQuery`, ...) are registered with `inputs.files(sourceSets.main.output, antClasspath)` instead of `dependsOn 'jar'`. They have no outputs, so they are never up to date, which is correct. (7) Keep `tasks.named('compileJava') { dependsOn 'generateModel' }` (deployers override `srcDirs = ['build/gen']`). |
| `DBModelUtils` (132) | `getByName("compile")` ×6, `commonResources`, `bioModel`, `api` singleFile; `getBuildDir()`; `new AntBuilder()` | `antClasspath()`; `imApiJar`; `layout.buildDirectory`; `new groovy.ant.AntBuilder()` (keep a fresh Ant project per call: `PostProcessPlugin` sets Ant properties on it). |
| `MineDBModelPlugin` (44) | `mergeModels` creates the `mineDBModelConfig` extension in its configure closure (:17). `plugin` dependency added at execution (:24). `compile` (:30). | Hoist the extension. Drop the `plugin` configuration and use `MergeSourceModelsTask.protectionDomain.codeSource.location`, so the plugin no longer resolves its own jar from a repository. `mergeModels` gets `inputs.files(mergeSource)` and `outputs.file(model xml)`. |
| `BioCoreDBModelPlugin` (19), `BioModelDBModelPlugin` (34) | `project.task('mergeModels')`; `compile` | `tasks.register`; `antClasspath()`. |
| `BioSourceDBModelPlugin` (98) | `tasks.test.dependsOn` ×2 (:17,97). `bioSourceDBModelConfig` extension at apply time (already correct). Uses a `mergeModel` configuration that the plugin never creates (defined in `bio/sources/build.gradle:95`). `project.copy` (:60). | Create `mergeModel` with `maybeCreate`. Generate the priorities file into an `im/resources` dir fed into `processResources`. `copyBioGenomicModel` becomes a `Copy` task. `tasks.named('test') { dependsOn 'buildUnitTestDB' }` stays (lifecycle). |
| `IntegratePlugin` (228) + `IntegrateUtils` (317) + `BioSourceProperties` (134) | Configurations `integrateSource`, `postProcesses`, `bioCore`. `initIntegration` adds dependencies in `doLast` (:55,78). `compile` ×9 in Utils. Duplicate `compileJava.dependsOn generateModel` (:33). State is shared through closure-captured locals. | `integrateSource.withDependencies { }` reads project.xml and `project.findProperty('source')` at resolution time. `bioCore` is added at apply time. Delete the duplicate `compileJava` wiring. Keep the task chain (lifecycle) but replace `initIntegration` with a memoized `IntegrationSpec` built on first use. |
| `PostProcessPlugin` (153) | `postProcesses` and `integrateSource` dependencies added in `doLast` (:58,93). `compile` ×2. Tooling `BuildException` (:6). | `withDependencies` on both configurations (`-Pprocess` / `-Psource`). Delete the import. `inputs.files(sourceSets.main.output, antClasspath)` replaces `dependsOn 'compileJava'`. |
| `WebAppPlugin` (236) | `initConfig` creates `webappConfig` and `new DBModelUtils(project)` in its configure closure (:22-24); dependencies added in `doLast` (:27-28). `addStrutsConfig` edits `unwarBioWebApp` output in place (:59-100). `compile` ×5. `buildDir` ×10. | Hoist the extension and utils; add dependencies at apply time. Replace `unwarBioWebApp` + `addStrutsConfig` with one `Sync` task (`from zipTree(bioWebApp)`, `filesMatching(['WEB-INF/struts-config.xml','WEB-INF/tiles-defs.xml','WEB-INF/web.xml']) { filter { ... } }`). In 6.0.0 the plugin should also configure the mine's `war` itself (`from(explodeBioWebApp)`, `webInf { from(mergeProperties); from(summariseObjectStore) }`, `duplicatesStrategy`). That removes the war boilerplate from every deployer. |
| `plugin/build.gradle` | `compile gradleApi()`, `localGroovy()`, `maven`, `classifier` | `implementation gradleApi()`, `implementation localGroovy()`; `maven-publish` + `signing`; `java { withSourcesJar(); withJavadocJar() }`. Optionally `java-gradle-plugin` with `automatedPublishing = false`: the plugin IDs are not namespaced (`dbmodel`, `webapp`), so marker artefacts cannot go to Central under `org.intermine`, and deployers keep using `buildscript { classpath }`. |

### 2.2 Behaviour changes for deployer mines

| Change | 5.1.1 (step 1) | 6.0.0 (steps 2+3) |
|---|---|---|
| Gradle needed in the mine | 4.9 (unchanged; verified by the compat smoke test in section 3) | **8.14.x** (Groovy 3; built against the 8.14 API) |
| Ant task classpath | `runtimeClasspath` instead of `compile`: a superset that also includes `runtimeOnly`; jar order may differ (risk R9) | same |
| Plugin-internal configurations | `api` -> `imApiJar`, `antlr` -> `imAntlr`, `plugin` -> `imPlugin`. Deployers do not reference them (checked: humanmine, flymine). | same |
| Task wiring | unchanged | lazy tasks. The `init*` tasks disappear. The `copyMineProperties` dependency is replaced by `processResources` inputs, so a mine-defined `copyMineProperties` no longer runs (breaking). `war` is composed by the plugin. |
| Extension DSL (`dbModelConfig`, `mineDBModelConfig`, `webappConfig`) | unchanged | unchanged names and properties |

### 2.3 What a deployer changes for 6.0.0 (humanmine shown; flymine is the same at the same lines unless noted)

1. While still on the old version, run `./gradlew wrapper --gradle-version 8.14.6 --distribution-type bin`. Running it before the other edits works because the build still configures on 4.9.
2. `gradle.properties:1-2`: change `5.0.+` to `6.0.+` (flymine: `5.1.+`). Drop `systemProp.javax.xml.stream...` (line 5) once B3 lands.
3. `build.gradle:8`: cargo `2.8.0` -> `2.9.0`. Lines 22 and 24: drop `apply plugin: 'maven'`; replace `sourceCompatibility` / `targetCompatibility` with `java { sourceCompatibility = JavaVersion.VERSION_1_8; targetCompatibility = JavaVersion.VERSION_1_8 }`. Line 30: drop `jcenter()`. Lines 42-44: `compile` -> `implementation`, `testCompile` -> `testImplementation`. Lines 47-54: delete `copyMineProperties` and replace it with `processResources { from(minePropertyFile) { rename { 'intermine.properties' } } }` inside `subprojects {}`. The 4.9 version fails at 5.0+ on line 53 alone.
4. `dbmodel/build.gradle:18-22`: `compile` -> `implementation`. The `bioModel` line is unchanged. Keep `srcDirs = ['build/gen']`; the plugin keeps the `compileJava` dependency.
5. `webapp/build.gradle:2`: delete the gretty `apply from`; delete the `gretty {}` block (lines 55-58). Lines 25-29: `compile` -> `implementation`. Lines 33-49: delete the `war {}` block, `warWebApp` and `copyWebappContent` (the plugin composes the war); if they are kept, add `duplicatesStrategy = DuplicatesStrategy.EXCLUDE`. Line 127: `main =` -> `mainClass =`. Lines 101-105: the `cargo*.dependsOn war` lines stay.
6. Verify with `./gradlew :dbmodel:tasks :webapp:war --dry-run`, then compare `unzip -Z1 webapp/build/libs/*.war | sort` against the 4.9 war.

## 3. Step plan

### 3.0 Preconditions, done once on the 4.9 baseline (the `baselines/` directory is empty today)

```bash
# in a task worktree with HOME from scripts/im-testenv.sh
python3 -I config/lib/install_intermine.py                       # 4.9, builds+installs plugin,intermine,bio,bio/sources,bio/postprocess
scripts/gate-intermine.sh "$WT" all > baselines/gate-4.9.txt     # test counts, wall time, RSS
for b in intermine bio bio/sources bio/postprocess bio/postprocess-test testmine; do
  (cd $b && ./gradlew -q projects | grep -o "'[^']*'" | tr -d "'" | while read p; do
     ./gradlew -q "$p:dependencies" --configuration compileClasspath  > "$BASE/deps/${p//:/_}.compile.txt"
     ./gradlew -q "$p:dependencies" --configuration runtimeClasspath  > "$BASE/deps/${p//:/_}.runtime.txt"; done); done
find . -path '*/build/libs/*' \( -name '*.jar' -o -name '*.war' \) | sort | while read f; do unzip -Z1 "$f" | sort > "$BASE/art/$(basename $f).lst"; done
find ~/.m2/repository/org/intermine -name '*.pom' -exec cp {} "$BASE/pom/" \;
```

Each later gate compares against these four things: test counts, dependency trees, artifact listings and POM dependency scopes.

### 3.1 Step 1: 4.9 -> 6.9.4 (im-ee7.1, ships as 5.1.1)

**Minimum needed for the builds to configure:** inventory rows 1, 2 and 3, plus the wrapper URL. Everything else still runs on 6.9.4, with warnings.

| Batch | Files | Changes | Agent |
|---|---|---|---|
| S1-core (do first) | `config/lib/install_intermine.py:188`; the 7 `*/gradle/wrapper/gradle-wrapper.properties.in` (add `distributionSha256Sum`); `testmine/build.gradle:72,86-88`; `bio/model/build.gradle:62-70` | default URL `gradle-6.9.4-bin.zip`; the 3 blockers | Opus spike, 2-3 h including 2 gate runs |
| S1-clean | 7 files with ivy repos (row 4); 9 files with `classifier =` (row 13); plugin 7 classes (row 6 `compile` -> `runtimeClasspath`, row 22 renames) | API-compatible with 4.9 and 6.9.4 | Sonnet, 1.5 h |
| S1-wrap | `plugin`, `intermine`, `bio`, `bio/sources`, `bio/postprocess`, `bio/postprocess-test`, `testmine`: `gradlew`, `gradlew.bat`, `gradle/wrapper/gradle-wrapper.jar` | `./gradlew wrapper --gradle-version 6.9.4 --distribution-type bin` in each | Sonnet, 0.5 h |
| S1b-publish | 6 builds' publishing blocks (rows 9-12, 30); `install_intermine.py:137`; `testmine/setup.sh:85-86`; `config/ci/run.sh:31`; planning `gate-intermine.sh:181` (add `GATE_INSTALL_TASK`, default `publishToMavenLocal`) | `maven-publish` works on 6.9.4. It has to be done before 5.1.1 can be released at all, because OSSRH is gone. The POM scope mapping for `compile`/`runtime` does not change. | Opus, 3 h |

Order: S1-core -> (S1-clean, S1-wrap in parallel) -> S1b-publish. Inside each build the usual order applies: plugin, then intermine, then bio, then bio/sources, bio/postprocess, bio/postprocess-test, then testmine.

Commands for each gate:
```bash
GATE_INSTALL_ARGS="--gradle_distribution_url https://services.gradle.org/distributions/gradle-6.9.4-bin.zip" \
  scripts/gate-intermine.sh "$WT" all                     # install (S1b+: publishToMavenLocal) + build + checkstyleMain + reports
(cd testmine && ./gradlew --warning-mode all help && ./gradlew :dbmodel:loadsadata --dry-run && ./gradlew :webapp:war --dry-run)
grep -h 'deprecated' "$WT"/.gate-logs/*.log | sort | uniq -c | sort -rn > deprecations-6.9.4.txt   # input to step 2
# deployer compat smoke (5.1.1 plugin must run on 4.9):
cd ../humanmine && sed -i 's/5.0.+/5.1.1/' gradle.properties && ./gradlew --offline :dbmodel:tasks --all && ./gradlew :dbmodel:compileJava --dry-run
```

Expected failures:
- **Configuration errors** from rows 1-3 if they are missed: `Cannot add task 'wrapper'`, `Could not find method stopExecutionIfEmpty()`, `Replacing a task that has already been realized`.
- **Plugin built with 6.9.4 fails on deployer 4.9**: Groovy 2.5 bytecode on a 2.4 runtime, seen as `NoSuchMethodError` from `org.codehaus.groovy.runtime.*`. Fallback: build the 5.1.1 plugin jar with a 4.9 wrapper in `plugin/` only. Old-compiled-on-new is the safe direction; `intermine` and `bio` on 6.9.4 can load it.
- **POM-consumption changes**: Gradle 5+ separates compile and runtime scopes (UG4:573), and from 6.0 a module whose metadata file is missing is treated as absent (UG5:403). This only bites consumers that read POMs (testmine via Central, deployers). Spot checks of `taglibs:string`, `mockobjects*`, `stax`, `ant`, `JOpenId`, `dwr`, `xmlunit`, `fastutil`, `antlr` and `tomcat@zip` all have POMs on Central.
- **Test-count drift**: there is no intended behaviour change, so any delta against the baseline is a bug.

Deprecation warnings that remain on 6.9.4, by design: rows 5-9 (`compile`, the `maven` plugin until S1b), 15, 19-21, 26-28, and all script `$buildDir` uses.

### 3.2 Step 2: 6.9.4 -> 7.6.4 (im-ee7.2, internal checkpoint, not released)

**2a, on 6.9.4 and in parallel.** This covers everything 6.9.4 accepts: `api`/`implementation`/`testImplementation`/`runtimeOnly`, `java-library`, `duplicatesStrategy`, `patternLayout`, `tasks.register`, `withDependencies` and `maven-publish`.

| Batch | Files | Dependency lines | Special items |
|---|---|---|---|
| P (plugin; **first**, blocks bio batches) | `plugin/build.gradle`, 17 Groovy files | 2 | all of section 2.1 except the Groovy 4 imports. Rename `api` before any `java-library`. |
| IM-core | `intermine/build.gradle`, `model`, `objectstore`, `pathquery`, `integrate`, `resources`, `testresources`, `api` (8 files) | 50 | `java-library` + `api` (row 5 rule). `bundled` (row 7). Delete the jar `dependsOn` (row 8). `testCompile.asPath` -> `testRuntimeClasspath` (5). Drop the antlr `srcDirs` override. Fold `copyDefaultProperties` into `processTestResources`. Exclude `antlr-2.7.6-caching` from the publication. `reports.html.required`. |
| IM-web + testmine | `intermine/webapp`, `webtasks`, `jbrowse-endpoint`, `testmine/build.gradle`, `testmine/dbmodel`, `testmine/webapp` (6 files) | 91 | the webapp publication is `components.web` + `classesJar`. `configurations.compile.asPath` ×10 -> `runtimeClasspath`. Fold the testmine copy tasks into `processResources` and remove the cross-project access (row 29). `war { from(unwarIMWebApp); duplicatesStrategy }` replaces `warTestModelWebApp`. |
| BIO-core | `bio/build.gradle`, `core`, `model`, `tools`, `webapp`, `testresources` (6 files) | 49 | `java-library` + `api` (core, model, tools, webapp). `bundled` in core. The bio-webapp publication is the merged war (`war { from(unwarIMWebApp) }`; delete `warBioWebApp`, `finalizedBy` and `signArchives.dependsOn`). |
| SRC-1 | `bio/sources/build.gradle` (root, owned only by this batch) + leaves 1-16 (`biogrid` to `homologene`, alphabetical) | 53 | `copyMineProperties` -> `processResources`; `implementation`; `bundled` in `psi-complexes` is in SRC-3 |
| SRC-2 | leaves 17-32 (`intermine-items-large-xml-file` to `protein2ipr`) | 36 | leaf-only |
| SRC-3 | leaves 33-47 (`psi` to `wormbase-identifiers`; skip the orphan `uberon`) | 37 | `psi-complexes` `bundled` |
| PP | `bio/postprocess/**` (17), `bio/postprocess-test/**` (9) | 85 | `compileTestJava.dependsOn buildUnitTestDB` -> `test.dependsOn` |

Order and merge constraints:
1. P merges first. Then IM-core, then IM-web+testmine and BIO-core in parallel.
2. SRC-1, SRC-2, SRC-3 and PP run in parallel after BIO-core. SRC-1 merges before SRC-2 and SRC-3 because it owns the root file.
3. Each batch's gate is the 6.9.4 gate for its own build plus every upstream build.

**2b: the flip** (one commit, Opus, after every 2a batch is merged): wrapper URL and `.in` templates set to 7.6.4, and the 7 wrapper sets regenerated.

```bash
GATE_INSTALL_ARGS="--gradle_distribution_url https://services.gradle.org/distributions/gradle-7.6.4-bin.zip" scripts/gate-intermine.sh "$WT" all
for m in $(cat modules.txt); do ./gradlew -q $m:dependencies --configuration compileClasspath | diff - "$BASE/deps/$m.compile.txt"; done   # only expected deltas
find . -path '*/build/libs/*' \( -name '*.jar' -o -name '*.war' \) | while read f; do diff <(unzip -Z1 $f | sort) "$BASE/art/$(basename $f).lst"; done
./gradlew generatePomFileForMavenJavaPublication && diff-scopes build/publications/*/pom-default.xml "$BASE/pom/..."   # compile vs runtime scope parity
```

Expected failures in 2b:
- `Could not find method compile()`: a batch was missed.
- `Entry X is a duplicate but no duplicate handling strategy has been set` (row 17).
- Groovy 3 compile errors in the plugin.
- `Cannot change dependencies of dependency configuration ... after it has been included in dependency resolution` (row 21, if any site is left).
- POM scope downgrades (`implementation` where `api` was needed): these show up as deployer or testmine `package ... does not exist`.

### 3.3 Step 3: 7.6.4 -> 8.14.6 (im-ee7.3, ships with step 2 as 6.0.0)

**3a, on 7.6.4.** Rows 13-15 if any are left (`archiveClassifier`, `required`; TestReport `destinationDirectory`/`testResults`). Row 25 (`providers.exec`). Row 26 (`java {}` block). Row 28 (space-assignment `sed` per property, UG8:509). Row 23 (`groovy.ant.AntBuilder`, `groovy.xml.XmlParser`, so the 6.0.0 jar is ready for Groovy 4). Rows 18 and 29 where 7.6 already warns. `canBeConsumed = false` on all plugin configurations: since 8.0, identical consumable configurations are an error (UG7:704). Version catalog (section 6).

| Batch | Files | Items |
|---|---|---|
| P3 | plugin | rows 23, 27, 28; the `war` composition for mines |
| ROOTS | the 7 root `build.gradle` + `settings.gradle` | rows 14, 26, 28; catalog wiring |
| TESTRES | `intermine/testresources`, `bio/testresources` | row 25; `generateTestModel` -> `build/generated/sources/testmodel` + `sourceSets.test.java.srcDir(generateTestModel)` |
| CATALOG | every `build.gradle` with third-party coordinates (24 files, per `inventory/intermine-dependencies.md:23`) | `libs.xxx` references |

**3b: the flip** to 8.14.6, plus the gate above with `--warning-mode all`. Target: zero deprecations from our own scripts and plugin; the cargo `convention` deprecations remain and are listed.

Expected failures in 3b:
- Removed APIs (rows 13, 15, 36).
- Implicit-dependency validation errors, for example `Task ':bio-core:jar' uses this output of task ':bio-core:copyMineProperties' without declaring an explicit or implicit dependency`. This is the largest class (row 18).
- `withSourcesJar()` combined with the antlr `srcDirs` override: `sourcesJar` uses `generateGrammarSource` output without a dependency.
- `SourceSet.classesDirs` no longer carries `processResources` (UG7:503-506). This affects ad-hoc tasks that used `sourceSets.main.output.classesDirs` (none found; check the gate).
- Checkstyle 7.8.1 running in an 8.14 worker **(verify)**.
- Cargo 2.9.0 on 8.14 **(verify)**: `./gradlew :webapp:cargoRunLocal` in `testmine/setup.sh:106` and the CI ws-tests job.

JDK: 6.9.4 runs on JDK 8 to 15, 7.6.4 on 8 to 19, and 8.14 on 8 to 24 **(verify upper bounds)**. CI stays on JDK 8 for steps 1-3 (`.github/workflows/im-build.yml:45`). JDK 17 is B4.

### 3.4 What 9.x needs in addition (later; plugin 7.0.0)

- **The daemon needs JVM 17** (UG9:420). Toolchains can still target 8 for compile, test, checkstyle and javadoc (UG9:422). But every InterMine Ant task the plugin runs (integrate, buildDB, postprocess, precompute) executes **inside the daemon**. So Gradle 9 means running the InterMine runtime on 17 (cglib 3.1, torque, JAXB, antlr 2) for every deployer. B4 must be done first.
- **Groovy 4** (UG9:439-474): row 23 done in 3a. Check `is`-prefixed boolean properties and closure delegation in the plugin.
- **Removed**: conventions (cargo 2.9.0 breaks, risk R6), `Project.exec`, `jcenter()`, implicit `archives` artifacts (UG9:771; any remaining `artifacts { archives ... }` must use publications), configuration mutation after observation (now an error).
- Deployers move again (Groovy 4), so plugin 7.0.0 requires Gradle 9.

### 3.5 Effort (agent-hours, including gate runs; wall time is lower with parallel batches)

| Step | Opus | Sonnet | Total | Wall time with 2 concurrent gates |
|---|---|---|---|---|
| 0 baseline artefacts | 0 | 2 | 2 | 1.5 h |
| 1 (incl. 1b publishing) | 6 | 2 | **8** | 4 h |
| 2 (2a: 7 batches + plugin; 2b flip) | 11 | 11 | **22** | 8 h |
| 3 (3a + catalog + 3b flip) | 5 | 7 | **12** | 5 h |
| deployer docs + humanmine/flymine (B5) | 1 | 3 | 4 | 2 h |
| 9.x (after B4) | 6 | 4 | 10 | 4 h |

## 4. Census of explicit `dependsOn`

D = data dependency: replace with input/output wiring. L = lifecycle ordering: keep, with a `// lifecycle:` comment. R = redundant: delete.

| Location | Edge | Class | Action |
|---|---|---|---|
| `plugin/build.gradle:22`, `intermine/build.gradle:108`, `bio/build.gradle:106`, `bio/sources/build.gradle:226`, `bio/postprocess:187`, `bio/postprocess-test:186` | `sourcesJar` -> `classes` | R | `withSourcesJar()`; `allSource` carries generator dependencies once the antlr `srcDirs` override is gone |
| same files, the `javadocJar` lines | `javadocJar` -> `javadoc` | D | `withJavadocJar()` or `from(tasks.named('javadoc'))` |
| `intermine/api:45`, `intermine/objectstore:45`, `bio/core:96` | `jar` -> `configurations.runtime` | R | delete |
| `intermine/{api:20, integrate:1, model:21, pathquery:25, objectstore:23, webapp:22}` | `test` -> `:intermine-testresources:buildDB` | L | keep: Postgres fixture, no file output |
| `bio/core:92`; `BioSourceDBModelPlugin:17` | `test` -> `buildUnitTestDB` | L | keep |
| `bio/core:93`, `bio/model:69` | `buildUnitTestDB`/`buildDB` -> `:bio-testresources:createUnitTestDatabases` | L | keep (creates DBs) |
| `bio/model:70` | `mergeModels` -> `processResources`, `copyGenomicModel`, `copyMineProperties`, `copyDefaultInterMineProperties` | D | `mergeModels.inputs.file(processResources output genomic_model.xml)`; delete the line |
| `bio/sources:143`, `bio/postprocess:122`, `bio/postprocess-test:121`, `testmine/build.gradle:77`, `testmine/webapp:64`, `humanmine/build.gradle:49` | copy* -> `processResources` | D | fold into `processResources.from(...)`; the task disappears |
| `bio/sources:288` | `compileTestJava` -> `copyMineProperties` | D | delete (it is a runtime resource) |
| `bio/postprocess:249`, `bio/postprocess-test:201` | `compileTestJava` -> `copyMineProperties`, `buildUnitTestDB` | D + L | delete the first; move the second to `test.dependsOn` |
| `bio/webapp:64-65,77` | `war` -> `unwarIMWebApp`; `finalizedBy warBioWebApp`; `signArchives` -> `warBioWebApp` | D | `war { from(unwarIMWebApp) }`; delete all three |
| `intermine/testresources:51` | `insertModel` -> `buildDB` | L | keep |
| `intermine/testresources:70` | `processTestResources` -> `copyDefaultProperties` | D | `processTestResources.from({ zipTree(commonResources.singleFile) }) { include ...; rename ... }` |
| `intermine/testresources:232-234` | `buildDB` -> `compileTestJava`, `createUnitTestDatabases`, `generateTestModel` | D, L, R | `inputs.files(sourceSets.test.runtimeClasspath)`; keep `createUnitTestDatabases`; delete `generateTestModel` (implied) |
| `intermine/testresources:257` | `compileTestJava` -> `generateTestModel` | D | `outputs.dir` + `sourceSets.test.java.srcDir(generateTestModel)` (stop writing into `src/test/java`) |
| `intermine/testresources:258` | `buildTestModelJar` -> `testClasses` | R | `from(sourceSets.test.output)` already carries it |
| `testmine/dbmodel:132,140,158` | `enormocorp` -> `loadsadata` -> `insertData` -> `buildDB` | L | keep (ordered DB loads) |
| `testmine/dbmodel:151,191,202` | `buildDB`/`insertUserData`/`createSearchIndex` -> `build`, copy* | D | `inputs.files(sourceSets.main.runtimeClasspath)`; copy* folded. `build` also ran tests, which was unintended. |
| `testmine/webapp:70-71,76,89` | `war` -> `mergeProperties`, `summariseTestObjectStore`, `unwarIMWebApp`; `finalizedBy`; `mergeProperties` -> `copyModelProperties`; summarise -> `copyDefaultProperties` | D | `war { from(unwarIMWebApp); webInf { from(mergeProperties); from(summariseTestObjectStore) } }` with declared `outputs` |
| `testmine/webapp:142`, `humanmine/webapp/build.gradle:101-105` | `cargo*` -> `war` | L | keep: Cargo 2.9.0 does not declare the war as a task input |
| `DBModelPlugin` 13 edges to `initConfig`; `WebAppPlugin` 7; `IntegratePlugin` 6 to `initIntegration`; `PostProcessPlugin` 1 to `initPostProcess`; `BioCore`/`BioModel`/`MineDBModel` 3 (30 in total) | to `init*` | R | the init tasks are deleted (apply-time setup plus `withDependencies`) |
| `DBModelPlugin:80-291` (6), `BioSourceDBModelPlugin:24,39`, `WebAppPlugin:34,61` | -> `processResources` | D | generate into `build/im/resources` and feed `processResources` |
| `DBModelPlugin:136,251`; `MineDBModelPlugin:14`; `BioSourceDBModelPlugin:71` | `generateKeys` -> `addSourceDependencies`; `generateModel` -> `mergeModels`; `mergeModels` -> copy*/`createSoModel` | D | file inputs and outputs (`@InputFile` model xml, `inputs.files(mergeSource)`) |
| `DBModelPlugin:259` | `compileJava` -> `generateModel` | D, **kept** | deployers set `srcDirs = ['build/gen']`, which would drop a lazily added srcDir; revisit in 7.0.0 |
| `IntegratePlugin:33` | duplicate of the above | R | delete |
| `DBModelPlugin:264-372`, `WebAppPlugin:140-213`, `IntegratePlugin:36`, `PostProcessPlugin:67` | DB tasks -> `jar`, `compileJava`, `copyMineProperties`, `copyDefaultInterMineProperties`, `generateKeys` | D | `inputs.files(sourceSets.main.output, antClasspath)` |
| `DBModelPlugin:319`; `WebAppPlugin:140-141` | `buildUserDB` -> `createUserDB`, `:webapp:loadDefaultTemplates`; `loadDefaultTemplates` -> `:dbmodel:createUserDB` + `mustRunAfter` | L, R | keep the dependsOn edges; delete the redundant `mustRunAfter` |
| `IntegratePlugin:113-214` | `integrate` -> single/multiple; single -> pre/retrieve/load; pre/retrieve -> `buildTgtItems`; `load` `mustRunAfter retrieve` | L | keep (DB pipeline order) |

Result: about 26 explicit edges remain, all lifecycle, out of 94.

## 5. Risks and unknowns

| # | Risk | Evidence | Mitigation |
|---|---|---|---|
| R1 | **Plugin and Gradle coupling for deployers**, plus a dynamic `imVersion` | decision 3; `flymine/gradle.properties:1` | compat smoke test in the step 1 gate; 6.0.0 is a new major so `5.1.+` cannot pick it up; release notes say "plugin 6 requires Gradle 8.14" |
| R2 | **`install_intermine.py` assumptions**: a single wrapper URL for all builds (:188); `install` task (:137); module list skips `bio/postprocess-test` and `testmine` (:121-127); offline mode turns `distributionUrl` into a bare zip name (:200-201), which has to sit next to each `gradle-wrapper.properties`; the `**/gradle.properties.in` glob also writes `testmine/webapp/gradle.properties` (subproject, ignored for `org.gradle.jvmargs`); generated files are gitignored (`.gitignore:227-228`) | file | S1-core: URL plus checksum; S1b: `publishToMavenLocal`; keep the templates (offline mode needs them) |
| R3 | **Ivy local repos** read `build/libs` with artifact-only metadata (`bio/build.gradle:30-42`). There are no transitive dependencies, so every bio module re-declares them. They are listed before Central, so stale jars win. 5.1.1 is not on Central (latest 5.1.0), so an unbuilt upstream fails resolution. Artifact *file names* are the interface. | files | keep `[artifact]-[revision](-[classifier]).[ext]` names stable (`archiveClassifier` keeps them); always gate with upstream rebuilt; composite build removes this later (section 6) |
| R4 | **Test-jar sharing**: the `testArtifacts` legacy configuration, the `testClasses` classifier jar resolved by `bio/core:74` and `bio/sources:119`, and raw `sourceSets.test.output` access across projects | rows 29-30 | publish the classifier jars explicitly; set `canBeResolved = false` on `testArtifacts`; move to `java-test-fixtures` before any composite |
| R5 | **antlr 2 caching jar**: flatDir (`intermine/build.gradle:18-20`), no group or version. On 7+ the antlr plugin puts it on `api` (decision 7), so it would leak into the POM/.module (5.1.0 POMs omit it). It is also bundled into the bio-core fat jar (`bio/core/libs`), and `runIQLQuery` adds `antlr-complete:3.5.2` (`DBModelPlugin:353`). | files, Central POM | exclude it from `apiElements`/`runtimeElements`, or publish it once as `org.intermine:antlr-caching:2.7.6`; JDK 17 behaviour is a B4 item |
| R6 | **Cargo 2.9.0**: no release since 2022; conventions removed in 9.0 | plugin metadata; bytecode | fine for 8.14 **(verify)**; before 9.x, replace with plain Cargo Ant tasks or a manager-API `curl` task. Any replacement package needs a `decisions/package-vetting.md` entry. |
| R7 | **Checkstyle**: 7.8.1 is three Gradle defaults behind. Bumping needs config changes: `LineLength` sits under `TreeWalker` (`config/checkstyle/checkstyle.xml:100`, must move to `Checker` for >= 8.24); `allowUndeclaredRTE` (:40) is removed in 8.28; JavadocMethod `scope` becomes `accessModifiers` (8.42); missing-javadoc checks move to `MissingJavadocMethod`, so coverage drops silently. 10.x needs Java 11. | file | keep 7.8.1 through 8.14 if `checkstyleMain` passes; separate issue to bump to 9.3 with the config migration and a violation-count diff |
| R8 | **JDK**: Gradle 8.14 on JDK 8 is supported and is CI's setup; 9.x needs 17 for the daemon, which hosts the Ant tasks | UG9:420-422 | B4 (JDK 17) before 9.x; optionally use the daemon JVM criteria in 8.14 to test 17 early |
| R9 | **Ant classpath order** changes with `compile` -> `runtimeClasspath`; two Ant coordinates are present (`inventory/intermine-dependencies.md:122`) | inventory | run testmine `loadsadata` and a humanmine `buildDB` smoke test; diff `runtimeClasspath` order |
| R10 | **Silent war and jar content change** from `duplicatesStrategy` (4.9 wrote duplicate zip entries) | row 17 | artifact-listing diff gate; choose `EXCLUDE` vs `INCLUDE` per task from the diff |
| R11 | **Publishing**: OSSRH is retired; the Central Portal needs a verified `org.intermine` namespace and user tokens; signing has never been enforced (row 12) | files | step 1b: `maven-publish` + `signing`, deploying to the Portal's OSSRH-staging-compatible endpoint, then the Portal upload call **(verify current Sonatype docs)**; a Portal-native plugin (e.g. GradleUp nmcp) is optional for 8.14 and needs vetting |
| R12 | **Implicit-dependency errors in 8.0** are numerous and only partly visible as 7.6 warnings | row 18 | 3a fixes everything 7.6 warns about; 3b gate is `--warning-mode all` on every task the CI and `testmine/setup.sh` run |
| R13 | **No baseline recorded yet** | `baselines/` empty | step 0 |
| R14 | **Deployer web builds** use gretty from a raw GitHub URL, duplicate war composition, `main=` and `jcenter()` | section 2.3 | plugin-owned war in 6.0.0; `docs/UPGRADING-build.md` (B5) |

## 6. Recommendations: version catalog and composite build

**Version catalog: adopt in step 3a** (the feature is stable since 7.4).
- Use one file, `gradle/libs.versions.toml`, at the repo root. Each of the 7 `settings.gradle` files references it with `dependencyResolutionManagement { versionCatalogs { libs { from(files('../gradle/libs.versions.toml')) } } }`, with the relative depth per build (`../../` for `bio/sources`).
- Generated properties are not needed; this replaces the "shared via generated properties" idea in `plans/10-intermine-backend.md:50`.
- Dependabot understands catalogs. Put the InterMine version in `[versions]` too, and have the plugin default to its own jar version instead of `System.getProperty("imVersion")`. Keep the system property only as an override for deployers.
- For deployers, publish a `java-platform` BOM (`org.intermine:intermine-bom`) later rather than the catalog: it also works for Maven consumers such as rdfc2im.

**Seven builds vs. a composite build: keep seven builds through step 3, then add an umbrella composite (B6).**
- Keeping the builds separate during the upgrade preserves CI's per-build commands (`config/ci/run.sh:44-69`), the gate script and the batch boundaries above.
- After 8.14, add a root `settings.gradle` with `includeBuild` for the 6 library builds plus testmine, and `pluginManagement { includeBuild('plugin') }`. Dependency substitution matches `org.intermine:<project-name>` automatically: `intermine-api`, `bio-core` and the other names already equal the artifact names.
- That removes the ivy repos, the `intermine.development.*` properties in 8 `.in` files and the install ordering. It also restores transitive metadata, so the transitive dependencies re-declared in `bio/build.gradle`, `bio/sources/build.gradle` and `bio/postprocess*/build.gradle` can be deleted.
- Prerequisite: substitution ignores classifiers and `@war`. The `testClasses`, `classes` and war dependencies must first become variant-aware (`java-test-fixtures`; a separate `intermine-webapp-classes` jar or feature variant; a `warElements` consumable configuration with attributes).
- Trade-off for deployers: nothing is forced, because they keep consuming published artefacts. The gain is optional: a mine can `includeBuild('../intermine')` to develop against a checkout, which is impossible today without `install`. A single merged multi-project build is not recommended. It would rewrite every `settings.gradle` and every `${rootDir}/../config` path for little extra gain over the composite.
