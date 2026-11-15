# 0003. Struts and other grant-retired subsystems: patch, do not replace

Status: Accepted, 2026-11-15, decided by Gos Micklem with Claude.

## Context

- The grant application (APP77434, "Scaling InterMine and AllianceMine") sets the feature direction:
  replace Postgres with QLever (SPARQL), move lists and templates to static files, retire the
  user-profile DB, web services and ORM (`plans/00-overview.md`, Context).
- Consequently the intermine back end is "keep the lights on": security updates, toolchain modernisation,
  green tests, modern CI and releasable artefacts, with no deep refactoring.
- Ancient dependencies (`plans/10-intermine-backend.md`, Findings): Struts 1.3.10 (170 Java files,
  207 JSPs), DWR 2.0.1, Lucene 3.0.2, the user-profile DB, commons-httpclient 3.0, and others.
- The runtime is Tomcat 9 with `javax.*`; no Jakarta migration yet (see ADR 0002).
- Dependency hygiene rules (rule 5b): a weak-dependency census comes first, libraries used in one place
  are removed rather than upgraded, replacements are vetted and logged in `decisions/package-vetting.md`.

## Decision

Per `plans/00-overview.md`, strategy decisions 2 and 3, the back-end dependency work has two tiers:

- **Tier 1** (do now, non-breaking for deployers' Java code): Postgres JDBC, Jackson, commons-*, bcprov,
  Jena, solrj, JUnit 4.13, HikariCP. servlet-api stays 3.1/4.0.
- **Tier 2** (the grant will retire these): Struts, DWR, Lucene 3, the profile DB. Only CVE-driven minimal
  patches. **Do not replace Struts 1;** patch around it.

Each CVE-bearing dependency found in the inventory (`inventory/dependencies.md`) becomes a Tier 1 or
Tier 2 issue. Replacing a package outright still requires the vetting step in rule 5b.

## Consequences

Positive:
- Effort goes to what benefits deployers now and survives the grant direction.
- Avoids a large Struts/JSP rewrite and a Jakarta migration that the grant would make redundant.
- Keeps the 5.1.1 release (Gradle 6.9.4 plus Tier 1 bumps) small enough to land non-breaking.

Negative:
- Struts 1, DWR and Lucene 3 stay in the product, with the security exposure that implies beyond
  CVE-driven patches.
- Minimal patches may need to be carried locally if upstream has no fixed version.

Follow-ups:
- Produce `inventory/dependencies.md` and `inventory/dependency-usage.md` and classify each dependency
  as Tier 1, Tier 2 or "remove".
- If dependabot alert reading on `intermine/intermine` is unavailable (needs `security_events` and
  admin/security access), the CVE inventory uses the GitHub Advisory DB and build-file versions.

## Alternatives considered

- **Replace Struts 1 now.** Rejected: Struts is retired by the grant direction, so a replacement would be
  wasted work.
- **Deep refactor of the back end.** Rejected: the back end is "keep the lights on" per the grant
  direction.
- **Upgrade all dependencies, Tier 2 included.** Rejected: Tier 2 libraries are slated for removal, so
  only CVE-driven minimal patches are justified.

## Review trigger

Revisit if the grant timeline changes so that Struts, DWR, Lucene 3 or the profile DB are not retired,
if a CVE in a Tier 2 component cannot be fixed with a minimal patch, or if deployers report that Tier 2
components block their own upgrades.
