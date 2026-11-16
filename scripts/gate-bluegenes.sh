#!/usr/bin/env bash
# gate-bluegenes.sh - quality gate for a BlueGenes worktree (dual mode).
#
# Usage:
#   gate-bluegenes.sh <worktree-path> [--with-prod] [--allow-no-browser] [--skip-npm-audit]
#
# Mode: GATE_MODE=auto (default) uses the Leiningen path when the worktree has
# project.clj, otherwise the deps.edn/shadow-cljs path. GATE_MODE=lein or
# GATE_MODE=deps forces one (useful while a tree has both build files).
#
# Steps (each timed, each logged to <worktree>/.gate-logs/<step>.log):
#
# deps.edn mode (deps.edn + shadow-cljs.edn + build.clj; JDK 21 by default)
#   1. fmt       : clojure -M:fmt check  (cljfmt 0.12, config in .cljfmt.edn)
#   2. npm       : npm ci  (only if node_modules is missing or package-lock.json
#                  changed since the last successful gate run)
#   3. test      : npx shadow-cljs compile test && node target/test/node-tests.js
#                  (:node-test build of test/cljs; a missing "Ran N tests"
#                  summary or any failure/error is a gate failure)
#   3b. test-clj : clojure -M:test-clj (server-side clojure.test, when deps.edn has the alias)
#   4b. closure-preds : the dev build must not call goog.is* predicates removed from the Closure Library
#   4. app-dev   : npx shadow-cljs compile app  (the dev build; warnings counted,
#                  listed in .gate-logs/app-dev-warnings.txt)
#      app-load  : a dev build as one file (--config-merge {:output-dir
#                  "target/bundle-dev" :devtools {:loader-mode :eval}}) loaded in
#                  a node vm with stub DOM globals by scripts/bluegenes-runbundle.js;
#                  any exception while a namespace loads fails the gate (e.g. a
#                  top-level def reading js/ReactTransitionGroup before the
#                  cljsjs stand-in that sets it). Only the re-frame-10x preload,
#                  which needs a real DOM, may fail.
#   5. prod      : (only with --with-prod)
#      uber      : clojure -T:build uber  (clean, im-tables CSS, lessc, shadow
#                  release with hashed file names, fingerprinted CSS, AOT of
#                  bluegenes.core) -> target/bluegenes.jar
#      bundle-load: the release app.<hash>.js loaded the same way (no exception,
#                  the four cljsjs globals set, bluegenes.core.init defined)
#      jar-check : jar has jetty classes, bluegenes/core.class, manifest.edn, the
#                  hashed app js and css
#      smoke-NN  : for each JDK in GATE_SMOKE_JDKS: run the uberjar on $GATE_PORT
#                  (default 5055) from a temp dir; time until /version answers;
#                  fetch /, /version,
#                  /api/tools/all and the js/css files the page references; the
#                  hash in those names must be the one in manifest.edn and in
#                  serverVars.version (the client-state reset key)
#      libjar    : clojure -T:build install (Clojars-style jar + pom into ~/.m2),
#                  check the pom coordinates and the jar contents, then resolve
#                  its dependencies as a consumer would (clojure -Spath) and run
#                  `java -cp <jars> bluegenes.core` (the rdfc2im contract) on the
#                  oldest JDK in GATE_SMOKE_JDKS, fetching / and the app js
#      Cypress is never run.
#
# Leiningen mode (project.clj; JDK 11 by default)
#   1. cljfmt   : "$LEIN" cljfmt check
#   2. npm      : as above
#   3. kaocha   : lein kaocha  (ClojureScript unit tests in a headless browser)
#   4. prod     : (only with --with-prod) lein uberjar. The :uberjar profile's
#                 prep-tasks run `lein build` (clean, assets, lessc -x, advanced
#                 cljsbuild "min", fingerprint-css) then AOT-compile, producing
#                 target/bluegenes.jar. The gate then checks the jar contains
#                 jetty classes and smoke-starts it on $GATE_PORT (default 5055),
#                 curls /, /version and the fingerprinted app js, and stops it.
#                 Cypress is never run.
#
# Options:
#   --with-prod          also run the production build (slow: several minutes)
#   --allow-no-browser   lein mode: if no usable headless browser is found, SKIP
#                        kaocha instead of failing. (deps mode needs no browser.)
#   --skip-npm-audit     do not record `npm audit` counts (audit is informational
#                        only and never fails the gate)
#
# Environment overrides:
#   GATE_MODE            auto | lein | deps (see above)
#   GATE_JAVA_HOME       build JDK. Default /usr/lib/jvm/java-21-openjdk-arm64 in
#                        deps mode, /usr/lib/jvm/java-11-openjdk-arm64 in lein mode.
#   GATE_SMOKE_JDKS      deps mode: JDK versions to smoke-test the uberjar on
#                        (default "21 17"; /usr/lib/jvm/java-NN-openjdk-arm64)
#   GATE_CLOJURE         clojure CLI, default `clojure` on PATH
#   GATE_LEIN            lein executable. Default /home/agent/tools/lein/lein
#                        (upstream 2.11.2 script, LEIN_HOME=/home/agent/tools/lein/home)
#                        if present, else `lein` on PATH. NOTE: the Debian/Ubuntu
#                        packaged lein 2.11.2 (/usr/bin/lein) has a broken dependency
#                        resolver that silently drops transitive deps (e.g. jetty-http,
#                        jetty-io, jetty-util under ring-jetty-adapter) and produces a
#                        uberjar that cannot start. The gate warns if it is used.
#   GATE_PORT            port for the smoke tests (default 5055)
#   GATE_BROWSER         lein mode: chrome/chromium executable for kaocha
#                        (the value `none` forces the no-browser path)
#   GATE_BROWSER_LIBS    optional LD_LIBRARY_PATH needed by that executable
#                        (default: <dir of browser>/al2023/lib if it exists)
#   CYPRESS_INSTALL_BINARY  default 0 here: cypress 6.9 has no linux-arm64 binary
#                        and the download host is blocked in the sandbox, and the
#                        gate never runs cypress. Set to "" to get the real install.
#
# Lein mode, browser discovery order: $GATE_BROWSER, google-chrome-stable,
# google-chrome, chromium, chromium-browser (only if `--version` works, i.e. not
# a snap stub), /home/agent/browser-scratch/chromium-arm64/chromium (Sparticuz
# arm64 build). kaocha-cljs uses cljs.repl.browser/repl-env which starts a
# server on :9000 and opens a browser via clojure.java.browse -> xdg-open. The
# gate puts a shim `xdg-open` first on PATH that starts the discovered browser
# headless, so it never tries to open a page on the host desktop. Browser
# processes are killed at exit.
#
# Exit code: 0 = every executed step passed (skipped-by-allowance steps count as
# pass); 1 = at least one step failed; 2 = usage error.
# Final line of output is a one-line machine-greppable summary: GATE RESULT: ...

