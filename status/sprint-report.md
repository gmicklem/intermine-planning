# Sprint report

Generated 2026-11-15 18:50 by `scripts/sprint-report.py` (since 2026-11-14). Regenerate with `python3 -I scripts/sprint-report.py`. All times UTC.

## 1. Headline

Sprint window (first to last timestamp in agent-runs.csv and the orchestrator log): 2026-11-14 22:38:30 UTC to 2026-11-15 18:50:34 UTC, elapsed 20:12:03.

Total agent runs recorded: 63 (3 of them resumptions of an earlier agent, charged only for the tokens added since its previous row).

| Model | Runs | Success | Failed | Partial | Other | Input tok | Cache read tok | Cache write tok | Output tok | Wall-clock agent time | Median run |
|---|---|---|---|---|---|---|---|---|---|---|---|
| opus | 23 | 23 | 0 | 0 | 0 | 4,282 | 372,143,637 | 16,585,230 | 1,667,950 | 18:57:37 | 0:41:59 |
| sonnet | 40 | 40 | 0 | 0 | 0 | 4,462 | 255,538,902 | 13,644,921 | 1,761,445 | 29:46:10 | 0:27:12 |
| **all workers** | 63 | 63 | 0 | 0 | 0 | 8,744 | 627,682,539 | 30,230,151 | 3,429,395 | 48:43:47 | 0:34:13 |
| orchestrator (fable) | n/a (539 msgs) | - | - | - | - | 13,648 | 136,091,981 | 1,159,841 | 495,234 | - | - |

Success = outcome `done`/`success`; failed = outcome starting `fail`/`error`/`abort`/`blocked`; partial = starting `partial`; other = anything else. Wall-clock agent time is the sum of ended minus started per run; agents ran in parallel, so it exceeds elapsed time. The orchestrator is the main Claude Code session (not in agent-runs.csv); its totals come from the session JSONL (1 file(s), de-duplicated per API message id) and cover its whole context re-reads, so cache read is large by nature.

Cross-check (agent-runs.csv / all subagent logs on disk, 62 logs parsed): differences are agents not yet recorded or still running.

| Model | Input | Cache read | Cache write | Output |
|---|---|---|---|---|
| opus | 4,282 / 4,282 | 372,143,637 / 372,143,637 | 16,585,230 / 16,585,230 | 1,667,950 / 1,667,950 |
| sonnet | 4,462 / 4,768 | 255,538,902 / 281,284,048 | 13,644,921 / 13,959,342 | 1,761,445 / 1,852,186 |

## 2. Delivered

### Commits on maint-2026 since 2026-11-14

| Repo | Ref | Commits | Merge commits |
|---|---|---|---|
| intermine-planning | HEAD | 64 | 0 |
| intermine | maint-2026 | 132 | 26 |
| bluegenes | maint-2026 | 79 | 5 |
| imcljs | maint-2026 | 8 | 0 |
| bluegenes-tool-store | maint-2026 | 8 | 0 |
| im-tables-3 | maint-2026 | 21 | 3 |

**intermine merge commits**

