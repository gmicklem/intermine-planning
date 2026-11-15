# BlueGenes dependency usage census

Generated 2026-11-15, read-only scan of `bluegenes`, `imcljs`, `im-tables-3`, `bluegenes-tool-store` under `repos/`. Companion to `bluegenes-dependencies.md`.

## Method and caveats

- Every `.clj/.cljs/.cljc` file under `src/`, `test/`, `dev/`, `script/` and the repo root (excluding `node_modules`, `target`, `.git`) was parsed for `(ns ... (:require|:require-macros|:use|:import))` forms and top-level `(require ...)`. For each required namespace the alias (`alias/var`) and `:refer`red names were searched in the file body to count distinct vars. Libraries were mapped to namespaces by prefix.
- Columns: *Files* = distinct files requiring the library (src/test/dev split in brackets); *Namespaces* = distinct namespaces required; *vars* = distinct `alias/var` plus referred names actually mentioned (approximate; `:refer-macros` and `:refer :all` are not tracked, and reader-conditional requires in `.cljc` files are under-counted by the parser, so `imcljs` core.async was counted by grep).
- "Representative paths" are shortened: `cljs:` = `src/cljs/bluegenes/`, `clj:` = `src/clj/bluegenes/`, `cljc:` = `src/cljc/imcljs/`, `src:` = `src/im_tables/`.
- Usage of JS-side assets (jQuery, `js/hljs`, `js/vegaEmbed`, `js/Select`, `js/DayPicker`) is by `js/...` interop, noted where relevant.
- Internal cross-repo dependencies (bluegenes -> imcljs / im-tables / bluegenes-tool-store) are included for completeness.

## 1. bluegenes

Built-ins and bundled libs (not separately declared): `clojure.string` 59 files, `clojure.set` 9, `cljs.test` 8 (tests), `clojure.spec.alpha` 4, `cljs.reader` 3, `clojure.walk` 2, `clojure.zip` 2, `clojure.java.io` 2, `clojure.edn`/`clojure.pprint` 1 each; **`goog.*` in 20 files across 8 namespaces** (`goog.dom` 8, `goog.string` 7, `goog.functions` 6, `goog.style` 5, `goog.fx.dom` 4, `goog.date.Date` 2, `goog.fx.easing` 2, `goog.json` 1). `js/$` (jQuery from CDN) appears on 16 lines in 8 files.

Note on the `ring` row: 1 of the 8 files is the dead `figwheel.clj` (requires `ring.middleware.json`, which is not a declared dependency).

