# 0002. JDK target 17 (verify 21), keep Tomcat 9 and javax

Status: Accepted, 2026-11-15, decided by Gos Micklem with Claude.

## Context

- The back end currently builds and runs on JDK 8 with Gradle 4.9 (`plans/00-overview.md`, Context).
- The `javax.*` namespace is used throughout, on a Tomcat 9 runtime. There is no Jakarta migration yet
  (`plans/10-intermine-backend.md`, Findings).
- Struts 1.3.10 (170 Java files, 207 JSPs) and DWR 2.0.1 are among the ancient dependencies; the grant
  direction retires web services, the ORM and the user-profile DB.
- B4 notes `--illegal-access` fallout: reflection in objectstore/torque and the antlr 2 caching jar.
- rdfc2im (`rdfc2im/tools/full-build.sh`) needs JDK 8 and consumes published `org.intermine` 5.0.8
  artefacts (`plans/30-testbed.md`).
- Sandbox: only JDK 25 is installed; apt has openjdk-8, 11, 17 and 21 (`plans/00-overview.md`).
- CI today uses `setup-java@v1` (`.github/workflows/im-build.yml`).

## Decision

Per `plans/00-overview.md`, strategy decision 2:

- Run the back end on **JDK 17**, and verify on **21** (B4: JDK 17 build and test run via toolchains, then
  21 verification).
- Keep **Tomcat 9 and the javax namespace**. Jakarta migration (Tomcat 10+) is a separate, later item.
- servlet-api stays 3.1/4.0 (Tier 1 rule).
- JDK 8 stays in the CI matrix only until B4 lands: {8 (until B4), 17, 21} x postgres {14, 16}.

## Consequences

Positive:
- Moves off JDK 8 without the large, risky namespace migration.
- Tier 1 dependency bumps stay non-breaking for deployers' Java code.
- CI covers the current LTS lines (17 and 21).

Negative:
- `--illegal-access` fallout must be fixed (objectstore/torque reflection, antlr 2 caching jar).
- Tomcat 9 and javax remain, so those parts stay on a legacy line until the Jakarta item is scheduled.
- The testbed (rdfc2im) still needs JDK 8 until it is updated, so JDK 8 tooling must be kept installed in
  the sandbox.

Follow-ups:
- Jakarta/Tomcat 10+ migration tracked as a separate later item.
- Gradle step order in ADR 0001 sets when JDK 17 can be used (B4 follows B1-B3).

## Alternatives considered

- **Stay on JDK 8.** Rejected: the plan's target is a modernised toolchain, and the plans list JDK 17 as
  the build and test target (B4).
- **Target 21 only.** Rejected for now: the decision is to run on 17 and only verify 21, to limit risk.
- **Migrate to Jakarta (Tomcat 10+) at the same time.** Rejected: Struts 1 is being retired by the grant
  direction, so the plan patches around it rather than replacing it, and a Jakarta migration is a separate
  later item.

## Review trigger

Revisit if JDK 17 or 21 verification fails in ways that cannot be fixed with small changes, if a Tier 1
dependency requires Jakarta, if the grant work retires Struts so that Jakarta becomes cheap, or when the
Jakarta migration is scheduled.