- `5279e4ee25 Merge maint/im-jqz.6-junit-vendored: JUnit 4.13.2, EasyMock 5.7; mockobjects, mockrunner, stringtree-json, libreadline-java, chebiWS-client removed; one patched antlr jar [im-jqz.6]`
- `10728b1bc0 Merge maint/im-ee7.5-deployer-guide: UPGRADING-build.md 6.0.0 section as a deployer step list, verified on humanmine and flymine [im-ee7.5]`
- `256977fbcb Merge maint/im-ee7.26-checkstyle-bump: Checkstyle 9.3 through the plain Gradle plugin; the Gradle 6 Ant bridge is deleted [im-ee7.26]`
- `03dcc65839 Merge maint/im-jqz.4-tier2-cves: bcprov removed (JDK-only certificate writer), OpenID 2.0 login and JOpenId removed, Oltu 1.0.2, DWR 2.0.11 [im-jqz.4]`
- `99a3aee9ed Merge maint/im-ee7.4-jdk17: builds and tests pass on JDK 8, 17 and 21; --release 8; --add-opens for cglib on JDK 9+; CI on JDK {8,17} x PostgreSQL {14,16}; deployer notes [im-ee7.4]`
- `159341ef2d Merge maint/im-jqz.25-webapp-libs: no log4j 2.5 in the bio war; junit, hamcrest, spring-test out of the war; Jersey removed, registry lookup via HttpURLConnection [im-jqz.25 im-jqz.26 im-jqz.11]`
- `70094bf344 Merge maint/im-ee7.24-jar-hygiene: no intermine.properties in published or dbmodel jars; no duplicate antlr, javax.inject, Jackson, lang3, logging jars in the wars [im-ee7.24 im-ee7.39 im-ee7.35]`
- `331bb31924 Merge maint/im-jqz.3-commons-ant-json: drop commons-beanutils and commons-codec usage; commons-collections 3.2.2, commons-io 2.22.0, commons-fileupload 1.6.0, ant 1.10.18; org.json declared in pathquery [im-jqz.3]`
- `4a72be62af Merge maint/im-ee7.3-gradle-814-flip: Gradle 8.14.6; zero deprecations from InterMine scripts and plugin; testmine on 8.14; addStrutsConfig inputs [im-ee7.3]`
- `58d3b6cb44 Merge maint/im-ee7.3-catalog-modules: all module coordinates in gradle/libs.versions.toml; conflicts resolved (xmlunit 1.6, oltu 1.0.1, commons-codec 1.15, jami-core 3.2.12) [im-ee7.3]`
- `4c53c22158 Merge branch 'maint-2026' into maint/im-ee7.3-catalog-modules`
- `476353f95d Merge maint/im-ee7.3-plugin-gradle8: plugin on groovy.ant/groovy.xml, layout.buildDirectory, = assignment, resolvable-only configurations [im-ee7.3]`
- `7e9227efaa merge: maint-2026 (ROOTS+TESTRES batch) into the plugin branch [im-ee7.3]`
- `7cdc8efb9e Merge maint/im-ee7.3-roots-testres: providers.exec, java {} block, = assignment, version catalog [im-ee7.3]`
- `11f73cb204 Merge maint/im-ee7.2-gradle-76-flip: Gradle 7.6.6 wrapper, checkstyle classpath on Gradle 7, TestReport 7.4+ API [im-ee7.2][im-ee7.17][im-ee7.18]`
- `a794507af1 Merge maint/im-bdy.3-docs: BUILDING, TESTING, UPGRADING-build docs; README fixes [im-bdy.3]`
- `567bb18dd7 Merge maint/im-89g.5-ci-actions: GitHub Actions current majors [im-89g.5]`
- `d178eb5cbe Merge maint/im-89g.3-maven-publish: maven-publish, centralBundle, RELEASING.md [im-89g.3]`
- `0d1016ae71 Merge maint/im-ee7.2-batch-bio: bio builds on Gradle 7 configurations [im-ee7.2]`
- `ccad4270c8 Merge branch 'maint-2026' into maint/im-ee7.2-batch-bio`
- `c1a158f511 Merge maint/im-jqz.8-flaky-tests: deterministic testBatchesCache; DataTracker.clear() thread-safe [im-jqz.8][im-ee7.9]`
- `70d2644cf1 Merge maint/im-ee7.2-batch-sources: bio/sources and testmine build files on Gradle 7 configurations [im-ee7.2]`
- `3774b2af7a Merge maint/im-ee7.2-batch-intermine: intermine/** build files on Gradle 7 configurations [im-ee7.2]`
- `742f3c9c4d Merge maint/im-jqz.7-weak-deps: remove 14 weak dependency declarations, dead HttpClient, commons-httpclient [im-jqz.7]`
- `42e105197e Merge maint/im-ee7.2-plugin-gradle7: plugin lazy tasks, no init tasks, input wiring [im-ee7.2]`
- `31d15fa725 Merge maint/im-ee7.1-gradle-6: Gradle 6.9.4 across all builds [im-ee7.1]`