| Library | Files (src/test/dev) | Namespaces required | Distinct vars used (alias/ + :refer) | Representative paths |
|---|---|---|---|---|
| `re-frame` | 99 (95/4/0) | 3: `re-frame.core`, `re-frame.events`, `re-frame.std-interceptors` | 12: `->interceptor`, `clear-subscription-cache!`, `dispatch`, `dispatch-sync`, `inject-cofx`, `path` +6 | `cljs:components/export_query.cljs`, `cljs:components/footer/views.cljs` |
| `binaryage/oops` | 46 (46/0/0) | 1: `oops.core` | 6: `oapply`, `ocall`, `ocall+`, `oget`, `oget+`, `oset!` | `cljs:components/bootstrap.cljs`, `cljs:components/idresolver/events.cljs` |
| `reagent` | 40 (40/0/0) | 4: `reagent.core`, `reagent.dom`, `reagent.dom.server` +1 | 11: `adapt-react-class`, `argv`, `atom`, `children`, `create-class`, `dom-node` +5 | `cljs:components/bootstrap.cljs`, `cljs:components/export_query.cljs` |
| `org.intermine/imcljs` | 37 (36/1/0) | 6: `imcljs.auth`, `imcljs.entity`, `imcljs.fetch` +3 | 84: `->xml`, `adjust-path-to-last-class`, `attributes`, `basic-auth`, `bluegenes-properties`, `branding` +78 | `clj:index.clj`, `clj:ws/auth.clj` |
| `ring/ring (+ring-core/jetty-adapter)` | 8 (7/0/1) | 10: `org.eclipse.jetty.server.handler.gzip.GzipHandler`, `ring.adapter.jetty`, `ring.middleware.json` +7 | 12: `charset`, `content-type`, `ok?`, `response`, `run-jetty`, `wrap-json-params` +6 | `figwheel.clj`, `clj:core.clj` |
| `org.clojure/core.async` | 7 (6/1/0) | 2: `cljs.core.async`, `cljs.core.async.macros` | 10: `<!`, `>!`, `chan`, `close!`, `go`, `go-loop` +4 | `cljs:components/lighttable.cljs`, `cljs:effects.cljs` |
| `com.andrewmcveigh/cljs-time` | 7 (7/0/0) | 3: `cljs-time.coerce`, `cljs-time.core`, `cljs-time.format` | 10: `formatter`, `formatters`, `from-date`, `from-long`, `from-string`, `now` +4 | `cljs:components/ui/constraint.cljs`, `cljs:error.cljs` |
| `yogthos/config` | 7 (7/0/0) | 1: `config.core` | 1: `env` | `clj:core.clj`, `clj:handler.clj` |
| `prismatic/dommy` | 5 (5/0/0) | 1: `dommy.core` | 3: `add-class!`, `listen!`, `remove-class!` | `cljs:components/lighttable.cljs`, `cljs:components/search/typeahead.cljs` |
| `compojure` | 5 (5/0/0) | 3: `compojure.core`, `compojure.middleware`, `compojure.route` | 7: `GET`, `POST`, `context`, `defroutes`, `not-found`, `resources` +1 | `clj:handler.clj`, `clj:routes.clj` |
| `metosin/ring-http-response` | 5 (5/0/0) | 1: `ring.util.http-response` | 5: `bad-request`, `found`, `internal-server-error`, `ok`, `see-other` | `clj:routes.clj`, `clj:ws/auth.clj` |
| `org.intermine/im-tables` | 4 (4/0/0) | 3: `im-tables.core`, `im-tables.events`, `im-tables.views.core` | 1: `main` | `cljs:core.cljs`, `cljs:events.cljs` |
| `com.taoensso/timbre` | 4 (4/0/0) | 1: `taoensso.timbre` | 5: `error`, `errorf`, `infof`, `set-level!`, `warnf` | `clj:core.clj`, `clj:index.clj` |
| `clj-http` | 4 (4/0/0) | 1: `clj-http.client` | 2: `get`, `with-middleware` | `clj:index.clj`, `clj:routes.clj` |
| `figwheel-sidecar` | 3 (0/0/3) | 1: `figwheel-sidecar.repl-api` | 3: `cljs-repl`, `start-figwheel!`, `stop-figwheel!` | `dev/user.clj`, `figwheel.clj` |
| `json-html` | 3 (3/0/0) | 1: `json-html.core` | 1: `edn->hiccup` | `cljs:components/idresolver/views.cljs`, `cljs:pages/results/views.cljs` |
| `cheshire` | 3 (3/0/0) | 1: `cheshire.core` | 2: `generate-string`, `parse-string` | `clj:index.clj`, `clj:ws/auth.clj` |
| `org.clojure/data.xml` | 2 (2/0/0) | 1: `clojure.data.xml` | 4: `element`, `element*`, `emit-str`, `parse-str` | `clj:ws/rss.clj`, `cljs:utils.cljs` |
| `cljs-bean` | 2 (2/0/0) | 1: `cljs-bean.core` | 1: `->clj` | `cljs:events.cljs`, `cljs:pages/developer/devhome.cljs` |
| `inflections` | 2 (2/0/0) | 1: `inflections.core` | 2: `ordinalize`, `plural` | `cljs:pages/querybuilder/views.cljs`, `cljs:pages/results/widgets/views.cljs` |
| `org.intermine/bluegenes-tool-store` | 2 (2/0/0) | 2: `bluegenes-tool-store.core`, `bluegenes-tool-store.tools` | 1: `initialise-tools` | `clj:core.clj`, `clj:routes.clj` |
| `hiccup` | 2 (2/0/0) | 1: `hiccup.page` | 3: `html5`, `include-css`, `include-js` | `clj:index.clj`, `clj:routes.clj` |
| `day8.re-frame/test` | 2 (0/2/0) | 1: `day8.re-frame.test` | 0: - | `test/cljs/bluegenes/effects_test.cljs`, `test/cljs/bluegenes/events_test.cljs` |
| `com.stuartsierra/component (NOT declared)` | 1 (0/0/1) | 1: `com.stuartsierra.component` | 4: `Lifecycle`, `start`, `stop`, `system-map` | `figwheel.clj` |
| `ring-component-jetty (NOT declared)` | 1 (0/0/1) | 1: `ring.component.jetty` | 1: `jetty-server` | `figwheel.clj` |
| `metosin/reitit` | 1 (1/0/0) | 6: `reitit.coercion`, `reitit.coercion.spec`, `reitit.core` +3 | 6: `apply-controllers`, `coercion`, `href`, `push-state`, `router`, `start!` | `cljs:route.cljs` |
| `cljs-http` | 1 (1/0/0) | 1: `cljs-http.client` | 4: `delete`, `get`, `post`, `put` | `cljs:effects.cljs` |
| `com.cognitect/transit-cljs` | 1 (1/0/0) | 1: `cognitect.transit` | 4: `read`, `reader`, `write`, `writer` | `cljs:effects.cljs` |
| `markdown-to-hiccup` | 1 (1/0/0) | 1: `markdown-to-hiccup.core` | 3: `component`, `hiccup-in`, `md->hiccup` | `cljs:utils.cljs` |
| `cljsjs/google-analytics` | 1 (1/0/0) | 1: `cljsjs.google-analytics` | 0: - | `cljs:core.cljs` |
| `cljsjs/react-transition-group` | 1 (1/0/0) | 1: `cljsjs.react-transition-group` | 0: - | `cljs:core.cljs` |
| `cljsjs/react-day-picker` | 1 (1/0/0) | 1: `cljsjs.react-day-picker` | 0: - | `cljs:core.cljs` |
| `cljsjs/react-select` | 1 (1/0/0) | 1: `cljsjs.react-select` | 0: - | `cljs:core.cljs` |
| `lambdaisland/uri` | 1 (1/0/0) | 1: `lambdaisland.uri` | 1: `uri` | `cljs:subs.cljs` |
| `day8.re-frame/http-fx` | 1 (1/0/0) | 1: `day8.re-frame.http-fx` | 0: - | `cljs:events.cljs` |
| `day8.re-frame/forward-events-fx` | 1 (1/0/0) | 1: `day8.re-frame.forward-events-fx` | 0: - | `cljs:events.cljs` |
| `day8.re-frame/async-flow-fx` | 1 (1/0/0) | 1: `day8.re-frame.async-flow-fx` | 0: - | `cljs:events.cljs` |
| `metosin/muuntaja` | 1 (1/0/0) | 1: `muuntaja.middleware` | 2: `wrap-format`, `wrap-params` | `clj:handler.clj` |
| `org.clojure/core.cache` | 1 (1/0/0) | 1: `clojure.core.cache.wrapped` | 2: `lookup-or-miss`, `lru-cache-factory` | `clj:index.clj` |
| `day8.re-frame/undo` | 0 | none | - | - (no `day8.re-frame.undo` anywhere; the "undo delete" UI is hand-rolled events) |
| `ring/ring-defaults` | 0 | none | - | - |
| `com.fzakaria/slf4j-timbre` | 0 | none (runtime SLF4J binding for Jetty/Apache logs) | - | - |
| `binaryage/devtools`, `re-frame-10x`, `re-frame/tracing` | 0 source files | `:preloads`/`:closure-defines` in `project.clj` only (dev build) | - | `core.cljs:21` has `(devtools/install!)` commented out |
| `cider/piggieback`, `figwheel-sidecar` | repl only | `:repl-options` / `dev/user.clj`, `script/repl.clj` | - | see `figwheel-sidecar` row |
| `lambdaisland/kaocha`, `kaocha-cljs` | tests | `tests.edn`, `bin/kaocha`, CI `lein kaocha` | - | `tests.edn` |

