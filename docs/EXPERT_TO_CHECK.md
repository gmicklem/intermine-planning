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