**bluegenes merge commits**

- `331b7124 Merge maint/im-7os.27-imjs-global: window.imjs for BlueGenes tools from the bundled imjs 4.0.0 (CDN script tag was removed upstream in Oct 2024); xmldom override; tool-rendering Cypress check [im-7os.27]`
- `5fd13485 Merge maint/im-7os.25-window-react: the app sets window.React and window.ReactDOM again for BlueGenes tools [im-7os.25]`
- `dab1a840 Merge maint/im-7os.23-humanmine-default: HumanMine is the default public mine for Cypress @external specs, templates test and docs; CYPRESS_EXTERNAL_ONLY [im-7os.24]`
- `69de5e6b Merge maint/im-7os.15-hljs11: highlight.js 11.12.0 shims and CDN theme with new SRI [im-7os.15]`
- `0acf48ef Merge maint/im-7os.2-lib-bumps: Clojure 1.12, ring 1.13, timbre 6, reagent 1.2, re-frame 1.4, reitit 0.7, React 18, react-select 5; drop core.cache, react-day-picker, react-transition-group, react-highlight.js [im-7os.2]`

**im-tables-3 merge commits**

- `7dd9082 Merge maint/im-7os.23-humanmine-default: HumanMine is the default mine for unit tests and the demo [im-7os.24]`
- `782b448 Merge maint/im-7os.15-hljs11: highlight.js 11.12.0, highlightElement, v11 github theme [im-7os.15]`
- `6d8df0f Merge maint/im-7os.2-lib-bumps: reagent 1.2, re-frame 1.4, React 18, react-select 5; drop react-day-picker and react-transition-group [im-7os.2]`

### Beads

`bd status`: total 166, open 88, in progress 8, blocked 0, ready 88, closed 70.

| Epic | Title | Epic status | Children | Open | In progress | Closed |
|---|---|---|---|---|---|---|
| im-28e | Epic F: BlueGenes tests and CI | open | 8 | 3 | 2 | 3 |
| im-7os | Epic E: BlueGenes toolchain modernisation | open | 29 | 13 | 0 | 16 |
| im-89g | Epic D: intermine CI and release pipeline | open | 10 | 5 | 0 | 5 |
| im-8dd | Epic I: Planning repo, beads, dashboard | open | 6 | 1 | 2 | 3 |
| im-bdy | Epic H: Docs and governance | open | 3 | 2 | 0 | 1 |
| im-ee7 | Epic B: intermine build toolchain (Gradle 4.9 -> 8.x, JDK 17) | open | 49 | 24 | 3 | 22 |
| im-jqz | Epic C: intermine Tier 1 dependency upgrades and removals | open | 33 | 23 | 1 | 9 |
| im-ore | Epic G: Whole-system testbed | open | 9 | 5 | 0 | 4 |
| im-rkn | Epic A: Environment and baseline | open | 10 | 3 | 0 | 7 |

#### Closed issues by epic

**im-28e Epic F: BlueGenes tests and CI**

- `im-28e.1` F1 kaocha unit tests green on new toolchain
- `im-28e.2` F2 Cypress 13+ migration targeting the rdfc2im mine
- `im-28e.4` bluegenes gate: smoke must execute the JS bundle, not just HTTP 200 (lesson from E1 review)

**im-7os Epic E: BlueGenes toolchain modernisation**

