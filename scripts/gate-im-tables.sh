#!/usr/bin/env bash
# gate-im-tables.sh - quality gate for an im-tables-3 worktree (dual mode: lein and/or deps.edn).
#
# Usage:
#   gate-im-tables.sh <worktree-path> [--allow-no-browser] [--skip-npm-audit]
#
# Steps (each timed, each logged to <worktree>/.gate-logs/<step>.log). A step that needs a
# file the worktree does not have yet (deps.edn, project.clj) is SKIPPED, so the same script
# gates the old lein tree, the dual-mode tree and a lein-less tree.
#
#   Leiningen mode (only if project.clj exists; upstream lein, see below)
#     lein-fmt     : lein cljfmt check
#     lein-kaocha  : lein kaocha (the 3 unit tests in headless Chromium through an xdg-open
#                    shim, as gate-bluegenes.sh does). They query the LIVE FlyMine
#                    (https://www.flymine.org/flymine, read-only).
#     lein-jar     : lein with-profile +build jar (runs the :build prep task: lessc, advanced
#                    cljsbuild); the jar must contain public/css/im-tables.css
#   deps.edn mode (only if deps.edn exists)
#     depcheck     : runtime coordinates and versions in deps.edn :deps equal project.clj
#                    :dependencies minus clojure, clojurescript and cljsjs/*; the test
#                    dependency agrees; project.clj version equals VERSION
#                    (scripts/gate-im-tables-depcheck.clj)
#     fmt          : clojure -M:fmt check
#     npm          : npm ci
#     shadow-test  : npx shadow-cljs compile test && node out/test.js (:node-test build; the
#                    same 3 live-FlyMine tests; a missing "Ran N tests" summary or any
#                    failure/error is a gate failure)
#     shadow-app   : npx shadow-cljs release app (advanced compile of the whole library plus
#                    the demo page: proves every npm require resolves)
#     shim-browser : loads that advanced build in headless Chromium and checks that the
#                    cljsjs shims set their globals (Select, DayPicker.Input,
#                    ReactTransitionGroup.CSSTransitionGroup, hljs with 6 languages) and that
#                    im_tables.core.init runs without an uncaught exception (needs a browser;
#                    skipped with --allow-no-browser)
#     jar          : clojure -T:build jar, then checks the jar: pom coordinates, version is a
#                    SNAPSHOT, no clojure/clojurescript/cljsjs in the pom, sources present,
#                    NO shim/ or compiled js, and public/css/im-tables.css present and non-empty
#     install      : clojure -T:build install, then checks ~/.m2 has the jar+pom
#
# Nothing here needs a Biotestmine. The unit tests query the live FlyMine; a `flymine` INFO
# line at the top of the summary says whether it was reachable. If it was not, the unit-test
# steps fail: that is an environment problem, not a code problem; report it as a blocker.
#
# Environment overrides:
#   GATE_JAVA_HOME   default /usr/lib/jvm/java-11-openjdk-arm64
#   GATE_LEIN        lein executable, default /home/agent/tools/lein/lein
#                    (LEIN_HOME=/home/agent/tools/lein/home). The Debian lein drops
#                    transitive dependencies; do not use it.
#   GATE_CLOJURE     clojure CLI, default `clojure` on PATH
#   GATE_BROWSER     chrome/chromium for lein-kaocha (`none` forces the no-browser path);
#                    GATE_BROWSER_LIBS optional LD_LIBRARY_PATH for it. Discovery order as in
#                    gate-bluegenes.sh, ending with
#                    /home/agent/browser-scratch/chromium-arm64/chromium.
#
# Exit code: 0 = every executed step passed; 1 = at least one step failed; 2 = usage.
# Final line of output is a one-line machine-greppable summary: GATE RESULT: ...

set -u
usage() { awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd)

WT=""; AUDIT=1; ALLOW_NO_BROWSER=0
for a in "$@"; do
  case "$a" in
    --skip-npm-audit) AUDIT=0 ;;
    --allow-no-browser) ALLOW_NO_BROWSER=1 ;;
    -h|--help) usage ;;
    -*) echo "unknown option $a" >&2; usage ;;
    *) if [ -z "$WT" ]; then WT=$a; else echo "unexpected arg $a" >&2; usage; fi ;;
  esac
