---
name: next-session-handover
description: "Where to start the next orchestrator session (after 17 Nov 2026): hybrid HumanMine testbed epic im-9n4, Renovate/Clojars/registry waits, DBCLS build host facts"
metadata:
  node_type: memory
  type: project
  originSessionId: 0492e8a9-74f1-4807-9fab-46d9cc2516dd
  modified: 2026-11-17T22:54:54.553Z
---

**Start here (next session, Gos will give the sandbox 75% of the Mac's RAM):**
1. Read status/LOG.md checkpoint 22, plans/50-hybrid-humanmine-testbed.md, decisions/0009, plans/50-beads.tsv.
2. Check Renovate output on the eleven forks (dashboard issues / PRs / `renovate/*` branches); Mend
   showed all "onboarded" on 17 Nov 23:00 UTC but nothing had reached GitHub yet. If Maven Central
   rate-limit warnings persist, build the self-hosted Renovate scheduled workflow (design §3/§6).
3. Check clojars/administration#349 (org.intermine membership) and reagent #676 for replies.
4. Begin epic im-9n4 with T0.1 and T0.2 (beads im-9n4.2, im-9n4.3): rdfc2im stock-source support and
   the raw-file subset filter, on the ut (6.0.0) stack only; the 5.1.1 stack stays the RDF-only
   baseline. Data hosts are allowed (docs/SANDBOX-NETWORK.md); UniProt files via the EBI mirror.
5. Milestone order: tools on the demo -> Genomics England lists (archive first; archive of the 2021
   lists already in gmicklem/historic_artefacts) -> full build on the DBCLS server.

**DBCLS server (dx):** CentOS 7, kernel 3.10, bare metal with KVM, 251 GB RAM, Docker 20.10.20, glibc
2.17, root 861 GB (192 GB free), Docker data dir not at /var/lib/docker. sbx and Claude Code cannot run
on the bare host (glibc); use an Ubuntu 24.04 container there, or DBCLS upgrades the OS (then sbx works).
Only one orchestrator session at a time (beads is single-writer).

**Why:** this is the agreed hand-over point; Gos wants the testbed epic in a fresh session.
**How to apply:** follow the list; do not re-derive the ten decisions. Related: [[intermine-maintenance-sprint]],
[[registry-and-dependabot-state]], [[gos-working-preferences]].