## 2. imcljs


| Library | Files (src/test/dev) | Namespaces required | Distinct vars used (alias/ + :refer) | Representative paths |
|---|---|---|---|---|
| `org.clojure/core.async` | 17 (7/10/0) | 3: `clojure.core.async` (JVM branch of reader conditionals), `cljs.core.async`, `cljs.core.async.macros` | `<!`, `>!`, `chan`, `go`, `go-loop`, `timeout` | `cljc:fetch.cljc`, `cljc:auth.cljc`, `test/cljs/imcljs/auth_test.cljs` |
| `cljs-http` | 2 (2/0/0) | 1: `cljs-http.client` | 4: `delete`, `get`, `post`, `put` | `cljs:core.cljs`, `cljs:internal/io.cljs` |
| `clj-http` | 1 (1/0/0) | 1: `clj-http.client` | 4: `delete`, `get`, `post`, `put` | `clj:internal/io.clj` |
| `cheshire` | 1 (1/0/0) | 1: `cheshire.core` | 0: - (alias `json` never used; the dependency is needed at runtime by clj-http `:as :json`) | `clj:internal/io.clj` |
| `figwheel-sidecar` | 1 (0/0/1) | 1: `figwheel-sidecar.repl-api` | 3: `cljs-repl`, `start-figwheel!`, `stop-figwheel!` | `dev/user.clj` |
| `doo` | 1 (0/1/0) | 1: `doo.runner` | 0: - | `test/cljs/imcljs/runner.cljs` |
| `aysylu/loom` | 0 | none | - | - |
| `org.clojure/core.unify` (plugin), `lein-doo` (plugin) | build | `project.clj:18`, `:68`; `doo.runner` in `test/cljs/imcljs/runner.cljs` | - | core.unify: no reference anywhere |

Built-ins: `clojure.string` 5, `cljs.test` 11, `clojure.test` 1, `clojure.set` 1, `clojure.edn` 1. `cheshire` is also reached via clj-http `:as :json` (`internal/io.clj:16,70,84,98`).

## 3. im-tables-3


