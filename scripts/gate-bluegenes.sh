#!/usr/bin/env bash
# gate-bluegenes.sh - quality gate for a BlueGenes worktree.
#
# Usage:
#   gate-bluegenes.sh <worktree-path> [--with-prod] [--allow-no-browser] [--skip-npm-audit]
#
# Steps (each timed, each logged to <worktree>/.gate-logs/<step>.log):
#   1. cljfmt   : lein cljfmt check
#   2. npm      : npm ci   (only if node_modules is missing or package-lock.json
#                 changed since the last successful gate run)
#   3. kaocha   : lein kaocha  (ClojureScript unit tests in a headless browser)
#   4. prod     : (only with --with-prod) lein build  (= clean, assets, lessc -x,
#                 advanced cljsbuild, fingerprint-css) then lein with-profile
#                 +uberjar uberjar-style packaging is NOT used by CI; instead the
#                 gate runs `lein with-profile uberjar uberjar` to produce
#                 target/bluegenes.jar and checks the jar exists. It does not run
#                 cypress and does not start the server.
#
# Options:
#   --with-prod          also run the production build (slow: several minutes)
#   --allow-no-browser   if no usable headless browser is found, SKIP kaocha and
#                        do not fail the gate because of it. Without this flag a
#                        missing browser is a gate FAILURE (exit non-zero).
#   --skip-npm-audit     do not record `npm audit` counts (audit is informational
#                        only and never fails the gate)
#
# Environment overrides:
#   JAVA_HOME            default /usr/lib/jvm/java-11-openjdk-arm64 (CI uses 8, the
#                        Dockerfile runs 11). Set GATE_JAVA_HOME to override.
#   GATE_BROWSER         path to a chrome/chromium executable to use for kaocha
#   GATE_BROWSER_LIBS    optional LD_LIBRARY_PATH needed by that executable
#                        (default: <dir of browser>/al2023/lib if it exists)
#   CYPRESS_INSTALL_BINARY  default 0 here: cypress 6.9 has no linux-arm64 binary
#                        and the download host is blocked in the sandbox, and the
#                        gate never runs cypress. Set to "" to get the real install.
#
# Browser discovery order: $GATE_BROWSER, google-chrome-stable, google-chrome,
# chromium, chromium-browser (only if `--version` works, i.e. not a snap stub),
# /home/agent/browser-scratch/chromium-arm64/chromium (Sparticuz arm64 build).
#
# kaocha-cljs uses cljs.repl.browser/repl-env which starts a server on :9000 and
# opens a browser via clojure.java.browse -> xdg-open. The gate puts a shim
# `xdg-open` first on PATH that starts the discovered browser headless, so it
# never tries to open a page on the host desktop. Browser processes are killed
# at exit.
#
# Exit code: 0 = every executed step passed (skipped-by-allowance steps count as
# pass); 1 = at least one step failed; 2 = usage error.
# Final line of output is a one-line machine-greppable summary: GATE RESULT: ...

