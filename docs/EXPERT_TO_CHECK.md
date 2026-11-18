# Items for an InterMine expert developer to check

Changes the sprint made that are correct as far as tests and the demo mine can show, but that
touch code or behaviour where a developer who knows InterMine's history should take a look.
Each entry says what changed, why, how it was verified, and what the reviewer should look for.
Gos decides the direction (recorded in `HUMAN-STEPS.md`); this log is the technical review queue.
Added items get a date; checked items move to the bottom with the reviewer's verdict.

## Open

### 1. KeySigner: hand-written X.509 writer replaces Bouncy Castle (16 Nov 2026)

- **Where:** intermine `intermine/webapp/src/main/java/org/intermine/web/security/KeySigner.java`
  (maint-2026 and release/5.1.1-candidate; sprint item C4, bcprov removal).
- **What it does:** when a mine configures trusted public keys (`security.publickey.*` in
  web.properties) for JWT bearer-token authentication, `KeyStoreBuilder` wraps each key in a
  self-signed X.509 v3 certificate so it can live in a Java key store; `JWTVerifier` later reads the
  public key back by alias. The certificate is only a container: nothing checks its signature or
  validity. HumanMine and FlyMine do not configure these keys, so the code path is skipped there.
- **Change:** bcprov 1.50 (used only here) removed; a ~90-line DER encoder builds the certificate
  with the JDK's `Signature` classes.
- **Verified:** `KeySignerTest` round-trips the certificate through the JDK `CertificateFactory`,
  checks the embedded public key, DN, validity window, that it verifies with the signing key, and
  other algorithms / unknown algorithm handling. Gate green on both lines.
- **Decision (Gos, 16 Nov 2026):** keep the hand-written writer; restoring bcprov at a current
  version is a one-line dependency change plus a small revert if the reviewer disagrees.
- **Reviewer, please check:** the DER structure (TBSCertificate field order, the
  AlgorithmIdentifier OIDs for the supported algorithms, time encoding UTCTime vs GeneralizedTime
  for dates after 2049), and whether any external consumer ever reads these certificates (we found
  none).

### 2. BlueGenes: start-up monkey-patch of reagent's input wrapper (16 Nov 2026)

- **Where:** bluegenes maint-2026, commit a2894c0d; design and measurements in
  `decisions/0007-reagent-input-patch.md` in the planning repo.
- **Why:** under React 18 (reagent 1.2, createRoot) stock reagent drops keystrokes in controlled text
  inputs: 57 of 5600 lost with createRoot, 277 of 6400 with legacy render, 309 of 6400 with flushSync.
  The patch replaces reagent's internal input handling so the DOM value is never overwritten by a stale
  render: 0 of 6400 lost.
- **Risk:** it touches reagent.impl.input, which is not public API. A unit test fails the build if
  the patched vars or their arity change, so a reagent upgrade cannot break it silently.
- **Decision (Gos, 16 Nov 2026):** keep for now; a ClojureScript developer should review it before
  the upstream PR. Alternative if rejected: an uncontrolled-input component at every text input in
  BlueGenes and im-tables.
- **Checked 16 Nov 2026 (im-7os.53):** reagent 2.0.1 does not fix it. Keys lost per 1600 typed: 1.2.0 without the
  patch 27; 2.0.1 on React 18 without the patch 100, with the patch 0; 2.0.1 on React 19 without 80, with 0.
  Under reagent 2 the loss moves from ratom-backed inputs to the inputs whose on-change dispatches a
  re-frame event (flushSync render queue). The patch carries over unchanged and its guard test passes on 2.0.1.
  Upstream issue posted 16 Nov 2026: https://github.com/reagent-project/reagent/issues/676 (draft kept in `docs/drafts/reagent-issue-keystrokes.md`).
- **Upstream fix (16 Nov 20:12 UTC):** reagent PR #680 merged on master with the same approach; the patch is
  to be dropped when a reagent release carries it (bead im-7os.62). The review question becomes: confirm the
  released reagent behaves the same on BlueGenes' inputs (keystroke spec) before deleting the patch.
