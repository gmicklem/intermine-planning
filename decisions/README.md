# Decision records

Decision records (ADR style) for the 2026 InterMine + BlueGenes maintenance sprint. Each is Accepted,
2026-11-15, decided by Gos Micklem with Claude. The sources are the plans in `../plans/`.

| Record | Title |
|---|---|
| [0001-gradle-upgrade-not-switch.md](0001-gradle-upgrade-not-switch.md) | Upgrade Gradle step by step, do not switch build systems |
| [0002-jdk-target-17.md](0002-jdk-target-17.md) | JDK target 17 (verify 21), keep Tomcat 9 and javax |
| [0003-struts-and-retired-subsystems.md](0003-struts-and-retired-subsystems.md) | Struts and grant-retired subsystems: patch, do not replace |
| [0004-bluegenes-build-tool-shadow-cljs.md](0004-bluegenes-build-tool-shadow-cljs.md) | BlueGenes build tool: shadow-cljs and deps.edn |
| [0005-beads-orchestrator-only-writer.md](0005-beads-orchestrator-only-writer.md) | Beads in embedded mode, orchestrator is the only writer |
| [0006-branching-and-gates.md](0006-branching-and-gates.md) | Branching model, remotes and gate scripts |

## Other logs

- [package-vetting.md](package-vetting.md): the package-vetting log. Whenever a dependency is replaced by a
  different package (not merely bumped), the worker records the vet there, even when the verdict is safe,
  for discussion with Gos.

## Record format

Status, Context, Decision, Consequences (positive, negative, follow-ups), Alternatives considered, Review
trigger.
