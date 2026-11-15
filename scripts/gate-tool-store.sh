#!/usr/bin/env bash
# gate-tool-store.sh - quality gate for a bluegenes-tool-store worktree.
#
# Usage:
#   gate-tool-store.sh <worktree-path> [--skip-install] [--skip-smoke]
#
# The gate is dual-mode: each step runs only if the files it needs exist, so
# it works on the original lein tree, the dual-mode tree and a deps.edn-only tree.
# Steps (each timed, each logged to <worktree>/.gate-logs/<step>.log):
#   1. lein-test : "$LEIN" test                 (only if project.clj exists)
#   2. cli-test  : clojure -M:test              (only if deps.edn exists; cognitect test-runner)
#   3. jar       : clojure -T:build jar         (only if build.clj exists). Checks that the jar holds
#                  the four source namespaces and config.edn, no .class files (no AOT), the pom has
#                  groupId org.intermine / artifactId bluegenes-tool-store and a -SNAPSHOT version.
#   4. install   : clojure -T:build install     (skipped with --skip-install). Checks the jar and pom
#                  exist under ~/.m2/repository/org/intermine/bluegenes-tool-store/<version>/.
#   5. smoke     : clojure -M -m bluegenes-tool-store.core on $GATE_PORT (default 5056) with a scratch
#                  config file (-Dconfig) pointing at a tools dir that already has a tools.edn, so no npm install is
#                  attempted. curls /api/tools/path and /api/tools/all (expects 200), then stops it.
#                  (only if deps.edn exists; skipped with --skip-smoke)
#
# Environment overrides:
#   GATE_JAVA_HOME  default /usr/lib/jvm/java-11-openjdk-arm64
#   GATE_LEIN       lein executable. Default /home/agent/tools/lein/lein (upstream; the Debian
#                   /usr/bin/lein silently drops transitive deps), LEIN_HOME=/home/agent/tools/lein/home
#   GATE_PORT       smoke-test port (default 5056)
#
# Exit code: 0 = every executed step passed; 1 = at least one step failed; 2 = usage error.
# Final line of output is a one-line machine-greppable summary: GATE RESULT: ...

set -u
usage() { awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"; exit 2; }

WT=""; SKIP_INSTALL=0; SKIP_SMOKE=0
for a in "$@"; do
  case "$a" in
    --skip-install) SKIP_INSTALL=1 ;;
    --skip-smoke) SKIP_SMOKE=1 ;;
    -h|--help) usage ;;
    -*) echo "unknown option $a" >&2; usage ;;
    *) if [ -z "$WT" ]; then WT=$a; else echo "unexpected arg $a" >&2; usage; fi ;;
  esac
done
[ -n "$WT" ] || usage
[ -f "$WT/project.clj" ] || [ -f "$WT/deps.edn" ] || { echo "not a bluegenes-tool-store checkout: $WT" >&2; exit 2; }
[ -d "$WT/src/clj/bluegenes_tool_store" ] || { echo "not a bluegenes-tool-store checkout: $WT" >&2; exit 2; }
WT=$(cd "$WT" && pwd)
cd "$WT" || exit 2

export JAVA_HOME=${GATE_JAVA_HOME:-/usr/lib/jvm/java-11-openjdk-arm64}
export PATH=$JAVA_HOME/bin:$PATH
if [ -n "${GATE_LEIN:-}" ]; then LEIN=$GATE_LEIN
elif [ -x /home/agent/tools/lein/lein ]; then LEIN=/home/agent/tools/lein/lein; export LEIN_HOME=${LEIN_HOME:-/home/agent/tools/lein/home}
else LEIN=$(command -v lein || true); fi

LOGS=$WT/.gate-logs
mkdir -p "$LOGS"
[ -f "$LOGS/.gitignore" ] || echo '*' > "$LOGS/.gitignore"