| Library | Files (src/test/dev) | Namespaces required | Distinct vars used (alias/ + :refer) | Representative paths |
|---|---|---|---|---|
| `re-frame` | 27 (25/2/0) | 1: `re-frame.core` | 9: `->interceptor`, `clear-subscription-cache!`, `dispatch`, `dispatch-sync`, `reg-event-db`, `reg-event-fx` +3 | `src:core.cljs`, `src:effects.cljs` |
| `reagent` | 19 (19/0/0) | 4: `reagent.core`, `reagent.dom`, `reagent.dom.server` +1 | 10: `adapt-react-class`, `atom`, `children`, `create-class`, `current-component`, `dom-node` +4 | `src:components/bootstrap.cljs`, `src:core.cljs` |
| `org.intermine/imcljs` | 18 (18/0/0) | 6: `imcljs.auth`, `imcljs.fetch`, `imcljs.internal.utils` +3 | 23: `->xml`, `attributes`, `class`, `class?`, `code`, `data-type` +17 | `src:core.cljs`, `src:events.cljs` |
| `binaryage/oops` | 16 (16/0/0) | 1: `oops.core` | 7: `oapply`, `ocall`, `ocall!`, `ocall+`, `oget`, `oget+` +1 | `src:components/bootstrap.cljs`, `src:events.cljs` |
| `inflections` | 5 (5/0/0) | 1: `inflections.core` | 1: `plural` | `src:utils.cljs`, `src:views/dashboard/exporttable.cljs` |
| `org.clojure/core.async` | 3 (3/0/0) | 2: `cljs.core.async`, `cljs.core.async.macros` | 6: `<!`, `chan`, `close!`, `go`, `go-loop`, `timeout` | `src:effects.cljs`, `src:events.cljs` |
| `com.andrewmcveigh/cljs-time` | 2 (2/0/0) | 3: `cljs-time.coerce`, `cljs-time.core`, `cljs-time.format` | 7: `formatter`, `formatters`, `from-date`, `now`, `parse`, `to-date` +1 | `src:views/table/error.cljs`, `src:views/table/head/controls.cljs` |
| `day8.re-frame/test` | 2 (0/2/0) | 1: `day8.re-frame.test` | 3: `run-test-async`, `run-test-sync`, `wait-for` | `test/cljs/im_tables/core_test.cljs`, `test/cljs/im_tables/test_utils.cljc` |
| `cljsjs/react-transition-group` | 1 (1/0/0) | 1: `cljsjs.react-transition-group` | 0: - | `src:core.cljs` |
| `cljsjs/react-day-picker` | 1 (1/0/0) | 1: `cljsjs.react-day-picker` | 0: - | `src:core.cljs` |
| `cljsjs/react-select` | 1 (1/0/0) | 1: `cljsjs.react-select` | 0: - | `src:core.cljs` |
| `cljsjs/highlight` | 1 (1/0/0) | 7: `cljsjs.highlight`, `cljsjs.highlight.langs.java`, `cljsjs.highlight.langs.javascript` +4 | 0: - | `src:core.cljs` |
| `joshkh/ctrlz` | 1 (1/0/0) | 1: `joshkh.undo` | 1: `undoable` | `src:events.cljs` |
| `figwheel-sidecar` | 1 (0/0/1) | 1: `figwheel-sidecar.repl-api` | 1: `start-figwheel!` | `dev/user.clj` |
| `reagent.dom.server` (part of reagent) | 4 | `views.cljs:6` (alias `server` unused), `views/core.cljs:82`, `components/bootstrap.cljs:44`, `views/table/body/main.cljs:21` | - | - |
| `cljsjs/highlight` runtime | - | `js/hljs` at `views/table/error.cljs:48` | - | - |

Built-ins: `clojure.string` 16 files, `clojure.set` 2, `goog.dom/string/style/json/i18n.NumberFormat` 3 files. `js/$` on 17 lines in 6 files (excluding the stray `.nfs` copy).

## 4. bluegenes-tool-store


