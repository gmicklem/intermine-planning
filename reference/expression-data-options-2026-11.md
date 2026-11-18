# Human expression data for a rebuilt HumanMine: options (November 2026)

Task im-9n4.47. Research only: no code was changed. Written 18 Nov 2026.
Every "latest release" fact gives the date it was checked (18 Nov 2026 unless stated). "Unverified" means I could not read it at the source.

## 1. Summary and recommendation

**The problem.** Three gene-page tools need `AtlasExpression.pValue` and `tStatistic`. Today only E-MTAB-62 supplies them. E-MTAB-62 is 2010 Affymetrix data. It was loaded as JSON from the Gene Expression Atlas API, and that API is retired. The tools are the two ArrayExpress visualizers (disease, tissue) and the box-swarm plot. On public HumanMine this data set is 6,279,840 rows for 11,624 genes, about 540 rows per gene.

**(a) Load now (minimal, robust set).** All of these have public, maintained bulk files.

| Data set | Status | Work |
|---|---|---|
| GTEx **v11** median TPM per tissue | replaces v8 | drop-in: the current `gtex` converter already reads the same GCT format |
| HPA **v26.0** RNA tissue consensus (nTPM) and IHC (`normal_ihc_data.tsv`) | keep, refresh | none: the converters already accept the current file names |
| E-MTAB-513 (Illumina Body Map) from the Expression Atlas FTP site | keep | none. The heat-map tool has a tab that selects it by name. |
| **Expression Atlas differential contrasts, human** (1,528 experiments, 4,315 contrasts; log2 fold change, adjusted p-value, and a moderated t-statistic for microarrays) | **new**: the successor to the E-MTAB-62 disease rows | new converter (moderate work) |
| HPA **single cell type** (nCPM, 155 cell types) | new, optional in the first build | small converter; it needs its own class (see section 6) |

**(b) The three ArrayExpress tools.**
- **Disease tool and box-swarm plot:** feed them from the Expression Atlas differential contrasts. Load one `AtlasExpression` row per gene per contrast. Set `type`, `condition` = the contrast name, `expression` = UP/DOWN/NONDE, `pValue` = adjusted p-value, and a new attribute `log2FoldChange`. Then make a small tool change: plot log2 fold change instead of the t-statistic, because RNA-seq contrasts (DESeq2) have no t-statistic. Without that change, the tools work only for the microarray contrasts (limma gives a t-statistic).
- **Tissue tool (`organism_part`):** retire it. Its statistic was "this tissue against all other samples in one big atlas". No maintained resource publishes that statistic. The baseline tissue data (GTEx, HPA, Body Map) is already shown by the working heat-map tool.
- **Do not rebuild E-MTAB-62.** Its normalised matrix is still on the EBI FTP site (884 MB, 2012). We could recompute the t-tests ourselves, but that freezes 2010 microarray data and makes us the maintainer of a home-made statistic.

**(c) Worth a later look.** HPA immune cells, brain regions and cell lines; HPA cancer and pathology files, which include TCGA-derived prognostic p-values; GTEx eQTL eGenes (v11); Bgee (CC0, also on RDF Portal); the Single Cell Expression Atlas and CELLxGENE Census.

**RDF Portal.** Of the expression resources, only **Bgee** is current there: version 15.2.3, updated 2026-07-21, CC0. The Expression Atlas graph on `rdfportal.org/ebi/sparql` is an old snapshot. It has E-MTAB-5214 (GTEx 53 tissues) but lacks E-GTEX-8 and the 2025 experiments. RefEx is dated 2017. So for expression, RDF Portal is not the route, except possibly for Bgee.

## 2. Candidates compared

