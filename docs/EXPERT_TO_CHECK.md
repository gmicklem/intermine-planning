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
- **Reviewer, please check:** whether a newer reagent release fixes the underlying issue (then drop
  the patch), the interaction with im-tables' own inputs, and IME / composition events, which the
  Cypress keystroke spec does not cover.

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
