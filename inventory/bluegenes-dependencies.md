# BlueGenes front-end dependency inventory

Generated 2026-11-15 from the checked-out repos under `repos/` (read-only): `bluegenes` (app), `imcljs` (client lib), `im-tables-3` (published as `org.intermine/im-tables`), `bluegenes-tool-store`. Latest versions were looked up live: Clojars API (`latest_release`), Maven Central `maven-metadata.xml` (for `org.clojure/*` and Java libs; latest *stable*, ignoring alpha/beta/RC), npm registry `/latest`. "Last pub." is the month of the artifact's `maven-metadata.xml` update, an approximation of the last release. Advisory data is from the GitHub Advisory Database (`gh api advisories?ecosystem=npm|maven&affects=<pkg>@<ver>`), queried for every locked npm version and for the Java libs listed below.

Companion file: `bluegenes-dependency-usage.md` (who actually uses what; removal candidates).

## Summary

| Repo | Clojure/CLJS entries (deps + plugins + profile deps) | npm packages | Lein plugins that are dead/superseded | Libs with 0 uses in the repo |
|---|---|---|---|---|
| bluegenes | 58 unique (59 lines; `inflections` is listed twice) | 14 (10 dep + 4 dev) | cljsbuild, figwheel, pdo, shell, doo, core.unify | 5 Clojure + 6 npm (see usage file) |
| imcljs | 16 | none (no package.json) | cljsbuild, figwheel, core.unify | 2 (`loom`, plugin `core.unify`) |
| im-tables-3 | 28 | 4 | cljsbuild, figwheel, pdo, shell | 0 Clojure; 2 npm (`@cljs-oss/module-deps`, `ws`) |
| bluegenes-tool-store | 19 | none | pdo, codox | 3 (`tools.reader`, `ring-defaults`, `lein-pdo`) |