set -u
HERE=$(cd "$(dirname "$0")" && pwd)
usage() { awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"; exit 2; }

WT=""; WITH_PROD=0; ALLOW_NO_BROWSER=0; AUDIT=1
for a in "$@"; do
  case "$a" in
    --with-prod) WITH_PROD=1 ;;
    --allow-no-browser) ALLOW_NO_BROWSER=1 ;;
    --skip-npm-audit) AUDIT=0 ;;
    -h|--help) usage ;;
    -*) echo "unknown option $a" >&2; usage ;;
    *) if [ -z "$WT" ]; then WT=$a; else echo "unexpected arg $a" >&2; usage; fi ;;
  esac
done
[ -n "$WT" ] || usage
[ -d "$WT" ] || { echo "no such directory: $WT" >&2; exit 2; }
WT=$(cd "$WT" && pwd)
cd "$WT" || exit 2

MODE=${GATE_MODE:-auto}
if [ "$MODE" = auto ]; then
  if [ -f project.clj ]; then MODE=lein
  elif [ -f deps.edn ] && [ -f shadow-cljs.edn ]; then MODE=deps
  else echo "not a bluegenes checkout (no project.clj, no deps.edn+shadow-cljs.edn): $WT" >&2; exit 2; fi
fi
case "$MODE" in
  lein) [ -f project.clj ] || { echo "GATE_MODE=lein but no project.clj in $WT" >&2; exit 2; } ;;
  deps) [ -f deps.edn ] && [ -f shadow-cljs.edn ] || { echo "GATE_MODE=deps but no deps.edn/shadow-cljs.edn in $WT" >&2; exit 2; } ;;
  *) echo "GATE_MODE must be auto, lein or deps" >&2; exit 2 ;;
esac

if [ "$MODE" = deps ]; then DEFAULT_JDK=/usr/lib/jvm/java-21-openjdk-arm64; else DEFAULT_JDK=/usr/lib/jvm/java-11-openjdk-arm64; fi
export JAVA_HOME=${GATE_JAVA_HOME:-$DEFAULT_JDK}
export PATH=$JAVA_HOME/bin:$PATH
export CYPRESS_INSTALL_BINARY=${CYPRESS_INSTALL_BINARY-0}
CLJ=${GATE_CLOJURE:-clojure}
PORT=${GATE_PORT:-5055}