| Resource | Maintainer | Latest release (checked 18 Nov 2026) | Measures | Conditions | Per-gene summary file | Gene ID | Licence (at source) | SPARQL | Verdict |
|---|---|---|---|---|---|---|---|---|---|
| GTEx | GTEx Consortium (Broad, NIH Common Fund) | v11: analysis date 2025-08-22, files uploaded 2026-01-15 (v10: 2024-08-06) | bulk RNA-seq baseline, TPM; eQTL | 54 tissues + 14 LCM pilot sub-tissues (68 columns) | `..._v11_RNASeQCv2.4.3_gene_median_tpm.gct.gz`, 10.1 MB | versioned Ensembl/GENCODE (`ENSG…​.25`) | unverified: gtexportal.org was blocked | no | **serious: load** |
| Human Protein Atlas | KTH / SciLifeLab | v26.0, 2026-11-11 | RNA consensus tissue (nTPM), IHC protein, single cell type (nCPM), immune cells, brain, cell lines, cancer | 51 tissues; 155 cell types; 19 immune cells; 20 IHC cancers; 21 TCGA cancers | `rna_tissue_consensus.tsv.zip` 5.3 MB; `rna_single_cell_type.tsv.zip` 16.4 MB; `normal_ihc_data.tsv.zip` | Ensembl (unversioned) | CC BY 4.0 | rdf-config model only (v25.1); no endpoint found | **serious: load** |
| Expression Atlas (bulk) | EMBL-EBI | experiments.json 2026-08-19; gxa-studies.yaml dated 2026-10-01 | baseline (TPM/FPKM) and **differential** (log2FC, adjusted p, t for microarrays) | human: 1,528 differential experiments with 4,315 contrasts; 47 RNA-seq baseline experiments | per experiment: `*-analytics.tsv`, `*-configuration.xml`; baseline `*-tpms.tsv` | Ensembl (unversioned) | CC BY 4.0 | stale snapshot on rdfportal.org/ebi | **serious: load the differential contrasts** |
| Bgee | SIB | 15.2.5 per homepage (unverified); RDF Portal 15.2.3, updated 2026-07-21 | present/absent calls with an expression score and FDR, per anatomical entity and stage | many (Uberon/CL); human count unverified | call files at bgee.org/ftp (blocked) | Ensembl | CC0 (RDF Portal metadata) | yes: rdfportal.org/sib/sparql, bgee.org/sparql | later look |
| RefEx | DBCLS | 2017 (RDF Portal) | CAGE (FANTOM5) and GeneChip reference expression | about 40 tissue classes | RDF only | RefEx/probe IDs | CC BY 4.0 | yes (primary) | not a candidate: out of date |
| FANTOM5 CAGE | RIKEN | not checked; 2014–2017 data | CAGE baseline | 46 tissues in HPA's copy | via HPA `rna_tissue_fantom.tsv.zip` or Atlas E-MTAB-3358 | Ensembl in those copies | HPA: CC BY 4.0 | via RefEx (old) | not a candidate: frozen, and already inside HPA consensus |
| Single Cell Expression Atlas | EMBL-EBI | `sc_experiments/` updated 2025-09-23 | single-cell, per experiment | per experiment | per experiment (not checked) | Ensembl | CC BY 4.0 (assumed same as bulk; unverified) | no | later look |
| CELLxGENE Census / Tabula Sapiens | CZI / Biohub | weekly builds, long-term releases every 6 months (secondary source) | single-cell counts | thousands of cell types | no per-gene summary file found | Ensembl | CC BY 4.0 (AWS registry; secondary) | no | later look; heavy |
| DepMap / CCLE | Broad | 26Q1 announced (forum; secondary) | cell-line RNA-seq | about 1,000+ cell lines | expression matrix (not checked) | Ensembl/symbol | CC BY 4.0 per secondary sources; unverified (depmap.org blocked) | ccle rdf-config model exists | keep the existing loader; outside this question |
| TCGA / GDC, cBioPortal | NCI / MSK | not checked | tumour RNA-seq | 33 cancers | per-sample only | – | GDC open tier (not checked) | tcga rdf-config model (files metadata) | not now: use HPA's cancer files instead |
| ENCODE | ENCODE DCC | not checked | cell lines, some tissues | – | per-experiment only | – | – | – | not a candidate: no gene-level atlas file |

Sources: GTEx bucket listing `https://storage.googleapis.com/storage/v1/b/adult-gtex/o?prefix=bulk-gex/v11/`; HPA `https://www.proteinatlas.org/about/releases`, `/about/licence`, `/humanproteome/tissue/data`, `/humanproteome/cancer/data`; Atlas `https://ftp.ebi.ac.uk/pub/databases/microarray/data/atlas/`, `https://www.ebi.ac.uk/gxa/licence.html`; RDF Portal `https://rdfportal.org/datasets/`.

## 3. Serious candidates