done
[ -n "$WT" ] || usage
[ -f "$WT/project.clj" ] || [ -f "$WT/deps.edn" ] || { echo "not an im-tables checkout: $WT" >&2; exit 2; }
WT=$(cd "$WT" && pwd)
cd "$WT" || exit 2

export JAVA_HOME=${GATE_JAVA_HOME:-/usr/lib/jvm/java-11-openjdk-arm64}
export PATH=$JAVA_HOME/bin:$PATH
if [ -n "${GATE_LEIN:-}" ]; then LEIN=$GATE_LEIN
elif [ -x /home/agent/tools/lein/lein ]; then LEIN=/home/agent/tools/lein/lein; export LEIN_HOME=${LEIN_HOME:-/home/agent/tools/lein/home}
else LEIN=$(command -v lein || true); fi
CLJ=${GATE_CLOJURE:-clojure}

LOGS=$WT/.gate-logs
mkdir -p "$LOGS"
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
pass_fail() { # name note-on-pass  (uses STEP_RC / STEP_SECS)
  if [ $STEP_RC -eq 0 ]; then record "$1" PASS "${STEP_SECS}s" "${2:-}"; else record "$1" FAIL "${STEP_SECS}s" "see .gate-logs/$1.log"; FAILED=1; fi
}
fail() { record "$1" FAIL "-" "$2"; FAILED=1; }

echo "gate-im-tables: worktree=$WT"
echo "gate-im-tables: java=$(java -version 2>&1 | grep -v Picked | head -1)"
echo "gate-im-tables: node=$(node -v) npm=$(npm -v) clojure=$($CLJ --version 2>&1 | grep -v Picked | head -1)"

if [ -f VERSION ]; then VERSION=$(tr -d '[:space:]' < VERSION)
else VERSION=$(sed -n 's/^(defproject org.intermine\/im-tables "\([^"]*\)".*/\1/p' project.clj); fi
echo "gate-im-tables: version=$VERSION"

check_jar_css() { # jar -> echoes problems
  local jar=$1 sz
  sz=$(unzip -l "$jar" 2>/dev/null | awk '$4=="public/css/im-tables.css" {print $1}')
  if [ -z "$sz" ]; then echo " public/css/im-tables.css missing;"; elif [ "$sz" -lt 5000 ]; then echo " public/css/im-tables.css only $sz bytes;"; fi
}


# ---- headless browser (used by lein-kaocha and shim-browser) ----
find_browser() {
  local c
  [ "${GATE_BROWSER:-}" = none ] && return 1
  if [ -n "${GATE_BROWSER:-}" ]; then "$GATE_BROWSER" --version >/dev/null 2>&1 && { echo "$GATE_BROWSER"; return 0; }; fi
  for c in google-chrome-stable google-chrome chromium chromium-browser; do
    if p=$(command -v $c) && "$p" --version >/dev/null 2>&1; then echo "$p"; return 0; fi
  done
  c=/home/agent/browser-scratch/chromium-arm64/chromium
  [ -x "$c" ] && "$c" --version >/dev/null 2>&1 && { echo "$c"; return 0; }
  return 1
}
BROWSER=$(find_browser 2>/dev/null) || BROWSER=""
SHIM=""
cleanup() { pkill -f "$LOGS/browser-profile" 2>/dev/null; [ -n "$SHIM" ] && rm -rf "$SHIM"; }
trap cleanup EXIT
browser_env() { # sets LIBS
  local bdir; bdir=$(dirname "$BROWSER"); LIBS=${GATE_BROWSER_LIBS:-}
  [ -z "$LIBS" ] && [ -d "$bdir/al2023/lib" ] && LIBS=$bdir/al2023/lib
}

