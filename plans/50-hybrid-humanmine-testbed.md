# 50 - Hybrid HumanMine testbed: rdfc2im plus the HumanMine bio-sources

Epic **im-9n4**. Planning document only (17 Nov 2026). Nothing here has been built.

**Goal (Gos).** rdfc2im builds a HumanMine subset from RDF Portal. It does not yet support the
gene report page tools that HumanMine has: JBrowse 2, the PDB/protein structure viewer, the
alignment viewer and the others. The aim is a hybrid build:
- take as much as possible from RDF Portal;
- fill the gaps with the HumanMine loaders (humanmine-bio-sources plus the generic
  intermine bio sources);
- use a gene subset by default, so test builds are fast;
- move over time towards a complete HumanMine;
- refresh the Genomics England public lists when HumanMine is rebuilt.

**How this was checked.** Everything below was read from the repositories, from the two
running demo stacks (`:8090` 5.1.1, `:18090` 6.0.0, BlueGenes with tools on `:15001`) and
with about 25 read-only requests to www.humanmine.org. Anything marked *unverified* could not
be checked from the sandbox; most data hosts are blocked (§3).

**Where the public mines run.**
- HumanMine and FlyMine run today as a set of Docker containers on a **DBCLS server**,
  `133.39.78.111` (`docs/INTERMINE_ORG_HOSTING.md`).
- An nginx reverse proxy with Let's Encrypt certificates fronts them.
- The same server also serves `jbrowse.intermine.org`.
- That container layout was the starting point for the `docker_template` repo.
- Every "HumanMine" reference below (`www.humanmine.org`, its JBrowse, its patched tools)
  is that deployment.
- Hosting rule for new services (the aligner, T1.14; the registry, which is covered
  elsewhere): they go on the same DBCLS server, behind its existing reverse proxy, by
  hostname, with no new ports.

**Correction to the brief.** `rdfc2im/tools/reduce_mine.py` does **not** choose the gene
subset. It trims HumanMine's config files (project.xml sources, priorities, webconfig,
objectstore summary) down to the classes a reduced model actually has. The subset is chosen
like this:
- `full-build.sh --genes FILE` (default `curation/demo_gene_panel.txt`, 113 HGNC symbols)
  sets the gene list.
- The `SCOPE_MODE` table in `tools/full-build.sh` gives each source a mode: `panel`, `full`,
  `pmid` or `none`.
- `gene_scope_field` in `rdfc2im/data/sources.yaml` names the field to filter on, and the
  resolvers in `rdfc2im/scope.py` turn symbols into each source's ids. Six sources have
  resolvers: ncbigene, hgnc, ensembl, uniprot, clinvar and gwascatalog.
- The filter is applied inside the SPARQL (a `VALUES` clause), so the raw data is already a
  subset when it is fetched.

---

## 1. What the demo mine has and lacks

### 1.1 The two report pages

- **HumanMine reference.** `https://www.humanmine.org/humanmine/report/Gene/1234788` is
  **PAX6** (NCBI 5080). It is served by BlueGenes at the site root (`46c4cc8`), with the tool
  store at `https://www.humanmine.org/api/tools/all`, which lists 19 tools. The page layout
  comes from the mine's `bluegenes-properties` key `layout.report` (EDN, fetched from
  `/service/bluegenes-properties`). The Gene layout is:

  | Category | Items, in order |
  |---|---|
  | Gene Ontology | `goAnnotation` (class); template `Gene_GO` |
  | Genomics | tool `bluegenesJBrowse2Tool`; `exons`, `introns`, `transcripts`, `UTRs`, `upstreamIntergenicRegion`, `downstreamIntergenicRegion` |
  | Proteins | `proteins`; tool `bluegenesProteinVisualizer`; tool `bluegenesMSAViewer` |
  | Homology | `homologues`; template `Gene_Orth2` |
  | Pathways | `pathways` |
  | Expression | `atlasExpression` with three tools (disease and tissue ArrayExpress visualizers, box-swarm); `proteinAtlasExpression` with the Protein Atlas tissue tool; `rnaSeqResults` with the Human Tissue Expression tool; template `Gene_Disease2` |
  | Interactions | `interactions`; tool `bluegenesToolCytoscape`; templates `Gene_Interact_disease`, `Gene_Interactions_forReportPage` |
  | Disease | `alleles`, `diseases`; templates `Gene_Alleles_Disease2`, `Gene_Disease2`, `Gene_Disease_HPO`, `Gene_HPOphenotype_2`, `Gene_SigSNP` |

  The page is not available in this repo; it is fetched from the mine.

- **Demo mine.**
  - Data: the 6.0.0 mine at `http://localhost:18090/humanmine` holds the 113-gene panel. PAX6
    is not in it, so the comparison gene is CYP2D6 (NCBI 1565).
  - BlueGenes: `669ae3ee` on `:15001` has 19 tools installed under
    `/home/agent/taskhomes/im-bg-serve/run/tools-15001/@intermine/`. BlueGenes 1.4.5 on
    `:5000` and `:15000` has **no tools** (`{"tools":[]}`).
  - The demo mine has **no `layout.report`**, so BlueGenes shows its default order.
  - Templates: 9 (`curation/demo_public_templates.sql`).
  - Lists: 0.
  - Widgets: 5. `go_enrichment_for_gene` is missing.

- **Tool store differences.**
  - Only HumanMine has `@intermine/bluegenes-jbrowse2-tool 0.1.0`. It is not on npm
    (registry 404); its source is `repos/jbrowse2/bluegenes-tool/`.
  - HumanMine runs hand-patched `bluegenes-protein-visualizer 2.1.1-patched.1` and
    `bluegenes-msa-viewer 2.1.1-patched.1`. The patch recipes are in `docker_template/README.md`
    ("BlueGenes tools that call dead external services") and in
    `sequence-alignment-service/README.md`.
  - Only the demo has `bluegenes-esyn-viewer`.

- **Model.** The live HumanMine model (`rdfc2im/in/humanmine_model.xml`, 170 classes) has 32
  classes the demo model (139) lacks:
  - expression: `AtlasExpression`, `ProteinAtlasExpression`, `RNASeqResult`, `Tissue`,
    `TissueGroup`, `ProbeSet`, `DepMapExpression`, `CellLine`
  - GO: `GOAnnotation`, `GOEvidence`, `GOEvidenceCode`
  - orthologues: `Homologue`, `OrthologueEvidence(Code)`
  - interactions: `Interaction`, `InteractionDetail`, `InteractionExperiment`,
    `InteractionRegion`, `InteractionTerm`, `Interactor`
  - disease and phenotype: `DiseaseAssociation`, `HPOAnnotation`, `HPOEvidence`, `HPOTerm`,
    `MammalianPhenotypeTerm`, `Genotype`
  - UniProt and domains: `ProteinDomain`, `ProteinDomainRegion`, `UniProtFeature`,
    `Component`
  - other: `DatabaseReference`, `Source`

  Fields missing from the demo:
  - `Protein`: `isUniprotCanonical`, `isFragment`, `uniprotAccession`, `canonicalProtein`,
    `isoforms`, `features`, `comments`, `components`, `interactions`,
    `proteinDomainRegions`.
  - `Gene` collections: `goAnnotation`, `homologues`, `interactions`, `atlasExpression`,
    `proteinAtlasExpression`, `rnaSeqResults`, `depMapExpression`, `diseaseAssociations`,
    `probeSets`, `SNPs`.
  - The live HumanMine model has **no `ProteinStructure` and no `Complex`**, because `pdb`,
    `psi-complexes`, `kegg-pathway` and `signor` are commented out of `humanmine/project.xml`.
    The `pdb` source code itself was deleted from intermine in 2017 (`12b341b819`).

- **Counts per gene.**

  | Collection | HumanMine PAX6 | Demo CYP2D6 | Demo whole mine |
  |---|---|---|---|
  | goAnnotation | 79 | (no class) | `OntologyAnnotation` 0, `GOTerm` 78,100 |
  | chromosomeLocation | 1 | 0 | `Location` 0 |
  | exons | 637 | 0 | |
  | transcripts | 53 | 0 | |
  | proteins | 5 | **58** (TrEMBL included, from RDF) | 13,546 proteins |
  | protein sequences | 5 | 0 | `Sequence` 0 |
  | homologues | 10 | (no class) | |
  | pathways | 10 | 6 | 2,883 pathways |
  | atlasExpression | 376 | (no class) | |
  | proteinAtlasExpression | 90 | (no class) | |
  | rnaSeqResults | 97 | (no class) | |
  | interactions | 156 | (no class) | |
  | alleles | 522 | 324 | |
  | diseases | 8 | 0 | |

  For CYP2D6 itself HumanMine has 2 proteins, 22 domain regions and 96 UniProt features.

### 1.2 Table: HumanMine report item, demo status, data needed, candidate source

The "Candidate source" column uses these keys:
- **RP-has**: RDF Portal already supplies it to rdfc2im.
- **RP-possible**: an rdf-config model exists. Configs are in
  `worktrees/rdfc2im/im-ore.1-intermine-src/in/config/`.
- **HM-bs X**: humanmine-bio-sources source X.
- **IM Y**: generic `intermine/bio/sources` source Y.
- **static**: a file or a deployment piece.