- **Reviewer, please check:** the interaction with im-tables' own inputs and IME / composition events
  (upstream says #680 also fixes Korean IME), which the Cypress keystroke spec does not cover.

### 3. objectstore: Byte Buddy replaces cglib for dynamic (multi-class) objects (16 Nov 2026)

- **Where:** intermine maint-2026 (6.0 line only), commits fb900f033f and f7dfc76a7b; vetting entry in
  `decisions/package-vetting.md`; deployer notes in `docs/UPGRADING-build.md` ("cglib is gone").
- **What changed:** `DynamicBean` is now an `InvocationHandler` behind a Byte Buddy generated subclass
  implementing the model interfaces plus a new marker `org.intermine.model.DynamicObject`
  (replaces `net.sf.cglib.proxy.Factory`); generated names are `<Interfaces>_<Class>$$Dynamic`; classes
  are cached and loaded via a child class loader, so JDK 17 needs no `--add-opens`. NotXmlParser,
  Util.decomposeClass, CollectionUtil and TypeUtil follow. JDK proxies were rejected because the
  test model combines concrete classes with interfaces.
- **Verified:** 8 new tests; JDK 8 gate 2161/92/64/12 and JDK 17 suite 2161, 0 failures; testmine on
  JDK 17 loads Broke+Company/Contractor/CEO objects and serves them via the query service; getter
  cost unchanged, object creation about 30 ns slower.
- **Reviewer, please check:** stored class lists in existing databases that name
  `net.sf.cglib.proxy.Factory` (the parser skips the name; confirm nothing else persists it), the
  `setoBJECT` path now throwing UnsupportedOperationException, and any deployer code that tested
  `instanceof Factory`.

### 4. bio-source POMs publish most dependencies in runtime scope (16 Nov 2026)

- **Where:** intermine `bio/sources/build.gradle` (dependencies block, comment at lines ~105-125) and
  `bio/postprocess`; the POM mapping (`implementation` → runtime, `api` → compile) is in
  `config/gradle/publishing.gradle`; deployer notes in `docs/UPGRADING-build.md`, section
  "Dependency scopes in the bio-source POMs". Both lines: 5.1.1 (release/5.1.1-candidate) and 6.0
  (maint-2026).
- **What changed:** the 5.1.0 POMs listed every dependency of each `bio-source-*` jar in compile
  scope (the old `maven` plugin mapped Gradle's `compile` that way). Since the conversion to
  `implementation`/`api` (sprint batch I, 323 dependencies), only `bio-core`, `intermine-objectstore`,
  `intermine-model`, `ant`, `commons-collections`, the logging bridge, and what a source exposes in
  its converter constructors are compile scope; HikariCP, postgresql, commons-io, commons-lang3,
  commons-lang 2.6, commons-logging, jakarta.activation-api and `bio-model` are runtime.
- **Effect:** nothing for the mine build (the plugin puts bio-source jars on a runtime classpath).
  A deployer's own `*-bio-sources` project that compiles against classes inside an `org.intermine`
  bio-source jar gets only the compile-scope entries; a library its code imports that used to
  arrive by accident must now be declared (compile error names the package).
- **Verified:** installed POMs for all 76 artifacts diffed before/after the publishing cleanup
  (identical); humanmine-bio-sources and flymine-bio-sources forks build on the 6.0 line
  (im-ee7.49, 5d10274 / 9a943f7).
- **Decision (Gos, 16 Nov 2026):** keep runtime scope.
- **To revert:** in `bio/sources/build.gradle` and `bio/postprocess/build.gradle` change
  `implementation`/`runtimeOnly` to `api` for the third-party libraries (or add
  `java-library` + `api` for the whole block), rebuild, and check `build/publications/*/pom-default.xml`
  shows `<scope>compile</scope>`; no Java changes are involved. Partial alternative: promote only
  the libraries deployers report missing.
- **Reviewer, please check:** whether any class in a shipped bio-source's public API (constructor
  or protected method signatures) uses a type that is now runtime scope, which would make that
  source impossible to extend without an extra declaration.

### 5. chado-db SequenceProcessor: an always-true Integer comparison preserved as-is (16 Nov 2026)

- **Where:** intermine `bio/sources/chado-db/.../SequenceProcessor.java` around lines 1028 and 1471 (commit 16c4648620, the boxed-constructor sweep).
- **What we found:** `currentFeatureId != featureId` compared two distinct `new Integer(...)` objects by identity, so it was always true. Replacing the constructors with `Integer.valueOf` would have flipped it for ids up to 127 (cached boxes). The sweep kept the old behaviour as `currentFeatureId != null` with a comment.
- **Question for the reviewer:** the apparent intent is to reset `existingAttributes` only when the feature changes. Making it do so changes which attributes get set on chado-loaded features. Decide whether to fix (and re-test a chado load) or keep the historical behaviour.
- **To revert:** none needed; the behaviour is unchanged. The fix, if wanted, is `!Objects.equals(currentFeatureId, featureId)`.

### 6. objectstore: InterMine's own DDL generator replaces the vendored torque/velocity jars (16 Nov 2026)

- **Where:** intermine maint-2026 (6.0 line), commits e16f6f194d and a554fdc28b (merge 05a1f192ee);
  `org.intermine.objectstore.intermine.DdlGenerator`, `BuildDbTask`, plugin `DBModelPlugin`/`IntegratePlugin`;
  deployer notes in `docs/UPGRADING-build.md` ("Torque is gone (6.0.0)").
- **What changed:** the DDL for a mine database (CREATE TABLE statements, column types, `<table>_pkey`
  UNIQUE constraints, indirection tables, `intermine_metadata`, `osbag_int`, `clob`) is generated by ~300
  lines of Java from the objectstore properties and model instead of torque-gen 3.2-dev's velocity
  templates. The plugin's `createSchema` step and the `<os>-schema.xml` intermediate are gone;
  `schemafile` on buildDB is deprecated and ignored; the SQL is still written to `tempDir/<os>-schema.sql`.
- **Verified:** old and new DDL diffed for 12 objectstore configurations (test models, userprofile,
  production, bio genomic, HumanMine's 243-table model) after normalisation: 0 lines; `pg_dump
  --schema-only` of databases built both ways identical. 11 tests including snapshots of the torque
  output for five test objectstores, so drift is visible. Gates on JDK 8 and 17 green; buildDB runs for
  every test database and testmine.
- **To revert:** `git revert a554fdc28b e16f6f194d` restores the jars (they are in git history),
  `TorqueModelOutputTask`, the `createSchema` step and the torqueRuntime configurations; nothing else
  depends on the new class.
- **Reviewer, please check:** whether any deployer tooling consumed the `<os>-schema.xml` file or the
  `schemafile` attribute; whether a model feature the 12 configurations do not exercise (e.g. a
  non-default `missingTables` or `noNotXml` combination) could produce different DDL.

### 7. rdfc2im hybrid build: CrossReference key and stock uniprot load order (18 Nov 2026, im-9n4.6)

- **What changed:** in the rdfc2im hybrid testbed (not in InterMine itself), the generated
  `humanmine-items` keys now key `CrossReference` on `subject, identifier` instead of `identifier`
  alone, and the stock `uniprot` source is loaded before every rdfc2im (RDF) source (`load_first: true`
  in `rdfc2im/data/stock_sources.yaml`). rdfc2im commit 2526302, merged in 5a293d4.
- **Why:** no stock keys file declares a CrossReference key, so the first real stock load died with
  "Duplicate objects from the same data source"; and stock uniprot keys Protein on
  `md5checksum, organism` only, so when it loaded after the RDF hgnc source it created a second
  Protein per accession and 77 of 140 isoforms were left with a `canonicalProtein` pointing at a
  deleted object.
- **Verified:** ut build on the 114-gene panel: 0 duplicate Protein by accession, 0 duplicate Gene by
  primaryIdentifier or by symbol within 9606, 0 dangling canonicalProtein; live tests 25/25.
- **Side effect:** RDF-only builds also change: they used to fold every protein's copy of a
  cross-reference id into one object.
- **To revert:** `git revert 2526302` in rdfc2im (the stock uniprot load then fails as described).
- **Reviewer, please check:** whether `uniprot_keys.properties` should gain a Protein key on
  `primaryAccession` (it would remove the need for the load-order rule), and whether
  `subject, identifier` is the right CrossReference key for a production HumanMine build.

### 8. humanmine-bio-sources: four expression converters read the current upstream files (18 Nov 2026, im-9n4.14)

All in gmicklem/humanmine-bio-sources `maint-2026`, merged in 47ef066; each fix has a fixture test cut
from the upstream file of 18 Nov 2026 (README with URL, sha256 and licence beside each fixture).

- **ProteinAtlasConverter (ca78f06):** accepts `normal_ihc_data.tsv` (HPA renamed `normal_tissue.tsv`
  and added an "IHC tissue name" column) and finds Tissue, Cell type, Level and Reliability by header
  name; the old 6-column positions remain the default. **To revert:** `git revert ca78f06`.
  **Please check:** tissue is still taken from `Tissue`, not `IHC tissue name`; the level/reliability
  remapping stays commented out, so the new values load verbatim (Not detected/Low/Medium/High;
  Enhanced/Supported/Approved/Uncertain) and templates and tools must expect them.
- **ProteinAtlasConverter (c9d1606):** a new `close()` stores Tissue items that no
  `tissue_to_organ.tsv` names; before, without that file every ProteinAtlasExpression pointed at a
  Tissue that was never stored. `tissue_to_organ.tsv` has no known source (the converter calls it
  "homebrew"). **To revert:** `git revert c9d1606`. **Please check:** with a `tissue_to_organ.tsv`
  whose names differ in case, duplicate Tissue items can arise (already so before).
- **ProteinAtlasRNAConverter (a017552):** accepts `rna_tissue_consensus.tsv`. **To revert:**
  `git revert a017552`. **Please check:** `expressionType` stays "TPM" although the values are nTPM.
- **GtexConverter (7b83777):** the median-TPM header may start with `Name` (v8) as well as `gene_id`
  (v7). **To revert:** `git revert 7b83777`. **Please check:** the eQTL (`signif`) parsing still
  assumes the v7 12-column layout and was not touched.
- **AtlasExpressConverter (d24c4e5):** maps columns g1..g16 to the tissue names of
  `E-MTAB-513-configuration.xml` (hard-coded; the experiment is frozen), takes the median of the five
  comma-separated values, and sets the type to "TPM value" when the file name contains "tpm"
  (otherwise "FPKM value"). The source had no tests before. **To revert:** `git revert d24c4e5`.
  **Please check:** whether HumanMine's old file was a tissue-named single-value table and whether
  FPKM or TPM should be the loaded measure.

### 9. humanmine-bio-sources hpo-annotation: reads the current HPO files; Orphanet diseases now loaded (18 Nov 2026, im-9n4.15)

gmicklem/humanmine-bio-sources `maint-2026`, commit 7623497 (merged in d67fc5d); fixtures cut from HPO
release v2026-09-01 (README with URLs, sha256 and licence beside them). **To revert:** `git revert 7623497`
(the converter then requires the retired `.tab` files again).

- **phenotype.hpoa replaces `phenotype_annotation.tab` and `phenotype_annotation_negated.tab`** (HPO
  retired them); the old files are still read when `phenotype.hpoa` is absent. `genes_to_phenotype.txt`
  is read in its current 6-column form (disease in the last column).
- **New behaviour: `ORPHA:n` rows are loaded as `Disease ORPHANET:n`.** Before, only OMIM diseases were
  loaded. All 733 negated (`NOT`) annotations in the current file belong to Orphanet diseases, so this
  is the only way any negated annotation appears. `DECIPHER:` rows are skipped. **Please check:** whether
  Orphanet diseases should carry HPO annotations (Gene_Disease_HPO and Gene_HPOphenotype_2 show extra
  rows; a mine without the orphanet source gets Diseases without names). To undo only this: drop the
  `ORPHA` branch in `getDisease`.
- **OMIM `mimTitles.txt` (`hpo.disease.file`) is now optional for the current files.** It was used only
  to tell OMIM disease ids from gene ids in the retired files. **Please check:** without it, an `OMIM:`
  id that is really a gene entry would become a Disease (not expected in the current files).
- **`assignedBy` loses the `[date]` suffix and repeats are collapsed**
  (`HPO:iea[2009-02-17];HPO:probinson[2021-03-23]` becomes `HPO:iea;HPO:probinson`), to match the old form.
- **Stored verbatim / ignored:** `frequency` is stored as given (`8/10`, `HP:0040281`) in
  `frequencyModifier`; `disease_name`, `onset`, `sex`, `modifier`, `aspect` are ignored.
- **Not checked:** the converter was tested on fixtures and a column count of the full files, not run
  over the full 21 MB and 36 MB files; the first mine build with it is that check.
- **orphanet:** unchanged; a fixture test on the current `en_product1.xml` (JDBOR 1.3.42) passes.

### 10. rdfc2im hybrid build: interaction filter rules for IntAct and BioGRID (18 Nov 2026, im-9n4.13)

rdfc2im `tools/subset_raw.py filter --format psi-xml` (commits a0639c6, c2420b9; merged in d267d68). The
demo keeps an interaction when at least one participant is a panel gene. Three further rules were added
because the 2026 files needed them; each changes what a HumanMine user would see. **To revert:**
`git revert c2420b9 a0639c6` in rdfc2im (the two loaders then go back to unfiltered input).

- **Ensembl version suffixes are stripped from interactor xrefs** (`ENSG....27` becomes `ENSG...`;
  94,341 ids). IntAct now writes versioned ids, and PsiConverter resolves human interactors through
  `gene_info`, which has none: without this no human interactor resolves. **Please check:** whether
  PsiConverter itself should strip versions (a full, unfiltered build would hit the same problem).
- **Negative interactions are dropped** (923 records from IntAct's `*_negative.xml` files). Neither
  converter reads the negative flag, so they would load as real interactions. **Please check:** what
  HumanMine did with these in 2022, and whether the converters should model them.
- **Records with more than two participants are trimmed** to the panel participants and the ones the
  converter would pair with them (1,792 records). `InteractionDetail.allInteractors` on those records
  lists only the kept participants, not the whole complex. This is a subset-build device and must be
  off in a full build.
- **Verified:** Interaction 22,351, 0 duplicates; IntAct and BioGRID share one Interaction per ordered
  gene pair; every InteractionDetail has an experiment and a type; live tests 42/42.
- **Known gap:** the 5,994 human partner genes outside the panel are stubs with an Entrez id and no
  symbol until all human genes are loaded as identifiers (bead im-9n4.40).

### 11. rdfc2im hybrid build: gene merge rules with all human genes loaded; ontology cross-references (18 Nov 2026, im-9n4.40, im-9n4.41)

rdfc2im commits 3e5ffc9 and 9e46813 (merged in 9323d9d). With `--gene-identifiers all` the RDF `ncbigene`
and `hgnc` sources load every human gene (64,470; HumanMine 2022: 64,160). **To revert:** build with the
default `--gene-identifiers panel`, or `git revert 3e5ffc9` / `git revert 9e46813` in rdfc2im.

- **ncbigene and hgnc key Gene on the Entrez id only** (own keys files); ensembl, uniprot and
  gwascatalog keep the symbol and Ensembl keys. Reason: the NCBI and HGNC snapshots assign 9 symbols and
  109 Ensembl ids to different Entrez genes (e.g. KCNIP4-AS2; "RNR1" versus MT-RNR1), which would merge
  two genes through those keys.
- **Where they disagree, HGNC gives way to NCBI** (9 symbols and 106 Ensembl ids dropped from hgnc);
  Ensembl ids shared within a source are dropped (hgnc 6, ncbigene 492); ten tRNA symbols shared by 2
  to 17 records are dropped from every holder, as the stock loader does. Result: 111 genes without a
  symbol. **Please check:** these precedence rules against what HumanMine's stock ncbi-gene and hgnc
  loaders do.
- **`Gene.secondaryIdentifier` priority: hgnc before ncbigene** (applies to every build, panel
  included): ncbigene's missing value had starved the Ensembl id on 7,337 genes.
- **NCBI records of type biological-region, other and unknown are dropped** (130,304 of 194,018), as
  the stock loader does; chromosomes are limited to 1-22, X, Y (no MT, Un or X|Y objects).
- **Ontology cross-references follow InterMine's `obo_xrefs.properties`** (only FBbt, FMA, MA, WBbt,
  ZFA prefixes kept), for every RDF ontology source. Before, the RDF go source created 29,760 nameless
  "GOTerm" objects for Reactome/RHEA/EC targets; GOTerm is now 48,348 with 8 cross-references, as on
  HumanMine. HPOTerm 20,413, all named.
- **Item keys are ASCII-folded** ("Albers-Schonberg" and "Albers-Schönberg" synonyms were two items
  but one database key, which broke the hpo load).
- **Verified:** 0 duplicate Gene by primaryIdentifier, by (symbol, organism) and by
  (secondaryIdentifier, organism); PAX6 and CYP2D6 deep-annotation counts unchanged; live tests 56/56.
- **Known leftover:** hgnc at full scope brings 25,899 Publication stubs without titles.
- **Disease.dataSets:** the build deletes that line from the hpo-annotation additions in its own copy
  because rdfc2im makes `Disease extends BioEntity`. HumanMine's Disease extends Annotatable and needs
  the line, so the fork is deliberately NOT changed. **Please check:** should Disease be a BioEntity?

### 12. InterMine go-annotation: GAF `UniProtKB:` With/From ids now make `GOEvidence.with` Proteins (18 Nov 2026, im-9n4.46)

intermine `maint-2026`, commit 079ef219c2 (test a649372658; merged in 3dd6108dec; fixture cut from
goa_human.gaf of 2026-05-21, README beside it). GoConverter accepted only the prefix `UniProt:` in
column 8, so every GAF 2.x row (`UniProtKB:`) left `with` empty (the text was always kept in
`withText`). `UniProtKB` now maps to Protein by `primaryAccession` through the same no-organism branch;
the old spelling is kept.

- **Effect:** in the human GAF, 434,009 of 592,504 With/From rows now link, to 38,824 accessions.
  23,288 of those are not human Swiss-Prot entries and become stub Proteins with no organism and no
  other data (1,413 in the 114-gene panel build), including 3,514 isoform accessions (`P41271-2`)
  that never merge with a canonical Protein.
- **To revert:** `git revert 079ef219c2`.
- **Please check:** whether stub Proteins with no organism are acceptable, or whether with-links should
  be limited to loaded proteins, or isoforms reduced to their base accession; whether GoPostprocess or
  templates treat `with` Proteins as annotated products. MGI, RGD, PANTHER, InterPro and the other
  prefixes stay text only.

### 13. InterMine psi (IntAct): `InteractionExperiment.hostOrganism` is set (18 Nov 2026, im-9n4.46)

Commit 9ee7a6fb37 (test 5dfe26f648; fixture cut from IntAct human.zip of 2026-10-24). The host's
fullName was never stored because the parser's marker was reset by every start tag. It is now taken
from `experimentDescription/hostOrganismList/hostOrganism/names/fullName` only, so the 245,774
participant-level host lists in human.zip and cell-type names cannot overwrite it. The value stored is
the fullName string ("In vitro" for taxon -1, "Homo sapiens HEK293T embryonic kidney cell"); the
taxon id is not stored; the model is unchanged. `PsiConverterTest_tgt.xml` encoded the bug and was
updated.

- **To revert:** `git revert 9ee7a6fb37`.
- **Please check:** whether fullName (cell line included), shortLabel or the taxon is the wanted value;
  whether biogrid's `hostOrganism` follows the same convention; experiments merged by shortLabel keep
  the first host stored (51 labels have different hosts in different occurrences; already so before).

### 14. InterMine psi (IntAct): DataSet licence CC BY 4.0 instead of Apache 2.0 (18 Nov 2026, im-9n4.46)

Commit 6e1209b48c (test babbf505cb). The Apache-2.0 URL was a 2018 test placeholder (4a5181bc4f, "add
dummy licence info just for testing."). IntAct's licence page
(https://www.ebi.ac.uk/intact/about#license_privacy, read 18 Nov 2026) puts all data under CC BY 4.0
and only software and database dumps under Apache 2.0.

- **To revert:** `git revert 6e1209b48c`.
- **Please check:** the URL form (`https://creativecommons.org/licenses/by/4.0/`). The same 2018 commit
  set PANTHER's GPL URL, for which no statement by PANTHER has been found; it is not changed yet.