LOGS=$WT/.gate-logs
mkdir -p "$LOGS"
# keep the log dir out of `git status` without touching tracked files
[ -f "$LOGS/.gitignore" ] || echo '*' > "$LOGS/.gitignore"

declare -a NAMES RESULTS TIMES NOTES
record() { NAMES+=("$1"); RESULTS+=("$2"); TIMES+=("$3"); NOTES+=("$4"); }
FAILED=0

run_step() { # name logfile cmd...   (sets STEP_RC, STEP_SECS)
  local name=$1 log=$2; shift 2
  local s e rc
  echo ">>> [$name] $*"
  s=$(date +%s)
  "$@" > "$log" 2>&1; rc=$?
  e=$(( $(date +%s) - s ))
  STEP_RC=$rc; STEP_SECS=$e
  if [ $rc -eq 0 ]; then echo "<<< [$name] ok (${e}s)"; else echo "<<< [$name] FAILED rc=$rc (${e}s), log: $log"; tail -n 15 "$log" | sed 's/^/    | /'; fi
}
nocolor() { sed 's/\x1b\[[0-9;]*m//g' "$@"; }

echo "gate-bluegenes: worktree=$WT mode=$MODE"
echo "gate-bluegenes: java=$(java -version 2>&1 | grep -v Picked | head -1) ($JAVA_HOME)"
echo "gate-bluegenes: node=$(node -v) npm=$(npm -v)"

# ---- npm ci (both modes) ----
npm_step() {
  local LOCKSUM STAMP=node_modules/.gate-lock-sha
  LOCKSUM=$(sha256sum package-lock.json package.json | sha256sum | cut -d' ' -f1)
  if [ -d node_modules ] && [ -f "$STAMP" ] && [ "$(cat $STAMP)" = "$LOCKSUM" ] && [ -x node_modules/.bin/lessc ]; then
    echo ">>> [npm] node_modules up to date, skipping npm ci"
    record npm SKIP "0s" "node_modules current for package-lock.json"
  else
    run_step npm "$LOGS/npm-ci.log" npm ci
    if [ $STEP_RC -eq 0 ]; then
      echo "$LOCKSUM" > "$STAMP"
      record npm PASS "${STEP_SECS}s" "npm ci (CYPRESS_INSTALL_BINARY=${CYPRESS_INSTALL_BINARY:-<unset>})"
    else
      record npm FAIL "${STEP_SECS}s" "see .gate-logs/npm-ci.log"; FAILED=1
    fi
  fi
  if [ $AUDIT -eq 1 ] && [ -d node_modules ]; then
    npm audit --json > "$LOGS/npm-audit.json" 2>/dev/null
    local AUD
    AUD=$(node -e 'try{const m=require(process.argv[1]).metadata.vulnerabilities;console.log(`critical=${m.critical} high=${m.high} moderate=${m.moderate} low=${m.low} total=${m.total}`)}catch(e){console.log("unavailable")}' "$LOGS/npm-audit.json")
    record npm-audit INFO "-" "$AUD"
  fi
}