- `im-7os.1` E1 shadow-cljs + deps.edn build reproducing dev/prod/kaocha; Node 22; lessc current
- `im-7os.10` bluegenes: remaining npm advisories (7 critical, 22 high) via cypress 6, less 1.7.5, bootstrap 3; resolve in E1/E2 bumps
- `im-7os.15` bluegenes: highlight.js 9.12.0 + react-highlight.js -> highlight.js 11 (the only production npm advisory; breaking API)
- `im-7os.17` im-tables: re-run test suite with FlyMine defaults when reachable (sort-column rewrite compares ids case-insensitively; only tested on numeric HumanMine ids); README to document IM_TABLES_SERVICE_ROOT / IM_TABLES_MINE_NAME; npm audit 2 high
- `im-7os.18` S5: switch bluegenes deps.edn to the sibling snapshots (imcljs 1.7.0-SNAPSHOT, im-tables 0.16.0-SNAPSHOT, tool-store 0.3.0-SNAPSHOT) or git deps, then E2 lockstep bumps
- `im-7os.2` E2 Library bumps: ClojureScript, re-frame 1.4, reagent 1.2/React 18, reitit, ring 1.12, timbre
- `im-7os.24` bluegenes/im-tables/imcljs tests: HumanMine as the default public mine (Gos: HumanMine is the most important service); FlyMine only for Drosophila-specific or multi-mine cases; im-tables test_config + demo app default, bluegenes @external Cypress specs, kaocha tests, gate probes, nightly-cypress.yml, docs
- `im-7os.25` [bug] bluegenes: built app no longer sets window.React / window.ReactDOM (cljsjs jars did; lost in the npm migration im-7os.1); BlueGenes tools (e.g. @intermine/bluegenes-protein-visualizer) throw 'reading Component' on HumanMine gene report pages; set the globals in src/shim, add a runbundle/gate check for React global, remove the /tools/ uncaught-error ignore in report_page_test.js
- `im-7os.27` [bug] bluegenes: tools need window.imjs (upstream 06363a30 Oct 2024 removed the CDN script tag); protein visualizer, MSA viewer, protein-atlas, human-tissue, expression visualizers fail with 'imjs is not defined'; bundle imjs 4.0.0 from npm setting window.imjs (vetting entry required), make runbundle/Cypress fail on missing imjs; check which tools expect jQuery
- `im-7os.3` E3 imcljs / im-tables-3 / bluegenes-tool-store on the same toolchain
- `im-7os.4` E4 CDN assets pinned with SRI or bundled; vega bumps
- `im-7os.5` E5 npm security: ws, wait-on, xmlhttprequest; npm audit clean
- `im-7os.6` commons-compress 1.19 -> 1.27.1 in tool-store/bluegenes (needs commons-io 2.16.1 + commons-codec 1.17.1 pins under lein)
- `im-7os.7` tool-store: replace dead api.npms.io discovery with registry.npmjs.org search (:objects, size=250), fail loudly
- `im-7os.8` tool-store: sanitise ../ in tar entry names (zip-slip) in package.clj
- `im-7os.9` tool-store: SERVER_PORT env var parsed as Long -> Integer/parseInt ClassCastException in core.clj:43

**im-89g Epic D: intermine CI and release pipeline**

- `im-89g.1` D1 GitHub Actions: pull_request trigger, setup-java@v4 matrix, Gradle cache
- `im-89g.2` D2 .github/dependabot.yml (gradle, github-actions)
- `im-89g.3` D3 maven-publish + Central Portal publishing; docs/RELEASING.md
- `im-89g.4` D4 PR template, CONTRIBUTING.md, README badges
- `im-89g.5` ci (both repos): bump actions/setup-java to v5 and checkout/setup-node/cache to current majors (Node 24 runtime); or let dependabot do it

**im-8dd Epic I: Planning repo, beads, dashboard**

- `im-8dd.1` I1 Planning repo skeleton, beads init, worktree scripts
- `im-8dd.3` I3 Transcript generator and transcript.md
- `im-8dd.4` I4 Per-area plan docs 10/20/30/40

**im-bdy Epic H: Docs and governance**

