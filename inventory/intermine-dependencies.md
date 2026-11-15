# InterMine Java back end: dependency inventory

Repo: `/Users/gos/claude_projects/update_intermine_planning/repos/intermine`, branch `dev`, commit `77cf7068`. Snapshot date 2026-11-15.
Companion file: `intermine-dependency-usage.md` (usage census, removal candidates, vendored jars).

## 1. Method and caveats

- Source of truth: every `dependencies {}`/`buildscript {}` line in the 95 `build.gradle` files (7 Gradle builds: `plugin`, `intermine`, `bio`, `bio/sources`, `bio/postprocess`, `bio/postprocess-test`, `testmine`). Parsed with a script, then cross-checked with grep for unparsed forms (string notation, `mergeModel`, `antlr`, `tomcat`, `classpath`). `org.intermine:*` project artefacts are excluded (internal). No Gradle resolution was run (repo is read-only), so transitive data is derived from POMs on Central and is indicative only.
- "Declared version(s)": literal versions in build files. No version catalogue / `ext` version variables exist for third-party libs; each module repeats its own literals, which is the root cause of the drift listed in section 4.
- "Build files": count of distinct `build.gradle` files declaring the coordinate, then representative module dirs. `(S: n modules)` marks a declaration inside a `subprojects {}` block of an aggregator build file, so it applies to n modules without appearing in their own build file (bio: 5, bio/sources: ~45, bio/postprocess: 16, bio/postprocess-test: 8, intermine: 10, testmine: 2).
- "Latest": `<release>` from `https://repo.maven.apache.org/maven2/<group>/<artifact>/maven-metadata.xml` (queried 2026-11-15); where `<release>` is a milestone/alpha, the highest stable version is shown with the pre-release in brackets. Several old artefacts have stale or odd metadata and were corrected by hand after HEAD-checking the files on Central: `javax.servlet:jstl` (metadata tops out at 1.1.2, but 1.2 exists), `antlr:antlr` (2.7.7 exists, metadata lists a date version), `commons-collections` (`<release>` is the legacy `20040616`; real latest is 3.2.2), `stax:stax` (metadata <=1.1.2-dev, 1.2.0 exists), `commons-httpclient` (3.1), `ant:ant` (frozen at 1.6.5, relocated to `org.apache.ant:ant`), `fastutil:fastutil` (frozen, relocated to `it.unimi.dsi:fastutil`). The existence of every declared version's POM on Central was verified by HEAD request (all 200 except the JAMI artefacts and the cargo plugin). "Latest same-major" is the newest stable release with the same first version number as the declared one, i.e. the lowest-risk bump.
- Vulnerabilities: GitHub Advisory Database via `gh api "/advisories?ecosystem=maven&affects=<g>:<a>@<v>&per_page=100"` (authenticated, 5000/h limit; no rate limiting hit). Withdrawn advisories dropped. All declared (group, artifact, version) pairs were queried (about 90 queries), plus the highest transitive version of ~100 transitive artefacts resolved from POMs.
- Lookups that failed: the 7 `psidev.psi.mi.jami*` artefacts return 404 on Central (they come from the EBI repo configured as `intermine.maven.ebi`), and `com.bmuschko:gradle-cargo-plugin:2.9.0` is not on Central (2.8.0 is; 2.9.0 comes from the Gradle plugin portal via `intermine.maven.plugins`). No advisory lookup failed.
- JDK 8 / Gradle 4.9 constraint: "latest" is often not usable on JDK 8. From upstream release notes (not verified here): Jena 4.x needs Java 11, 5.x Java 17, 6.x Java 21; Solr 9 needs Java 11, 10 needs Java 21; Lucene 9 needs Java 11, 10 needs Java 21; HikariCP 5+ needs Java 11; Jersey 3+/4+ moves to `jakarta.*`. The "same-major" column is the JDK 8 safe path. Gradle 4.9 itself is far outside the Java 21 toolchain support.

## 2. Summary

