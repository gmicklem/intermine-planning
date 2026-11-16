# Sprint report

Generated 2026-11-16 21:13 by `scripts/sprint-report.py` (since 2026-11-14). Regenerate with `python3 -I scripts/sprint-report.py`. All times UTC.

## 1. Headline

Sprint window (first to last timestamp in agent-runs.csv and the orchestrator log): 2026-11-14 22:38:30 UTC to 2026-11-16 21:13:01 UTC, elapsed 46:34:30.

Total agent runs recorded: 173 (3 of them resumptions of an earlier agent, charged only for the tokens added since its previous row).

| Model | Runs | Success | Failed | Partial | Other | Input tok | Cache read tok | Cache write tok | Output tok | Wall-clock agent time | Median run |
|---|---|---|---|---|---|---|---|---|---|---|---|
| opus | 32 | 32 | 0 | 0 | 0 | 6,596 | 561,353,996 | 26,418,968 | 2,511,121 | 28:38:51 | 0:48:55 |
| sonnet | 141 | 139 | 0 | 0 | 2 | 122,897 | 1,051,442,026 | 40,027,843 | 5,643,697 | 72:36:16 | 0:22:02 |
| **all workers** | 173 | 171 | 0 | 0 | 2 | 129,493 | 1,612,796,022 | 66,446,811 | 8,154,818 | 101:15:07 | 0:23:44 |
| orchestrator (fable) | n/a (1578 msgs) | - | - | - | - | 39,036 | 646,253,706 | 2,979,528 | 1,310,493 | - | - |

Success = outcome `done`/`success`; failed = outcome starting `fail`/`error`/`abort`/`blocked`; partial = starting `partial`; other = anything else. Wall-clock agent time is the sum of ended minus started per run; agents ran in parallel, so it exceeds elapsed time. The orchestrator is the main Claude Code session (not in agent-runs.csv); its totals come from the session JSONL (1 file(s), de-duplicated per API message id) and cover its whole context re-reads, so cache read is large by nature.

Cross-check (agent-runs.csv / all subagent logs on disk, 171 logs parsed): differences are agents not yet recorded or still running.

| Model | Input | Cache read | Cache write | Output |
|---|---|---|---|---|
| haiku | 0 / 2 | 0 / 0 | 0 / 9,356 | 0 / 112 |
| opus | 6,596 / 6,328 | 561,353,996 / 539,911,758 | 26,418,968 / 25,017,650 | 2,511,121 / 2,416,630 |
| sonnet | 122,897 / 18,212 | 1,051,442,026 / 1,081,670,590 | 40,027,843 / 43,085,914 | 5,643,697 / 5,795,525 |

## 2. Delivered

### Commits on maint-2026 since 2026-11-14

| Repo | Ref | Commits | Merge commits |
|---|---|---|---|
| intermine-planning | HEAD | 240 | 0 |
| intermine | maint-2026 | 294 | 70 |
| bluegenes | maint-2026 | 148 | 26 |
| imcljs | maint-2026 | 12 | 2 |
| bluegenes-tool-store | maint-2026 | 19 | 4 |
| im-tables-3 | maint-2026 | 42 | 11 |

**intermine merge commits**

- `a27dcf5398 Merge maint/im-bdy.11-docs-sweep: documentation agrees with the 6.0.0 tree (BUILDING, TESTING, RELEASING, UPGRADING-build, CONTRIBUTING, RELEASE_NOTES, header comments, setup.sh echo) [im-bdy.11]`
- `c923cc6420 Merge maint/im-jqz.67-throws-charset: chado-db @throws documented (checkThrowsDocs covers every build); sql Query UTF-8; UPGRADING XMLOutputFactory note [im-jqz.67 im-ee7.69]`
- `44e70ad9f7 Merge maint/im-89g.30-release-notes: RELEASE_NOTES entries for 5.1.1 and 6.0.0 [im-89g.30]`
- `7f63073aa6 Merge maint/im-jqz.64-followups: LoadQueryAction 400, explicit UTF-8 (PasswordHasher with fallback), MetabolicGeneSummaryDisplayer model-aware; dead config lines; GFF3Converter scoreType restored; @throws docs + checkThrowsDocs in the Checkstyle CI job; commons-logging docs [im-jqz.64 im-ee7.66 im-jqz.66 im-ee7.68 im-ee7.42]`
- `5351d0c301 Merge maint/im-89g.10-6.0.0: the 6.0 line is 6.0.0 (one catalog entry); ant 1.6.5 source documented [im-89g.10]`
- `dab8b39d01 Merge maint/im-ee7.67-versions: one place to bump the version (install_intermine.py reads the catalog); StAX writers flush (XMLOutputFactory workaround gone); org.intermine modules and Cargo as catalog libraries [im-ee7.67 im-ee7.33 im-ee7.40]`
- `8f80e927fd Merge maint/im-jqz.16-bio-batch: XSLT audit (nothing uses it); psi-complexes allInteractors/ranges/stoichiometry; ChEBI names via REST; xmlunit confined to real users [im-jqz.16 im-jqz.54 im-jqz.30 im-jqz.33]`
- `28de302a28 Merge maint/im-ee7.54-plugin-batch: war warns on two versions of one library; unwarBioWebApp uses the source set's resources dir; report tasks declare outputs; Cargo config in the build dir; 26 Javadoc comments fixed, @throws enforcement measured [im-ee7.54 im-ee7.32 im-ee7.56 im-ee7.44 im-ee7.45]`
- `05a1f192ee Merge maint/im-jqz.32-torque: own DDL generator replaces the vendored torque/velocity jars (DDL identical for 12 objectstore configurations incl. HumanMine's 243 tables); commons-lang 2 and commons-logging gone from the catalog; UPGRADING/BUILDING notes [im-jqz.32 im-jqz.24]`
- `a5b3d3ef9c Merge maint/im-ee7.62-build-ci-batch: plugin TestKit tests in CI (+11 tests); plugin version from the catalog; runtimeOnly for never-compiled-against deps; boxed constructors -> valueOf (1331); dead log4j2.properties; testmine Ant logging [im-ee7.62 im-89g.13 im-89g.9 im-ee7.63 im-ee7.43 im-ee7.58]`
- `47430e9bd6 Merge maint/im-jqz.17-cleanups: DataTracker recovers from a failed write (volatile flag, messages, no lost entries); test leak fixed; dead bio-fulldata-test objectstore removed; stale .gitignore; bio-model default properties explained; docs/README tidy [im-jqz.17 im-jqz.18 im-ee7.31 im-89g.15 im-jqz.27 im-bdy.8 im-bdy.4]`
- `ed4bc60f40 Merge maint/im-jqz.56-webapp-batch: facet values unescaped in queries; unique temp list names + atomic rename; autocompleter getContent exposed, dead historyBagView.js gone; serialVersionUID on form beans; multi-class report pages, ForwardParameters null, UTF-8 in the data load [im-jqz.56 im-jqz.57 im-jqz.60 im-jqz.40 im-jqz.62]`
- `9555d84f95 Merge maint/im-jqz.35-commons-lang: commons-lang 2 no longer reaches mine classpaths (solrj exclusion, torque confined to the DDL task, SqlGenerator cast types inlined); UPGRADING section [im-jqz.35 im-jqz.34]`
- `bf6503cdd3 Merge maint/im-jqz.29-cglib: Byte Buddy replaces cglib for dynamic model objects; no --add-opens needed on JDK 17; UPGRADING notes [im-jqz.29]`
- `ee17636458 Merge maint/im-jqz.58-rdf-500: RDF export expands ontology CURIEs and drops blank terms, so RDF/XML no longer 500s on GOTerm/Pathway; Gene SO term typo fixed [im-jqz.58]`
- `92219f54ee Merge maint/im-jqz.49-orphans2: 218 message keys of vanished pages removed, unreferenced widget JS, getSingleUseKey, dangling tiles and the viewInvitation action gone; webapp sweep scripts in docs/tools with a release step [im-jqz.49]`
- `5465eb8840 Merge maint/im-jqz.47-charts-shim: local SVG charts shim replaces the Google Charts loader for list-widgets (no third-party script left on the legacy webapp); footer wording [im-jqz.47]`
- `bca41e465b Merge maint/im-ee7.14-plugin-publishing: legacy runtime re-mapping removed from publishing.gradle; stale maven-plugin comments; testmine unwarIMWebApp uses into (POMs and jars identical before/after) [im-ee7.14 im-89g.6]`
- `0f6b9ce82a Merge maint/im-ee7.51-plugin-testkit: 11 Gradle TestKit tests for the plugin (createSoModel, mergeProperties, war composition, unwarBioWebApp, Ant logging); mergeProperties no longer glues intermine.properties onto a web.properties without a final newline; createSoModel sees a mine's log4j config; bio/webapp unwarIMWebApp syncs [im-ee7.51]`
- `96ab7070d3 Merge maint/im-jqz.52-dwr-hardening: dwr.xml publishes only the 36 AjaxServices methods the pages call; no JDate creator, no exception details to the client, bean converter only for api.beans [im-jqz.52]`
- `51556c9469 Merge maint/im-jqz.5-jena-solrj: Jena narrowed to jena-core + jena-arq and bumped to 3.17.0 (last Java 8 release; RDF output byte-identical, pinned by a test); solrj without Netty, Jetty and Snappy; solrj and Lucene 3 stances documented [im-jqz.5]`
- `194dce17d8 Merge maint/im-jqz.55-userprofile-ids: id allocation skips ids already in the database and refills under a lock; profile loading skips and reports a colliding object instead of a ClassCastException that stopped the webapp [im-jqz.55]`
- `16e2e40976 Merge maint/im-jqz.53-solr-facet: keyword search facet selections are exact phrase filters on the facet_ string fields (values with spaces or Solr syntax chars returned nothing or a SyntaxError); bag-id filter was a broken varargs call [im-jqz.53]`
- `fe788d083c Merge maint/im-jqz.51-psi-participants: jaxb-runtime 2.3.x removed from the bio-source classpath (it silently took over jami-xml's JAXB binding since 2020 so complexes loaded with no participants); converter and parsing tests assert 14 participants; targets regenerated [im-jqz.51]`
- `ac788e9d04 Merge maint/im-jqz.28-webapp-hardening: registry lookup with timeouts and a retry interval; DWR servlet without debug pages, GET remoting or reverse Ajax; psi-complexes on one jami release (3.2.9) with parsing tests [im-jqz.28 im-jqz.31 im-jqz.19]`
- `7b6c1c742c Merge maint/im-jqz.36-delete-user: DELETE /service/user no longer 500s on a bag value with a null extra; TagManager.addTag returns the existing tag and retries on a duplicate key; TagManagerFactory synchronized [im-jqz.36]`
- `4a722d2a0c Merge maint/im-ee7.57-upgrading-plugin: 6.0.0 deployer notes for the plugin task wiring and Ant logging (verified on the humanmine/flymine forks), 5.1.1 webXml step and first-run note, ElSweep tool in docs/tools, CDN subsection filled in [im-ee7.57 im-bdy.6 im-bdy.7]`
- `27bbc14bf6 Merge maint/im-ee7.27-build-hygiene: Ant tasks log through reload4j again (build/im/antLogging log4j.properties on every taskdef classpath, log4j.ignoreTCL); BUILDING.md build/im table complete [im-ee7.36 im-ee7.28]`
- `950dfc7858 Merge maint/im-ee7.6-task-outputs: plugin copy/key/model tasks declare inputs and outputs under build/im/<task>; mergeModels has its own output dir; runtime-only resources out of jars and javadoc inputs; buildDB temp dir out of build/tmp (no-change rebuild after tests 79 s -> 10 s; jars identical in both task orders) [im-ee7.6 im-ee7.13 im-ee7.12 im-ee7.8]`
- `dbe5f9ed8f Merge maint/im-jqz.41-orphans: paging/count-estimate and background-query machinery, unused tags, JS, message keys and struts/tiles entries with missing classes removed [im-jqz.41]`
- `110df1b94f Merge maint/im-jqz.44-widget-npe: graph and enrichment widgets skip a null filter value (list of genes whose organism has no name) instead of a 500, with a filterWarning in the response [im-jqz.44]`
- `769d054b93 Merge maint/im-jqz.45-ext-hosts: InterMine logo served from the webapp (rawgit dead); no third-party script hosts on legacy pages except the Google Charts loader on bagDetails.do (list-widgets); Play badge removed; code snippet links the mine's font css; CORS on /vendor/fonts [im-jqz.45 im-jqz.46]`
- `65aab971a9 Merge maint/im-jqz.43-dead-cdn: the webapp serves its own copies of everything it loaded from the dead cdn.intermine.org (vendor/, SHA256SUMS, head.cdn.location ignored with a warning); generated JavaScript loads im-tables from the mine itself; upload confirm page works again in a real browser [im-jqz.43]`
- `03dfc486c7 Merge maint/im-89g.16-war-dups: the plugin's mine war drops the legacy ant:ant jar with a warning; UPGRADING-build.md on ant:ant, oltu and duplicate war entries [im-89g.16]`
- `6dae138b3f Merge maint/im-bdy.5-el-docs: deployer warnings for EL keyword property names and the dead cdn.intermine.org; release steps run the EL sweep [im-bdy.5]`
- `5a6064e30a Merge maint/im-jqz.39-dead-jsp: dead objectView/paging/tablePageLinks/tableCountEstimate pages, getTag.tag and jspRedirector.jsp removed with their tiles, actions and controllers; abbreviate.tag and locatedSequenceFeatureShort.jsp import the classes' current packages [im-jqz.39]`
- `f6deb9f47c Merge maint/im-ee7.21-weak-deps: unused biojava-core removed from bio-source-delimited [im-ee7.21]`
- `6dbc1417ff Merge maint/im-jqz.37-jsp-el: JSP EL no longer uses .class or Java keywords as property names (Tomcat 8.5.100+ Jasper rejects them); widgets and template pages render again, 104 EL errors to 0 on the testbed [im-jqz.37 im-jqz.38]`
- `2076822f6a Merge maint/im-jqz.21-beanutils: commons-beanutils 1.11.0 for the Struts runtime (CVE-2025-48734); gate 2125/92/59/12 on JDK 8, intermine on 17; 16 Struts form checks identical before and after on the testbed [im-jqz.21]`
- `08c7103d1c Merge maint/im-89g.8-ci-dbnames: CI bio properties name the database the build creates (bio-fulldata-test) [im-89g.8]`
- `3c485f0326 Merge maint/im-bdy.3-docs: developer docs final pass for maint-2026; UPGRADING-build.md separates the 5.1.1 and 6.0.0 lines, lists the three edits every mine needs, documents bio-source POM runtime scope [im-bdy.3 im-ee7.38 im-ee7.10 im-ee7.23]`
- `a93c0fba20 Merge maint/im-ee7.53-deployer-recheck: UPGRADING-build.md commons-lang step, re-check numbers with the final plugin, bio-sources conversion notes [im-ee7.53 im-ee7.52]`
- `45c10e48ee Merge maint/im-jqz.20-commons-lang3: commons-lang 2.6 -> commons-lang3 3.21.0 in 268 files; XmlUtil.escapeXml; secure random API keys; lang 2.6 kept at run time for the vendored torque [im-jqz.20]`
- `5fa33f25f8 Merge maint/im-ee7.46-plugin-deployer-fixes: webapp classes jar in webtasks/jbrowse POMs; SO paths resolved against the mine root; mergeProperties wired to processResources; the webapp plugin composes the war (Sync) [im-ee7.46 im-ee7.47 im-ee7.48 im-ee7.41]`
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