- `im-bdy.2` H2 Decision records: gradle-upgrade-vs-switch, jdk-target, struts-stance, bluegenes-build-tool, beads-usage, branching

**im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> 8.x, JDK 17)**

- `im-ee7.1` B1 Gradle 4.9 -> 6.9.4 across all seven builds and plugin; tests green on JDK 8
- `im-ee7.11` gate-intermine.sh header still says default Gradle 4.9; update
- `im-ee7.15` plugin: unwarBioWebApp + addStrutsConfig -> Sync task when the plugin composes the war (P3)
- `im-ee7.16` build files: compileTestJava.dependsOn -> test.dependsOn in bio/core, bio/model, bio/postprocess*; drop redundant mergeModels.inputs.files(processResources) in bio/model
- `im-ee7.17` B2 flip: checkstyle 7.8.1 fails on Gradle 7.x (JavadocMethod 'Unable to get class information for @throws' x7 in intermine-api; 8.45 rejects allowUndeclaredRTE): suppress, fix tags, or bump checkstyle + config
- `im-ee7.18` B2 flip: root testReport task destinationDir->destinationDirectory and reportOn->testResults (7.x-only APIs)
- `im-ee7.2` B2 Gradle 7.6.4: compile->implementation/api, maven->maven-publish, plugin getByName(compile) rework
- `im-ee7.22` plugin: fold copyMineProperties into processResources (needs DBModelUtils.mineProperties() change)
- `im-ee7.24` intermine bio/model jar ships the test intermine.properties (contains DB credentials) - exclude from jar (pre-existing, seen in batch B listings)
- `im-ee7.25` B5 input: deployer changes seen in flymine smoke on 6.9.4/7.6: convert compile lines, drop maven plugin and jcenter(), delete stopExecutionIfEmpty(); webapp compile needs full data-source set
- `im-ee7.26` R7 checkstyle bump: 7.8.1 -> 9.3 (Gradle 8.14 default) or 10.x; migrate config (allowUndeclaredRTE removed, JavadocMethod options), then DELETE config/gradle/checkstyle-classpath.gradle (100-line classloader workaround; flagged for Gos as convoluted/temporary)
- `im-ee7.29` B5 deployer list from 7.6.6 flymine smoke: delete stopExecutionIfEmpty(); drop maven plugin; compile->implementation, testCompile->testImplementation; drop jcenter(); remove gretty apply-from and block; regenerate wrapper; JavaExec main= -> mainClass= before 8.0 (flymine webapp/build.gradle:138, humanmine :127)
- `im-ee7.3` B3 Gradle 8.14, remove com.sun.xml.internal property, version catalog
- `im-ee7.30` B3 CATALOG batch: move the 50 module-file coordinates into gradle/libs.versions.toml; resolve conflicts commons-codec 1.15/1.9, oltu client 1.0.1/1.0.0 (intermine/webapp both), jami-core 3.0.0/3.2.12, xmlunit 1.6/1.0; plugin/build.gradle literal 5.1.1 -> catalog; docs/RELEASING.md:50 version note
- `im-ee7.34` RELEASE BLOCKER check: does the 5.1.1 candidate plugin (release/5.1.1-candidate, built on Gradle 6.9.4) run in a Gradle 4.9 mine? G1 found the 7.6.6-built plugin fails on 4.9 (NoClassDefFoundError groovy/ant/AntBuilder). If 6.9.4-built also fails, 5.1.1 must document 'mine on Gradle 6.9.4' and UPGRADING-build.md must drop the 4.9 claim
- `im-ee7.35` intermine-webapp war built by the 7.6.6 toolchain carries two versions of jackson (2.18.12 + 2.7.5), commons-lang3, ant, javax.inject, jcl-over-slf4j (diff in repos/.sandbox-disk/rdfc2im/logs_ut/war-listing-diff-5.0.8-vs-5.1.1.txt); fix dependency metadata (resolutionStrategy / exclusions) before 6.0.0
- `im-ee7.37` plugin addStrutsConfig uses outputs of copyMineProperties and copyWebappContent without declaring dependencies (Gradle 7 warns, Gradle 8 errors); seen in the G1 humanmine build
- `im-ee7.39` 6.0.0 deployer guide + plugin: with the new copyMineProperties pattern intermine.properties (DB credentials) lands in the mine's dbmodel jar; add jar { exclude 'intermine.properties' } to the guide and consider doing it in the plugin
- `im-ee7.4` B4 JDK 17 build and test run; JDK 21 verification
- `im-ee7.5` B5 Deployer migration: update humanmine/flymine build files; docs/UPGRADING-build.md
- `im-ee7.7` intermine: regenerate the seven gradlew scripts and wrapper jars for 6.9.4 (S1-wrap)
- `im-ee7.9` intermine: flaky IntegrationWriterDataTrackingImplTest (setUp IllegalArgumentException cascades to 17 failures) under concurrent gates