declare -a NAMES RESULTS TIMES NOTES
record() { NAMES+=("$1"); RESULTS+=("$2"); TIMES+=("$3"); NOTES+=("$4"); }
FAILED=0
run_step() { # name logfile cmd...
  local name=$1 log=$2; shift 2
  local s rc
  echo ">>> [$name] $*"
  s=$(date +%s)
  "$@" > "$log" 2>&1; rc=$?
  STEP_RC=$rc; STEP_SECS=$(( $(date +%s) - s ))
  if [ $rc -eq 0 ]; then echo "<<< [$name] ok (${STEP_SECS}s)"; else echo "<<< [$name] FAILED rc=$rc (${STEP_SECS}s), log: $log"; tail -n 15 "$log" | sed 's/^/    | /'; fi
}
test_summary() { sed 's/\x1b\[[0-9;]*m//g' "$1" | grep -E '^Ran [0-9]+ tests' | tail -1; }
fail() { record "$1" FAIL "$2" "$3"; FAILED=1; }

echo "gate-tool-store: worktree=$WT"
echo "gate-tool-store: java=$(java -version 2>&1 | grep -v Picked | head -1)"
HAVE_CLJ=0; command -v clojure >/dev/null 2>&1 && HAVE_CLJ=1
[ $HAVE_CLJ -eq 1 ] && echo "gate-tool-store: clojure CLI=$(clojure --version 2>&1 | grep -v Picked | head -1)"

# ---- 1. lein test ----
if [ -f project.clj ]; then
  if [ -z "$LEIN" ] || [ ! -x "$LEIN" ]; then fail lein-test 0s "lein not found (set GATE_LEIN)"
  else
    run_step lein-test "$LOGS/lein-test.log" "$LEIN" test
    S=$(test_summary "$LOGS/lein-test.log")
    if [ $STEP_RC -eq 0 ] && [ -n "$S" ]; then record lein-test PASS "${STEP_SECS}s" "$S"; else fail lein-test "${STEP_SECS}s" "${S:-see .gate-logs/lein-test.log}"; fi
  fi
else record lein-test SKIP 0s "no project.clj"; fi

# ---- 2. clojure -M:test ----
if [ -f deps.edn ]; then
  if [ $HAVE_CLJ -eq 0 ]; then fail cli-test 0s "clojure CLI not found"
  else
    run_step cli-test "$LOGS/cli-test.log" clojure -M:test
    S=$(test_summary "$LOGS/cli-test.log")
    if [ $STEP_RC -eq 0 ] && [ -n "$S" ]; then record cli-test PASS "${STEP_SECS}s" "$S"; else fail cli-test "${STEP_SECS}s" "${S:-see .gate-logs/cli-test.log}"; fi
  fi
else record cli-test SKIP 0s "no deps.edn"; fi

# ---- 3. jar ----
VERSION=""
if [ -f build.clj ] && [ -f deps.edn ] && [ $HAVE_CLJ -eq 1 ]; then
  run_step jar "$LOGS/jar.log" clojure -T:build jar
  JAR=$(ls target/bluegenes-tool-store-*.jar 2>/dev/null | head -1)
  if [ $STEP_RC -ne 0 ] || [ -z "$JAR" ]; then fail jar "${STEP_SECS}s" "see .gate-logs/jar.log"
  else
    LISTING=$(unzip -Z1 "$JAR")
    PROBLEMS=""
    for f in bluegenes_tool_store/core.clj bluegenes_tool_store/tools.clj bluegenes_tool_store/package.clj bluegenes_tool_store/auth.clj config.edn; do
      echo "$LISTING" | grep -qx "$f" || PROBLEMS="$PROBLEMS missing:$f"
    done
    echo "$LISTING" | grep -q '\.class$' && PROBLEMS="$PROBLEMS contains-.class(AOT)"
    echo "$LISTING" | grep -Eq '^(test/|bluegenes_tool_store/.*_test\.clj)' && PROBLEMS="$PROBLEMS contains-tests"
    POM=$(unzip -p "$JAR" META-INF/maven/org.intermine/bluegenes-tool-store/pom.xml 2>/dev/null)
    VERSION=$(echo "$POM" | sed -n 's|.*<version>\(.*-SNAPSHOT\)</version>.*|\1|p' | head -1)
    [ -n "$VERSION" ] || PROBLEMS="$PROBLEMS pom-version-not-SNAPSHOT"
    echo "$POM" | grep -q '<groupId>org.intermine</groupId>' || PROBLEMS="$PROBLEMS pom-groupId"
    echo "$POM" | grep -q '<artifactId>bluegenes-tool-store</artifactId>' || PROBLEMS="$PROBLEMS pom-artifactId"
    if [ -z "$PROBLEMS" ]; then record jar PASS "${STEP_SECS}s" "$JAR $(du -h "$JAR" | cut -f1), $(echo "$LISTING" | grep -vc '/$') files"
    else fail jar "${STEP_SECS}s" "$JAR:$PROBLEMS"; fi
  fi