| Library | Files (src/test/dev) | Namespaces required | Distinct vars used (alias/ + :refer) | Representative paths |
|---|---|---|---|---|
| `com.taoensso/timbre` | 4 (4/0/0) | 1: `taoensso.timbre` | 5: `error`, `errorf`, `infof`, `set-level!`, `warnf` | `clj:auth.clj`, `clj:core.clj` |
| `cheshire` | 3 (3/0/0) | 1: `cheshire.core` | 1: `parse-string` | `clj:auth.clj`, `clj:package.clj` |
| `yogthos/config` | 3 (3/0/0) | 1: `config.core` | 1: `env` | `clj:auth.clj`, `clj:core.clj` |
| `metosin/ring-http-response` | 2 (2/0/0) | 1: `ring.util.http-response` | 8: `bad-gateway`, `bad-request`, `internal-server-error`, `not-found`, `not-implemented`, `ok` +2 | `clj:auth.clj`, `clj:tools.clj` |
| `org.intermine/bluegenes-tool-store` | 2 (2/0/0) | 3: `bluegenes-tool-store.auth`, `bluegenes-tool-store.package`, `bluegenes-tool-store.tools` | 10: `check-priv`, `get-all-tools`, `get-tools-path`, `initialise-tools`, `install-package`, `install-tool` +4 | `clj:core.clj`, `clj:tools.clj` |
| `clj-http` | 2 (2/0/0) | 1: `clj-http.client` | 1: `get` | `clj:package.clj`, `clj:tools.clj` |
| `org.intermine/imcljs` | 1 (1/0/0) | 1: `imcljs.auth` | 1: `who-am-i?` | `clj:auth.clj` |
| `compojure` | 1 (1/0/0) | 2: `compojure.core`, `compojure.route` | 6: `GET`, `POST`, `context`, `defroutes`, `files`, `resources` | `clj:core.clj` |
| `ring/ring (+ring-core/jetty-adapter)` | 1 (1/0/0) | 2: `ring.adapter.jetty`, `ring.middleware.reload` | 2: `run-jetty`, `wrap-reload` | `clj:core.clj` |
| `metosin/muuntaja` | 1 (1/0/0) | 1: `muuntaja.middleware` | 2: `wrap-format`, `wrap-params` | `clj:core.clj` |
| `org.apache.commons/commons-compress` | 1 (1/0/0) | 2: `org.apache.commons.compress.archivers.tar.TarArchiveEntry`, `org.apache.commons.compress.archivers.tar.TarArchiveInputStream` | 0: - | `clj:package.clj` |
| `org.clojure/tools.reader` | 0 | none (`clojure.edn` is used instead) | - | - |
| `ring/ring-defaults` | 0 | none | - | - |
| `com.fzakaria/slf4j-timbre` | 0 | none (runtime binding) | - | - |

## 5. Build tooling and plugins: who uses them

| Tool | Repos | Evidence of use | Verdict |
|---|---|---|---|
| `lein-cljsbuild` | bg, imcljs, imt3 | `:cljsbuild :builds` (dev/min/test); `lein build` alias | Used; end-of-life (replace with shadow-cljs or figwheel-main) |
| `lein-figwheel` + `figwheel-sidecar` | bg, imcljs, imt3 | `:figwheel` keys; `dev/user.clj`, `script/repl.clj` call `start-figwheel!` | Used in dev; superseded |
| `lein-pdo` | bg, imt3, tool-store | bg/imt3 `dev` alias runs `pdo` (less watcher + repl). tool-store: no alias uses it | tool-store: dead; others: only needed for the less watcher |
| `lein-shell` | bg, imt3 | aliases `build`, `dev`, `less` shell out to `npx lessc/chokidar` | Used |
| `lein-environ` | bg, tool-store | writes `.lein-env` for `yogthos/config` (`:env` in `:dev`/`:biotestmine`) | Used |
| `lein-cljfmt` | all four | `format` alias; CI runs `lein cljfmt check` (bg) | Used (version 0.6.1 is 2018) |
| `lein-codox` | bg, imcljs, tool-store | bg: `:codox` config only; imcljs: README/CI mention; tool-store: nothing | bg/tool-store: no doc build wired up; optional |
| `lein-ancient` | bg, imt3, tool-store | no alias; manual `lein ancient` | Optional dev tool |
| `org.clojure/core.unify` (as plugin) | bg, imcljs | no `unify` reference anywhere | **Dead** |
| `lein-doo` | bg (dev), imcljs (dev) | bg: no `doo.*` require, tests run via kaocha (`tests.edn`, `bin/kaocha`, CI `lein kaocha`). imcljs: `doo.runner` in `test/cljs/imcljs/runner.cljs`, `:doo` config with PhantomJS | bg: **dead**; imcljs: used but on PhantomJS (abandoned) |
| `lambdaisland/kaocha` + `kaocha-cljs` | bg, imt3 | `tests.edn` identical in both; `lein kaocha` alias | Used |
| `:java9` profile (`--add-modules java.xml.bind`) | bg, imcljs, tool-store | not referenced by aliases/CI | **Dead and harmful on JDK >= 11** (`java.xml.bind` no longer exists) |

## 6. npm packages: who uses them