- `2785384e Merge maint/im-89g.30-changelog: CHANGELOG 1.5.0 (unreleased) [im-89g.30]`
- `669ae3ee Merge maint/im-7os.61-pin-imt: im-tables f780276 (reagent 2 readiness) [im-7os.61]`
- `94295acc Merge maint/im-7os.57-unsafe-html: unsafe-html compatibility for inner HTML [im-7os.57]`
- `38260724 Merge maint/im-7os.58-bg-batch3: transit-js 0.8.874; no possible-values requests for Date/clob attributes; im-tables 1be6530 and tool-store da4f23b pins; upload default organism re-applied after a late organism list [im-7os.58 im-7os.60 im-7os.59]`
- `e55d8b02 Merge maint/im-7os.52-bg-batch2: per-input region debounce flushed on search; vega-lite params; results code-export spec; compojure/core.async bumps [im-7os.52 im-7os.14 im-28e.11 im-7os.21]`
- `5a3f9229 Merge maint/im-7os.54-pins: imcljs d96a3eb and im-tables 0d6cbed pins (list saves from results work again) [im-7os.54]`
- `900f0ff5 Merge maint/im-7os.50-bg-followups: tool-store pin be4678f; React refs replace dom-node; re-frame-10x React 18 preload; Cypress without typing delays + keystroke regression spec; docs; unique default list names, visible save errors, unquoted identifiers [im-7os.50 im-7os.20 im-7os.41 im-28e.10 im-7os.39]`
- `76bd3f20 Merge maint/im-28e.13-repin: im-tables 0fc6eba; nightly builds the demo mine from rdfc2im 31eeae9 (green on the fork, 139/0/33) [im-28e.13]`
- `06be4a71 Merge maint/im-7os.32-chart-upload: tools are hidden when the mine lacks the widgets they need (the 'No data found!' rejections and go_enrichment_for_gene 404 came from go-term-visualizer and interaction-network); upload organism dropdown and state agree [im-7os.32]`
- `89169e30 Merge maint/im-7os.37-dev-build: oops 0.7.2 (dev build no longer calls the Closure predicates removed in the current library) [im-7os.37]`
- `c4c03f86 Merge maint/im-ore.16-nightly-repin: nightly builds the demo mine from rdfc2im d169a7f (organism names, one data set per pathway) [im-ore.16 im-ore.10]`
- `c399fdb0 Merge maint/im-ore.10-cypress-data: Cypress specs follow the corrected demo data (one Reactome data set, organism facet); counts derived from fixtures and /service/widgets [im-28e.12]`
- `661dc13a Merge maint/im-7os.46-sibling-pins: im-tables f04d757 (nil-safe dropdowns, first click on the static toolbar) and tool-store 4e3e896 (path containment, name validation); date spec without toolbar workarounds [im-7os.46]`
- `4b7a141c Merge maint/im-7os.22-date-input: a date constraint applies when picked or typed, not only on blur; @external date spec with a mock Date attribute (no public mine has one) [im-7os.22]`
- `a5e552bd Merge maint/im-7os.43-im-tables-pin: im-tables a36091a (code export loads im-tables from the mine, no cdn.intermine.org); Cypress 137/0/23 [im-7os.43]`
- `86a401f9 Merge maint/im-28e.7-nightly: nightly Cypress builds the rdfc2im demo mine in the job (release-asset data cache), runs this commit's BlueGenes, 137/0/23 on the fork; profile inputs disabled until preferences load [im-28e.7 im-7os.38]`
- `25aa153a Merge maint/im-7os.26-default-humanmine: HumanMine is the product default mine (Gos, 16 Nov 2026) [im-7os.26]`
- `24421fe5 Merge maint/im-7os.34-cdn-pins: sibling pins (tool-store 1029320, im-tables 146b1c5, one imcljs), no load of the dead rawgit logo, jQuery 3.7.1 from cdnjs with SRI; Cypress 137/0/23 with admin specs [im-7os.34 im-7os.13 im-7os.28]`
- `4f2b2524 Merge maint/im-7os.35-controlled-inputs: one start-up patch of reagent's input wrapper so no text input drops keystrokes under React 18 createRoot (0/6400 keys dropped vs 57 before); text-input removed, inputs plain again; flagged for Gos (reagent internals) [im-7os.35]`
- `79077194 Merge maint/im-7os.33-p1-bugs: ids case-sensitivity fix, text-input that keeps keystrokes under React 18 createRoot, search submits the typed term, Cypress defaults on the demo mine; 137 pass / 0 fail / 23 skipped [im-7os.30 im-7os.31 im-28e.9]`
- `0adc0ad8 Merge maint/im-28e.5-cypress-demo-mine: Cypress suite re-targeted to the rdfc2im demo mine (API-created test accounts, re-recorded fixtures, capability-based skips); 136 pass / 0 fail / 23 skipped [im-28e.5]`
- `331b7124 Merge maint/im-7os.27-imjs-global: window.imjs for BlueGenes tools from the bundled imjs 4.0.0 (CDN script tag was removed upstream in Oct 2024); xmldom override; tool-rendering Cypress check [im-7os.27]`
- `5fd13485 Merge maint/im-7os.25-window-react: the app sets window.React and window.ReactDOM again for BlueGenes tools [im-7os.25]`
- `dab1a840 Merge maint/im-7os.23-humanmine-default: HumanMine is the default public mine for Cypress @external specs, templates test and docs; CYPRESS_EXTERNAL_ONLY [im-7os.24]`
- `69de5e6b Merge maint/im-7os.15-hljs11: highlight.js 11.12.0 shims and CDN theme with new SRI [im-7os.15]`
- `0acf48ef Merge maint/im-7os.2-lib-bumps: Clojure 1.12, ring 1.13, timbre 6, reagent 1.2, re-frame 1.4, reitit 0.7, React 18, react-select 5; drop core.cache, react-day-picker, react-transition-group, react-highlight.js [im-7os.2]`

**imcljs merge commits**

- `d96a3eb Merge maint/im-7os.51-save-list [im-7os.51]`
- `82f5128 Merge maint/im-7os.26-default-humanmine: HumanMine in the README and dev examples [im-7os.26]`

**bluegenes-tool-store merge commits**

- `da4f23b Merge maint/im-7os.12-ts-cookies: standard cookie policy for registry requests; config.json reference for tool authors [im-7os.12 im-7os.49]`
- `be4678f Merge maint/im-7os.47-https-registry: tarball URL restricted to https registry.npmjs.org, integrity (SRI/shasum) verified before extraction, download and extraction bounded, installed version replaced only after verification [im-7os.47]`
- `4e3e896 Merge maint/im-7os.11-path-safety: real-path containment for tool directories (no sibling-dir or symlink escape), npm-rule package-name validation with 400 responses, tools.edn reserved [im-7os.11]`
- `1029320 Merge maint/im-7os.19-imcljs-pin: imcljs 1.7.0-SNAPSHOT by git sha instead of Clojars 1.4.3 [im-7os.19]`

**im-tables-3 merge commits**

- `f780276 Merge maint/im-7os.57-reagent2-ready: refs replace dom-node; unsafe-html compatibility for inner HTML [im-7os.57]`
- `1be6530 Merge maint/im-7os.55-imt-batch: filter dispatch fix + oops 0.7.2; cljs-time removed; explicit highlight.js languages; no possible-values request for Date/clob attributes [im-7os.55 im-7os.21 im-7os.23 im-7os.45]`
- `a15bf75 Merge maint/im-7os.54-pin-imcljs: imcljs pin d96a3eb [im-7os.54]`
- `0d6cbed Merge maint/im-7os.51-save-list [im-7os.51]`
- `0fc6eba Merge maint/im-28e.8-humanmine-default: dev page demo configs on HumanMine (lookup, wide, subclass, outer-join, boolean), no FlyMine config left [im-28e.8]`
- `f04d757 Merge maint/im-7os.44-dropdown-bugs: nil-safe filter dropdown handlers (hide.bs.dropdown without a last click; nil constraintLogic); the first click or tap on the static toolbar reaches the live table [im-7os.44 im-7os.40]`
- `a36091a Merge maint/im-7os.42-dead-cdn: generated HTML loads im-tables from the mine; :settings/cdn removed; dev page without the dead CDN [im-7os.42]`
- `146b1c5 Merge maint/im-7os.19-imcljs-pin: imcljs 1.7.0-SNAPSHOT by git sha until the Clojars release [im-7os.19]`
- `7dd9082 Merge maint/im-7os.23-humanmine-default: HumanMine is the default mine for unit tests and the demo [im-7os.24]`
- `782b448 Merge maint/im-7os.15-hljs11: highlight.js 11.12.0, highlightElement, v11 github theme [im-7os.15]`
- `6d8df0f Merge maint/im-7os.2-lib-bumps: reagent 1.2, re-frame 1.4, React 18, react-select 5; drop react-day-picker and react-transition-group [im-7os.2]`

### Beads

`bd status`: total 298, open 24, in progress 2, blocked 0, ready 24, closed 272.

| Epic | Title | Epic status | Children | Open | In progress | Closed |
|---|---|---|---|---|---|---|
| im-28e | Epic F: BlueGenes tests and CI | open | 13 | 0 | 0 | 13 |
| im-7os | Epic E: BlueGenes toolchain modernisation | open | 61 | 4 | 0 | 57 |
| im-89g | Epic D: intermine CI and release pipeline | open | 32 | 1 | 0 | 31 |
| im-8dd | Epic I: Planning repo, beads, dashboard | open | 9 | 0 | 2 | 7 |
| im-bdy | Epic H: Docs and governance | open | 10 | 2 | 0 | 8 |
| im-ee7 | Epic B: intermine build toolchain (Gradle 4.9 -> 8.x, JDK 17) | open | 67 | 1 | 0 | 66 |
| im-jqz | Epic C: intermine Tier 1 dependency upgrades and removals | open | 66 | 6 | 0 | 60 |
| im-ore | Epic G: Whole-system testbed | open | 21 | 1 | 0 | 20 |
| im-rkn | Epic A: Environment and baseline | open | 10 | 0 | 0 | 10 |

#### Closed issues by epic

**im-28e Epic F: BlueGenes tests and CI**

