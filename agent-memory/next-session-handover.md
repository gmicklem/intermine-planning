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
