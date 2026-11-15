# BlueGenes build migration: shadow-cljs + deps.edn (design study)

Beads: **im-7os.1** (E1, toolchain), **im-7os.2** (E2, library bumps), **im-7os.3** (E3, sibling libraries).
Status: design only. Nothing in this document has been run. Every claim cites the file it was read from.
Repos read (all under `repos/`): `bluegenes` (dev @ 9f340692), `imcljs`, `im-tables-3`, `bluegenes-tool-store`.
Related: [../plans/20-bluegenes.md](../plans/20-bluegenes.md), [package-vetting.md](package-vetting.md), `scripts/gate-bluegenes.sh`.

## 0. Summary of decisions

| # | Decision | Reason (evidence) |
|---|---|---|
| D1 | ClojureScript is built with **shadow-cljs 2.28.18** (bundles ClojureScript 1.11.132). Classpath comes from **deps.edn** (`:deps {:aliases [...]}` in `shadow-cljs.edn`). | `bluegenes/project.clj` has two cljsbuild builds plus a figwheel `user.clj` (`bluegenes/dev/user.clj`). shadow can replace both, and the dev hot reload too. |
| D2 | The server side and the uberjar are built with **tools.build** (`clojure -T:build uber`). No `lein` shim. | With lein kept, deps would be listed twice (project.clj plus deps.edn), and lein-tools-deps is unmaintained. tools.build can produce both artifacts we need: the uberjar `target/bluegenes.jar` (`Dockerfile`, `Procfile`) and the Clojars jar+pom (used by `rdfc2im/tools/full-build.sh:928-958`, which resolves `org.intermine:bluegenes:1.4.5` from Clojars and runs `java -cp lib/* bluegenes.core`, `rdfc2im/trial/docker-compose.yml:122`). |
| D3 | JS deps come from npm (React 18.3.1 at E2). **E1 keeps the current library versions** (React 16.13.1, reagent 0.10, re-frame 0.12, react-select 2.4.4...) and uses `cljsjs.*` **shim namespaces**, so the toolchain change is isolated from library changes. | `cljsjs.*` is required in only 2 files (`bluegenes/src/cljs/bluegenes/core.cljs:13-16`, `im-tables-3/src/im_tables/core.cljs:12-21`). App code reaches the libraries through `js/` globals (section 2), and a shim that sets those globals leaves app code untouched. |
| D4 | Unit tests use shadow **`:node-test`** as the gate. A **`:karma`** build with ChromeHeadless (Playwright chromium on arm64) is the fallback for any test that needs a DOM. kaocha-cljs and kaocha-cljs2 are dropped. | `bluegenes/tests.edn` uses `cljs.repl.browser`, which needs an `xdg-open` shim and a real browser (`scripts/gate-bluegenes.sh` step 3). The 35 tests (`bluegenes/test/cljs/bluegenes/*.cljs`) are re-frame event and pure-function tests with stubbed storage and fetch (`test_utils.cljs:12-71`). The only top-level DOM access is inside a `delay` (`events/registry.cljs:23`). |
| D5 | CSS stays on **Less**, bumped to **lessc 4.2.0** with `--math=always`. No move to postcss/plain CSS now. | Our own Less is about 9,000 lines (`bluegenes/less/**`), plus a Less-only Bootstrap-3 theme (`less/site.less:1` imports `node_modules/bootstrap-material-design`). Less 4's default `parens-division` would silently break `margin-top: @circle-diameter / 2;` (`less/components/idresolver.less:461`). |
| D6 | Node **22 LTS**. Cypress **13.17.0**. JDK **21** for build and runtime (Docker `eclipse-temurin:21-jre`). | `package.json` pins `"node": "10.x"` and `"cypress": "^6.0.0"`. The `Dockerfile` uses `gcr.io/distroless/java:11`. JDK 21 is installed in the sandbox (`/usr/lib/jvm/java-21-openjdk-arm64`). |
| D7 | During the sprint, siblings are consumed as **locally installed `-SNAPSHOT` jars** (`clojure -T:build install`). A `:siblings` alias with `:local/root` is for interactive work. Clojars release happens at the end, and is a human step. | Worktree paths vary per task (plans/40 decision 5), so a relative `:local/root` cannot work in worktrees. bluegenes needs im-tables' compiled CSS from its jar (`bluegenes/src/clj/bluegenes/prep.clj:12-26`), and a git dep would not contain it. |

Prerequisite: **the Clojure CLI is not installed in the sandbox** (`which clojure` finds nothing, only `/usr/bin/lein`). E1 step 0 installs it from `github.com/clojure/brew-install` releases (GitHub is reachable per `plans/30-testbed.md:20`).

## 1. Target toolchain

### 1.1 Files added to bluegenes (shapes, not final text)

`deps.edn`: runtime server deps go in `:deps`. ClojureScript-only deps go in an alias, so the uberjar stops shipping the ClojureScript compiler and Closure (today `org.clojure/clojurescript` is a main dependency, `project.clj:36`).

```clojure
{:paths ["src/clj" "config/defaults" "resources"]
 :deps  {org.clojure/clojure {:mvn/version "1.12.0"} ring/ring {:mvn/version "1.12.2"} ...
         org.intermine/imcljs {:mvn/version "1.7.0-SNAPSHOT"}
         org.intermine/bluegenes-tool-store {:mvn/version "0.3.0-SNAPSHOT"}}
 :aliases
 {:cljs     {:extra-paths ["src/cljs" "src/shim"]          ; src/shim only during E1
             :extra-deps {thheller/shadow-cljs {:mvn/version "2.28.18"}
                          reagent/reagent {...} re-frame/re-frame {...}
                          org.intermine/im-tables {:mvn/version "0.16.0-SNAPSHOT"} ...}}
  :cljs-dev {:extra-deps {binaryage/devtools {:mvn/version "1.0.7"} day8.re-frame/re-frame-10x {...}
                          day8.re-frame/tracing {...}}}
  :test     {:extra-paths ["test/cljs"] :extra-deps {day8.re-frame/test {:mvn/version "0.1.5"}}}
  :dev      {:extra-paths ["dev" "config/dev"] :jvm-opts ["-Ddevelopment=true"]}
  :prod     {:extra-paths ["config/prod"]}
  :siblings {:override-deps {org.intermine/imcljs {:local/root "../imcljs"}
                             org.intermine/im-tables {:local/root "../im-tables-3"}
                             org.intermine/bluegenes-tool-store {:local/root "../bluegenes-tool-store"}}}
  :fmt      {:deps {dev.weavejester/cljfmt {:mvn/version "0.12.0"}} :main-opts ["-m" "cljfmt.main"]}
  :outdated {:deps {com.github.liquidz/antq {:mvn/version "RELEASE"}} :main-opts ["-m" "antq.core"]}
  :build    {:deps {io.github.clojure/tools.build {:git/tag "v0.10.5" :git/sha "<from tag>"}
                    slipset/deps-deploy {:mvn/version "0.2.2"}} :ns-default build}}}
```

Notes:
- Classpath order: `:extra-paths` are prepended, so `config/dev` (or `config/prod`) shadows `config/defaults`. This matches the `:resource-paths ^:replace [...]` ordering in `project.clj:120,126`.
- `:development true` used to reach yogthos/config through `lein-environ` and `.lein-env` (`project.clj:91-93,124`). Now it comes from `-Ddevelopment=true`, which yogthos/config reads from system properties. The `:biotestmine` profile `:env` map (`project.clj:132-136`) becomes env vars (`BLUEGENES_DEFAULT_SERVICE_ROOT` etc.), as CircleCI already sets them (`.circleci/config.yml:9-16`).
- `src/cljc` and `src/workers` (in `:source-paths`, `project.clj:111`) do not exist, so drop them. `script/` contains only a figwheel `repl.clj`, so delete it.