### 3.1 GTEx
- Files are in a public Google bucket: `https://storage.googleapis.com/adult-gtex/bulk-gex/<version>/rna-seq/`.
  - v8 median: 6.95 MB.
  - v10 median: 8.85 MB, last modified 2024-08-06, 59,033 genes.
  - v11 median: `GTEx_Analysis_2025-08-22_v11_RNASeQCv2.4.3_gene_median_tpm.gct.gz`, 10.13 MB, uploaded 2026-01-15, 74,628 genes.
- **v8 → v10/v11, what changed:** more genes (newer GENCODE), and 14 extra columns from a laser-capture-microdissection (LCM) pilot (for example `Liver_Hepatocyte`, `Pancreas_Islets`, `Colon_Transverse_Mucosa`). The format is the same GCT 1.2 file with versioned gene IDs.
  - The gene count in the v11 median file is my own count. The GENCODE version (v47 for v11, v39 for v10) is from a secondary page, unverified.
  - The v11 README for 2026-05-19 says those newer files exclude LCM samples. The median file is still the 2025-08-22 one, which includes LCM.
  - Decision needed: load all 68 columns, or only the 54 standard tissues.
- The PAX6 values are close in v10 and v11 (cerebellar hemisphere 40.6 against 41.2 TPM). PAX6 is used as a spot check.
- **eQTL:** v10 and v11 `GTEx_Analysis_v1x_eQTL.tar` are 2.6 GB and 3.3 GB. Per the v11 README (`bulk-qtl/v11/single-tissue-cis-qtl/README_eQTL_v11.txt`):
  - eGenes are in `*.eGenes.txt.gz` (one row per gene and tissue, with q-value).
  - Significant pairs are now in `*.signif_pairs.parquet`.
  - The current `gtex` converter parses a 12-column text "signif" file, so the eQTL part needs rework. The expression part needs none.
- Loader work: none for expression (the file-name match is `gene_median`, and the header test accepts `Name`). Rows in a full mine: up to about 60,000 resolved genes × 54 tissues ≈ 3.2M rows; with LCM, 68 tissues.
- Risks: the licence and terms text could not be read (gtexportal.org was blocked). The bucket path has been stable from v3 to v11.

### 3.2 Human Protein Atlas (v26.0, 2026-11-11)
- Release notes (`https://www.proteinatlas.org/about/releases`):
  - v26.0 moved immune cell data to a separate Immune Cell resource.
  - It added basophils and bone marrow MSCs to single cell.
  - QC removed IHC data for 2,050 genes.
- Licence, quoted: "The Human Protein Atlas is licensed under the Creative Commons Attribution 4.0 International License" (`https://www.proteinatlas.org/about/licence`). The page also requires a citation and a link wherever the data are shown.
- Files counted on 18 Nov 2026 (all `https://www.proteinatlas.org/download/tsv/…`, last modified 10 Nov 2026):
  - `rna_tissue_consensus.tsv.zip`: 1,026,292 rows, 20,162 genes, 51 tissues; columns Gene, Gene name, Tissue, nTPM.
  - `rna_single_cell_type.tsv.zip`: 3,107,242 rows, 20,162 genes, 155 cell types; nCPM.
  - `rna_immune_cell.tsv.zip`: 383,078 rows, 19 immune cells; TPM, pTPM, nTPM.
  - `rna_brain_region_hpa.tsv.zip`: 2.1 MB.
  - `rna_celline.tsv.zip`: 206 MB, 1,206 cell lines (last modified 2025-11-05).
  - `cancer_data.tsv.zip`: 1.5 MB, IHC in 20 cancers.
  - `cancer_prognostic_data.tsv.zip` (log-rank p-values, 21 TCGA cancers).
  - `rna_cancer_sample.tsv.gz` (pTPM per TCGA sample, 8,383 samples). Not size-checked.
- The old names `normal_tissue.tsv.zip`, `pathology.tsv.zip` and `rna_cancer_sample.tsv.zip` now return 404. Our converters already accept `normal_ihc_data.tsv`.
- Loader work: none for consensus and IHC. Single cell type needs a small new converter, or an extension of `protein-atlas-rna` (section 6).
- Risks: HPA renames files between versions (it did so in 2025–2026), so pin the version and check the names at each release. The rdf-config `hpa` model describes v25.1 specificity and nTPM/nCPM, but no SPARQL endpoint for it was found.