| Package | bluegenes | im-tables-3 | Evidence |
|---|---|---|---|
| `less` | used | used | `npx lessc` in `project.clj` aliases and `Makefile` |
| `chokidar-cli` | used | used | `npx chokidar` in `watch-less` alias, `Makefile` |
| `bootstrap-material-design` | used | - | `less/site.less:1` |
| `bootstrap` | indirect | - | peer of bootstrap-material-design |
| `cypress`, `cypress-file-upload`, `@4tw/cypress-drag-drop` | used | - | `npm test`, `cypress/support/commands.js:26-27` |
| `@cljs-oss/module-deps` | **0 refs** | **0 refs** | no `:npm-deps`/`:install-deps` in any build |
| `cypress-downloadfile`, `isomorphic-ws`, `wait-on`, `ws`, `xmlhttprequest` | **0 refs** | `ws`: **0 refs** | no `require`/`import`/script/CI/Dockerfile reference |
| `clipboardy` | comment only | - | `cypress/plugins/index.js:19-23` commented out |

## 7. Removal candidates

"Calls" are exact `file:line` call sites. Confidence: H = mechanical/no behaviour change, M = small code change, L = needs design or testing. "bg" = bluegenes.

### 7.1 bluegenes (Clojure/ClojureScript and plugins)

| # | Library | Files | Exact call sites | Suggested replacement | Conf. |
|---|---|---|---|---|---|
| 1 | `day8.re-frame/undo` (`project.clj:45`) | 0 | none | Delete the dependency. | H |
| 2 | `cljs-bean` (`project.clj:78`) | 2 | require-only: `cljs/events.cljs:38`, `cljs/pages/developer/devhome.cljs:8` (`[cljs-bean.core :refer [->clj]]`; `->clj` is never called) | Delete both requires and the dependency. | H |
| 3 | `lambdaisland/uri` (`project.clj:80`) | 1 | require-only: `cljs/subs.cljs:19` (`:refer [uri]`; `uri` never called) | Delete the require and the dependency. | H |
| 4 | `ring/ring-defaults` (`project.clj:62`) | 0 | none (`ring.middleware.defaults` is not required; session/params/multipart come from ring-core) | Delete the dependency (also in tool-store). | H |
| 5 | `cljsjs/google-analytics` (`project.clj:76`) | 1 | `cljs/core.cljs:12` (side-effect require, no vars). Analytics actually run via `js/gtag`: `index.clj:96-97`, `cljs/effects.cljs:64,374-375`, `cljs/route.cljs:290`, `cljs/events/boot.cljs:300-301` | Delete require and dependency (it loads the sunset Universal Analytics `ga`). | H |
| 6 | duplicate `inflections` entry | - | `project.clj:73` and `:75` | Delete one line. | H |
| 7 | `inflections` | 2 | `cljs/pages/results/widgets/views.cljs:31,33` (`plural`); `cljs/pages/querybuilder/views.cljs:393,394` (`plural` x2), `:618` (`ordinalize`) | 5 call sites for two functions: local `pluralize` (class display names; `-y`->`-ies`, `-s/-x/-ch/-sh`->`-es`, plus a small irregular map) and a 3-line ordinal helper. Do together with im-tables (item in 7.3). | M |
| 8 | `prismatic/dommy` (abandoned 2015; `project.clj:50`) | 5 | `cljs/components/search/typeahead.cljs:95-97` (`sel1 :input`, `listen!` x2 for `:focus`/`:blur`, `add-class!`/`remove-class!` `:open`); `cljs/pages/upload/views.cljs:50-57` (`sel1 :body`, `unlisten!`/`listen!` x3 on `:keypress`/`:keydown`/`:keyup`); `cljs/components/table.cljs:15` and `cljs/components/lighttable.cljs:65` (`sel1 ... :.im-target`); `cljs/components/ui/constraint.cljs:8` (require-only) | `(.querySelector el ".im-target")`; `(.addEventListener el "focus" f)` / `removeEventListener`; `(.. el -classList (add "open"))`. All of it is plain DOM API. | H |
| 9 | `json-html` (`project.clj:52`) | 3 | one call: `cljs/components/idresolver/views.cljs:126` `(json-html/edn->hiccup @everything)` (debug dump). Require-only: `cljs/pages/results/views.cljs:12`, `cljs/pages/templates/views.cljs:5` | `[:pre (with-out-str (cljs.pprint/pprint @everything))]`; delete the other two requires. Also drops `data.json` from the server classpath. | H |
| 10 | `markdown-to-hiccup` (`project.clj:53`; pulls markdown-clj, hickory, commons-lang3 3.8.1) | 1 | `cljs/utils.cljs:30` (`md/md->hiccup`, `md/component`, `md/hiccup-in`) and `:36`; consumed via `md-paragraph` (5 sites: `pages/tools/view.cljs:86`, `pages/home/views.cljs:33,97,189,290`) and `md-element` (5 sites: `pages/admin/views.cljs:77,273`, `pages/reportpage/utils.cljs:128,133`, `pages/home/views.cljs:36`) | Wrap in one function; use markdown-clj directly (`markdown.core/md->html` + sanitised `:dangerouslySetInnerHTML`) or an npm markdown lib once npm is first-class. Keep the two wrapper fns so callers don't change. | M |
| 11 | `cljs-time` (abandoned 2017; `project.clj:72`) | 7 | `cljs/time.cljs:5-13` (`formatter "d MMM, HH:mm"`, `"dd MMM yyyy HH:mm:ss"`, `unparse`, `from-long`); `cljs/error.cljs:15` (`:rfc822` `unparse`); `cljs/interceptors.cljs:65` (`time/now`); `cljs/components/ui/constraint.cljs:101-132` (`formatter`, `from-date`, `unparse`, `parse`, `to-date`); `cljs/pages/results/events.cljs:89,137` (`(to-long (now))`); `cljs/pages/home/views.cljs:72-82` (`"MMMM d, Y"`, `from-string`); `cljs/pages/lists/views.cljs:153-176` (`:mysql` formatter, `"dd MMM, Y"`) | `(js/Date.now)` for the two `to-long (now)` sites and `time/now`; `goog.i18n.DateTimeFormat` (already in CLJS; `goog.date.Date` is in use) or `js/Intl.DateTimeFormat` for the formatters. Same lib is in im-tables (7.3). | M |
| 12 | `hiccup` (server side; `project.clj:49`) | 2 | `clj/index.clj:2` (`html5`, `include-css`; `include-js` is referred but unused) and `clj/routes.clj:17,44` (`html5` for the 404 page) | Tiny and dependency-free; only worth removing if the page shell moves to a static `index.html` template with 3 substitutions. Otherwise bump to 2.0.0. | L |
| 13 | `cljs-http` (`project.clj:59`) | 1 | `cljs/effects.cljs:5`; `:184-188` `http/get`, `http/post`, `http/delete`, `http/put` in the `:http` effect | `js/fetch` or `goog.net.XhrIo`; but imcljs also depends on it, so dropping it from bg alone only removes a direct pin. | L |
| 14 | `transit-cljs` (`project.clj:71`) | 1 | `cljs/effects.cljs:22` (`t/read (t/reader :json)`), `:30` (`t/write (t/writer :json-verbose)`) for localStorage | `pr-str` / `cljs.reader/read-string`. Changes the stored format, so existing users' localStorage entries must be migrated or discarded. Transitive via cljs-http anyway. | L |
| 15 | `org.clojure/core.cache` (`project.clj:38`) | 1 | `clj/index.clj:9,35-41` (`lru-cache-factory {} :threshold 32`), `:52` (`lookup-or-miss`) | `(atom {})` + `swap!`, or `clojure.core/memoize` with a size cap. | M |
| 16 | `org.clojure/core.unify` as plugin (`project.clj:94`) | 0 | none | Delete (also `imcljs/project.clj:18`). | H |
| 17 | `lein-doo` (`project.clj:158`) | 0 | no `doo.*` require; tests are run by kaocha (`bin/kaocha`, `tests.edn`, CI `lein kaocha`) | Delete. | H |
| 18 | `day8.re-frame/test` (`project.clj:77`) | 2 (tests only) | `test/cljs/bluegenes/effects_test.cljs:5`, `events_test.cljs:5` | Move to the `:kaocha` profile (not removal). | H |
| 19 | `org.clojure/data.xml` duplicate require | 1 | `cljs/utils.cljs:3` and `:11` both `[clojure.data.xml :as xml]` | Delete one line. Library itself is needed (`utils.cljs:144,371-381`, `clj/ws/rss.clj:36`). | H |