- `im-28e.1` F1 kaocha unit tests green on new toolchain
- `im-28e.10` bluegenes docs/building.md Cypress section still says two tests are @external; there are three (renders data in the tools of the report page); the rdfc2im raw-data release assets live on the gmicklem fork and could move to intermineorg later
- `im-28e.11` bluegenes cypress: add a spec for the results-table code export (Generate Code, JavaScript, Include HTML: snippet must reference <mine>/vendor/js/intermine/im-tables/2.2.0-beta and never cdn.intermine.org); note im-tables dashboard buttons need .trigger('mouseover') on .im-table first and the modal class is .im-modal
- `im-28e.12` bluegenes cypress: search_test (1) and enrichment_test (4) fail against the demo mine rebuilt with the im-ore.16/10 data (organism names, one Reactome data set, merged chromosomes) - update the specs/fixtures to the corrected data, then re-pin the nightly to rdfc2im d169a7f (side branch maint/im-ore.16-nightly-repin, run 43810273578)
- `im-28e.13` bluegenes nightly: re-pin RDFC2IM_REF to rdfc2im 31eeae9 (serial-sequence template ids, single public service root with bluegenes on the mine's network namespace, RDFC2IM_DATA_ROOT) with the next bluegenes change; check the nightly's check_prereqs/BG_PORT expectation
- `im-28e.2` F2 Cypress 13+ migration targeting the rdfc2im mine
- `im-28e.3` F3 GitHub Actions for bluegenes (cljfmt, kaocha, nightly cypress)
- `im-28e.4` bluegenes gate: smoke must execute the JS bundle, not just HTTP 200 (lesson from E1 review)
- `im-28e.5` F4 re-record Cypress specs and fixtures for the rdfc2im demo mine (113-gene panel; replace Biotestmine Plasmodium ids, MAL chromosomes, 'DB identifier' labels, GST hit counts, seeded test_user account); 41 failures today are all data
- `im-28e.6` bluegenes cypress: user_account_test.js has 4 upstream it.only calls (silently skips other tests); account specs register fixed user names (not idempotent on a long-lived mine)
- `im-28e.7` bluegenes: enable nightly-cypress.yml with npm run test:e2e against a mine (CYPRESS_MINE_URL/MINE_NAME); needs a mine in CI (rdfc2im stack or FlyMine @external)
- `im-28e.8` tests: default public mine is HumanMine (Gos): im-tables test_config default SERVICE-ROOT/MINE-NAME -> humanmine; bluegenes @external Cypress tests and gate-im-tables probe -> humanmine where the spec is not Drosophila-specific
- `im-28e.9` bluegenes cypress: cypress.config.js defaults still point at Biotestmine (set defaults to the demo mine, name 'rdfc2im: 113 gene food/drug-metabolism panel'); nightly-cypress.yml placeholder still describes Biotestmine (im-28e.7); regions_test edits untested on a mine with locations

**im-7os Epic E: BlueGenes toolchain modernisation**

- `im-7os.1` E1 shadow-cljs + deps.edn build reproducing dev/prod/kaocha; Node 22; lessc current
- `im-7os.10` bluegenes: remaining npm advisories (7 critical, 22 high) via cypress 6, less 1.7.5, bootstrap 3; resolve in E1/E2 bumps
- `im-7os.11` tool-store: delete-dir uses string/starts-with? on paths (sibling dir tools-evil passes); package name from API joined into path unvalidated
- `im-7os.12` tool-store: clj-http 'Invalid cookie header' warnings from npm registry -> :cookie-policy :standard; tools.clj help still says 'lein tools'
- `im-7os.13` bluegenes nav.cljs loads the logo from dead cdn.rawgit.com; move to a local asset
- `im-7os.14` bluegenes viz/cases.cljs uses deprecated vega-lite 'selection' forms (removed in vega-lite 6); migrate to params before the vega 6 / vega-lite 6 / vega-embed 7 major bump
- `im-7os.15` bluegenes: highlight.js 9.12.0 + react-highlight.js -> highlight.js 11 (the only production npm advisory; breaking API)
- `im-7os.17` im-tables: re-run test suite with FlyMine defaults when reachable (sort-column rewrite compares ids case-insensitively; only tested on numeric HumanMine ids); README to document IM_TABLES_SERVICE_ROOT / IM_TABLES_MINE_NAME; npm audit 2 high
- `im-7os.18` S5: switch bluegenes deps.edn to the sibling snapshots (imcljs 1.7.0-SNAPSHOT, im-tables 0.16.0-SNAPSHOT, tool-store 0.3.0-SNAPSHOT) or git deps, then E2 lockstep bumps
- `im-7os.19` siblings before release: im-tables deps.edn still lists imcljs 1.6.0, tool-store lists imcljs 1.4.3 -> point at imcljs 1.7.0; release all three to Clojars (human: credentials) then switch bluegenes back to Maven coordinates (design 5.3) and drop the CI consumer workaround
- `im-7os.2` E2 Library bumps: ClojureScript, re-frame 1.4, reagent 1.2/React 18, reitit, ring 1.12, timbre
- `im-7os.20` bluegenes: replace 11 uses of deprecated reagent.dom/dom-node (reagent 1.2); move re-frame-10x preload to its React 18 variant
- `im-7os.21` im-tables: drop cljs-time (single use in error.cljs); bluegenes: bump core.async/medley or compojure to silence 'already refers to' warnings on Clojure 1.12
- `im-7os.22` bluegenes/im-tables: test the new browser date input end to end against a mine with Date attributes (demo mine has none; HumanMine preferred)
- `im-7os.23` im-tables codegen: pass an explicit language-<name> class per selected language instead of auto-detection (Ruby is detected as Perl with highlight.js 11)
- `im-7os.24` bluegenes/im-tables/imcljs tests: HumanMine as the default public mine (Gos: HumanMine is the most important service); FlyMine only for Drosophila-specific or multi-mine cases; im-tables test_config + demo app default, bluegenes @external Cypress specs, kaocha tests, gate probes, nightly-cypress.yml, docs
- `im-7os.25` [bug] bluegenes: built app no longer sets window.React / window.ReactDOM (cljsjs jars did; lost in the npm migration im-7os.1); BlueGenes tools (e.g. @intermine/bluegenes-protein-visualizer) throw 'reading Component' on HumanMine gene report pages; set the globals in src/shim, add a runbundle/gate check for React global, remove the /tools/ uncaught-error ignore in report_page_test.js
- `im-7os.26` Decision for Gos: switch BlueGenes product default mine from FlyMine to HumanMine? config/defaults/config.edn, docs/configuring.md:13-15, script/ci/smoke.sh:22,37 change together; imcljs README/shadow-cljs.edn examples too
- `im-7os.27` [bug] bluegenes: tools need window.imjs (upstream 06363a30 Oct 2024 removed the CDN script tag); protein visualizer, MSA viewer, protein-atlas, human-tissue, expression visualizers fail with 'imjs is not defined'; bundle imjs 4.0.0 from npm setting window.imjs (vetting entry required), make runbundle/Cypress fail on missing imjs; check which tools expect jQuery
- `im-7os.28` bluegenes: jQuery 3.1.0 still loaded from code.jquery.com (same CDN-reliability risk as imjs had; no tool checked needs it); bundle or pin with SRI, or drop if nothing uses it
- `im-7os.3` E3 imcljs / im-tables-3 / bluegenes-tool-store on the same toolchain
- `im-7os.30` [bug] bluegenes ws/ids.clj:57: case-sensitive condition inverted (ticking 'Identifiers are case sensitive' lower-cases identifiers, UniProt accessions not found)
- `im-7os.31` [bug] bluegenes search input-new-term: on-submit uses the term from the last render (Enter right after typing searches nothing ~50% when logged in); controlled inputs drop keystrokes under fast typing ('PPARG' -> 'PARG'); Cypress works around both (1 s wait, typeSlowly helper) - fix the components and remove the workarounds
- `im-7os.32` [bug] bluegenes: chromosome chart throws unhandled 'No data found!' when empty (e2e.js ignores it); upload organism dropdown shows 'Any' while state holds the default organism missing from the list; go_enrichment_for_gene requested and 404s
- `im-7os.34` bluegenes: bump the tool-store pin to 1029320 and the im-tables pin to 146b1c5 (imcljs git-sha pins); tool-store build.clj could gain a :deploy alias so all three siblings release with the same env vars
- `im-7os.35` bluegenes: ~90 remaining reagent controlled inputs still drop keystrokes under React 18 createRoot - decide global fix (flushSync/reagent.dom.client sync render, or reagent patch) vs converting each site to text-input (components/ui/inputs.cljs); convert as touched meanwhile
- `im-7os.36` bluegenes gate-bluegenes.sh: also run 'npm run test:server' (clj tests, :test-clj alias added in im-7os.30)
- `im-7os.37` bluegenes dev build (shadow-cljs compile app) fails at runtime: goog.isBoolean is not a function (binaryage/oops vs current Closure library); release build unaffected
- `im-7os.38` bluegenes profile page: preferences response overwrites in-progress edits (one cy.wait(500) remains in admin_account_test for this); disable form while loading or merge instead of replace
- `im-7os.39` bluegenes lists: default list name has 1-second resolution so two saves in the same second collide and the mine returns a bare 400 (no user message); parse-identifiers leaves single-quoted tokens quoted ('c' stays 'c')
- `im-7os.4` E4 CDN assets pinned with SRI or bundled; vega bumps
- `im-7os.40` im-tables: toolbar renders as static HTML until the mouse passes over the table, so the first click on Export or a column summary does nothing (Cypress needs trigger('mouseover') first; real users may hit the dead first click)
- `im-7os.41` bluegenes cypress: drop the remaining {delay:100} typing in older specs now that inputs keep every keystroke; consider adding the im-7os.35 keystroke spec (40 keys x 8 inputs) as a permanent regression test (changes suite totals; copies in /home/agent/taskhomes/im-7os.35/)
- `im-7os.42` im-tables: default :cdn "http://cdn.intermine.org" in src/im_tables/db.cljs and the dev index.html script tag for imjs 3.15.0 point at the dead host; drop the :cdn setting (or make it nil and remove its users) and load the dev page's imjs from the npm bundle like bluegenes does
- `im-7os.43` bluegenes: bump the im-tables git-sha pin to the maint-2026 merge of im-7os.42 (export snippet without cdn.intermine.org) and re-run Cypress
- `im-7os.44` [bug] im-tables filter-dropdown-menu (views/table/head/controls.cljs): hide.bs.dropdown handler does (string/starts-with? @last-clicked-id ...) with a nil id -> 'Cannot read properties of null (reading lastIndexOf)' under Cypress (dropdown stays open); in real Chromium opening/closing any column filter logs 'Cannot read properties of null (reading trim)' (also on the stack's own BlueGenes, not date-specific)
- `im-7os.45` bluegenes/im-tables: confirm date constraints against a real InterMine with a Date attribute (testmine's testmodel has Types.dateObjType): point the date spec at a testmine instance from the testbed; also the query builder requests possible values (summaryPath, size 7000) for Date paths although the date input ignores them
- `im-7os.46` bluegenes: bump the im-tables pin (maint-2026 merge of im-7os.44/40) and the tool-store pin (4e3e896, im-7os.11), run the full Cypress suite; tool-store: require https for the registry tarball URL
- `im-7os.47` tool-store: require https for the registry tarball URL (file:/http: currently accepted by the download step)
- `im-7os.48` bluegenes: transit-cljs 0.8.256's com.cognitect.transit.types.print calls goog.isArray/goog.isString (removed from the Closure Library); latent (only in toString of transit map/set values); bump transit-cljs when a release drops them and remove the allowlist entry in gate-bluegenes.sh step 4b
- `im-7os.49` bluegenes tools: upstream fix is for the tool packages (go-term-visualizer, interaction-network, probably go-concept-relation which queries Gene.goAnnotation) to declare depends/widgets in their own config.json; also the upload page keeps organism Any if the organisms load after a reset
- `im-7os.5` E5 npm security: ws, wait-on, xmlhttprequest; npm audit clean
- `im-7os.50` bluegenes: bump the tool-store pin to be4678f (im-7os.47 tarball hardening) with the next sibling bump; optional: clj-http 'Invalid cookie header' warnings from the registry (set :cookie-policy :standard)
- `im-7os.51` [bug] im-tables: saving a list from query results fails on a mine with constraintLogic="" in the posted query XML (400 'XML is not well formatted'); omit the attribute when empty (curl confirmed); add a Cypress spec that saves a list from results; also each save failure shows two alerts, and im-tables' own default list name has 1-second resolution
- `im-7os.52` bluegenes regions: the extension inputs share one 250 ms debounce, so Search clicked within 250 ms misses the value and typing into the second input within 250 ms replaces the first (two Cypress tests use cy.wait(300) as a workaround); flush on Search and debounce per input; im-tables still uses reagent.dom/dom-node (components/bootstrap.cljs, views/table/head/controls.cljs) + 3 :fn-arity warnings
- `im-7os.53` bluegenes: evaluate reagent 2.0.1 (Oct/Nov 2025, React 19 batching changes) with the reagent input monkey-patch (decision 0007) disabled: does the keystroke-loss bug persist? If fixed, drop the patch; if not, raise an issue on reagent-project/reagent referencing the umbrella issue #619 with the measurements (Gos asked 16 Nov)
- `im-7os.54` sibling pin bumps after im-7os.51: im-tables deps.edn imcljs pin -> d96a3eb (gate), then bluegenes deps.edn imcljs -> d96a3eb and im-tables -> new im-tables head (gate + Cypress); until BlueGenes' imcljs pin moves, list saves from results still 400 there
- `im-7os.55` im-tables follow-ups from im-7os.51: views/table/head/controls.cljs:387 calls re-frame.core/dispatch with 2 args (filter 'Add More' button; real bug, build warns); oops 0.7.0 dynamic access calls goog.isBoolean in dev-mode builds (Closure removed it); bluegenes.prep/prepare-assets does not run lessc for site.css
- `im-7os.57` reagent 2.x readiness (later): im-tables calls reagent.dom/dom-node (head/controls.cljs, components/bootstrap.cljs; gone in reagent 2) and needs (reagent.core/unsafe-html ..) in views/core.cljs (static table dashboard renders empty without it); BlueGenes has two unsafe-html sites (results/widgets/views.cljs:29, templates/views.cljs:229); patch in planning reference/reagent-2.0.1-experiment.patch
- `im-7os.58` bluegenes: add explicit com.cognitect/transit-js 0.8.874 (drops goog.isArray/isString; transit-cljs stays 0.8.256) and remove the gate-bluegenes.sh step 4b allowlist entry for com.cognitect.transit.types.js; closure-preds must be empty after a dev build
- `im-7os.59` [bug] bluegenes upload page: organism stays 'Any' if the organism list loads after a reset (race between the reset event and the organisms fetch); HUMAN later: PRs on bluegenes-go-term-visualizer (widgets go_enrichment_for_gene), bluegenes-interaction-network (depends Interaction), bluegenes-go-concept-relation to declare depends/widgets in config.json, then drop crud/tools.cljs tool-requirements
- `im-7os.6` commons-compress 1.19 -> 1.27.1 in tool-store/bluegenes (needs commons-io 2.16.1 + commons-codec 1.17.1 pins under lein)
- `im-7os.60` bluegenes: query builder requests possible values (summaryPath, size 7000) for Date paths although the date input ignores them: skip for Date/clob attributes like im-tables 63b9b9a; also bump the im-tables pin to the merge of 63b9b9a (filter dispatch fix, Date fix, codegen languages) with the next sibling bump
- `im-7os.61` bluegenes: bump the im-tables pin to f780276 (reagent 2 readiness: dom-node gone, unsafe-html; removes 4 of 5 dev :fn-deprecated warnings); gate + Cypress
- `im-7os.7` tool-store: replace dead api.npms.io discovery with registry.npmjs.org search (:objects, size=250), fail loudly
- `im-7os.8` tool-store: sanitise ../ in tar entry names (zip-slip) in package.clj
- `im-7os.9` tool-store: SERVER_PORT env var parsed as Long -> Integer/parseInt ClassCastException in core.clj:43

**im-89g Epic D: intermine CI and release pipeline**

- `im-89g.1` D1 GitHub Actions: pull_request trigger, setup-java@v4 matrix, Gradle cache
- `im-89g.10` release 6.0.0: change humanmine/flymine fork pins from exact 5.1.1 to 6.0.+ and drop the 'published as 5.1.1' wording in UPGRADING-build.md; ant 1.6.5 sits next to ant 1.10 in mine wars (find the source)
- `im-89g.11` release: intermine-webtasks 5.1.0 POM on Maven Central has the webapp-war-as-dependency bug; 5.1.1 must carry the classes classifier fix (config/gradle/webapp-classes-dependency.gradle) - check the release/5.1.1-candidate branch
- `im-89g.12` 5.1.1 candidate ecabf7f66c: re-verify a Gradle 4.9 mine build against it (plugin tasks.named exclude, classes-classifier POM, commons-io 2.19 via fileupload 1.6.0) - the rdfc2im --intermine-src testbed run covers this
- `im-89g.13` intermine release checklist: plugin/build.gradle hard-codes version = '5.1.1' instead of reading the catalog; make the plugin version come from gradle/libs.versions.toml (or the generated gradle.properties) so a release bumps one place
- `im-89g.14` release/5.1.1-candidate: check its docs/UPGRADING-build.md matches the 5.1.1/6.0.0 split now in maint-2026 (3c485f0326); backport the 5.1.1 section if not
- `im-89g.15` intermine: the bio-fulldata-test objectstore is dead (no test opens it): remove os./db. entries from bio/model and intermine/resources default properties, the createDbInternal/grantPrivileges lines in bio/testresources/build.gradle, the dropDBs entry in intermine/testresources, init.sh line 46 and config/ci-bio.properties block; archive config/archive/codeship-init.sh still names biofulldatatest
- `im-89g.16` mine war duplicates on the 5.1.1 line: ant-1.6.5 + ant-1.7.0 (the mine's own compile('ant:ant:1.6.5') per UPGRADING step 3, plus whatever brings 1.7.0) and oltu client/common 1.0.0 + 1.0.1 in WEB-INF/lib; webapp.war from Gradle 6.9.4 has 63 duplicate zip entries (duplicatesStrategy). Decide: exclude in the plugin's war task or document for deployers; 6.0.0 line has oltu 1.0.2 - check it has one copy
- `im-89g.17` release/5.1.1-candidate: backport the JSP EL keyword fixes (710f6d0059 d1d758565e c949317eac: widget.jsp, template.jsp, historyBagView, objectView, dataSourceShort, tablePageLinks, imf:className/simpleClassName) - without them list widgets, templates and My Data lists are broken on Tomcat 8.5.100+/9.0.x
- `im-89g.18` release/5.1.1-candidate: backport im-jqz.43 (cdn.intermine.org removal: head.cdn.location, codegen imjs source, expected files) - RELEASING.md's CDN grep step must pass on 5.1.1 too
- `im-89g.19` release/5.1.1-candidate: war duplicates backport (from im-89g.16): drop the two providedCompile oltu 1.0.0 lines in intermine/webapp/build.gradle (POM then names one oltu; better bump client to 1.0.2), add the ant:ant classpath exclusion + warning to WebAppPlugin, and give a mine's warWebApp duplicatesStrategy EXCLUDE (plugin cannot compose the war on this line); verify on the ut 5.1.1 stack
- `im-89g.2` D2 .github/dependabot.yml (gradle, github-actions)
- `im-89g.20` release/5.1.1-candidate: backport im-jqz.46 + im-jqz.45 (c868487d6d, 04cc83f46f: vendored logo + BrandingService URL resolution, google jsapi off every page, Play badge, snippet font css, CORS on /vendor/fonts)
- `im-89g.21` release/5.1.1-candidate docs: port the 5.1.1 webXml step 6 and first-run step 7 (a6fb6035e3) into the candidate's UPGRADING-build.md (renumber, reword the 6.0 reference to the maint-2026 pointer), and optionally the 'Two deployer warnings' section + docs/tools/ElSweep
- `im-89g.22` release/5.1.1-candidate: backport im-jqz.36 (ca862be955 InterMineBagBinding null extra -> DELETE /service/user 500; e298df6dad TagManager dedup + 23505 retry, TagManagerFactory synchronized); should cherry-pick cleanly
- `im-89g.23` release/5.1.1-candidate: psi-complexes JAXB fix backport (443d49bdda): drop jaxb-runtime/jakarta.xml.bind-api from bio/sources/build.gradle, noOptimize in the converter, replace the vacuous assertEquals(4) test and regenerate the target; jami there is 3.0.0
- `im-89g.24` release/5.1.1-candidate: backport the Solr facet filter fix 4e1ec37ef2 (SolrKeywordSearchHandler identical there) [im-jqz.53]
- `im-89g.25` release/5.1.1-candidate: backport im-jqz.55 (6725c6de24 objectstore id allocation past existing ids + locked refill; 8203f6a6fc collision-tolerant wrapUserProfile/saveProfile); same code there bar a couple of lines
- `im-89g.26` release/5.1.1-candidate: backport the non-breaking parts of im-jqz.5 (Jena narrowed to jena-core + jena-arq, 3.17.0; solrj without netty/jetty/snappy) with the RDFSerialisationTest
- `im-89g.27` release/5.1.1-candidate: cherry-pick the web.xml DWR settings (f034052342, applies cleanly) and port dwr.xml hardening (7576d4b549) adding getColumnSummary and getResultsSize to the include list (imdwr.js still calls them there); DWR 2.0.1 error format without the exception converter untested
- `im-89g.28` 5.1.1 backport: RDF export CURIE expansion / blank-term fix (intermine b6975f4341: RDFHelper, ModelMerger, core.xml Gene term, R2RMLMappingProcess, 5 tests); Jena 3.17 on both lines so it should cherry-pick cleanly
- `im-89g.29` 5.1.1 backport candidates from im-jqz.56 batch: aff41f85d9 (facet escaping + model-less web config fields), c6cfc200a6 (unique temp list names, atomic rename), ed8d151727 (serialVersionUID), the ForwardParameters null guard and UTF-8 writeLargeUTF fix from 64bf2b9fce; abc225696a only if 5.1.1 has the dwr.xml hardening
- `im-89g.3` D3 maven-publish + Central Portal publishing; docs/RELEASING.md
- `im-89g.30` release notes: intermine RELEASE_NOTES has no 5.1.1 entry (both lines) and no 6.0.0 entry (maint-2026); bluegenes CHANGELOG has no 1.5.0 entry; write them from RELEASING.md's 5.1.1 list, the UPGRADING docs and the closed beads; fork CIs (humanmine-/flymine-bio-sources) red on an old Python 2.7 step: fix the workflow step
- `im-89g.31` release/5.1.1-candidate docs: apply the publishing.gradle header fix and the testmine/setup.sh echo fix from im-bdy.11; UPGRADING-build.md there still says maint-2026 carries 5.1.1 (lines 7/17) and its 6.0.0 half is ~350 lines behind maint-2026's: decide whether the 5.1.1 release ships the 6.0.0 migration guide (recommended: copy maint-2026's file) 
- `im-89g.32` release rehearsal: build the Central Portal bundles for 6.0.0 (maint-2026 a27dcf5398) and 5.1.1 (release/5.1.1-candidate be54f8d81f) locally with a throwaway GPG key per docs/RELEASING.md, verify layout (pom/jar/sources/javadoc/.asc/.md5/.sha1 per module, POM metadata Central requires: name, description, url, licenses, developers, scm), no upload; COMPLETION.md step 2 rehearsal
- `im-89g.4` D4 PR template, CONTRIBUTING.md, README badges
- `im-89g.5` ci (both repos): bump actions/setup-java to v5 and checkout/setup-node/cache to current majors (Node 24 runtime); or let dependabot do it
- `im-89g.6` D3 follow-up: drop legacy-runtime fix-up in config/gradle/publishing.gradle once bio uses runtimeOnly
- `im-89g.8` intermine CI: config/ci-bio.properties names database biofulldatatest but init.sh/Gradle create bio-fulldata-test; check which is used and align
- `im-89g.9` intermine: central-bundle.gradle header says <build>-<version>.zip but code writes <name>-bundle.zip; fix comment (docs/RELEASING.md describes the code)

**im-8dd Epic I: Planning repo, beads, dashboard**

- `im-8dd.1` I1 Planning repo skeleton, beads init, worktree scripts
- `im-8dd.3` I3 Transcript generator and transcript.md
- `im-8dd.4` I4 Per-area plan docs 10/20/30/40
- `im-8dd.6` gate-intermine.sh counts javac 'deprecated' lines as Gradle deprecations; separate the two counts
- `im-8dd.7` gate/testenv: task homes share ~/.gradle via symlink, so a 'gradle --stop' from one task kills another task's daemons (seen 15 Nov); give each task its own GRADLE_USER_HOME daemon dir or drop --stop from the gate
- `im-8dd.8` sprint infra: worker agents hang for ever when a Bash call hits a permission prompt (relative-path rm -rf under .sandbox-disk, 15 Nov 20:42Z, 78 min lost). Mitigations: worker prompts require absolute paths matching settings.local.json allow rules and run_in_background for long jobs; dashboard 'stalled' should trigger an orchestrator check within 15 min; consider allow rules for relative rm within .sandbox-disk/rdfc2im
- `im-8dd.9` testenv docs: baselines/intermine-2026-11-15.md caveat 9 and the worker-prompt rules still describe the shared ~/.gradle symlink layout (now per-task GRADLE_USER_HOME); workers that skip im-testenv.sh still share /home/agent/.gradle/daemon; optional --role-nogrant negative mode to reproduce PG15+ privilege failures

**im-bdy Epic H: Docs and governance**

- `im-bdy.11` intermine docs consistency sweep after the sprint's merges (maint-2026 c923cc6420): RELEASE_NOTES, docs/UPGRADING-build.md, BUILDING.md, TESTING.md, RELEASING.md, CONTRIBUTING.md, README must agree with the code (versions, removed libraries, task names, property names, CI steps); fix drift; same for the 5.1.1 candidate's docs where they describe that line
- `im-bdy.2` H2 Decision records: gradle-upgrade-vs-switch, jdk-target, struts-stance, bluegenes-build-tool, beads-usage, branching
- `im-bdy.3` H1 intermine docs: building, local testing, upgrading, releasing
- `im-bdy.4` intermine README: depsy.org badge likely dead; decide on badges (version badge 5.1.0 until release)
- `im-bdy.5` docs/UPGRADING-build.md: warn deployers that Tomcat 8.5.100+/9.0.x Jasper rejects EL property names that are Java keywords (.class, .boolean, .short) in the mine's own JSPs; give the scan script (jsp_sweep.py from im-jqz.37, parse every ${} with the container's ExpressionBuilder) and the SKIP_IDENTIFIER_CHECK stop-gap
- `im-bdy.6` intermine docs: copy reference/jsp-el/ElSweep.java + README from the planning repo into intermine docs/tools/ so deployers find the EL sweep the guide describes; fill the real im-jqz.43 property names/paths into UPGRADING-build.md's CDN subsection after it merges
- `im-bdy.7` docs/UPGRADING-build.md 5.1.1 section: add the webXml edit full-build.sh applies and the first-run note (a fresh mine's first :webapp:war fails with missing web.xml until :webapp:copyWebappContent has run once; known first-run wipe)
- `im-bdy.8` docs/tools/README-el-sweep.md (both lines): the results section cites maint-2026 ids and 246 files/3786 expressions; the 5.1.1 tree gives 239/3783 (same 10 failures before the fixes) - make the section line-neutral or per line

**im-ee7 Epic B: intermine build toolchain (Gradle 4.9 -> 8.x, JDK 17)**

- `im-ee7.1` B1 Gradle 4.9 -> 6.9.4 across all seven builds and plugin; tests green on JDK 8
- `im-ee7.10` B5 deployer guide: deployers must delete stopExecutionIfEmpty(); gretty resolves from dead jcenter; SO file paths relative to daemon dir
- `im-ee7.11` gate-intermine.sh header still says default Gradle 4.9; update
- `im-ee7.12` intermine plugin: runtime-resources dir so test-only files stop leaking into build/resources/main and jars (completes im-ee7.6; javadoc reruns)
- `im-ee7.13` bio/model: mergeModels edits processResources output in place, so bio/model is never up to date
- `im-ee7.14` plugin/build.gradle: maven -> maven-publish, classifier, sourcesJar/javadocJar dependsOn (part of D3/S1b)
- `im-ee7.15` plugin: unwarBioWebApp + addStrutsConfig -> Sync task when the plugin composes the war (P3)
- `im-ee7.16` build files: compileTestJava.dependsOn -> test.dependsOn in bio/core, bio/model, bio/postprocess*; drop redundant mergeModels.inputs.files(processResources) in bio/model
- `im-ee7.17` B2 flip: checkstyle 7.8.1 fails on Gradle 7.x (JavadocMethod 'Unable to get class information for @throws' x7 in intermine-api; 8.45 rejects allowUndeclaredRTE): suppress, fix tags, or bump checkstyle + config
- `im-ee7.18` B2 flip: root testReport task destinationDir->destinationDirectory and reportOn->testResults (7.x-only APIs)
- `im-ee7.19` intermine: jsonassert declared api in model but only webapp tests use it -> testImplementation in webapp (after im-jqz.13 org.json declaration)
- `im-ee7.2` B2 Gradle 7.6.4: compile->implementation/api, maven->maven-publish, plugin getByName(compile) rework
- `im-ee7.20` bio/sources psi-complexes: chebiWS-client-2.4.jar is on the compile/runtime classpath but neither packed into the jar nor in the POM (NoClassDefFoundError risk in mines): decide bundled vs POM dependency
- `im-ee7.21` bio/sources delimited: biojava-core declared but unused; remove
- `im-ee7.22` plugin: fold copyMineProperties into processResources (needs DBModelUtils.mineProperties() change)
- `im-ee7.23` D3 follow-up: confirm bio/sources POM scope change (323 deps compile->runtime from implementation in batch I) is intended for deployers; document in UPGRADING-build.md
- `im-ee7.24` intermine bio/model jar ships the test intermine.properties (contains DB credentials) - exclude from jar (pre-existing, seen in batch B listings)
- `im-ee7.25` B5 input: deployer changes seen in flymine smoke on 6.9.4/7.6: convert compile lines, drop maven plugin and jcenter(), delete stopExecutionIfEmpty(); webapp compile needs full data-source set
- `im-ee7.26` R7 checkstyle bump: 7.8.1 -> 9.3 (Gradle 8.14 default) or 10.x; migrate config (allowUndeclaredRTE removed, JavadocMethod options), then DELETE config/gradle/checkstyle-classpath.gradle (100-line classloader workaround; flagged for Gos as convoluted/temporary)
- `im-ee7.27` intermine: sourcesJar in objectstore and pathquery reads antlr-generated sources without depending on generateGrammarSource (the only 2 remaining 8.x deprecations on 7.6.6); check whether 8.14 wires it
- `im-ee7.28` testmine :webapp:war alone fails in mergeProperties (needs dbmodel copyMineProperties output, no task dependency; setup.sh hides it by running loadsadata first); bio/sources, postprocess, postprocess-test copyMineProperties copy into resources output without declared outputs
- `im-ee7.29` B5 deployer list from 7.6.6 flymine smoke: delete stopExecutionIfEmpty(); drop maven plugin; compile->implementation, testCompile->testImplementation; drop jcenter(); remove gretty apply-from and block; regenerate wrapper; JavaExec main= -> mainClass= before 8.0 (flymine webapp/build.gradle:138, humanmine :127)
- `im-ee7.3` B3 Gradle 8.14, remove com.sun.xml.internal property, version catalog
- `im-ee7.30` B3 CATALOG batch: move the 50 module-file coordinates into gradle/libs.versions.toml; resolve conflicts commons-codec 1.15/1.9, oltu client 1.0.1/1.0.0 (intermine/webapp both), jami-core 3.0.0/3.2.12, xmlunit 1.6/1.0; plugin/build.gradle literal 5.1.1 -> catalog; docs/RELEASING.md:50 version note
- `im-ee7.31` intermine/testresources/.gitignore still ignores /src/test/java/ (nothing writes there since generateTestModel moved to build/generated)
- `im-ee7.32` plugin addStrutsConfig hard-codes build/resources/main instead of the source set's resources dir (pre-existing; covered by the planned Sync rewrite of war composition)
- `im-ee7.33` intermine: move org.intermine:* imVersion coordinates into the version catalog (after 8.14 flip)
- `im-ee7.34` RELEASE BLOCKER check: does the 5.1.1 candidate plugin (release/5.1.1-candidate, built on Gradle 6.9.4) run in a Gradle 4.9 mine? G1 found the 7.6.6-built plugin fails on 4.9 (NoClassDefFoundError groovy/ant/AntBuilder). If 6.9.4-built also fails, 5.1.1 must document 'mine on Gradle 6.9.4' and UPGRADING-build.md must drop the 4.9 claim
- `im-ee7.35` intermine-webapp war built by the 7.6.6 toolchain carries two versions of jackson (2.18.12 + 2.7.5), commons-lang3, ant, javax.inject, jcl-over-slf4j (diff in repos/.sandbox-disk/rdfc2im/logs_ut/war-listing-diff-5.0.8-vs-5.1.1.txt); fix dependency metadata (resolutionStrategy / exclusions) before 6.0.0
- `im-ee7.36` plugin: Ant task logging lost under Gradle 7 (log4j:WARN No appenders, 210 lines in integrate); plugin's log4j 1/reload4j config for the isolated AntBuilder
- `im-ee7.37` plugin addStrutsConfig uses outputs of copyMineProperties and copyWebappContent without declaring dependencies (Gradle 7 warns, Gradle 8 errors); seen in the G1 humanmine build
- `im-ee7.38` docs/UPGRADING-build.md: 5.1.1 verified on a Gradle 4.9 mine (configure + task start) and on 6.9.4; step 4 gretty: 'repoint apply-from script to mavenCentral()' as alternative to removal (gretty 2.0.0 is on Central); release note wording in im-ee7.34 close reason
- `im-ee7.39` 6.0.0 deployer guide + plugin: with the new copyMineProperties pattern intermine.properties (DB credentials) lands in the mine's dbmodel jar; add jar { exclude 'intermine.properties' } to the guide and consider doing it in the plugin
- `im-ee7.4` B4 JDK 17 build and test run; JDK 21 verification
- `im-ee7.40` intermine: buildscript blocks can read the catalog on 8.14 -> move plugin (imVersion) and cargo coordinates into gradle/libs.versions.toml; testmine webapp does not apply the webapp plugin so addStrutsConfig is only covered by deployer smokes (add a plugin test or a testmine variant)
- `im-ee7.41` intermine plugin/testmine: Copy tasks that unwar intermine-webapp into explodedWebApp do not clear the target, so stale jars survive until clean; make it a Sync task
- `im-ee7.42` mine template / deployer guide: drop commons-logging from the mine dbmodel and rely on jcl-over-slf4j (both provide org.apache.commons.logging in the war today; comment in testmine/dbmodel/build.gradle)
- `im-ee7.43` intermine: remove the com.sun.xml.internal property from the .in templates (harmless on 17/21 but obsolete); replace 534 boxed-type constructor calls (new Integer(...)) marked for removal
- `im-ee7.44` testmine Cargo writes Tomcat config to /tmp/cargo (shared path, outside task homes); point it into the build dir
- `im-ee7.45` intermine checkstyle 9.3: @throws-per-checked-exception enforcement lost (needs classpath); decide whether a custom check or javac -Xlint replaces it; bio/sources/build.gradle has two identical checkstyle {} blocks; 26 malformed Javadoc comments suppressed via MissingDeprecated message match (fix the comments and drop the suppression)
- `im-ee7.46` [bug] intermine-webtasks POM declares intermine-webapp as a compile dependency, so every mine's war gets intermine-webapp-<v>.war (12 MB) in WEB-INF/lib; fix the dependency metadata (seen in B5 humanmine/flymine wars)
- `im-ee7.47` plugin: resolve soTermListFilePath and soAdditionFilePath against rootDir (Ant resolves relative paths against the Gradle 8 daemon cwd; deployers must use absolute paths today)
- `im-ee7.48` plugin: mergeProperties resource() should depend on processResources so mines need no copyMineProperties workaround; copyWebappContent empties build/explodedWebApp on a first Gradle 8 run so the war silently lacks bio-webapp content (46 MB vs 68 MB) - move war composition (warWebApp, duplicatesStrategy, filter) into the plugin
- `im-ee7.49` deployer sources: convert intermine/humanmine-bio-sources and intermine/flymine-bio-sources (Gradle 4.9, compile/maven/signing/bintray) to the 6.0 line and publish; needed because a mine's webapp compiles against all sources in project.xml
- `im-ee7.5` B5 Deployer migration: update humanmine/flymine build files; docs/UPGRADING-build.md
- `im-ee7.50` humanmine/flymine forks: simplify webapp/build.gradle per the new plugin war composition (delete warWebApp, copyWebappContent, explodedWebAppDir, propsDir, mergeProperties input block, classpath filter); rebuild the wars to confirm byte-equivalence
- `im-ee7.51` plugin: add Gradle TestKit tests for unwarBioWebApp, mergeProperties, createSoModel and the war composition (plugin has no src/test); check bio/webapp's own unwarIMWebApp Copy for the stale-directory problem
- `im-ee7.52` UPGRADING-build.md: a mine's dbmodel build must add commons-lang3 (InterMine code now imports lang3) and keep commons-lang 2.6 for the vendored torque at build time; or have the plugin add both (im-jqz.20 follow-up)
- `im-ee7.53` deployer re-verification on the new plugin: humanmine/flymine forks simplified per the war composition change, rebuilt (buildDB + war) against maint-2026 45c10e48ee; lang3 transitivity checked; UPGRADING-build.md updated (covers im-ee7.50, im-ee7.52)
- `im-ee7.54` plugin: warn when the mine war contains two versions of one library (foo-1.0.jar next to foo-1.1.jar); EXCLUDE only collapses identical file names. Also apply the ant:ant exclusion to testmine/webapp's own war task
- `im-ee7.56` plugin/build follow-ups from im-ee7.6: runAcceptanceTests and generateUpdateTriggers still write into build/resources/main (ends up in dbmodel jar and war); testmine/dbmodel has the same build/tmp temp-dir problem; remove bio-model's 2017 test default.intermine.properties from src/main/resources; bio/core jar exclude genomic_model.xml now redundant; testresources buildDB dependsOn compileTestJava -> inputs.files; integrate tasks should declare generateKeys output as input
- `im-ee7.57` docs/UPGRADING-build.md 6.0.0: deployer-visible effects of the plugin task wiring (950dfc7858): merged model in dbmodel/build/im/mergeModels (repoint any doLast on mergeModels), run clean once after upgrading, dbmodel.jar no longer carries default.intermine.properties/so.obo/keys, generateKeys output preferred over a same-named mine resource, bio-model jar carries its own default.intermine.properties; re-run buildDB+war on the humanmine/flymine forks
- `im-ee7.58` intermine cleanup: intermine/resources/log4j2.properties is dead (log4j 2 excluded everywhere); testmine/webapp summariseTestObjectStore uses Gradle's own ant and still prints 3 'No appenders' lines (needs the antLogging dir + log4j.ignoreTCL); consider log4j.logger.org.intermine.sql=WARN to quieten buildDB's 'Dropping table' lines
- `im-ee7.6` intermine plugin: tasks without declared outputs rerun every build (bio/sources install ~100 s with no changes)
- `im-ee7.60` flymine-bio-sources: 2 tests fail on stale test data (FlybaseAllelesConverterTest 7-column input vs converter needing 10; MirandaConverterTest expects scoreType the handler never sets) - fix and drop ignoreFailures; humanmine-bio-sources: DepmapSampleInfoConverterTest rewrites its items.xml in the source tree, signor source not in settings.gradle since 2019; both CIs need maint-2026 artefacts on Central or mavenLocal
- `im-ee7.61` plugin: a mine's createSoModel does not get the build directory on its Ant classpath, so a mine's own log4j.properties is ignored there and 'No appenders' returns (buildDB honours it); also UPGRADING says mergeModels runs only when dbmodel/build has no model, the real condition is dbmodel/build/gen missing
- `im-ee7.62` CI: config/ci/run.sh and install_intermine.py never run the plugin's TestKit tests; add a 'plugin test' job/step (JDK 8 and 17); extend coverage to mergeModels, generateModel, generateKeys, the integrate/postprocess/bio-source plugins (need fake ModelOutputTask/MergeSourceModelsTask stand-ins); note the relative-SO-path test only catches regressions on JDK 17
- `im-ee7.63` intermine build: implementation dependencies the comments call 'never compiled against' (bio, bio/core, bio/sources) could become runtimeOnly with identical POMs but narrower compile classpaths; publishing.gradle header still says 'Needs Gradle 6.0 or later' (harmless)
- `im-ee7.65` humanmine/flymine forks: configs name classes gone from intermine/bio (flymine Cytoscape*Action in struts-config-model.xml; humanmine GWASEnrichmentLdr/GWASEnrichmentURLQuery/HomologueURLQuery in webconfig-model.xml, GenomicRegionSequenceExportServlet in web-model.xml) - run docs/tools/classrefs.py on the forks and fix; intermine leftovers: duplicate jbrowse commandrunner line in bio.web.properties, os.unittest-client alias with a missing class
- `im-ee7.66` intermine leftovers from classrefs: bio/webapp bio.web.properties:24 duplicate webservice.jbrowse.commandrunner.genomic line naming a non-existent jbrowse.testmodel.Engine (next line overrides); default.intermine.test.properties os.unittest-client alias with missing class org.intermine.objectstore.webservice.ObjectStoreClient; humanmine web.properties header/blog/tour links still point at flymine.org (stale copy-paste, host status unknown)
- `im-ee7.67` intermine: install_intermine.py should substitute imVersion/bioVersion into the six .in templates from gradle/libs.versions.toml so a release bumps one place (plugin already reads the catalog, im-89g.13); the XMLOutputFactory property in intermine/gradle.properties.in is still needed by five api binding tests (empty marshalled XML without it): find out why (Woodstox from solrj?) before removing
- `im-ee7.68` intermine: document the 17 checked exceptions javac -Xdoclint:missing reports (16 intermine, 1 bio), then add a CI step that fails on new ones (measurement and recipe in docs/BUILDING.md, im-ee7.45); cargoStartLocal smoke: confirm a request is served (curl got HTTP 000 in the sandbox smoke)
- `im-ee7.7` intermine: regenerate the seven gradlew scripts and wrapper jars for 6.9.4 (S1-wrap)
- `im-ee7.70` fork CIs (humanmine-/flymine-bio-sources) fail with 'Could not find any version that matches org.intermine:plugin:6.0.+' until 6.0.0 is on Central: make the workflow self-sufficient by cloning gmicklem/intermine maint-2026 and running config/lib/install_intermine.py (JDK 17) before the fork build (like the BlueGenes nightly builds the demo mine); drop that step after the 6.0.0 release; bump actions/checkout@v2 -> v4
- `im-ee7.8` intermine: test-only files leak into bio-source/postprocess jars depending on task order (inventory row 18)
- `im-ee7.9` intermine: flaky IntegrationWriterDataTrackingImplTest (setUp IllegalArgumentException cascades to 17 failures) under concurrent gates

**im-jqz Epic C: intermine Tier 1 dependency upgrades and removals**

- `im-jqz.1` C1 Postgres JDBC 42.7.x + HikariCP
- `im-jqz.11` intermine: remove jersey-media-json-jackson + Jersey client (inventory R13) and the jackson-jaxrs-json-provider line
- `im-jqz.12` sandbox: Postgres max_connections=100 nearly exhausted by one gate (94-100); raise to 400 at next quiet moment and/or cap test pools
- `im-jqz.13` intermine: pathquery and model rely on org.json via jsonassert transitively; declare org.json directly, then move jsonassert to testCompile in webapp
- `im-jqz.15` intermine: objenesis redundant with easymock; remove
- `im-jqz.16` intermine: xalan removal verified only by unit tests; confirm XSLT paths in the running webapp on the testbed (G)
- `im-jqz.17` intermine DataTracker: 'broken' flag never reset and not volatile; a failed background write makes the tracker permanently unusable with a message-less IllegalArgumentException
- `im-jqz.18` intermine DataTrackingTest.testWrongOrderBug leaks a DataTracker thread and two connections (dt2 never closed)
- `im-jqz.19` bio/sources/psi-complexes now mixes jami-core 3.2.12 with jami-commons/mitab/xml 3.0.0 (catalog conflict resolution); verify at run time with a PSI-MI XML/MITAB load, or move the three to 3.2.12 (C5 scope)
- `im-jqz.2` C2 Jackson 2.17+, org.json, everit json-schema
- `im-jqz.20` intermine: commons-lang 2.6 -> commons-lang3 migration (268 files import it; mechanical, batchable)
- `im-jqz.21` intermine: commons-beanutils 1.9.4 -> 1.11.0 (clears 3 advisories) after a Struts runtime smoke test of form population (webapp deployed via testbed --intermine-src)
- `im-jqz.22` intermine: runtime smoke test of Struts multipart upload with commons-fileupload 1.6.0 (ListUploadService, upload forms) on the testbed; gate has no webapp deployment
- `im-jqz.24` intermine: commons-logging is a hidden runtime dependency of the vendored torque jar (BuildDbTask); remove with torque or document; declared in objectstore now
- `im-jqz.25` intermine bio/webapp war ships log4j-core/api/slf4j-impl 2.5 (Log4Shell) via biojava-core and biojava-ontology; other modules exclude org.apache.logging.log4j, bio/webapp does not; also a second SLF4J binding
- `im-jqz.26` intermine bio/webapp war stale jars: junit-4.10 + hamcrest-core (via json-simple), spring-test, aopalliance-1.0 next to aopalliance-repackaged; commons-logging + jcl-over-slf4j both in testmine war
- `im-jqz.27` intermine: default.intermine.properties in bio-model and testresources jars (example passwords commented out); check whether bio-model's copy (bio-test defaults) is still needed by consumers
- `im-jqz.28` intermine webapp: registry lookup in SemanticMarkupFormatter has no connect/read timeout (pre-existing); a hung registry can hang the home page; add timeouts (behaviour change, note in release notes)
- `im-jqz.29` intermine: replace cglib 3.1 (needs --add-opens java.base/java.lang on JDK 16+) with ByteBuddy or JDK proxies; changes the Factory type deployers may use; needs vetting entry
- `im-jqz.3` C3 commons-* (collections, io, lang, fileupload, httpclient, codec, math3 duplicate)
- `im-jqz.30` bio-source-psi-complexes: ChEBI lookup uses a SOAP client needing JAX-WS (gone in JDK 11; endpoint returns 500 anyway): switch to ChEBI REST and confine the JAXB jars to psi-complexes (second JAXB copy)
- `im-jqz.31` intermine webapp web.xml: DwrServlet runs with debug=true and allowGetForSafariButMakeForgeryEasier=true (poor production settings; pre-existing); review and turn off; smoke-test a DWR AJAX call on the testbed after the 2.0.11 bump
- `im-jqz.32` intermine: replace torque-3.2-dev, torque-gen-3.2-dev and velocity-1.3 (vendored, patched builds) with own DDL generation; only SqlGenerator (3 classes) and BuildDbTask use them
- `im-jqz.33` psi-complexes: restore small-molecule names via ChEBI REST (SOAP client removed in C6; endpoint was returning 500 anyway); xmlunit 1.6 kept (10 test files, 4 real users) - move the 6 XMLTestCase-only subclasses to TestCase
- `im-jqz.34` intermine: exclude commons-lang 2.6 from solr-solrj 8.11.4 once torque is gone; StringEscapeUtils and StrTokenizer/StrMatcher are deprecated in lang3 (would need commons-text if removed)
- `im-jqz.35` Decision for Gos: commons-lang 2.6 reaches a mine's compile classpath only via solr-solrj's POM (and objectstore for torque); decide whether InterMine should declare it as api for deployer code or drop it with torque (guide currently tells mines to declare it themselves)
- `im-jqz.36` [bug] intermine webservice: DELETE /service/user returns 500 (NullPointerException in InterMineBagBinding.marshal) when the user owns a list without a description; occasional duplicate key on tag_pkey when tagging
- `im-jqz.37` [bug] intermine webapp: list analysis page (bagDetails.do) logs JasperException at widget.jsp line 16 ${fn:split(widget.class,'.')} on the Tomcat 9 image; page returns 200 but list widgets probably do not render. Seen on the 5.1.1 ut stack; widget.jsp identical in 5.0.8 default stack (check there first); likely EL now rejects .class access - replace with widget['class'].name or a getter
- `im-jqz.38` [bug] intermine webapp: template.jsp line 148 ${dec.boolean &amp;&amp; ...} fails EL parsing on the testbed Tomcat, so template.do renders blank (pre-existing; seen on the maint-2026 ut stack 15 Nov). Fix the expression (dec['boolean'] or a getter) and check every JSP for reserved-word property access (.class, .boolean); verify by redeploying the war into the ut stack
- `im-jqz.39` intermine webapp: WEB-INF/tags/abbreviate.tag fails to compile (org.intermine.util.StringUtil cannot be resolved) and is used by objectView.jsp; objectView.jsp, paging.jsp, tablePageLinks.jsp, bio dataSourceShort.jsp are included by no live page and objectView.tile points at a missing controller - fix the import or delete the dead pages
- `im-jqz.4` C4 bcprov, oltu, JOpenId, DWR CVE check (Tier 2 minimal)
- `im-jqz.40` intermine webapp: Tomcat logs 'Cannot deserialize session attribute' / InvalidClassException on TemplateForm.attributeValues when restoring persisted sessions across a redeploy; add serialVersionUID or mark the form non-serializable
- `im-jqz.41` intermine webapp: after im-jqz.39 check for orphans: PageTableQueryMonitor, SessionMethods.startPagedTableCount, getResultsSize in imdwr.js/AjaxServices; results.first/results.pageinfo.* message keys; 8 tags referenced by no JSP in intermine/bio/humanmine/flymine (bagLine, flush, formatColumnName, hspacer, manualLink, sortableDiv, sortablejs, wildcardSqlToUser) - remove or document as mine-facing
- `im-jqz.43` [bug] intermine webapp/api: dead host cdn.intermine.org still referenced (global.web.properties, WebserviceJavaScriptCodeGenerator templates emit script tags for it, bag upload confirm page renders client-side from it, 49 .expected test files); serve imjs etc. from the webapp or cdnjs with SRI, update codegen + expected files, verify the upload confirm page in Chromium on the ut stack
- `im-jqz.44` [bug] intermine webapp: list analysis widget chromosome_distribution_for_gene returns 500 'Cannot create a QueryValue with null' (server-side NPE) on the demo mine; page shows 'Invalid JSON ... got 500'
- `im-jqz.45` intermine webapp: remaining external script hosts after im-jqz.43: https://www.google.com/jsapi (head.js.all.L) and the vendored imjs/im-tables files' json3 IE7 fallback naming cdn.intermine.org (overridden at runtime); a pasted codegen snippet still pulls icon fonts from netdna.bootstrapcdn.com (CORS errors, table works). Decide: drop jsapi, patch the fallback, host fonts
- `im-jqz.46` [bug] intermine webapp: global.web.properties branding.images.logo defaults to https://cdn.rawgit.com/... (rawgit is dead; the ut mine shows the same line) - ship the logo in the webapp (images/) and default to it; same on release/5.1.1-candidate
- `im-jqz.47` intermine webapp: remove the last third-party script (gstatic charts loader on bagDetails.do): list-widgets 2.1.4 needs google.visualization (ColumnChart/BarChart/PieChart/arrayToDataTable/events + google.load) - write a local shim or build a newer list-widgets; also drop unused js/intermine.api.js and js/widgets/spell-histogram.js; check metabolicmine.org and esyn.org references (sandbox 403), footer 'mobile apps' wording
- `im-jqz.49` intermine webapp: remaining orphans from the im-jqz.41 sweeps (scripts in planning reference/webapp-sweeps/): 288 message keys without literal use, publications-displayer.js and mouse-phenotype-dendrogram.js unreferenced, AjaxServices.getSingleUseKey without callers, tiles viewInvitation/reportBags/galaxy/bagTagSelect/linkPopUp/bagView with missing JSP or action, bio actions initAttributeLinks/initOtherMinesLink unchecked; add classrefs.py to the release checklist
- `im-jqz.5` C5 Jena 4.x, solrj latest 8.x, Lucene 3 stance
- `im-jqz.50` intermine objectstore: ObjectStoreInterMineImpl.getSerialWithConnection is not thread-safe on a multi-connection ObjectStore (resets sequenceOffset before updating sequenceBase); two concurrent uploads of the same list name give 500 BagDoesNotExistException 'Attempting to rename l0_temp'
- `im-jqz.51` [bug] bio/sources/psi-complexes: the converter test is vacuous - swr1_yeast-1.xml yields a Complex with no participants/identifiers/names (jami onInteractionWithoutParticipants) under every jami version tried, so only Complex/DataSet/DataSource/Ontology items are produced and assertEquals(4) passes; find why participantList is not read and whether production complexes lose participants
- `im-jqz.52` intermine webapp dwr.xml hardening: remove the java.util.Date 'JDate' new-creator and the exception converter that sends stack traces to clients ('disable in production'); gate-intermine.sh should run testmine build -x test; 5.1.1 candidate: cherry-pick the web.xml DWR values (f034052342)
- `im-jqz.53` [bug] intermine search: SolrKeywordSearchHandler (~line 303) builds facet filters as field:value without quoting, so a facet value with a space (organism.shortName 'H. sapiens') gives totalHits 0 on the demo mine although the facet counts 64; escaped value works; public HumanMine accepts the unescaped value (different Solr setup?). Fix the quoting; then un-skip bluegenes search_test 'can filter search results by organism'
- `im-jqz.54` bio/sources after im-jqz.51: verify on JDK 17 at runtime that no other bio source needed the removed jaxb-runtime (grep javax.xml.bind users; run their converter tests and one integrate on the testbed); psi-complexes follow-ups: InteractionDetail.allInteractors only has earlier participants, undetermined ranges become Location 0..0, stoichiometry untested, unreachable return in processInteractions
- `im-jqz.55` [bug] intermine userprofile: a saved bag got id 2000001, an id also used by savedtemplatequery rows, so ProfileManager.wrapUserProfile threw ClassCastException and the webapp would not start after a restart (ut stack, bag ore16-list created 16 Nov; renumbered by hand to 2500001). Find how the userprofile ObjectStoreWriter allocated an id already used by another class (serial vs id ranges; related to im-jqz.50 getSerialWithConnection) and make startup tolerate/repair it
- `im-jqz.56` intermine webapp follow-ups from im-jqz.53: KeywordSearchResultsController.getFacetValues HTML-escapes facet values so '&' or quote values do not match; GWAS.firstAuthor NullPointerException when rendering search results on a model without the field; bluegenes search_test organism click-through stays it.skip until the nightly's demo mine is built from InterMine with the fix (it uses published 5.0.8 artefacts)
- `im-jqz.57` [bug] intermine api: two concurrent uploads of the same list name give 500 BagDoesNotExistException 'Attempting to rename l0_temp' (seen in the im-jqz.36 stress run); make temp-bag naming/rename per request or lock per user+name
- `im-jqz.58` [bug] intermine webapp RDF/XML output returns 500 for GOTerm, Pathway and Gene with proteins/pathways: Jena BaseXMLWriter.checkURI BadURIException on ontology-term namespaces like obo:SO:0000704; N-Triples works for the same data (seen on the ut mine, pre-existing)
- `im-jqz.6` C6 JUnit 4.13.2, xmlunit, mockobjects/easymock cleanup, vendored jars -> Maven artefacts
- `im-jqz.60` intermine webapp: historyBagView.js calls AjaxServices.filterByTag and autocompleter.js calls AjaxServices.getContent, neither exists in AjaxServices.java (already broken); remove or repair; UPGRADING-build.md: mines whose own JS calls an AjaxServices method outside dwr.xml's include list must add it
- `im-jqz.62` intermine webapp follow-ups from im-jqz.29: report pages for objects of more than one class fail with 'No simple class for Broke,CEO' (ReportObject.java:126, pre-existing); loadQuery.do?method=xml NPE in ForwardParameters.forward on testmine; loading testmodel_data.xml without LANG=C.UTF-8 fails on SimpleObject; Byte Buddy 1.18.17 bump when convenient
- `im-jqz.63` humanmine-bio-sources: tests rewrite the tracked file depmap-sample-info/depmap-sample-info-items.xml (left out of c297687); point the test output elsewhere. intermine-objectstore: commons-logging is implementation only for the bundled torque jar; move it to the confined torque classpath too (im-jqz.24)
- `im-jqz.64` intermine follow-ups from im-jqz.56 batch: LoadQueryAction.xml NPE when the query parameter is missing; String.getBytes() with platform charset in PrecomputedTableManager, PasswordHasher, IqlQueryParser; MetabolicGeneSummaryDisplayer errors on models without Gene.atlasExpression (demo mine) - guard by model check
- `im-jqz.66` follow-ups from im-jqz.16 batch: GFF3Converter dropped scoreType for every source in May 2021 (miRanda handler restored it in flymine-bio-sources d0fca59); check other GFF-based sources that relied on it; signor Protein items carry only primaryAccession (no organism); both bio-source forks declare xmlunit without users
- `im-jqz.67` intermine follow-ups: document the 46 @throws in bio-source-chado-db and drop its checkThrowsDocs exclusion; sql/query/Query.java has three getBytes() calls on the platform charset; gate-intermine.sh should run checkThrowsDocs; flymine-bio-sources MirandaGFF3RecordHandler can drop its own scoreType lines once on 6.0.0 (GFF3Converter sets it)
- `im-jqz.68` flymine-bio-sources: MirandaGFF3RecordHandler can drop its own scoreType lines once the fork builds against 6.0.0 (GFF3Converter sets scoreType since 9e42ee37df)
- `im-jqz.7` C7 Weak-dependency removals from the usage census
- `im-jqz.8` intermine: flaky testBatchesCache in FlatMode/WithNotXml ObjectStoreInterMineImplTest (test-order dependent result cache)
- `im-jqz.9` intermine: ant 1.7.0 -> 1.10.x (3 advisories); testmine build not covered by gate

**im-ore Epic G: Whole-system testbed**

- `im-ore.1` G1 rdfc2im --intermine-src: consume local org.intermine artefacts and war
- `im-ore.10` rdfc2im demo mine data: Organism.name/shortName null (no organism facet); each pathway in two data sets so enrichment rows duplicate and the widget filter matches nothing; no GO enrichment widget; no Location/Sequence objects (23 Cypress skips)
- `im-ore.11` testbed: mine-tests venv at /home/agent/venvs/mine-tests (pytest, playwright, lxml, pyyaml); make test-live needs PY=<venv>/bin/python (system python lacks lxml) - document in rdfc2im BUILD.md/Makefile default; test lists smoke511* left in the ut mine
- `im-ore.14` rdfc2im full-build.sh --intermine-src on maint-2026: build_reactome_source expects bio/sources/reactome/libs (antlr caching jar now in intermine/libs); _upgrade_mine_build must apply the 6.0 fork conversion of humanmine webapp/build.gradle (plugin composes the war) or webapp war fails Gradle 8 validation. Hand-fixed in trial_home_ut by im-jqz.21; make permanent in the im-ore.1 worktree and rerun the ut stack from maint-2026
- `im-ore.15` rdfc2im --intermine-src: when the InterMine catalog moves to 6.0.0 check _pin_intermine_version still lines up with the humanmine fork's gradle.properties (both say 5.1.1 today, log reads 'InterMine 5.1.1, 6.0 line'); HUMANMINE_60_URL needs network on first run (document local-clone override)
- `im-ore.16` rdfc2im: the demo mine's Organism (taxon 9606) has a null name - the loader/items should set name 'Homo sapiens' (and shortName/genus/species); it also blanks widget titles and filter dropdowns
- `im-ore.17` [bug] rdfc2im 49ebe66: --use-cached-data now implies RDFC2IM_OFFLINE=1, so fetch_inputs refuses to clone the upstream repos on a fresh checkout ('OFFLINE=1 and no clone in/.upstream/rdf-config - run once without --use-cached-data'); the nightly CI (fresh runner, network available) fails. Separate the modes: --use-cached-data restores cache groups and still clones/pulls when a clone is missing; a new --offline flag (or explicit RDFC2IM_OFFLINE=1) enforces no network
- `im-ore.19` mine-tests tests/service/test_frontend.py test_no_internal_hostnames_leak: add 'mine' to both host regexes (lines 84, 86), check /service/branding too, update the docstring; run against the ut stack
- `im-ore.2` G2 mine-tests fixtures for the local demo mine (mines.toml local)
- `im-ore.20` testbed: rebuild the DEFAULT rdfc2im stack (8090/5000) from rdfc2im 31eeae9 so local Cypress runs see the corrected demo data (the maint-2026 specs now expect it; 5 tests fail against the stale stack); do it when no worker is using the default stack
- `im-ore.21` [bug] rdfc2im testbed: both stacks stage the webapp into the same worktree dir trial/artifacts/humanmine (bind-mounted into rdfc2im-mine AND rdfc2im-ut-mine), so the default-stack rebuild (07:36Z) replaced the ut stack's maint-2026 webapp with the 5.0.8 one (webapp.baseurl localhost:8090 -> every query 500 on :18090). Stage per stack (trial/artifacts-<stack>/ or under TRIAL_HOME), then rebuild the ut stack from maint-2026
- `im-ore.22` rdfc2im demo mine: a template references GWAS.firstAuthor, a field the model lacks (101 PathException errors in the ut mine log); fix or drop the template in curation/demo_public_templates.sql; also note mines must rebuild bio/model to drop blank class terms from /service/model (im-jqz.58)
- `im-ore.23` testbed: ut stack rebuilt from 6.0.0 (5351d0c301, done 18:15Z; full-build.sh 22c57ae uses the humanmine-bio-sources fork on the 6.0 line) and default stack rebuilt from release/5.1.1-candidate b9355b129e for side-by-side testing (worker running)
- `im-ore.3` rdfc2im: make --use-cached-data fully offline (enable gene-symbol lookup cache by default, save on fetch runs, unit test); branch maint/im-rkn.5-testbed-baseline has the opt-in version (4cc0b44)
- `im-ore.4` rdfc2im: pass -Duser.home/GRADLE_USER_HOME explicitly (JDK 8 ignores $HOME, so a private ~/.gradle is silently bypassed); bind-mount data dirs in trial/docker-compose.yml via env vars
- `im-ore.5` mine-tests: add a 'local' mine entry; skip JBrowse/location tests when the mine has no locations; configurable template threshold; separate service and BlueGenes URLs; browser executable-path option
- `im-ore.6` G1 prerequisites for --intermine-src (from A5 baseline): override imVersion/bioVersion 5.0.+ in the humanmine checkout; reactome source hard-codes 5.0.8; artefacts via private maven repo (-Dmaven.repo.local), not shared ~/.m2; UPSTREAM_CACHE/intermine -> our worktree; wrapper newer than 4.9
- `im-ore.7` rdfc2im follow-ups from G1: per-stack data dir instead of shared /micklem/data; PGDATA_DIR/SOLR_DATA_DIR bind mounts in compose; re-run --intermine-src after the 8.14.6 flip (edits keyed on Gradle major; copyMineProperties change not handled)
- `im-ore.8` rdfc2im/BlueGenes stack: /favicon.ico redirects to http://mine:8090/... (Docker-internal host name leaks); set webapp.baseurl / BlueGenes mine URL to the published host; also make mine-tests test_no_internal_hostnames_leak match 'mine'
- `im-ore.9` mine-tests [mines.local]: gene object id (1000940) changes on every rebuild; resolve id by primaryIdentifier via the web service at test start instead of a fixed id

**im-rkn Epic A: Environment and baseline**

- `im-rkn.1` Install toolchain in sandbox (JDK 8/11/17/21, Postgres 18, lein, chromium, bd)
- `im-rkn.10` sandbox: Cypress Electron needs Xvfb+GTK; worker extracted debs to /home/agent/tools/cypress-sysdeps (source env.sh); proper fix: apt-get install xvfb libgtk-3-0t64 libgbm1 libxss1
- `im-rkn.2` Clone sibling repos imcljs, im-tables-3, bluegenes-tool-store
- `im-rkn.3` Baseline: intermine build and tests on JDK 8 / Gradle 4.9 / Postgres 18
- `im-rkn.4` Baseline: bluegenes cljfmt, kaocha (chromium), prod uberjar
- `im-rkn.5` Baseline: rdfc2im full-build + make test-live + mine-tests against local stack
- `im-rkn.6` Inventory: intermine dependencies, CVEs and usage census
- `im-rkn.7` Inventory: bluegenes + sibling libs dependencies, advisories and usage census
- `im-rkn.8` im-testenv.sh: offer a non-superuser test role mode so the local gate catches PG15+ privilege problems like CI does
- `im-rkn.9` sandbox/human: approve cdn.jsdelivr.net and cdn.intermine.org (BlueGenes loads scripts from them; browser tests against the local stack fail without them); Playwright's own Chromium needs 8 apt libs on Ubuntu 26.04 (PLAYWRIGHT_HOST_PLATFORM_OVERRIDE=ubuntu24.04-arm64)

## 3. Cost per outcome

Mean tokens per run, by model and outcome class:

| Model | Outcome class | Runs | Mean input | Mean cache read | Mean cache write | Mean output |
|---|---|---|---|---|---|---|
| opus | success | 32 | 206 | 17,542,312 | 825,593 | 78,473 |
| opus | failed | 0 | - | - | - | - |
| sonnet | success | 139 | 884 | 7,550,493 | 286,941 | 40,437 |
| sonnet | failed | 0 | - | - | - | - |
| sonnet | other | 2 | 31 | 961,750 | 71,524 | 11,446 |

Five most expensive runs, ranked by output tokens, then cache write tokens (no prices supplied):

| Run | Bead | Model | Output tok | Cache write tok | Outcome |
|---|---|---|---|---|---|
| E1 bluegenes shadow-cljs migration | im-7os.1 | opus | 177,729 | 755,011 | done |
| F4 Cypress specs and fixtures for the demo mine | im-28e.5 | sonnet | 164,627 | 1,742,226 | success |
| build/CI batch (plugin TestKit in CI, catalog version, runtimeOnly, valueOf, log4j2, gate counts) | im-ee7.62 | sonnet | 155,022 | 1,054,991 | success |
| B2 batch P plugin rewrite | im-ee7.2 | opus | 151,358 | 653,034 | done |
| plugin task inputs/outputs batch (ee7.6/13/12/8) | im-ee7.6 | opus | 139,541 | 2,739,044 | success |

## 4. Model usage pattern

**opus** (32 runs)

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
- BlueGenes P1 bugs: ids case, text-input keystrokes, search term, Cypress defaults (`im-7os.31`)
- BlueGenes global fix for dropped keystrokes (reagent input wrapper patch) (`im-7os.35`)
- nightly Cypress in GitHub Actions (demo mine built in the job) (`im-28e.7`)
- plugin task inputs/outputs batch (ee7.6/13/12/8) (`im-ee7.6`)
- userprofile id collision: allocation past existing ids + collision-tolerant profile load (`im-jqz.55`)
- plugin TestKit tests (11) + 2 plugin bugs + unwarIMWebApp Sync (`im-ee7.51`)
- Byte Buddy replaces cglib (6.0 line) (`im-jqz.29`)
- own DDL generator replaces vendored torque/velocity (6.0 line) (`im-jqz.32`)
- COMPLETION.md + HUMAN_TESTING.md guides (`im-bdy`)

**sonnet** (141 runs)

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
- F4 Cypress specs and fixtures for the demo mine (`im-28e.5`)
- B5 deployer migration: humanmine, flymine, UPGRADING-build.md (`im-ee7.5`)
- plugin deployer fixes: webtasks POM, SO paths, war composition (`im-ee7.46`)
- commons-lang 2.6 -> lang3 3.21.0 (268 files) (`im-jqz.20`)
- 5.1.1 candidate backports (6 items, 8 commits) (`im-89g.11`)
- deployer re-check on the final plugin (humanmine, flymine, guide) (`im-ee7.53`)
- siblings imcljs git-sha pins + release order doc (`im-7os.19`)
- Testbed: 5.1.1 candidate ut stack + smoke (first attempt) (`im-89g.12`)
- intermine docs final pass (BUILDING/TESTING/RELEASING/UPGRADING, README, CONTRIBUTING) (`im-bdy.3`)
- Testbed: 5.1.1 candidate ut stack + Struts/DWR smoke (`im-89g.12`)
- 5.1.1 candidate: deployer guide + BUILDING.md backport (`im-89g.14`)
- CI bio-fulldata-test database name alignment (`im-89g.8`)
- commons-beanutils 1.11.0 + Struts form-population smoke (`im-jqz.21`)
- JSP EL reserved-word fixes (widget.jsp, template.jsp, sweep) (`im-jqz.37`)
- 5.1.1 backport of the JSP EL fixes (`im-89g.17`)
- BlueGenes batch: sibling pins, rawgit logo, jQuery CDN, it.only check (`im-7os.34`)
- rdfc2im testbed fixes for maint-2026 (first attempt) (`im-ore.14`)
- rdfc2im testbed: --intermine-src builds a 6.0-line mine (`im-ore.14`)
- dead JSP pages + abbreviate.tag import fix + import sweep (`im-jqz.39`)
- weak-dependency batch (biojava-core; jsonassert and chebiWS already done) (`im-ee7.21`)
- rdfc2im --use-cached-data fully offline (`im-ore.3`)
- mine war duplicates: ant:ant exclusion, oltu facts, EXCLUDE verified (`im-89g.16`)
- webapp: dead cdn.intermine.org removed (vendored assets, codegen) (`im-jqz.43`)
- UPGRADING/RELEASING: EL keyword and dead-CDN deployer warnings (`im-bdy.5`)
- BlueGenes default mine -> HumanMine (+ imcljs examples) (`im-7os.26`)
- 5.1.1 backport: war duplicates (oltu POM, ant:ant exclusion, EXCLUDE) (`im-89g.19`)
- 5.1.1 backport: cdn.intermine.org removal (`im-89g.18`)
- legacy webapp: remaining external hosts + rawgit logo (`im-jqz.45`)
- im-tables: dead cdn.intermine.org removed from export and dev page (`im-7os.42`)
- BlueGenes im-tables pin a36091a (`im-7os.43`)
- widget 500 on null organism filter (GraphWidgetLoader/EnrichmentWidgetImplLdr) (`im-jqz.44`)
- rdfc2im: cached mode clones upstream repos; --offline is the no-network mode (`im-ore.17`)
- 5.1.1 backport: logo + third-party hosts (`im-89g.20`)
- webapp orphan sweep after the JSP deletions (`im-jqz.41`)
- date constraints end to end (mock Date attribute) + on-change fix (`im-7os.22`)
- humanmine-bio-sources + flymine-bio-sources to the 6.0 line (`im-ee7.49`)
- build hygiene batch (Ant logging; ee7.27/28 already fixed) (`im-ee7.36`)
- UPGRADING 6.0.0 plugin-wiring notes + fork verification; docs/tools ElSweep; 5.1.1 webXml step (`im-ee7.57`)
- DELETE /service/user 500 + concurrent tag creation (`im-jqz.36`)
- 5.1.1 candidate: docs port (webXml step, deployer warnings, ElSweep) (`im-89g.21`)
- webapp hardening batch (registry timeouts, DWR settings, ant check, jami) (`im-jqz.28`)
- 5.1.1 backport: api fixes (user delete 500, concurrent tags) (`im-89g.22`)
- rdfc2im demo data: organism names, one data set per pathway, chromosomes, Gradle home, compose dirs (`im-ore.16`)
- im-tables: nil-safe dropdown handlers + static toolbar first click (`im-7os.44`)
- tool-store path containment + package name validation (`im-7os.11`)
- psi-complexes: JAXB runtime shadowed jami-xml binding (`im-jqz.51`)
- BlueGenes sibling pins (im-tables f04d757, tool-store 4e3e896) (`im-7os.46`)
- Cypress specs for the corrected demo data (`im-28e.12`)
- Solr facet filter quoting (+ broken bag-id filter) (`im-jqz.53`)
- BlueGenes dev build: oops 0.7.2 (`im-7os.37`)
- 5.1.1 backport: psi-complexes JAXB fix (`im-89g.23`)
- 5.1.1 backport: Solr facet filter fix (`im-89g.24`)
- 5.1.1 backport: id allocation + collision-tolerant profile load (`im-89g.25`)
- BlueGenes: tool widget requirements; upload organism state (`im-7os.32`)
- C5: Jena 3.17.0 narrowed, solrj slimmed, Lucene 3 stance (`im-jqz.5`)
- rdfc2im stack: service-name leak, per-stack data root, G1 follow-ups (`im-ore.8`)
- im-tables demo configs on HumanMine (`im-28e.8`)
- default rdfc2im stack rebuilt with the corrected data (`im-ore.20`)
- 5.1.1 backport: Jena narrowed + solrj exclusions (`im-89g.26`)
- BlueGenes pins: im-tables 0fc6eba, nightly rdfc2im 31eeae9 (`im-28e.13`)
- dwr.xml hardening + testmine gate step (`im-jqz.52`)
- 5.1.1 backport: DWR web.xml settings + dwr.xml hardening (`im-89g.27`)
- publishing/build audit across the seven builds (`im-ee7.14`)
- tool-store: tarball URL/integrity/size hardening (`im-7os.47`)
- local charts shim for list-widgets (last third-party script gone) (`im-jqz.47`)
- gate/testenv: per-task Gradle daemon registry + PG role modes (`im-8dd.7`)
- webapp orphan sweep, second pass (`im-jqz.49`)
- rdfc2im: per-stack artifacts staging + ut rebuild (`im-ore.21`)
- RDF/XML 500 on ontology terms (`im-jqz.58`)
- bluegenes follow-up batch (5 items) (`im-7os.50`)
- 5.1.1 backport: RDF export fix (`im-89g.28`)
- commons-lang 2 off mine classpaths; forks to lang3 (`im-jqz.35`)
- list save 400 (imcljs query XML) + im-tables default names (`im-7os.51`)
- humanmine/flymine dangling class references (`im-ee7.65`)
- reagent 2.0.1 keystroke experiment (`im-7os.53`)
- sibling pin bumps (imcljs d96a3eb, im-tables 0d6cbed) (`im-7os.54`)
- webapp/api bug batch (facets, concurrent uploads, dead JS, sessions, multi-class reports) (`im-jqz.56`)
- build/CI batch (plugin TestKit in CI, catalog version, runtimeOnly, valueOf, log4j2, gate counts) (`im-ee7.62`)
- bluegenes batch 2 (regions debounce, vega params, code-export spec, lib bumps) (`im-7os.52`)
- im-tables batch (dispatch bug, cljs-time, codegen languages, Date values) (`im-7os.55`)
- intermine small cleanups batch (9 items) (`im-jqz.17`)
- tool-store: cookie policy, config.json reference, transit-cljs check (`im-7os.12`)
- 5.1.1 backports (webapp bugs, DataTracker, DWR test) (`im-89g.29`)
- version catalog consolidation + StAX flush root cause (`im-ee7.67`)
- plugin batch (war duplicate check, resources dir, task outputs, Cargo dir, checkstyle leftovers) (`im-ee7.54`)
- bio batch (XSLT audit, JAXB/psi-complexes, ChEBI REST, fork tests) (`im-jqz.16`)
- bluegenes batch 3 (transit-js, Date values + pins, upload organism race) (`im-7os.58`)
- reagent 2 readiness (im-tables refs + unsafe-html; bluegenes unsafe-html) (`im-7os.57`)
- intermine follow-ups batch (NPE, charsets, doclint CI, scoreType, docs) (`im-jqz.64`)
- 6.0.0 version bump + fork pins (`im-89g.10`)
- ut demo stack rebuilt from 6.0.0 (5351d0c301) (`im-ore.23`)
- intermine.org hosting investigation (http, heroku) (`im-bdy`)
- chado-db @throws (46), gate checkThrowsDocs step, sql Query UTF-8 (`im-jqz.67`)
- default demo stack rebuilt from 5.1.1 candidate (b9355b129e) (`im-ore.23`)
- bluegenes im-tables pin f780276 (`im-7os.61`)
- new BlueGenes served on 15001 (6.0.0) and 5001 (5.1.1) (`im-bdy`)
- release notes (5.1.1, 6.0.0), bluegenes CHANGELOG 1.5.0, fork CI Python 3 (`im-89g.30`)
- fork CIs build intermine maint-2026 in the job (`im-ee7.70`)
- intermine docs consistency sweep (`im-bdy.11`)
- Central bundle rehearsal, both lines (`im-89g.32`)
- 5.1.1 doc fixes + flymine miRanda scoreType simplification (`im-89g.31`)
- reagent master (PR 680) keystroke measurement (`im-7os.62`)

## 5. Notes

Approximate pricing: not applied. Token totals are shown without prices; pass `--prices prices.json` (model name to per-million-token prices for input, cache_read, cache_write, output) to add an approximate cost.

Token counts are de-duplicated per API message id. Runs that resume an earlier agent are charged for the increase over the previous row of that agent (same started_utc).

## 6. Open items / blockers

| Issue | Title | Status | Why listed |
|---|---|---|---|
| im-7os.33 | HUMAN (Gos): release imcljs 1.7.0, im-tables 0.16.0, tool-store 0.3.0 to Clojars in that order per intermine-planning/docs/RELEASING-siblings.md (CLOJARS_USERNAME/CLOJARS_PASSWORD deploy token; tool-store via lein deploy, move its project.clj to imcljs 1.7.0 first); then switch bluegenes deps.edn back to :mvn/version and drop the CI git-dep workaround (ci.yml 179-188, build.clj 206-228) | open | title mentions human |
| im-89g.7 | D3 follow-up: test real Central Portal upload (central.sonatype.com blocked in sandbox); human: Portal account, org.intermine namespace, GPG key, run docs/RELEASING.md for 5.1.1 | open | label human, title mentions blocked, title mentions human |
| im-bdy.10 | intermine.org hosting (docs/INTERMINE_ORG_HOSTING.md): HUMAN: repoint DNS to GitHub Pages' current IPs, re-add custom domain + Enforce HTTPS, baseurl https in intermine-homepage-2017 and im-docs; then AGENTS: switch hard-coded http://intermine.org and http://registry.intermine.org references in bluegenes (home/footer/querybuilder/webproperties), intermine webapp (footer.jsp, global.web.properties:66, SemanticMarkupFormatter:289), vendored imjs/imtables, codegen fixtures to https | open | title mentions human |
| im-jqz.61 | HUMAN: check whether metabolicmine.org and esyn.org are alive (sandbox proxy needs approval): references in js/widgets/mouse-phenotype-dendrogram.js, bio genomicRegionSearch* and esynDisplayer/esynListDisplayer.jsp (plain http); remove if dead. Also 5.1.1 backport of the charts shim (one js file, one properties line, README) | open | title mentions human |

`bd status` also counts 0 issue(s) as blocked by unfinished dependencies (see `bd blocked`).
