# Sandbox network allow-list

The Docker sandbox (`sbx`) blocks outbound hosts that are not on an allow rule; a blocked
request returns HTTP 403 "Approval required for <host>". Rules added with
`sbx policy allow network` are global (every sandbox on the Mac), so they should survive a new
`sbx` session; this file is the record of what Gos has approved, so that a new sandbox or a new
Mac can be set up in one command, and so that the orchestrator never asks twice.

Run on the Mac (safe to repeat; existing rules are kept):

```bash
sbx policy allow network repo1.maven.org,intermine.org,download.clojure.org,download.cypress.io,cdn.cypress.io,cdn.jsdelivr.net,registry.intermine.org
sbx policy allow network aquamine.rnet.missouri.edu,bar.utoronto.ca,faangmine.rnet.missouri.edu,hymenopteramine.rnet.missouri.edu,maizemine.rnet.missouri.edu,phytozome.jgi.doe.gov,phytozome-next.jgi.doe.gov,planmine.mpinat.mpg.de,s.gravatar.com,urgi.versailles.inra.fr,urgi.versailles.inrae.fr,www.alliancegenome.org,alliancemine.alliancegenome.org,www.mousemine.org
sbx policy allow network mizuguchilab.org,www.mizuguchilab.org,targetmine.mizuguchilab.org
```

To see what is in force: `sbx policy ls`; recent blocks: `sbx policy log`.

## Why each host

| Host(s) | Approved | Used for |
|---|---|---|
| repo1.maven.org | 15 Nov 2026 | intermine's configured Maven Central URL |
| intermine.org | 15 Nov 2026 | contribution guide, docs (https has a TLS fault; http works) |
| download.clojure.org | 15 Nov 2026 | Clojure CLI install |
| download.cypress.io, cdn.cypress.io | 15 Nov 2026 | Cypress binary for the BlueGenes nightly tests |
| cdn.jsdelivr.net | 16 Nov 2026 | BlueGenes CDN assets check |
| registry.intermine.org | 17 Nov 2026 | capturing the old registry's API before the rewrite |
| the mine hosts (Missouri x4, bar.utoronto.ca, JGI x2, planmine.mpinat.mpg.de, URGI inra.fr and inrae.fr, alliancegenome.org x2, mousemine.org) and s.gravatar.com | 17 Nov 2026 | the new registry's demo on port 3300 checks every mine's `/service/version*`, `/service/branding` and logo every six hours |
| mizuguchilab.org, www.mizuguchilab.org, targetmine.mizuguchilab.org | 17 Nov 2026 | TargetMine (re-added to the registry; server under repair) and its icon |

## Reachable from the first day (rule origin not verified from inside)

github.com and api.github.com, clojars.org, repo.maven.apache.org, plugins.gradle.org,
services.gradle.org, registry.npmjs.org, pypi.org, Ubuntu apt mirrors, Docker Hub, rdfportal.org,
humanmine.org, flymine.org, cdn.rawgit.com. The sandbox cannot see which of these are the sandbox
default policy and which are rules Gos added when the sandbox was created (`sbx policy ls` on the Mac
shows the rules and their origin); humanmine.org and flymine.org in particular were probably added by
Gos for the sprint rather than being defaults.

## Deliberately not allowed

- cdn.intermine.org: dead (502); references to it are bugs to remove, not a host to allow.
- api.adoptium.net, oss.sonatype.org, jitpack.io: not needed (JDKs come from apt; publishing goes to
  the Central Portal from the Mac).

## Keeping this file current

When the orchestrator asks for a new host, it adds the host here in the same commit as the work
that needed it, with the date and the reason. The planning repo is public; hostnames are not
secrets. If a host ever is sensitive (an internal server, a staging box), keep it out of this file
and in a private note instead.

## Hybrid HumanMine testbed data hosts (plans/50, approved in principle by Gos 17 Nov 2026, D-10)

Run before milestone 1 fetching starts (the loaders download from these; `www.humanmine.org` and
`registry.npmjs.org` already work):

```bash
sbx policy allow network ftp.ncbi.nlm.nih.gov,ftp.uniprot.org,rest.uniprot.org,ftp.ebi.ac.uk,www.ebi.ac.uk,current.geneontology.org,purl.obolibrary.org,data.pantherdb.org,www.informatics.jax.org,downloads.thebiogrid.org,reactome.org,search.rcsb.org,www.proteinatlas.org,storage.googleapis.com,panelapp.genomicsengland.co.uk,www.orphadata.com,download.rgd.mcw.edu,prod-media-panelapp.genomicsengland.co.uk
```