### 7.2 bluegenes (npm)

| # | Package | Call sites | Suggested replacement |
|---|---|---|---|
| 20 | `@cljs-oss/module-deps` | none | Remove from `package.json` (and im-tables-3). Eliminates `babel-traverse 6` (critical). |
| 21 | `cypress-downloadfile` | none (`cypress/` uses `cy.readFile` only) | Remove. |
| 22 | `isomorphic-ws` | none | Remove. |
| 23 | `wait-on` | none | Remove. |
| 24 | `ws` | none | Remove (high advisories). |
| 25 | `xmlhttprequest` | none | Remove. |
| 26 | `clipboardy` (dev) | commented-out code only (`cypress/plugins/index.js:19-23`) | Remove. |

### 7.3 im-tables-3

| # | Library | Files | Exact call sites | Suggested replacement | Conf. |
|---|---|---|---|---|---|
| 27 | `@cljs-oss/module-deps`, `ws` (npm) | 0 | none | Remove both from `package.json`. | H |
| 28 | `inflections` | 5 req / 3 real | calls: `src/utils.cljs:45`, `views/dashboard/save.cljs:66,74,75`, `views/dashboard/manager/columns/main.cljs:44` (all `plural`). Require-only: `views/dashboard/exporttable.cljs:5`, `views/dashboard/manager/relationships/main.cljs:5` | Delete the 2 dead requires now; replace `plural` with a local fn shared with bluegenes. | M |
| 29 | `cljs-time` | 2 | `views/table/error.cljs:22` (`:rfc822` `unparse (now)`); `views/table/head/controls.cljs:128-159` (`formatter`, `from-date`, `unparse`, `parse`, `to-date`) | `(.toUTCString (js/Date.))` for the RFC 822 header; `goog.i18n.DateTimeFormat` / `Intl.DateTimeFormat` for the date input. | M |
| 30 | `day8.re-frame/test` | 2 (tests only) | `test/cljs/im_tables/core_test.cljs`, `test_utils.cljc` | Move to the `:kaocha` profile. | H |
| 31 | unused requires | - | `src/views.cljs:6` (`[reagent.dom.server :as server]`), `src/core.cljs:11` (`[imcljs.query :as query]`) | Delete. | H |