| Metric | Count |
|---|---|
| Distinct third-party coordinates declared (group:artifact) | 79 (77 libraries + `gradle-cargo-plugin` build plugin + `tomcat` test container zip) |
| Tier 1 | 63 (38 upgrade + 25 flagged "remove") |
| Tier 2 | 16 (11 patch-only + 5 flagged "remove") |
| `build.gradle` files that declare third-party coordinates | 24 of 95 (most of the ~45 `bio/sources/*` and 16 `bio/postprocess/*` module builds only depend on `org.intermine:*` and inherit third-party libs from their aggregator's `subprojects {}`) |
| Direct coordinates with >=1 known advisory | 21 |
| Distinct advisories on directly declared versions (GHSA) | 153: 31 critical, 84 high, 35 medium, 3 low (131 if the testmine-only Tomcat container zip is excluded) |
| Distinct advisories on selected transitive libs (indicative) | 51: 8 critical, 25 high, 15 medium, 3 low (section 6) |
| Coordinates with no fix available upstream | struts-core/extras/tiles (EOL Struts 1), commons-httpclient 3.0, commons-lang 2.6 |
| Vendored jars (not Gradle coordinates) | 18 jar files, 11 distinct artefacts, plus 7 `gradle-wrapper.jar` (usage file section 4) |

## 3. Dependency table

Tier: 1 = upgrade/remove now (used by core, not slated for retirement); 1 (remove) / 2 (remove) = also a removal or JDK-replacement candidate (usage file section 3; some conditional); 2 = Struts 1, DWR, Lucene 3, JSP/webapp-only legacy: minimal CVE patch only. CVE column = distinct advisories across all declared versions (crit/high/medi/low).

| Coordinate | Declared | Config(s) | Build files (count: representative) | Latest on Central | Latest same-major | Advisories | Tier |
|---|---|---|---|---|---|---|---|
| ant:ant | 1.6.5 | compile | 2: `bio (S: 5 modules)`, `testmine (S: 2 modules)` | 1.6.5 (relocated to org.apache.ant:ant) | 1.6.5 | 0 | 1 |
| antlr:antlr | 2.7.6 | compile | 1: `testmine/dbmodel` | 2.7.7 | 2.7.7 | 0 | 1 |
| au.com.bytecode:opencsv | 2.4 | compile,testCompile | 3: `bio (S: 5 modules)`, `bio/sources (S: ~45 modules)`, `intermine/objectstore` | 2.4 | 2.4 | 0 | 1 |
| cglib:cglib | 3.1 | compile,testCompile | 5: `bio (S: 5 modules)`, `bio/postprocess-test (S: 8 modules)`, `bio/sources (S: ~45 modules)` +2 | 3.3.0 | 3.3.0 | 0 | 1 |
| ch.qos.reload4j:reload4j | 1.2.22 | compile,mergeModel | 9: `bio/postprocess (S: 16 modules)`, `bio/postprocess-test (S: 8 modules)`, `bio/sources (S: ~45 modules)` +6 | 1.2.27 | 1.2.27 | 0 | 1 |
| com.bmuschko:gradle-cargo-plugin | 2.9.0 | classpath | 1: `testmine/webapp` | 2.8.0 | 2.8.0 | 0 | 1 |
| com.fasterxml.jackson.core:jackson-annotations | 2.9.8 | compile | 1: `bio/sources/isa` | 2.23 (newer pre-release: 3.0-rc5) | 2.23 | 0 | 1 |
| com.fasterxml.jackson.core:jackson-core | 2.9.8 | compile | 1: `bio/sources/isa` | 2.23.0 | 2.23.0 | 4 (3 high, 1 medi) | 1 |
| com.fasterxml.jackson.core:jackson-databind | 2.2.3, 2.9.8 | compile | 2: `bio/sources/isa`, `intermine/webapp` | 2.23.0 | 2.23.0 | 70 (20 crit, 43 high, 7 medi) | 1 |
| com.sleepycat:je | 4.0.92 | compile | 1: `bio/sources/update-publications` | 18.3.12 | - | 0 | 1 (remove) |
| com.zaxxer:HikariCP | 3.2.0 | compile | 6: `bio/postprocess (S: 16 modules)`, `bio/postprocess-test (S: 8 modules)`, `bio/sources (S: ~45 modules)` +3 | 7.1.0 | 3.4.5 | 0 | 1 |
| commons-beanutils:commons-beanutils | 1.9.3 | compile | 1: `intermine/objectstore` | 1.11.0 | 1.11.0 | 3 (3 high) | 1 (remove) |
| commons-codec:commons-codec | 1.9, 1.15 | runtime | 2: `intermine/webapp`, `testmine/webapp` | 1.23.0 | 1.23.0 | 0 | 1 (remove) |
| commons-collections:commons-collections | 3.2 | compile,runtime | 7: `bio/postprocess (S: 16 modules)`, `bio/postprocess-test (S: 8 modules)`, `bio/sources (S: ~45 modules)` +4 | 3.2.2 | 3.2.2 | 2 (1 crit, 1 high) | 1 |
| commons-fileupload:commons-fileupload | 1.2.2 | compile,runtime | 2: `intermine/webapp`, `testmine/webapp` | 1.6.0 | 1.6.0 | 6 (1 crit, 5 high) | 2 (remove) |
| commons-httpclient:commons-httpclient | 3.0 | compile,runtime | 2: `intermine/webapp`, `testmine/webapp` | 3.1 | 3.1 | 1 (1 medi) | 1 (remove) |
| commons-io:commons-io | 1.2 | compile,runtime | 8: `bio/postprocess-test (S: 8 modules)`, `bio/sources (S: ~45 modules)`, `bio/core` +5 | 2.22.0 | 1.4 | 1 (1 medi) | 1 (remove) |
| commons-lang:commons-lang | 2.6 | compile,mergeModel,runtime,testCompile | 10: `bio/postprocess (S: 16 modules)`, `bio/postprocess-test (S: 8 modules)`, `bio/sources (S: ~45 modules)` +7 | 2.6 | 2.6 | 1 (1 medi) | 1 |
| commons-logging:commons-logging | 1.3.5 | compile | 4: `bio/postprocess-test (S: 8 modules)`, `bio/sources (S: ~45 modules)`, `bio/core` +1 | 1.4.0 | 1.4.0 | 0 | 1 (remove) |
| fastutil:fastutil | 5.0.9 | runtime | 1: `intermine/webapp` | 5.0.9 (moved to it.unimi.dsi:fastutil) | - | 0 | 1 (remove) |
| jakarta.xml.bind:jakarta.xml.bind-api | 2.3.2 | implementation | 1: `bio/sources (S: ~45 modules)` | 4.0.5 (newer pre-release: 4.1.0-M1) | 2.3.3 | 0 | 1 (remove) |
| javax.annotation:javax.annotation-api | 1.3.2 | implementation | 1: `bio/sources (S: ~45 modules)` | 1.3.2 | 1.3.2 | 0 | 1 (remove) |
| javax.mail:mail | 1.4 | compile | 2: `intermine/webapp`, `testmine/webapp` | 1.4.7 (newer pre-release: 1.5.0-b01) | 1.4.7 | 0 | 1 |
| javax.servlet:javax.servlet-api | 3.1.0 | compile,providedCompile,testCompile | 3: `bio/webapp`, `intermine/webapp`, `testmine/webapp` | 4.0.1 | 3.1.0 | 0 | 1 |
| javax.servlet:jstl | 1.2 | compile | 2: `intermine/webapp`, `testmine/webapp` | 1.2 | 1.2 | 0 | 2 |
| javax.servlet.jsp:javax.servlet.jsp-api | 2.3.1 | providedCompile,runtime | 2: `intermine/webapp`, `testmine/webapp` | 2.3.3 | 2.3.3 | 0 | 2 |
| javax.ws.rs:javax.ws.rs-api | 2.0.1 | compile | 1: `intermine/webapp` | 2.1.1 | 2.1.1 | 0 | 1 (remove) |
| javax.xml.bind:jaxb-api | 2.3.1 | runtime | 1: `intermine/webapp` | 2.3.1 (newer pre-release: 2.4.0-b180830.0359) | 2.3.1 | 0 | 1 (remove) |
| junit:junit | 4.8.2 | testCompile | 5: `bio (S: 5 modules)`, `bio/postprocess (S: 16 modules)`, `bio/postprocess-test (S: 8 modules)` +2 | 4.13.2 | 4.13.2 | 1 (1 medi) | 1 |
| mockobjects:mockobjects-core | 0.09 | compile | 2: `bio/sources (S: ~45 modules)`, `intermine/objectstore` | 0.09 | 0.09 | 0 | 1 (remove) |
| mockobjects:mockobjects-jdk1.3 | 0.09 | compile | 2: `bio/sources (S: ~45 modules)`, `intermine/objectstore` | 0.09 | 0.09 | 0 | 1 (remove) |
| net.iharder:base64 | 2.3.8 | compile | 2: `intermine/objectstore`, `testmine/dbmodel` | 2.3.9 | 2.3.9 | 0 | 1 (remove) |
| org.apache.ant:ant | 1.7.0 | compile | 3: `bio/postprocess (S: 16 modules)`, `bio/sources (S: ~45 modules)`, `intermine (S: 10 modules)` | 1.10.18 | 1.10.18 | 3 (1 high, 2 medi) | 1 |
| org.apache.commons:commons-lang3 | 3.0 | compile | 1: `bio/sources/psi-complexes` | 3.22.0 | 3.22.0 | 1 (1 medi) | 1 (remove) |
| org.apache.commons:commons-math3 | 3.0, 3.2 | compile | 1: `intermine/webapp` | 3.6.1 | 3.6.1 | 0 | 1 (remove) |
| org.apache.jena:apache-jena-libs | 3.16.0 | compile | 2: `bio/postprocess/create-R2RML-mapping`, `intermine/api` | 6.2.0 | 3.17.0 | 0 | 1 |
| org.apache.jena:jena-core | 3.16.0 | compile | 1: `intermine/webapp` | 6.2.0 | 3.17.0 | 1 (1 high) | 1 |
| org.apache.lucene:lucene-analyzers | 3.0.2 | compile,testCompile | 2: `bio (S: 5 modules)`, `testmine/dbmodel` | 3.6.2 | 3.6.2 | 0 | 2 (remove) |
| org.apache.lucene:lucene-core | 3.0.2 | compile | 2: `intermine/api`, `intermine/webapp` | 10.6.0 | 3.6.2 | 0 | 2 |
| org.apache.lucene:lucene-highlighter | 3.0.2 | compile | 1: `intermine/api` | 10.6.0 | 3.6.2 | 0 | 2 |
| org.apache.lucene:lucene-queries | 3.0.2 | compile | 1: `intermine/api` | 10.6.0 | 3.6.2 | 0 | 2 (remove) |
| org.apache.lucene:lucene-snowball | 3.0.2 | compile,runtime | 3: `bio/webapp`, `intermine/api`, `testmine/dbmodel` | 3.0.3 | 3.0.3 | 0 | 2 |
| org.apache.oltu.oauth2:org.apache.oltu.oauth2.client | 1.0.0, 1.0.1 | compile,providedCompile | 1: `intermine/webapp` | 1.0.2 | 1.0.2 | 0 | 1 |
| org.apache.oltu.oauth2:org.apache.oltu.oauth2.common | 1.0.0 | providedCompile | 1: `intermine/webapp` | 1.0.2 | 1.0.2 | 0 | 1 |
| org.apache.solr:solr-solrj | 8.11.4 | compile | 4: `bio/postprocess (S: 16 modules)`, `intermine/api`, `intermine/webapp` +1 | 10.1.0 | 8.11.4 | 0 | 1 |
| org.apache.struts:struts-core | 1.3.10 | compile | 2: `intermine/webapp`, `testmine/webapp` | 1.3.10 | 1.3.10 | 4 (4 high) | 2 |
| org.apache.struts:struts-extras | 1.3.10 | compile | 2: `intermine/webapp`, `testmine/webapp` | 1.3.10 | 1.3.10 | 1 (1 medi) | 2 |
| org.apache.struts:struts-taglib | 1.3.10 | compile | 2: `intermine/webapp`, `testmine/webapp` | 1.3.10 | 1.3.10 | 0 | 2 |
| org.apache.struts:struts-tiles | 1.3.10 | compile,providedCompile | 3: `bio/webapp`, `intermine/webapp`, `testmine/webapp` | 1.3.10 | 1.3.10 | 1 (1 high) | 2 |
| org.apache.taglibs:taglibs-standard | 1.2.5 | compile | 1: `intermine/webapp` | 1.2.5 | 1.2.5 | 0 | 2 (remove) |
| org.apache.tomcat:tomcat | 9.0.115 | tomcat | 1: `testmine/webapp` | 11.0.29 | 9.0.124 | 22 (8 crit, 8 high, 5 medi, 1 low) | 1 |
| org.biojava:biojava-core | 4.2.0 | compile | 3: `bio/sources/delimited`, `bio/sources/fasta`, `bio/webapp` | 7.3.0 | 4.2.12 | 0 | 1 |
| org.biojava:biojava-genome | 4.2.0 | compile | 1: `bio/webapp` | 7.3.0 | 4.2.12 | 0 | 1 (remove) |
| org.biojava:biojava-ontology | 4.2.0 | compile | 1: `bio/webapp` | 7.3.0 | 4.2.12 | 0 | 1 |
| org.bouncycastle:bcprov-jdk15on | 1.50 | providedCompile | 1: `intermine/webapp` | 1.70 | 1.70 | 17 (6 high, 10 medi, 1 low) | 1 |
| org.directwebremoting:dwr | 2.0.1 | compile | 2: `intermine/webapp`, `testmine/webapp` | 3.0.2-RELEASE | 2.0.11-RELEASE | 2 (2 medi) | 2 |
| org.easymock:easymock | 3.2 | testCompile | 1: `intermine/webapp` | 5.7.0 | 3.6 | 0 | 1 |
| org.everit.json:org.everit.json.schema | 1.5.1 | compile | 1: `intermine/webapp` | 1.5.1 | 1.5.1 | 0 | 1 (remove) |
| org.expressme:JOpenId | 1.08 | providedCompile | 1: `intermine/webapp` | 1.08 | 1.08 | 0 | 2 (remove) |
| org.glassfish.jaxb:jaxb-runtime | 2.3.2 | implementation | 1: `bio/sources (S: ~45 modules)` | 4.0.9 | 2.3.9 | 0 | 1 (remove) |
| org.glassfish.jersey.core:jersey-client | 2.25 | compile | 1: `intermine/webapp` | 4.0.3 (newer pre-release: 5.0.0-M1) | 2.48 | 0 | 1 (remove) |
| org.glassfish.jersey.media:jersey-media-json-jackson | 2.25 | compile | 1: `intermine/webapp` | 4.0.3 (newer pre-release: 5.0.0-M1) | 2.48 | 0 | 1 (remove) |
| org.json:json | 20170516 | compile,runtime | 4: `bio/webapp`, `intermine/api`, `intermine/webapp` +1 | 20260814 | - | 3 (2 high, 1 medi) | 1 |
| org.objenesis:objenesis | 2.1 | testCompile | 1: `intermine/webapp` | 3.6 | 2.6 | 0 | 1 |
| org.ow2.asm:asm | 4.2 | compile | 2: `intermine/model`, `intermine/objectstore` | 9.11.1 | 4.2 | 0 | 1 (remove) |
| org.postgresql:postgresql | 42.2.2 | compile | 6: `bio/postprocess (S: 16 modules)`, `bio/postprocess-test (S: 8 modules)`, `bio/sources (S: ~45 modules)` +3 | 42.7.14 | 42.7.14 | 8 (1 crit, 4 high, 2 medi, 1 low) | 1 |
| org.skyscreamer:jsonassert | 1.2.3 | compile | 1: `intermine/model` | 1.5.3 (newer pre-release: 2.0-rc1) | 1.5.3 | 0 | 1 (remove) |
| org.slf4j:slf4j-reload4j | 1.7.36 | compile,mergeModel | 9: `bio/postprocess (S: 16 modules)`, `bio/postprocess-test (S: 8 modules)`, `bio/sources (S: ~45 modules)` +6 | 2.0.20 (newer pre-release: 2.1.0-alpha1) | 1.7.36 | 0 | 1 |
| psidev.psi.mi.jami:jami-commons | 3.0.0 | compile | 1: `bio/sources/psi-complexes` | lookup failed (not on Central) | - | 0 | 1 |
| psidev.psi.mi.jami:jami-core | 3.0.0, 3.2.12 | compile | 2: `bio/sources/psi-complexes`, `bio/webapp` | lookup failed (not on Central) | - | 0 | 1 |
| psidev.psi.mi.jami:jami-interactionviewer-json | 3.2.12 | compile | 1: `bio/webapp` | lookup failed (not on Central) | - | 0 | 1 |
| psidev.psi.mi.jami:jami-mitab | 3.0.0 | compile | 1: `bio/sources/psi-complexes` | lookup failed (not on Central) | - | 0 | 1 |
| psidev.psi.mi.jami:jami-xml | 3.0.0 | compile | 1: `bio/sources/psi-complexes` | lookup failed (not on Central) | - | 0 | 1 |
| psidev.psi.mi.jami.bridges:bridges-core | 3.2.12 | compile | 1: `bio/webapp` | lookup failed (not on Central) | - | 0 | 1 |
| psidev.psi.mi.jami.bridges:jami-ols | 3.2.12 | compile | 1: `bio/webapp` | lookup failed (not on Central) | - | 0 | 1 |
| stax:stax | 1.2.0 | compile,runtime | 2: `intermine/integrate`, `intermine/pathquery` | 1.2.0 | - | 0 | 1 (remove) |
| taglibs:string | 1.1.0 | runtime | 2: `intermine/webapp`, `testmine/webapp` | 1.1.0 | 1.1.0 | 0 | 2 |
| xalan:xalan | 2.7.2 | compile | 1: `intermine/api` | 2.7.3 | 2.7.3 | 1 (1 high) | 1 (remove) |
| xmlunit:xmlunit | 1.0, 1.6 | testCompile | 7: `bio (S: 5 modules)`, `bio/postprocess (S: 16 modules)`, `bio/postprocess-test (S: 8 modules)` +4 | 1.6 | 1.6 | 0 | 1 |

## 4. Inventory findings (declarations, drift, anomalies)

| # | Finding | Evidence |
|---|---|---|
| 1 | Version drift: `jackson-databind` 2.2.3 (webapp) vs 2.9.8 (`bio/sources/isa`); `jackson-core`/`-annotations` 2.9.8 only in isa, so webapp gets jackson-core 2.2.3 via databind. Jena brings 2.10.1 and Jersey 2.8.4 transitively; Gradle conflict resolution picks the highest, so the effective webapp version is likely 2.10.1 (still vulnerable). | `intermine/webapp/build.gradle:42`, `bio/sources/isa/build.gradle:23-25` |
| 2 | Duplicate declarations with different versions in one file: `commons-math3` 3.0 (line 39) and 3.2 (line 54); `oltu.oauth2.client` 1.0.1 (compile, line 41) and 1.0.0 (providedCompile, line 50). | `intermine/webapp/build.gradle` |
| 3 | Two Ant coordinates on the classpath at once: `ant:ant:1.6.5` (`bio/build.gradle:52`, `testmine/build.gradle:61`) and `org.apache.ant:ant:1.7.0` (`intermine/build.gradle:31`, `bio/sources/build.gradle:106`, `bio/postprocess/build.gradle:98`). Same `org.apache.tools.ant` packages; 86 source files use them. | usage file |
| 4 | `commons-codec` 1.15 (intermine webapp) vs 1.9 (testmine webapp); `xmlunit` 1.0 (6 files) vs 1.6 (`intermine/integrate`). | build files |
| 5 | `org.apache.taglibs:taglibs-standard:1.2.5` is a POM-only artefact (parent POM, packaging `pom`, no jar on Central; the jars are `taglibs-standard-impl`/`-spec`). It contributes nothing; JSTL comes from `javax.servlet:jstl:1.2`. | HEAD on `.jar` = 404, `.pom` = 200 |
| 6 | Scope misuse: `jsonassert` (`intermine/model`, `compile`) is only used by 4 webapp tests; `mockobjects-core`/`-jdk1.3` (`compile` in `intermine/objectstore` and the `bio/sources` subprojects) are only used by 3 test files; `opencsv` `testCompile` in `bio` and `bio/sources` duplicates the `compile` in `intermine/objectstore`. All leak into production classpaths and WARs. | usage file |
| 7 | `javax.servlet-api` is `compile` in `intermine/webapp` but `providedCompile` in `bio/webapp`; `commons-io`/`-collections`/`-lang` are `runtime` in webapp although webapp source imports them (compiles only through api's transitive `compile`). | `intermine/webapp/build.gradle:47,57-59` |
| 8 | Declared but with no source import: `xalan`, `stax:stax`, `org.ow2.asm:asm` (cglib 3.1 already pulls asm 4.2), `lucene-queries`, `lucene-analyzers`, `commons-logging`, `javax.xml.bind:jaxb-api`, `jakarta.xml.bind-api`, `jaxb-runtime`, `javax.annotation-api`, `fastutil`, `jersey-media-json-jackson`. Some are runtime-only needs (commons-logging, Jersey implementation, JAXB for JDK 9+); see usage file section 3. | usage file |
| 9 | `HikariCP` is declared with `transitive: false` in 6 places (comment: "conflict with log4j library this JAR needs"). A `configurations.all { exclude group: 'org.apache.logging.log4j' }` exists in only 5 build files (`intermine/build.gradle`, `intermine/objectstore`, `bio/core`, `bio/sources/build.gradle`, `testmine/dbmodel`); `bio/webapp` has none, yet it declares `biojava-core` 4.2.0 whose POM depends on `log4j-core` 2.5 (Log4Shell-era, 3 critical advisories). Verify the built `bio-webapp` WAR. | `bio/webapp/build.gradle:42-44` |
| 10 | Build tooling is on EOL lines: Gradle 4.9 (`distributionUrl` is templated `@@im_gradle_distribution_url@@` in 7 `gradle-wrapper.properties.in`); the `compile`/`runtime`/`testCompile`/`providedCompile` configurations and `maven` plugin are removed in Gradle 7. `plugin/` has no third-party deps (`gradleApi()`, `localGroovy()` only). | all 7 builds |
| 11 | Repositories are indirected through properties (`intermine.maven.central`, `.ebi` for JAMI, `.clojars`, `.plugins`); one `flatDir { dirs '../libs' }` in `intermine/build.gradle` for the vendored antlr jar. | `intermine/build.gradle:13-20`, `bio/gradle.properties.in` |
| 12 | Logging mismatch: the only logging config shipped is `intermine/resources/src/main/resources/log4j2.properties` (log4j2 syntax, `log4j2.debug=true`), but code uses the log4j 1.x API (351 files) provided by `reload4j`, and all `org.apache.logging.log4j` artefacts are excluded. reload4j does not read `log4j2.properties`, so this file is dead config unless a log4j2 stack is supplied by the container; `WebConfig.java:77` calls `BasicConfigurator.configure()`. | `intermine/webapp/.../config/WebConfig.java:77` |
| 13 | Relocated upstream coordinates: `commons-collections` -> `org.apache.commons:commons-collections4`; `commons-lang` -> `commons-lang3` (already used once, v3.0); `commons-httpclient` -> `org.apache.httpcomponents:httpclient`/`client5`; `fastutil:fastutil` -> `it.unimi.dsi:fastutil`; `ant:ant` -> `org.apache.ant:ant`; `au.com.bytecode:opencsv` -> `com.opencsv:opencsv`; `bcprov-jdk15on` -> `bcprov-jdk18on`; `javax.*` -> `jakarta.*` (EE 9+). | Central metadata |

## 5. Tiering

- **Tier 2 (16 coordinates, 5 of them also removal candidates; minimal CVE patches only, no upgrade investment)**: `struts-core`, `struts-extras`, `struts-taglib`, `struts-tiles`, `dwr`, `lucene-core`, `lucene-snowball`, `lucene-highlighter`, `lucene-queries`, `lucene-analyzers`, `commons-fileupload` (Struts multipart plus one upload service; a drop-in bump to 1.6.0 clears all 6 advisories), `javax.servlet:jstl`, `taglibs-standard`, `taglibs:string`, `javax.servlet.jsp-api`, `JOpenId` (OpenID 2 login). Struts 1 has no upstream fix for any of its 6 advisories: mitigation is retiring Struts 1, not patching.
- **Tier 1 (63 coordinates, 25 of them flagged "remove")**: everything else, i.e. libraries used by `model`/`objectstore`/`api`/`integrate`/`bio` and the web-service layer, plus build/test libs (junit, xmlunit, easymock, cglib, ant, Tomcat test container). Highest-value first moves, all Tier 1:
  1. `postgresql` 42.2.2 -> 42.7.x (8 advisories incl. critical CVE-2024-1597 SQL injection; per the advisory it needs `preferQueryMode=simple`, so check deployment JDBC URLs). Every API used (`CopyManager`, `LargeObjectManager`, `PGConnection`, `PSQLException`, and the test-only deprecated `PGPoolingDataSource`) still exists in 42.7.14 (checked by listing the jar).
  2. `jackson-databind` 2.2.3/2.9.8 -> 2.18.11+ or 2.22.3 (70 advisories, 20 critical). Used in 9 files via `ObjectMapper` and annotations only.
  3. `commons-collections` 3.2 -> 3.2.2 immediately (critical CVE-2015-7501): `InvokerTransformer` is called in 5 main files; longer term `commons-collections4`.
  4. `commons-beanutils` 1.9.3 -> 1.11.0; `org.json:json` 20170516 -> 20260814 (3 advisories); `commons-lang` 2.6 (no fix) -> `commons-lang3` >= 3.18.0; `commons-io` 1.2 -> 2.x; `bcprov-jdk15on` 1.50 -> `bcprov-jdk18on` (17 advisories); `ant` 1.7.0/1.6.5 -> `org.apache.ant:ant:1.10.18`; `junit` 4.8.2 -> 4.13.2; `xalan` and `commons-httpclient` (no fix) -> remove; Tomcat test container 9.0.115 -> 9.0.121+.

## 6. Known vulnerabilities

Source: GitHub Advisory Database, queried 2026-11-15 per declared (group:artifact@version). "Fixed in" is the smallest patched version greater than the declared one for that advisory (backport branches may differ); "clears all at" is the largest such value, i.e. the minimum single version that clears every listed advisory (can force a major-line jump, e.g. Jena 3 -> 4). Coordinates with **no advisory** at their declared version: ant:ant, antlr, opencsv, cglib, reload4j, slf4j-reload4j, gradle-cargo-plugin, jackson-annotations, je, HikariCP, commons-codec (both), commons-logging, fastutil, the jakarta/javax xml/annotation APIs, javax.mail, servlet/jsp/jstl/ws.rs APIs, mockobjects, base64, commons-math3, apache-jena-libs (advisories sit on `jena-core`), all five lucene artefacts, oltu, solr-solrj 8.11.4, struts-taglib, taglibs, biojava (3), easymock, everit, JOpenId, jersey (2), objenesis, asm, jsonassert, the 7 JAMI artefacts, stax, xmlunit. No advisory in GHSA is not proof of safety: Lucene 3.0.2, Struts taglib, DWR and stax 1.2.0 are unmaintained.


#### `com.fasterxml.jackson.core:jackson-core` (declared 2.9.8) - 4 advisories (3 high, 1 medium); clears all at: 2.18.11
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2025-52999 | GHSA-h46c-h94j-95f3 | high | 2.15.0 | jackson-core can throw a StackoverflowError when processing deeply nes |
| CVE-2026-68494 | GHSA-r7wm-3cxj-wff9 | high | 2.18.8 | jackson-core: Async parser maxNumberLength bypass via chunked digit ac |
| CVE-2026-89425 | GHSA-7hhh-6rmp-j9qf | high | 2.18.11 | jackson-core: UTF8DataInputJsonParser._reportInvalidToken() missing ma |
| CVE-2025-49128 | GHSA-wf8f-6423-gfxg | medium | 2.13.0 | Jackson-core Vulnerable to Memory Disclosure via Source Snippet in Jso |

#### `com.fasterxml.jackson.core:jackson-databind` (declared 2.2.3, 2.9.8) - 70 advisories (20 critical, 43 high, 7 medium); clears all at: 2.18.11
- critical (20): CVE-2018-7489, CVE-2017-7525, CVE-2017-17485, CVE-2017-15095, CVE-2018-14719, CVE-2018-19362, CVE-2018-14718, CVE-2018-11307, CVE-2019-14379, CVE-2019-16335, CVE-2019-14540, CVE-2019-16942, CVE-2019-17531, CVE-2019-16943, CVE-2020-8840, CVE-2019-20330, CVE-2020-9546, CVE-2020-9547, CVE-2020-9548, CVE-2019-17267
- high (43): CVE-2018-12022, CVE-2019-12086, CVE-2019-14439, CVE-2020-10969, CVE-2020-11620, CVE-2020-10672, CVE-2020-10673, CVE-2019-14892, CVE-2019-14893, CVE-2020-10968, CVE-2020-11111, CVE-2020-11113, CVE-2020-11619, CVE-2020-11112, CVE-2020-14061, CVE-2020-14062, CVE-2020-14060, CVE-2020-14195, CVE-2018-5968, CVE-2021-20190, CVE-2020-25649, CVE-2020-36186, CVE-2020-36189, CVE-2020-36187, CVE-2020-36188, CVE-2020-36183, CVE-2020-36184, CVE-2020-36180, CVE-2020-36181, CVE-2020-36185, CVE-2020-36179, CVE-2020-36182, CVE-2020-24750, CVE-2020-35728, CVE-2020-35491, CVE-2020-35490, CVE-2020-24616, CVE-2020-36518, CVE-2020-10650, CVE-2022-42003, CVE-2022-42004, CVE-2026-91776, CVE-2026-91777
- medium/low: 7 more (see GHSA database)

#### `commons-beanutils:commons-beanutils` (declared 1.9.3) - 3 advisories (3 high); clears all at: 1.11.0
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2014-0114 | GHSA-p66x-2cv9-qq3v | high | 1.9.4 | Arbitrary code execution in Apache Commons BeanUtils |
| CVE-2019-10086 | GHSA-6phf-73q6-gh87 | high | 1.9.4 | Insecure Deserialization in Apache Commons Beanutils |
| CVE-2025-48734 | GHSA-wxr5-93ph-8wr9 | high | 1.11.0 | Apache Commons Improper Access Control vulnerability |

#### `commons-collections:commons-collections` (declared 3.2) - 2 advisories (1 critical, 1 high); clears all at: 3.2.2
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2015-7501 | GHSA-fjq5-5j5f-mvxh | critical | 3.2.2 | Deserialization of Untrusted Data in Apache commons collections |
| CVE-2015-6420 | GHSA-6hgm-866r-3cjv | high | 3.2.2 | Insecure Deserialization in Apache Commons Collection |

#### `commons-fileupload:commons-fileupload` (declared 1.2.2) - 6 advisories (1 critical, 5 high); clears all at: 1.6.0
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2016-1000031 | GHSA-7x9j-7223-rg5m | critical | 1.3.3 | Improper Access Control in commons-fileupload |
| CVE-2014-0050 | GHSA-xx68-jfcg-xmmf | high | 1.3.1 | Commons FileUpload Denial of service vulnerability |
| CVE-2016-3092 | GHSA-fvm3-cfvj-gxqq | high | 1.3.2 | High severity vulnerability that affects commons-fileupload:commons-fi |
| CVE-2013-2186 | GHSA-qx6h-9567-5fqw | high | 1.3.1 | Arbitrary file write in Apache Commons Fileupload |
| CVE-2023-24998 | GHSA-hfrx-6qgj-fp6c | high | 1.5 | Apache Commons FileUpload denial of service vulnerability |
| CVE-2025-48976 | GHSA-vv7r-c36w-3prj | high | 1.6.0 | Apache Commons FileUpload, Apache Commons FileUpload: FileUpload DoS v |

#### `commons-httpclient:commons-httpclient` (declared 3.0) - 1 advisories (1 medium); clears all at: no fix for 1 advisory(ies)
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2012-5783 | GHSA-3832-9276-x7gf | medium | no fix | Improper Certificate Validation in Apache Commons HttpClient |

#### `commons-io:commons-io` (declared 1.2) - 1 advisories (1 medium); clears all at: 2.7
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2021-29425 | GHSA-gwrp-pvrq-jmwv | medium | 2.7 | Path Traversal and Improper Input Validation in Apache Commons IO |

#### `commons-lang:commons-lang` (declared 2.6) - 1 advisories (1 medium); clears all at: no fix for 1 advisory(ies)
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2025-48924 | GHSA-j288-q9x7-2f5v | medium | no fix | Apache Commons Lang is vulnerable to Uncontrolled Recursion when proce |

#### `junit:junit` (declared 4.8.2) - 1 advisories (1 medium); clears all at: 4.13.1
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2020-15250 | GHSA-269g-pwp5-87pp | medium | 4.13.1 | TemporaryFolder on unix-like systems does not limit access to created  |

#### `org.apache.ant:ant` (declared 1.7.0) - 3 advisories (1 high, 2 medium); clears all at: 1.10.9
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2020-11979 | GHSA-f62v-xpxf-3v68 | high | 1.10.9 | Code injection in Apache Ant |
| CVE-2020-1945 | GHSA-4p6w-m9wc-c9c9 | medium | 1.9.15 | Sensitive Data Exposure in Apache Ant |
| CVE-2021-36373 | GHSA-q5r4-cfpx-h6fh | medium | 1.9.16 | Improper Handling of Length Parameter Inconsistency in Apache Ant |

#### `org.apache.commons:commons-lang3` (declared 3.0) - 1 advisories (1 medium); clears all at: 3.18.0
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2025-48924 | GHSA-j288-q9x7-2f5v | medium | 3.18.0 | Apache Commons Lang is vulnerable to Uncontrolled Recursion when proce |

#### `org.apache.jena:jena-core` (declared 3.16.0) - 1 advisories (1 high); clears all at: 4.2.0
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2021-39239 | GHSA-7rp6-w7mg-h8rw | high | 4.2.0 | XML External Entity Reference in Apache Jena |

#### `org.apache.struts:struts-core` (declared 1.3.10) - 4 advisories (4 high); clears all at: no fix for 4 advisory(ies)
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2016-1181 | GHSA-7jw3-5q4w-89qg | high | no fix | Improper Input Validation in Apache Struts |
| CVE-2016-1182 | GHSA-5ggr-mpgw-3mgx | high | no fix | Improper Input Validation in Apache Struts |
| CVE-2015-0899 | GHSA-cvvx-r33m-v7pq | high | no fix | Improper Input Validation in Apache Struts |
| CVE-2023-34396 | GHSA-4g42-gqrg-4633 | high | no fix | Apache Struts vulnerable to memory exhaustion |

#### `org.apache.struts:struts-extras` (declared 1.3.10) - 1 advisories (1 medium); clears all at: no fix for 1 advisory(ies)
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2025-54656 | GHSA-cx25-xg7c-xfm5 | medium | no fix | Apache Struts Extras Before 2 has an Improper Output Neutralization fo |

#### `org.apache.struts:struts-tiles` (declared 1.3.10) - 1 advisories (1 high); clears all at: no fix for 1 advisory(ies)
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2023-49735 | GHSA-qw4h-3xjj-84cc | high | no fix | Apache Tiles: Unvalidated input may lead to path traversal and XXE |

#### `org.apache.tomcat:tomcat` (declared 9.0.115) - 22 advisories (8 critical, 8 high, 5 medium, 1 low); clears all at: 9.0.121
- critical (8): CVE-2026-29145, CVE-2026-43512, CVE-2026-43515, CVE-2026-41293, CVE-2026-55276, CVE-2026-65905, CVE-2026-65182, CVE-2026-68525
- high (8): CVE-2026-34483, CVE-2026-34487, CVE-2026-29129, CVE-2026-29146, CVE-2026-41284, CVE-2026-43513, CVE-2026-42498, CVE-2026-53404
- medium/low: 6 more (see GHSA database)

#### `org.apache.velocity:velocity` (declared 1.3) - 1 advisories (1 high); clears all at: no fix for 1 advisory(ies)
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2020-13936 | GHSA-59j4-wjwp-mw9m | high | no fix | Sandbox Bypass in Apache Velocity Engine |

#### `org.bouncycastle:bcprov-jdk15on` (declared 1.50) - 17 advisories (6 high, 10 medium, 1 low); clears all at: no fix for 2 advisory(ies)
- high (6): CVE-2018-1000180, CVE-2016-1000352, CVE-2016-1000343, CVE-2016-1000342, CVE-2016-1000338, CVE-2016-1000344
- medium/low: 11 more (see GHSA database)

#### `org.directwebremoting:dwr` (declared 2.0.1) - 2 advisories (2 medium); clears all at: 2.0.11
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2014-5326 | GHSA-q5v2-2v66-6hwm | medium | 2.0.11 | Improper Neutralization of Input During Web Page Generation in Direct  |
| CVE-2014-5325 | GHSA-hqw5-62gp-rqgm | medium | 2.0.11 | Exposure of Sensitive Information to an Unauthorized Actor in Direct W |

#### `org.json:json` (declared 20170516) - 3 advisories (2 high, 1 medium); clears all at: 20260719
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2022-45688 | GHSA-3vqj-43w4-2q58 | high | 20230227 | json stack overflow vulnerability |
| CVE-2023-5072 | GHSA-4jq9-2xhw-jpx7 | high | 20231013 | Java: DoS Vulnerability in JSON-JAVA |
| CVE-2026-59171 | GHSA-ghc9-756g-vrcv | medium | 20260719 | JSON-java: JSONTokener Has Unbounded Numeric String Resource-Exhaustio |

#### `org.postgresql:postgresql` (declared 42.2.2) - 8 advisories (1 critical, 4 high, 2 medium, 1 low); clears all at: 42.7.11
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2024-1597 | GHSA-24rp-q3w6-vc56 | critical | 42.2.28 | org.postgresql:postgresql vulnerable to SQL Injection via line comment |
| CVE-2022-21724 | GHSA-v7wg-cpwc-24m4 | high | 42.2.25 | pgjdbc Does Not Check Class Instantiation when providing Plugin Classe |
| CVE-2020-13692 | GHSA-88cc-g835-76rp | high | 42.2.13 | Improper Restriction of XML External Entity Reference |
| CVE-2022-31197 | GHSA-r38f-c4h4-hqq2 | high | 42.2.26 | PostgreSQL JDBC Driver SQL Injection in ResultSet.refreshRow() with ma |
| CVE-2026-42198 | GHSA-98qh-xjc8-98pq | high | 42.7.11 | pgjdbc: Unbounded PBKDF2 iterations in SCRAM authentication allows CPU |
| - | GHSA-673j-qm5f-xpv8 | medium | 42.3.3 | pgjdbc Arbitrary File Write Vulnerability |
| CVE-2022-41946 | GHSA-562r-vg33-8x8h | medium | 42.2.27 | TemporaryFolder on unix-like systems does not limit access to created  |
| CVE-2022-26520 | GHSA-727h-hrw8-jg8q | low | 42.3.3 | Path traversal in org.postgresql:postgresql |

#### `xalan:xalan` (declared 2.7.2) - 1 advisories (1 high); clears all at: 2.7.3
| CVE | GHSA | Severity | Fixed in (min above declared) | Summary |
|---|---|---|---|---|
| CVE-2022-34169 | GHSA-9339-86wc-4qgf | high | 2.7.3 | Apache Xalan Java XSLT library integer truncation issue when processin |

### 6.1 Transitive libraries with advisories (indicative, not a Gradle resolution)

Resolved by walking compile/runtime POM dependencies (depth 4, highest version per artefact, exclusions ignored except noting the project-wide `org.apache.logging.log4j` exclude), starting from every non-test direct dependency except HikariCP (`transitive: false`). Treat as a lead list; confirm with `gradle dependencies` in a build environment.

| Transitive coordinate | Version | Pulled in via | Advisories | Clears all at |
|---|---|---|---|---|
| com.google.guava:guava | 19.0 | org.everit.json:org.everit.json.schema | 4 (1 high, 2 medi, 1 low) | 33.7.2 |
| io.netty:netty-codec | 4.1.99.Final | org.apache.solr:solr-solrj | 3 (2 high, 1 medi) | 4.1.136.Final |
| io.netty:netty-common | 4.1.99.Final | org.apache.solr:solr-solrj > io.netty:netty-codec | 2 (2 medi) | 4.1.118.Final |
| io.netty:netty-handler | 4.1.99.Final | org.apache.solr:solr-solrj | 6 (1 crit, 4 high, 1 medi) | 4.1.137.Final |
| io.netty:netty-transport-native-epoll | 4.1.99.Final | org.apache.solr:solr-solrj | 1 (1 medi) | 4.1.135.Final |
| log4j:log4j | 1.2.17 | org.apache.solr:solr-solrj > org.apache.zookeeper:zookeeper | 6 (3 crit, 3 high) | 2.0 (+unfixed) |
| org.apache.commons:commons-compress | 1.20 | org.apache.jena:apache-jena-libs > org.apache.jena:jena-shacl > org.apache.jena:jena-arq > org.apache.jena:jena-core > org.apache.jena:jena-base | 5 (4 high, 1 medi) | 1.26.0 |
| org.apache.logging.log4j:log4j-core | 2.5 | org.biojava:biojava-core | 8 (3 crit, 1 high, 3 medi, 1 low) | 2.25.4 |
| org.apache.thrift:libthrift | 0.13.0 | org.apache.jena:apache-jena-libs > org.apache.jena:jena-shacl > org.apache.jena:jena-arq | 4 (4 high) | 0.24.0 |
| org.apache.zookeeper:zookeeper | 3.6.2 | org.apache.solr:solr-solrj | 2 (1 crit, 1 medi) | 3.8.4 |
| org.eclipse.jetty.http2:http2-common | 9.4.53.v20231009 | org.apache.solr:solr-solrj | 3 (2 high, 1 medi) | 10.0.17 |
| org.eclipse.jetty:jetty-http | 9.4.53.v20231009 | org.apache.solr:solr-solrj | 3 (1 high, 1 medi, 1 low) | 12.0.31 |
| org.xerial.snappy:snappy-java | 1.1.10.1 | org.apache.solr:solr-solrj | 4 (3 high, 1 medi) | 1.1.10.9 |

Notes: `log4j:log4j` 1.2.17 comes from Solr's ZooKeeper (`slf4j-log4j12` binding), has no fixed 1.x release and would clash with `reload4j` (same classes). The netty/jetty/zookeeper/snappy rows arrive via `solr-solrj` 8.11.4 (last Solr 8.x); consider excluding them if only `HttpSolrClient` is used. `commons-compress`, `libthrift` arrive via `apache-jena-libs` 3.16.0 (jena-arq/jena-shacl); Jena is imported in only 6 files. `guava` 19.0 comes from `everit-json-schema` 1.5.1 (no direct Guava imports exist in the codebase). `log4j-core` 2.5 (CVE-2021-44228 Log4Shell, CVE-2021-45046, CVE-2017-5645 critical) comes from `biojava-core` 4.2.0 and is covered by the exclude everywhere except `bio/webapp` (finding 9).
