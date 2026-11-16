# Steps only Gos can take

Everything the agents could do without credentials, approvals or a judgement call that is
yours has been done or is tracked in beads. This page lists what remains for you, in the
order that unblocks the most. Each item names its beads id; close the bead (or tell the
orchestrator) when done. Updated 15 Nov 2026 22:15 UTC.

## 1. Release the BlueGenes sibling libraries to Clojars (im-7os.33, P1)

BlueGenes `maint-2026` consumes imcljs, im-tables and the tool store as git dependencies
(gmicklem forks pinned by sha) because nobody can publish to Clojars from the sandbox.
Follow `docs/RELEASING-siblings.md` in this repo: imcljs 1.7.0, then im-tables 0.16.0, then
bluegenes-tool-store 0.3.0 (lein deploy; move its project.clj to imcljs 1.7.0 first).
You need `CLOJARS_USERNAME` and a `CLOJARS_PASSWORD` deploy token.

After the three releases the agents switch bluegenes `deps.edn` back to `:mvn/version`
coordinates and delete the CI git-dependency workaround (`.github/workflows/ci.yml` lines
179-188, `build.clj` lines 206-228).

## 2. Publish InterMine 5.1.1 to Maven Central (im-89g.7, P1)

Branch `release/5.1.1-candidate` on gmicklem/intermine (d3ee1881dd) is the non-breaking
Gradle 6.9.4 line with the Tier 1 security fixes and eight jar/war hygiene backports; it
loads and runs in a Gradle 4.9 mine. OSSRH is dead, so publishing goes through the Central
Portal:

- Portal account with the `org.intermine` namespace verified, and a GPG signing key.
- Run `docs/RELEASING.md` in the intermine checkout (version bump, bundle build, Portal
  upload). central.sonatype.com is blocked in the sandbox, so the upload itself has never
  been exercised; expect to iterate once on the bundle layout.
- Then 6.0.0 from `maint-2026` (Gradle 8.14.6, JDK 8 and 17): same steps; im-89g.10 lists
  the wording and pin changes (humanmine/flymine forks from exact 5.1.1 to 6.0.+).

## 3. CDN hosts: done (16 Nov)

You approved cdn.jsdelivr.net and cdn.intermine.org in the sandbox. cdn.intermine.org is dead, so the
remaining references to it in the InterMine webapp (52 files, bag upload confirm page and the JS
code-generation templates) and im-tables are now bugs im-jqz.43 and im-7os.42, not approvals.

## 4. Merge the testbed branches you own (no bead; small)

- intermineorg/rdfc2im: `maint/im-ore.1-intermine-src` (pushed to gmicklem/rdfc2im) adds
  `--intermine-src DIR` and `--stack-name` so the demo mine builds from a local InterMine
  checkout (5.1.1 and 6.0 lines, 9b0f6be); `maint/im-rkn.5-testbed-baseline` holds the baseline fixes. BUILD.md documents both.
- intermineorg/mine-tests: `maint-2026` (pushed to gmicklem/mine-tests) adds the
  `[mines.local]` entry, capability flags and `MINE_TESTS_BROWSER_PATH`.

Open PRs from the gmicklem forks when you want them upstream; the agents never push to
intermineorg/* or intermine/*.

## 5. Review items flagged "for discussion with Gos"

- `decisions/0007-reagent-input-patch.md` (bluegenes a2894c0d): a start-up monkey-patch of reagent's
  input wrapper is what stops every text input dropping keystrokes under React 18 (0/6400 keys lost,
  measured). It touches non-public reagent API, guarded by a unit test. Keep it, or revert to
  per-input components?
- im-7os.28: BlueGenes now loads jQuery 3.7.1 (was 3.1.0) from cdnjs with SRI. Cypress is green
  including the admin specs, but nobody has clicked through popovers and dropdowns in a real browser.
- `decisions/package-vetting.md`: every package swap, with the vet verdict and reasons.
- `KeySigner.java` (intermine/webapp): bcprov removed; a ~90-line hand-written DER X.509 v3
  self-signed certificate writer replaces it (C4). Please read it or say whether you would
  rather keep bcprov at a current version.
- im-jqz.35 (P2): commons-lang 2.6 reaches a mine's compile classpath only through
  solr-solrj's POM (and objectstore for torque). Declare it `api` for deployer code, or drop
  it with torque?
- im-7os.26: DONE 16 Nov (HumanMine is the BlueGenes product default; bluegenes f2ddf4d5, imcljs 1b59843).
- im-ee7.23 (P2): bio/sources POMs now declare most dependencies in runtime scope
  (Gradle `implementation`). A deployer whose bio-source compiles against classes in an
  org.intermine bio-source jar must declare that dependency. Intended?

## 6. Later, with a Gradle 4.9 mine of your own

- im-ee7.49: DONE 16 Nov (gmicklem/humanmine-bio-sources 5d10274 and gmicklem/flymine-bio-sources
  9a943f7, branch maint-2026, build and publish on the 6.0 line); publishing to Central is still your
  step (same Portal credentials as InterMine).
- Upstream PRs `gmicklem:maint-2026 -> intermine:dev` following the contribution guide, once
  you are happy with the integration branches (intermine, bluegenes, imcljs, im-tables-3,
  bluegenes-tool-store, humanmine, flymine).

## Standing conditions in the sandbox

- GitHub token: everything pushes as gmicklem; the orchestrator checks `gh api user` before
  each remote operation.
- Hourly `status/STATUS.md` commits continue while the sandbox is up; sleeping the laptop
  pauses everything and the workers resume or are relaunched when you say "back".