**im-jqz Epic C: intermine Tier 1 dependency upgrades and removals**

- `im-jqz.1` C1 Postgres JDBC 42.7.x + HikariCP
- `im-jqz.11` intermine: remove jersey-media-json-jackson + Jersey client (inventory R13) and the jackson-jaxrs-json-provider line
- `im-jqz.2` C2 Jackson 2.17+, org.json, everit json-schema
- `im-jqz.25` intermine bio/webapp war ships log4j-core/api/slf4j-impl 2.5 (Log4Shell) via biojava-core and biojava-ontology; other modules exclude org.apache.logging.log4j, bio/webapp does not; also a second SLF4J binding
- `im-jqz.26` intermine bio/webapp war stale jars: junit-4.10 + hamcrest-core (via json-simple), spring-test, aopalliance-1.0 next to aopalliance-repackaged; commons-logging + jcl-over-slf4j both in testmine war
- `im-jqz.3` C3 commons-* (collections, io, lang, fileupload, httpclient, codec, math3 duplicate)
- `im-jqz.4` C4 bcprov, oltu, JOpenId, DWR CVE check (Tier 2 minimal)
- `im-jqz.7` C7 Weak-dependency removals from the usage census
- `im-jqz.8` intermine: flaky testBatchesCache in FlatMode/WithNotXml ObjectStoreInterMineImplTest (test-order dependent result cache)

**im-ore Epic G: Whole-system testbed**

- `im-ore.1` G1 rdfc2im --intermine-src: consume local org.intermine artefacts and war
- `im-ore.2` G2 mine-tests fixtures for the local demo mine (mines.toml local)
- `im-ore.5` mine-tests: add a 'local' mine entry; skip JBrowse/location tests when the mine has no locations; configurable template threshold; separate service and BlueGenes URLs; browser executable-path option
- `im-ore.6` G1 prerequisites for --intermine-src (from A5 baseline): override imVersion/bioVersion 5.0.+ in the humanmine checkout; reactome source hard-codes 5.0.8; artefacts via private maven repo (-Dmaven.repo.local), not shared ~/.m2; UPSTREAM_CACHE/intermine -> our worktree; wrapper newer than 4.9

**im-rkn Epic A: Environment and baseline**

- `im-rkn.1` Install toolchain in sandbox (JDK 8/11/17/21, Postgres 18, lein, chromium, bd)
- `im-rkn.2` Clone sibling repos imcljs, im-tables-3, bluegenes-tool-store
- `im-rkn.3` Baseline: intermine build and tests on JDK 8 / Gradle 4.9 / Postgres 18
- `im-rkn.4` Baseline: bluegenes cljfmt, kaocha (chromium), prod uberjar
- `im-rkn.5` Baseline: rdfc2im full-build + make test-live + mine-tests against local stack
- `im-rkn.6` Inventory: intermine dependencies, CVEs and usage census
- `im-rkn.7` Inventory: bluegenes + sibling libs dependencies, advisories and usage census

