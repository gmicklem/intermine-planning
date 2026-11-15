# BlueGenes baseline, 2026-11-15 (beads im-rkn.4)

Measured on branch `dev`, HEAD 9f340692 ("dynamic favicon slows down dx"), in worktree
`/Users/gos/claude_projects/update_intermine_planning/worktrees/bluegenes/im-rkn.4-baseline`
(branch `maint/im-rkn.4-baseline`). No source changes were made. Gate script:
`scripts/gate-bluegenes.sh <worktree> [--with-prod] [--allow-no-browser]`.

## Result table

| Step | Command | Result | Wall time |
|---|---|---|---|
| cljfmt | `lein cljfmt check` | PASS ("All source files formatted correctly") | 7-8 s warm; 10 s first run with upstream lein; 46 s very first run (cold plugin deps) |
| npm | `npm ci` | FAIL as written (cypress postinstall); PASS with `CYPRESS_INSTALL_BINARY=0` | 41 s (cold, failed in postinstall); 5-7 s with cypress skipped |
| kaocha | `lein kaocha` (headless Chromium 153 arm64) | PASS, 27 tests, 132 assertions, 0 failures | 16-29 s warm; 27 s with 4 downloads; 265 s on first ever run (587 artifacts downloaded) |
| prod build | `lein prod` (= clean, assets, lessc -x, advanced cljsbuild, fingerprint-css, then run server) | PASS with upstream lein: serving on :5000 after 53 s. FAIL with the Debian-packaged lein (see Problems 1) | 53 s to listening; cljs advanced compile itself 28-35 s |
| uberjar | `lein uberjar` (prep-tasks `build`, `compile`, AOT all) | PASS, `target/bluegenes.jar` 56,262,757 bytes (54 MiB); thin `bluegenes-1.4.5.jar` 8.8 MB | 55-61 s |
| serve | `java -jar target/bluegenes.jar` (+ env defaults) | PASS, listening in about 2 s after JVM start, 5 s to first 200; RSS about 395 MB | - |
| gate, all steps | `gate-bluegenes.sh <wt> --with-prod` | PASS (rc 0) | about 2 min warm |