### 3.3 Expression Atlas (EMBL-EBI): differential experiments
- Licence, quoted: "We are applying the Creative Commons Attribution 4.0 International License for all copyrightable material on our website" (`https://www.ebi.ac.uk/gxa/licence.html`). The citation it asks for is the NAR 2026 Expression Atlas paper.
  - Note: the README in `atlas-express/src/test/resources/upstream/` says "EMBL-EBI terms of use". It should say CC BY 4.0.
- Index: `https://ftp.ebi.ac.uk/pub/databases/microarray/data/atlas/experiments.json` (2.6 MB, modified 2026-08-19) lists 4,562 experiments; 1,651 are human:
  - microarray differential: 1,107
  - RNA-seq differential: 411
  - RNA-seq baseline: 47
  - proteomics: 80
- `gxa-studies.yaml` (dated 2026-10-01) lists 4,315 contrasts in the 1,528 human differential experiments.
  - Contrast factors include disease (369 experiments), compound (363), genotype (192), time (183), cell type (84) and organism part (49).
  - 1,076 of the experiments carry a disease annotation.
- Per-experiment files (examples read with byte ranges):
  - `E-GEOD-100833_A-GEOD-13158-analytics.tsv` (microarray). Columns: Gene ID, Gene Name, Design Element, then for each contrast `gX_gY.p-value`, `gX_gY.t-statistic`, `gX_gY.log2foldchange`. The methods file says: "Moderated t-statistics computed with limma … p-values adjusted using Benjamini & Hochberg (1995) FDR correction … significant differential expression called if adjusted p <= 0.05".
  - `E-GEOD-101794-analytics.tsv` (RNA-seq, DESeq2). Only `p-value` and `log2foldchange`; **no t-statistic**.
  - `*-configuration.xml`. Gives the human-readable contrast name, for example "'Crohn's disease' vs 'non inflammatory bowel disease control' in 'A1a Paris classification'", and the reference and test groups.
  - There is no "all analytics" file. The `indices/by-file-type/` directory has only `sdrf/` and `tpms/`. A loader must fetch about 1,528 analytics files and 1,528 configuration files.
  - Total download size: unverified. The examples are 2.9 MB (RNA-seq) and larger for multi-contrast microarrays; my guess is a few GB.
- Rows in a full mine:
  - All genes × all contrasts ≈ 4,315 × ~20,000 ≈ 86M. Too many.
  - Significant genes only (adjusted p ≤ 0.05) is perhaps 5–10%: about 4–9M rows. This is an estimate. It is the same order as today's 6.3M E-MTAB-62 rows.
- Loader work: a new converter. Read experiments.json, filter on Homo sapiens and differential, read the configuration and analytics files, and resolve Ensembl IDs.
- Risks:
  - The analytics files of some experiments were last regenerated in 2019–2022. The FTP layout has been stable since at least 2016.
  - Contrasts from different experiments are not comparable with each other. The tools must say "fold change against the study's own control".

### 3.4 Bgee (later look)
- CC0. RDF Portal lists Bgee 15.2.3, updated 2026-07-21, 6.76 billion triples, endpoint `sib`. The local rdf-config `bgee` model exposes expression level, FDR p-value, anatomical entity and stage.
- A broad query on `https://rdfportal.org/sib/sparql` timed out after 90 s, so extraction must be targeted per gene or per tissue.
- www.bgee.org is blocked from the sandbox, so file names, sizes and the human condition count are unverified. Expasy news says 15.2 (May 2024) added single-cell 10X libraries. A `bgee_v16_0` FTP path exists, but its release is unverified.
- Value: one integrated call per gene and anatomical entity, across RNA-seq, single-cell and arrays. It is the only fully open, RDF-served candidate. It does not give disease contrasts.

## 4. What E-MTAB-62 gave HumanMine

- **Loader** (`humanmine-bio-sources/arrayexpress-atlas`, `ArrayexpressAtlasConverter.java`):
  - It reads Atlas API JSON: `geneExpressionStatistics → arrayDesign → genes → probes → [ {ef, efv, stat{expression, pvalue, tstat}} ]`.
  - It keeps `ef` in {organism_part, disease_state, cell_type} and drops `cell_line`.
  - It skips expression "NA" and pValue > 1, and rounds tStatistic to one decimal place.
  - It stores `type` = ef, `condition` = efv, `expression` = UP/DOWN/NONDE, `pValue`, `tStatistic`.
