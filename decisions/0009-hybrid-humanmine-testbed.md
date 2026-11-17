# 0009: Hybrid HumanMine testbed (RDF-portal + original loaders): the ten decisions

Status: accepted (Gos, 17 Nov 2026, in conversation). Plan: plans/50-hybrid-humanmine-testbed.md
(epic im-9n4). Production host facts: HumanMine/FlyMine run as Docker containers on the DBCLS
server (133.39.78.111, CentOS 7, 251 GB RAM, KVM, Docker 20.10); the sandbox cannot do a full build.

| # | Decision | Chosen |
|---|---|---|
| D-1 | Meaning of the gene subset | All human genes as identifiers; deep annotation only for the panel genes |
| D-2 | Locations, gene models, GO for milestone 1 | Stock loaders (ncbi-gff, go-annotation) now; RDF route (im-ore.18) later when it matches |
| D-3 | Tool order | Protein viewer, alignment viewer, JBrowse 2, then Cytoscape, then the expression tools |
| D-4 | Fixture genes | Add PAX6 and the other mine-tests fixture genes to the demo panel; regenerate the CI data asset |
| D-5 | Stacks | 5.1.1 (:8090) stays the RDF-only baseline, unchanged; the hybrid is built on the 6.0.0 ut stack (:18090) only |
| D-6 | UniProt scope | Swiss-Prot plus splice variants only; TrEMBL comes from RDF-portal |
| D-7 | Restricted data (OMIM, DisGeNET, KEGG) | Only from Gos's local copies; never in the CI release asset; skipped on CI |
| D-8 | Genomics England lists | All current PanelApp panels, Green genes, panel version recorded; archive the previous lists in gmicklem/historic_artefacts before every refresh (done 17 Nov for the 2021 set) |
| D-9 | Full build host | The DBCLS server, not the sandbox; Claude Code there runs in an Ubuntu 24.04 container until the OS is upgraded (sbx needs Ubuntu 24.04+; KVM is present) |
| D-10 | Sandbox network allows | Approved in principle; Gos runs the allow command for the data hosts listed in the plan's section 3 (recorded in docs/SANDBOX-NETWORK.md) |

Milestone order: 1 tools on the demo (44-53 agent-hours) -> 2 Genomics England lists (6-8) ->
3 full build on the DBCLS server (32-38). Related: [[0008-registry-rewrite]], plans/30-testbed.md.