Headline findings:
- Everything on the Clojure side is pinned at 2019-2021 versions. Biggest structural blockers are the **cljsjs/* React 16 stack** (Reagent 0.10, react-select 2, react-day-picker 7, react-transition-group 1) and **lein-cljsbuild/lein-figwheel** (both end-of-line); the move is shadow-cljs + npm React.
- `ring 1.8.2` -> **Jetty 9.4.31**, and 9.4.x is end of life: the final Central release (9.4.58) still has an unfixed medium advisory, so fixing means moving to Jetty 11/12 (Ring 1.12+/1.14+).
- `less 1.7.5` (2014, pinned exact) is the root of ~12 vulnerable/deprecated transitive npm packages (`request 2.40`, `hawk`, `hoek`, `qs 1.0.2`, `form-data 0.1.4`...).
- Node `engines` is `10.x` in bluegenes (EOL 2021); current `less`/`wait-on`/`cypress` need Node 18-22+.
- Counts of npm advisories (GHSA, per package-version instance, unmaintained packages incl.): bluegenes 80 (7 critical, 43 high, 27 medium, 3 low; 53 of them in production-scope `dependencies`), im-tables-3 23 (2 critical, 13 high, 7 medium, 1 low); 65 distinct GHSA ids overall.

## 1. Clojure / ClojureScript (project.clj)

`dep` = `:dependencies`; `plugin` = `:plugins`; `dev dep`/`dev plugin` = `:profiles {:dev ...}`; `kaocha dep` = `:profiles {:kaocha ...}`. The `:repl`, `:prod`, `:uberjar`, `:java9`, `:biotestmine`, `:build`, `:noaot` profiles declare no dependencies.

### 1.1 bluegenes


| Dependency | Declared | Scope | Latest | Last pub. | Status / note |
|---|---|---|---|---|---|
| `org.clojure/clojure` | 1.10.1 | dep | 1.12.6 | 2026-10 | Behind 2 minors (1.12.x). 1.10.1 has CVE-2024-22871 (GHSA-vr64-r9qj-h27f, high; fixed 1.11.2). `:java9` profile adds `java.xml.bind` which no longer exists on JDK 11+. |
| `org.clojure/clojurescript` | 1.10.520 | dep | 1.12.145 | 2026-05 | 1.10.520 (2019) -> 1.12.145. Moving off lein-cljsbuild to shadow-cljs/figwheel-main also needs a recent CLJS. |
| `org.clojure/core.async` | 1.0.567 | dep | 1.9.865 | 2026-06 | Old; latest stable 1.9.865 (1.10.x alpha exists). Three different pins across repos (0.4.500 / 1.0.567 / 1.1.587). |
| `org.clojure/core.cache` | 0.8.2 | dep | 1.2.999 | 2026-09 | Used once (`index.clj`). Current. |
| `re-frame` | 0.12.0 | dep | 1.4.7 | 2026-04 | 0.12.0 (2020) -> 1.4.7. The React version is decided by Reagent, not re-frame (see reagent). |
| `day8.re-frame/http-fx` | 0.1.6 | dep | 0.2.4 | 2022-01 | 0.1.6 -> 0.2.4. Required in one file only (side-effect require registers `:http-xhrio`). |
| `day8.re-frame/async-flow-fx` | 0.1.0 | dep | 0.4.0 | 2023-05 | 0.1.0 -> 0.4.0. Required in one file only (registers `:async-flow`). |
| `day8.re-frame/forward-events-fx` | 0.0.6 | dep | 0.0.6 | 2018-06 | Latest is the same version, but unmaintained since 2018 (tiny lib). |
| `day8.re-frame/undo` | 0.3.3 | dep | 0.3.3 | 2019-09 | UNUSED in bluegenes: no `day8.re-frame.undo` require anywhere. Removal candidate. |
| `reagent` | 0.10.0 | dep | 2.0.1 | 2025-11 | 0.10.0 (React 16 via cljsjs/react) -> 2.0.1. Current Reagent takes React from npm (via shadow-cljs) instead of cljsjs; this is the blocker for dropping the cljsjs/* React 16 stack. |
| `cljsjs/react-transition-group` | 1.2.0-0 | dep | 4.3.0-0 | 2019-09 | 1.2.0-0 (React-TransitionGroup v1; exposes `js/ReactTransitionGroup.CSSTransitionGroup`, a removed API). Latest cljsjs 4.3.0-0 is an API rewrite. cljsjs packages are legacy; replace with npm `react-transition-group`. |
| `hiccup` | 1.0.5 | dep | 2.0.0 | 2025-06 | 1.0.5 (2015 API) -> 2.0.0 (`hiccup2.core`/`hiccup.page` still present). Server-side only: 2 files. |
| `prismatic/dommy` | 1.1.0 | dep | 1.1.0 | 2015-04 | Abandoned (last release 2015). 5 files; trivial DOM calls. |
| `metosin/reitit` | 0.5.12 | dep | 0.11.0 | 2026-09 | 0.5.12 -> 0.11.0. Frontend router; actively maintained. |
| `json-html` | 0.4.7 | dep | 0.4.7 | 2019-08 | 0.4.7 is the latest but unmaintained since 2019. One real call site. |
| `markdown-to-hiccup` | 0.6.2 | dep | 0.6.2 | 2019-01 | Latest = declared, unmaintained since 2019. Drags markdown-clj, hickory and commons-lang3 3.8.1 (CVE-2025-48924). |
| `cljsjs/react-day-picker` | 7.3.0-1 | dep | 8.0.7-0 | 2022-07 | 7.3.0-1 -> cljsjs 8.0.7-0 (cljsjs frozen). npm `react-day-picker` is at v9.x; v7 API (`DayPicker.Input`) is gone upstream. |
| `cljsjs/react-select` | 2.4.4-0 | dep | 2.4.4-0 | 2019-07 | 2.4.4-0 (same as cljsjs latest). npm `react-select` is at v5.x; `js/Select.Creatable` API changed (`react-select/creatable`). |
| `clj-http` | 3.10.0 | dep | 3.13.1 | 2025-06 | 3.10.0 -> 3.13.1. Bundles Apache HttpClient 4.5.8 (CVE-2020-13956 XSS, medium; fixed 4.5.13). Maintained. |
| `cljs-http` | 0.1.46 | dep | 0.1.49 | 2025-08 | 0.1.46 -> 0.1.49. Low-activity; wraps XHR via core.async. Also a transitive dep of imcljs. |
| `compojure` | 1.6.2 | dep | 1.7.2 | 2025-09 | 1.6.2 -> 1.7.2. Maintained (slow). |
| `ring` | 1.8.2 | dep | 1.15.6 | 2026-10 | 1.8.2 -> 1.15.6. Ring 1.8.2 bundles Jetty 9.4.31 (9.x is end-of-life; see Java section). Ring 1.12/1.13 use Jetty 11 and 1.14+ use Jetty 12 (JDK 17+); `bluegenes.core/add-gzip-handler` (direct Jetty `GzipHandler` interop) must be re-checked on upgrade. |
| `ring/ring-defaults` | 0.3.2 | dep | 0.7.1 | 2026-06 | 0.3.2 -> 0.7.1. UNUSED in bluegenes (no `ring.middleware.defaults`). Removal candidate (also unused in tool-store). |
| `cheshire` | 5.10.0 | dep | 6.2.1 | 2026-11 | 5.10.0 -> 6.2.1. Pulls jackson-core/smile/cbor 2.10.2 (see Java section). In imcljs only needed so clj-http's `:as :json` works. |
| `metosin/ring-http-response` | 0.9.1 | dep | 0.9.5 | 2025-01 | 0.9.1 -> 0.9.5. Small, maintained. |
| `metosin/muuntaja` | 0.6.7 | dep | 0.6.12 | 2026-08 | 0.6.7 -> 0.6.12. Brings jsonista 0.2.6 -> jackson 2.11.0 and transit-clj. |
| `yogthos/config` | 1.1.7 | dep | 1.2.1 | 2024-10 | 1.1.7 -> 1.2.1. Reads env/`.lein-env`/config.edn. |
| `com.cognitect/transit-cljs` | 0.8.256 | dep | 0.8.280 | 2022-06 | 0.8.256 -> 0.8.280. One use (localStorage serialisation). Also transitive via cljs-http. |
| `com.andrewmcveigh/cljs-time` | 0.5.2 | dep | 0.5.2 | 2017-11 | Abandoned (last release 2017); superseded by goog.date/`java.time`-style libs (tick/cljc.java-time). |
| `inflections` | 0.13.2 (x2) | dep | 0.15.0 | 2025-08 | 0.13.2 -> 0.15.0. Listed TWICE in bluegenes project.clj. Used for `plural`/`ordinalize` only. |
| `binaryage/oops` | 0.7.0 | dep | 0.7.2 | 2022-03 | 0.7.0 -> 0.7.2. Heavily used (46 files); not a candidate. |
| `cljsjs/google-analytics` | 2017.09.21-0 | dep | 2017.09.21-0 | 2019-02 | Loads Universal Analytics `analytics.js` (sunset July 2023). Code actually uses `js/gtag` (GA4 snippet in `index.clj`), so this require is dead. |
| `day8.re-frame/test` | 0.1.5 | dep | 0.1.7 | 2025-09 | Only used under `test/`; belongs in a test profile. 0.1.5 -> 0.1.7. |
| `cljs-bean` | 1.5.0 | dep | 1.9.0 | 2022-11 | UNUSED: required in 2 files but `->clj` is never called. Removal candidate. |
| `org.clojure/data.xml` | 0.2.0-alpha6 | dep | 0.2.0-alpha11 | 2026-04 | 0.2.0-alpha6 (alpha line; 0.2.0-alpha11 is latest). Used on both JVM (RSS) and CLJS (query XML). |
| `lambdaisland/uri` | 1.2.1 | dep | 1.19.155 | 2024-01 | UNUSED: `uri` is referred in `subs.cljs` but never called. Removal candidate. |
| `com.taoensso/timbre` | 4.10.0 | dep | 6.8.0 | 2025-08 | 4.10.0 (2017) -> 6.8.0. No GHSA entries; many API/config changes in 5.x/6.x. |
| `com.fzakaria/slf4j-timbre` | 0.3.19 | dep | 0.4.1 | 2023-11 | 0.3.19 -> 0.4.1. No direct require; acts as SLF4J binding for Jetty/Apache logging. |
| `org.intermine/imcljs` | 1.6.0 | dep | 1.6.0 | 2022-04 | Same as latest on Clojars (1.6.0, Apr 2022). |
| `org.intermine/im-tables` | 0.15.0 | dep | 0.15.0 | 2022-11 | Same as latest on Clojars (0.15.0, Nov 2022); built from the im-tables-3 repo. |
| `org.intermine/bluegenes-tool-store` | 0.2.3 | dep | 0.2.3 | 2021-11 | Same as latest on Clojars (0.2.3, Nov 2021). |
| `lein-cljsbuild` | 1.1.7 | plugin | 1.1.8 | 2021-03 | Superseded. Last stable release 1.1.8 (2021). Replace with shadow-cljs (also solves npm/React 18) or figwheel-main. |
| `org.clojure/core.unify` | 0.5.7 | plugin | 0.7.3 | 2026-05 | Listed as a *plugin* but nothing references it (no `clojure.core.unify` use). Dead entry. 0.5.7 is old; latest 0.7.3. |
| `lein-codox` | 0.10.5 | plugin | 0.10.8 | 2021-10 | 0.10.5 -> 0.10.8. Doc generator; no CI step uses it. Optional. |
| `lein-ancient` | 0.6.15 | plugin | 1.0.0 | 2026-05 | 0.6.15 -> 1.0.0. Dev convenience only. |
| `lein-pdo` | 0.1.1 | plugin | 0.1.1 | 2012-07 | Abandoned (2012). Used only for the `dev` alias; shadow-cljs/figwheel-main watch makes it redundant. |
| `lein-cljfmt` | 0.6.1 | plugin | 0.9.2 | 2023-01 | 0.6.1 (2018) -> 0.9.2. Used by CI (`lein cljfmt check`). |
| `lein-shell` | 0.5.0 | plugin | 0.5.0 | 2015-11 | No release since 2015; used to run `npx lessc/chokidar`. |
| `lein-environ` | 1.2.0 | plugin | 1.2.0 | 2020-05 | 1.2.0 (2020), latest. Writes `.lein-env` for yogthos/config. |
| `binaryage/devtools` | 1.0.0 | dev dep | 1.0.7 | 2023-04 | 1.0.0 -> 1.0.7 (0.9.10 in imcljs). Dev only. |
| `day8.re-frame/re-frame-10x` | 0.6.0 | dev dep | 1.12.3 | 2026-05 | Dev-only preload. 0.6.x -> 1.12.3. |
| `day8.re-frame/tracing` | 0.5.3 | dev dep | 0.9.2 | 2026-04 | Dev-only. 0.5.3 -> 0.9.2. |
| `figwheel-sidecar` | 0.5.19 | dev dep | 0.5.20 | 2020-06 | Superseded by figwheel-main; used by `dev/user.clj`, `script/repl.clj`. |
| `cider/piggieback` | 0.4.2 | dev dep | 0.8.0 | 2026-10 | 0.4.x -> 0.8.0. Dev only. |
| `lein-figwheel` | 0.5.19 | dev plugin | 0.5.20 | 2020-06 | Superseded by figwheel-main (0.5.20 final, 2020). Remove with cljsbuild. |
| `lein-doo` | 0.1.8 | dev plugin | 0.1.11 | 2018-11 | bluegenes: no `doo.*` use; tests run with kaocha (`tests.edn`, `lein kaocha` in CI). Dead entry. (imcljs genuinely uses it.) Last release 2018. |
| `lambdaisland/kaocha` | 1.0.700 | kaocha dep | 1.91.1392 | 2024-05 | bluegenes 1.0.700, im-tables 1.0-612 -> 1.91.1392. |
| `lambdaisland/kaocha-cljs` | 0.0-71 | kaocha dep | 1.9.181 | 2026-02 | 0.0-71 -> 1.9.181. |


### 1.2 imcljs


| Dependency | Declared | Scope | Latest | Last pub. | Status / note |
|---|---|---|---|---|---|
| `org.clojure/clojure` | 1.10.1 | dep | 1.12.6 | 2026-10 | Behind 2 minors (1.12.x). 1.10.1 has CVE-2024-22871 (GHSA-vr64-r9qj-h27f, high; fixed 1.11.2). `:java9` profile adds `java.xml.bind` which no longer exists on JDK 11+. |
| `org.clojure/clojurescript` | 1.10.520 | dep | 1.12.145 | 2026-05 | 1.10.520 (2019) -> 1.12.145. Moving off lein-cljsbuild to shadow-cljs/figwheel-main also needs a recent CLJS. |
| `org.clojure/core.async` | 0.4.500 | dep | 1.9.865 | 2026-06 | 0.4.500 is the oldest of the three pins; shared by cljs-http 0.1.46 (0.4.474). |
| `cljs-http` | 0.1.46 | dep | 0.1.49 | 2025-08 | 0.1.46 -> 0.1.49. Low-activity; wraps XHR via core.async. Also a transitive dep of imcljs. |
| `clj-http` | 3.10.0 | dep | 3.13.1 | 2025-06 | 3.10.0 -> 3.13.1. Bundles Apache HttpClient 4.5.8 (CVE-2020-13956 XSS, medium; fixed 4.5.13). Maintained. |
| `cheshire` | 5.8.1 | dep | 6.2.1 | 2026-11 | 5.8.1 -> 6.2.1; jackson 2.9.6. Needed only for clj-http `:as :json`; the `[cheshire.core :as json]` require in `io.clj` is unused. |
| `aysylu/loom` | 1.0.2 | dep | 1.2.4 | 2026-11 | UNUSED in imcljs: no `loom.*` require. Removal candidate. |
| `lein-cljsbuild` | 1.1.7 | plugin | 1.1.8 | 2021-03 | Superseded. Last stable release 1.1.8 (2021). Replace with shadow-cljs (also solves npm/React 18) or figwheel-main. |
| `org.clojure/core.unify` | 0.5.7 | plugin | 0.7.3 | 2026-05 | Listed as a *plugin* but nothing references it (no `clojure.core.unify` use). Dead entry. 0.5.7 is old; latest 0.7.3. |
| `lein-cljfmt` | 0.6.1 | plugin | 0.9.2 | 2023-01 | 0.6.1 (2018) -> 0.9.2. Used by CI (`lein cljfmt check`). |
| `lein-codox` | 0.10.7 | plugin | 0.10.8 | 2021-10 | 0.10.5 -> 0.10.8. Doc generator; no CI step uses it. Optional. |
| `binaryage/devtools` | 0.9.10 | dev dep | 1.0.7 | 2023-04 | 0.9.10 -> 1.0.7. |
| `figwheel-sidecar` | 0.5.19 | dev dep | 0.5.20 | 2020-06 | Superseded by figwheel-main; used by `dev/user.clj`, `script/repl.clj`. |
| `cider/piggieback` | 0.4.1 | dev dep | 0.8.0 | 2026-10 | 0.4.1 -> 0.8.0. |
| `lein-figwheel` | 0.5.19 | dev plugin | 0.5.20 | 2020-06 | Superseded by figwheel-main (0.5.20 final, 2020). Remove with cljsbuild. |
| `lein-doo` | 0.1.10 | dev plugin | 0.1.11 | 2018-11 | Used (runner `imcljs.runner`, `:doo` config). Runs against PhantomJS, which is archived/abandoned since 2018 -- switch to kaocha-cljs or shadow-cljs `:browser-test`/karma. Last release 2018. |


### 1.3 im-tables-3


| Dependency | Declared | Scope | Latest | Last pub. | Status / note |
|---|---|---|---|---|---|
| `org.clojure/clojure` | 1.10.1 | dep | 1.12.6 | 2026-10 | Behind 2 minors (1.12.x). 1.10.1 has CVE-2024-22871 (GHSA-vr64-r9qj-h27f, high; fixed 1.11.2). `:java9` profile adds `java.xml.bind` which no longer exists on JDK 11+. |
| `org.clojure/clojurescript` | 1.10.520 | dep | 1.12.145 | 2026-05 | 1.10.520 (2019) -> 1.12.145. Moving off lein-cljsbuild to shadow-cljs/figwheel-main also needs a recent CLJS. |
| `org.clojure/core.async` | 1.1.587 | dep | 1.9.865 | 2026-06 | 1.1.587 -> 1.9.865 (differs from bluegenes pin 1.0.567). |
| `re-frame` | 0.12.0 | dep | 1.4.7 | 2026-04 | 0.12.0 (2020) -> 1.4.7. The React version is decided by Reagent, not re-frame (see reagent). |
| `reagent` | 0.10.0 | dep | 2.0.1 | 2025-11 | 0.10.0 (React 16 via cljsjs/react) -> 2.0.1. Current Reagent takes React from npm (via shadow-cljs) instead of cljsjs; this is the blocker for dropping the cljsjs/* React 16 stack. |
| `cljsjs/react-transition-group` | 1.2.0-0 | dep | 4.3.0-0 | 2019-09 | 1.2.0-0; used via `js/ReactTransitionGroup.CSSTransitionGroup` (controls.cljs:17). See bluegenes row. |
| `cljsjs/highlight` | 9.12.0-2 | dep | 11.7.0-0 | 2022-12 | 9.12.0-2 -> cljsjs 11.7.0-0. Provides `js/hljs` (used in `views/table/error.cljs:48`) + 6 language bundles. highlight.js 9.12.0 has GHSA-7wwv-vh3v-89cq and CVE-2020-26237 (medium). |
| `joshkh/ctrlz` | 0.3.0 | dep | 0.3.0 | 2018-02 | Source of `joshkh.undo`; 1 file (`events.cljs`, 6 `(undoable)` interceptors). No release since 2018. |
| `binaryage/oops` | 0.7.0 | dep | 0.7.2 | 2022-03 | 0.7.0 -> 0.7.2. Heavily used (46 files); not a candidate. |
| `inflections` | 0.13.2 | dep | 0.15.0 | 2025-08 | 0.13.2 -> 0.15.0. Listed TWICE in bluegenes project.clj. Used for `plural`/`ordinalize` only. |
| `org.intermine/imcljs` | 1.6.0 | dep | 1.6.0 | 2022-04 | 1.6.0 = latest Clojars. |
| `day8.re-frame/test` | 0.1.5 | dep | 0.1.7 | 2025-09 | Only used under `test/` (2 files); belongs in the kaocha/test profile. |
| `cljsjs/react-day-picker` | 7.3.0-1 | dep | 8.0.7-0 | 2022-07 | 7.3.0-1; used in `controls.cljs:145` (`js/DayPicker.Input`). |
| `cljsjs/react-select` | 2.4.4-0 | dep | 2.4.4-0 | 2019-07 | 2.4.4-0; used in `controls.cljs:176,197` (`js/Select`). |
| `com.andrewmcveigh/cljs-time` | 0.5.2 | dep | 0.5.2 | 2017-11 | Abandoned (last release 2017); superseded by goog.date/`java.time`-style libs (tick/cljc.java-time). |
| `lein-cljsbuild` | 1.1.7 | plugin | 1.1.8 | 2021-03 | Superseded. Last stable release 1.1.8 (2021). Replace with shadow-cljs (also solves npm/React 18) or figwheel-main. |
| `lein-ancient` | 0.6.15 | plugin | 1.0.0 | 2026-05 | 0.6.15 -> 1.0.0. Dev convenience only. |
| `lein-pdo` | 0.1.1 | plugin | 0.1.1 | 2012-07 | Abandoned (2012). Used only for the `dev` alias; shadow-cljs/figwheel-main watch makes it redundant. |
| `lein-cljfmt` | 0.6.1 | plugin | 0.9.2 | 2023-01 | 0.6.1 (2018) -> 0.9.2. Used by CI (`lein cljfmt check`). |
| `lein-shell` | 0.5.0 | plugin | 0.5.0 | 2015-11 | No release since 2015; used to run `npx lessc/chokidar`. |
| `binaryage/devtools` | 1.0.0 | dev dep | 1.0.7 | 2023-04 | 1.0.0 -> 1.0.7 (0.9.10 in imcljs). Dev only. |
| `day8.re-frame/re-frame-10x` | 0.6.2 | dev dep | 1.12.3 | 2026-05 | Dev-only preload. 0.6.x -> 1.12.3. |
| `day8.re-frame/tracing` | 0.5.3 | dev dep | 0.9.2 | 2026-04 | Dev-only. 0.5.3 -> 0.9.2. |
| `figwheel-sidecar` | 0.5.20 | dev dep | 0.5.20 | 2020-06 | 0.5.20 here vs 0.5.19 elsewhere; superseded by figwheel-main. |
| `cider/piggieback` | 0.4.2 | dev dep | 0.8.0 | 2026-10 | 0.4.x -> 0.8.0. Dev only. |
| `lein-figwheel` | 0.5.19 | dev plugin | 0.5.20 | 2020-06 | Superseded by figwheel-main (0.5.20 final, 2020). Remove with cljsbuild. |
| `lambdaisland/kaocha` | 1.0-612 | kaocha dep | 1.91.1392 | 2024-05 | bluegenes 1.0.700, im-tables 1.0-612 -> 1.91.1392. |
| `lambdaisland/kaocha-cljs` | 0.0-71 | kaocha dep | 1.9.181 | 2026-02 | 0.0-71 -> 1.9.181. |


### 1.4 bluegenes-tool-store


| Dependency | Declared | Scope | Latest | Last pub. | Status / note |
|---|---|---|---|---|---|
| `org.clojure/clojure` | 1.10.1 | dep | 1.12.6 | 2026-10 | Behind 2 minors (1.12.x). 1.10.1 has CVE-2024-22871 (GHSA-vr64-r9qj-h27f, high; fixed 1.11.2). `:java9` profile adds `java.xml.bind` which no longer exists on JDK 11+. |
| `org.clojure/tools.reader` | 1.3.4 | dep | 1.6.0 | 2026-01 | Never required (only `clojure.edn` is used). Dead entry. |
| `clj-http` | 3.10.0 | dep | 3.13.1 | 2025-06 | 3.10.0 -> 3.13.1. Bundles Apache HttpClient 4.5.8 (CVE-2020-13956 XSS, medium; fixed 4.5.13). Maintained. |
| `compojure` | 1.6.2 | dep | 1.7.2 | 2025-09 | 1.6.2 -> 1.7.2. Maintained (slow). |
| `ring` | 1.8.2 | dep | 1.15.6 | 2026-10 | 1.8.2 -> 1.15.6. Ring 1.8.2 bundles Jetty 9.4.31 (9.x is end-of-life; see Java section). Ring 1.12/1.13 use Jetty 11 and 1.14+ use Jetty 12 (JDK 17+); `bluegenes.core/add-gzip-handler` (direct Jetty `GzipHandler` interop) must be re-checked on upgrade. |
| `ring/ring-defaults` | 0.3.2 | dep | 0.7.1 | 2026-06 | 0.3.2 -> 0.7.1. UNUSED (no `ring.middleware.defaults`). Removal candidate. |
| `cheshire` | 5.10.0 | dep | 6.2.1 | 2026-11 | 5.10.0 -> 6.2.1. Pulls jackson-core/smile/cbor 2.10.2 (see Java section). In imcljs only needed so clj-http's `:as :json` works. |
| `metosin/ring-http-response` | 0.9.1 | dep | 0.9.5 | 2025-01 | 0.9.1 -> 0.9.5. Small, maintained. |
| `metosin/muuntaja` | 0.6.7 | dep | 0.6.12 | 2026-08 | 0.6.7 -> 0.6.12. Brings jsonista 0.2.6 -> jackson 2.11.0 and transit-clj. |
| `yogthos/config` | 1.1.7 | dep | 1.2.1 | 2024-10 | 1.1.7 -> 1.2.1. Reads env/`.lein-env`/config.edn. |
| `com.taoensso/timbre` | 4.10.0 | dep | 6.8.0 | 2025-08 | 4.10.0 (2017) -> 6.8.0. No GHSA entries; many API/config changes in 5.x/6.x. |
| `com.fzakaria/slf4j-timbre` | 0.3.19 | dep | 0.4.1 | 2023-11 | 0.3.19 -> 0.4.1. No direct require; acts as SLF4J binding for Jetty/Apache logging. |
| `org.apache.commons/commons-compress` | 1.19 | dep | 1.28.0 | 2025-07 | 1.19 -> 1.28.0. 5 GHSA advisories (4 high; fixed 1.21/1.26). Used to untar npm packages downloaded from the registry (`package.clj`). |
| `org.intermine/imcljs` | 1.4.3 | dep | 1.6.0 | 2022-04 | 1.4.3 vs latest 1.6.0 (bluegenes pins 1.6.0 and wins resolution). Only `imcljs.auth/who-am-i?` is used. |
| `lein-codox` | 0.10.5 | plugin | 0.10.8 | 2021-10 | No `:codox` config or alias. Dead entry. |
| `lein-ancient` | 0.6.15 | plugin | 1.0.0 | 2026-05 | 0.6.15 -> 1.0.0. Dev convenience only. |
| `lein-pdo` | 0.1.1 | plugin | 0.1.1 | 2012-07 | Declared but no alias uses `pdo` in this repo. Dead entry. |
| `lein-cljfmt` | 0.6.1 | plugin | 0.9.2 | 2023-01 | 0.6.1 (2018) -> 0.9.2. Used by CI (`lein cljfmt check`). |
| `lein-environ` | 1.2.0 | plugin | 1.2.0 | 2020-05 | 1.2.0 (2020), latest. Writes `.lein-env` for yogthos/config. |

## 2. npm (package.json)

`imcljs` and `bluegenes-tool-store` have no package.json. Locked versions are from each repo's `package-lock.json` (bluegenes: lockfileVersion 1, im-tables-3: lockfileVersion 2).

### 2.1 bluegenes (10 dependencies, 4 devDependencies)

| Package | Declared | Locked | Latest | Direct GHSA | Used? | Status / note |
|---|---|---|---|---|---|---|
| `@cljs-oss/module-deps` | ^1.1.1 | 1.1.1 | 1.1.1 | 0 | no reference anywhere | ClojureScript's own `:npm-deps` helper; bluegenes sets neither `:npm-deps` nor `:install-deps`. Brings `babel-traverse 6` (critical), old `lodash`/`minimist`. Remove. |
| `bootstrap` | ^3.3.7 | 3.4.1 | 5.3.9 (3.x final: 3.4.1, 2019) | 2 real + 2 data-quirk matches (medium; no 3.x fix) | indirectly (peer of bootstrap-material-design, LESS source) | Bootstrap 3 is end-of-life. See also CDN section: CSS/JS come from the CDN, not from this package. |
| `bootstrap-material-design` | git `intermine/bootstrap-material-design#im-0.0.2` | commit ff99133 | n/a (upstream npm 4.1.3 is an unrelated rewrite) | n/a | yes: `less/site.less:1` imports it | Private fork of an abandoned Bootstrap-3 theme; requires `bootstrap>=3`, `jquery>=1.9.1`. Pins the whole UI to Bootstrap 3 + jQuery. |
| `chokidar-cli` | ^2.1.0 | 2.1.0 | 3.0.0 | 0 | yes: `lein less`/`dev` alias and `Makefile` | Pulls `glob-parent 5.1.1`, `braces 3.0.2`, `y18n 4.0.0`, `picomatch 2.2.2` (all high, see 3.2). Update to 3.x or use `less --watch`-style tooling / shadow-cljs hooks. |
| `cypress-downloadfile` | ^1.2.1 | 1.2.1 | 1.2.4 | 0 | no reference in `cypress/` | Listed in `dependencies` (not dev); pulls `node-fetch 2.6.1` (high). Remove. |
| `isomorphic-ws` | ^4.0.1 | 4.0.1 | 5.0.0 | 0 | no reference | Remove. |
| `less` | 1.7.5 (exact) | 1.7.5 | 4.9.1 | 0 direct (but see 3.2) | yes: `npx lessc` in aliases/Makefile | **Superseded.** 2014 release, deprecated `request` 2.40 tree. Less 4 changes default math (`parens-division`) and compress handling, so LESS may need `--math=always`/`-x` review. Needs Node >=18 on latest. |
| `wait-on` | ^3.3.0 | 3.3.0 | 9.5.1 | 0 | no reference (scripts/CI don't call it) | In `dependencies`; pulls `request`, `joi`. Remove or move to dev if CI adopts it. |
| `ws` | ^7.3.1 | 7.3.1 | 8.23.0 (7.x: 7.5.14) | 3 (2 high, 1 medium) | no reference | GHSA-3h5v-q93c-6h6q (CVE-2024-37890, fixed 7.5.10), GHSA-96hv-2xvq-fx4p (CVE-2026-48779, fixed 7.5.11), GHSA-6fc8-4gx4-v693 (CVE-2021-32640, fixed 7.4.6). Remove (or bump to 7.5.14). |
| `xmlhttprequest` | ^1.8.0 | 1.8.0 | 1.8.0 | 0 | no reference | Unmaintained since 2022 (the *-ssl fork has CVEs; this package does not). Remove. |
| `@4tw/cypress-drag-drop` (dev) | ^1.8.0 | 1.8.0 | 2.3.1 | 0 | yes: `cypress/support/commands.js:27` | Fine; bump with Cypress. |
| `clipboardy` (dev) | ^2.3.0 | 2.3.0 | 5.3.2 | 0 | only in commented-out code (`cypress/plugins/index.js:19`) | Remove. Pulls `cross-spawn`, `semver` (high). |
| `cypress` (dev) | ^6.0.0 | 6.9.1 | 16.3.0 | 0 | yes: `npm test`, CI | Cypress 6 (Dec 2020) is ~10 majors behind; transitive tree has `minimatch`, `moment`, `tmp`, `extract-zip`, `brace-expansion`, `@cypress/request`... (all dev scope). |
| `cypress-file-upload` (dev) | ^5.0.8 | 5.0.8 | 5.0.8 | 0 | yes: `commands.js:26` | Current (no longer needed on Cypress >= 9.3, which has `selectFile`). |

### 2.2 im-tables-3 (4 dependencies, no devDependencies)

| Package | Declared | Locked | Latest | Direct GHSA | Used? | Status / note |
|---|---|---|---|---|---|---|
| `@cljs-oss/module-deps` | ^1.1.1 | 1.1.1 | 1.1.1 | 0 | no | As above. Remove. |
| `chokidar-cli` | ^2.1.0 | 2.1.0 | 3.0.0 | 0 | yes (`watch-less` alias) | As above. |
| `less` | 1.7.5 | 1.7.5 | 4.9.1 | 0 | yes (`lessc` in aliases) | As above. |
| `ws` | ^7.4.6 | 7.4.6 | 8.23.0 (7.x: 7.5.14) | 2 (high: CVE-2024-37890, CVE-2026-48779) | no | Remove. |

## 3. Known vulnerabilities

### 3.1 npm packages you declare (GitHub Advisory Database, queried per locked version)

| Package@locked | Advisories | Fixed in | Notes |
|---|---|---|---|
| `ws@7.3.1` (bluegenes), `ws@7.4.6` (im-tables-3) | GHSA-96hv-2xvq-fx4p / CVE-2026-48779 (high, memory-exhaustion DoS), GHSA-3h5v-q93c-6h6q / CVE-2024-37890 (high, DoS via many headers), GHSA-6fc8-4gx4-v693 / CVE-2021-32640 (medium ReDoS; 7.3.1 only) | 7.5.11 / 7.5.10 / 7.4.6 | Not referenced by any source file; removal is the fix. |
| `bootstrap@3.4.1` | 2 real: GHSA-vxmc-5x29-h64v / CVE-2024-6485 (XSS via data-* attrs), GHSA-q58r-hwc8-rm9j / CVE-2025-1647 (tooltip/popover XSS). 2 more (CVE-2019-8331, CVE-2016-10735) match only because the DB carries loose `< 4.3.1` / `< 4.0.0-beta.2` ranges although 3.4.0/3.4.1 are the 3.x fixes: treat as data quirks | none in 3.x (maintainers EOL) | The CDN copy is 3.3.7, which additionally has CVE-2018-14040/14042/20676/20677 (fixed in 3.4.0). |
| `less@1.7.5` | none against `less` itself | n/a | Risk is its dependency tree: `request 2.40.0` (CVE-2017-16026, CVE-2023-28155), `hawk 1.1.1` (CVE-2016-2515, CVE-2022-29167), `hoek 0.9.1` (CVE-2018-3728, CVE-2020-36604), `qs 1.0.2`, `form-data 0.1.4` (CVE-2025-7783, critical), `mime 1.2.11`, `tunnel-agent 0.4.3`, `clean-css 2.2.23`. Build-time only (CSS compile) but all in `dependencies`. |
| `cypress@6.9.1` | none direct | n/a | Dev only; transitive items in 3.2 (`minimatch`, `moment`, `tmp`, `extract-zip`, `brace-expansion`, `@cypress/request`, `tough-cookie`). |
| `wait-on@3.3.0`, `xmlhttprequest@1.8.0`, `isomorphic-ws@4.0.1`, `chokidar-cli@2.1.0`, `clipboardy@2.3.0` | none direct | n/a | `chokidar-cli` and `clipboardy` pull vulnerable transitive packages (3.2). The other three are unused. |
| `@cljs-oss/module-deps@1.1.1`, `cypress-downloadfile@1.2.1` | none direct | n/a | Pull `babel-traverse 6.26.0` (CVE-2023-45133, critical) and `node-fetch 2.6.1` (CVE-2022-0235, high) respectively. |

### 3.2 Transitive npm packages with advisories (all locked versions of both lockfiles scanned: 385 distinct package@version pairs, 47 affected)

"# adv." counts advisory x package-version instances. "Scope" is npm's `dev` flag in the lockfile (prod = reachable from `dependencies`). "Reachable from" is a name-level approximation of which declared package requires it; use `npm ls <pkg>` to confirm. bg = bluegenes, imt3 = im-tables-3.

| Package | Locked version(s) | Worst | # adv. | Example IDs | Scope | Repo | Reachable from (approx.) |
|---|---|---|---|---|---|---|---|
| `babel-traverse` | 6.26.0 | crit | 1 | CVE-2023-45133 | prod | bg,imt3 | @cljs-oss/module-deps |
| `form-data` | 0.1.4, 2.3.3 | crit | 4 | CVE-2025-7783, CVE-2026-12143 (+1 more) | prod | bg,imt3 | cypress, less, wait-on |
| `json-schema` | 0.2.3 | crit | 1 | CVE-2021-3918 | prod | bg | cypress, less, wait-on |
| `minimist` | 0.0.8, 1.2.0, 1.2.5 | crit | 5 | CVE-2020-7598, CVE-2021-44906 (+2 more) | prod | bg | @cljs-oss/module-deps, cypress, less, wait-on |
| `ansi-regex` | 3.0.0, 4.1.0, 5.0.0 | high | 3 | CVE-2021-3807 | prod | bg | @cljs-oss/module-deps, chokidar-cli, cypress |
| `async` | 3.2.0 | high | 1 | CVE-2021-43138 | dev | bg | cypress, less, wait-on |
| `brace-expansion` | 1.1.11 | high | 8 | CVE-2025-5889, CVE-2026-102276, CVE-2026-102277 (+5 more) | dev | bg | cypress |
| `braces` | 3.0.2 | high | 1 | CVE-2024-4068 | prod | bg,imt3 | chokidar-cli |
| `cached-path-relative` | 1.0.2 | high | 1 | CVE-2021-23518 | prod | bg | @cljs-oss/module-deps |
| `cross-spawn` | 6.0.5, 7.0.3 | high | 2 | CVE-2024-21538 | dev | bg | clipboardy, cypress |
| `extract-zip` | 1.7.0 | high | 2 | CVE-2026-19693, CVE-2026-56876 | dev | bg | cypress |
| `glob-parent` | 5.1.1 | high | 1 | CVE-2020-28469 | prod | bg | chokidar-cli |
| `hawk` | 1.1.1 | high | 2 | CVE-2016-2515, CVE-2022-29167 | prod | bg,imt3 | less, wait-on |
| `hoek` | 0.9.1 | high | 2 | CVE-2018-3728, CVE-2020-36604 | prod | bg,imt3 | less, wait-on |
| `lodash` | 4.17.15, 4.17.21 | high | 7 | CVE-2020-28500, CVE-2020-8203, CVE-2021-23337 (+4 more) | prod | bg,imt3 | @cljs-oss/module-deps, cypress |
| `mime` | 1.2.11 | high | 1 | CVE-2017-16138 | prod | bg,imt3 | cypress, less, wait-on |
| `minimatch` | 3.0.4 | high | 4 | CVE-2022-3517, CVE-2026-26996, CVE-2026-27903 (+1 more) | dev | bg | cypress |
| `moment` | 2.29.1 | high | 2 | CVE-2022-24785, CVE-2022-31129 | dev | bg | cypress |
| `node-fetch` | 2.6.1 | high | 1 | CVE-2022-0235 | prod | bg | cypress-downloadfile |
| `picomatch` | 2.2.2, 2.3.1 | high | 4 | CVE-2026-33671, CVE-2026-33672 (+1 more) | prod | bg,imt3 | chokidar-cli |
| `qs` | 1.0.2, 6.5.2 | high | 6 | CVE-2017-1000048, CVE-2022-24999, CVE-2025-15284 (+3 more) | prod | bg,imt3 | cypress, less, wait-on |
| `semver` | 5.7.1 | high | 1 | CVE-2022-25883 | dev | bg | clipboardy, cypress |
| `tmp` | 0.2.1 | high | 2 | CVE-2025-54798, CVE-2026-44705 | dev | bg | cypress |
| `ws` | 7.3.1, 7.4.6 | high | 5 | CVE-2021-32640, CVE-2024-37890, CVE-2026-48779 (+2 more) | prod | bg,imt3 | ws |
| `y18n` | 4.0.0 | high | 1 | CVE-2020-7774 | prod | bg | chokidar-cli |
| `@cypress/request` | 2.88.5 | med | 1 | CVE-2023-28155 | dev | bg | cypress |
| `ajv` | 6.10.2 | med | 2 | CVE-2020-15366, CVE-2025-69873 | prod | bg | cypress, less, wait-on |
| `bootstrap` | 3.4.1 | med | 4 | CVE-2016-10735, CVE-2019-8331, CVE-2024-6485 (+1 more) | prod | bg | bootstrap, bootstrap-material-design |
| `path-parse` | 1.0.6 | med | 1 | CVE-2021-23343 | prod | bg | @cljs-oss/module-deps |
| `request` | 2.40.0, 2.88.0 | med | 3 | CVE-2017-16026, CVE-2023-28155 | prod | bg,imt3 | less, wait-on |
| `tough-cookie` | 2.4.3, 2.5.0, 4.0.0 | med | 3 | CVE-2023-26136 | prod | bg,imt3 | cypress, less, wait-on |
| `tunnel-agent` | 0.4.3 | med | 1 | GHSA-xc7v-wxcw-j472 | prod | bg,imt3 | cypress, less, wait-on |
| `uuid` | 3.3.3 | med | 1 | CVE-2026-41907 | prod | bg | cypress, less, wait-on |
| `clean-css` | 2.2.23 | low | 1 | GHSA-wxhq-pm8v-cw75 | prod | bg,imt3 | less |

Practical reading: of 36 distinct vulnerable packages, the production-scope ones come almost entirely from four declared packages that are either unused or replaceable: `less@1.7.5` (request/hawk/hoek/qs/form-data/mime/tunnel-agent/clean-css/tough-cookie/uuid/ajv/json-schema), `@cljs-oss/module-deps` (babel-traverse/lodash/minimist/cached-path-relative/path-parse), `chokidar-cli` (braces/glob-parent/picomatch/y18n/ansi-regex) and `cypress-downloadfile` (node-fetch). None of these ship to browsers; they affect developer machines and CI.

### 3.3 Java libraries pulled in transitively (GitHub Advisory Database, maven ecosystem)

Resolved versions are read from the artifacts' POMs on Clojars/Central; the real classpath should be confirmed with `lein deps :tree` (not run: read-only task). Clojars-only libraries (ring, compojure, clj-http, cheshire, timbre, muuntaja, hiccup) have no GHSA entries of their own; the risk is in the Java libraries they bundle.

| Java library | Resolved version | Pulled in by | Maven Central latest | Advisories against that version |
|---|---|---|---|---|
| `jetty-server` | 9.4.31.v20200723 | `ring-jetty-adapter 1.8.2` (bluegenes, tool-store) | 12.1.15 (9.4 line ends at 9.4.58) | 9 (2 high): CVE-2024-13009 (`GzipHandler` request-body mishandling, fixed 9.4.57; **bluegenes enables `GzipHandler` in `core.clj`**), CVE-2021-28165 (TLS frame CPU DoS, fixed 9.4.39); medium CVE-2020-27223, CVE-2020-27218, CVE-2023-26048, CVE-2024-8184, CVE-2026-6790 (Host/authority mismatch, **no fixed 9.4 release**); low CVE-2021-34428, CVE-2023-26049 |
| `jetty-http` | 9.4.31 | same | 12.1.15 | 5 (1 high): CVE-2026-2332 (request smuggling via chunked extensions; patched only in 10.0.28/11.0.29/12.x, not on Central for 9.4); medium CVE-2023-40167, CVE-2024-6763; low CVE-2022-2047, CVE-2025-11143 (no 9.4 fix) |
| `jackson-core` | 2.10.2 (cheshire 5.10.0); 2.11.0 (jsonista via muuntaja); 2.9.6 (cheshire 5.8.1, imcljs) | cheshire, muuntaja | 2.23.0 | 4 (3 high): CVE-2025-52999 (deep-nesting StackOverflow, fixed 2.15.0), CVE-2026-68494, CVE-2026-89425; medium CVE-2025-49128 |
| `jackson-databind` | 2.11.0 (jsonista 0.2.6) | muuntaja 0.6.7 | 2.23.0 | 15 (8 high): CVE-2021-46877, CVE-2022-42003/42004, CVE-2020-36518, CVE-2026-54512/54513, CVE-2026-91776/91777 ... (2.10.x additionally CVE-2020-25649 XXE) |
| `jackson-dataformat-cbor` / `-smile` | 2.10.2 | cheshire 5.10.0 | 2.23.0 | cbor: CVE-2020-28491 (high, fixed 2.11.4); smile: none |
| `httpclient` (+`httpcore`, `httpmime`, `httpasyncclient`) | 4.5.8 (core 4.4.11) | clj-http 3.10.0 | 4.5.14 (core 4.4.16) | CVE-2020-13956 (medium, fixed 4.5.13); others none |
| `commons-fileupload` | 1.4 | ring-core 1.8.2 | 1.6.0 | CVE-2023-24998 (high, fixed 1.5), CVE-2025-48976 (high, fixed 1.6.0). **Reachable: `wrap-multipart-params` is used in `bluegenes.ws.ids`.** |
| `commons-io` | 2.6 | ring-core, clj-http | 2.22.0 | CVE-2024-47554 (high, fixed 2.14.0), CVE-2021-29425 (medium, fixed 2.7) |
| `commons-compress` | 1.19 (declared) | bluegenes-tool-store | 1.28.0 | 5 (4 high): CVE-2021-35515/35516/35517/36090 (fixed 1.21), CVE-2024-25710 (medium, fixed 1.26). **Reachable: untars npm tarballs in `package.clj`.** |
| `commons-lang3` | 3.8.1 | markdown-to-hiccup 0.6.2 | 3.22.0 | CVE-2025-48924 (medium, fixed 3.18.0) |
| `org.clojure/clojure` | 1.10.1 | declared | 1.12.6 | CVE-2024-22871 (high, fixed 1.11.2) |
| `core.async`, `core.cache`, `data.xml`, `tools.reader`, `data.json 0.2.6`, `clojurescript`, `slf4j-api`, `servlet-api`, `commons-codec 1.12`, `transit-clj` | as declared/resolved | various | - | no advisories returned |

timbre 4.10.0 / slf4j-timbre 0.3.19: no advisories found (Clojars libs are not covered by GHSA; no known CVEs from memory). `ring 1.8.2`, `compojure 1.6.2`, `clj-http 3.10.0`, `cheshire 5.10.0`: likewise no entries for the libraries themselves.

Upgrade notes: Ring 1.10.0 pulls Jetty 9.4.51; Ring 1.12/1.13 use Jetty 11; Ring 1.14+ use Jetty 12 (JDK 17+; the Docker image is `distroless/java:11`, CI uses JDK 8).

## 4. CDN-loaded assets (hard-coded in `bluegenes/src/clj/bluegenes/index.clj`)

| Asset | Line | Pinned version | Latest (same major) | Latest overall | Advisories at pinned version | Note |
|---|---|---|---|---|---|---|
| Bootstrap CSS (`maxcdn.bootstrapcdn.com`) | 99 | 3.3.7 | 3.4.1 | 5.3.9 | GHSA-ph58-4vrj-w6hr, GHSA-3mgp-fx93-9xv5, CVE-2018-14042, CVE-2016-10735 (medium XSS, all fixed in 3.4.0) + CVE-2024-6485, CVE-2025-1647 (unfixed) | `maxcdn.bootstrapcdn.com` is the legacy host. |
| Bootstrap JS (`cdnjs .../twitter-bootstrap/3.3.7/...`) | 128 | 3.3.7 | 3.4.1 | 5.3.9 | same as above | JS is the part with the XSS issues (tooltip/popover/data-target). Used by `js/$ ... popover/dropdown/modal` calls. |
| jQuery (`code.jquery.com`, SRI pinned) | 126 | 3.1.0 | 3.7.1 | 4.0.0 | CVE-2019-11358 (fixed 3.4.0), CVE-2020-11022, CVE-2020-11023 (fixed 3.5.0) | `js/$` is used on 16 lines in bluegenes (8 files) and 17 in im-tables (6 files). |
| Font Awesome CSS (cdnjs) | 102 | 4.7.0 | 4.7.0 (final 4.x) | v6/v7 now under `@fortawesome/*` | none | FA4 is end-of-life; icons are `fa fa-*` classes. |
| highlight.js CSS theme (cdnjs) | 103 | 9.12.0 | 9.18.5 | 11.12.0 | GHSA-7wwv-vh3v-89cq (ReDoS, medium), CVE-2020-26237 (prototype pollution, fixed 9.18.2) | Only the stylesheet is on the CDN; the JS (`js/hljs`) comes from `cljsjs/highlight 9.12.0-2` via im-tables, so the two must stay in the same major. |
| Gridlex CSS (cdnjs) | 98 | 2.2.0 | 2.7.1 | 2.7.1 | none | Last npm release 2018-02. |
| vega | 130 | 5.20.2 | 5.33.1 | 6.4.0 | 6 medium/high XSS advisories: CVE-2023-26486/26487 (fixed 5.23.0), CVE-2025-25304 (5.26.0), CVE-2025-26619 (5.31.0), CVE-2025-27793 (5.32.0), CVE-2025-59840 (high; fixed 6.2.0 only) | Used via `js/vegaEmbed` (`components/viz/common.cljs:27`); no SRI hashes. |
| vega-lite | 131 | 5.1.0 | 5.23.0 | 6.5.0 | none | Keep on a matching vega major. |
| vega-embed | 132 | 6.17.0 | 6.29.0 | 7.3.0 | none | |

Other external references: `less/site.less:36` imports Google Fonts (Roboto 400/700/300) over HTTP at CSS-compile time; `navbar/nav.cljs:23` loads a logo from `cdn.rawgit.com` (rawgit was shut down in 2019, treat as broken); `index.clj:96` loads the Google Tag Manager `gtag.js` when `:google-analytics` is configured. `im-tables-3/resources/public/index.html` (dev page) repeats gridlex 2.2.0, Bootstrap 3.3.7 and FA 4.7.0.

## 5. Lookups that failed or are unverified

| Item | Result |
|---|---|
| `api.cdnjs.com` (cdnjs library versions) | Blocked by the sandbox firewall (approval required). Versions for gridlex, font-awesome, highlight.js, Bootstrap were taken from the npm registry instead; cdnjs may lag npm. |
| `maxcdn.bootstrapcdn.com`, `cdn.rawgit.com` reachability | Blocked by the sandbox firewall; liveness not verified (statements above are from general knowledge). |
| `com.cognitect/transit-cljs`, `org.apache.commons/commons-compress` on Clojars | Not on Clojars; looked up on Maven Central instead (0.8.280, 1.28.0). |
| `timbre`, `slf4j-timbre`, `transit-cljs`, `cljs-time` POMs | Have no `<dependencies>` block that could be parsed; their Java transitive dependencies were not enumerated. |
| Full resolved Maven classpath | Not computed (would need `lein deps :tree`, which was out of scope). Versions in 3.3 come from direct POM reading; Maven "nearest wins" may pick newer ones (e.g. `ring-codec`, `commons-io` via other paths). |
| npm advisories | The `affects=` filter matched on exact locked versions; advisories without a patched version (e.g. bootstrap 3) are included. `minimist`, `lodash` etc. appear in several nested versions. |