# Start `java <args>` from a temp dir (the server writes ./tools into its cwd),
# wait for :$PORT, fetch the page and the assets it references, then stop it.
# smoke <step-name> <java-binary> <expected-hash or ""> <java args...>
smoke() {
  local name=$1 javabin=$2 want=$3; shift 3
  local dir s pid html js css imcss ver c_root c_ver c_tools c_js c_css c_imcss up=0 prob=""
  dir=$(mktemp -d); s=$(date +%s)
  ( cd "$dir" && SERVER_PORT=$PORT \
      BLUEGENES_DEFAULT_SERVICE_ROOT=${BLUEGENES_DEFAULT_SERVICE_ROOT:-https://www.flymine.org/flymine} \
      exec "$javabin" "$@" ) > "$LOGS/$name-server.log" 2>&1 &
  pid=$!
  # /version answers without calling out; / fetches the default mine's semantic
  # markup first (3 s timeout in bluegenes.index), so give it longer below.
  for _ in $(seq 1 120); do
    curl -s -o /dev/null -m 2 "http://localhost:$PORT/version" && { up=1; break; }
    kill -0 $pid 2>/dev/null || break; sleep 1
  done
  local startup=$(( $(date +%s) - s ))
  html=$(curl -s -m 30 "http://localhost:$PORT/")
  js=$(echo "$html" | grep -oE '/js/compiled/app[^"]*\.js' | head -1)
  css=$(echo "$html" | grep -oE '/css/site[^"]*\.css' | head -1)
  imcss=$(echo "$html" | grep -oE '/css/im-tables[^"]*\.css' | head -1)
  ver=$(echo "$html" | grep -oE ':version \\"[^\\]*' | sed 's/.*"//')
  c_root=$(curl -s -o /dev/null -m 30 -w '%{http_code}' "http://localhost:$PORT/")
  c_ver=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "http://localhost:$PORT/version")
  c_tools=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "http://localhost:$PORT/api/tools/all")
  c_js=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "http://localhost:$PORT$js")
  c_css=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "http://localhost:$PORT$css")
  c_imcss=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "http://localhost:$PORT$imcss")
  kill $pid 2>/dev/null; sleep 1; kill -9 $pid 2>/dev/null; wait $pid 2>/dev/null; rm -rf "$dir"
  [ $up -eq 1 ] || prob="$prob server did not come up;"
  for c in "$c_root" "$c_ver" "$c_tools" "$c_js" "$c_css" "$c_imcss"; do [ "$c" = 200 ] || { prob="$prob http $c_root/$c_ver/$c_tools/$c_js/$c_css/$c_imcss;"; break; }; done
  if [ -n "$want" ]; then
    [ "$js" = "/js/compiled/app.$want.js" ] || prob="$prob page js '$js' != app.$want.js;"
    [ "$css" = "/css/site-$want.css" ] || prob="$prob page css '$css' != site-$want.css;"
    [ "$imcss" = "/css/im-tables-$want.css" ] || prob="$prob page css '$imcss' != im-tables-$want.css;"
    [ "$ver" = "$want" ] || prob="$prob serverVars version '$ver' != $want;"
  fi
  if [ -z "$prob" ]; then
    record "$name" PASS "${startup}s" "up in ${startup}s; / /version /api/tools/all $js $css $imcss all 200; serverVars version=$ver"
  else
    record "$name" FAIL "${startup}s" "$prob see .gate-logs/$name-server.log"; FAILED=1
  fi
}

