#!/usr/bin/env bash
# gate-imcljs.sh - quality gate for an imcljs worktree (dual mode: lein and/or deps.edn).
#
# Usage:
#   gate-imcljs.sh <worktree-path> [--skip-npm-audit]
#
# Steps (each timed, each logged to <worktree>/.gate-logs/<step>.log). A step that
# needs a file the worktree does not have yet (deps.edn, project.clj) is SKIPPED, so
# the same script gates the old lein tree, the dual-mode tree and a lein-less tree.
#
#   Leiningen mode (only if project.clj exists; upstream lein, see below)
#     lein-fmt     : lein cljfmt check
#     lein-cljs    : lein cljsbuild once min   (advanced compile of src/cljc + src/cljs)
#     lein-jar     : lein jar                  (must create target/imcljs-<version>.jar)
#   deps.edn mode (only if deps.edn exists)
#     depcheck     : runtime dependency coordinates and versions in deps.edn :deps must
#                    equal project.clj :dependencies minus clojure/clojurescript, and the
#                    project.clj version must equal the VERSION file
#                    (scripts/gate-imcljs-depcheck.clj)
#     fmt          : clojure -M:fmt check      (if deps.edn has a :fmt alias)
#     npm          : npm ci                    (if package.json exists)
#     shadow-test  : npx shadow-cljs compile test && node out/test.js
#                    (:node-test build; OFFLINE tests only; a missing "Ran N tests"
#                    summary or any failure/error is a gate failure)
#     shadow-live  : npx shadow-cljs compile test-live (compile only, no run: the live
#                    suite needs a Biotestmine, see the usage in shadow-cljs.edn)
#     clj-load     : clojure -M -e (require every JVM-side namespace)
#     jar          : clojure -T:build jar      then checks the jar: coordinates in the
#                    pom, no test/ or compiled output in it, source namespaces present
#     install      : clojure -T:build install  then checks ~/.m2 contains the jar+pom
#
# The imcljs integration tests (all of test/cljs except utils_test, test/clj) need a
# live Biotestmine on localhost:9999 and are never run by the gate; the old
# `lein doo phantom test once` could not run in the sandbox either (no phantomjs, and
# the doo.runner namespace is not on the lein classpath).
#
# Environment overrides:
#   GATE_JAVA_HOME   default /usr/lib/jvm/java-11-openjdk-arm64
#   GATE_LEIN        lein executable, default /home/agent/tools/lein/lein
#                    (LEIN_HOME=/home/agent/tools/lein/home). The Debian lein drops
#                    transitive dependencies; do not use it.
#   GATE_CLOJURE     clojure CLI, default `clojure` on PATH
#
# Exit code: 0 = every executed step passed; 1 = at least one step failed; 2 = usage.
# Final line of output is a one-line machine-greppable summary: GATE RESULT: ...

set -u
usage() { awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd)

WT=""; AUDIT=1
for a in "$@"; do
  case "$a" in
    --skip-npm-audit) AUDIT=0 ;;
    -h|--help) usage ;;
    -*) echo "unknown option $a" >&2; usage ;;
    *) if [ -z "$WT" ]; then WT=$a; else echo "unexpected arg $a" >&2; usage; fi ;;
  esac
done
[ -n "$WT" ] || usage
[ -f "$WT/project.clj" ] || [ -f "$WT/deps.edn" ] || { echo "not an imcljs checkout: $WT" >&2; exit 2; }
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

echo "gate-imcljs: worktree=$WT"
echo "gate-imcljs: java=$(java -version 2>&1 | grep -v Picked | head -1)"
echo "gate-imcljs: node=$(node -v) npm=$(npm -v) clojure=$($CLJ --version 2>&1 | grep -v Picked | head -1)"

VERSION=""
if [ -f VERSION ]; then VERSION=$(tr -d '[:space:]' < VERSION)
elif [ -f project.clj ]; then VERSION=$(sed -n 's/^(defproject org.intermine\/imcljs "\([^"]*\)".*/\1/p' project.clj); fi
echo "gate-imcljs: version=$VERSION"

# ---------------- Leiningen mode ----------------
if [ -f project.clj ]; then
  if [ -z "$LEIN" ] || [ ! -x "$LEIN" ]; then
    fail lein-fmt "lein not found (set GATE_LEIN)"
  else
    run_step lein-fmt "$LOGS/lein-fmt.log" "$LEIN" cljfmt check
    pass_fail lein-fmt
    run_step lein-cljs "$LOGS/lein-cljs.log" "$LEIN" cljsbuild once min
    pass_fail lein-cljs "advanced build of the library"
    rm -f target/imcljs-*.jar
    run_step lein-jar "$LOGS/lein-jar.log" "$LEIN" jar
    if [ $STEP_RC -eq 0 ] && ls target/imcljs-*.jar > /dev/null 2>&1; then record lein-jar PASS "${STEP_SECS}s" "$(ls target/imcljs-*.jar | head -1)"
    else record lein-jar FAIL "${STEP_SECS}s" "see .gate-logs/lein-jar.log"; FAILED=1; fi
  fi
