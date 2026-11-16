# intermine.org hosting: HTTP/HTTPS and Heroku findings

Investigated 2026-11-16, read-only, from inside the sprint sandbox. Method: DNS (`dig`/`getent`), `curl` GETs/HEADs, `gh api` against public GitHub metadata, and grep of the local repo checkouts. No logins, no writes.

Evidence tags used below: **[observed]** = I saw it directly; **[repo]** = stated in a repository file; **[inference]** = my reasoning, not verified; **[unreachable]** = the sandbox proxy blocked it (HTTP 403 "Approval required" / "no matching allow rule"), so nothing is known from here.

Sandbox caveat: the sandbox resolver answers only A records and returns empty answers for many names (including ones that exist), so NS/CAA/TXT/CNAME data could not be read, and "no DNS answer" below does not prove a name does not exist. The sandbox proxy also blocks many hosts outright.

## Summary

**Q1. Why is http://intermine.org/im-docs/... served over http, and how to fix it?**

- The apex site and all the "sub-sites" under it (`/im-docs/`, `/intermine-user-docs/`, `/identifiers-widget/`, `/internships/`, `/training-workshops/`, `/bosc-2018/`) are GitHub Pages [observed: `Server: GitHub.com`; `gh api .../pages`]. The apex is the user-site repo `intermine/intermine.github.io` with CNAME `intermine.org`; each sub-site is a project-site repo whose Pages are published under the same custom domain [observed].
- HTTPS is not usable at the moment. `https://intermine.org/` is answered with GitHub's generic `*.github.com` certificate (Sectigo, expires 2027-01-05), which does not match `intermine.org`, so browsers show a certificate error [observed]. GitHub has no certificate for the custom domain and `https_enforced` is `false` on every Pages repo checked [observed via the Pages API]. Plain http returns 200 with no redirect [observed], so the whole web presence is effectively http-only.
- Most likely cause [inference, consistent with GitHub's documentation as I remember it, verify]: `intermine.org` and `www.intermine.org` resolve to the **legacy GitHub Pages IPs 192.30.252.153 and 192.30.252.154** [observed], not the current `185.199.108.153` / `.109.153` / `.110.153` / `.111.153`. GitHub only issues Let's Encrypt certificates for custom domains whose DNS points at the current setup, so the certificate was probably never provisioned. A CAA record that excludes Let's Encrypt would give the same symptom; I could not read CAA from here.
- The fix is small and entirely at DNS plus GitHub settings level, with no self-hosting needed: (1) change the apex A records to the four current Pages IPs (and optionally add the four AAAA records), make `www` a CNAME to `intermine.github.io`; (2) in `intermine/intermine.github.io` -> Settings -> Pages, wait for the certificate, then tick "Enforce HTTPS"; (3) change the hard-coded `http://` base URLs in the site generators (Hugo `baseurl` and Docusaurus `url`, see Code references) and in BlueGenes/mine code so absolute links stop pointing at http. GitHub Pages then does the http->https redirect itself, so old http links keep working. One apex certificate covers all the `/im-docs/`-style sub-sites.
- Needs: DNS control of `intermine.org` (owner unknown, see Open questions) and admin on the `intermine` GitHub org / Pages settings.

**Q2. What is on Heroku and why, versus self-hosting?**

- I could not find any evidence that anything **current** runs on Heroku. The only Heroku hostnames in InterMine repos are historic: `staircase.herokuapp.com` (repo archived 2019), `intermine-neo4jwebapp.herokuapp.com` (GSoC 2017 neo4j prototype), `cross-intermine-search-tool.herokuapp.com` (GSoC 2018; the live homepage now links `cross-intermine-search-tool.apps.intermine.org` instead) [repo]. I could not reach any of them to see if they still respond [unreachable].
- `*.apps.intermine.org` and `*.labs.intermine.org` are almost certainly **self-hosted Dokku** ("Docker-powered mini-Heroku"), not Heroku: the repo `intermine/dokku-default-site` says "Default placeholder for when dokku on bert-vm is asked to serve an unknown subdomain" and `mineversions` says its live copy is at `mineversions.apps.intermine.org` [repo]. Dokku speaks the same `Procfile`/`.buildpacks` conventions as Heroku, which explains why BlueGenes (`Procfile`, `.buildpacks` pinning Heroku buildpacks) and `iodocs`/`intermod-site` (`Procfile`) look "Heroku-shaped" [repo]. `bert-vm` is a named VM; the owner (probably the Cambridge Micklem lab) is not stated [inference].
- Where Gos saw Heroku is therefore uncertain. The best candidate [inference] is **registry.intermine.org** (a Node/Express + MongoDB app, an obvious Heroku-plus-mLab/Atlas shape), but I could not resolve or fetch it from the sandbox [unreachable], and the registry repo contains no Procfile or Heroku reference [repo]. Heroku's free tier ended Nov 2022, so if the registry is on Heroku someone is paying (or it was moved to Dokku/another host); who is unknown.
- Recommendation: do not move anything *to* Heroku. Static parts stay on GitHub Pages (free, TLS automatic once DNS is fixed). The registry (the one dynamic service everything depends on) should be inventoried first, then moved, if it is on Heroku, to the same small VM/Dokku/Docker Compose host that already runs the apps and BlueGenes, with Caddy or the Dokku letsencrypt plugin for TLS. Details in the Heroku section.

## Inventory

DNS data comes from the sandbox resolver (A records only). "n/r" = not resolvable or not reachable from the sandbox.

| Host | DNS target | Hosting (tag) | http | https / certificate | What it serves | Source repo |
|---|---|---|---|---|---|---|
| intermine.org | A 192.30.252.153, .154 (legacy Pages IPs) [observed] | GitHub Pages user site [observed] | 200, no redirect, `Cache-Control: max-age=600` | Handshake succeeds but cert is `*.github.com` (Sectigo DV R36, exp 2027-01-05), name mismatch [observed] | Hugo homepage (last built 2022-05-27 per `Last-Modified`); hosts the docs sub-sites below | `intermine/intermine-homepage-2017` (Hugo, GitHub Action deploys to) `intermine/intermine.github.io` (CNAME `intermine.org`, branch master) |
| www.intermine.org | A same two legacy IPs [observed] | GitHub Pages | https request answered by GitHub with 301 to `http://intermine.org/` (note: redirects to http) [observed]; http blocked by sandbox policy [unreachable] | same `*.github.com` mismatch | alias of apex | same |
| intermine.org/im-docs/ | same | GitHub Pages project site of `intermine/im-docs`, branch gh-pages, `cname: null` [observed] | 200 on http | same mismatch | Docusaurus server docs (the "Get involved" page cited by Gos is `/im-docs/docs/intermine/get-involved/`; 200 on http, last modified 2022-08-31) [observed] | `intermine/im-docs` (workflow `documentation.yml`, `npm run deploy` with deploy key) |
| intermine.org/intermine-user-docs/, /identifiers-widget/, /internships/, /training-workshops/, /bosc-2018/ | same | GitHub Pages project sites, all `https_enforced:false` [observed] | n/t | same | user docs, widget demo, GSoC info, workshops | `intermine-user-docs`, `identifiers-widget`, `internships`, `training-workshops`, `bosc-2018` |
| docs.intermine.org | no answer [n/r] | unknown. Docs actually live at intermine.org/im-docs/ [observed] and legacy `intermine.readthedocs.io` (linked from `docusaurus.config.js`) | n/r | n/r | probably does not exist [inference] | none found |
| registry.intermine.org | no answer from sandbox resolver [n/r] | unknown; app is Node/Express + MongoDB [repo]. Heroku vs Dokku vs VM undetermined [inference only] | blocked by proxy [unreachable] | blocked [unreachable]. Swagger says `"host":"registry.intermine.org","schemes":["http"]` [repo]; imcljs and the mine webapp already call it over https | InterMine instance registry + REST API `/service/instances`; used by BlueGenes (mine list), imcljs, im-tables, iOS/R clients | `intermine/intermine-registry` (last commit 2020-11-23; no Procfile) |
| cdn.intermine.org | A 127.0.0.1 [observed] | decommissioned deliberately [observed; matches "known dead"] | proxy 500 | proxy 502 | was JS/CSS CDN | `intermine/CDN` (README says it is served from GitHub) |
| bluegenes.apps.intermine.org, data-browser.apps.intermine.org, gointermod.apps.intermine.org, mineversions.apps.intermine.org, cross-intermine-search-tool.apps.intermine.org, iodocs.apps.intermine.org | no answer [n/r] | Dokku on "bert-vm" [repo-based inference, see Summary] | blocked [unreachable] | blocked [unreachable] | BlueGenes demo, Data Browser tool, GO InterMOD, version checker, cross-mine search, API docs | `bluegenes`, `InterMine-Data-Browser-Tool`, `go-intermod-webapp`, `mineversions`, `cross-intermine-search-tool`, `iodocs` |
| *.labs.intermine.org (e.g. iodoc.labs.intermine.org) | no answer [n/r] | probably the same Dokku host (older naming) [inference] | blocked [unreachable] | blocked | old demo apps; referenced 43 times in the intermine repo only as a comment in generated Perl code | `iodocs` etc. |
| chat.intermine.org | no answer [n/r] | probably a redirect to the Discord invite [inference] | blocked | blocked | linked from intermine.org footer as `http://chat.intermine.org` | none |
| lists.intermine.org | n/t | https link on intermine.org; mailing list host | blocked | blocked | mailing lists | none |
| test.intermine.org | no answer [n/r] | unknown | blocked | blocked | `https://test.intermine.org/covidmine` used as example in `im-tables-3` | none |
| jbrowse.intermine.org | A 133.39.78.111 [observed] | nginx/1.27.1 [observed] | 200 | valid Let's Encrypt (YR2), exp 2027-01-31 [observed] | JBrowse 1 page (`Last-Modified` 2026-10-23) | `jbrowse` (local checkout) |
| flymine.org, www.flymine.org, www.humanmine.org | A 133.39.78.111 (same host as jbrowse) [observed] | nginx/1.27.1 in front of a BlueGenes build [observed] | 200 with no redirect to https | valid Let's Encrypt (YR2), exp 2026-12-14 (about 4 weeks away) [observed] | BlueGenes front-end ("InterMine 2.0 BlueGenes") pointing at `https://www.flymine.org/flymine` | flymine/humanmine repos and BlueGenes |
| humanmine.org (apex) | no A answer [n/r] | n/r | blocked | blocked | n/r | n/r |
| api.intermine.org, mines.intermine.org, data.intermine.org, apps.intermine.org, blog/training/bluegenes.intermine.org | no answer [n/r] | likely do not exist [inference] | n/r | n/r | none referenced in any repo | n/a |
| intermineorg.wordpress.com | n/t | WordPress.com (SaaS) | blocked | blocked | project blog | `blog-container` is an obsolete dockerised WordPress |

Notes on the last four rows with data: the flymine.org / humanmine / jbrowse results all point at one IP, 133.39.78.111, with a Let's Encrypt certificate, and the BlueGenes page there displays "Debug: Stylesheets not compiled" with version tag `46c4cc8`. This looks like a recent self-hosted deployment, possibly one of the sprint's own, but I could not tell from outside whether that is the production FlyMine/HumanMine or an environment particular to the sandbox network [inference; ask Gos]. http does not redirect to https on those hosts, and no `Strict-Transport-Security` header was returned on `www.flymine.org` [observed].

## HTTPS plan

### A. intermine.org and everything under it (GitHub Pages) - the main fix

Who can do it: someone with DNS control of `intermine.org` plus org admin on the `intermine` GitHub org (the token in this sandbox reported `admin: true` on `intermine/im-docs`, so Gos's account may already have the needed rights; I did not and will not change anything).

1. **Confirm no CAA conflict**: `dig CAA intermine.org` from a normal machine. If CAA exists it must allow `letsencrypt.org` (GitHub Pages uses Let's Encrypt).
2. **Fix DNS** at the registrar/DNS host (owner unknown):
   - Apex `intermine.org` A: 185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153 (replace 192.30.252.153/154). Optionally AAAA: 2606:50c0:8000::153, 2606:50c0:8001::153, 2606:50c0:8002::153, 2606:50c0:8003::153.
   - `www`: CNAME to `intermine.github.io.` (currently an A record to the legacy IPs [observed]).
   - Verify the values against the current GitHub docs ("Managing a custom domain for your GitHub Pages site") before applying; IPs are from memory.
   - Keep TTLs low during the change (they were not observable from here).
3. **Re-trigger certificate issuance**: in `intermine/intermine.github.io` Settings -> Pages, remove and re-add the custom domain `intermine.org` (the repo already has a `CNAME` file containing `intermine.org` [observed]). Provisioning usually takes minutes to an hour; DNS check must pass.
4. **Tick "Enforce HTTPS"** once available. Then `http://intermine.org/...` will 301 to https, including `/im-docs/`, `/intermine-user-docs/` etc., because they share the apex certificate. No change is needed in each project-site repo's Pages settings (they show `cname: null`, which is normal for project sites under a user-site custom domain). If the checkbox stays greyed, GitHub's Pages API (`gh api repos/intermine/intermine.github.io/pages`) will show `https_certificate` once provisioned; it is absent now [observed].
5. **Fix source URLs so generated links are https** (otherwise pages mix http links and https pages, and `www` keeps redirecting to http):
   - `intermine-homepage-2017/config.toml` line 1: `baseurl = "http://intermine.org"` -> `https://intermine.org`. Then rebuild and redeploy (GitHub Action `deploy.yml` pushes to `intermine/intermine.github.io`; its runner `ubuntu-18.04` and Hugo 0.82/Node 14 are long out of support, so the Action will likely need updating before it runs again; last deploy appears to be 2022-05-27 per the `Last-Modified` header).
   - `im-docs/docusaurus.config.js`: `url: 'http://intermine.org'` -> `https://`, navbar `href: 'http://intermine.org'` and the Discord footer `http://chat.intermine.org` -> https (the file is 3 KB; line numbers not captured). Rebuild with `npm run deploy` (the `documentation.yml` workflow runs it on push to master with Node 12, which also needs updating).
   - Same `url`/`baseUrl` check in `intermine-user-docs`, `identifiers-widget`, `internships`, `training-workshops`, `bosc-2018` (not inspected in detail).
   - The homepage itself loads logos from `https://cdn.rawgit.com/...` (19 references, e.g. `.../design-materials/78a13db5/logos/intermine/squareish/45x45.png`) [observed]. RawGit was shut down by its operator in 2019 [from memory, verify], so these images are probably broken independent of https; replace with files in the repo or `raw.githubusercontent.com` / jsDelivr.
6. **Add HSTS only after step 4 has been stable for a while**. GitHub Pages sets its own `Strict-Transport-Security` header when HTTPS is enforced; do not add `includeSubDomains`/preload at DNS level while `*.apps.intermine.org` and `registry.intermine.org` are still http-only.
7. **Redirect hygiene / cost of broken links**: with Pages "Enforce HTTPS" all old `http://` URLs (there are very many: BlueGenes, mine webapps, papers, the registry README) keep working via 301. Do not drop port 80 anywhere. Keep the `www` -> apex redirect, but make it https (after step 4 GitHub does that automatically).

Risk: low. If the cert never appears, the fallback is to put Cloudflare (free plan, proxy on, SSL "Full") in front of GitHub Pages, or to serve the same static output from the VM described below with Caddy.

### B. registry.intermine.org (hosting unknown)

Who can do it: whoever controls the host (Heroku account / Dokku VM / cloud console) and the DNS record.

- If it is on **Heroku**: add the custom domain with `heroku domains:add registry.intermine.org` on a paid dyno (Eco/Basic or higher); Automated Certificate Management (Let's Encrypt-based, as I remember Heroku's current offering, verify) is on by default for paid dynos. DNS: CNAME the host to the `*.herokudns.com` target Heroku gives. Then set the app to force https (an `x-forwarded-proto` redirect middleware in `app.js`, since Heroku terminates TLS).
- If it is on **Dokku**: `dokku letsencrypt:enable registry` after installing the `dokku-letsencrypt` plugin, plus `dokku letsencrypt:cron-job --add`; port 80 must be reachable from the internet for the HTTP-01 challenge.
- If on a **plain VM**: Caddy in front (automatic certificates, http->https redirect built in) is the least-maintenance path.
- In all cases: update `swagger.json` `schemes` from `["http"]` to `["https"]` and the README API URLs (`http://intermine.org/registry/service/`, `http://registry.intermine.org/api-docs/`) [repo].
- Clients already use https for the registry in the places that matter (see Code references), so no client breakage is expected once TLS works; the old http clients (vendored imjs 3.18.1 inside mine webapps) will break on https-only if the redirect is a 301 on a non-GET method or if HSTS blocks mixed content, so keep http->https as 301 on GET and test the vendored imjs.

### C. *.apps.intermine.org / *.labs.intermine.org (Dokku)

- On Dokku: `dokku letsencrypt:enable <app>` per app, or install the plugin and enable globally with `dokku letsencrypt:auto-renew`. Wildcard certificates are not needed; each app gets its own.
- Alternatively retire the apps that nobody uses (cross-intermine-search-tool, iodocs, mineversions, go-intermod, data-browser are all untouched since 2018-2020 [repo]) and stop linking to them. BlueGenes `home/views.cljs` currently links two of them over http (see below).

### D. flymine.org / humanmine / jbrowse (nginx + Let's Encrypt, 133.39.78.111)

- Certificates are already valid. Missing: an http -> 301 -> https server block and optional HSTS in the nginx config (http currently serves 200) [observed]. `docker_template` is the likely source of the config [inference]; the cert for flymine.org expires 2026-12-14, so confirm renewal is automated.

## Heroku findings and self-hosting recommendation

What I could and could not establish:

- **Present in the repos**: `bluegenes/Procfile` (`web: java -cp target/bluegenes.jar clojure.main -m bluegenes.core`) and `bluegenes/.buildpacks` (heroku nodejs v174 and heroku clojure v85 buildpacks) [repo]; `bluegenes/docs/building.md:149` says Dokku is the supported way and "You can also use BlueGenes with heroku"; `bluegenes-tool-store/src/clj/bluegenes_tool_store/core.clj:49` and `bluegenes/src/clj/bluegenes/core.clj:32` mention Heroku and Dokku only as examples of PORT-providing platforms; `im-tables-3/README.md:204` has a "Deploying to Heroku" recipe for its demo app. These are conventions and instructions, not evidence of a running Heroku app.
- **Historic Heroku URLs**: `staircase.herokuapp.com` (archived repo), `intermine-neo4jwebapp.herokuapp.com` (`intermine/neo4j` README), `cross-intermine-search-tool.herokuapp.com` (homepage repo partial `layouts/partials/cross-intermine-search.html`, now superseded by the apps.intermine.org host on the live homepage) [repo/observed]. Also `iodocs` and `intermod-site` carry Procfiles.
- **Unknown**: whether any of these are still deployed, which Heroku team/account owns them, and what plan/cost applies. From outside, `herokuapp.com` could not be reached through the sandbox proxy [unreachable]. Since Heroku's free dynos and free Postgres/Redis were withdrawn in November 2022 [from memory], anything left on a free plan has been offline since then; a surviving registry would need a paid dyno plus a Mongo add-on or external Mongo (Atlas), roughly in the order of a few tens of USD per month at the smallest paid tiers [inference; do not quote without checking current Heroku pricing].
- **Why Heroku was likely used** [inference]: GSoC student projects (2017-2018: registry, neo4j webapp, cross-mine search) needed a zero-ops way to publish a demo; the mentors could not easily hand students shell access on the lab VM. The consequence is orphaned apps tied to personal or student Heroku accounts.

Recommendation [inference, for Gos to confirm]:

1. **Static content (homepage, docs, user docs, workshops)**: stay on GitHub Pages. It is free, has no servers to patch, and TLS becomes automatic once the A records are corrected. Self-hosting these would add cost and duty with no benefit.
2. **The registry**: it is the only dynamic service that BlueGenes, imcljs, mine webapps (SemanticMarkupFormatter) and mobile/R clients depend on; an outage degrades the mine switcher in BlueGenes (`events/registry.cljs` shows an error toast). Keep one canonical home for it. Minimum viable self-host: one small VM (1-2 vCPU, 2 GB RAM) running Docker Compose with three services: the registry (`node ./bin/www`), MongoDB, and Caddy (automatic Let's Encrypt, http->https redirect, HSTS). Cost: a few USD per month from any VPS provider, or free on an existing university VM; needs a DNS A/AAAA record and port 80/443 open. Maintenance: OS patches, Mongo backups (a cron `mongodump`), and updating the app's ancient dependencies (`bcrypt ^3`, `mongoose ~5.7`, `request`) which no longer build on current Node.
3. **Alternatives**: Fly.io or Render (small paid instance plus managed Mongo/Atlas free tier, automatic TLS, git-push deploys) trade a few USD per month for no VM maintenance; keep Heroku only if an account is found that already pays for it and someone with owner rights will keep paying. Either way the registry needs an owner named in the repo, which it lacks (last commit 2020).
4. **Dokku apps**: nobody should add new apps; consolidate or retire. If kept, enable the letsencrypt plugin.
5. **TLS everywhere**: Caddy or the Dokku plugin handle renewal; a plain nginx + certbot setup (as flymine.org appears to use) needs a monitored renewal timer, because the flymine.org cert expires 2026-12-14.

## Code references that hard-code http:// intermine hosts

Update these when intermine.org and the other hosts go https. Paths are relative to the repo named in the first column; working checkouts are `repos/<name>` or `worktrees/intermine/merge-maint-2026` (named `intermine` here). Do NOT change XML namespace identifiers (`http://intermine.org/query/1.0`, `http://intermine.org/vocabulary/`, `http://www.intermine.org/aspectsXMLSchema`): they are names, not fetchable URLs, and changing them breaks validation and stored data.

**BlueGenes** (`repos/bluegenes`)
- `src/cljs/bluegenes/pages/home/views.cljs:114` `http://intermine.org/intermine-user-docs/`; `:118` `http://intermine.org/im-docs/docs/web-services/index`; `:236` `http://data-browser.apps.intermine.org/`; `:242` `http://gointermod.apps.intermine.org/`; `:299`, `:301`, `:305` `http://intermine.org/` (funding text and links)
- `src/cljs/bluegenes/events/webproperties.cljs:49` citation default `http://intermine.org/publications/`; `:68` `http://intermine.org/about-intermine/`; `:69` `http://intermine.org/privacy-policy/`
- `src/cljs/bluegenes/components/footer/views.cljs:35` `http://www.intermine.org`
- `src/cljs/bluegenes/pages/results/enrichment/views.cljs:289` `http://intermine.org/im-docs/docs/webapp/lists/list-widgets/enrichment-widgets/`
- `src/cljs/bluegenes/pages/querybuilder/views.cljs:346`, `:348` `http://intermine.org/intermine-user-docs/docs/the-query-builder...`; `:844` `http://intermine.org/im-docs/docs/api/pathquery/`
- `build.clj:249` POM `:url "http://www.intermine.org"`
- docs: `docs/useful-faqs.md:8` (`http://registry.intermine.org/`), `docs/building.md:311`, `:349`
- The registry itself is fetched via imcljs, not configured in BlueGenes (below); `HIDE_REGISTRY_MINES` (`docs/configuring.md:17`) turns it off.

**imcljs** (`repos/imcljs`)
- `src/cljc/imcljs/fetch.cljc:280` registry root `https://registry.intermine.org/service` (already https, but any change of registry hostname or path must be made here and in the next entries)

**InterMine mine webapp** (`worktrees/intermine/merge-maint-2026`)
- `intermine/webapp/src/main/java/org/intermine/web/fair/SemanticMarkupFormatter.java:71` `INTERMINE_REGISTRY = "https://registry.intermine.org/"` (https); `:289` provider url `http://intermine.org`
- `intermine/webapp/src/main/webapp/footer.jsp:34` and `:90` `http://intermine.org`, `http://www.intermine.org`
- `intermine/webapp/src/main/webapp/serviceLink.jsp:70`, `:75` `http://www.intermine.org/wiki/JavaScriptClient` and `http://intermine.org/wiki/JavaScriptClient` (the `/wiki/` path no longer exists on the Hugo site [inference], so this is a dead link as well)
- `intermine/webapp/src/main/webapp/apiJava.jsp:28` `http://intermine.org/intermine-ws-java/javadoc/`
- `intermine/webapp/src/main/webapp/WEB-INF/global.web.properties:66` `begin.thirdBox.link = http://www.intermine.org/`
- `intermine/webapp/src/main/webapp/WEB-INF/web.xml:3970` `http://iodocs.intermine.org` (comment)
- `intermine/api/src/main/java/org/intermine/api/query/codegen/WebservicePerlCodeGenerator.java:112` `http://iodoc.labs.intermine.org` (written into generated Perl; ~40 `.expected` test fixtures under `intermine/api/src/test/resources/org/intermine/api/query/codegen/` repeat it at line 18, so a change needs a fixture regeneration); `WebserviceRubyCodeGenerator.java:69`, `:70` `http://intermine.org/docs/ruby-docs/`, `.../ruby-bio-docs/`
- `bio/postprocess/create-intron-features/src/main/java/org/intermine/bio/postprocess/CreateIntronFeaturesProcess.java:122` `dataSet.setUrl("http://www.intermine.org")` (stored in the database as dataset URL; changing affects new builds only)
- Vendored libraries: `intermine/webapp/src/main/webapp/vendor/js/intermine/imjs/3.18.1/im.js:3022` and `.../im-tables/2.2.0-beta/imtables.js:45251` both set `ROOT = "http://registry.intermine.org/service/"`. These matter most: a mine served over https that loads these will have the registry call blocked as mixed content unless the registry redirects or the string is changed to https; and `imtables.js:14` still has `server: 'http://cdn.intermine.org'` (dead host)
- Mine-level: `jbrowse.install.url` is `https://jbrowse.intermine.org/` in `bio/webapp/src/main/webapp/WEB-INF/bio.web.properties:52` but `http://jbrowse.intermine.org/` in `humanmine/webapp/src/main/webapp/WEB-INF/web.properties:254`. `project.citation` in `flymine/.../web.properties:560` and `humanmine/.../web.properties:262` link `http://intermine.org/publications/`; `flymine/.../web.properties:499`, `:500` have commented-out `http://www.intermine.org/rgd/portal.do...` links.
- `project.releaseVersion` (`global.web.properties:17`, `@RELEASE_VERSION@`) is a version token and holds no URL, so no change is needed there.
- Already handled by sprint work: `global.web.properties:73` says the `cdn.intermine.org` references were removed; `WebUtil.java:285-300` warns when `head.cdn.location` is set; `htmlHead.jsp:99`.

**Other repos**
- `repos/im-tables-3/project.clj:4`, `build.clj:55` `http://www.intermine.org`; `src/im_tables/views.cljs:76` uses `https://test.intermine.org/covidmine` (host unreachable, example only)
- `repos/bluegenes-tool-store/project.clj:4`, `build.clj:40` `http://www.intermine.org`
- `repos/mine-tests/tests/service/test_tools.py:9` `DEAD_ALIGNER = "https://sequencealignment.apps.intermine.org"` (a host the tests already treat as dead)
- `repos/docker_template/README.md:205,251,362` and `nginx/nginx.conf.template:52` mention `cdn.intermine.org`, `sequencealignment.apps.intermine.org` and `jbrowse.intermine.org` in prose/comments

**Upstream GitHub-side references (not in a local checkout)**
- `intermine/intermine-homepage-2017/config.toml` line 1 `baseurl = "http://intermine.org"`
- `intermine/im-docs/docusaurus.config.js` `url: 'http://intermine.org'`
- `intermine/intermine-registry/swagger.json` `"schemes": ["http"]`; its README API URLs
- GitHub repo "homepage" metadata for ~25 repos lists `http://intermine.org`, `http://www.intermine.org`, `http://bluegenes.apps.intermine.org`, `http://registry.intermine.org` (editable in GitHub settings; cosmetic)

## Open questions for Gos

1. **Who owns the DNS for intermine.org** (registrar and nameservers)? `whois` is not installed and NS lookups are blocked here. Needed for the A/CNAME/AAAA/CAA changes.
2. **Does Gos's GitHub account have admin on `intermine/intermine.github.io`?** The Pages "Enforce HTTPS" checkbox and domain re-add need it. (The sandbox token reported admin on `intermine/im-docs`; I did not attempt any changes.)
3. **Where does registry.intermine.org actually run, and who pays?** I could not resolve or fetch it. Candidates: a Heroku app on a personal account, the Dokku VM `bert-vm`, or another host. Ask whoever deployed it (the registry's last committer was Daniela Butano in 2020; the original author was GSoC 2017 student Leonardo Kuffo). If nobody answers, `host registry.intermine.org` from a normal network will show a `*.herokudns.com` / `*.herokuapp.com` CNAME if it is Heroku, or an IP in a university range if it is Dokku or a VM.
4. **Who maintains the registry** going forward? The sprint plan treats it as a dependency (BlueGenes mine list); a named owner and a backup of its Mongo data are needed before any migration.
5. **Is 133.39.78.111 the production host for flymine.org / www.humanmine.org / jbrowse.intermine.org**, or is it an environment peculiar to this sandbox? If production, it should get the http->https redirect and HSTS, and its flymine.org certificate renews by 2026-12-14.
6. **Which `*.apps.intermine.org` apps are still wanted?** Most are not touched since 2018-2020; retire or move rather than add TLS everywhere.
7. **Is http-only intermine.org a known issue** that someone deliberately avoided (for example because a partner's embedded iframe or an old mine webapp depends on http)? Check for an existing issue in `intermine/intermine.github.io` before changing DNS.
8. **Should the homepage be rebuilt?** The last deploy is from May 2022 and its CI image (`ubuntu-18.04`, Hugo 0.82) no longer exists on GitHub; changing `baseurl` needs a working build, or the checked-in output in `intermine.github.io` can be edited with a `sed` replacement of `http://intermine.org` as a stop-gap.
9. **GitHub Pages IPs**: please double-check the four `185.199.x.153` addresses and the AAAA set against the live GitHub docs before changing DNS; I quoted them from memory.