Not in that command, on purpose: omim.org, www.disgenet.org, depmap.org (restricted or account-gated
data; loaded only from Gos's local copies, decision D-7). jbrowse2.intermine.org is already allowed.

Checked 17 Nov 2026 22:40 UTC after Gos ran the command: every host answers (NCBI, rest.uniprot.org,
EBI x2, geneontology, PANTHER, MGI, BioGRID, Reactome, RCSB, Protein Atlas, GTEx on
storage.googleapis.com, PanelApp, Orphadata; purl.obolibrary.org redirects to
release-assets.githubusercontent.com, which also works). One exception: `ftp.uniprot.org` over https
connects through the proxy and then times out after 30 s (the host, not the policy); use the EBI mirror
`https://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/taxonomic_divisions/`
for the UniProt XML and FASTA files instead.

Added 18 Nov 2026 (Gos ran both; each answered 200 from the sandbox at 11:25 UTC) and now part of the
command above, so a new machine gets them with the rest:

- `download.rgd.mcw.edu`: RGD gene reports, for the rat partner-gene symbols of the PANTHER
  homologues (bead im-9n4.35).
- `prod-media-panelapp.genomicsengland.co.uk`: where PanelApp serves its Terms of Use PDF; needed to
  decide whether the cached panel data may be redistributed.

No other host was requested on 18 Nov. `jbrowse2.intermine.org` and `www.orphadata.com` were already
reachable. Still deliberately not allowed: omim.org, www.disgenet.org, depmap.org (decision D-7).

## Allowed on 18 Nov 2026 (second batch; Gos ran all three commands, checked 21:40 UTC)

Rule (Gos, 18 Nov 2026): whenever a request is blocked, tell Gos the exact command and add the host
to this file, so a new session on a new machine can be set up from it alone.

```bash
sbx policy allow network rgd.mcw.edu,web.archive.org,archive.org
sbx policy allow network www.pantherdb.org,www.gtexportal.org,hpo.jax.org,www.genenames.org,www.ensembl.org,www.ncbi.nlm.nih.gov,togovar.org,geneontology.org
sbx policy allow network www.nlm.nih.gov,www.uniprot.org,wiki.thebiogrid.org,interpro-documentation.readthedocs.io
```

- `rgd.mcw.edu`: RGD's licence and citation wording. `web.archive.org`, `archive.org`: the Wayback
  Machine (TargetMine's logo while its site is down).
- Licence pages (bead im-9n4.45): `www.pantherdb.org`, `www.gtexportal.org`, `hpo.jax.org`,
  `www.genenames.org`, `www.ensembl.org`, `www.ncbi.nlm.nih.gov`, `togovar.org`, `geneontology.org`;
  second statements: `www.nlm.nih.gov`, `www.uniprot.org`, `wiki.thebiogrid.org`,
  `interpro-documentation.readthedocs.io`.
- All answer through the proxy. Two still return 403 FROM THE SITE, not from the sandbox:
  `www.pantherdb.org` (its own HTML error page for a plain client) and `togovar.org` (a Cloudflare
  "Just a moment" challenge). A browser, or another route to the same statement, is needed for those.
- Not solvable by an allow rule either: IntAct's and InterPro's licence statements are on JavaScript
  pages of `www.ebi.ac.uk`; IntAct's text is readable at
  `raw.githubusercontent.com/Intact-portal/intact-portal-documentation` (allowed).

## Allowed on 18 Nov 2026 (third batch; Gos ran it, checked 23:10 UTC)

```bash
sbx policy allow network gtexportal.org,www.bgee.org,jun2026.archive.ensembl.org
```

- `gtexportal.org` (GTEx licence and release notes; `www.gtexportal.org` redirects to it),
  `www.bgee.org` (Bgee downloads, licence, SPARQL), `jun2026.archive.ensembl.org` (where
  `www.ensembl.org` redirects for the Ensembl disclaimer; the archive name changes with each release).
- `www.bgee.org` still answers 403 to a plain client from the site itself (not from the sandbox).
- No allow rule helps for these; a person must read them in a normal browser: PANTHER's terms
  (`https://www.pantherdb.org/tou.jsp`), TogoVar's terms (`https://togovar.org/doc/terms`), ClinVar's
  own data-use page (reCAPTCHA).
- `depmap.org` stays on the "deliberately not allowed" list (decision D-7); it was wanted only to read
  DepMap's licence page: `sbx policy allow network depmap.org` if Gos wants that.

## Requested, not yet allowed

- (allowed 20 Nov 2026; add on a new machine too) `archive.apache.org,dlcdn.apache.org`: Apache download sites (Ant, Tomcat). Needed to
  build and test the old 1.8 line; worked around through Maven Central, so optional.
  `sbx policy allow network archive.apache.org,dlcdn.apache.org`

- (allowed 20 Nov 2026; add on a new machine too) `depmap.org`: to read the DepMap licence and file list at source, so the three depmap
  data sources can be considered for the HumanMine build. `sbx policy allow network depmap.org`
  (Earlier notes in this file call depmap.org "deliberately not allowed (decision D-7)". That was the
  orchestrator's mistake: D-7 covers OMIM, DisGeNET and KEGG only. Gos never refused DepMap.)

- `keyserver.ubuntu.com,keys.openpgp.org` (20 Nov 2026): public key servers; Maven Central checks release
  signatures against a key published there. `sbx policy allow network keyserver.ubuntu.com,keys.openpgp.org`

(Allowed on 19 Nov 2026, to add on a new machine too:
`sbx policy allow network central.sonatype.org,dns.google,tomcat.apache.org,httpd.apache.org`
and, for publishing InterMine releases to Maven Central (20 Nov 2026),
`sbx policy allow network ossrh-staging-api.central.sonatype.com,central.sonatype.com`)