- **Meaning:** each condition was tested against all other samples of the same factor in the one 5,372-sample U133A atlas. This was the old Gene Expression Atlas one-against-rest test. So t > 0 with UP means "higher in this tissue or disease than in the rest of the atlas". It is a specificity score, not a disease-against-healthy contrast.
- **Public HumanMine** (5 read-only requests, 18 Nov 2026):
  - DataSet `arrayexpress-atlas`, description "E-MTAB-62: Human gene expression atlas of 5372 samples representing 369 different cell and tissue types, disease states and cell lines", version "June 2011". It has 6,279,840 rows for 11,624 genes.
  - There are 0 rows with type `cell_type`; only `organism_part` and `disease_state` are present.
  - PAX6 has 376 rows: 16 `FPKM value` (E-MTAB-513) and 360 from E-MTAB-62. The 360 split into 231 disease_state conditions (24 UP, 30 DOWN, 177 NONDE) and 129 organism_part conditions (18 UP, 42 DOWN, 69 NONDE).
  - The conditions are free text, often duplicated or misspelt: "cololrectal tumor", "septic arthiritis", "brain" and "brain cerebellum" next to "cerebellum". Some disease_state values are really cell lines ("RJ2.2.5 Burkitts lymphoma cell line").
  - Example rows:
    - brain cerebellum: UP, p = 0.0, t = 70.1
    - brain tumor: UP, p = 0.0, t = 23.2
    - eye: NONDE, p = 0.23, t = −1.7. This is odd for PAX6 and fits the "wrong-p-value" doubt; the cause is unverified.
  - Many p-values are exactly 0.0.
- **Is it still obtainable?**
  - The ArrayExpress legacy FTP site still serves `https://ftp.ebi.ac.uk/pub/databases/microarray/data/experiment/MTAB/E-MTAB-62/`, dated 2012-01-31. It holds the IDF, the SDRF (3.2 MB), 121 raw CEL zip files (about 150 MB each), and `E-MTAB-62.processed.2.zip`. The processed file is 926,704,898 bytes and holds the RMA matrix `hgu133a_rma_okFiles_080619_MAGETAB.csv` named in the SDRF.
  - BioStudies has the study with 5,372 raw files plus IDF and SDRF only (`https://www.ebi.ac.uk/biostudies/api/v1/studies/E-MTAB-62/info`).
  - The SDRF has the groupings (4, 15, 96 and 369 meta-groups, OrganismPart, DiseaseState, CellType, CellLine), so the one-against-rest tests could be recomputed.
  - E-MTAB-62 is **not** in the current Expression Atlas: it is absent from experiments.json, and `https://www.ebi.ac.uk/gxa/experiments/E-MTAB-62/Results` returns 404. The per-gene statistics are therefore published nowhere.
  - The paper (Lukk et al., Nat Biotechnol 28:322, 2010, doi:10.1038/nbt0410-322) has only a PDF supplement (text, figures, methods). No statistics tables were seen; this was checked via a search summary only, so it is unverified.

## 5. Fit to the tools

All seven upstream repositories are in `intermine/` on GitHub. None is archived and none has had a commit since August 2021 (`gh api repos/intermine/<name>`, 18 Nov 2026).

