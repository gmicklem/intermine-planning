---
name: next-session-handover
description: "State of epic im-9n4 (hybrid HumanMine testbed) at 18 Nov 2026 ~11:00 UTC: milestones 1 and 2 built on the ut demo; what waits on Gos; how to restart the demo"
metadata:
  type: project
---

**State (18 Nov 2026, ~11:00 UTC; LOG.md checkpoint 26):** milestone 1 (tools on the demo) is built and
gated, milestone 2 (Genomics England lists) is applied on the demo. Heads: rdfc2im
maint/im-ore.1-intermine-src c78b0f1 (make test 483/59, test-live 59/59; no CI workflow, local gate
only), mine-tests maint-2026 bf6c391, humanmine-bio-sources maint-2026 d67fc5d. rdfc2im task branches
are cut from maint/im-ore.1-intermine-src (it has no maint-2026).

**Rebuild / restart the hybrid demo (ut, 6.0.0, :18090):**
`bash repos/.sandbox-disk/rdfc2im/drive-ut-hybrid.sh` (offline from cache, about 24 min, 1.12 M objects,
all 64,470 human genes, 16 stock sources, report layout, 438 public lists). Front (nginx :15001, jar
:15011, aligner, JBrowse 2): `worktrees/rdfc2im/im-ore.1-intermine-src/trial/front/up.sh`. Other demos:
/home/agent/taskhomes/im-bg-serve/README.txt. After a sandbox restart the 5.1.1 mine container may need
`docker restart rdfc2im-mine` then `rdfc2im-bluegenes` (it starts before Postgres is ready).
Milestone gate: `pytest tests/browser --mine local-hybrid --browser chromium -rfs` in mine-tests
(10 pass / 1 fail / 1 skip; the failure is three ArrayExpress tools needing E-MTAB-62).

**Waiting on Gos (asked 18 Nov, unanswered when the session paused):** E-MTAB-62 copy or record the
three ArrayExpress tools as compare_exceptions; upload of three release tarballs in repos/rdfc2im/
(cached_raw_data-2026-11-18b, stock_filtered-2026-11-18, cached_raw_data_allgenes-2026-11-18);
MSA viewer Swiss-Prot only or all proteins (im-9n4.32); Orphanet diseases with HPO annotations;
2021 names kept for the 17 renamed PanelApp panels (assumed); network allows for download.rgd.mcw.edu
(im-9n4.35) and prod-media-panelapp.genomicsengland.co.uk (PanelApp terms; cache is marked
non-redistributable); check of rdfc2im/data/hpa_tissue_to_organ.tsv (hand-written); T1.14 public
aligner needs his DBCLS access; T2.5 ask Genomics England; go-ahead for milestone 3 (full build on DBCLS).

**Sandbox limits seen:** still 16 GB RAM (not 75%), no swap; integrate needs --no-daemon per source
(already in full-build with --gene-identifiers all). Root disk 20 GB, about 3 GB free: each build
worktree copies in/ and out/ (about 600 MB); remove worktrees after merging.

**Why:** hand-over point for the next orchestrator session. **How to apply:** read LOG.md checkpoints
23 to 26 and docs/EXPERT_TO_CHECK.md entries 7 to 11 first; do not start milestone 3 without Gos.
Related: [[intermine-maintenance-sprint]], [[worker-permission-prompt-hang]], [[gos-working-preferences]].

**EMBARGOED ITEM (bead im-ct0), until Monday 7 December 2026.** These notes are copied hourly to a PUBLIC
repository: write NOTHING about the item here, in beads, LOG.md, STATUS or in commit messages on pushed
branches. Everything is in `repos/.sandbox-disk/embargo/im-ct0/`, a checkout of a private repository:
read `RESTART-PROMPT.md`, `ORCHESTRATOR-NOTES.md` and `RUNBOOK-for-Gos.md` there first. Gos has given one
narrow permission connected with it, recorded in those files; the general rule (never push to intermine/*
or intermineorg/*) is otherwise unchanged. Never send unusual requests to a hosted mine. Several local
branches in repos/intermine must never be pushed: the private notes list them.
(20 Nov 2026: an earlier version of this note said more than it should have and was public for about 14
hours; it was reduced to this text. Do not restore the old wording.)
Gos (20 Nov 2026): no sandbox recreation for now (keeps 16 GB; dedicated hardware planned later). A fresh
conversation in the SAME sandbox is fine at any time to cut token use: a restart prompt is kept at
`repos/.sandbox-disk/embargo/im-ct0/RESTART-PROMPT.md` (update it before he uses it); sandbox commands
are in docs/SANDBOX-PORTS.md and docs/SANDBOX-NETWORK.md; access record in docs/PROJECT-ACCESS.md.
ut demo state, 20 Nov 2026 05:30 UTC: rebuilt with six new stock sources (protein2ipr, interpro, mgi-alleles,
pubmed-gene, humanmine-static, update-data-sources), the corrected cited-PMID set and the Protein.organism
priority fix; 1,222,869 objects; test-live 69 passed 2 skipped; mine-tests as baseline. Driver pair to use
now: `.sandbox-disk/rdfc2im/drive-ut-9n427.sh` + `fb-env-ut-9n427.sh`; cache
`repos/rdfc2im/cached_raw_data.remaining-2026-11-20`; rdfc2im integration tip 9f50411868 (pushed).
update-publications and entrez-organism wait on `sbx policy allow network eutils.ncbi.nlm.nih.gov`.
After a laptop sleep the ut mine's database connections go stale: `docker restart rdfc2im-ut-mine`.
20 Nov 2026 07:00 UTC, LOG checkpoint 28 written. ut demo rebuilt again on the fixed converters: driver pair
is now `drive-ut-9n450.sh` + `fb-env-ut-9n450.sh`; its InterMine source is a LOCAL-ONLY worktree,
`worktrees/intermine/local-ut-build-src` (NEVER push it; see the private notes for what it is and how to
refresh it).
rdfc2im integration tip cc1d6405c6; intermine maint-2026 b81dbfd8e5; humanmine-bio-sources 1d36e19; humanmine
d877a36. Trap: `trial_home_ut/humanmine-bio-sources` is a persistent copy the driver does not refresh.
Open with Gos: eutils host; DepMap terms; im-9n4.52; Pfam/PFAM case; Ensembl at full scope.