## 3. Cost per outcome

Mean tokens per run, by model and outcome class:

| Model | Outcome class | Runs | Mean input | Mean cache read | Mean cache write | Mean output |
|---|---|---|---|---|---|---|
| opus | success | 23 | 186 | 16,180,158 | 721,097 | 72,520 |
| opus | failed | 0 | - | - | - | - |
| sonnet | success | 40 | 112 | 6,388,473 | 341,123 | 44,036 |
| sonnet | failed | 0 | - | - | - | - |

Five most expensive runs, ranked by output tokens, then cache write tokens (no prices supplied):

| Run | Bead | Model | Output tok | Cache write tok | Outcome |
|---|---|---|---|---|---|
| E1 bluegenes shadow-cljs migration | im-7os.1 | opus | 177,729 | 755,011 | done |
| B2 batch P plugin rewrite | im-ee7.2 | opus | 151,358 | 653,034 | done |
| intermine dependency census and CVE inventory | im-rkn.6 | sonnet | 133,496 | 316,367 | done |
| Gradle upgrade path design (read-only) | im-ee7 | opus | 132,117 | 312,803 | done |
| B4 JDK 17 build and tests; JDK 21 check | im-ee7.4 | opus | 123,396 | 3,947,438 | success |

## 4. Model usage pattern

**opus** (23 runs)

- Survey intermine build/test state (`im-rkn`)
- Survey bluegenes build/test state (`im-rkn`)
- Survey rdfc2im/docker_template/mine-tests/beads (`im-rkn`)
- A3 intermine baseline (`im-rkn.3`)
- Gradle upgrade path design (read-only) (`im-ee7`)
- shadow-cljs migration design (read-only) (`im-7os.1`)
- B1 Gradle 4.9->6.9.4 (`im-ee7.1`)
- E1 bluegenes shadow-cljs migration (`im-7os.1`)
- E1 review fixes (`im-7os.1`)
- B2 batch P plugin rewrite (`im-ee7.2`)
- E1 pre-merge review (`im-7os.1`)
- Fix flaky testBatchesCache + DataTracker.clear race (`im-jqz.8`)
- A5 rdfc2im testbed baseline (cached data) (`im-rkn.5`)
- B2 flip: Gradle 7.6.6 + checkstyle classpath + TestReport API (`im-ee7.2`)
- F2 Cypress 13 migration (`im-28e.2`)
- B3 P3: plugin ready for Gradle 8/Groovy 4 (`im-ee7.3`)
- B3 ROOTS+TESTRES: providers.exec, java{}, = assignment, version catalog (`im-ee7.3`)
- im-tables deps.edn validation vs local mine (`im-7os.3`)
- B3 3b: flip to Gradle 8.14.6 (`im-ee7.3`)
- G1 rdfc2im --intermine-src (local 5.1.1 artefacts) (`im-ore.1`)
- S5 bluegenes on sibling git deps (`im-7os.18`)
- E2 bluegenes+im-tables library bumps (`im-7os.2`)
- B4 JDK 17 build and tests; JDK 21 check (`im-ee7.4`)

**sonnet** (40 runs)