| Tool (last commit) | Data it reads | Fed with no change | Small change | Not at all / note |
|---|---|---|---|---|
| disease-expression-arrayexpress (2020-06-23) | `atlasExpression` with type = `disease_state` and expression ≠ NONDE; bar = `tStatistic`, colour = UP/DOWN, hover shows t and p | Atlas microarray contrasts (they have a t-statistic) | plot `log2FoldChange` when there is no t, and label p as "adjusted p" → all 4,315 contrasts | – |
| tissue-expression-arrayexpress (2020-06-23) | the same, type = `organism_part` | nothing current has one-against-rest tissue statistics | could plot a derived GTEx z-score, but that is our own statistic | **retire**; the heat map covers baseline tissues |
| expression-box-swarm (2020-07-10) | all `atlasExpression` ≠ NONDE; box of `tStatistic` for organism_part and disease_state | Atlas microarray contrasts | as for the disease tool (log2FC) | its organism_part box goes empty unless something is loaded with that type |
| human-tissue-expression heat map (2021-08-03) | `rnaSeqResults` (all), `rnaSeqResults` with dataSet "Protein Atlas RNA Gene data", `atlasExpression` with dataSet "E-MTAB-513" | GTEx v11, HPA v26 consensus, E-MTAB-513 | – | **risk:** the GTEx tab reads *all* `RNASeqResult` rows. Putting HPA single cell into `RNASeqResult` would pollute it. |
| protein-atlas-tissue-expression (2020-06-23) | `proteinAtlasExpression` tissue, tissueGroup, cellType, level, reliability | HPA v26 `normal_ihc_data.tsv` | – | – |
| protein-tissue-localisation (2021-08-03) | `ProteinAtlasExpression` | HPA v26 IHC | – | – |
| tissue-expression-visualizer (2021-05-27) | `microArrayResults` of type `FlyAtlasResult`, `rnaSeqResults.stage` | – | – | FlyMine tool (FlyAtlas); not relevant to HumanMine |

Model consequence of the recommendation:
- Add `log2FoldChange` (Double) and perhaps `experiment`/`contrast` (String) to `AtlasExpression`. Keep `pValue` (it now means the adjusted p-value; document this).
- Keep `tStatistic` (filled only for microarray contrasts).
- For `type`, map the Atlas contrast factor: `disease` → `disease_state`, so the tools still match. Other factors (compound, genotype) are either left out or get their own type value.

## 6. Recommendation: details per data set

| Data set | Loader work | Rows in a full HumanMine | Risks |
|---|---|---|---|
| GTEx v11 median TPM | none (existing `gtex`); decide on the LCM columns; eQTL part needs parquet/eGenes rework | ~3.2M (54 tissues) to ~4M (68) | licence text unverified (portal blocked) |
| HPA v26 consensus + IHC | none | ~1.03M (consensus) + IHC (not counted) | file renames between versions |
| E-MTAB-513 | none (existing `atlas-express`) | ~0.9M (about 56,000 genes × 16; estimate) | static (2014 data, files last regenerated 2021-12-14) |
| Expression Atlas human differential contrasts | new converter; small change to the disease and box-swarm tools | ~4–9M if only significant rows (estimate) | many independent studies, so values are not comparable; about 3,000 file fetches per refresh |
| HPA single cell type (later in the first build, or the next one) | small converter. Store it in a new class (for example `SingleCellExpression(cellType, nCPM)`) or teach the heat map to filter `RNASeqResult` by data set. | 3.1M | the heat-map pollution risk above |

Not recommended: rebuilding E-MTAB-62; RefEx and the Expression Atlas RDF on RDF Portal (both stale); CELLxGENE now (no per-gene summary file found, very large).

## 7. Open questions

1. GTEx v11 terms of use and citation text: read gtexportal.org once it is allowed.
2. Load the 14 GTEx LCM pilot sub-tissues or not.
3. Which Atlas contrast factors to load: disease only (closest to E-MTAB-62), or also compound, genotype and others. And the significance cut-off (adjusted p ≤ 0.05; perhaps |log2FC| ≥ 1).
4. Owner of the small change to the disease and box-swarm tools (upstream is dormant; fork it under the project?).
5. Bgee human file layout and the 16.0 status (www.bgee.org blocked).
6. DepMap licence at source (depmap.org blocked).
7. The exact cause of "wrong-p-value" in the private E-MTAB-62 copy (not examined; the copy was not read).

## 8. Blocked hosts

| Host | What I wanted | Command for the host |
|---|---|---|
| gtexportal.org | release notes (v10, v11), data-use and citation terms, dataset metadata API | `sbx policy allow network gtexportal.org` |
| www.bgee.org | download page, FTP listing for human call files, licence page, SPARQL | `sbx policy allow network www.bgee.org` |
| depmap.org | current release and licence of DepMap expression files | `sbx policy allow network depmap.org` |

All three returned "Approval required for <host>" to curl, so a pending approval may be waiting: `sbx policy approval ls`. WebFetch (outside the sandbox) also got HTTP 403 from gtexportal.org, www.bgee.org and depmap.org; those sites appear to refuse automated fetches as well.

Requests to public HumanMine: 5.