### 7.4 imcljs

| # | Library | Call sites | Suggested replacement |
|---|---|---|---|
| 32 | `aysylu/loom` (`project.clj:16`) | none | Delete. |
| 33 | `org.clojure/core.unify` plugin (`project.clj:18`) | none | Delete. |
| 34 | unused require `cheshire.core :as json` | `src/clj/imcljs/internal/io.clj:3` (alias never used) | Delete the require, **keep** the dependency (clj-http `:as :json` needs it at runtime). |

### 7.5 bluegenes-tool-store

| # | Library | Call sites | Suggested replacement |
|---|---|---|---|
| 35 | `org.clojure/tools.reader` (`project.clj:7`) | none (`clojure.edn` used in `package.clj`, `tools.clj`) | Delete. |
| 36 | `ring/ring-defaults` (`project.clj:13`) | none | Delete. |
| 37 | `lein-pdo` (`project.clj:34`) and `lein-codox` (`:32`) | no alias uses `pdo`; no `:codox` config | Delete both. |
| 38 | unused require `cheshire.core :as cheshire` | `src/clj/bluegenes_tool_store/auth.clj:3` | Delete the require (library is used in `package.clj:64`, `tools.clj:28,82,85`). |

Counts: 19 Clojure/plugin items for bluegenes (9 pure deletions: #1-6, 16, 17, 19; 1 move to a test profile: #18; 9 replacement candidates: #7-15), 7 npm items for bluegenes, 5 for im-tables-3, 3 for imcljs, 4 for bluegenes-tool-store (38 rows in total).

## 8. Dead or suspect files and paths

| Path | Evidence | Recommendation |
|---|---|---|
| `bluegenes/figwheel.clj` | Repo-root file, not on any `:source-paths`, last changed 2019-03-27. Requires `com.stuartsierra.component`, `ring.component.jetty`, `ring.middleware.json` (none declared in `project.clj`); lists externs `externs/imjs.js`, `externs/imtables.js` (no `externs/` dir); defines a `:test` build with `:main "bluegenes.runner"` (no such ns). Superseded by `dev/user.clj` + `:cljsbuild`/`:figwheel` in `project.clj`. | Delete. |
| `bluegenes/src/workers` | Listed in `:source-paths` but the directory does not exist (nor does `src/cljc`). | Remove both from `:source-paths`. |
| `bluegenes/config/dev`, `bluegenes/config/prod` | `:dev` and `:prod` profiles `^:replace` `:resource-paths` with them, but only `config/defaults/config.edn` exists (users are told to copy it). | Intentional for deploys, but document or `.gitkeep`. |
| `bluegenes/resources/migrations/0-postgres-setup.up.sql`, `1-create-mymine-table.up.sql` | Last touched Oct 2017 ("Create mymine table at startup"); no migration library, JDBC/Postgres dependency, or reference to `migrations` anywhere in code, config or docs ("mymine" elsewhere means the front-end MyMine feature/CSS and an example mine name, not a database). | Delete. |
| `bluegenes/script/repl.clj` | Directory `script/` is in `:source-paths` but the file is a standalone REPL helper that runs `(start-figwheel!)` at load; last touched 2017. Duplicates `dev/user.clj`. | Delete or move out of `:source-paths`. |
| `imcljs/src/cljs/imcljs/core.cljs` | Dev scratch namespace (hard-coded `beta.humanmine.org/beta` service, sample queries, three aliases of `cljs-http.client`), used as `:main` of the dev/min builds; no other repo requires `imcljs.core`. | Move to `dev/` or delete. |
| `im-tables-3/src/im_tables/views/table/head/.nfs0000001c008443b00000937c` | Stale NFS silly-rename copy of an older `controls.cljs` (16 KB vs 31 KB), sits inside `src/`. | Delete. |
| `:java9` profile in bluegenes, imcljs, tool-store `project.clj` | Adds `--add-modules java.xml.bind`, removed in JDK 11; Docker image is `distroless/java:11`. | Delete. |
