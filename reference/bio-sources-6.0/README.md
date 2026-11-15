# humanmine-bio-sources and flymine-bio-sources on the 6.0 line (scratch conversion)

Build files produced by the im-ee7.53 worker (15 Nov 2026) when converting the two deployer
bio-source repositories (intermine/humanmine-bio-sources 4.3.0, intermine/flymine-bio-sources 4.2.0;
Gradle 4.9 builds with `compile`, `maven`, `signing`, bintray/artifactory in the `*-static` modules)
so that humanmine and flymine could be built against the maint-2026 artefacts. Only the root
`build.gradle`, `gradle.properties`, `settings.gradle` and one `*-static/build.gradle` per repo are kept
here as the starting point for im-ee7.49 (convert and publish them properly). They compiled and
published with `publishToMavenLocal -x test` on Gradle 8.14.6 / JDK 17; no unit tests were run.
The InterMine `plugin` was resolved from `mavenLocal()`; `imVersion`/`bioVersion` = 5.1.1 (the version
the maint-2026 tree publishes until 6.0.0 is cut). Wrapper files were copied from intermine/plugin.
