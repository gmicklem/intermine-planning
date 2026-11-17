# 0008: The InterMine Registry is rewritten in Clojure, without MongoDB, and its open questions

Status: accepted (Gos, 17 Nov 2026). Code: gmicklem/intermine-registry, branch maint-2026
(fork of intermine/intermine-registry; the Node/Express/MongoDB app by Leonardo Kuffo, GSoC 2017,
stays in the history and is acknowledged in the README).

## Decision

- The registry is a small Clojure web service (ring, compojure, hiccup; the tools BlueGenes already
  uses), serving the old read API unchanged for clients (BlueGenes, imcljs, im-tables) and a plain
  website without animation. The data is `resources/instances.edn`, version-controlled and
  spec-checked; no MongoDB, no accounts, no write endpoints (`POST`/`PUT`/`DELETE /service/instances`
  answer 405). Mines are added by pull request.
- Purpose (Gos): the registry signposts the range of public mines and lets one BlueGenes switch
  between them; it is not an uptime monitor. Hence: checks every 6 hours (not daily, not hourly),
  a mine becomes Unreachable only after 24 hours of failing checks, and unreachable mines stay
  listed with the reason (bot-protection page, timeout, html instead of json, http 403 ...) rather
  than disappearing.
- Logos are cached and served by the registry on a tile whose shade is chosen per logo from its
  measured luminance; a per-mine override shipped with the registry (`:logo-override`) wins over a
  mine's branding when that gives no usable logo (first use: PlanMine's planarian). A
  System / Light / Dark switch is in the header. `/map` draws the mines on a Natural Earth
  equirectangular outline from each entry's latitude/longitude; nearby mines are bumped into a ring
  with one label (Gos: "fine").

## The six questions and Gos's answers (17 Nov 2026)

1. `/service/namespace?url=` answers the exact match first (the Node app returned the first
   substring match in database order, which made the FlyMine URL answer `flymine.beta`). **Keep.**
   Gos adds: the non-production flag is really a *test* flag, for checking a mine's BlueGenes
   integration before release; call it that in the UI and docs (bead im-bdy.22; the API field stays
   `isProduction` and `?mines=dev|prod|all`, with `test` accepted as an alias of `dev`).
2. Mongo's `_id` and `__v` are dropped from the API. **Agreed.**
3. The 29 "Not Running" entries of the old export (YeastMine, RatMine, the legumeinfo mines,
   flymine.beta ...) are left out. **Agreed**; TargetMine alone was re-added on request (server under
   repair, listed Unreachable with the reason).
4. Mines answering HTML (URGI's bot check; PhytoMine's web app; AllianceMine until its real service
   root was found) are **kept listed with the reason**, not hidden.
5. Refresh cadence: **six-hourly, Unreachable after 24 h** (see above).
6. Deployment: the Compose fragment goes next to the mines; **detailed instructions requested**
   (docs/REGISTRY-DEPLOYMENT.md), to be followed after the other open items, then DNS moves and the
   Heroku app and the Atlas cluster are retired (bead im-bdy.13).

## Consequences

- Deployers who relied on `_id`/`__v` (none known) must use `id`/`namespace`.
- The data lives in git: adding a mine is a pull request, reviewed by a human, not a web form.
- Cached state (versions, branding, logos, last checks) lives in `REGISTRY_CACHE_DIR`, a Docker
  volume; losing it only costs one refresh.
- Related: [[0007-reagent-input-patch]] (BlueGenes), docs/INTERMINE_ORG_HOSTING.md,
  docs/REGISTRY-BACKUP.md, docs/SANDBOX-NETWORK.md.