# ---- is the live FlyMine up? (informational; the unit tests need it) ----
FM_ROOT=${IM_TABLES_SERVICE_ROOT:-https://www.flymine.org/flymine}; FM=$(curl -s -m 15 -o /dev/null -w "%{http_code}" "$FM_ROOT/service/version" 2>/dev/null)
if [ "$FM" = 200 ]; then record flymine INFO "-" "$FM_ROOT reachable"; else record flymine INFO "-" "NOT reachable (http $FM): unit tests will fail for environmental reasons"; fi

# ---------------- Leiningen mode ----------------
if [ -f project.clj ]; then
  if [ -z "$LEIN" ] || [ ! -x "$LEIN" ]; then
    fail lein-fmt "lein not found (set GATE_LEIN)"
  else
    run_step lein-fmt "$LOGS/lein-fmt.log" "$LEIN" cljfmt check
    pass_fail lein-fmt

    # lein-kaocha needs node_modules for nothing, but `lein build` (below) needs lessc
    if [ ! -x node_modules/.bin/lessc ]; then run_step npm-lein "$LOGS/npm-lein.log" npm ci; pass_fail npm-lein "npm ci for lessc"; fi

    if [ -z "$BROWSER" ]; then
      if [ $ALLOW_NO_BROWSER -eq 1 ]; then record lein-kaocha SKIP "0s" "no browser; allowed by --allow-no-browser"
      else fail lein-kaocha "no usable browser (GATE_BROWSER=/path/to/chrome or --allow-no-browser)"; fi
    else
      browser_env
      SHIM=$(mktemp -d)
      cat > "$SHIM/xdg-open" <<SH
#!/bin/sh
# shim installed by gate-im-tables.sh: open URL in headless browser instead of host desktop
echo "\$(date +%T) open \$1" >> "$LOGS/browser.log"
LD_LIBRARY_PATH="$LIBS\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}" nohup "$BROWSER" --headless --no-sandbox --disable-dev-shm-usage --disable-gpu --no-proxy-server --no-first-run --user-data-dir="$LOGS/browser-profile-\$\$" "\$1" >> "$LOGS/browser.log" 2>&1 &
SH
      chmod +x "$SHIM/xdg-open"; : > "$LOGS/browser.log"
      PATH="$SHIM:$PATH" run_step lein-kaocha "$LOGS/lein-kaocha.log" timeout 1800 "$LEIN" kaocha
      KRC=$STEP_RC; KS=$STEP_SECS
      pkill -f "$LOGS/browser-profile" 2>/dev/null; rm -rf "$LOGS"/browser-profile-* 2>/dev/null
      SUMMARY=$(sed 's/\x1b\[[0-9;]*m//g' "$LOGS/lein-kaocha.log" | grep -E '^[0-9]+ tests, [0-9]+ assertions' | tail -1)
      if [ $KRC -eq 0 ] && [ -n "$SUMMARY" ]; then record lein-kaocha PASS "${KS}s" "$SUMMARY"; else record lein-kaocha FAIL "${KS}s" "${SUMMARY:-see .gate-logs/lein-kaocha.log}"; FAILED=1; fi
    fi

    rm -f target/im-tables-*.jar
    run_step lein-jar "$LOGS/lein-jar.log" "$LEIN" with-profile +build jar
    LJ=$(ls target/im-tables-*.jar 2>/dev/null | head -1)
    if [ $STEP_RC -eq 0 ] && [ -n "$LJ" ]; then
      PROB=$(check_jar_css "$LJ")
      if [ -z "$PROB" ]; then record lein-jar PASS "${STEP_SECS}s" "$LJ (with CSS)"; else record lein-jar FAIL "${STEP_SECS}s" "$PROB"; FAILED=1; fi
    else record lein-jar FAIL "${STEP_SECS}s" "see .gate-logs/lein-jar.log"; FAILED=1; fi
  fi
else
  record lein SKIP "-" "no project.clj"
fi

# ---------------- deps.edn mode ----------------
if [ -f deps.edn ]; then
  if [ -f project.clj ]; then
    run_step depcheck "$LOGS/depcheck.log" "$CLJ" -M "$HERE/gate-im-tables-depcheck.clj" "$WT"
    pass_fail depcheck "$(tail -n 1 "$LOGS/depcheck.log")"
  fi

  if grep -q ':fmt' deps.edn; then
    run_step fmt "$LOGS/fmt.log" "$CLJ" -M:fmt check
    pass_fail fmt "cljfmt via deps.edn alias"
  else record fmt SKIP "-" "no :fmt alias"; fi

  if [ -f package.json ]; then
    run_step npm "$LOGS/npm.log" npm ci
    pass_fail npm
    if [ $AUDIT -eq 1 ] && [ -d node_modules ]; then
      npm audit --json > "$LOGS/npm-audit.json" 2>/dev/null
      AUD=$(node -e 'try{const m=require(process.argv[1]).metadata.vulnerabilities;console.log(`critical=${m.critical} high=${m.high} moderate=${m.moderate} low=${m.low} total=${m.total}`)}catch(e){console.log("unavailable")}' "$LOGS/npm-audit.json")
      record npm-audit INFO "-" "$AUD"
    fi
  fi

  if [ -f shadow-cljs.edn ] && [ -d node_modules ]; then
    rm -f out/test.js
    run_step shadow-test "$LOGS/shadow-test.log" bash -c 'npx shadow-cljs compile test && node out/test.js'
    SUMMARY=$(grep -E '^Ran [0-9]+ tests containing [0-9]+ assertions' "$LOGS/shadow-test.log" | tail -1)
    COUNTS=$(grep -E '^[0-9]+ failures, [0-9]+ errors' "$LOGS/shadow-test.log" | tail -1)
    if [ $STEP_RC -eq 0 ] && [ -n "$SUMMARY" ] && echo "$COUNTS" | grep -q '^0 failures, 0 errors'; then
      record shadow-test PASS "${STEP_SECS}s" "$SUMMARY; $COUNTS"
    else
      record shadow-test FAIL "${STEP_SECS}s" "${SUMMARY:-no cljs.test summary}; ${COUNTS:-}; see .gate-logs/shadow-test.log"; FAILED=1
    fi
    if grep -q ':app' shadow-cljs.edn; then
      run_step shadow-app "$LOGS/shadow-app.log" npx shadow-cljs release app
      WARN=$(grep -ci 'warning' "$LOGS/shadow-app.log")
      pass_fail shadow-app "advanced build of the demo app ($WARN warning lines)"
      if [ $STEP_RC -eq 0 ]; then
        if [ -z "$BROWSER" ]; then
          if [ $ALLOW_NO_BROWSER -eq 1 ]; then record shim-browser SKIP "0s" "no browser; allowed by --allow-no-browser"
          else fail shim-browser "no usable browser (GATE_BROWSER=/path/to/chrome or --allow-no-browser)"; fi
        else
          browser_env
          CHECK=$LOGS/shim-check.html
          cat > "$CHECK" <<HTML
<!doctype html><html><body><div id="app"></div>
<script src="file://$WT/resources/public/js/compiled/app.js"></script>
<script>
var r = {};
try {
  // react-select 5 exports Select as a forwardRef object, not a function
  r.Select = (typeof Select === "function" || (typeof Select === "object" && Select !== null)) ? "component" : typeof Select;
  r.Creatable = (typeof Select.Creatable === "function" || typeof Select.Creatable === "object") ? "component" : typeof Select.Creatable;
  r.langs = hljs.listLanguages().join(",");
  var el = document.createElement("code"); el.className = "xml"; el.textContent = "<a b='c'>d</a>";
  document.body.appendChild(el); hljs.highlightBlock(el); r.highlighted = el.innerHTML.indexOf("hljs-") >= 0;
  im_tables.core.init(); r.init = "ok";
} catch (e) { r.error = String(e); }
console.log("SHIMCHECK " + JSON.stringify(r));
</script></body></html>
HTML
          s0=$(date +%s)
          LD_LIBRARY_PATH="$LIBS" timeout 25 "$BROWSER" --headless --no-sandbox --disable-gpu --disable-dev-shm-usage --allow-file-access-from-files --no-first-run --no-proxy-server --user-data-dir="$LOGS/browser-profile-shim" "file://$CHECK" > "$LOGS/shim-browser.log" 2>&1
          pkill -f "$LOGS/browser-profile" 2>/dev/null; rm -rf "$LOGS"/browser-profile-* 2>/dev/null
          RES=$(grep -o 'SHIMCHECK {.*}' "$LOGS/shim-browser.log" | head -1 | sed 's/", source.*//')
          UNCAUGHT=$(grep -c 'Uncaught' "$LOGS/shim-browser.log")
          WANT='"Select":"component","Creatable":"component","langs":"javascript,perl,python,ruby,java,xml","highlighted":true,"init":"ok"'
          if echo "$RES" | grep -qF "$WANT" && [ "$UNCAUGHT" = 0 ]; then record shim-browser PASS "$(( $(date +%s) - s0 ))s" "globals set, init ran, no uncaught errors"
          else record shim-browser FAIL "$(( $(date +%s) - s0 ))s" "${RES:-no SHIMCHECK line}; uncaught=$UNCAUGHT; see .gate-logs/shim-browser.log"; FAILED=1; fi
        fi
      fi
    fi
  else
    record shadow-test FAIL "-" "no shadow-cljs.edn or no node_modules (npm step failed?)"; FAILED=1
  fi

  if [ -f build.clj ]; then
    rm -rf target/classes target/im-tables-*.jar
    run_step jar "$LOGS/jar.log" "$CLJ" -T:build jar
    JAR=$(ls target/im-tables-*.jar 2>/dev/null | head -1)
    if [ $STEP_RC -ne 0 ] || [ -z "$JAR" ]; then
      record jar FAIL "${STEP_SECS}s" "see .gate-logs/jar.log"; FAILED=1
    else
      PROB=$(check_jar_css "$JAR")
      LIST=$(unzip -Z1 "$JAR")
      echo "$LIST" | grep -qx 'im_tables/core.cljs' || PROB="$PROB missing im_tables/core.cljs;"
      echo "$LIST" | grep -qE '^shim/|^cljsjs/|^public/js/|^public/index.html|\.nfs|_test\.clj|\.class$' && PROB="$PROB shims, compiled js, tests, classes or junk in jar;"
      POM=$(unzip -p "$JAR" 'META-INF/maven/org.intermine/im-tables/pom.xml' 2>/dev/null)
      echo "$POM" | grep -q '<groupId>org.intermine</groupId>' || PROB="$PROB pom groupId;"
      echo "$POM" | grep -q '<artifactId>im-tables</artifactId>' || PROB="$PROB pom artifactId;"
      echo "$POM" | grep -q "<version>$VERSION</version>" || PROB="$PROB pom version != $VERSION;"
      case "$VERSION" in *-SNAPSHOT) ;; *) PROB="$PROB version $VERSION is not a SNAPSHOT;" ;; esac
      echo "$POM" | grep -qE '<groupId>cljsjs</groupId>|<artifactId>(clojure|clojurescript)</artifactId>|<artifactId>test</artifactId>' && PROB="$PROB pom lists cljsjs/clojure/clojurescript/test deps;"
      if [ -z "$PROB" ]; then record jar PASS "${STEP_SECS}s" "$JAR ($(echo "$LIST" | grep -c '\.cljs$') cljs files, CSS $(unzip -l "$JAR" | awk '$4=="public/css/im-tables.css" {print $1}') bytes)"; else record jar FAIL "${STEP_SECS}s" "$PROB"; FAILED=1; fi
    fi
    run_step install "$LOGS/install.log" "$CLJ" -T:build install
    M2=${HOME}/.m2/repository/org/intermine/im-tables/$VERSION
    if [ $STEP_RC -eq 0 ] && [ -f "$M2/im-tables-$VERSION.jar" ] && [ -f "$M2/im-tables-$VERSION.pom" ]; then
      record install PASS "${STEP_SECS}s" "org.intermine/im-tables {:mvn/version \"$VERSION\"} in $M2"
    else
      record install FAIL "${STEP_SECS}s" "jar/pom not in $M2; see .gate-logs/install.log"; FAILED=1
    fi
  else
    record jar SKIP "-" "no build.clj"
  fi
else
  record deps.edn SKIP "-" "no deps.edn (lein-only tree)"
fi

# ---------------- summary ----------------
echo
echo "================ gate-im-tables summary ($WT) ================"
printf '%-12s %-6s %-8s %s\n' STEP RESULT TIME NOTES
for i in "${!NAMES[@]}"; do printf '%-12s %-6s %-8s %s\n' "${NAMES[$i]}" "${RESULTS[$i]}" "${TIMES[$i]}" "${NOTES[$i]}"; done
echo "logs: $LOGS"
if [ $FAILED -eq 0 ]; then echo "GATE RESULT: PASS"; exit 0; else echo "GATE RESULT: FAIL"; exit 1; fi
