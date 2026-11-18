# Things to investigate

Questions that need research before anyone can decide or build. This is not the task list (that is
beads) and not the review queue for changes already made (that is `EXPERT_TO_CHECK.md`). An entry
belongs here when the next step is to find something out.

How to use it:

- Add an entry when a question comes up that nobody can answer yet. Give it the next free number.
- Each entry says what the question is, why it matters, what is already known (with where that came
  from), and what a good answer would contain.
- When someone starts on it, file a bead and write its id on the entry.
- When it is answered, move the entry to "Answered" at the bottom with the date, the answer in two or
  three lines, and where the detail is (a decision file, a bead, a commit). Do not delete entries.

Status words: **open** (nobody is on it), **in progress** (bead named), **answered**.

## Open

### 1. Is there more recent expression data that should replace E-MTAB-62 and E-MTAB-513? (Gos, 18 Nov 2026)

- **Status:** open.
- **Question:** which current, maintained human expression data sets should a rebuilt HumanMine load,
  and can they drive the gene-page expression tools?
- **Why it matters:** three tools on HumanMine's gene page (the ArrayExpress disease and tissue
  expression visualizers and the box-swarm plot) need p-values and t-statistics from E-MTAB-62, a 2011
  data set from a retired service; the only copy is Gos's (`/micklem/data/metabolic/array-express/
  E-MTAB-62-wrong-p-value/`). The demo excuses those three tools for now (mine-tests
  `compare_exceptions`). The Illumina Body Map data (E-MTAB-513) is from 2014.
- **Known:** the demo already loads GTEx v8 median TPM and Human Protein Atlas RNA consensus (2026
  files). GTEx v10 exists (format unverified; eQTL files possibly parquet). Expression Atlas still
  serves baseline and differential experiments. Bgee and RefEx are in RDF Portal (plan 50, section 1.2).
  Gos expects that more recent expression data is available.
- **A good answer:** a short list of candidate data sets (source, release date, licence, size, whether
  differential or baseline, whether RDF Portal has them), what each tool's query needs, and a
  recommendation: load new data and adapt the tools, or retire the three tools.

### 2. Why does PAX6 have 5 pathways on the demo and 10 on HumanMine?

- **Status:** open.
- **Known:** both come from Reactome through UniProt2Reactome; the demo uses the lowest-level file
  (BUILD.md has an "all levels" option). HumanMine's data are Reactome 79 (2022). Nobody has compared
  the two pathway lists.
- **A good answer:** the two lists side by side and the reason (levels option, release, or loader).

### 3. Why does PAX6 have 57 GO annotations on the demo and 79 on HumanMine?

- **Status:** open.
- **Known:** the current GOA file holds exactly 57 distinct GO terms for PAX6 (T1.6). The worker's
  explanation, an older GOA release on HumanMine, was not checked. HumanMine may also count
  annotations rather than distinct terms, or include annotations inherited through InterPro.
- **A good answer:** what HumanMine's 79 are made of.

### 4. PanelApp: the Acknowledgements page and written consent

- **Status:** open (to raise with Genomics England together with T2.5, bead im-9n4.24).
- **Known:** the Terms of Use (December 2019) require acknowledging Genomics England and "any
  identified contributors" and point to an Acknowledgements page that could not be found on the site.
  They allow downloading extracts and bar commercial use; they do not clearly allow redistributing
  whole panels, so the cached panel JSON is marked non-redistributable. The gene lists in the mine
  carry an attribution and a non-commercial notice.
- **A good answer:** Genomics England's confirmation that publishing Green-gene lists in a public mine
  with that attribution is acceptable, the wording they want, and whether they would publish panels
  in a versioned repository.

### 5. `/service/ids` gives no answer for HGNC:12530 (UGT1A1)

- **Status:** open.
- **Known:** the mine holds `HGNC:12530` as a synonym of UGT1A1, but the id-resolution service returns
  neither a match nor "unresolved" for it (T2.2). The Ensembl fallback covers the PanelApp lists.
  UGT1A1 shares exons with the other UGT1A genes, and the gene-id lookup cache once picked the wrong
  Ensembl id for it.
- **A good answer:** the cause, and whether other genes are affected silently.

### 6. What did HumanMine do with IntAct negative interactions and with complexes?

- **Status:** open.
- **Known:** neither interaction converter reads the negative flag; the demo's filter drops 923
  negative records, and trims records with more than two participants (EXPERT_TO_CHECK entry 10).
- **A good answer:** what the 2022 HumanMine load contains for a known negative interaction, and
  whether the converters should model negatives.

### 7. Where did `tissue_to_organ.tsv` and `pubmed_cited` come from?

- **Status:** open (low priority: the demo no longer depends on either).
- **Known:** the Protein Atlas converter's comment calls the tissue file "homebrew"; no source in any
  repository. Gos reviewed and accepted the replacement grouping on 18 Nov 2026 (Retina under Brain).
  `pubmed_cited`, which the OMIM loader requires, is not an OMIM product.

## Answered

(none yet)