else record jar SKIP 0s "no build.clj/deps.edn yet"; fi

# ---- 4. install ----
if [ -f build.clj ] && [ -f deps.edn ] && [ $HAVE_CLJ -eq 1 ] && [ $SKIP_INSTALL -eq 0 ]; then
  run_step install "$LOGS/install.log" clojure -T:build install
  D=$HOME/.m2/repository/org/intermine/bluegenes-tool-store/$VERSION
  if [ $STEP_RC -eq 0 ] && [ -n "$VERSION" ] && [ -f "$D/bluegenes-tool-store-$VERSION.jar" ] && [ -f "$D/bluegenes-tool-store-$VERSION.pom" ]; then
    record install PASS "${STEP_SECS}s" "$D"
  else fail install "${STEP_SECS}s" "jar/pom not found under ~/.m2 for version '${VERSION}'; see .gate-logs/install.log"; fi
else record install SKIP 0s "no build.clj, or --skip-install"; fi

# ---- 5. smoke ----
if [ -f deps.edn ] && [ $HAVE_CLJ -eq 1 ] && [ $SKIP_SMOKE -eq 0 ]; then
  PORT=${GATE_PORT:-5056}
  SMOKE=$(mktemp -d)
  mkdir -p "$SMOKE/tools"; echo '{:tools {}}' > "$SMOKE/tools/tools.edn"
  # The port goes in a config file as a *string*: core.clj does (Integer/parseInt (:server-port env)),
  # and yogthos/config turns a numeric SERVER_PORT env var into a Long, which throws ClassCastException.
  printf '{:server-port "%s" :bluegenes-tool-path "%s" :bluegenes-default-service-root "http://localhost:1/none"}\n' "$PORT" "$SMOKE/tools" > "$SMOKE/config.edn"
  s=$(date +%s)
  ( exec clojure -J-Dconfig="$SMOKE/config.edn" -M -m bluegenes-tool-store.core ) > "$LOGS/smoke-server.log" 2>&1 &
  SPID=$!
  for _ in $(seq 1 90); do curl -s -o /dev/null -m 2 "http://localhost:$PORT/api/tools/path" && break; kill -0 $SPID 2>/dev/null || break; sleep 1; done
  c_path=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "http://localhost:$PORT/api/tools/path")
  c_all=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "http://localhost:$PORT/api/tools/all")
  pkill -P $SPID 2>/dev/null; kill $SPID 2>/dev/null; sleep 1; pkill -9 -P $SPID 2>/dev/null; kill -9 $SPID 2>/dev/null
  rm -rf "$SMOKE"
  if [ "$c_path" = 200 ] && [ "$c_all" = 200 ]; then record smoke PASS "$(( $(date +%s)-s ))s" "/api/tools/path=$c_path /api/tools/all=$c_all on :$PORT"
  else fail smoke "$(( $(date +%s)-s ))s" "path=$c_path all=$c_all; see .gate-logs/smoke-server.log"; fi
else record smoke SKIP 0s "no deps.edn, or --skip-smoke"; fi

# ---- summary ----
echo
echo "================ gate-tool-store summary ($WT) ================"
printf '%-10s %-6s %-8s %s\n' STEP RESULT TIME NOTES
for i in "${!NAMES[@]}"; do printf '%-10s %-6s %-8s %s\n' "${NAMES[$i]}" "${RESULTS[$i]}" "${TIMES[$i]}" "${NOTES[$i]}"; done
echo "logs: $LOGS"
if [ $FAILED -eq 0 ]; then echo "GATE RESULT: PASS"; exit 0; else echo "GATE RESULT: FAIL"; exit 1; fi