`lein prod` does not build an uberjar; it builds the minified CLJS/CSS then runs the server in the prod profile
(CircleCI's `lein prod &` for Cypress). The uberjar step is `lein uberjar` (what the Dockerfile and docs expect).
Cypress was not run (see Problems 4).

## Toolchain

- Ubuntu 26.04.1 LTS arm64, 10 cores, 15 GB shared. Default `java` is 25, so JAVA_HOME/PATH were set explicitly.
- JDK: OpenJDK 11.0.33 (`/usr/lib/jvm/java-11-openjdk-arm64`). JDK 8 fallback was not needed. CI uses openjdk-8 (lein 2.9.1), Dockerfile runs `gcr.io/distroless/java:11`.
- Leiningen: upstream 2.11.2 script from github (`/home/agent/tools/lein/lein`, `LEIN_HOME=/home/agent/tools/lein/home`). The Debian package `leiningen 2.11.2-1build1` at `/usr/bin/lein` is unusable for prod (Problems 1). Use `/home/agent/browser-scratch/env.sh` or let the gate pick it automatically.
- Node v22.22.1, npm 9.2.0 (package.json pins `engines.node: 10.x`; npm only warns `EBADENGINE`).
- Chromium 153.0.8010.0 headless (Sparticuz build, see Browser).
- Key versions from project.clj: Clojure 1.10.1, ClojureScript 1.10.520, re-frame 0.12.0, reagent 0.10.0, ring 1.8.2 (jetty 9.4.31), kaocha 1.0.700, kaocha-cljs 0-71, lein-cljfmt 0.6.1, lein-cljsbuild 1.1.7, imcljs 1.6.0, im-tables 0.15.0, bluegenes-tool-store 0.2.3. Project version 1.4.5. Less 1.7.5 (npm).

## Kaocha tests (suite `:unit-cljs`, 27 tests, 132 assertions, 0 failures, 0 errors)

Run in a browser via `cljs.repl.browser/repl-env` (server on :9000, browser opened through `xdg-open`).

- bluegenes.effects-test: retry
- bluegenes.regions-test: parsing-genome-regions (accepted formats in help text; weird chromosome and strand identifiers; leading and trailing whitespace; nil instead of chromosome/strand; interbase coordinate system; strand-specific search; extend genome region)
- bluegenes.querybuilder-test: get-all-subclasses, qb-menu->type-constraints
- bluegenes.templates-test: web-service-url
- bluegenes.lists-test: ensure-subpaths, normalize-lists, list->path, filtered-list-ids-set, path-title, top-level-predicates, denormalize-lists, copy-list-name, path-relation
- bluegenes.results-test: clean-query-parts-test
- bluegenes.events-test: replace-invalid-token, clear-invalid-login-token, reuse-login-token, new-anonymous-token, use-oauth2-token, reuse-anonymous-token, reuse-persisted-login-token
- bluegenes.utils-test: read-xml-query, highlight-substring, version-string->vec, compatible-version?, suitable-entities

Test order is shuffled between runs; counts were identical in every run. For per-test names run `lein kaocha --reporter kaocha.report/documentation`.

## npm

- `npm ci` as written fails: `cypress@6.9.1` postinstall tries `https://download.cypress.io/desktop/6.9.1?platform=linux&arch=x64`, which returns 403 in this sandbox, and Cypress 6 has no linux-arm64 binary in any case. With `CYPRESS_INSTALL_BINARY=0` it installs 385 packages (117 MB node_modules) cleanly. The gate sets that by default.
- Other warnings: `npm WARN old lockfile` (lockfileVersion 1, metadata refetched on every `npm ci`), `EBADENGINE` (node 10.x pin vs 22), about 25 `npm WARN deprecated` (request, har-validator, sntp, hoek, boom, cryptiles, hawk, node-uuid, rimraf 3, glob 7, core-js 2, bootstrap 3.4.1, several @hapi/*).
- `npm audit --json`: 45 vulnerabilities: critical 10, high 27, moderate 7, low 1 (info 0). Production deps only (`--omit=dev`): critical 9, high 18, moderate 7, low 1 (35).
  - critical: @cljs-oss/module-deps (direct), @cypress/request, babel-traverse, form-data, json-schema, jsprim, konan, minimist, mkdirp, request
  - high direct: cypress, less, ws; transitive include lodash, qs, semver, braces, minimatch, node-fetch, moment, y18n
  - moderate direct: bootstrap, wait-on
  Raw JSON: `<worktree>/.gate-logs/npm-audit.json` (regenerated by the gate).

## Warnings and deprecations

- ClojureScript advanced compile (`cljsbuild once min`): zero warnings. Output `app-c612493.js` 2,430,617 bytes, `site-c612493.css` 233,288 bytes.
- `lein uberjar`, `lein prod`, `lein kaocha`, `lein cljfmt check`: no WARNING/deprecation lines other than the JAVA_TOOL_OPTIONS "Picked up" notice.
- `lein deps :tree` prints "Possibly confusing dependencies": core.async 1.0.567 overrides im-tables' 1.1.587; muuntaja 0.6.7 vs reitit's 0.6.8; spec.alpha 0.2.176 vs 0.2.187; tools.reader 1.3.0 vs 1.3.2/1.3.4. Suggested exclusions are on reitit and im-tables.
- Runtime log at server start (non-fatal): `ERROR [bluegenes-tool-store.tools:31] Failed to acquire list of bluegenes-intermine-tool from api.npms.io: clj-http: status 403`. The sandbox blocks that host (and npms.io is itself a long-lived third-party API); `/api/tools/all` then returns `{"tools":[]}`. The server creates `./tools/tools.edn` in its cwd (gitignored `/tools/`); the gate runs the jar from a temp dir.
- index.html loads jquery, bootstrap, vega, font-awesome and gridlex from public CDNs (code.jquery.com, cdnjs, jsdelivr, maxcdn) at page load, so offline use breaks the UI. Not tested in a browser here.

## Server smoke test

`java -jar target/bluegenes.jar` with `BLUEGENES_DEFAULT_SERVICE_ROOT=https://www.flymine.org/flymine`, `..._MINE_NAME=FlyMine`, `..._NAMESPACE=flymine` (the config/defaults values) and default port 5000:
`/` 200 (43,532 B HTML), `/flymine` 200, `/version` 200 `{"version":"0.1.0"}`, `/api/tools/all` 200 `{"tools":[]}`, `/js/compiled/app-c612493.js` 200 (2.4 MB), `/css/site-c612493.css` 200. Unknown paths, including `/api/auth/oauth2authenticator` and `/api/rss/blog-posts` via GET, return the SPA HTML shell with 200. Server stopped afterwards. No call was made to a real mine from the server (the front end talks to the mine from the browser).

## Browser situation (what worked)

- `chromium-browser` / `chromium`: apt only provides a transitional stub that requires the snap; not usable. No google-chrome. `xdg-open` in this sandbox is a stub that asks the host to open the URL, so it must be shadowed (the gate does this).
- Playwright: `npx playwright@1.58.0 install chromium` first fails with "does not support chromium on ubuntu26.04-arm64"; `PLAYWRIGHT_HOST_PLATFORM_OVERRIDE=ubuntu24.04-arm64` gets past that, then the download from `playwright.download.prss.microsoft.com` returns 403 "Approval required" (`cdn.playwright.dev` the same). A host approval would make this route work. `storage.googleapis.com/chrome-for-testing-public` returns AccessDenied and `googlechromelabs.github.io` needs approval, so Puppeteer/Chrome for Testing was not attempted further.
- What worked: the arm64 build from `github.com/Sparticuz/chromium` release v153.0.0 (`chromium-v153.0.0-pack.arm64.tar`, 68 MB; the npm package ships x64 only). Unpacked (brotli) to `/home/agent/browser-scratch/chromium-arm64/` with swiftshader libs copied next to the binary and `LD_LIBRARY_PATH=.../al2023/lib`. It is a third-party Lambda-oriented headless Chromium 153.0.8010.0; fine for unit tests, not an official Google build. Flags: `--headless --no-sandbox --disable-dev-shm-usage --disable-gpu --no-proxy-server`. Note `--dump-dom` hangs on this build; kaocha does not use it.
- The gate finds a browser in order: `$GATE_BROWSER`, google-chrome-stable, google-chrome, chromium, chromium-browser (only if `--version` works), then the Sparticuz path above. Without one it exits non-zero unless `--allow-no-browser`.
- Cypress 6.9.1 cannot run on this box (no linux-arm64 binary, download host blocked), so CircleCI's second job (biotestmine plus Cypress) has no local equivalent here.

## Problems found

1. **Debian-packaged Leiningen drops transitive dependencies.** With `/usr/bin/lein` 2.11.2, `ring/ring-jetty-adapter` resolves to `jetty-server` only: `jetty-http`, `jetty-io`, `jetty-util` are never resolved (also reproduced in a one-dependency project and on JDK 8/11/17). `lein cljfmt check` and `lein kaocha` still pass, but `lein prod` fails after the CLJS compile with `ClassNotFoundException: org.eclipse.jetty.util.Attributes`, and `lein uberjar` fails the same way during AOT. Upstream lein 2.11.2 (script from github) resolves correctly (176 jars on the prod classpath vs 173) and also pulled 22 extra plugin jars (aws sdk etc.) for the lein plugins. Everything after the first runs in this document used upstream lein. The shared `~/.m2` now contains the complete set, but anyone using `/usr/bin/lein` will still hit the bug. Gate refuses to be fooled: it warns when Debian lein is selected and checks the jar for jetty classes.
2. `npm ci` fails on cypress postinstall (above). Workaround `CYPRESS_INSTALL_BINARY=0`.
3. Node 10.x engine pin is stale; builds work on Node 22 (less 1.7.5, chokidar-cli, wait-on all fine; only lessc is exercised by `lein build`).
4. Cypress not run per instructions; also not runnable here.
5. Lein shell-outs: `project.clj` runs `git describe --always` for the version, so the worktree must be a git checkout.

## Commands to reproduce

```
. /home/agent/browser-scratch/env.sh         # upstream lein, JDK 11
cd <worktree>
lein cljfmt check
CYPRESS_INSTALL_BINARY=0 npm ci
PATH=<dir with xdg-open shim>:$PATH lein kaocha   # or just use the gate
lein uberjar && (cd /tmp && SERVER_PORT=5000 java -jar <worktree>/target/bluegenes.jar)
scripts/gate-bluegenes.sh <worktree> --with-prod
```