- intermine dependency census and CVE inventory (`im-rkn.6`)
- bluegenes dependency census and inventory (`im-rkn.7`)
- Write dashboard generator (`im-8dd.2`)
- Split plan into per-area docs (`im-8dd.4`)
- A4 bluegenes baseline (`im-rkn.4`)
- Decision records 0001-0006 (`im-bdy.2`)
- bluegenes weak-dependency removals (`im-7os.5`)
- imcljs deps.edn + shadow-cljs migration (`im-7os.3`)
- tool-store deps.edn migration (`im-7os.3`)
- C1+C2 JDBC/Hikari/Jackson/json/everit/ant/math3 bumps (`im-jqz.1`)
- C7 intermine weak-dependency removals (`im-jqz.7`)
- im-tables-3 deps.edn + shadow-cljs migration (`im-7os.3`)
- D1+D2+D4 GitHub Actions, dependabot, docs (`im-89g.1`)
- CI fix: drop sudo -E for Postgres (`im-89g.1`)
- CI fix2: PG15+ public schema grant (`im-89g.1`)
- F3 bluegenes GitHub Actions (`im-28e.3`)
- D3 maven-publish + Central Portal (`im-89g.3`)
- B2 batch I intermine build files (`im-ee7.2`)
- B2 batch B: bio core/postprocess build files to Gradle 7 configs (`im-ee7.2`)
- B2 batch S bio/sources + testmine (`im-ee7.2`)
- tool-store fixes im-7os.6-9 (`im-7os.6`)
- H1 intermine docs: BUILDING/TESTING/UPGRADING-build (`im-bdy.3`)
- CI actions major bumps (both repos) (`im-89g.5`)
- I5 sprint-report generator (`im-8dd.5`)
- B3 CATALOG: module coordinates to version catalog (`im-ee7.3`)
- E4 CDN assets SRI + vega bumps (`im-7os.4`)
- bluegenes npm advisories (`im-7os.10`)
- 5.1.1 candidate plugin on Gradle 4.9 check (`im-ee7.34`)
- G2 mine-tests local mine entry + capability flags (`im-ore.2`)
- C3 commons-*, ant, org.json cleanup (`im-jqz.3`)
- highlight.js 9 -> 11 (bluegenes + im-tables) (`im-7os.15`)
- jar hygiene: credentials out of jars, duplicate libs out of wars (`im-ee7.24`)
- webapp libs: log4j 2.5 out, stale jars out, Jersey removed (`im-jqz.25`)
- C4 Tier 2 CVE check: bcprov, oltu, JOpenId, DWR (`im-jqz.4`)
- HumanMine as default test mine (im-tables + bluegenes) (`im-7os.24`)
- R7 checkstyle 7.8.1 -> 9.3, bridge deleted (`im-ee7.26`)
- window.React/ReactDOM globals for tools (`im-7os.25`)
- window.imjs for tools (bundled imjs 4.0.0) (`im-7os.27`)
- C6 JUnit 4.13.2, EasyMock 5.7, vendored jars 16->6 (`im-jqz.6`)
- B5 deployer migration: humanmine, flymine, UPGRADING-build.md (`im-ee7.5`)

## 5. Notes

Approximate pricing: not applied. Token totals are shown without prices; pass `--prices prices.json` (model name to per-million-token prices for input, cache_read, cache_write, output) to add an approximate cost.

Token counts are de-duplicated per API message id. Runs that resume an earlier agent are charged for the increase over the previous row of that agent (same started_utc).

## 6. Open items / blockers

| Issue | Title | Status | Why listed |
|---|---|---|---|
| im-7os.19 | siblings before release: im-tables deps.edn still lists imcljs 1.6.0, tool-store lists imcljs 1.4.3 -> point at imcljs 1.7.0; release all three to Clojars (human: credentials) then switch bluegenes back to Maven coordinates (design 5.3) and drop the CI consumer workaround | open | label human, title mentions human |
| im-89g.7 | D3 follow-up: test real Central Portal upload (central.sonatype.com blocked in sandbox); human: Portal account, org.intermine namespace, GPG key, run docs/RELEASING.md for 5.1.1 | open | label human, title mentions blocked, title mentions human |
| im-rkn.9 | sandbox/human: approve cdn.jsdelivr.net and cdn.intermine.org (BlueGenes loads scripts from them; browser tests against the local stack fail without them); Playwright's own Chromium needs 8 apt libs on Ubuntu 26.04 (PLAYWRIGHT_HOST_PLATFORM_OVERRIDE=ubuntu24.04-arm64) | open | label human, label blocked, title mentions human |

`bd status` also counts 0 issue(s) as blocked by unfinished dependencies (see `bd blocked`).