| HumanMine report item | On demo? | Data the mine needs | Candidate source |
|---|---|---|---|
| **JBrowse 2** (`bluegenesJBrowse2Tool`) | No. The tool is not installed (not on npm), and `/service/jbrowse/9606/refSeqs.json` returns 404 because chromosomes have no length | `Gene.chromosomeLocation` (Location), `Chromosome.length`, Transcript/Exon/CDS/UTR for gene models, `Chromosome.sequence` for the reference track. JBrowse 2 reads the mine live through `/service/jbrowse`. Also needs a JBrowse 2 server: `repos/jbrowse2` (docker, `:14881`) plus `config/generate.mjs` | **IM ncbi-gff** + **IM fasta** (ncbi-fasta) + postprocesses `create-chromosome-locations-and-lengths` and `transfer-sequences`. Alternative: **RP-possible** Ensembl FALDO (the `ensembl` model has `faldo:begin/end`, EnsemblTranscript, EnsemblExon); this is bead im-ore.18. Chromosome lengths are already cached (`cached_raw_data/grch38-chromosome-lengths/refSeqs.json`). Sequence is not in RDF Portal |
| JBrowse 1 (`bluegenesJBrowseTool`, installed on demo) | Shown but wrong. Its `jbrowseUrl` is HumanMine's public JBrowse 1 | Same as above | Not in HumanMine's layout; hide it, or repoint it |
| **Exons, Introns, Transcripts, UTRs, intergenic regions** | No (0) | GFF features. Introns and intergenic regions come from postprocesses (`create-intron-features`, `create-intergenic-region-features`); neither is in HumanMine's list, and PAX6 has 0 UTRs and 0 intergenic regions on HumanMine | **IM ncbi-gff** (Gene, Transcript/MRNA, Exon; no CDS/UTR handling). Alternative: **RP-possible** Ensembl transcripts/exons |
| **Proteins** collection | Yes (58 for CYP2D6, TrEMBL included) | already there | **RP-has** uniprot |
| **Protein Visualizer** (PDB) | Shown, broken in two ways: (1) its query selects `Protein.canonicalProtein.primaryAccession`, which is absent from the demo model, so 400; (2) bundle 2.1.1 calls RCSB `search.rcsb.org/rcsbsearch/v1/query`, which returns 404 (checked). v2 works: CYP2D6 P10635 returns 14 entries | `Gene.proteins.primaryAccession`, `Protein.canonicalProtein`. **PDB ids come live from RCSB in the browser; no PDB data is loaded into the mine** | **IM uniprot** (stock UniProt XML; sources.yaml already declares `uniprot: alongside: [uniprot]`), plus the static bundle patch v1 to v2 |
| **MSA Viewer** | Shown, broken in three ways: (1) selects `isUniprotCanonical` and `isFragment` (absent); (2) `sequence.residues` is empty; (3) it posts to `https://sequencealignment.apps.intermine.org`, which fails TLS from here: the name no longer serves a valid certificate, and the repo README says InterMine "no longer hosts" the service there. The mines themselves still run on the DBCLS server; only this service was not carried over. Reinstating it there is T1.14 | `Protein.sequence.residues` (canonical and isoforms), `isUniprotCanonical`, `isFragment`; an aligner | **IM uniprot** (canonical sequence) + **IM fasta** (uniprot-fasta, `uniprot_sprot_varsplic.fasta`, isoforms). **RP-possible**: UniProt `core:sequence` rdf:value. **static**: `repos/sequence-alignment-service` container plus the bundle patch to the same-origin `/align-sequence` |
| **GO Annotation** + `Gene_GO`; GO term / GO concept tools; `go_enrichment_for_gene` widget | No (`OntologyAnnotation` 0; the widget is dropped by `reduce_mine.py webconfig`) | `GOAnnotation(subject Protein/Gene, ontologyTerm, evidence)` and `GOTerm.parents` | **IM go-annotation** (GAF `goa_human`; annotates `Protein.primaryAccession`, and `GoPostprocess` copies to Gene), plus **IM interpro-go**. **RP-possible**: UniProt `core:classifiedWith` with no evidence codes (D4); bead im-ore.18 covers this route |
| **Homologues** + `Gene_Orth2` | No (no class) | `Homologue(gene, homologue, type, evidence)`; partner genes in 6 organisms | **IM panther** (RefGenomeOrthologs). Partner symbols also need **IM mgi-identifiers**, **IM rgd-identifiers**. **RP-possible**: homologene (D7 blocks it; HomoloGene has been frozen upstream since 2014), and OMA (rdf-config `oma`, own endpoint `sparql.omabrowser.org`, not RDF Portal) |
| **Pathways** | Yes (6 for CYP2D6) | already there | **RP-has** reactome + stock reactome alongside |
| **Atlas Expression** + 3 tools (`depends: AtlasExpression`) | Hidden, because the class is absent | `AtlasExpression(type, condition, expression, pValue, tStatistic)` | **HM-bs arrayexpress-atlas** (E-MTAB-62 JSON from the retired ArrayExpress Atlas API; only Gos's `/micklem` copy exists) + **HM-bs atlas-express** (Illumina Body Map, Expression Atlas E-MTAB-513). **RP-possible**: expressionatlas (D10, needs flattening) |
| **Protein Atlas Expression** + tissue tool; Protein Tissue Localisation tool | Hidden (class absent) | `ProteinAtlasExpression(level, reliability, cellType, tissue.tissueGroup)` | **HM-bs protein-atlas** (`normal_tissue.tsv`). **RP-possible**: hpa (rdf-config model only, no `endpoint.yaml`; host *unverified*) |
| **RNA-Seq results** + Human Tissue Expression tool (`depends: AtlasExpression, RNASeqResult`); Tissue Expression tool | Hidden | `RNASeqResult(expressionScore, tissue, expressionType)` | **HM-bs protein-atlas-rna** (`rna_tissue.tsv`) + **HM-bs gtex** (median TPM GCT). **RP-possible**: bgee (SIB), refex (RDF Portal) |
| **Interactions** + Cytoscape tool + 2 templates | Shown, broken: `Gene.interactions` is absent, so 400 | `Interaction`, `InteractionDetail(type, role, experiment)`, `InteractionTerm` | **IM psi** (psi-intact), **IM biogrid**, **IM psi-mi-ontology**. **RP-possible**: hint (med2rdf endpoint). IntAct is not in RDF Portal (D6) |
| **Alleles** + `Gene_Alleles_Disease2` | Yes (324 for CYP2D6) | already there | **RP-has** clinvar |
| **Diseases**, `Gene_Disease2` (OMIM) | Gene.diseases is 0; `Disease` has 818 rows, linked from alleles | `Gene.diseases` (written by hpo-annotation and omim) | **IM omim** (licence needed), **HM-bs hpo-annotation**, **HM-bs orphanet**. **RP-possible**: medgen, mondo (D5) |
| `Gene_Disease_HPO`, `Gene_HPOphenotype_2` | No | `HPOTerm`, `HPOAnnotation` | `hp.obo` is **RP-has-in-rdfc2im**: rdfc2im source `hpo` exists (scope good, replaces stock `hpo`) but is not in the demo `--sources`. Annotations come from **HM-bs hpo-annotation** |
| `Gene_SigSNP` (GTEx eQTL) | No | `SNP(pValue, tssDistance, tissue)`, `Gene.SNPs` | **HM-bs gtex** (`*signif_variant_gene_pairs*`) |
| Protein report: Protein Features (`bluegenes-protvista`) | Probably works: it needs only `primaryAccession`, and ProtVista fetches from EBI (*unverified in a browser*) | - | none |
| GWAS report: GWAS visualizer | Partly: it selects `results.marker.chromosomeLocation`, and SNP has no location | SNP Locations | im-ore.18 (SNP chromosomes) |

**Headline.** Three tools are what Gos named, and the work to make them function is smaller
than expected:

- **Protein Visualizer (PDB viewer).** It needs no PDB data in the mine, only the stock
  UniProt fields and a one-line bundle patch.
- **MSA viewer.** It needs UniProt sequences and the canonical flag, the aligner container,
  and a bundle patch.
- **JBrowse 2.** This is the real data gap: locations, gene models and chromosome lengths,
  plus a JBrowse 2 server.

The rest of the page (GO, homology, expression, interactions, HPO and OMIM disease) is new
data. Each part is one to three stock or HumanMine sources.

### 1.3 Ad hoc supplements rdfc2im already uses (data not taken from RDF Portal)

Read from rdfc2im `main` (`0308ebf`), `maint/im-ore.1-intermine-src` (`22c57ae`, the
branch the testbed stacks are built from), `maint/im-rkn.5-testbed-baseline`, and
`cached_raw_data/`. There are two findings.

**Finding 1.** In committed code, the **only** fetches outside RDF Portal are:
- the live HumanMine model (`make-inputs.sh`);
- Reactome's `UniProt2Reactome.txt` (phase 6);
- the build tooling (git, Maven, Clojars, Docker, npm).

**Finding 2.** Two cache groups that look like the "ad hoc JBrowse/tool data" Gos remembers are
not read by any code on any branch, local or `fork/*`:
- `grch38-chromosome-lengths`
- `bluegenes-tools`

Both were saved on 2026-10-21. They probably come from a session whose code was never
committed (*unverified*). BUILD.md on the ore.1 branch says of the lengths: "nothing in the
pipeline reads them".

| Supplement | What it supplies | Where it comes from | Proper replacement in the hybrid |
|---|---|---|---|
| `humanmine-items/` loader (BUILD.md phase 5) | No data itself. It is the stock `intermine-items-large-xml-file` loader under the type `humanmine-items`, plus generated `humanmine-items_keys.properties` and `_additions.xml`. Every rdfc2im source loads through it | rdfc2im `project` / `make fork-sync`; built into the humanmine-bio-sources fork | **Keep**: it is how the RDF data loads. But its additions repeat fields from the stock additions (next row), so de-duplicate them once those stock sources are in the model |
| `curation/extensions_additions.xml` | Model fields the live HumanMine model lacks or that a reduced mine drops: `Gene.typeOfGene`, `Gene.pathways`; `Pathway.description`, `.organism`, `.reactions`, `.dataSets`, `.genes`; class `PathwayReaction`; `Allele.reviewStatus`, `.submissionCount`, `.diseases`; `Disease extends BioEntity` + `.alleles`; `Protein.ecNumbers` / `ECNumber.proteins`; `MeshTerm.identifier`; `GWASResult.mappedTraitUri`, `.associatedGenes` | Hand-written (spec "section 8"). Several fields are copied verbatim from stock additions, as the file's comments say: `Gene.pathways`, `Pathway.genes` and `.dataSets` from `reactome_additions.xml`; `Protein.ecNumbers` (uniprot); `Allele.diseases` (clinvar); `GWASResult.associatedGenes` (huge-gwas) | Fields copied from **IM reactome**, **IM uniprot**, **HM-bs clinvar** and **HM-bs huge-gwas** come back through those sources' own additions. Keep only the fields that are genuinely RDF-only: `typeOfGene`, `Pathway.description`, `PathwayReaction`, `Allele.reviewStatus`/`submissionCount`, `MeshTerm.identifier`, `GWASResult.mappedTraitUri` |
| Stock **reactome** "alongside" (phases 6, 11, 12) | `Pathway` to `Protein` participants (rdfc2im's own reactome maps `Pathway.description` only; `pathwayComponent` is pruned), and `Gene.pathways` through `ReactomePostProcess` | `reactome.org/download/current/UniProt2Reactome.txt` (or `_All_Levels`), converter built from intermine source | This **is** the original loader (**IM reactome**). Keep it. The longer-term RDF replacement is mapping `pathwayComponent` |
| Stock **uniprot** "alongside" (`sources.yaml`: `uniprot: alongside: [uniprot]`) | Meant to supply features, comments, isoforms, components and canonical-protein links. **It is not actually loaded**: phase 7 runs `reduce_mine.py sources ... humanmine-items reactome`, keeping only those two types, and the demo's DataSets show only the RDF UniProt set | none today | **IM uniprot** + uniprot-fasta + uniprot-keywords. This is exactly what the Protein Visualizer and MSA viewer lack (T1.1) |
| `rdfc2im/items.py` synthesised values (im-ore.10, im-ore.16) | `Organism.name`, `shortName`, `genus`, `species` from a hard-coded `KNOWN_ORGANISMS` table; one `Chromosome` per number, given the organism of its genes and no length; one DataSet per pathway source; `DataSource.url` from `sources.yaml` `data_source_url` | Constants in rdfc2im | Organism: **IM entrez-organism** (NCBI E-utilities). Chromosome with length: **IM fasta** (ncbi-fasta) + `create-chromosome-locations-and-lengths`, or ncbi-gff. DataSource: **IM update-data-sources** (UniProt `dbxref.txt`). DataSet metadata: **HM-bs humanmine-static** (`datasets.xml`) |
| `cached_raw_data/grch38-chromosome-lengths/refSeqs.json` (967 B) | GRCh38 chromosome lengths, which JBrowse's `refSeqs` needs (§1.4) | **HumanMine's own web service**: `https://www.humanmine.org/humanmine/service/jbrowse/config/9606/seq/refSeqs.json` (META.json) | **IM fasta** (ncbi-fasta) + `create-chromosome-locations-and-lengths`. A stopgap that is cheaper than the 3 GB genome: set `Chromosome.length` from this file in `items.py`, or from the GFF `##sequence-region` lines (*unverified* that ncbi-gff sets length) |
| `cached_raw_data/bluegenes-tools/` (18 npm tarballs) | Offline installs of the 2021 tool versions, **unpatched** (protein-visualizer and msa-viewer 2.1.1). No jbrowse2-tool | registry.npmjs.org | Not data. Replace with the patched tarballs plus jbrowse2-tool from `repos/jbrowse2/bluegenes-tool` (T1.2); published packages later (im-7os.49) |
| `tools/make-inputs.sh`, live model | `in/humanmine_model.xml` and `.json` (HumanMine's 2022 production model), used as `live_model` for mapping and validation | `https://www.humanmine.org/humanmine/service/model`, cached as `humanmine-model` | Derive the model from the humanmine checkout's own `:dbmodel` build (project.xml plus the additions of the sources actually loaded). The live 2022 model is a moving and external input |
| `curation/demo_public_templates.sql` | 9 hand-written public templates plus tags, loaded into userprofile in phase 17 | hand-written | HumanMine's production templates (`humanmine/webapp/src/main/resources/default-template-queries.xml` and the report templates in §1.1), filtered to the paths that resolve (T1.11) |
| `curation/priorities_override.properties`, `autocomplete_override.properties`, `extra_allow.txt` (`/uberon/`), `demo_gene_panel*.txt`, `linkml/humanmine.yaml` | Configuration only: priority order (`Pathway.description = humanmine-reactome, reactome, *`), autocomplete fields, model activation, gene scope, schema | hand-written | Keep. Revisit the priorities each time a stock source is added (§6 risk 3) |
| `gene-id-lookup` cache | Panel symbols resolved to NCBI and Ensembl ids | live lookups against the RDF Portal endpoints (`scope.py`) | RDF-sourced already. Keep |

### 1.4 JBrowse: using jbrowse.intermine.org and jbrowse2.intermine.org again

`docs/HUMAN_TESTING.md` line 774 ("No JBrowse") is true for two reasons:
- the demo mine has no data JBrowse can draw;
- during the sprint the shared hosts were down.

Host status today, from the sandbox:
- **jbrowse.intermine.org: reachable** (HTTP 200, JBrowse 1 index page).
- **jbrowse2.intermine.org: blocked from the sandbox** (403 "Approval required for
  jbrowse2.intermine.org:443"; needs an allow). It was not retried.

**Neither host stores genome data.** Both are viewer apps that load **the mine's own**
`/service/jbrowse/...` endpoints into the user's browser. So "does the track data there cover
the demo's genome build" reduces to "does the mine hold GRCh38 coordinates":
- The demo is GRCh38 throughout: ClinVar `ASSEMBLY="GRCh38"`, the Ensembl RDF and TogoVar
  grch38.
- HumanMine is GRCh38.p13 (ncbi-fasta DataSet).
- The cached `refSeqs.json` is GRCh38.

Any GRCh38 source added for locations (ncbi-gff RefSeq GRCh38, or Ensembl FALDO) is therefore
consistent.

**Existing workarounds and settings found:**
- `intermine/bio/webapp/.../WEB-INF/bio.web.properties`:
  - `jbrowse.install.url = https://jbrowse.intermine.org/`;
  - the `org.intermine.webservice.server.jbrowse.genomic.*` keys: `featureClass =
    SequenceFeature`, `referenceClass = Chromosome`, `domain = organism.taxonId`, `location =
    chromosomeLocation`, `paths.names = symbol|primaryIdentifier|secondaryIdentifier|name`.
  - The duplicate `commandrunner.genomic` line is fixed on maint-2026 (im-ee7.66).
- `humanmine/webapp/src/main/webapp/WEB-INF/web.properties:254`:
  `jbrowse.install.url=http://jbrowse.intermine.org/`. It is plain http and is used only by the
  classic JSP `JBrowseDisplayer`.
- BlueGenes tool `bluegenes-jbrowse-tool` `config.json` has `"jbrowseUrl":
  "https://jbrowse.intermine.org/?data="`. This is the npm default, and what `:15001` has
  installed.
  - It builds the iframe from
    `<jbrowseUrl><service.root>/service/jbrowse/config/<taxonId>&loc=<chr>:<start>..<end>&tracks=<project.title>-<taxonId>-Gene`.
  - It reads `project.title` from `/service/web-properties` and the location from
    `Gene.chromosomeLocation`.
  - HumanMine's copy is sed-patched to `https://www.humanmine.org/jbrowse/?data=`, its own
    nginx `/jbrowse/` route (`repos/jbrowse/README.md` route B; `docker_template`
    `nginx.conf.template` `location /jbrowse/`).
- `bluegenes-jbrowse2-tool` `config.json`:
  - `"jbrowse2Url": "https://jbrowse2.intermine.org/"` and `"jbrowse2ConfigUrl": ""`.
  - Empty means the site's own `config.json`, which `repos/jbrowse2` generates from the
    **public** mines' track lists (`config/generate.mjs <mine> 9606`, committed as
    `docker/config.json`).
  - HumanMine's copy uses `https://www.humanmine.org/jbrowse2/`.
- mine-tests `[mines.local]` has no `jbrowse` key, so the JBrowse tests skip.

**What the demo mine must contain.** Today `/service/jbrowse/config/9606/seq/refSeqs.json`
answers 404 "No Chromosomes on 9606", because `Config.serveRefSeqs` keeps only Chromosomes with
`length > 0`. The demo's 22 Chromosomes have no length. What is needed:

1. `Chromosome.length` for each chromosome, with `organism.taxonId = 9606`. Without it there
   is no reference sequence list and nothing draws.
2. `SequenceFeature.chromosomeLocation` (Location `start`, `end`, `strand`, `locatedOn` =
   Chromosome) for every feature to be drawn: Gene at least; Transcript, Exon and CDS for gene
   models. JBrowse 2's gene glyph also uses the query service for gene structure.
3. Optionally `Chromosome.sequence` for the DNA track (ncbi-fasta). Without it the reference
   track is empty, but features still draw.
4. A `project.title` that makes a usable track or assembly id. The demo's title is "rdfc2im:
   113 gene food/drug-metabolism panel", so the tracks become
   `rdfc2im: 113 gene food/drug-metabolism panel-9606-Gene`. That works in JBrowse 1. Whether
   JBrowse 2 accepts the assembly name `<title>-9606` with spaces and a colon is *unverified*.

**What the testbed must configure to use the shared hosts:**
- **JBrowse 1** (`bluegenesJBrowseTool`): nothing to change in the tool, since the default
  already points at jbrowse.intermine.org. The page then fetches
  `http://localhost:18090/humanmine/service/jbrowse/...` from an https page. Three things are
  *unverified* in a browser:
  - the mixed-content exemption for `localhost`, which Chrome and Firefox both grant;
  - Chrome's Private Network Access preflight for a public origin reaching localhost;
  - InterMine's `AllowCORSWebServiceRequests` filter in `web.xml`, which answers ordinary CORS.

  The fallback that avoids all three is the local `repos/jbrowse` container (`:14880`,
  `allowCrossOriginDataRoot` true) with the tool's `jbrowseUrl` set to it.
- **JBrowse 2** (`bluegenesJBrowse2Tool`): the shared site's `config.json` knows only the
  public mines, so the demo needs one of:
  - `jbrowse2ConfigUrl` pointing to a config generated for the demo
    (`node config/generate.mjs http://localhost:18090/humanmine 9606 -o ...`), served with
    CORS somewhere the browser reaches; or
  - the local `repos/jbrowse2` container (`:14881`) built with that config, and `jbrowse2Url`
    set to it.

  The same mixed-content and PNA caveats apply to the shared host, so the local container is
  the safer default (T1.5). The jbrowse2 host also needs a sandbox allow before any check.
- **Classic webapp** (`JBrowseDisplayer`): `jbrowse.install.url` already points at the shared
  host. Changing it to https in `humanmine/webapp/.../web.properties` is a one-line fix.

---

## 2. How a hybrid build would work

### 2.1 Where the extra sources plug into the 18 phases

Phase names are from `tools/full-build.sh` (main and the `maint/im-ore.1-intermine-src`
branch, `22c57ae`). The `--intermine-src` branch adds `publish_intermine` after phase 2, and
`--stack-name ut` runs the 6.0.0 stack.

| Phase | Change for the hybrid |
|---|---|
| 1 `check_prereqs` | Validate a new `--stock-sources` list against a table (next row), the same way `SCOPE_MODE` validates `--sources`. Fail early when a source's licence flag says its data needs a local copy (OMIM) and none is given |
| 3 `rdfc2im_pipeline` | Unchanged. Optionally add `hpo` and `mp` (both already scope `good`) to `--sources` |
| 4 `rdfc2im_project` | `rdfc2im project` already writes `out/_mine/project.xml` and `replaced_sources.xml` from `replaces`/`alongside`. The hybrid needs it to **keep** the stock `<source>` entries named in `--stock-sources`, in HumanMine's own order, with their properties rewritten to the staged data dirs. Today phase 7 drops every stock source except reactome |
| 6 `build_reactome_source` | Generalise to `build_stock_sources`. Each stock source is either an `org.intermine:bio-source-<name>` jar from the `--intermine-src` m2 repo (6.0 line) or from the humanmine-bio-sources fork (`maint-2026`, version `4.3.0`). The download is part of the same phase, or a new `fetch_stock_data` phase |
| (new) `subset_stock_data`, after 6 | Turn the gene panel into id sets: Entrez ids from the ncbigene items, Ensembl ids, UniProt accessions from the uniprot/hgnc items, symbols. Then pre-filter every staged raw file (§2.2) and write the filtered **ID-resolver file** `${resolver.file.rootpath}/entrez`. Cache the results as rdfc2im cache groups, keyed on `genes_md5` like the panel sources |
| 7 `prepare_mine_checkout` | Keep the stock sources: `reduce_mine.py sources` must be told about them, since today it keeps only `type="humanmine-items"`. Add `resolver.file.rootpath` to `~/.intermine/humanmine.properties`. Delete any `idresolver.cache` |
| 8 `stage_src_data` | Symlink the filtered files into `$RDFC2IM_DATA_ROOT/<HumanMine's own path>` (for example `/micklem/data/go-annotation/current/human`), so the stock properties keep working |
| 10 `build_dbmodel` | Unchanged mechanism. The merged model gains the stock additions, so `reduce_mine.py webconfig` automatically stops dropping widgets such as `go_enrichment_for_gene` |
| 11 `integrate_sources` | Order comes from `project.xml`, as now. Constraints: `uniprot` (stock) before rdfc2im `uniprot` (alongside); `protein2ipr` after uniprot (it queries `os.production`); `go-annotation` after uniprot; `ncbi-gff`/`ncbi-fasta` after ncbigene; `update-publications` and `entrez-organism` last |
| 12 `postprocess` | Add HumanMine's list: `create-chromosome-locations-and-lengths`, `transfer-sequences`, `create-gene-flanking-features`, `create-location-overlap-index`, `create-overlap-view` (from `humanmine/project.xml`), and `do-sources` (GoPostprocess, ReactomePostProcess) |
| 15 `stage_artifacts` / 16 `start_mine_stack` | Install `bluegenes-jbrowse2-tool` from `repos/jbrowse2/bluegenes-tool`. Apply the two bundle patches. Start the `aligner` (sequence-alignment-service) and `jbrowse2` containers in the stack's compose project |
| 17 `apply_templates` | Also load HumanMine's report templates (the ones in the §1.1 layout whose paths resolve in the merged model) and the `layout.report` BlueGenes property. It is stored in the userprofile DB through `MetadataManager.BG_PROPERTIES` (`BGPropertiesCreationService`, superuser only), so either SQL in the same file or a POST with the superuser token |
| (new) `apply_public_lists`, after 17 | Genomics England and the other public lists (§4) |
| 18 `verify` | Add mine-tests `[mines.local]` with tools enabled (§5, T1.12) |

### 2.2 How the gene subset propagates

**What "accept a gene list" means per loader.** No loader in `intermine/bio/sources` or
`humanmine-bio-sources` has a gene or accession allowlist setter. The only filters are
organism setters: `setOrganisms` (ncbi-gene), `setUniprotOrganisms`, `setIntactOrganisms`,
`setBiogridOrganisms`, `setPantherOrganisms`/`setPantherHomologues`, `setReactomeOrganisms`,
`setPubmedOrganisms`, `setProtein2iprOrganisms` and `setOrgTaxonId` (gff). The one gene-list
hook, `DepmapExpressionConverter.GENE_LIST_FILE = ""`, is a hard-coded constant that is
switched off. Three mechanisms are available:

1. **ID-resolver gate (no Java changes).**
   - How it works: `EntrezGeneIdResolverFactory` reads `${resolver.file.rootpath}/entrez`
     (an NCBI `gene_info`) and caches it as `idresolver.cache`. If that file holds only the
     panel genes, every converter that resolves genes through `IdResolverService` silently
     drops unresolved genes.
   - Loaders it covers:
     - generic: psi, biogrid, panther, kegg, omim, pubmed-gene;
     - humanmine-bio-sources: arrayexpress-atlas, atlas-express, protein-atlas,
       protein-atlas-rna, gtex, disgenet, depmap-expression, huge-gwas.
   - Exception: pubmed-gene passes ids through when the taxon is absent from the resolver
     altogether.
   - Cost: one filtered file.
2. **Already restricted by what is loaded.** `protein2ipr` loads domain regions only for
   `Protein.primaryAccession` values already in `os.production`. `go-annotation` creates
   annotations for proteins by accession; with the resolver gate absent it would also create
   stub proteins, so pre-filter it too.
3. **Pre-filter the raw files** (a new `tools/subset_raw.py` in rdfc2im). This is needed for
   loaders with no resolver:
   - ncbi-gene and hgnc: replaced by RDF anyway.
   - uniprot XML: stream the `<entry>` elements and keep those whose accession is in the set;
     `UniprotFilterTask` filters by organism only.
   - uniprot-fasta: by header accession.
   - go-annotation GAF: by column 2.
   - ncbi-gff GFF3: keep `##sequence-region` lines, the features whose
     `Dbxref=GeneID:` is in the set, and their `Parent` closure.
   - ncbi-fasta: whole chromosomes, so no gene filter is possible. Either load it or skip it.
   - interpro.xml: keep everything (it is ontology-like).
   - psi-complexes: by participant accession.
   - mgi-alleles: by MGI marker of the homologues.

   It is also needed where the resolver gate is too strict (next paragraph).

**Interactions and homologues need a decision about what "subset" means.**
- With the resolver gate, an interaction or homologue whose partner is outside the panel is
  dropped. psi drops the interactor and biogrid marks it invalid. Only panel-to-panel pairs
  would survive, which is nearly nothing for 113 metabolic genes.
- HumanMine shows all partners: PAX6 has 156 interactions and 10 homologues. There are two
  options:
  - **(a) Panel-only mine.** Pre-filter the interaction and orthologue files to records with
    at least one panel gene and use the full `gene_info` resolver. Partner genes then exist
    only as bare Entrez or MGI ids, with no symbol, unless ncbigene/hgnc load them.
  - **(b) Recommended: thin genome plus deep panel.** Load the cheap identifier sources
    (rdfc2im `ncbigene`, `hgnc`, `ensembl`) for all about 64,000 human genes (HumanMine has
    64,160 genes with taxon 9606), and keep the heavy annotation (UniProt XML, GO, expression,
    interactions, GFF features) panel-scoped and pre-filtered.

  Option (b) also gives JBrowse neighbouring genes when the GFF filter keeps the gene rows
  only. It is mostly a `SCOPE_MODE` change (`ncbigene=full`, `hgnc=full`, `ensembl=full`).
  Its cost is a slower `integrate_sources`. The fully loaded RDF ncbigene
  ("193,000 genes" in BUILD.md's scope bug) suggests a few extra minutes; this is
  *unverified*.
- **Gos decides (D-1).**

**Pre-filtering versus loading everything then pruning.**
- Pre-filtering, as rdfc2im already does for RDF in SPARQL, keeps the testbed's 10-minute
  build and fits the about 5 GB free on `/var/lib/docker` (or uses `repos/.sandbox-disk/`, §6).
- "Load all, then delete" would need the full database first, which is impossible in this
  sandbox (RAM, §6), and InterMine has no supported delete path (deletes leave tracker and
  overlap tables inconsistent).
- So: pre-filter at stage time, and record what was filtered in the cache `META.json`
  (`genes_md5`, upstream release).

**Default panel.** Add PAX6 (and possibly the other mine-tests fixture genes) to
`curation/demo_gene_panel.txt`, so the demo's report page can be compared directly with
HumanMine's PAX6 page and mine-tests' `[mines.humanmine.gene]` expectations. This changes
`genes_md5`, which means a refetch of the panel-scoped RDF sources (about 10 min of network)
and a new CI release asset (`demo-data-*`). **Gos decides (D-4).**

### 2.3 Downloads, volumes and time per candidate source

- **Sizes.** "Verified" means a HEAD request answered from the sandbox. Every other size is
  an estimate from general knowledge (*est.*); confirm it once the hosts are allowed.
- **Times.** The filtered subset integrates in about 1 to 3 minutes per source, judging from
  the demo's 9 to 10 sources taking 109 to 233 s in total.
- **Releases.** "Last loaded on HumanMine" comes from the public mine's `DataSet.version`
  values. The last HumanMine load was **February 2022**.

| Source | Upstream file (canonical URL; HumanMine's project.xml names only `/micklem/...` paths) | Size | Last loaded on HumanMine | Pre-filter / stream time |
|---|---|---|---|---|
| uniprot (stock) | `ftp.uniprot.org/.../taxonomic_divisions/uniprot_sprot_human.xml.gz`, `uniprot_trembl_human.xml.gz` | est. about 80 MB and about 400 MB gz | 2021_04 | about 5 to 10 min to stream TrEMBL; Swiss-Prot only is enough for the tools (decision D-6) |
| uniprot-fasta | `.../complete/uniprot_sprot_varsplic.fasta.gz` | est. about 10 MB | 2021_04 | under 1 min |
| uniprot-keywords | `.../complete/docs/keywlist.xml` | est. about 3 MB | 2021_04 | none |
| go-annotation | `current.geneontology.org/annotations/goa_human.gaf.gz` | est. about 12 MB | Feb 2022 | under 1 min |
| ncbi-gff | `ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/GRCh38_latest_genomic.gff.gz` | est. about 60 MB | RefSeq 109.20210514 | 1 to 2 min |
| ncbi-fasta | same directory, `GRCh38_latest_genomic.fna.gz` (or per-chromosome `*.fna`) | est. about 950 MB gz, 3.1 GB raw | GRCh38.p13 | No gene filter possible; **does not fit `/var/lib/docker` or `worktrees/` (about 5 GB free); stage it under `repos/.sandbox-disk/` (604 GB)**. Make it optional |
| panther | `data.pantherdb.org/ftp/ortholog/current_release/RefGenomeOrthologs.tar.gz` | est. about 60 MB | 16.0 (Dec 2020) | 1 min |
| psi-intact | `ftp.ebi.ac.uk/pub/databases/intact/current/psi25/species/human.zip` (layout *unverified*) | est. several hundred MB | Feb 2022 | 5 to 15 min (XML, interactor-list rewrite) |
| biogrid | `downloads.thebiogrid.org/.../BIOGRID-ORGANISM-LATEST.psi25.zip` | est. about 150 MB | 4.4.206 | 5 min |
| psi-mi-ontology | `purl.obolibrary.org/obo/mi.obo` | est. about 3 MB | Feb 2022 | none |
| protein-atlas | `www.proteinatlas.org/download/tsv/normal_tissue.tsv.zip` | est. about 5 MB | 21.0 | under 1 min (resolver gate) |
| protein-atlas-rna | HPA `rna_tissue_consensus.tsv.zip` (the converter wants the literal name `rna_tissue.tsv`) | est. about 6 MB | 21.0 | under 1 min |
| gtex (median) | `storage.googleapis.com/adult-gtex/bulk-gex/v8/rna-seq/GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_median_tpm.gct.gz` | **verified 6,952,331 B** (last-modified 2023-03-20) | v8 | under 1 min |
| gtex (eQTL) | GTEx v8 `GTEx_Analysis_v8_eQTL.tar` (`*.signif_variant_gene_pairs.txt.gz`) | est. about 1.5 GB | v8 | 5 min. Stage it under `repos/.sandbox-disk/` |
| atlas-express | Expression Atlas E-MTAB-513 (`/gxa/json/experiments/E-MTAB-513` **verified 200**, 18,674 B; the TSV the converter needs is *unverified*) | est. under 5 MB | July 2014 | under 1 min |
| arrayexpress-atlas | E-MTAB-62 JSON (ArrayExpress Atlas API, retired); only Gos's `/micklem/data/metabolic/array-express/E-MTAB-62-wrong-p-value/` | unknown | June 2011 | Gos must supply the copy |
| hpo-annotation | `purl.obolibrary.org/obo/hp/hpoa/genes_to_phenotype.txt`, `phenotype.hpoa` | est. under 50 MB | Feb 2022 | under 1 min |
| omim | `mimTitles.txt`, `morbidmap.txt` (licensed download key); `pubmed_cited` | small | Feb 2022 | Gos must supply the copy (licence) |
| orphanet | `www.orphadata.com/data/xml/en_product1.xml` | est. about 5 MB | Feb 2022 | none |
| hgnc (only if the stock source is kept) | `storage.googleapis.com/public-download-files/hgnc/tsv/tsv/hgnc_complete_set.txt` | **verified 17,007,798 B** (2026-11-13) | Feb 2022 | replaced by RDF |
| reactome (already used) | `reactome.org/download/current/UniProt2Reactome.txt` | **verified 200**, last-modified 2026-10-18 | 79 | as now |
| Milestone 3 only | protein2ipr (`protein2ipr.dat.gz`, est. over 20 GB for all of UniProt); interpro (`interpro.xml.gz`, est. about 150 MB); interpro-go; clinvar full (RDF); gene2pubmed (est. about 200 MB); mgi/rgd reports; depmap; disgenet; GTEx eQTL; ncbi-summaries (no public file; HumanMine's `gene_summaries.txt` came from a script in the external `intermine-scripts` repo, not cloned here) | | | |

Overall, milestone 1 needs about **0.7 to 1.2 GB of downloads** without the genome FASTA
(est.), or about 2 GB with it. After filtering, the panel data is small: under 50 MB, which
is cacheable in `cached_raw_data/` beside the current 181 MB.

### 2.4 Licensing and redistributing cached raw data

This matters because `cached_raw_data/` is published as a **GitHub release asset for CI**
(`demo-data-2026-11-16`, 14 cache groups; LOG 16 Nov 03:30).

- **Redistributable with attribution.** The licence is recorded in `DataSet.licence` or in
  the converter where one is present.
  - CC BY 4.0: UniProt, GO/GOA, IntAct and Complex Portal (EBI), Expression Atlas,
    Orphanet, MGI, DepMap.
  - Public domain / NCBI policy: NCBI gene, RefSeq GFF/FASTA, ClinVar, gene2pubmed.
  - CC0: Reactome (`DataSet.licence` on the demo), InterPro, RCSB.
  - MIT: BioGRID (*unverified*).
  - GTEx summary statistics (open-access tier).
- **Share-alike.** HPA is CC BY-SA 3.0 in the converter (HPA now states 4.0, *unverified*).
  A redistributed filtered copy must carry the same licence.
- **Not redistributable.**
  - **OMIM**: licensed download key; personal or institutional use only.
  - **DisGeNET**: academic licence behind registration since its 2024 commercialisation
    (*unverified from here*).
  - **KEGG**: FTP subscription; already commented out.
  - SIGNOR: *unverified*.

  These must never enter the CI release asset. Add a `redistributable: false` flag per cache
  group, and have `rdfc2im cache save --for-release` refuse such groups.
- **HPO.** HPO's licence allows reuse with attribution and no altering of terms. A filtered
  annotation file is probably fine but should be checked (*unverified*).
- **PanelApp.** Genomics England terms are *unverified*; the API was blocked, see §4.
- **Robots and rate limits.** Bulk files come from FTP/HTTPS download areas, not from page
  scraping, so robots.txt does not apply. The live NCBI E-utilities calls (`update-publications`,
  `entrez-organism`) must stay under 3 requests per second without an API key. The tools'
  browser calls (RCSB, EBI ProtVista) are per user and per page, as on HumanMine.

---

## 3. Loader maintenance debt

- **Network checks.** HEAD requests went out on 17 Nov 2026 from the sandbox. Almost every
  data host returned **HTTP 403 from the sandbox proxy (blocked from sandbox; needs
  allow)**, and none was retried. The blocked hosts were:
  - current.geneontology.org, ftp.ebi.ac.uk, purl.obolibrary.org
  - ftp.ncbi.nlm.nih.gov, ftp.uniprot.org, rest.uniprot.org
  - downloads.thebiogrid.org, data.pantherdb.org, www.proteinatlas.org
  - omim.org, www.orphadata.com, www.disgenet.org
  - www.informatics.jax.org, depmap.org, rest.kegg.jp
  - panelapp.genomicsengland.co.uk

  Reachable: storage.googleapis.com (GTEx, HGNC), www.ebi.ac.uk/gxa, reactome.org,
  search.rcsb.org, www.humanmine.org, registry.npmjs.org.
- **Git dates.** "Last change" is the last commit touching the directory:
  - humanmine-bio-sources: `maint-2026`, `73e6b70`. The 16 Nov dates are the 6.0
    conversion and commons-lang3 sweep, not data-format work.
  - intermine: the checkout is on `dev`; `maint-2026` is in a worktree. 2022-04-27 is a
    copyright-only sweep.
- **"Expects"** is what the converter is coded for.

| Source | Converter expects | Upstream now | Last change / tests | Debt |
|---|---|---|---|---|
| IM uniprot | `<taxon>_uniprot_sprot.xml`, `_trembl.xml` (UniProt XML); config `9606.primaryIdentifier.dbref = GeneID` | XML still published (*unverified*, blocked) | 2022-05-13; 9 test files | Check against a 2026 XML (the schema has changed since 2021_04). Isoforms get no sequence from the XML; uniprot-fasta supplies them |
| IM fasta (uniprot-fasta, ncbi-fasta) | varsplic FASTA; NCBI `*.fna` with NC_ headers | *unverified* | 2022-04-27; 15 | Low |
| IM go-annotation | GAF 2.x `**/gene_association*`; 9606 annotates `Protein.primaryAccession` | GAF 2.2 (*unverified*, blocked) | **2025-11-19** (test fixes); 7 | Low. The file must be renamed to `gene_association*` or the include changed |
| IM ncbi-gff | NCBI GFF3; chromosome map **hard-coded** NC_000001.11 to NC_000024.10, so **MT is not mapped**; no CDS/UTR handling | RefSeq annotation is now released as RS_YYYY_MM (*unverified*) | 2022-04-27; 3 | Medium. Re-test on the current GFF; add MT; decide on CDS/UTR (JBrowse 2 draws CDS and UTR when present) |
| IM panther | `RefGenomeOrthologs` (`HUMAN\|HGNC=..\|UniProtKB=..`) | PANTHER 19 (*unverified*) | 2022-04-27; 3 | Low to medium |
| IM psi (intact) | PSI-MI 2.5 XML per species | *unverified* (blocked) | 2022-04-27; 3 | Medium. Does IntAct still publish psi25 species files? |
| IM biogrid | `BIOGRID-ORGANISM-<Genus_species>-*.psi25.xml`; organism taken from the filename at `substring(17)` | *unverified* | 2025-12-19 (build.gradle only); 3 | Low, but the filename parsing is fragile |
| IM psi-mi-ontology, go, so, mp (OBO) | OBO | stable | 2020; 0 | Low. go is replaced by RDF; mp could be (rdfc2im `mp`) |
| IM omim | `mimTitles.txt`, `morbidmap.txt`, `pubmed_cited` (all required) | licensed; `pubmed_cited` is not an OMIM product (*unverified* where it came from) | 2022-04-27; 5 | Licence, not code |
| IM pubmed-gene | `gene2pubmed` | stable | 2022-04-27; 13 | Low |
| IM protein2ipr / interpro / interpro-go | `protein2ipr.dat`, `interpro.xml`, interpro2go | stable formats; very large file | 2022-04-27; 3 each | Disk and time, not code |
| HM-bs protein-atlas | literal file names `normal_tissue.tsv`, `tissue_to_organ.tsv` or `proteinatlas.xml` (throws on others); level/reliability remapping is commented out | HPA ships `normal_tissue.tsv.zip` (*unverified* columns) | 2026-11-16 (sweep); 2 methods | Medium. Unzip and rename in staging; check the columns |
| HM-bs protein-atlas-rna | literal `rna_tissue.tsv` with columns Gene, Gene name, Sample, Value, Unit | HPA renamed its RNA files (consensus, hpa, gtex; columns now `nTPM`) (*unverified*) | 2026-11-16; 2 methods | **Converter fix likely** (about 1 h) |
| HM-bs gtex | names containing `gene_median` (GCT) and `signif` (v7 12-column pairs) | v8 median file verified reachable; v10 exists (*unverified* format; eQTL possibly parquet) | 2026-11-16; 1 test (v7 fixtures) | Medium. Pin v8 (what HumanMine has) for milestone 1 |
| HM-bs atlas-express | Illumina Body Map FPKM tab | Expression Atlas still serves E-MTAB-513 (JSON verified) | 2026-11-16; **no tests** | Medium. Add a fixture test first |
| HM-bs arrayexpress-atlas | ArrayExpress Atlas JSON (`results[0].geneExpressionStatistics`) | **the API is gone**; no refresh possible | 2026-11-16; **no tests** | Frozen data. Use Gos's copy, or retire it in favour of Expression Atlas |
| HM-bs hpo-annotation | requires `phenotype_annotation.tab`, `phenotype_annotation_negated.tab`, `genes_to_phenotype.txt` | HPO replaced the `.tab` files with `phenotype.hpoa` (2021-22) and changed the `genes_to_phenotype.txt` columns (2023) (*unverified*) | 2026-11-16; **test class deleted** (27323d2), 6 orphan fixtures | **Converter fix needed** (about 2 h, including restoring the test) |
| HM-bs hpo | OBO loader | stable | 2020-06-12; 0 | Replace with rdfc2im `hpo` |
| HM-bs orphanet | `en_product1.xml` (throws on other names) | *unverified* | 2021-11-12; 1 | Low |
| HM-bs clinvar, huge-gwas, hgnc | as tabled by the converters | replaced by rdfc2im `clinvar`, `gwascatalog`, `hgnc` | 2026-11-16 | Keep as the fallback for milestone 3 |
| HM-bs disgenet | `curated_gene_disease_associations.tsv` | licensing changed (*unverified*) | 2026-11-16; empty stub test | Decision D-7 |
| HM-bs depmap-* | `CCLE_expression.csv`, `sample_info.csv` | DepMap renamed its release files after 2022 (*unverified*) | 2026-11-16; stub test (expression) | Milestone 3, about 1 to 2 h |
| HM-bs ncbi-summaries | `gene_summaries.txt` (Entrez, summary) | no upstream file; made by a script (intermine-scripts, not cloned) | 2026-11-16; 1 | Milestone 3: write a small E-utilities fetcher, or take `Gene.description` from RDF ncbigene, which already maps it |
| HM-bs mgi-alleles, IM mgi-identifiers, rgd-identifiers | MGI and RGD report files | *unverified* | 2026-11-16 / 2022; mgi-alleles and rgd have no tests | Low to medium |
| HM-bs humanmine-static | items XML `datasets.xml` from a `humanmine-datasets` git repo | not in any cloned repo; Gos to locate | 2026-11-16 | It is the source of `DataSet.version`/`description` on HumanMine |
| **Tools** | protein-visualizer 2.1.1 (RCSB v1), msa-viewer 2.1.1 (dead aligner host), jbrowse2-tool (not on npm) | RCSB v2 verified; aligner repo ready; jbrowse2 repo "implemented and tested, not yet deployed" | npm latest 2.1.1 for both, 2021-06-11 | The upstream PRs are already tracked as **im-7os.49** (do not duplicate) |

**Test coverage summary.** In humanmine-bio-sources, seven sources have no `src/test` at all:
arrayexpress-atlas, atlas-express, ensembl-hgnc, hgnc, hpo, humanmine-static and mgi-alleles.
Two have empty stubs (depmap-expression, disgenet), and hpo-annotation's test class is
deleted. The generic sources each have 1 to 15 test files, but those use 2010-era fixtures.

**Rule for every converter fix.** First add a fixture test cut from the **current** upstream
file, then fix (gate: `./gradlew :<src>:test` green on maint-2026 CI). This follows the
sprint's practice.

---

## 4. Genomics England lists

**What exists on public HumanMine** (`/service/lists`, 184 public lists):
- **171** lists named `PL_GenomicsEngland_GenePanel:<Panel_name>`, all of type Gene.
  - Tags: `Genomics England gene panel`, `im:public`.
  - Created 1 to 9 December 2021.
  - Sizes 1 to 1,991, 10,375 members in total.
  - Description: *"Gene panel from the Genomics England PanelApp. Only genes with a high level
    of confidence (Green level) are included. Updated Decemeber 1st 2021. See
    https://panelapp.genomicsengland.co.uk/ for more details"* (the typo is theirs).
- **13** older `PL_` lists from 2015 to 2019, for example `PL_BHF_UCL_cardiovascGenes`
  (4,103), `PL_DiabesityGWAS_pval-4`, `PL_Pax6_Targets` and `PL_obesityLociReview_Day2011`.
  Two are Protein lists and one is a SNP list.

**How they were made.**
- **No code in any cloned repo** creates them: humanmine, humanmine-bio-sources, rdfc2im,
  intermine and intermine-planning (where beads mention PanelApp only in the im-9n4 title).
- `humanmine/webapp/src/main/resources/default-template-queries.xml` has `<bags/>` (empty).
- The only mention anywhere is BlueGenes' own `src/cljs/bluegenes/components/tools/effects.cljs`,
  which hard-codes `navigate('list', 'PL_GenomicsEngland_GenePanel:Radial_dysplasia')` as an
  example. **List names must stay stable.**
- The lists live in HumanMine's userprofile database (superuser-owned, tagged `im:public`).
  They were almost certainly uploaded through the list web service by a script or by hand;
  the script may be in the external `intermine-scripts` repo (*unverified*).
- Consequence: **a fresh rebuild has none of the 184 public lists** unless they are
  re-created.

**How to refresh them.**
- **Access.** The PanelApp API `https://panelapp.genomicsengland.co.uk/api/v1/` is **blocked
  from the sandbox**. One GET of `/api/v1/panels/?page=1` returned 403 "Approval required for
  panelapp.genomicsengland.co.uk:443". Gos must approve the host with
  `sbx policy approval ls`, `... inspect`, `... respond`.
- **API.** From PanelApp's public documentation, *unverified here*:
  - `GET /api/v1/panels/` is paginated (`next`), giving id, name, version and
    `version_created`. `/api/v1/panels/signedoff/` gives the signed-off subset.
  - `GET /api/v1/panels/<id>/` gives `genes[]` with `confidence_level` (`"3"` = Green),
    `gene_data.hgnc_id`, `gene_data.gene_symbol`, `gene_data.ensembl_genes.GRch38`.
- **Policy (Gos, decided).**
  - Refresh with whatever PanelApp currently provides: **all panels, Green genes only**, with
    each panel's PanelApp version recorded in its description.
  - Before any rebuild or refresh, **archive the current HumanMine public lists** (all 184:
    names, descriptions, tags, members) in a new repository **`gmicklem/historic_artefacts`**.
    A user who asks for the 2021 lists can then be given them.
  - The archive is a separate bead (T2.1), and **archiving is the first step of every future
    list refresh**. Each refresh adds a dated directory; earlier ones are never overwritten.
  - **Wish, to raise with Genomics England:** that they publish the panels in a versioned
    repository (for example a git repository or a release per PanelApp snapshot). Old panel
    sets would then not depend on mine archives at all.
- **Script.** A new `rdfc2im/tools/panelapp_lists.py`:
  1. Fetch every panel. Keep Green genes. Save the raw JSON as cache group `panelapp/` with
     `META.json` holding the panel versions and the fetch date.
  2. Map genes to mine identifiers by **HGNC id first**, then Ensembl GRCh38 id, then
     symbol. The demo's Gene keys are Entrez (`primaryIdentifier`) and Ensembl
     (`secondaryIdentifier`). HGNC ids reach the mine only as rdfc2im hgnc
     `CrossReference`/`Synonym` values (*unverified* that they resolve in list upload), so
     Ensembl ids are the safe key.
  3. Upload through `POST /service/lists` (type Gene, organism *H. sapiens*) as the superuser.
     Use the same names, a description carrying the PanelApp panel version and the date,
     and tags `Genomics England gene panel` and `im:public` (`POST /service/list/tags`).
     Write an "unresolved identifiers" report per panel.
  4. Re-create the 13 non-PanelApp `PL_` lists from the archive export (T2.1). Their
     identifiers come from public HumanMine (read-only `/service/lists` plus a list-contents
     query), and a copy is kept in `rdfc2im/curation/public_lists/`.
- **Where it belongs.** A new phase `apply_public_lists` after `apply_templates`.
  - It is first developed and tested against the **small demo database** (milestone 2).
    With D-1 option (b), all about 64,000 human genes exist there as identifiers, so the
    panels resolve almost completely even on a subset build. With option (a) most panels
    would be partial, and each description must carry a "subset" note.
  - The same phase then runs on the full build (milestone 3) and after every production
    HumanMine release. Each run is preceded by the archive step.

---

## 5. Phased plan with beads

**Conventions.**
- All beads are children of **im-9n4**.
- Sizes are agent-hours, measured against the sprint: a converter fix is about 1 h; a new
  source wired into rdfc2im is 2 to 4 h; a demo rebuild from the cache is about 10 min
  warm.
- Every rdfc2im change keeps the existing gates (`make test`; demo rebuild; `make test-live`
  20/20; the 13 reference counts unchanged unless intended).
- Model: **Sonnet** for mechanical wiring, filters, tests and converter fixes; **Opus** for
  phase design, identifier merging and anything touching `project`/priorities; **human** for
  decisions, approvals and licensed data.
- All work is on the **ut stack (6.0.0)** only; see D-5.

**Existing beads this plan touches; do not duplicate them.**
- **im-ore.18**: the RDF route to GO annotations, Locations and SNP chromosomes. T1.4 and
  T1.6 are the stock-loader route to the same report items. Gos picks one route (D-2), or
  keeps im-ore.18 as the long-term RDF replacement (milestone 4 below).
- **im-7os.49**: upstream PRs on the tool packages. T1.2 only patches the testbed's
  installed copies.
- **im-7os.33**: tool-store release.
- **im-ore**: Epic G, the whole-system testbed.

### Decisions for Gos (before or at T0)

| # | Decision | Recommendation |
|---|---|---|
| D-1 | Subset meaning: (a) panel-only mine, or (b) all human genes as identifiers plus panel-deep annotation | (b): interactions, homologues and JBrowse look like HumanMine; costs minutes, not hours (*unverified*) |
| D-2 | Locations, gene models and GO: stock loaders (ncbi-gff, go-annotation) now, or RDF (im-ore.18) | Stock now for milestone 1. Keep im-ore.18 as the RDF replacement once it matches |
| D-3 | Which tools matter most | Order: Protein Visualizer, MSA, JBrowse 2, then Cytoscape, then the expression tools. This matches mine-tests `[mines.humanmine.tools].rendered` (JBrowse, ProteinVisualizer, MSAViewer, HumanTissueExpression, ProteinAtlasTissueExpression, Cytoscape) |
| D-4 | Add PAX6 (and other fixture genes) to the demo panel; regenerate the CI data asset | Yes |
| D-5 | Keep both 5.1.1 (`:8090`) and 6.0.0 (`:18090`) stacks | Keep 5.1.1 as the **RDF-only baseline** (unchanged) and do the hybrid on `ut` only. The humanmine-bio-sources fork is converted to 6.0 only, and the Docker volume disk holds about 5 GB free |
| D-6 | Stock UniProt: Swiss-Prot only, or also TrEMBL | Swiss-Prot plus varsplic. TrEMBL already arrives from RDF. Note the demo has 58 proteins for CYP2D6 against HumanMine's 2, so the MSA viewer would try to align 58 sequences. Consider limiting `Gene.proteins` to reviewed entries (an rdfc2im `core:reviewed` filter) |
| D-7 | Restricted data (OMIM, DisGeNET, KEGG) | Load only from Gos's local copies; never in the cache release asset; skip on CI |
| D-8 | PanelApp scope | **Decided (Gos):** whatever PanelApp currently provides; all panels, Green genes, panel version recorded; archive the current 184 lists in `gmicklem/historic_artefacts` first (T2.1) |
| D-9 | Where milestone 3 (the full build) runs | **Decided (Gos):** on the DBCLS server that hosts HumanMine and FlyMine (about 256 GB RAM). It needs preparation there (T3.1). This sandbox cannot do it: 15 GB RAM now, Docker on a 10 GB volume (§6). The next sandbox session gets 75% of the Mac's RAM instead of 50% (about 22 to 24 GB, *est.*), which is more room for hybrid demo builds but still not enough for the full build |
| D-10 | Approve sandbox network allows for the data hosts in §3 | Needed before T0.4 and T1.x fetches |

### Milestone 1: the demo gene report page shows HumanMine's tools for the subset genes

**Milestone gate.**
- mine-tests browser suite `tests/browser/test_report_tools.py` against `[mines.local]` with
  these settings:
  - `has_tool_store = true`, `has_locations = true`;
  - `tools.rendered` = HumanMine's six plus `bluegenesJBrowse2Tool`;
  - `gene.expect.rcsb = true`, `align = true`;
  - fixture gene PAX6 (or CYP2D6).
- All of these pass in Chromium: `test_expected_tools_render`,
  `test_no_tool_shows_error_text`, `test_protein_visualizer_uses_rcsb_v2`,
  `test_msa_viewer_calls_the_aligner`, `test_jbrowse_iframe_loads`.
- Plus a new side-by-side check (T1.12).

| ID | Title (bead text) | Size | Deps | Gate | Who |
|---|---|---|---|---|---|
| T0.1 | rdfc2im full-build.sh: generic stock-source support (`--stock-sources`, a per-source table of jar origin, data path, fetch URL, filter, licence flag; keep stock `<source>`s through `project`/`reduce_mine.py sources`) | M, 3-4 h | D-1, D-2 | `--dry-run` lists the new steps; a rebuild with `--stock-sources ""` is byte-identical (test-live 20/20, 13 counts) | Opus |
| T0.2 | rdfc2im tools/subset_raw.py: derive the panel id sets (Entrez, Ensembl, UniProt, symbol) and stream-filter GAF, GFF3 (Parent closure), UniProt XML, FASTA, tab files, gene_info; unit tests on fixtures | M, 3 h | T0.1 interface | `make test` with new fixtures; the filtered output of a recorded sample file matches the expected | Sonnet |
| T0.3 | rdfc2im: ID-resolver gate (filtered `entrez` gene_info under `resolver.file.rootpath`, `idresolver.cache` removed) and stock cache groups with `redistributable` flag | S, 1-2 h | T0.2 | `rdfc2im cache save --for-release` refuses a non-redistributable group (test) | Sonnet |
| T0.4 | Demo panel: add PAX6 (+ mine-tests fixture genes), refetch panel-scoped RDF sources, regenerate cached_raw_data and the CI demo-data release asset | S, 1 h + 15 min network | D-4, D-10 | test-live green; the new counts are recorded in BUILD.md | Sonnet (asset upload: Gos approves) |
| T1.1 | Hybrid: load the stock uniprot (Swiss-Prot human, filtered), uniprot-keywords and uniprot-fasta (varsplic) alongside rdfc2im uniprot, giving canonicalProtein, isUniprotCanonical, isFragment, sequence, features, comments | M, 3 h | T0.1-T0.3, D-6 | `Protein.canonicalProtein` and `Protein.sequence.residues` are non-empty for every Swiss-Prot panel protein; the protein-visualizer and MSA tool queries return 200; no duplicate Protein per accession | Opus |
| T1.2 | Testbed tools: install bluegenes-jbrowse2-tool from repos/jbrowse2/bluegenes-tool, apply the RCSB v1-to-v2 and MSA same-origin patches (docker_template recipe), cache the patched tarballs | S, 2 h | none | mine-tests `tests/service/test_tools.py` (`@patched` tests) pass on `:15001` | Sonnet |
| T1.3 | Testbed aligner: run sequence-alignment-service in the ut compose project and route `/align-sequence` on the BlueGenes origin (small nginx in front of `:15001`, or a direct patch to `http://localhost:13000`; the service enables CORS) | M, 2 h | T1.2 | `test_align_sequence_route`, `test_msa_viewer_calls_the_aligner` | Sonnet |
| T1.4 | Hybrid: load ncbi-gff (filtered to the panel's genes, transcripts and exons) with the chromosome lengths, run create-chromosome-locations-and-lengths; ncbi-fasta and transfer-sequences optional behind `--with-genome-sequence` | L, 4-6 h | T0.1-T0.3, D-2 | `Gene.chromosomeLocation` for all panel genes; `/service/jbrowse/9606/refSeqs.json` 200; mine-tests JBrowse REST tests with `has_locations=true` | Opus |
| T1.5 | Testbed JBrowse 1 and 2 (§1.4): try the shared jbrowse.intermine.org and jbrowse2.intermine.org first (host allow, demo config via `jbrowse2ConfigUrl`); fall back to the local repos/jbrowse (`:14880`) and repos/jbrowse2 (`:14881`) containers with demo-generated config; set `[mines.local].jbrowse` | M, 2-3 h | T1.2, T1.4, D-10 | refSeqs.json 200; jbrowse2 `docker/smoke-test.sh`; `test_jbrowse_iframe_loads`; PAX6 draws its transcripts in both tools | Sonnet |
| T1.6 | Hybrid: load go-annotation (goa_human GAF filtered by panel accessions) and interpro-go, giving GOAnnotation; restore go_enrichment_for_gene; GO term/concept tools | S-M, 2 h | T1.1 | `Gene.goAnnotation` > 0 for CYP2D6; the widget is in `/service/widgets`; go-term-visualizer renders on a list | Sonnet |
| T1.7 | Hybrid: load panther homologues (filtered to the panel's rows) plus mgi-identifiers and rgd-identifiers for partner symbols; template Gene_Orth2 | M, 2-3 h | T0.3, D-1 | `Gene.homologues` > 0 for PAX6; partners have symbols | Sonnet |
| T1.8 | Hybrid: load psi-intact, biogrid and psi-mi-ontology filtered to interactions with at least one panel gene; the Cytoscape tool; templates Gene_Interactions_forReportPage, Gene_Interact_disease | L, 4-6 h | T0.2, D-1 | `Gene.interactions` > 0; the Cytoscape panel renders with no 400s in the captured POSTs | Opus |
| T1.9 | Hybrid: load protein-atlas, protein-atlas-rna (fix the file name and columns) and gtex v8 (median TPM), plus atlas-express; arrayexpress-atlas only from Gos's copy; the expression tools | L, 5-6 h (2-3 converter fixes, tests first) | T0.3 | each converter's new fixture test is green on CI; Protein Atlas and Human Tissue tools render | Sonnet, Opus review |
| T1.10 | Hybrid: the disease section, using rdfc2im `hpo` (RDF) plus a fixed hpo-annotation (phenotype.hpoa, restored test), orphanet and omim (local licensed copy); templates Gene_Disease2, Gene_Disease_HPO, Gene_HPOphenotype_2, Gene_SigSNP (gtex eQTL, optional) | M-L, 4 h | T0.3, D-7 | `Gene.diseases` > 0 for PAX6; the templates run with rows | Sonnet; Gos supplies OMIM |
| T1.11 | Demo report layout: apply HumanMine's Gene `layout.report` (bluegenes-properties) and the report templates whose paths resolve, in apply_templates | S-M, 2 h | T1.1-T1.10 (incremental) | `/service/bluegenes-properties` holds the layout; every referenced template exists | Sonnet |
| T1.12 | mine-tests: `[mines.local]` tools enabled, plus a test comparing the demo's rendered tool panels with HumanMine's for the same gene | S, 1-2 h | T0.4 | the milestone gate above | Sonnet |
| T1.14 | Reinstate repos/sequence-alignment-service on the DBCLS server behind its existing reverse proxy with a valid certificate, at sequencealignment.apps.intermine.org (or a new name), so the MSA viewer works on the public mines as well as the demo | M: 2-3 h agent (container, nginx server block, cert, health check, mine-tests run against www.humanmine.org) + Gos (DNS for apps.intermine.org, server access) | none (parallel with T1.3) | `curl https://<name>/` returns `{"api_working":true}` with a valid cert; mine-tests `test_msa_viewer_calls_the_aligner` passes against public HumanMine and against the demo. With the original name restored, the unpatched 2.1.1 bundle's hard-coded URL works again; only the msa-library crash patch remains | Sonnet + Gos |
| T1.13 | Full ut demo rebuild with all milestone 1 sources from cache; record timings and disk in BUILD.md; refresh the release asset (redistributable groups only) | S, 1 h (+ build about 15-25 min, est.) | all of the above | test-live, mine-tests service and browser suites green; timings recorded | Sonnet; Gos approves the asset |

**Milestone 1 total: about 44 to 53 agent-hours**, including T1.14 (the public aligner, 2-3 h plus Gos for DNS and server access).
- A **tools-only cut**, matching the six tools in mine-tests' HumanMine list, is about 30 h.
  It covers T0.1-T0.4, T1.1-T1.5, T1.8, the T1.9 Protein Atlas and Human Tissue part, and
  T1.12.
- Wall time is longer, for downloads and network approvals.
- Parallelism: T1.2, T1.3 and T1.5 run in parallel with the data beads. The data beads
  serialise on the ut stack (one build at a time; peak 9 GB of 15 GB RAM).

### Workstream A: replace the ad hoc supplements with the original loaders

This runs alongside milestone 1 and must be finished before milestone 3: a full build must not
depend on the HumanMine web service or on hard-coded constants. Each bead removes one row of
§1.3.

**Gate for every bead:**
- the supplement's code path or cache group is gone, or is used only behind an explicit
  `--stopgap` flag;
- the proper loader provides the same fields, checked by a count query;
- test-live and the 13 reference counts are unchanged, or changed in the intended direction.

| ID | Title (bead text) | Size | Deps | Gate | Who |
|---|---|---|---|---|---|
| TA.1 | rdfc2im: actually load the declared `uniprot: alongside: [uniprot]` stock source (reduce_mine.py keeps it), with the same work as T1.1, so the sources.yaml declaration is true | (in T1.1) | T1.1 | the demo DataSets list a UniProt Swiss-Prot data set from the stock loader | Opus |
| TA.2 | rdfc2im: Chromosome lengths from ncbi-fasta / create-chromosome-locations-and-lengths (or the GFF sequence-region lines) instead of HumanMine's refSeqs.json; retire the `grch38-chromosome-lengths` cache group | S-M, 2 h | T1.4 | `Chromosome.length` for every chromosome matches GRCh38; no request to www.humanmine.org in the build log | Sonnet |
| TA.3 | rdfc2im items.py: drop the KNOWN_ORGANISMS constants in favour of the entrez-organism loader; drop the synthesised DataSource.url in favour of update-data-sources | M, 2-3 h | T0.1 | `Organism.name`/`shortName`/`genus`/`species` and `DataSource.url` are non-null and come from the loader's DataSet | Sonnet |
| TA.4 | rdfc2im curation/extensions_additions.xml: remove the fields copied from stock additions (Gene.pathways, Pathway.genes/dataSets, Protein.ecNumbers, Allele.diseases, GWASResult.associatedGenes) once their stock source is in the build; keep only RDF-only fields | S, 1-2 h | T1.1, T1.10 | isolated `mergeModels` (phase 5) and `:dbmodel:builddb` pass; the merged model is unchanged by this bead | Opus |
| TA.5 | rdfc2im: derive the model from the humanmine checkout's own :dbmodel build rather than fetching HumanMine's live /service/model; retire the `humanmine-model` cache group | M, 3 h | T0.1 | `rdfc2im check` passes against the built model; no request to www.humanmine.org in phases 2-4 | Opus |
| TA.6 | rdfc2im: replace curation/demo_public_templates.sql with HumanMine's default-template-queries.xml plus the report templates, filtered by path resolution (shared with T1.11) | (in T1.11) | T1.11 | every HumanMine report-layout template exists or is listed as unresolvable | Sonnet |
| TA.7 | rdfc2im cache: replace the `bluegenes-tools` group (18 unpatched 2021 tarballs) with the patched set plus jbrowse2-tool (shared with T1.2) | (in T1.2) | T1.2 | `cache verify`; the tool list on `:15001` equals HumanMine's 19 (no esyn-viewer) | Sonnet |

**Workstream A extra effort: about 10 agent-hours.** TA.1, TA.6 and TA.7 are counted inside
the milestone 1 beads.

### Milestone 2: Genomics England lists refreshed (on the small demo database)

**Gate.**
- The archive repository exists, with all 184 lists.
- `apply_public_lists` has loaded the current PanelApp panels plus the 13 legacy `PL_` lists
  into the demo mine, public and tagged.
- BlueGenes' hard-coded `PL_GenomicsEngland_GenePanel:Radial_dysplasia` resolves.
- A diff report against the December 2021 lists exists.

| ID | Title | Size | Deps | Gate | Who |
|---|---|---|---|---|---|
| T2.1 | Archive the current 184 HumanMine public lists (names, descriptions, tags, types, member identifiers) from public HumanMine into a new repository gmicklem/historic_artefacts, read-only export, dated directory, README; also copied to rdfc2im/curation/public_lists/ | S, 1-2 h | Gos creates the repository (or approves its creation) | 184 lists; member counts equal the `/service/lists` sizes; a README says how to hand a list to a user | Sonnet + Gos |
| T2.2 | rdfc2im tools/panelapp_lists.py: fetch all current PanelApp v1 panels, Green genes, cache group `panelapp/` (panel versions, date), map by Ensembl/HGNC/symbol | M, 2-3 h | D-10 (panelapp host allow) | a unit test on a recorded panel JSON; the unresolved report is empty or explained | Sonnet |
| T2.3 | full-build.sh phase apply_public_lists: run the archive step (T2.1 script) first, then upload the PanelApp lists plus the 13 legacy PL_ lists as superuser, tag them `im:public` and `Genomics England gene panel`, keep the names stable | M, 2 h | T2.1, T2.2 | on the demo, `/service/lists` shows them public; `Radial_dysplasia` resolves; a re-run adds a new archive directory and replaces the lists without duplicates | Sonnet |
| T2.4 | Run on the demo database; compare with the December 2021 lists (panels added, removed and changed; genes per panel) and write it up | S, 1 h | T2.3 | diff report in baselines/ | Sonnet; Gos reviews |
| T2.5 | Ask Genomics England whether they would publish PanelApp panels in a versioned repository (git or per-release snapshots) | human | none | answer recorded in decisions/ | Gos |

**Milestone 2 total: about 6 to 8 agent-hours.**
- It can start as soon as the PanelApp host is allowed and the archive repository exists.
- It does not wait for the full build. Milestone 3 re-runs T2.3 on the full mine.

### Milestone 3: complete HumanMine build, subset flag off, on the DBCLS server

**Gate.** Per-class and per-dataset counts are compared with public HumanMine (for example
64,160 human genes, 253,611 genes in all, and the DataSet list in §2.3). Each difference over
5% is explained (newer upstream releases are expected). mine-tests `[mines.humanmine]`
fixtures (PAX6) pass against the new build. It runs on the DBCLS server (D-9).
The build database is kept separate from the live HumanMine and FlyMine containers, so the
public mines are not disturbed. Then T2.3 re-runs the list import on the full mine.

| ID | Title | Size | Deps | Gate | Who |
|---|---|---|---|---|---|
| T3.1 | Prepare the DBCLS server (about 256 GB RAM) for full builds: build account; disk for the raw data directory and a separate build Postgres/Solr (size *unverified*; at least 500 GB est.); JDK, Docker, Gradle caches; outbound access to the data hosts; isolation from the live mine containers | human + Sonnet (runbook), 2 h agent | D-9 | `full-build.sh --dry-run` passes there; the live mines are untouched | Gos |
| T3.2 | rdfc2im full-build.sh: `--genes all` mode (no pre-filter, the full RDF extracts with `--limit 0` for every source, the full resolver), plus `reduce_mine.py` as a no-op when every stock source is present | M, 3 h | T0.1 | `--dry-run` shows no subset steps; the cache meta records `scope=full` | Opus |
| T3.3 | Wire the remaining milestone 3 sources: interpro, protein2ipr (stream filter by human accession), pubmed-gene, mgi-alleles, depmap-*, humanmine-static (datasets.xml), update-publications, update-data-sources, entrez-organism | L, 6-8 h | T3.2 | each integrates on a panel build first | Sonnet |
| T3.4 | Converter fixes found by current upstream files (est. 6-10 fixes at about 1 h: depmap file names, ncbi-gff MT and CDS, hpo, HPA, GTEx, uniprot XML drift, PANTHER 19, ...), each test-first | L, 8-12 h | T3.3 | fork CI green per fix | Sonnet |
| T3.5 | Decide replaced-or-stock per overlapping source at full scale (clinvar, gwascatalog, hgnc, ncbigene vs ncbi-gene, go vs go-annotation obo, hpo); fix the integration keys (GWASResult key, D14 ambiguity, Pathway/MeshTerm DRAFT keys, STATUS.md next steps 2-3) | M, 4 h | T3.2 | no duplicate Gene, Protein or Pathway objects (a duplicate-key query is empty) | Opus |
| T3.6 | First full build on the DBCLS server; watch, fix, resume (`--from`) | L, 6 h agent + about 1-2 days wall (est., *unverified*) | T3.1-T3.5 | build reaches verify | Opus |
| T3.7 | Count comparison against public HumanMine, plus mine-tests humanmine fixtures; write `baselines/humanmine-full-<date>.md` | M, 3 h | T3.6 | the milestone 3 gate | Sonnet |

**Milestone 3 total: about 32 to 38 agent-hours**, plus server preparation and about two
days of wall time (*est.*; the 256 GB server may be faster).

### Milestone 4 (later): shrink the HumanMine-loader dependency

For each stock source added above, open a follow-up when RDF Portal covers it. The
candidates are the "RP-possible" entries in §1.2:
- Ensembl FALDO locations, transcripts and exons (im-ore.18);
- UniProt sequences, isoforms, features and `reviewed`;
- the UniProt GO column (D4, im-ore.18);
- HPA, Bgee or RefEx expression;
- OMA orthologues;
- HINT interactions;
- MONDO and MedGen disease.

Each switch is gated by the same report-page test (T1.12) plus count parity with the stock
load.

---

## 6. Risks and unknowns

1. **Sandbox capacity.**
   - Only `repos/` is the host mount, with about **604 GB free**. The sandbox root and
     `/var/lib/docker` have about 5 GB free each; `worktrees/` and the Docker volumes live
     there.
   - Large raw data and Postgres data must therefore go under `repos/.sandbox-disk/`, using
     `RDFC2IM_PGDATA` / `RDFC2IM_SOLRDATA` bind mounts and the data root. That mount is
     virtiofs, where plain `cp` has produced NUL-filled files (BUILD.md) and fsync behaves
     differently (memory note "clone fsync quirk"). Postgres on it is *unverified*.
   - RAM is 15 GB now, with a 9 GB peak per demo build. The next sandbox session gets 75% of
     the Mac's RAM instead of 50% (about 22 to 24 GB, *est.*). That helps the hybrid demo
     builds, but **this sandbox cannot do the full build**.
   - The full build (milestone 3) runs on the **DBCLS server** that already hosts HumanMine
     and FlyMine (about 256 GB RAM, Gos; D-9). The risks move there:
     - the disk needed for raw data plus a second (build) database is *unverified*, likely
       hundreds of GB;
     - the build must not starve or disturb the live mine containers on the same host.
2. **Upstream drift is mostly unverified.** All but six data hosts are blocked from the
   sandbox. Every "format still OK" in §3 needs re-checking once D-10 is approved. HumanMine's
   own data dates from **February 2022**, so 4.5 years of format change are untested.
3. **Identifier merging between RDF and stock objects.**
   - Stock uniprot creates Genes from the XML `GeneID` dbref.
   - ncbi-gff and IdResolver-based loaders key on Entrez.
   - RDF ncbigene, hgnc and clinvar key on Entrez too (good), but the rdfc2im `uniprot` and
     `ensembl` sources merge on `symbol` / `secondaryIdentifier`. The 255 shared Ensembl ids
     (D14) can split or merge genes wrongly.
   - `genomic_priorities.properties` must list the stock source first for every field the
     alongside source also writes. The duplicate-object check belongs in every gate.
4. **Tool fragility.** The alignment service stops being a patch-only fix once T1.14
   restores it on the DBCLS server.
   - Two tools work only through hand patches to built bundles. A tool-store reinstall
     silently restores the broken bundles.
   - jbrowse2-tool is not on npm.
   - The MSA viewer's bundled `msa` library crashes in current browsers without the patch.
   - Until im-7os.49 publishes fixed packages, the testbed must re-apply the patches on
     every stage.
5. **Testbed front end.** The ut BlueGenes on `:15001` is a bare jar with no nginx. HumanMine
   relies on nginx for `/align-sequence`, `/vendor/imjs` and `/jbrowse2/`. T1.3 and T1.5 must
   add a proxy or accept cross-origin URLs, and that path is *unverified*.
6. **Subset semantics (D-1).** Panel-only gives empty or misleading interaction and homology
   sections. The thin-genome option's integrate and postprocess time is *unverified*.
7. **Licensing.**
   - OMIM, DisGeNET and KEGG cannot go into the public CI asset. HPA is share-alike.
     PanelApp's terms are unchecked.
   - A missing flag would publish restricted data in a GitHub release; T0.3's refusal test
     is the guard.
8. **Public list continuity.** A rebuild loses all 184 public lists unless they are
   re-created. The 2021 versions survive only in the `gmicklem/historic_artefacts` archive
   (T2.1), and only if that runs before any rebuild or refresh.
9. **Frozen or vanished upstreams.** The ArrayExpress Atlas API (E-MTAB-62), the
   `gene_summaries.txt` generator, `humanmine-static`'s `datasets.xml` repo, and how the
   2021 lists were made are all outside the cloned repos. Gos's `/micklem` copies may be the
   only source.
10. **5.1.1 compatibility.** The humanmine-bio-sources fork is on the 6.0 line, so the hybrid
   is 6.0.0 only. If Gos wants the 5.1.1 stack hybrid too, that is a second jar set and is
   *unverified*.
11. **Demo-versus-HumanMine protein counts.** The RDF uniprot loads TrEMBL linked by symbol
    (58 proteins for CYP2D6 against 2 on HumanMine). The MSA and protein tools will behave
    differently until D-6 is settled.
12. **Unverified in a browser.** None of the tool behaviour in §1.2 was observed in a
    rendered page in this session. It was derived from the tools' source and queries, the
    mine model, and the mine-tests and docker_template records.