set -u
usage() { sed -n '2,45p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }

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
[ -f "$WT/project.clj" ] || { echo "not a bluegenes checkout: $WT" >&2; exit 2; }
WT=$(cd "$WT" && pwd)
cd "$WT" || exit 2

export JAVA_HOME=${GATE_JAVA_HOME:-/usr/lib/jvm/java-11-openjdk-arm64}
export PATH=$JAVA_HOME/bin:$PATH
export CYPRESS_INSTALL_BINARY=${CYPRESS_INSTALL_BINARY-0}

LOGS=$WT/.gate-logs
mkdir -p "$LOGS"
# keep the log dir out of `git status` without touching tracked files
[ -f "$LOGS/.gitignore" ] || echo '*' > "$LOGS/.gitignore"

declare -a NAMES RESULTS TIMES NOTES
record() { NAMES+=("$1"); RESULTS+=("$2"); TIMES+=("$3"); NOTES+=("$4"); }
FAILED=0

run_step() { # name logfile cmd...
  local name=$1 log=$2; shift 2
  local s e rc
  echo ">>> [$name] $*"
  s=$(date +%s)
  "$@" > "$log" 2>&1; rc=$?
  e=$(( $(date +%s) - s ))
  STEP_RC=$rc; STEP_SECS=$e
  if [ $rc -eq 0 ]; then echo "<<< [$name] ok (${e}s)"; else echo "<<< [$name] FAILED rc=$rc (${e}s), log: $log"; tail -n 15 "$log" | sed 's/^/    | /'; fi
}

echo "gate-bluegenes: worktree=$WT"
echo "gate-bluegenes: java=$(java -version 2>&1 | grep -v Picked | head -1) lein=$(lein version 2>&1 | grep -v Picked | head -1)"
echo "gate-bluegenes: node=$(node -v) npm=$(npm -v)"

# ---- 1. cljfmt ----
run_step cljfmt "$LOGS/cljfmt.log" lein cljfmt check
if [ $STEP_RC -eq 0 ]; then record cljfmt PASS "${STEP_SECS}s" ""; else record cljfmt FAIL "${STEP_SECS}s" "see .gate-logs/cljfmt.log"; FAILED=1; fi

# ---- 2. npm ci ----
LOCKSUM=$(sha256sum package-lock.json package.json | sha256sum | cut -d' ' -f1)
STAMP=node_modules/.gate-lock-sha
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
  AUD=$(node -e 'try{const m=require(process.argv[1]).metadata.vulnerabilities;console.log(`critical=${m.critical} high=${m.high} moderate=${m.moderate} low=${m.low} total=${m.total}`)}catch(e){console.log("unavailable")}' "$LOGS/npm-audit.json")
  record npm-audit INFO "-" "$AUD"
fi

# ---- 3. kaocha ----
find_browser() {
  local c
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
SHIM=""
cleanup() {
  pkill -f "$LOGS/browser-profile" 2>/dev/null
  [ -n "$SHIM" ] && rm -rf "$SHIM"
}
trap cleanup EXIT
if [ -z "$BROWSER" ]; then
  echo ">>> [kaocha] no usable headless browser found"
  if [ $ALLOW_NO_BROWSER -eq 1 ]; then
    record kaocha SKIP "0s" "no browser; allowed by --allow-no-browser"
  else
    record kaocha FAIL "0s" "no usable browser (use GATE_BROWSER=/path/to/chrome or --allow-no-browser)"; FAILED=1
  fi
else
  echo ">>> [kaocha] browser: $BROWSER ($("$BROWSER" --version 2>&1 | head -1))"
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
  PATH="$SHIM:$PATH" run_step kaocha "$LOGS/kaocha.log" timeout 1800 lein kaocha
  KRC=$STEP_RC; KS=$STEP_SECS
  pkill -f "$LOGS/browser-profile" 2>/dev/null; rm -rf "$LOGS"/browser-profile-* 2>/dev/null
  SUMMARY=$(grep -E '^[0-9]+ tests, [0-9]+ assertions' "$LOGS/kaocha.log" | tail -1)
  if [ $KRC -eq 0 ]; then record kaocha PASS "${KS}s" "$SUMMARY"; else record kaocha FAIL "${KS}s" "${SUMMARY:-see .gate-logs/kaocha.log}"; FAILED=1; fi
fi

# ---- 4. prod ----
if [ $WITH_PROD -eq 1 ]; then
  if [ ! -d node_modules ] || [ ! -x node_modules/.bin/lessc ]; then
    record prod FAIL "0s" "node_modules missing (npm step failed)"; FAILED=1
  else
    run_step prod-build "$LOGS/prod-build.log" lein build
    if [ $STEP_RC -ne 0 ]; then
      record prod-build FAIL "${STEP_SECS}s" "see .gate-logs/prod-build.log"; FAILED=1
    else
      record prod-build PASS "${STEP_SECS}s" "lein build (clean, assets, less -x, cljsbuild min, fingerprint-css)"
      run_step uberjar "$LOGS/uberjar.log" lein with-profile uberjar uberjar
      # note: :uberjar profile prep-tasks run `build` again, so this step includes a second cljs compile
      if [ $STEP_RC -eq 0 ] && [ -f target/bluegenes.jar ]; then
        record uberjar PASS "${STEP_SECS}s" "target/bluegenes.jar $(du -h target/bluegenes.jar | cut -f1)"
      else
        record uberjar FAIL "${STEP_SECS}s" "see .gate-logs/uberjar.log"; FAILED=1
      fi
    fi
    grep -i -E 'WARNING|deprecat' "$LOGS/prod-build.log" "$LOGS/uberjar.log" 2>/dev/null | grep -v '^Picked' | sort | uniq -c | sort -rn | head -50 > "$LOGS/warnings.txt"
  fi
fi

# ---- summary ----
echo
echo "================ gate-bluegenes summary ($WT) ================"
printf '%-12s %-6s %-8s %s\n' STEP RESULT TIME NOTES
for i in "${!NAMES[@]}"; do printf '%-12s %-6s %-8s %s\n' "${NAMES[$i]}" "${RESULTS[$i]}" "${TIMES[$i]}" "${NOTES[$i]}"; done
echo "logs: $LOGS"
if [ $FAILED -eq 0 ]; then echo "GATE RESULT: PASS"; exit 0; else echo "GATE RESULT: FAIL"; exit 1; fi
