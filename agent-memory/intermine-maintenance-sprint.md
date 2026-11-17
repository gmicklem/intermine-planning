---
name: intermine-maintenance-sprint
description: InterMine/BlueGenes maintenance sprint (Nov 2026): goals, branches, heads at the end of 16 Nov, where the plan and guides live
metadata:
  type: project
---

Sprint ran 14-16 Nov 2026 (deadline 23:00 UK 16 Nov) to inform Gos's subscription renewal on 17 Nov. Orchestrator = this Fable session; workers Opus (judgement) / Sonnet (mechanical); beads prefix `im` in gmicklem/intermine-planning (orchestrator is the only writer).

State at 20:30 UTC 16 Nov (all pushed, all CI green, every commit gated):
- intermine maint-2026 (6.0.0 line: Gradle 8.14.6, JDK 8+17, Byte Buddy for cglib, own DDL generator for torque, commons-lang 2/commons-logging gone, catalog version 6.0.0) head a27dcf5398 on gmicklem/intermine (remote `fork`); release/5.1.1-candidate (Gradle 6.9.4, non-breaking) head f323054d5c. Push events do not fire CI on the fork: dispatch im-build.yml + checkstyle.yml with `gh workflow run --ref`.
- bluegenes maint-2026 2785384e (origin = gmicklem/bluegenes; CI on push; nightly Cypress green); im-tables-3 f780276, imcljs d96a3eb, bluegenes-tool-store da4f23b, mine-tests cbbef24, rdfc2im maint/im-ore.1-intermine-src 22c57ae, humanmine c0731c5 / flymine 118eb07a (pins 6.0.+), humanmine-bio-sources 20ad5a2 / flymine-bio-sources e9af505 (CI builds InterMine maint-2026 in the job).
- Demo testbed: default stack 8090/5000 = 5.1.1, ut stack 18090/15000 = 6.0.0 (two commits behind), new BlueGenes 669ae3ee served on 5001/15001 (restart recipe /home/agent/taskhomes/im-bg-serve/README.txt). Superuser superuser@intermine.org / intermine.
- InterMine Registry (17 Nov): the Heroku-16 app (owner intermineorg@gmail.com, data in MongoDB Atlas, dumped privately by Gos) is being replaced by a Clojure rewrite at gmicklem/intermine-registry maint-2026 8bd88f7 (fork of intermine/intermine-registry; CI green; EDN data file, read-only API compatible with the GSoC 2017 API, hourly refresh, Hiccup pages, Docker). Not deployed yet; six open questions on bead im-bdy.13; deployment next to the mines via docker-compose.example.yml, then DNS, then retire Heroku/Atlas. Upstream push disabled on that checkout too.
- Guides for Gos in the planning repo docs/: COMPLETION.md (release/merge checklist), HUMAN_TESTING.md (manual test plan both lines), HUMAN-STEPS.md (credential steps), EXPERT_TO_CHECK.md (6 review items with reversion steps), INTERMINE_ORG_HOSTING.md, RELEASE-REHEARSAL-2026-11-16.md, SANDBOX-NOTES.md; decisions/ (0007 reagent patch; package-vetting.md); status/sprint-report.md (scripts/sprint-report.py), LOG.md checkpoints, dashboard artifact https://claude.ai/code/artifact/05b16eb4-91fb-45af-9601-1db800c8d9b5.
- Upstream push URLs are DISABLED in every checkout (Gos has admin on intermine/*); re-enable only for the upstream PRs (COMPLETION.md step 7).
- Open at the end: human steps (Clojars group membership, Central Portal namespace, DNS/HTTPS for intermine.org), JDK-11+ baseline items (HikariCP 5, JAXB shims, commons-io, Jena 5), Cypress 16, imjs fold-in, demo-data GO annotations, expert decisions (chado-db comparison).

**Production hosting (Gos, 17 Nov 2026):** HumanMine and FlyMine run as Docker containers on a DBCLS server
(133.39.78.111, ~256 GB RAM) behind nginx with per-host Let's Encrypt certs; it also serves
jbrowse.intermine.org and jbrowse2.intermine.org. docker_template was derived from that layout. The
registry, the alignment service and the full hybrid HumanMine build (plans/50) all belong there; the
earlier "no InterMine server exists" belief was wrong (only the Cambridge Dokku VM is gone). Next
sandbox session: Gos will allocate 75% of the Mac's RAM. Plan for the hybrid testbed epic im-9n4:
plans/50-hybrid-humanmine-testbed.md (milestones: tools on the demo -> Genomics England lists -> full build).
