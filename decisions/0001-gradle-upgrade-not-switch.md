# 0001. Upgrade Gradle, do not switch build systems

Status: Accepted, 2026-11-15, decided by Gos Micklem with Claude.

## Context

- InterMine's back end builds with Gradle 4.9 on JDK 8. The wrapper is not committed
  (`plans/10-intermine-backend.md`, Findings).
- The build is seven separate Gradle builds (`plugin/`, `intermine/`, `bio/`, `bio/sources/`,
  `bio/postprocess/`, `bio/postprocess-test/`, `testmine/`) wired together through local ivy dirs and a
  generated `gradle.properties` (`config/lib/install_intermine.py`).
- Gradle 7+ removes what the build relies on: `compile` (321 lines in 92 files), `testCompile`, `runtime`,
  and the `maven` plugin with `uploadArchives` (5 files).
- The custom Groovy plugin in `plugin/src/main/groovy/org/intermine/plugin/**` calls
  `configurations.getByName("compile")` about 30 times. Every deployer's mine build uses this plugin;
  the humanmine and flymine `gradle.properties` pin `imVersion=5.0.+`.
- Publishing targets the dead OSSRH and must move to Central Portal plus `maven-publish`.
- Gradle 4 to 7 (2018-2021) was an unusually breaking stretch (configuration rename, jcenter shutdown,
  plugin rewrite). Since 7, breakage per major is far smaller, and Gradle warns one major ahead.
- The grant direction (APP77434) means the back end is "keep the lights on", with no deep refactoring
  (`plans/00-overview.md`, Context).

## Decision

Upgrade Gradle in steps and keep Gradle as the build system (`plans/00-overview.md`, strategy decision 1):
4.9 -> 6.9.4 -> 7.6.4 -> 8.14 -> later 9.x.

- 6.9.4 still accepts `compile` and shows every deprecation with `--warning-mode all` (B1).
- 7.6.4 moves `compile` to `implementation`/`api` and `maven` to `maven-publish` (B2).
- 8.14 removes the `com.sun.xml.internal` property and adds a version catalog,
  `gradle/libs.versions.toml`, shared via generated properties (B3).
- Explicit `dependsOn` is replaced by input/output wiring wherever the relationship is a data dependency,
  progressively through B1-B3 (rule 5b).

## Consequences

Positive:
- Deployers keep the plugin they already use; their mines are not rewritten.
- Each step has a clear gate and the first step (6.9.4) is landable as a non-breaking 5.1.1.
- A version catalog plus dependabot/renovate makes later bumps routine; the plan expects a modest upgrade
  roughly every two years, not another rewrite.

Negative:
- B1-B3 together are the critical path and the largest single risk of the sprint.
- The Groovy plugin must be ported by hand (Opus spike, then Sonnet batches).
- Deployers will need a migration guide (`docs/UPGRADING-build.md`, B5) once 7+ lands.

Follow-ups:
- Fallback if B2 is slow: ship Gradle 6.9.4 plus Tier 1 dependency bumps plus modern CI as 5.1.1, with
  Gradle 8 / JDK 17 as 6.0.
- Move publishing to `maven-publish` plus the Central Portal plugin; document in `docs/RELEASING.md`.

## Alternatives considered

- **Switch to Maven.** Rejected: the custom plugin is the deployer-facing build tool, so switching would
  break every mine and require rewriting the plugin from scratch.
- **Stay on Gradle 4.9.** Not stated in the plans as an option; implicitly rejected because Gradle 7+
  removal of `compile`, `maven` and related features and the dead OSSRH publishing target force a move.
- **Jump straight to Gradle 8.** Rejected in favour of stepwise upgrades: 6.9.4 still accepts `compile` and
  surfaces every deprecation, which makes the later steps mechanical and allows an early 5.1.1.

## Review trigger

Revisit if B2 (Gradle 7.6.4) proves slow enough to threaten the fallback release, if Gradle's
one-major-ahead deprecation warnings start to demand plugin rewrites rather than small fixes, or if the
grant work retires the deployer-facing plugin so the deployer-impact argument no longer applies.
