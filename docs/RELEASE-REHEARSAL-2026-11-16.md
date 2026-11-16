# Release rehearsal im-89g.32 (16 Nov 2026)

Both lines built with `./gradlew centralBundle` in the five builds, signed with a throwaway RSA-3072 key (no passphrase,
fingerprint A92BB41CF44589A306F47238640A7FEB3153729A, GNUPGHOME /home/agent/taskhomes/im-89g.32/gnupg), JDK 8, no upload.
Nothing was uploaded; the only network use was Gradle dependency resolution.

| Line | worktree | commit | Gradle |
|---|---|---|---|
| 6.0.0 | worktrees/intermine/im-89g.32-bundle-60 | a27dcf5398 (maint-2026) | 8.14.6 |
| 5.1.1 | worktrees/intermine/im-89g.32-bundle-511 | be54f8d81f (release/5.1.1-candidate); doc fix on branch maint/im-89g.32-bundle-511 a5cee46b0f | 6.9.4 |

## Result: all ten bundles are structurally valid; no defect that Central would reject

| Line | Bundle | Modules | Zip size | Wall time | Verdict |
|---|---|---|---|---|---|
| 6.0.0 | plugin-bundle.zip | 1 | 0.64 MB | 12 s | OK |
| 6.0.0 | intermine-bundle.zip | 10 | 24.1 MB | 26 s | OK |
| 6.0.0 | bio-bundle.zip | 5 | 34.6 MB | 17 s | OK |
| 6.0.0 | bio-sources-bundle.zip | 44 | 34.5 MB | 80 s | OK |
| 6.0.0 | bio-postprocess-bundle.zip | 16 | 0.55 MB | 16 s | OK |
| 5.1.1 | plugin-bundle.zip | 1 | 0.53 MB | 6 s | OK |
| 5.1.1 | intermine-bundle.zip | 10 | 28.1 MB | 22 s | OK |
| 5.1.1 | bio-bundle.zip | 5 | 38.3 MB | 15 s | OK |
| 5.1.1 | bio-sources-bundle.zip | 44 | 34.6 MB | 77 s | OK |
| 5.1.1 | bio-postprocess-bundle.zip | 16 | 0.59 MB | 14 s | OK |

Wall time is the whole `./gradlew --no-daemon centralBundle` (compile, jars, sources, javadoc, POM, sign, zip), cold daemon, warm dependency cache, `--max-workers=2 -Xmx3g`. Peak memory was not measured. Both lines have the same 76 modules (same artifactIds; versions 6.0.0 / 5.1.1).

Module counts differ from the brief in one place: the `intermine` build has **10** modules, not 11 (settings.gradle includes model, testresources, pathquery, objectstore, integrate, api, resources, webapp, webtasks, jbrowse-endpoint; the commented-out webservice-client/webservice-test are not built). Same on both lines. `bio/sources` has 44 module directories with a build.gradle (plus `example-sources`, `build`, `gradle`, which are not modules) and 44 are published.

## What was checked, per bundle (script: tools/verify.py)

- Zip integrity (`testzip`), every file under `org/intermine/<artifactId>/<version>/`, version dir equals the build version, no `maven-metadata*`, no `.module` files, no files outside that layout.
- Per module: `.pom`, `.jar` (or `.war`), `-sources.jar`, `-javadoc.jar`, each with `.asc`, `.md5`, `.sha1` (and `.sha512`, which Gradle writes; the Portal ignores it). Extra classifier jars (`-classes.jar`, `-testClasses.jar`) also have all three companions. 0 missing in all ten bundles.
- md5 and sha1 recomputed and compared for every artefact (6.0.0 and 5.1.1: 614 md5/sha1 files each): 0 mismatches.
- `gpg --verify` of **every** .asc against its file (6.0.0: 4 + 42 + 21 + 176 + 64 = 307; 5.1.1: same): 0 failures. Signatures are on every artefact including the POM.
- POM: groupId `org.intermine`, artifactId and version match the path, `name`, `description`, `url`, `licenses/license` (name + url), `developers/developer/name`, `scm` (url, connection, developerConnection) present; no `<repositories>` or `<pluginRepositories>`; no SNAPSHOT; every dependency has a concrete version (no `+`, `[`, `${`); no test-scope dependency; `packaging` war for the two war modules. 0 POMs with any problem on both lines.
- Cross check (tools/xdeps.py): all 388 `org.intermine` dependency edges in the POMs of each line point to a (artifactId, version) that is in one of the five bundles of that line; no external dependency has a non-numeric version.
- Wars: `intermine-webapp` has `.war` + `-classes.jar` (+ POM `<packaging>war</packaging>`, the intermine-api/objectstore dependencies as `provided`); `bio-webapp` has `.war` + `-classes.jar` and its POM depends on `intermine-webapp` with `<classifier>classes</classifier>` scope `provided`, which is what the mines resolve. `intermine-integrate` carries `-testClasses.jar`.
- Plugin: the bundle carries `org.intermine:plugin` only, with no Gradle plugin marker artifact (`org.intermine.plugin.gradle.plugin` does not exist and is not needed): the mines put the plugin on the buildscript classpath (`classpath group: 'org.intermine', name: 'plugin', version: ...`, see docs/UPGRADING-build.md) and then `apply plugin: 'webapp'` etc. by the short ids in `META-INF/gradle-plugins/*.properties` inside the jar (webapp, integrate, postprocess, dbmodel, mine-dbmodel, biocore-dbmodel, biomodel-dbmodel, biosource-dbmodel). The plugin POM has no dependencies (gradleApi/localGroovy are not leaked).