else
  record lein SKIP "-" "no project.clj"
fi

# ---------------- deps.edn mode ----------------
if [ -f deps.edn ]; then
  if [ -f project.clj ]; then
    run_step depcheck "$LOGS/depcheck.log" "$CLJ" -M "$HERE/gate-imcljs-depcheck.clj" "$WT"
    pass_fail depcheck "$(tail -n 1 "$LOGS/depcheck.log")"
  fi

  if grep -q ':fmt' deps.edn; then
    run_step fmt "$LOGS/fmt.log" "$CLJ" -M:fmt check
    pass_fail fmt "cljfmt via deps.edn alias"
  else
    record fmt SKIP "-" "no :fmt alias"
  fi

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
    if grep -q ':test-live' shadow-cljs.edn; then
      run_step shadow-live "$LOGS/shadow-live.log" npx shadow-cljs compile test-live
      pass_fail shadow-live "compiled only (needs live mine to run)"
    fi
  else
    record shadow-test FAIL "-" "no shadow-cljs.edn or no node_modules (npm step failed?)"; FAILED=1
  fi

  run_step clj-load "$LOGS/clj-load.log" "$CLJ" -M -e "(doseq [n '[imcljs.fetch imcljs.save imcljs.auth imcljs.path imcljs.query imcljs.entity imcljs.send imcljs.internal.io imcljs.internal.utils imcljs.internal.defaults]] (require n)) (println \"loaded JVM namespaces\")"
  pass_fail clj-load "all JVM namespaces load"

  if [ -f build.clj ]; then
    rm -rf target/classes target/imcljs-*.jar
    run_step jar "$LOGS/jar.log" "$CLJ" -T:build jar
    JAR=$(ls target/imcljs-*.jar 2>/dev/null | head -1)
    if [ $STEP_RC -ne 0 ] || [ -z "$JAR" ]; then
      record jar FAIL "${STEP_SECS}s" "see .gate-logs/jar.log"; FAILED=1
    else
      PROB=""
      LIST=$(unzip -Z1 "$JAR")
      echo "$LIST" | grep -qx 'imcljs/fetch.cljc' || PROB="$PROB missing imcljs/fetch.cljc;"
      echo "$LIST" | grep -qx 'imcljs/internal/io.clj' || PROB="$PROB missing imcljs/internal/io.clj;"
      echo "$LIST" | grep -qx 'imcljs/internal/io.cljs' || PROB="$PROB missing imcljs/internal/io.cljs;"
      echo "$LIST" | grep -qE '_test\.clj|runner\.cljs|^public/|\.class$' && PROB="$PROB tests, assets or classes in jar;"
      POM=$(unzip -p "$JAR" 'META-INF/maven/org.intermine/imcljs/pom.xml' 2>/dev/null)
      echo "$POM" | grep -q '<groupId>org.intermine</groupId>' || PROB="$PROB pom groupId;"
      echo "$POM" | grep -q '<artifactId>imcljs</artifactId>' || PROB="$PROB pom artifactId;"
      echo "$POM" | grep -q "<version>$VERSION</version>" || PROB="$PROB pom version != $VERSION;"
      case "$VERSION" in *-SNAPSHOT) ;; *) PROB="$PROB version $VERSION is not a SNAPSHOT;" ;; esac
      echo "$POM" | grep -qE '<artifactId>(loom|core.unify|clojure|clojurescript)</artifactId>' && PROB="$PROB pom lists clojure/clojurescript/loom/unify;"
      if [ -z "$PROB" ]; then record jar PASS "${STEP_SECS}s" "$JAR ($(echo "$LIST" | grep -c '\.clj')) source files"; else record jar FAIL "${STEP_SECS}s" "$PROB"; FAILED=1; fi
    fi
    run_step install "$LOGS/install.log" "$CLJ" -T:build install
    M2=${HOME}/.m2/repository/org/intermine/imcljs/$VERSION
    if [ $STEP_RC -eq 0 ] && [ -f "$M2/imcljs-$VERSION.jar" ] && [ -f "$M2/imcljs-$VERSION.pom" ]; then
      record install PASS "${STEP_SECS}s" "org.intermine/imcljs {:mvn/version \"$VERSION\"} in $M2"
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
echo "================ gate-imcljs summary ($WT) ================"
printf '%-12s %-6s %-8s %s\n' STEP RESULT TIME NOTES
for i in "${!NAMES[@]}"; do printf '%-12s %-6s %-8s %s\n' "${NAMES[$i]}" "${RESULTS[$i]}" "${TIMES[$i]}" "${NOTES[$i]}"; done
echo "logs: $LOGS"
if [ $FAILED -eq 0 ]; then echo "GATE RESULT: PASS"; exit 0; else echo "GATE RESULT: FAIL"; exit 1; fi
