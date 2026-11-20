# Project access: where InterMine publishes, and who holds the keys

InterMine and BlueGenes are released through several outside services. Most of the accounts were set
up by developers who have left. This file records, for each service, what lives there, whether the
current maintainer (Gos Micklem, GitHub `gmicklem`) has access, and how access was or can be regained.
Work through an entry when a release needs it; update the entry when its state changes. No passwords,
tokens or keys in this file, ever: only where they are kept.

Status words: **have** (access confirmed by use), **unknown** (not checked), **missing** (checked, no
access), **not needed yet**.

## Have

| Service | What lives there | State | How access was obtained | Where the credentials are kept |
|---|---|---|---|---|
| GitHub organisation `intermine` | intermine, bluegenes, im-tables-3, imcljs and the other repositories | have (admin) | already held | Gos's GitHub account |
| Maven Central (Sonatype Central Portal), namespace `org.intermine` | the InterMine Java artefacts every mine build downloads | have (organisation admin since 20 Nov 2026) | new Portal account `gmicklem`; a TXT record on intermine.org; e-mail to Central support quoting the original registration ticket OSSRH-66082 (support request 131291) | Portal user token and the release signing key: `repos/.sandbox-disk/secrets/` on Gos's machine (in no repository), with a README |
| Release signing key | signs every artefact on Maven Central | have | created 20 Nov 2026: "InterMine Release Signing Key <info@intermine.org>", RSA 4096, expires 19 Nov 2031, fingerprint E725 F092 CFC8 B927 F51D E49E 10BC 4AAD F69E 0505; public half on keys.openpgp.org | as above |
| Clojars, group `org.intermine` | imcljs, im-tables and the other ClojureScript libraries | have (group member since Nov 2026) | a former developer added `gmicklem` to the group | Gos's Clojars account |
| DNS for intermine.org | domain verification records, service names | have | already held | Gos |
| info@intermine.org | project contact address (security reports arrive here) | have: forwards to Gos | already held | - |

## To check (not yet verified; listed from knowledge of the project, 20 Nov 2026)

| Service | What lives there | Why it matters | First step |
|---|---|---|---|
| npm, organisation or scope `intermine` | BlueGenes tools (the `@intermine/bluegenes-*` packages) and the JavaScript client `imjs` | BlueGenes installs its tools from npm; no fixed tool can be released without it | find the package owners with `npm owner ls <package>`; ask a former developer to add an owner, or use npm's dispute process |
| PyPI, project `intermine` | the Python client | widely used in users' scripts | see the maintainers on the PyPI project page; PyPI has an account-recovery and project-transfer process (PEP 541) |
| Bioconductor, package `InterMineR` | the R client | Bioconductor keeps one named maintainer per package | check the maintainer in the package DESCRIPTION; write to the Bioconductor core team to change it |
| CPAN (`Webservice::InterMine`), RubyGems (`intermine`) | Perl and Ruby clients | low use; needed only if they are released again | check owners; ask the registries |
| Docker Hub, organisation `intermine` | published images (BlueGenes, builder images) | Docker deployments pull them | check who owns the organisation; Docker Hub support can transfer an organisation |
| GitHub organisation `intermineorg` | docker_template, jbrowse, sequence-alignment-service | deployment recipes for the public mines | confirm Gos's role there |
| GitHub Actions secrets in the `intermine` organisation | deploy and publish tokens used by workflows | old tokens are probably expired; new ones are needed for automated releases | list the secrets (names only) per repository and decide which are still wanted |
| Read the Docs, project `intermine` | the documentation site | upgrade and release instructions are published there | check the project's maintainers; Read the Docs support can add one |
| Mailing lists and the project web site | announcements | needed for release and security announcements | confirm who can post and edit |
| Registry service (registry.intermine.org) and the dead CDN name (cdn.intermine.org) | the list of mines BlueGenes reads; old script hosting | BlueGenes depends on the registry | covered by the new registry work; decide where it is hosted |
| DBCLS server | FlyMine and HumanMine production | Gos has shell access; agents do not | nothing to do unless an agent is to work there |

## Good practice still to set up

- Private vulnerability reporting on `intermine/intermine`, and a `SECURITY.md` saying how to report
  (beads filed 20 Nov 2026).
- A second person with access to each "Have" entry, so that no service depends on one account.