## Observations (not rejections)

1. Thin javadoc/sources jars: `intermine-resources` and `intermine-testresources` javadoc jars (and the testresources sources jar) contain only a manifest, because the modules have no Java sources. Central requires the files to exist; I do not know of a content check beyond that, but if the Portal complains about an empty javadoc jar this is where.
2. The bundles are not byte-reproducible (PGP signatures are timestamped); re-running changes the zip bytes, not the content.
3. `.sha512` files ship in every bundle (Gradle verifies against them; Portal accepts extra checksums). `.asc.*` and `.sha256` are excluded as designed.
4. 6.0.0 docs (section 2 and 4) say JDK 17 for 6.0.0; this rehearsal used JDK 8 as requested (Gradle 8.14.6 prints its deprecation notice "Executing Gradle on JVM versions 16 and lower"). The JDK 17 run was not done; the jars are Java 8 bytecode with either (`java-target.gradle`).
5. The POM `<developers>` entry has only a `name` (no id/email/url). Central requires at least one developer with a `name`; id and email are optional.
6. Gradle emitted no publishing-script warnings with `--warning-mode all` on either line.

## Defects found

1. (fixed, branch `maint/im-89g.32-bundle-511`, commit a5cee46b0f, docs + comment only) **5.1.1 docs/RELEASING.md section 3 does not say that `gradle.properties` and `gradle-wrapper.properties` are generated, git-ignored files.** On a fresh clone `./gradlew centralBundle` stops at once with `Could not get unknown property 'intermine.maven.central' for root project 'plugin'` (reproduced by moving plugin/gradle.properties away). Section 2 and the 6.0.0 section 4 step (1) already generate them via `config/lib/install_intermine.py`. Step 1 of section 3 now says so. No publishToMavenLocal/install step is required before `centralBundle`: each build compiles its own modules and the later builds find the earlier jars through `build/libs` (confirmed: I ran the five `centralBundle` builds in order with no install).
2. (fixed, same commit) The header comment of `config/gradle/central-bundle.gradle` on 5.1.1 said `<build>-<version>.zip`; the file is `<name>-bundle.zip` (the 6.0.0 line already says so). After the fix the 5.1.1 plugin bundle was rebuilt: BUILD SUCCESSFUL, same 20 files.
3. The brief's "11 intermine modules" is wrong; 10 is correct (above). docs/RELEASING.md does not state a count, so nothing to fix there.

No defect in the generated POMs, signatures, checksums or layout on either line. The 6.0.0 worktree is unchanged (no commit).

## Commands (repeat with the real key)

```bash
# once per checkout: generated, git-ignored files (the gate's variant skips the Gradle install; the plain script also works)
export PSQL_HOST=localhost PSQL_USER=test PSQL_PWD=test
python3 -I config/lib/install_intermine.py          # or tools/genprops.py <checkout>/config/lib  (skips the publishToMavenLocal step)

# key (rehearsal: tools/keygen.batch, `gpg --batch --gen-key`; real run: your key)
export SIGNING_KEY="$(gpg --armor --export-secret-keys <KEYID>)"
export SIGNING_PASSWORD=''                          # real key: its passphrase
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64 LANG=C.UTF-8 LC_ALL=C.UTF-8

for b in plugin intermine bio bio/sources bio/postprocess; do
  (cd $b && ./gradlew -Dorg.gradle.jvmargs=-Xmx3g --max-workers=2 --no-daemon --warning-mode all centralBundle) || break
done

# verification (rehearsal GNUPGHOME has the throwaway public key; for the real key import its public half)
export GNUPGHOME=/home/agent/taskhomes/im-89g.32/gnupg
python3 -I tools/verify.py <bundle.zip> <empty-extract-dir> <version>     # layout, checksums, gpg --verify of every .asc, POM rules
python3 -I tools/xdeps.py <dir-with-the-five-extract-dirs> <version>      # cross-bundle dependency check
```

The exact commands of this run are in tools/bundle.sh (one build), tools/genprops.py, and the logs in logs/ (60-*.log, 511-*.log).

## Artefacts (delete when done)

`/home/agent/taskhomes/im-89g.32/` (private key in gnupg/, extracted bundles 60/ and 511/, the ten zips in 60/zips and 511/zips, logs/, tools/, and the task's Postgres DBs `*_im_89g_32`, which `scripts/im-testenv.sh im-89g.32 destroy` drops together with the directory).
Both worktrees' `build/` directories were deleted; the generated, git-ignored gradle.properties / gradle-wrapper.properties remain.