# =====================================================================
deps_mode() {
  echo "gate-bluegenes: clojure=$($CLJ --version 2>&1 | grep -v Picked | head -1)"

  # ---- 1. fmt ----
  run_step fmt "$LOGS/fmt.log" "$CLJ" -M:fmt check
  if [ $STEP_RC -eq 0 ]; then record fmt PASS "${STEP_SECS}s" "cljfmt (clojure -M:fmt check)"; else record fmt FAIL "${STEP_SECS}s" "see .gate-logs/fmt.log"; FAILED=1; fi

  # ---- 2. npm ----
  npm_step
  if [ ! -x node_modules/.bin/shadow-cljs ]; then
    record test FAIL "-" "node_modules/.bin/shadow-cljs missing (npm step failed?)"; FAILED=1
    return
  fi

  # ---- 3. unit tests (:node-test) ----
  rm -f target/test/node-tests.js
  run_step test "$LOGS/test.log" bash -c 'npx shadow-cljs compile test && node target/test/node-tests.js'
  local SUMMARY COUNTS
  SUMMARY=$(nocolor "$LOGS/test.log" | grep -E '^Ran [0-9]+ tests containing [0-9]+ assertions' | tail -1)
  COUNTS=$(nocolor "$LOGS/test.log" | grep -E '^[0-9]+ failures, [0-9]+ errors' | tail -1)
  if [ $STEP_RC -eq 0 ] && [ -n "$SUMMARY" ] && echo "$COUNTS" | grep -q '^0 failures, 0 errors'; then
    record test PASS "${STEP_SECS}s" "$SUMMARY $COUNTS"
  else
    record test FAIL "${STEP_SECS}s" "${SUMMARY:-no cljs.test summary} ${COUNTS:-}; see .gate-logs/test.log"; FAILED=1
  fi

  # ---- 3b. server-side Clojure tests (:test-clj alias, added by im-7os.30) ----
  if grep -q ':test-clj' deps.edn 2>/dev/null; then
    run_step test-clj "$LOGS/test-clj.log" "$CLJ" -M:test-clj
    local CSUMMARY CCOUNTS
    CSUMMARY=$(nocolor "$LOGS/test-clj.log" | grep -E '^Ran [0-9]+ tests containing [0-9]+ assertions' | tail -1)
    CCOUNTS=$(nocolor "$LOGS/test-clj.log" | grep -E '^[0-9]+ failures, [0-9]+ errors' | tail -1)
    if [ $STEP_RC -eq 0 ] && [ -n "$CSUMMARY" ] && echo "$CCOUNTS" | grep -q '^0 failures, 0 errors'; then
      record test-clj PASS "${STEP_SECS}s" "$CSUMMARY $CCOUNTS"
    else
      record test-clj FAIL "${STEP_SECS}s" "${CSUMMARY:-no clojure.test summary} ${CCOUNTS:-}; see .gate-logs/test-clj.log"; FAILED=1
    fi
  fi

  # ---- 4. dev build of :app ----
  run_step app-dev "$LOGS/app-dev.log" npx shadow-cljs compile app
  nocolor "$LOGS/app-dev.log" | grep -A2 -E '^-+ WARNING' | grep -E 'WARNING|Resource:|File:' > "$LOGS/app-dev-warnings.txt"
  local BUILT NWARN
  BUILT=$(nocolor "$LOGS/app-dev.log" | grep -E '^\[:app\] Build completed' | tail -1)
  NWARN=$(nocolor "$LOGS/app-dev.log" | grep -cE '^-+ WARNING')
  if [ $STEP_RC -eq 0 ] && [ -n "$BUILT" ]; then
    record app-dev PASS "${STEP_SECS}s" "$BUILT; $NWARN warnings (.gate-logs/app-dev-warnings.txt)"
  else
    record app-dev FAIL "${STEP_SECS}s" "see .gate-logs/app-dev.log"; FAILED=1
  fi

  # ---- 4b. removed Closure Library predicates in the dev build (im-7os.37) ----
  # goog.isBoolean/isNumber/isString/isFunction/isArray/isDef/... were dropped from the Closure
  # Library that ClojureScript 1.11 ships; a library calling them (oops 0.7.0 did) breaks the dev
  # build at run time, after load, where app-load cannot see it. No exceptions: bluegenes pins
  # transit-js 0.8.874, which no longer calls them (im-7os.58).
  if [ -d resources/public/js/compiled/cljs-runtime ]; then
    grep -rlE 'goog\.is(Boolean|Number|String|Function|Array|Def|DefAndNotNull|Null)\b' resources/public/js/compiled/cljs-runtime 2>/dev/null \
      > "$LOGS/closure-preds.txt" || true
    if [ ! -s "$LOGS/closure-preds.txt" ]; then
      record closure-preds PASS "0s" "no removed goog.is* predicates in the dev build"
    else
      record closure-preds FAIL "0s" "$(wc -l < "$LOGS/closure-preds.txt") files call removed goog.is* predicates; see .gate-logs/closure-preds.txt"; FAILED=1
    fi
  fi

  rm -rf target/bundle-dev
  run_step app-load "$LOGS/app-load.log" bash -c "npx shadow-cljs compile app --config-merge '{:output-dir \"target/bundle-dev\" :devtools {:loader-mode :eval}}' && node '$HERE/bluegenes-runbundle.js' --allow-fail=day8.re_frame_10x.preload.react_18.js target/bundle-dev/app.js"
  if [ $STEP_RC -eq 0 ]; then record app-load PASS "${STEP_SECS}s" "$(grep -E '^LOADED OK' "$LOGS/app-load.log" | sed 's/ (.*bytes)//')"
  else record app-load FAIL "${STEP_SECS}s" "$(grep -E '^LOAD' "$LOGS/app-load.log" | cut -c1-200) (see .gate-logs/app-load.log)"; FAILED=1; fi

  [ $WITH_PROD -eq 1 ] || return

  # ---- 5. prod: uberjar ----
  run_step uber "$LOGS/uber.log" "$CLJ" -T:build uber
  nocolor "$LOGS/uber.log" | grep -iE 'WARNING|deprecat' | grep -v '^Picked' | sort | uniq -c | sort -rn | head -50 > "$LOGS/warnings.txt"
  record warnings INFO "-" "$(wc -l < "$LOGS/warnings.txt") distinct warning lines in uber.log (.gate-logs/warnings.txt)"
  if [ $STEP_RC -ne 0 ] || [ ! -f target/bluegenes.jar ]; then
    record uber FAIL "${STEP_SECS}s" "see .gate-logs/uber.log"; FAILED=1
    return
  fi
  local HASH
  HASH=$(grep -oE ':output-name "app\.[^"]*\.js"' resources/public/js/compiled/manifest.edn | sed -E 's/.*app\.(.*)\.js"/\1/')
  record uber PASS "${STEP_SECS}s" "target/bluegenes.jar $(du -h target/bluegenes.jar | cut -f1) ($(stat -c %s target/bluegenes.jar) bytes), hash $HASH"

  run_step bundle-load "$LOGS/bundle-load.log" node "$HERE/bluegenes-runbundle.js" "resources/public/js/compiled/app.$HASH.js"
  if [ $STEP_RC -eq 0 ]; then record bundle-load PASS "${STEP_SECS}s" "$(grep -E '^LOADED OK' "$LOGS/bundle-load.log" | sed 's/ (.*bytes)//; s|resources/public/js/compiled/||')"
  else record bundle-load FAIL "${STEP_SECS}s" "$(grep -E '^LOAD' "$LOGS/bundle-load.log" | cut -c1-200)"; FAILED=1; fi

  local LIST PROB=""
  LIST=$(unzip -Z1 target/bluegenes.jar)
  echo "$LIST" | grep -qx 'org/eclipse/jetty/util/Attributes.class' || PROB="$PROB no jetty-util classes;"
  echo "$LIST" | grep -qx 'bluegenes/core.class' || PROB="$PROB no bluegenes/core.class;"
  echo "$LIST" | grep -qx 'public/js/compiled/manifest.edn' || PROB="$PROB no manifest.edn;"
  echo "$LIST" | grep -qx "public/js/compiled/app.$HASH.js" || PROB="$PROB no app.$HASH.js;"
  echo "$LIST" | grep -qx "public/css/site-$HASH.css" || PROB="$PROB no site-$HASH.css;"
  echo "$LIST" | grep -qx "public/css/im-tables-$HASH.css" || PROB="$PROB no im-tables-$HASH.css;"
  echo "$LIST" | grep -qx 'config.edn' || PROB="$PROB no config.edn;"
  if [ -z "$PROB" ]; then record jar-check PASS "-" "jetty, bluegenes/core.class, manifest, app.$HASH.js, site/im-tables-$HASH.css, config.edn"
  else record jar-check FAIL "-" "$PROB"; FAILED=1; fi

  local J JB OLDEST=""
  for J in ${GATE_SMOKE_JDKS:-21 17}; do
    JB=/usr/lib/jvm/java-$J-openjdk-arm64/bin/java
    if [ ! -x "$JB" ]; then record smoke-$J FAIL "-" "no JDK $J at $JB"; FAILED=1; continue; fi
    smoke smoke-$J "$JB" "$HASH" -jar "$WT/target/bluegenes.jar"
    if [ -z "$OLDEST" ] || [ "$J" -lt "$OLDEST" ]; then OLDEST=$J; fi
  done

  # ---- 5b. prod: Clojars-style library jar ----
  run_step libjar "$LOGS/libjar.log" "$CLJ" -T:build install
  local VERSION LJAR POM
  VERSION=$(sed -n 's/^(def version "\([^"]*\)").*/\1/p' build.clj)
  LJAR=target/bluegenes-$VERSION.jar
  if [ $STEP_RC -ne 0 ] || [ ! -f "$LJAR" ]; then
    record libjar FAIL "${STEP_SECS}s" "see .gate-logs/libjar.log"; FAILED=1
    return
  fi
  HASH=$(grep -oE ':output-name "app\.[^"]*\.js"' resources/public/js/compiled/manifest.edn | sed -E 's/.*app\.(.*)\.js"/\1/')
  PROB=""
  LIST=$(unzip -Z1 "$LJAR")
  echo "$LIST" | grep -qx 'bluegenes/core.class' || PROB="$PROB no bluegenes/core.class;"
  echo "$LIST" | grep -qx 'bluegenes/routes.clj' || PROB="$PROB no server sources;"
  echo "$LIST" | grep -qx "public/js/compiled/app.$HASH.js" || PROB="$PROB no app.$HASH.js;"
  echo "$LIST" | grep -qx 'public/js/compiled/manifest.edn' || PROB="$PROB no manifest.edn;"
  echo "$LIST" | grep -qx "public/css/site-$HASH.css" || PROB="$PROB no site-$HASH.css;"
  echo "$LIST" | grep -qE '^(org|clojure|ring|compojure|bluegenes_tool_store)/' && PROB="$PROB dependency classes in library jar;"
  POM=$(unzip -p "$LJAR" 'META-INF/maven/org.intermine/bluegenes/pom.xml' 2>/dev/null)
  echo "$POM" | grep -q '<groupId>org.intermine</groupId>' || PROB="$PROB pom groupId;"
  echo "$POM" | grep -q '<artifactId>bluegenes</artifactId>' || PROB="$PROB pom artifactId;"
  echo "$POM" | grep -q "<version>$VERSION</version>" || PROB="$PROB pom version != $VERSION;"
  echo "$POM" | grep -qE '<artifactId>(clojurescript|shadow-cljs|re-frame|reagent|im-tables)</artifactId>' && PROB="$PROB pom lists front-end deps;"
  local M2=$HOME/.m2/repository/org/intermine/bluegenes/$VERSION
  [ -f "$M2/bluegenes-$VERSION.jar" ] && [ -f "$M2/bluegenes-$VERSION.pom" ] || PROB="$PROB not installed in $M2;"
  if [ -n "$PROB" ]; then record libjar FAIL "${STEP_SECS}s" "$PROB"; FAILED=1; return; fi
  record libjar PASS "${STEP_SECS}s" "$LJAR $(du -h "$LJAR" | cut -f1), $(echo "$POM" | grep -c '<dependency>') pom deps, installed org.intermine/bluegenes $VERSION"

  local CONS CP
  CONS=$(mktemp -d)
  echo "{:deps {org.intermine/bluegenes {:mvn/version \"$VERSION\"}}}" > "$CONS/deps.edn"
  CP=$( cd "$CONS" && "$CLJ" -Spath 2>>"$LOGS/libjar.log" | tr ':' '\n' | grep '\.jar$' | paste -sd: )
  local NJARS
  NJARS=$(echo "$CP" | tr ':' '\n' | grep -c .)
  rm -rf "$CONS"
  if [ -z "$CP" ]; then record libjar-run FAIL "-" "could not resolve the installed jar (see .gate-logs/libjar.log)"; FAILED=1; return; fi
  smoke libjar-run-${OLDEST:-17} "/usr/lib/jvm/java-${OLDEST:-17}-openjdk-arm64/bin/java" "$HASH" -cp "$CP" bluegenes.core
  NOTES[${#NOTES[@]}-1]="java -cp <$NJARS jars> bluegenes.core: ${NOTES[${#NOTES[@]}-1]}"
}

# =====================================================================
lein_mode() {
  if [ -n "${GATE_LEIN:-}" ]; then LEIN=$GATE_LEIN
  elif [ -x /home/agent/tools/lein/lein ]; then LEIN=/home/agent/tools/lein/lein; export LEIN_HOME=${LEIN_HOME:-/home/agent/tools/lein/home}
  else LEIN=$(command -v lein || true); fi
  [ -n "$LEIN" ] && [ -x "$LEIN" ] || { echo "lein not found (set GATE_LEIN)" >&2; exit 2; }
  LEIN_WARN=""
  if [ "$LEIN" = /usr/bin/lein ] || grep -q 'dh-clojure' "$LEIN" 2>/dev/null; then
    LEIN_WARN="Debian-packaged lein in use: resolver drops transitive deps (jetty), prod/uberjar will likely fail"
    echo "WARNING: $LEIN_WARN" >&2
  fi
  echo "gate-bluegenes: lein=$LEIN ($("$LEIN" version 2>&1 | grep -v Picked | head -1))"

  # ---- 1. cljfmt ----
  run_step cljfmt "$LOGS/cljfmt.log" "$LEIN" cljfmt check
  if [ $STEP_RC -eq 0 ]; then record cljfmt PASS "${STEP_SECS}s" ""; else record cljfmt FAIL "${STEP_SECS}s" "see .gate-logs/cljfmt.log"; FAILED=1; fi

  # ---- 2. npm ci ----
  npm_step

  # ---- 3. kaocha ----
  find_browser() {
    local c p
    [ "${GATE_BROWSER:-}" = none ] && return 1   # force the no-browser path (for testing the gate)
    if [ -n "${GATE_BROWSER:-}" ]; then
      "$GATE_BROWSER" --version >/dev/null 2>&1 && { echo "$GATE_BROWSER"; return 0; }
    fi
    for c in google-chrome-stable google-chrome chromium chromium-browser; do
      if p=$(command -v $c) && "$p" --version >/dev/null 2>&1; then echo "$p"; return 0; fi
    done
    c=/home/agent/browser-scratch/chromium-arm64/chromium
    [ -x "$c" ] && "$c" --version >/dev/null 2>&1 && { echo "$c"; return 0; }
    return 1
  }
  BROWSER=$(find_browser 2>/dev/null) || BROWSER=""
  if [ -z "$BROWSER" ]; then
    echo ">>> [kaocha] no usable headless browser found"
    if [ $ALLOW_NO_BROWSER -eq 1 ]; then
      record kaocha SKIP "0s" "no browser; allowed by --allow-no-browser"
    else
      record kaocha FAIL "0s" "no usable browser (use GATE_BROWSER=/path/to/chrome or --allow-no-browser)"; FAILED=1
    fi
  else
    echo ">>> [kaocha] browser: $BROWSER ($("$BROWSER" --version 2>&1 | head -1))"
    local BDIR LIBS KRC KS SUMMARY
    BDIR=$(dirname "$BROWSER")
    LIBS=${GATE_BROWSER_LIBS:-}
    [ -z "$LIBS" ] && [ -d "$BDIR/al2023/lib" ] && LIBS=$BDIR/al2023/lib
    SHIM=$(mktemp -d)
    cat > "$SHIM/xdg-open" <<SH
#!/bin/sh
# shim installed by gate-bluegenes.sh: open URL in headless browser instead of host desktop
echo "\$(date +%T) open \$1" >> "$LOGS/browser.log"
LD_LIBRARY_PATH="$LIBS\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}" nohup "$BROWSER" --headless --no-sandbox --disable-dev-shm-usage --disable-gpu --no-proxy-server --no-first-run --user-data-dir="$LOGS/browser-profile-\$\$" "\$1" >> "$LOGS/browser.log" 2>&1 &
SH
    chmod +x "$SHIM/xdg-open"
    : > "$LOGS/browser.log"
    PATH="$SHIM:$PATH" run_step kaocha "$LOGS/kaocha.log" timeout 1800 "$LEIN" kaocha
    KRC=$STEP_RC; KS=$STEP_SECS
    pkill -f "$LOGS/browser-profile" 2>/dev/null; rm -rf "$LOGS"/browser-profile-* 2>/dev/null
    SUMMARY=$(nocolor "$LOGS/kaocha.log" | grep -E '^[0-9]+ tests, [0-9]+ assertions' | tail -1)
    if [ $KRC -eq 0 ]; then record kaocha PASS "${KS}s" "$SUMMARY"; else record kaocha FAIL "${KS}s" "${SUMMARY:-see .gate-logs/kaocha.log}"; FAILED=1; fi
  fi

  # ---- 4. prod ----
  if [ $WITH_PROD -eq 1 ]; then
    if [ ! -x node_modules/.bin/lessc ]; then
      record prod FAIL "0s" "node_modules/.bin/lessc missing (npm step failed)"; FAILED=1
    else
      run_step uberjar "$LOGS/uberjar.log" "$LEIN" uberjar
      if [ $STEP_RC -eq 0 ] && [ -f target/bluegenes.jar ]; then
        record uberjar PASS "${STEP_SECS}s" "target/bluegenes.jar $(du -h target/bluegenes.jar | cut -f1)"
        if ! unzip -l target/bluegenes.jar | grep -q 'org/eclipse/jetty/util/Attributes.class'; then
          record jar-check FAIL "-" "jetty-util classes missing from jar (broken dependency resolution?) ${LEIN_WARN}"; FAILED=1
        else
          record jar-check PASS "-" "jetty classes present"
          smoke smoke "$JAVA_HOME/bin/java" "" -jar "$WT/target/bluegenes.jar"
        fi
      else
        record uberjar FAIL "${STEP_SECS}s" "see .gate-logs/uberjar.log"; FAILED=1
      fi
      grep -i -E 'WARNING|deprecat' "$LOGS/uberjar.log" 2>/dev/null | grep -v '^Picked' | sort | uniq -c | sort -rn | head -50 > "$LOGS/warnings.txt"
      record warnings INFO "-" "$(wc -l < "$LOGS/warnings.txt") distinct warning lines in uberjar.log (.gate-logs/warnings.txt)"
    fi
  fi
}

SHIM=""
cleanup() {
  pkill -f "$LOGS/browser-profile" 2>/dev/null
  [ -n "$SHIM" ] && rm -rf "$SHIM"
}
trap cleanup EXIT

if [ "$MODE" = deps ]; then deps_mode; else lein_mode; fi

# ---- summary ----
echo
echo "================ gate-bluegenes summary ($WT, $MODE mode) ================"
printf '%-14s %-6s %-8s %s\n' STEP RESULT TIME NOTES
for i in "${!NAMES[@]}"; do printf '%-14s %-6s %-8s %s\n' "${NAMES[$i]}" "${RESULTS[$i]}" "${TIMES[$i]}" "${NOTES[$i]}"; done
echo "logs: $LOGS"
if [ $FAILED -eq 0 ]; then echo "GATE RESULT: PASS ($MODE mode)"; exit 0; else echo "GATE RESULT: FAIL ($MODE mode)"; exit 1; fi