`shadow-cljs.edn` (sketch):

```clojure
{:deps {:aliases [:cljs :cljs-dev :test]}
 :nrepl {:port 8777}
 :builds
 {:app  {:target :browser
         :output-dir "resources/public/js/compiled" :asset-path "/js/compiled"
         :modules {:app {:entries [bluegenes.core]}}     ; keep ^:export init + inline call (index.clj:173)
         :devtools {:after-load bluegenes.core/mount-root  ; was :figwheel {:on-jsload ...} project.clj:139
                    :watch-dir "resources/public"           ; CSS reload, was :figwheel {:css-dirs} project.clj:117
                    :preloads [devtools.preload]}           ; E2 adds day8.re-frame-10x.preload.react-18
         :dev {:closure-defines {re-frame.trace/trace-enabled? true
                                 day8.re-frame.tracing/trace-enabled? true}}
         :release {:module-hash-names true                  ; replaces :fingerprint true, project.clj:156
                   :closure-defines {goog.DEBUG false}}}
  :test  {:target :node-test :output-to "target/test/node-tests.js" :ns-regexp "-test$"}
  :karma {:target :karma :output-to "target/karma/test.js" :ns-regexp "-test$"}}}
```

- The version define `bluegenes.version.release` (`project.clj:158`, read by `src/cljs/bluegenes/version.cljs:5`) is passed by build.clj as `--config-merge '{:closure-defines {bluegenes.version/release "<git describe>"}}'`.
- `:asset-path` used to be prefixed with `BLUEGENES_DEPLOY_PATH` (`project.clj:17-29,144`). Only dev builds need that, so the Makefile adds `--config-merge '{:asset-path "<path>/js/compiled"}'` when the env var is set.
- `package.json` gains `shadow-cljs` 2.28.18 as a devDependency (same version as the Clojure artifact) plus the npm libraries from section 2.

**Fingerprint format change (must-fix).** `bluegenes/src/clj/bluegenes/utils.clj:6-43` reads `public/js/compiled/manifest.edn` in cljsbuild's shape (`{"resources/public/js/compiled/app.js" "…/app-HASH.js"}`) and extracts the hash with `#"app-(.*)\.js"`. shadow writes a vector, `[{:module-id :app :output-name "app.HASH.js" …}]`, to the same path.
- Rewrite `read-fingerprints`, `get-bundle-path` and `parse-bundle-hash` (regex `app\.(.*)\.js`).
- `insert-filename-css` (`site-HASH.css`) can stay.
- The hash also has to change on every build: it invalidates persisted client state (`src/cljs/bluegenes/events/boot.cljs:181`, `events.cljs:113`).

`build.clj` tasks:

> **As implemented (im-7os.1):** both `uber` and `jar` AOT-compile `bluegenes.core` only (`:ns-compile '[bluegenes.core]` with `:filter-nses '[bluegenes.core]`); every other namespace loads from source at start-up (6-11 s instead of about 2 s). `:filter-nses '[bluegenes]` as planned below does not work: AOT-compiled compojure routes embed `clout.core.CompiledRoute` records, so `java -cp lib/* bluegenes.core` fails with `NoClassDefFoundError` before clout is loaded, and the path prefix `bluegenes` also keeps `bluegenes_tool_store/*.class`. Keeping all classes (lein's `:aot :all`) is not portable either: classes compiled on JDK 21 fail on JDK 17 (instaparse then needs `java.util.SequencedCollection`), and rdfc2im runs the Clojars jar on JDK 17. The release file hash is also computed by build.clj from the build inputs, not by `:module-hash-names` (see docs/building.md).

| Task | What it does |
|---|---|
| `clean` | Deletes `target`, `resources/public/js/compiled`, `resources/public/css`. |
| `assets` | Runs `bluegenes.prep/prepare-assets` (`prep.clj:28`) on the `:cljs` basis, which copies im-tables CSS from the classpath. Change its arity to `[_]` so it can also run as `clojure -X`. |
| `css` | `npx lessc --math=always less/site.less resources/public/css/site.css`. |
| `cljs` | `npx shadow-cljs release app --config-merge ...`. |
| `fingerprint-css` | Runs the existing `prep.clj:31-38`. |
| `release` | `clean`, `assets`, `css`, `cljs`, `fingerprint-css` in sequence: the old `lein build` alias. |
| `uber` | `release`, then `compile-clj` of `bluegenes.core` (it has `:gen-class`, `core.clj:9`), then `b/uber` to `target/bluegenes.jar` with `:main bluegenes.core`. |
| `jar` | `release`, then `compile-clj` with `:filter-nses '[bluegenes]`, `write-pom` and `jar`. This is the Clojars artifact, keeping the `java -cp lib/* bluegenes.core` contract. |
| `install` | Installs to the local Maven repository (`~/.m2`). |
| `deploy` | deps-deploy to Clojars. |

Makefile: replace the current `less`/`less-prod` targets (`bluegenes/Makefile`) with the targets in 1.2. Use `make -j2` for parallel watchers instead of lein-pdo, which avoids adding `concurrently` to npm.

`dev/bluegenes/dev.clj` (replaces `dev/user.clj`, `figwheel.clj` and `script/repl.clj`). It starts everything in one JVM: `(shadow.cljs.devtools.server/start!)`, `(shadow.cljs.devtools.api/watch :app)`, then `(bluegenes.core/-main)`, the old `lein dev`/`lein repl` behaviour (`project.clj:119-121` `:repl-options {:init (-main)}`). nREPL comes from shadow on :8777, and the cljs REPL via `(shadow/repl :app)`. `wrap-reload` keeps working because it is driven by `:development` (`handler.clj:21`).

Dockerfile: multi-stage. The build stage uses `clojure:temurin-21-tools-deps` plus Node 22 and runs `npm ci && clojure -T:build uber`. The runtime stage is `eclipse-temurin:21-jre` with `COPY target/bluegenes.jar /` and `CMD ["java","-jar","/bluegenes.jar"]`. `Procfile` (`java -cp target/bluegenes.jar clojure.main -m bluegenes.core`) works unchanged. Delete `.buildpacks` (it pins the lein-only heroku clojure buildpack v85) and document Dokku deploys through the Dockerfile.

### 1.2 Command map (bluegenes)

| Old (`project.clj` aliases :85-108, profiles :112-136) | New | Notes |
|---|---|---|
| `lein dev` (clean, assets, pdo less-watch + `with-profile +repl run`) | `make dev` = `clojure -T:build clean assets` then `make -j2 css-watch app-dev`; `app-dev` = `clojure -M:dev:cljs:cljs-dev -m bluegenes.dev` | Jetty on :5000, shadow websocket on :9630. Check the CSP and proxy for the ws port. |
| `lein repl` | same as `make dev`; connect to nREPL :8777 | |
| `lein build` | `clojure -T:build release` | |
| `lein prod` | `make prod` = `clojure -T:build release && clojure -M:prod -m bluegenes.core` | CircleCI runs this as the Cypress server (`.circleci/config.yml:85-87`). |
| `lein biotestmine` | `make localmine` = `release` + `BLUEGENES_DEFAULT_SERVICE_ROOT=${MINE:-http://localhost:8090/humanmine} … clojure -M -m bluegenes.core` | Target the rdfc2im mine (`plans/30-testbed.md:9`). |
| `lein uberjar` (`:uberjar` profile, `:aot :all`) | `clojure -T:build uber` | Output `target/bluegenes.jar`. The uberjar contains `config/defaults` only (`project.clj:127`). |
| `lein deploy` | `clojure -T:build deploy` (needs `CLOJARS_USERNAME`, `CLOJARS_PASSWORD`) | Human step. |
| `lein format` / `lein cljfmt check` | `clojure -M:fmt fix` / `clojure -M:fmt check` | Move the config to `.cljfmt.edn`. Since cljfmt 0.11, `:indents` **replaces** the defaults, so rename it to `:extra-indents` (`project.clj:95-97`). Expect one reformat commit. |
| `lein kaocha`, `bin/kaocha` | `make test` = `npx shadow-cljs compile test && node target/test/node-tests.js`; `bin/kaocha` becomes `exec make test` | Fallback: `npx shadow-cljs compile karma && npx karma start --single-run`. |
| `lein tools` | `clojure -M -m bluegenes-tool-store.tools` | |
| `lein less` | `make css-watch` (`npx chokidar "less/**/*.less" -c "npx lessc --math=always …" --initial`) | |
| `lein assets` | `clojure -T:build assets` | |
| `lein fingerprint-css` | `clojure -T:build fingerprint-css` (inside `release`) | |
| `lein ancient` | `clojure -M:outdated` | |
| `lein codox` | drop (bluegenes docs are not published) | |
| `:java9` profile | drop | |
| `lein release` (`:release-tasks`, `project.clj:177-181`) | manual steps in `docs/building.md` (section 5.3) | |
| `npm test` (Cypress) | `npx cypress run` (Cypress 13) | |

**The gate script must change in the same merge.** `scripts/gate-bluegenes.sh` refuses any directory without `project.clj` ("not a bluegenes checkout") and calls `lein cljfmt check`, `lein kaocha`, `lein build` and `lein with-profile uberjar uberjar`. Make it dual-mode: if `deps.edn` and `shadow-cljs.edn` exist, use the new commands. The browser and `xdg-open` shim logic is only needed for the karma fallback.

## 2. cljsjs to npm (all four repos)

imcljs and bluegenes-tool-store have no cljsjs dependencies (`imcljs/project.clj`, `bluegenes-tool-store/project.clj`). tool-store is JVM-only: it downloads tool tarballs from `registry.npmjs.org` at runtime (`bluegenes_tool_store/package.clj:59`). It has no npm build of its own.

| cljsjs artifact (declared in) | Required at | `js/` sites (code that must change at E2) | npm, E1 (shim, same version) | npm, E2 target |
|---|---|---|---|---|
| `cljsjs/react`, `react-dom`, `react-dom-server` (transitive via reagent 0.10) | implicit | `reagent.dom/render` (`bluegenes/core.cljs:26`, `im_tables/core.cljs:30`); `reagent.dom.server` (`im_tables/views/core.cljs:82`, `views/table/body/main.cljs:21`, `components/bootstrap.cljs:44`) | `react@16.13.1`, `react-dom@16.13.1` (shadow maps `cljsjs.react` itself) | `react@18.3.1`, `react-dom@18.3.1` |
| `cljsjs/react-select 2.4.4-0` (bluegenes `project.clj:55`, im-tables `project.clj:19`) | `bluegenes/core.cljs:16`, `im_tables/core.cljs:14` | `js/Select.Creatable`: `bluegenes/components/ui/constraint.cljs:142,164`, `components/select_tags.cljs:24`, `pages/lists/views.cljs:569`. `js/Select`: `pages/admin/views.cljs:178`, `im_tables/views/table/head/controls.cljs:176,197` | `react-select@2.4.4`; shim `(set! js/Select rs/default)` plus `.-Creatable` from `react-select/lib/Creatable` | `react-select@5.8.0` or later 5.x: `["react-select$default" :as Select]`, `["react-select/creatable$default" :as Creatable]` |
| `cljsjs/react-day-picker 7.3.0-1` (bluegenes `:54`, im-tables `:18`) | `bluegenes/core.cljs:15`, `im_tables/core.cljs:13` | `js/DayPicker.Input`: `bluegenes/components/ui/constraint.cljs:118`, `im_tables/views/table/head/controls.cljs:145`; CSS `bluegenes/less/components/calendar.less`, `im-tables-3/less/calendar.less` | `react-day-picker@7.3.0` (`react-day-picker/DayPickerInput`) | **remove**: native `<input type="date">` (section 7). Fallback `react-day-picker@7.4.10` (v8 has no `DayPickerInput`). |
| `cljsjs/react-transition-group 1.2.0-0` (bluegenes `:47`, im-tables `:10`) | `bluegenes/core.cljs:14`, `im_tables/core.cljs:12` | `js/ReactTransitionGroup.CSSTransitionGroup`: used at `pages/results/enrichment/views.cljs:16,173`, `pages/regions/views.cljs:20,~244`, `im_tables/views/table/head/controls.cljs:17,501`; defined but unused at `pages/templates/views.cljs:37` | `react-transition-group@1.2.1` (v1 API) | **remove**: a CSS `@keyframes` fade on mount (section 7). Fallback `react-transition-group@4.4.5` with `TransitionGroup` + `CSSTransition`. |
| `cljsjs/highlight 9.12.0-2` + 6 `langs.*` (im-tables `:12`) | `im_tables/core.cljs:15-21` | `js/hljs` `:highlightBlock`: `im_tables/views/dashboard/manager/codegen/main.cljs:67,71`, `views/table/error.cljs:48`. CDN CSS 9.12.0 `bluegenes/src/clj/bluegenes/index.clj` (head), `im-tables-3/less/highlight.less` | `highlight.js@9.12.0`; shim `(set! js/hljs hljs)` | `highlight.js@11.9.0` or later 11.x: `highlight.js/lib/core` + register javascript, perl, python, ruby, java, xml. `highlightBlock` becomes `highlightElement`. Bump the CDN CSS to the same version (E4). |
| `cljsjs/google-analytics 2017.09.21-0` (bluegenes `:76`) | `bluegenes/core.cljs:13` | none: no `js/ga` anywhere. Analytics uses `js/gtag` (`events/boot.cljs:300-301`, `effects.cljs:64,374-375`, `route.cljs:290`), loaded from googletagmanager by `index.clj` | none | **remove** |

Globals that are **not** cljsjs and stay as CDN script globals (handled in E4, not here):
- jQuery 3.1.0 and Bootstrap 3.3.7 JS (`index.clj`, `js/$` at 16 sites in bluegenes, 17 in im-tables, for example `components/bootstrap.cljs:22-83` and `interceptors.cljs:41`).
- vega, vega-lite and vega-embed (`js/vegaEmbed`, `components/viz/common.cljs:27`).
- `js/serverVars` and `js/initVars` (`config.cljs:14-15`, emitted by `index.clj`).

Externs: no custom externs exist; cljsjs supplied them. `figwheel.clj:33-34` lists `externs/imjs.js`, but that file is dead and the directory is absent. shadow's `:infer-externs :auto` covers npm. Most `js/$` calls go through `oops` string access (`ocall`), which is advanced-safe. Check `(.focus (js/$ %))` (`pages/results/views.cljs:77`) and `.-` property access on jQuery objects in the first `release` warnings.

**E1 shim namespaces** live in `bluegenes/src/shim/cljsjs/` (`react_select.cljs`, `react_day_picker.cljs`, `react_transition_group.cljs`, `highlight.cljs`, `highlight/langs/{javascript,perl,python,ruby,java,xml}.cljs`; `google_analytics.cljs` is deleted instead). Each requires the npm module and `set!`s the global that app code expects. They have to sit in bluegenes, because during E1 bluegenes still consumes Clojars `im-tables 0.15.0`, which requires these namespaces (`im_tables/core.cljs:12-21`). shadow ignores the cljsjs `deps.cljs` foreign-libs and picks up the shim `.cljs` instead. When im-tables migrates (step S5), it switches to real `(:require ["react-select" ...])` forms and bluegenes deletes `src/shim` in E2.

## 3. Library bump plan

Legend: **M** = mechanical (bump, gate, Cypress smoke). **D** = needs design or behaviour review. **R** = remove instead (section 7).
Versions are known releases at least a year old. At execution time, a worker may take a newer patch release that is more than 2 weeks old, and must log it.

### 3.1 bluegenes (`project.clj:33-83`, dev/kaocha profiles `:112-123`)

| Dependency | Now | Target | Class | Relevant changes and usage sites |
|---|---|---|---|---|
| org.clojure/clojure | 1.10.1 | 1.12.0 | M | None expected. shadow 2.28 needs 1.11 or later. |
| org.clojure/clojurescript | 1.10.520 | 1.11.132 (the version bundled with shadow) | M | Moves to the `:cljs` alias. Closure-library requires still exist (`goog.dom`, `goog.string`, `goog.style`, `goog.fx.dom`, `goog.i18n`, `goog.json`, `goog.functions`, 9 to 2 files each). |
| org.clojure/core.async | 1.0.567 | 1.6.681 | M | `(:require-macros [cljs.core.async.macros ...])` in 14 files across bluegenes, im-tables and imcljs. Still provided but deprecated; optional cleanup to `(:require [cljs.core.async :refer [go]])`. |
| org.clojure/core.cache | 0.8.2 | 1.1.234 or R | M | `index.clj:9,48` (`cache/lru-cache-factory`, `lookup-or-miss`). |
| re-frame | 0.12.0 | 1.4.3 | M plus a review | `reg-event-fx` and `inject-cofx` unchanged (`events.cljs:117,123`, `events/boot.cljs:151,335`, `effects.cljs:18,39`). `re-frame.std-interceptors/path` still exists (`pages/{lists,home,admin}/events.cljs:3`). `->interceptor` still exists (`interceptors.cljs:18,39,53,62`, `effects.cljs:53`, `im_tables/interceptors.cljs:11`). `:dispatch-n` (67 sites) still works; `:fx` is preferred, so no change is needed. Remove the unused require of internal ns `re-frame.events` (`pages/templates/events.cljs:4`). `clear-subscription-cache!` unchanged (`core.cljs:25`). Bump in lockstep with im-tables: they share one app-db. |
| reagent | 0.10.0 | 1.2.0 | **D** | `reagent.dom/render` at `core.cljs:26` changes to `reagent.dom.client/create-root` + `rdc/render` held in a `defonce`. **Two-step**: first ship React 18 with the legacy `reagent.dom/render` (React 17 semantics, one console warning) and pass Cypress, then switch to `createRoot` (automatic batching can change input and focus timing). `reagent.dom/dom-node` (findDOMNode) is used at 16 sites: `bluegenes/components/bootstrap.cljs` (2), `typeahead.cljs`, `regions/views.cljs`, `upload/views.cljs`, `im_tables/components/bootstrap.cljs` (8), `controls.cljs:98`, plus dead `table.cljs` and `lighttable.cljs`. It still works in 18 (deprecated, removed in 19), so keep it and file a follow-up to convert to refs. `adapt-react-class` and `:>` are used at 13 sites (section 2). No `:component-will-*` lifecycles, `reagent.interop` or `reagent.core/render` found, so nothing else breaks. `reagent.ratom/reaction` is required in 5 subs files but never called, so drop those requires. |
| day8.re-frame/http-fx | 0.1.6 | R | R | Required at `events.cljs:13`; `:http-xhrio` is never used. |
| day8.re-frame/async-flow-fx | 0.1.0 | 0.4.0 | **D** (light) | Boot orchestration `events/boot.cljs:190,247` (`boot-flow`). Review the rule semantics across 0.2 to 0.4, then run the Cypress boot specs. |
| day8.re-frame/forward-events-fx | 0.0.6 | 0.0.6 (latest) | M | `events.cljs:174`, `pages/results/events.cljs:193,202`, `events/boot.cljs:192`. |
| day8.re-frame/undo | 0.3.3 | R | R | Not required anywhere in bluegenes. |
| day8.re-frame/test | 0.1.5 | 0.1.5, moved to `:test` | M | `test/cljs/bluegenes/{effects,events}_test.cljs:5`. |
| hiccup | 1.0.5 | **stay 1.0.5** | M | `index.clj` builds `<script>` bodies from raw strings (`serverVars`, gtag). Hiccup 2 escapes strings by default, so 2.x would break them. |
| prismatic/dommy | 1.1.0 | R | R | See section 7. |
| metosin/reitit | 0.5.12 | 0.7.2 | M | Frontend only: `route.cljs:4-9` (`reitit.frontend.easy`, `controllers`, `coercion.spec`). Smoke-test every route with Cypress `main_page_test.js` and `pr_test.js`. |
| json-html | 0.4.7 | R | R | See section 7. |
| markdown-to-hiccup | 0.6.2 | 0.6.2 (latest) | M | `utils.cljs:8,30,36`, called from `pages/tools/view.cljs:86`, `pages/home/views.cljs:33,36,97`, `pages/reportpage/utils.cljs:128,133`. |
| clj-http | 3.10.0 | 3.13.0 | M | `routes.clj:15`, `index.clj:8` (`with-middleware`), `ws/lookup.clj:7`, `ws/rss.clj:10`. |
| cljs-http | 0.1.46 | 0.1.48 | M | `effects.cljs:5,184-188`. imcljs sets `:with-credentials? false` explicitly (`imcljs/internal/defaults.cljc:33`), so a default change does not matter. |
| compojure | 1.6.2 | 1.7.1 | M | `routes.clj`, `ws/{auth,ids,rss}.clj`, `handler.clj:5`. |
| ring | 1.8.2 | 1.12.2 | **D** (light) | Jetty 9.4 becomes Jetty 11, which needs Java 11+. `core.clj:7` imports `org.eclipse.jetty.server.handler.gzip.GzipHandler` and uses `:configurator` (`core.clj:20-27,39-42`); the package is the same in Jetty 11, but verify it compiles. `wrap-session` `:same-site` (`handler.clj:27`). Any consumer that still runs bluegenes on Java 8 breaks: check InterMine's Gradle BlueGenes launcher. |
| ring/ring-defaults | 0.3.2 | R | R | No `ring.middleware.defaults` require in bluegenes or tool-store. |
| cheshire | 5.10.0 | 5.13.0 | M | `ws/lookup.clj:6`, `ws/auth.clj:4`, `index.clj:5`. |
| metosin/ring-http-response | 0.9.1 | 0.9.4 | M | 5 server files. |
| metosin/muuntaja | 0.6.7 | 0.6.10 | M | `handler.clj:6`. |
| yogthos/config | 1.1.7 | 1.2.1 (verify) | M | 7 files. The `.lein-env` input disappears (section 1.1). |
| com.cognitect/transit-cljs | 0.8.256 | 0.8.280 | M | `effects.cljs:22,30` (localStorage format; keep it so stored state survives). |
| com.andrewmcveigh/cljs-time | 0.5.2 | 0.5.2 (no newer; repo archived) | M now, D later | 7 bluegenes files (`time.cljs`, `error.cljs`, `interceptors.cljs`, `components/ui/constraint.cljs`, `pages/results/events.cljs`, `pages/home/views.cljs`, `pages/lists/views.cljs`). Follow-up: replace with `goog.i18n.DateTimeFormat`/`goog.date`, which are already in use. |
| inflections | 0.13.2 (listed **twice**, `project.clj:72,75`) | 0.14.x (verify) | M | Only `plural` and `ordinalize`: `pages/results/widgets/views.cljs:6`, `pages/querybuilder/views.cljs:12`. Dedupe the entry. |
| binaryage/oops | 0.7.0 | 0.7.2 | M | 46 bluegenes files, 16 im-tables files. |
| cljs-bean | 1.5.0 | R | R | See section 7. |
| org.clojure/data.xml | 0.2.0-alpha6 | 0.2.0-alpha9 | M | `utils.cljs:3,11,144,371-381` (cljs) and `ws/rss.clj:11`. |
| lambdaisland/uri | 1.2.1 | R | R | See section 7. |
| com.taoensso/timbre | 4.10.0 | 6.6.1 | **D** (light) | `core.clj:52` `set-level!` becomes `set-min-level!`. 4 server files. |
| com.fzakaria/slf4j-timbre | 0.3.19 | `com.taoensso/timbre-slf4j` matching timbre (verify), or slf4j-timbre 0.4.x | **D** | Logging bridge for Jetty and clj-http. Check that Jetty logs still appear. |
| org.intermine/imcljs, im-tables, bluegenes-tool-store | 1.6.0, 0.15.0, 0.2.3 | 1.7.0, 0.16.0, 0.3.0 (SNAPSHOT during the sprint) | D | Section 5. |
| *dev* binaryage/devtools | 1.0.0 | 1.0.7 | M | shadow auto-preloads it. |
| *dev* day8.re-frame/re-frame-10x | 0.6.0 | 1.9.x | D | React 18 needs preload `day8.re-frame-10x.preload.react-18`. Optional; not in the gate. |
| *dev* day8.re-frame/tracing | 0.5.3 | 0.6.2 | M | No `day8.re-frame.tracing` requires in source; only the closure-define. Drop it unless 10x needs it. |
| *dev* figwheel-sidecar 0.5.19, cider/piggieback 0.4.2, lein-figwheel, lein-doo | | remove | R | Replaced by the shadow devtools and nREPL. |
| *kaocha* lambdaisland/kaocha 1.0.700, kaocha-cljs 0-71 | | remove | R | D4. |
| *plugins* lein-cljsbuild, core.unify (oddly listed as a plugin, `:84`), lein-codox, lein-ancient, lein-pdo, lein-cljfmt 0.6.1, lein-shell, lein-environ | | remove | R | Replacements are in 1.2. |

### 3.2 im-tables-3 (`im-tables-3/project.clj:5-20,69-76`)

| Dependency | Now | Target | Class | Notes |
|---|---|---|---|---|
| clojure / clojurescript | 1.10.1 / 1.10.520 | not declared in deps.edn | M | The app pins them. Remove clojurescript from the library's main deps, otherwise it drags an old compiler onto consumers. |
| core.async | 1.1.587 | 1.6.681 | M | 4 files. |
| re-frame / reagent | 0.12.0 / 0.10.0 | 1.4.3 / 1.2.0 | D | Lockstep with bluegenes. `im_tables/core.cljs:30` `dom/render` is only for the standalone dev page. Server rendering via `reagent.dom.server` (3 sites) works with `react-dom/server` 18 in the browser. |
| cljsjs/* (4 libraries) | | npm | D | Section 2. |
| joshkh/ctrlz | 0.3.0 | R (replace) | D | `im_tables/events.cljs:4,25` (`joshkh.undo/undo-config!`, `undoable`, 11 references). Single-author library from 2017. Section 7. |
| binaryage/oops | 0.7.0 | 0.7.2 | M | |
| inflections | 0.13.2 | 0.14.x | M | `plural` in 5 files. |
| org.intermine/imcljs | 1.6.0 | 1.7.0-SNAPSHOT | M | |
| day8.re-frame/test | 0.1.5 | to `:test` alias | M | `test/cljs/im_tables/core_test.cljs:5`, `test_utils.cljc:2`. |
| cljs-time | 0.5.2 | R | R | `views/table/head/controls.cljs:12-13,128-159` (goes away with the native date input) and `views/table/error.cljs:6-7` (a timestamp, which `goog.i18n.DateTimeFormat` can format). |
| *dev* devtools, re-frame-10x 0.6.2, tracing, figwheel-sidecar 0.5.20, piggieback; *kaocha* 1.0-612 | | as bluegenes | | |
| npm `less` 1.7.5, `ws`, `@cljs-oss/module-deps` (`im-tables-3/package.json`) | | `less@4.2.0`; remove the other two | M | |

Library-specific: the im-tables jar must keep shipping `resources/public/css/im-tables.css`. bluegenes copies it from the classpath (`bluegenes/src/clj/bluegenes/prep.clj:12-26`). So im-tables' `build.clj jar` runs lessc before jarring, as `:build {:prep-tasks ["build"]}` did (`im-tables-3/project.clj:68`). CircleCI's `lein uberjar` for a ClojureScript library (`im-tables-3/.circleci/config.yml`) is pointless: drop it.

### 3.3 imcljs (`imcljs/project.clj:10-16`)

| Dependency | Now | Target | Class | Notes |
|---|---|---|---|---|
| clojure / clojurescript | 1.10.1 / 1.10.520 | not declared | M | |
| core.async | 0.4.500 | 1.6.681 | M | 17 cljs/cljc files and 6 clj files use it. |
| cljs-http | 0.1.46 | 0.1.48 | M | `src/cljs/imcljs/internal/io.cljs:2`, `core.cljs:4-13`. |
| clj-http | 3.10.0 | 3.13.0 | M | `src/clj/imcljs/internal/io.clj:2`. |
| cheshire | 5.8.1 | 5.13.0 | M | `io.clj:3`. |
| aysylu/loom | 1.0.2 | R | R | 0 requires anywhere. |
| *dev* devtools 0.9.10, figwheel, piggieback, lein-doo (phantom) | | remove | R | PhantomJS is dead (`imcljs/.circleci/config.yml` uses `npm install -g phantomjs`). |

Library-specific:
- `:source-paths` includes `test/clj` and `test/cljs` (`imcljs/project.clj:22`), so test namespaces (`imcljs.runner` requires `doo.runner`) ship in the jar. deps.edn `:paths` should be `["src/cljc" "src/cljs" "src/clj"]` only.
- Codox docs deploy to gh-pages (`.circleci/config.yml` `docs_build`/`docs_deploy`) becomes a `:codox` alias, if kept.

### 3.4 bluegenes-tool-store (`bluegenes-tool-store/project.clj:5-28`)

| Dependency | Now | Target | Class | Notes |
|---|---|---|---|---|
| clojure | 1.10.1 | 1.12.0 | M | |
| org.clojure/tools.reader | 1.3.4 | R | R | No direct require. It was probably a conflict pin; check with `clojure -X:deps tree`. |
| clj-http, compojure, ring, cheshire, ring-http-response, muuntaja, yogthos/config, timbre, slf4j-timbre | as bluegenes | as bluegenes | M/D | Same lines as 3.1. `core.clj` uses `run-jetty` and `wrap-reload`. |
| ring/ring-defaults | 0.3.2 | R | R | Unused. |
| org.apache.commons/commons-compress | 1.19 | 1.27.1 | M | `package.clj:9` (tar.gz extraction). 1.19 has known DoS CVEs (CVE-2021-35515/6/7, CVE-2021-36090). |
| org.intermine/imcljs | **1.4.3** | 1.7.0-SNAPSHOT | M | `auth.clj:2` `imcljs.auth`. Today bluegenes overrides it to 1.6.0 transitively. |

Library-specific: the tool store has two artifacts.
- The library jar, deployed without AOT (`:noaot` profile, `project.clj:66-68`). bluegenes uses it, so the new `jar` task must also skip AOT.
- An optional standalone uberjar.

Runtime finding (out of scope, filed as a risk): `tools.clj:20-31` discovers tools through `https://api.npms.io/v2/search`. That third-party API's liveness should be verified. If it is dead, first-boot tool install silently fails (errors are only logged, `tools.clj:29-31`). Candidate fix: `registry.npmjs.org/-/v1/search?text=scope:intermine+keywords:bluegenes-intermine-tool`.

### 3.5 npm (`bluegenes/package.json`)

| Package | Now | Target | Notes |
|---|---|---|---|
| engines.node | 10.x | 22.x | |
| less | 1.7.5 | 4.2.0 | D5. Verify that `-x` (compress) is still accepted; if not, drop it, since Jetty gzips CSS (`core.clj:22-24`). |
| bootstrap | ^3.3.7 | keep (verify) | Probably imported by the bootstrap-material-design Less; `node_modules` is absent, so this is unconfirmed. |
| bootstrap-material-design | git `intermine/...#im-0.0.2` | keep | `less/site.less:1`. The git dependency needs GitHub at `npm ci`. |
| chokidar-cli | ^2.1.0 | 3.0.0 | Less watch. |
| cypress | ^6.0.0 | 13.17.0 | Section 4.3. |
| @cljs-oss/module-deps, isomorphic-ws, ws, xmlhttprequest, wait-on, cypress-downloadfile, clipboardy | | remove | Section 7. Removing ws 7.x is part of E5. |
| cypress-file-upload | ^5.0.8 | remove (built-in `.selectFile()`) | Section 7. |
| @4tw/cypress-drag-drop | ^1.8.0 | 2.x | 1 spec. |
| new | | shadow-cljs 2.28.18 (dev); react, react-dom, react-select, highlight.js per section 2 | |

## 4. Test strategy

### 4.1 Unit tests (35 in bluegenes, 4 in im-tables)

| Option | Verdict | Reason |
|---|---|---|
| shadow `:node-test` | **Recommended gate** | No browser, so it works on the arm64 sandbox, where Google Chrome has no Linux arm64 build and apt chromium is a snap stub. It is deterministic and fast. The suites stub localStorage (`test_utils.cljs:12-34`) and fetches (`with-redefs`, 10 sites), and `js/gtag` is stubbed with `set!` (`test_utils.cljs:71`). Test namespaces load `bluegenes.events` and `bluegenes.subs`, which pull in im-tables views and React; npm React loads in Node. |
| shadow `:karma` + karma-chrome-launcher, ChromeHeadless via `CHROME_BIN` | **Fallback** for any test that turns out to need `window`, `document` or XhrIo | Real-browser fidelity, the same as the current kaocha setup. The browser binary comes from Playwright (`npx playwright install chromium`, which has linux-arm64 builds; the download host must be allowlisted), the existing Sparticuz build at `/home/agent/browser-scratch/chromium-arm64/chromium` (already used by the gate), or Chrome preinstalled on GitHub Actions `ubuntu-latest` runners. |
| shadow `:browser-test` + a manual browser | Reject | Needs a human or a scripted browser to open the page, so it reproduces today's `xdg-open` shim problem. |
| kaocha-cljs2 (+ funnel + chui) | Reject | Three extra moving parts (websocket relay, runner UI, browser) for 39 tests. Low maintenance activity. |
| kaocha-cljs 1 with shadow | Reject | It drives `cljs.repl.*` envs and does not fit shadow's compiler. |

Gate rule: pass/fail parity with the baseline (35 tests). The cljs.test summary line replaces kaocha's `N tests, M assertions` line, which the gate greps (`gate-bluegenes.sh`, `SUMMARY=` line), so update that regex.

imcljs tests are integration tests against a live mine:
- `imcljs/test/cljs/imcljs/env.cljs` hardcodes `http://localhost:9999/biotestmine`.
- `test/clj/imcljs/core_test.clj` hardcodes `:8080/biotestmine`.
- Assertions name Biotestmine templates (`core_test.cljs:16-19`).
- Under `:node-test`, cljs-http needs `XMLHttpRequest`, so add the `xhr2` npm polyfill or use `:karma`.

Proposal: make the root configurable (a `goog-define`), keep imcljs tests **out of the per-commit gate**, and run them nightly against whichever mine has Biotestmine-compatible data. Re-recording assertions for the rdfc2im HumanMine-style mine is a separate issue.

### 4.2 Headless browser availability (sandbox, arm64)

| Source | Works here? | Notes |
|---|---|---|
| apt `chromium`/`chromium-browser` | No | Snap stub. The gate already skips it. |
| Google Chrome / Chrome for Testing | No | No linux-arm64 build. |
| Sparticuz chromium-arm64 (`/home/agent/browser-scratch/chromium-arm64`) | Yes | Already wired into the gate (`GATE_BROWSER_LIBS`). Use it for `:karma` too. |
| Playwright-managed chromium | Likely | Has arm64. Needs the Playwright CDN allowlisted (`sbx policy allow network ...` on the host). |
| Docker `mcr.microsoft.com/playwright` / `cypress/included` | Partly | Docker Hub is reachable (`plans/30-testbed.md:20`); mcr.microsoft.com is unverified. `cypress/included` ships Electron on arm64 but no Chrome. |
| Electron bundled with Cypress 13 | Yes, for Cypress | Default browser for `cypress run`. Cypress has had linux-arm64 binaries since 10.x. The gate notes that 6.9 has none (`gate-bluegenes.sh`, `CYPRESS_INSTALL_BINARY`). |

### 4.3 Cypress 13 against a locally built mine

| Change | Where |
|---|---|
| `cypress.json` becomes `cypress.config.js` with `e2e.baseUrl` from `CYPRESS_BASE_URL` (default `http://localhost:5000`) and `specPattern: "cypress/integration/**/*.js"`, which avoids renaming 22 spec files. Keep the junit reporter and `retries` config. | `bluegenes/cypress.json` |
| `plugins/index.js` becomes `setupNodeEvents`, and `support/index.js` becomes `support/e2e.js`. | `cypress/plugins/index.js`, `cypress/support/index.js` |
| `cy.server`/`cy.route` (14 calls in 1 file) become `cy.intercept`. | `grep -rn "cy.server\|cy.route" cypress` |
| `attachFile` (2 specs) becomes `.selectFile()`, and `cypress-file-upload` is dropped. | `cypress/support/commands.js:26`; `lists_test/upload_test.js` and one other spec |
| Set `testIsolation: false` first (Cypress 12+ clears storage between tests; these specs were written without that), then re-enable spec by spec. | |
| Tag the 4 FlyMine-dependent references `external` and skip them by default. | `grep -rn flymine cypress/integration` |
| Run: build with `clojure -T:build release`, start the rdfc2im stack (webapp :8090), run `BLUEGENES_DEFAULT_SERVICE_ROOT=http://localhost:8090/humanmine BLUEGENES_DEFAULT_MINE_NAME=HumanMine BLUEGENES_DEFAULT_NAMESPACE=humanmine clojure -M -m bluegenes.core &`, wait for `curl -sf localhost:5000` (as `.circleci/config.yml:91-95` does), then `npx cypress run --browser electron`. Alternatively, point at the stack's own BlueGenes container on :5000 after restaging its lib dir. | `plans/30-testbed.md:9`, `rdfc2im/trial/docker-compose.yml:102-125` |

Fixtures under `cypress/fixtures/*.tsv|bed|gff3|fa` are Biotestmine outputs and need re-recording for the new mine (workstream F, not E1).

## 5. Sibling libraries

### 5.1 Order of work

| Step | Repo | Content | Depends on |
|---|---|---|---|
| S1 | imcljs | `deps.edn` (paths without tests), `build.clj` (jar/install/deploy, no AOT), `shadow-cljs.edn` `:test` build (`:node-test` + `xhr2`, or `:karma`), bumps from 3.3, drop loom, cljfmt alias. Version `1.7.0-SNAPSHOT`. | none |
| S2 | bluegenes-tool-store | `deps.edn`, `build.clj` (noaot `jar`, optional `uber`), bumps from 3.4. Version `0.3.0-SNAPSHOT`. | S1 for the imcljs coordinate, but it can start at once with Clojars imcljs 1.6.0 and swap later. |
| S3 | bluegenes E1 | Toolchain only (sections 1, 2 with shims), consuming **Clojars** imcljs 1.6.0, im-tables 0.15.0 and tool-store 0.2.3. | none (independent of S1/S2) |
| S4 | im-tables-3 | `deps.edn`, `build.clj` (lessc, then jar with CSS), `shadow-cljs.edn` (`:app` dev page, `:test`), real npm requires at the **same versions** as E1 (react-select 2.4.4 etc.), so it stays compatible with E1 bluegenes. Version `0.16.0-SNAPSHOT`. | S1 |
| S5 | bluegenes | Switch to SNAPSHOT siblings and delete the shims that im-tables no longer needs. | S2, S3, S4 |
| S6 | im-tables + bluegenes **together** | E2 lockstep: reagent 1.2, re-frame 1.4, React 18 (legacy render first), react-select 5, highlight.js 11, removal of day-picker and transition-group. One worker owns both branches. | S5 |
| S7 | bluegenes + tool-store | Server-side bumps (ring 1.12, timbre 6, clj-http, ...). | S3 (deps.edn exists). Can run in parallel with S4 to S6. |

### 5.2 Consuming unreleased siblings during the sprint

| Mechanism | Use | Pros | Cons |
|---|---|---|---|
| `X.Y.Z-SNAPSHOT` installed into the shared `~/.m2` with `clojure -T:build install`, run from each sibling's `maint-2026` checkout | **Default** for agents and the gate | Works from any worktree path. The im-tables jar carries compiled CSS. No network needed. | Can go stale: the orchestrator must re-install after every sibling merge, and the gate should print the resolved sibling jar mtimes. |
| `:siblings` alias with `:override-deps ... :local/root "../imcljs"` | Interactive work in the canonical `repos/` layout only | Live edits across repos; shadow hot-reloads im-tables sources too. | Relative paths break in worktrees. im-tables CSS must be built in place (`clojure -T:build css` in `../im-tables-3`). |
| git deps `{:git/url "https://github.com/gmicklem/im-tables-3" :git/sha ...}` | GitHub Actions before the Clojars release | Reproducible and pinned. | Gitlibs have no built CSS, so it needs `:deps/prep-lib` with lessc in the gitlib (needs node). An alternative is a CI step that checks out the siblings and runs `install`. **Prefer the checkout+install CI step.** |

### 5.3 Release steps (end of sprint, human-run for Clojars and Docker Hub)

1. imcljs: set `1.7.0`, update CHANGELOG, tag `v1.7.0`, run `clojure -T:build deploy`.
2. im-tables: point at `imcljs 1.7.0`, set `0.16.0`, run `clojure -T:build deploy` (the jar includes CSS and has no AOT).
3. tool-store: point at `imcljs 1.7.0`, set `0.3.0`, deploy (no AOT).
4. bluegenes: replace the SNAPSHOT coordinates, set `1.5.0`, run `clojure -T:build deploy`. Check that the jar contains `bluegenes/core.class`, `public/js/compiled/app.*.js` and `manifest.edn`, and that the pom lists runtime deps only.
5. Verify the rdfc2im contract: change `full-build.sh` to resolve `org.intermine:bluegenes:1.5.0` and confirm `java -cp lib/* bluegenes.core` serves the UI.
6. Docker: `docker build -t intermine/bluegenes:1.5.0 .`, then push `1.5.0` and `latest`.
7. Update `docs/building.md` (it still documents lein everywhere) and the CHANGELOG. Re-point `gmicklem` to `intermine` upstream PRs.

## 6. Risks, unknowns and batching

### 6.1 Risks and unknowns

| # | Risk | Likelihood / impact | Mitigation |
|---|---|---|---|
| R1 | React 18 + reagent 1.2 behaviour change: `createRoot` batching, findDOMNode warnings at 16 `dom-node` sites, jQuery/Bootstrap popovers mutating React-owned DOM (`components/bootstrap.cljs:22-83`, `im_tables/components/bootstrap.cljs`). | High / high | Two-step render switch (3.1). Cypress after each step. Refs conversion is a follow-up. |
| R2 | im-tables is embedded and shares app-db, re-frame and React with bluegenes. A version skew between them cannot be tested in isolation. | Certain / high | One owner for S6. Bump both in one merge window. |
| R3 | Fingerprinting and manifest shape changes break index HTML and the persisted-state invalidation (`utils.clj:6-43`, `boot.cljs:181`). | Certain / medium | Covered in 1.1. Add a clj unit test for the manifest parsing (bluegenes has none today). |
| R4 | Less 4 semantics: division (`idresolver.less:461`), inline JS disabled by default, behaviour of the git-pinned bootstrap-material-design fork. | Medium / medium | `--math=always`. Diff compiled CSS (1.7.5 output vs 4.2.0 output) as a gate artefact. |
| R5 | Advanced-compilation renames on jQuery or other untyped interop. | Medium / medium | Read the shadow `release` warnings. Cypress runs against the release build only. |
| R6 | The Clojars jar contract (pom deps, AOT `bluegenes.core`, bundled assets) is used by rdfc2im and possibly by InterMine's Gradle launcher. Jetty 11 drops Java 8. | Medium / high | Release step 5. Grep the InterMine Gradle plugin for the BlueGenes launch task before the ring bump. |
| R7 | Toolchain availability: no Clojure CLI in the sandbox; first Maven/Clojars resolution goes through the proxy (`JAVA_TOOL_OPTIONS` already sets it); Playwright or Cypress binary hosts may be blocked. | Medium / medium | Step 0. Prefer Electron and Sparticuz chromium. Ask Gos for allowlist entries early. |
| R8 | `:node-test` hides DOM-dependent failures that kaocha-in-Chrome would show. | Low / medium | Run `:karma` once per epic as a cross-check. |
| R9 | cljfmt 0.6 to 0.12 changes formatting widely. | High / low | A dedicated, format-only first commit. |
| R10 | Cypress 13 `testIsolation`, fixtures recorded on Biotestmine, live FlyMine dependence. | High / medium | 4.3. Fixture re-recording is a workstream F issue. |
| R11 | tool-store relies on `api.npms.io` at runtime (`tools.clj:23`). | Unknown | Verify. Switch to npm registry search in S2. |
| R12 | re-frame-10x / tracing compatibility with re-frame 1.4 and React 18. | Medium / low (dev only) | Keep it out of the gate. Optional preload. |
| R13 | async-flow-fx 0.1 to 0.4 semantic drift in the boot flow. | Low / high (boot) | Review `boot.cljs:150-250`, run the Cypress boot specs. |

### 6.2 Batching plan for parallel agents

| Batch | Steps (parallel within a batch) | Model | Est. agent-hours | Gate |
|---|---|---|---|---|
| B0 | Install the Clojure CLI; make `gate-bluegenes.sh` dual-mode (lein or shadow); add an `install`-freshness check | Sonnet | 1.5 | the gate runs on the old tree |
| B1a | S1 imcljs | Sonnet | 2.5 | `clojure -M:fmt check`, `jar`, `install`; tests nightly |
| B1b | S2 tool-store | Sonnet | 2 | fmt, jar, a smoke `-m bluegenes-tool-store.core` |
| B1c | Hygiene removals on the **lein** tree (section 7 items that do not touch npm or the toolchain) | Sonnet | 1.5 | the current lein gate |
| B1d | Cypress 13 migration against the current lein build (4.3) | Sonnet | 4 | `cypress run` on the testbed mine |
| B2 | S3 bluegenes E1 (after B1c merges, to avoid project.clj conflicts) | **Opus** | 6 | new gate: fmt, `:node-test` (35 pass), `release`, `uber`, Cypress smoke |
| B3a | S4 im-tables (after B1a) | Sonnet (Opus review) | 4 | fmt, `:node-test` (4 pass), `jar` contains CSS |
| B3b | S7 server-side bumps (after B2) | Sonnet | 2 | gate + manual `/api/auth` and RSS checks |
| B4 | S5 SNAPSHOT switch + shim deletion | Sonnet | 1 | full gate |
| B5 | S6 E2 lockstep (React 18 legacy render, then createRoot) | **Opus** | 8 | full gate + full Cypress |
| B6 | GitHub Actions workflows, Dockerfile, docs/building.md | Sonnet | 2.5 | the workflow runs on the fork |
| B7 | Release (5.3) | Human + orchestrator | 1 | rdfc2im contract check |

The total is about **36 agent-hours**, with a critical path of B0, B2, B4, B5, B6 (about 19 h). B1a, B1b, B1c and B1d are fully independent. B3a and B3b are independent of each other.

## 7. Dependency hygiene (weakly used libraries)

The rule: a library required in 3 files or fewer, or one that is trivially replaceable, gets removed rather than upgraded. Replacements that add a different package must be vetted and logged in `decisions/package-vetting.md`. Every item below either uses code already in the build (Closure library, CSS, browser built-ins) or nothing at all, so no vetting entry is needed unless noted.

| Repo | Library | Call sites (grep-confirmed) | Proposal |
|---|---|---|---|
| bluegenes | cljsjs/google-analytics | required at `core.cljs:13`; zero `js/ga` calls | **Remove** (gtag comes from a script tag in `index.clj`). |
| bluegenes | day8.re-frame/http-fx | required at `events.cljs:13`; zero `:http-xhrio` | **Remove**. |
| bluegenes | day8.re-frame/undo | zero requires | **Remove**. |
| bluegenes | cljs-bean | required at `events.cljs:38`, `pages/developer/devhome.cljs:8`; `->clj` never called | **Remove** both requires. |
| bluegenes | lambdaisland/uri | required at `subs.cljs:19`; `uri` never called | **Remove**. |
| bluegenes | json-html | required at `pages/templates/views.cljs:5`, `pages/results/views.cljs:12`, `components/idresolver/views.cljs:5`; the only call is `idresolver/views.cljs:126` inside `debugger`, which is never referenced | **Remove** the library and the `debugger` fn. |
| bluegenes | prismatic/dommy | live: `components/search/typeahead.cljs:95-97` (listen focus/blur, add/remove class), `pages/upload/views.cljs:50-57` (body key listeners); unused require at `components/ui/constraint.cljs:8`; dead namespaces `components/table.cljs` (self-declared unused, line 8-10) and `components/lighttable.cljs` (required at `pages/templates/views.cljs:6`, `components/idresolver/views.cljs:10`, `pages/reportpage/views.cljs:8`, but `lighttable/` is never called) | **Remove.** Replace the 2 live files with `goog.events/listen` and `goog.dom.classlist`. Delete `table.cljs` and `lighttable.cljs` and their requires (table is required in 5 views, never called). |
| bluegenes + im-tables | cljsjs/react-transition-group | 3 live `css-transition-group` uses, all `"fade"` (`enrichment/views.cljs:173`, `regions/views.cljs:~244`, `im_tables/.../controls.cljs:501`); 1 dead def (`templates/views.cljs:37`) | **Replace** with a CSS `@keyframes` fade-in on mount (no leave animation). |
| bluegenes + im-tables | cljsjs/react-day-picker | `constraint.cljs:118`, `im_tables/.../controls.cljs:145` (`DayPicker.Input`, fixed `YYYY-MM-DD`) | **Replace** with native `<input type="date">`; its value is already `YYYY-MM-DD`. Delete both `calendar.less` files. UX review by Gos. |
| bluegenes | org.clojure/core.cache | `index.clj:9,48`: an LRU of 32 for semantic markup per configured mine | **Replace** with an `atom` map keyed by service root (bounded by the number of configured mines, `utils.clj` `env->mines`). Low priority. |
| bluegenes | ring/ring-defaults | zero requires | **Remove**. |
| bluegenes | day8.re-frame/tracing | no source requires; only a closure-define (`project.clj:149`) | **Remove** unless re-frame-10x needs it. |
| bluegenes | transit-cljs | `effects.cljs:22,30` | Keep: it is also a transitive dependency of cljs-http, and changing the localStorage format would wipe users' saved state. |
| bluegenes | markdown-to-hiccup | `utils.cljs:8`, 7 call sites via `md-paragraph`/`md-element` | Keep: safe markdown-to-hiccup has no trivial replacement. |
| bluegenes | reitit, data.xml, async-flow-fx, forward-events-fx, hiccup | 1-2 files each, but core functionality (routing, template XML, boot, im-tables bridge, server HTML) | Keep. |
| bluegenes | dead files (no deps) | `figwheel.clj`, `script/repl.clj`, `dev/user.clj`, `resources/public/index.html` ("only used by figwheel"), `resources/migrations/*.sql` (no references in `src`) | **Delete**. |
| im-tables | joshkh/ctrlz | `im_tables/events.cljs:4,25` (`undoable`, `undo-config!`) | **Replace** with `day8.re-frame/undo 0.3.3`, which `events.cljs:3` shows was the original intent; it needs a package-vetting entry. Fallback: vendor the namespace (the jar is not cached locally, so its size is unknown). |
| im-tables | cljs-time | `views/table/head/controls.cljs` (goes with day-picker), `views/table/error.cljs:6-7` | **Remove** and use `goog.i18n.DateTimeFormat`. |
| imcljs | aysylu/loom | zero requires | **Remove**. |
| tool-store | org.clojure/tools.reader, ring/ring-defaults | zero requires | **Remove** (confirm with the deps tree). |
| tool-store | commons-compress | `package.clj:9`: tar.gz extraction; nothing in the JDK replaces it | Keep, bump to 1.27.1. |
| npm (bluegenes) | @cljs-oss/module-deps, isomorphic-ws, ws, xmlhttprequest | no references in source or CI; leftovers of cljs `:npm-deps` and the kaocha/node REPL | **Remove** (this also clears the ws advisories, E5). |
| npm (bluegenes) | wait-on | no references (CI uses a curl loop, `.circleci/config.yml:91-95`) | **Remove**. |
| npm (bluegenes) | cypress-downloadfile, clipboardy | not imported; clipboardy appears only in commented code (`cypress/plugins/index.js`) | **Remove**. |
| npm (bluegenes) | cypress-file-upload | `support/commands.js:26`, `attachFile` in 2 specs | **Replace** with built-in `.selectFile()` (Cypress 9.3+). |
| npm (bluegenes) | @4tw/cypress-drag-drop | 1 spec | Keep and bump to 2.x. Possible later replacement with `.trigger()` sequences. |
| npm (im-tables) | @cljs-oss/module-deps, ws | no references | **Remove**. |
| inventory | oops (62 files), cljs-time in bluegenes (7 files), inflections (7 files) | above the threshold | Keep. File follow-ups to move cljs-time to goog.i18n, and to shrink oops where shadow's externs inference makes plain interop safe. |
