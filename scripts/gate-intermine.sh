#!/usr/bin/env bash
# gate-intermine.sh - per-commit gate for the InterMine Java back end (mirrors CI).
#
# Usage:
#   eval "$(scripts/im-testenv.sh <task-id> create --src <worktree>)"   # once per task
#   scripts/gate-intermine.sh <worktree-path> [builds...]
#
# builds (default: all):
#   all               = suite:intermine + suite:bio (CI im-build.yml unit-tests matrix {intermine, bio})
#   suite:intermine   = intermine
#   suite:bio         = bio bio/sources bio/postprocess bio/postprocess-test (config/ci/run.sh "bio")
#   intermine | bio | bio/sources | bio/postprocess | bio/postprocess-test   (single Gradle builds)
#
# Steps (each Gradle call is CI's run_gradle from config/ci/run.sh:
#   ./gradlew -Dorg.gradle.jvmargs=-Xmx4g --max-workers=4 --no-daemon --warning-mode all --stacktrace <task>)
#   1. config/lib/install_intermine.py with its Gradle-install step disabled: writes every
#      gradle.properties / gradle-wrapper.properties from the *.in templates (defaults: Maven Central,
#      the wrapper version in the .in templates, 6.9.4 since im-ee7.1) and leaves the task's ~/.intermine/*.properties alone (they already exist).
#   2. `publishToMavenLocal` (GATE_INSTALL_TASK) in plugin, intermine, and (if any bio build is requested) bio, bio/sources,
#      bio/postprocess - the module list of install_intermine.py. Any failure aborts the gate.
#   3. `build` in each requested build (tests run with ignoreFailures=true, as in CI).
#   4. `checkstyleMain` in requested builds among intermine, bio, bio/sources, bio/postprocess
#      (checkstyle.yml / run.sh "checkstyle"), then config/lib/parse_checkstyle_report.py <worktree>.
#   5. config/lib/parse_test_report.py on intermine, bio, bio/sources, bio/postprocess-test (as
#      run.sh), plus bio/postprocess if it produced test results.
#   Exit status is non-zero if any step fails or any test fails/errors.
#
# Environment:
#   HOME must be a task home made by im-testenv.sh (checked: $HOME/.intermine/intermine-test.properties
#   exists and HOME is not the real home, unless GATE_ALLOW_REAL_HOME=1).
#   GRADLE_USER_HOME   the task's own Gradle home (<taskhome>/.gradle, exported by im-testenv.sh): private daemon
#                      registry, caches/wrapper/jdks shared by symlink. Defaults to $HOME/.gradle. The gate refuses
#                      to run when it resolves to the shared /home/agent/.gradle (a `gradle --stop` from any task
#                      would then kill this gate's daemons; im-8dd.7), unless GATE_ALLOW_REAL_HOME=1. Every Gradle call
#                      of the gate uses --no-daemon, but Gradle still starts a single-use daemon process
#                      that registers in GRADLE_USER_HOME/daemon, which is why the isolation matters. Workers who run
#                      ad-hoc `./gradlew` must use the task env; `gradle --stop` then only reaches this task's daemons
#                      (so never run it with the task env while this task's gate is running).
#   GATE_JAVA_HOME     JDK to use (default /usr/lib/jvm/java-8-openjdk-arm64)
#   GATE_PYTHON        python with xunitparser (default /home/agent/venvs/intermine-ci/bin/python;
#                      created automatically if missing)
#   GATE_INSTALL_ARGS  extra args for install_intermine.py (e.g. --gradle_distribution_url ...)
#   GATE_GRADLE_ARGS   extra args appended to every Gradle call (e.g. --offline, --rerun-tasks)
#   GATE_CLEAN=1       run `clean` in every involved build before installing
#   GATE_FAIL_ON_GRADLE_DEPRECATION=1 fail the gate when a Gradle deprecation warning appears (the JDK 8 "Executing Gradle on JVM
#                      versions 16 and lower" note excepted). javac's deprecation notes and warnings are counted apart and never fail it (im-8dd.6)
#   GATE_SKIP_PLUGIN_TEST=1 skip the plugin's TestKit tests (im-ee7.51)
#   GATE_SKIP_TESTMINE=1 skip the testmine build -x test that follows the intermine suite (im-jqz.52)
#   GATE_SKIP_INSTALL=1, GATE_SKIP_CHECKSTYLE=1   skip those steps (for quick local iteration only;
#                      a real gate run must not skip them)
#   GATE_INSTALL_TASK  Gradle task of step 2 (default publishToMavenLocal; `install` is a deprecated alias of it)
#   GATE_SHARED_M2=1   let publishToMavenLocal write org.intermine artefacts to the shared ~/.m2 (CI behaviour);
#                      default is the task-private $HOME/.m2-intermine/repository (-Dmaven.repo.local)
#   GATE_LANG          locale for the build (default C.UTF-8, as on GitHub runners)
#   GATE_XMX           Gradle daemon heap (default 4g; do not raise in the shared sandbox)
#   GATE_MAX_WORKERS   default 4
#
# Output: compact summary on stdout (per build: tests run/failed/errored/skipped, wall time, peak RSS
# of the Gradle process tree); full logs, per-test failure list, deprecation list and summary in
# <worktree>/.gate-logs/ (self-ignored via .gate-logs/.gitignore).
set -uo pipefail

[ $# -ge 1 ] || { sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }
WT=$(cd "$1" && pwd) || exit 2; shift
[ -f "$WT/config/lib/install_intermine.py" ] || { echo "not an intermine checkout: $WT" >&2; exit 2; }

# ---------- requested builds ----------
ALL_BUILDS=(intermine bio bio/sources bio/postprocess bio/postprocess-test)
BUILDS=()
add_build() { local b; for b in "${BUILDS[@]}"; do [ "$b" = "$1" ] && return; done; BUILDS+=("$1"); }
[ $# -eq 0 ] && set -- all
for arg in "$@"; do
  case $arg in
    all) for b in "${ALL_BUILDS[@]}"; do add_build "$b"; done ;;
    suite:intermine) add_build intermine ;;
    suite:bio) for b in bio bio/sources bio/postprocess bio/postprocess-test; do add_build "$b"; done ;;
    intermine|bio|bio/sources|bio/postprocess|bio/postprocess-test) add_build "$arg" ;;
    *) echo "unknown build '$arg'" >&2; exit 2 ;;
  esac
done
NEED_BIO=0
for b in "${BUILDS[@]}"; do case $b in bio*) NEED_BIO=1 ;; esac; done

# ---------- environment ----------
if [ "${GATE_ALLOW_REAL_HOME:-0}" != 1 ]; then
  [ "$HOME" != /home/agent ] || { echo "HOME is the real home; eval \"\$(im-testenv.sh <task-id>)\" first" >&2; exit 2; }
fi
export GRADLE_USER_HOME=${GRADLE_USER_HOME:-$HOME/.gradle}
if [ "${GATE_ALLOW_REAL_HOME:-0}" != 1 ] && [ "$(readlink -f "$GRADLE_USER_HOME")" = "$(readlink -f /home/agent/.gradle)" ]; then
  echo "GRADLE_USER_HOME ($GRADLE_USER_HOME) is the shared /home/agent/.gradle: daemons would be shared with, and killable by, other tasks." >&2
  echo "Re-run: im-testenv.sh <task-id> create --src <worktree> (it makes <taskhome>/.gradle a private home) and eval its output / source <taskhome>/env.sh" >&2
  exit 2
fi
for f in intermine-test.properties intermine-bio-test.properties testmodel.properties; do
  [ -f "$HOME/.intermine/$f" ] || { echo "missing $HOME/.intermine/$f (run im-testenv.sh)" >&2; exit 2; }
done
export PSQL_HOST=${PSQL_HOST:-localhost} PSQL_USER=${PSQL_USER:-test} PSQL_PWD=${PSQL_PWD:-test}
export JAVA_HOME=${GATE_JAVA_HOME:-/usr/lib/jvm/java-8-openjdk-arm64}
export PATH=$JAVA_HOME/bin:$PATH
export ANT_OPTS='-server'
# GitHub runners run with LANG=C.UTF-8; without a UTF-8 locale JDK 8 defaults to ASCII and javadoc
# fails on non-ASCII source (jbrowse-endpoint Segment.java). Override with GATE_LANG.
export LANG=${GATE_LANG:-C.UTF-8} LC_ALL=${GATE_LANG:-C.UTF-8}
PY=${GATE_PYTHON:-/home/agent/venvs/intermine-ci/bin/python}
if ! "$PY" -c 'import xunitparser' 2>/dev/null; then
  echo "creating venv for xunitparser at $(dirname "$(dirname "$PY")")" >&2
  python3 -m venv "$(dirname "$(dirname "$PY")")" && "$PY" -m pip install -q xunitparser==1.3.4 'requests>=2.20.0' || exit 2
fi
XMX=${GATE_XMX:-4g}
WORKERS=${GATE_MAX_WORKERS:-4}

LOGS=$WT/.gate-logs
mkdir -p "$LOGS"
printf '*\n' > "$LOGS/.gitignore"
rm -f "$LOGS"/*.log "$LOGS"/summary.txt "$LOGS"/steps.tsv "$LOGS"/deprecations.txt "$LOGS"/gradle-deprecations.count "$LOGS"/failed-tests.txt
STEPS=$LOGS/steps.tsv      # name \t status \t seconds \t peakRSS_MB
FAIL=0

{
  echo "gate-intermine $(date -Is)"
  echo "worktree: $WT  ($(git -C "$WT" rev-parse --short HEAD 2>/dev/null) $(git -C "$WT" rev-parse --abbrev-ref HEAD 2>/dev/null)$(git -C "$WT" diff --quiet 2>/dev/null || echo ', dirty'))"
  echo "GRADLE_USER_HOME=$GRADLE_USER_HOME  PSQL_USER=$PSQL_USER"
  echo "HOME=$HOME  JAVA_HOME=$JAVA_HOME  LANG=$LANG"
  "$JAVA_HOME/bin/java" -version 2>&1 | grep -v JAVA_TOOL_OPTIONS | head -1
  echo "builds: ${BUILDS[*]}"
} | tee "$LOGS/header.txt"

# ---------- helpers ----------
CUR_PID=
on_signal() {
  if [ -n "$CUR_PID" ]; then pkill -TERM -P "$CUR_PID" 2>/dev/null; kill -TERM "$CUR_PID" 2>/dev/null; fi
  echo "gate interrupted" >&2; exit 130
}
trap on_signal INT TERM HUP
# Sum RSS (MB) of a process tree every 2 s; write the peak to $2.
mem_sampler() {
  local root=$1 out=$2 peak=0 cur
  while kill -0 "$root" 2>/dev/null; do
    cur=$(ps -e -o pid=,ppid=,rss= | awk -v r="$root" '
      { p[$1]=$2; m[$1]=$3 }
      END { s=0; for (i in p) { j=i; while (j!="" && j!=0 && j!=1) { if (j==r) { s+=m[i]; break } j=p[j] } } print int(s/1024) }')
    [ "$cur" -gt "$peak" ] && peak=$cur && echo "$peak" > "$out"
    sleep 2
  done
}

# run_step <name> <dir> <cmd...> : run in dir, log to $LOGS/<name>.log, record time/mem/status.
run_step() {
  local name=$1 dir=$2; shift 2
  local log=$LOGS/$name.log memf=$LOGS/.$name.mem start end rc
  echo 0 > "$memf"
  start=$(date +%s)
  printf '%-34s ' "$name" >&2
  ( cd "$WT/$dir" && echo "+ (cd $dir && $*)" && exec "$@" ) > "$log" 2>&1 &
  local pid=$!
  CUR_PID=$pid
  mem_sampler "$pid" "$memf" &
  local spid=$!
  wait "$pid"; rc=$?
  CUR_PID=
  kill "$spid" 2>/dev/null; wait "$spid" 2>/dev/null
  end=$(date +%s)
  local secs=$((end-start)) mem; mem=$(cat "$memf"); rm -f "$memf"
  local st=OK; [ $rc -eq 0 ] || st="FAIL($rc)"
  printf '%s\t%s\t%s\t%s\n' "$name" "$st" "$secs" "$mem" >> "$STEPS"
  printf '%-9s %6ss  peak %5s MB\n' "$st" "$secs" "$mem" >&2
  return $rc
}

# publishToMavenLocal (maven-publish; `install` was the old maven plugin) writes org.intermine:*:5.1.1 into the Maven local repo. ~/.m2 is
# shared between tasks, so by default each task installs into its own repo inside the task home
# (the intermine builds never read mavenLocal; they resolve each other through file/ivy repos in
# the worktree, so nothing else changes). GATE_SHARED_M2=1 restores CI's behaviour (~/.m2).
M2_ARGS=
if [ "${GATE_SHARED_M2:-0}" != 1 ]; then
  M2_LOCAL=$HOME/.m2-intermine/repository
  mkdir -p "$M2_LOCAL"
  M2_ARGS=-Dmaven.repo.local=$M2_LOCAL
fi

gradle() {  # gradle <dir> <task> [more gradle args...]  == run.sh run_gradle
  local dir=$1 task=$2; shift 2
  local label; label=$(printf '%s' "$task $*" | sed -e 's/ -x [^ ]*//g' -e 's/^://' -e 's/ :/ /g' -e 's/[: ]/_/g')
  # shellcheck disable=SC2086
  run_step "$(echo "$dir" | tr / -)-$label" "$dir" ./gradlew -Dorg.gradle.jvmargs=-Xmx$XMX --max-workers=$WORKERS \
    --no-daemon --warning-mode all --stacktrace $M2_ARGS ${GATE_GRADLE_ARGS:-} "$task" "$@"
}

TOTAL_START=$(date +%s)

# ---------- 1. generated properties ----------
cat > "$LOGS/.genprops.py" <<'EOF'
import sys
sys.path.insert(0, sys.argv[1])
import install_intermine as m
m.IntermineBuilder.gradle_install_modules = lambda self, clean=False: None
sys.argv = ["install_intermine.py"] + sys.argv[2:]
m.main()
EOF
# shellcheck disable=SC2086
run_step genprops . "$PY" "$LOGS/.genprops.py" "$WT/config/lib" ${GATE_INSTALL_ARGS:-} || { echo "property generation failed" >&2; exit 1; }
if grep -q "^Written $HOME/.intermine" "$LOGS/genprops.log"; then
  echo "install_intermine.py wrote unsuffixed ~/.intermine files; re-run im-testenv.sh" >&2; exit 1
fi

# ---------- 2. install ----------
INSTALL=(plugin intermine)
[ $NEED_BIO = 1 ] && INSTALL+=(bio bio/sources bio/postprocess)
# GATE_CLEAN: `clean` right before each build's install (as install_intermine.py --clean does) or,
# for builds that are not installed, right before `build`. Order matters: the bio builds cannot even
# be configured (and so cannot be cleaned) until plugin/intermine have been installed.
is_install() { local x; for x in "${INSTALL[@]}"; do [ "$x" = "$1" ] && return 0; done; return 1; }
is_build() { local x; for x in "${BUILDS[@]}"; do [ "$x" = "$1" ] && return 0; done; return 1; }
if [ "${GATE_SKIP_INSTALL:-0}" != 1 ]; then
  for d in "${INSTALL[@]}"; do
    if [ "${GATE_CLEAN:-0}" = 1 ]; then gradle "$d" clean || { FAIL=1; break; }; fi
    gradle "$d" "${GATE_INSTALL_TASK:-publishToMavenLocal}" || { echo "install failed in $d; see $LOGS" >&2; FAIL=1; break; }
  done
fi

# ---------- 3. build ----------
BUILT=0
if [ $FAIL = 0 ]; then
  BUILT=1
  # TestKit tests of the Gradle plugin (plugin/src/test, im-ee7.51); publishToMavenLocal does not run them
  if is_build intermine && [ "${GATE_SKIP_PLUGIN_TEST:-0}" != 1 ]; then
    gradle plugin test || FAIL=1
  fi
  for d in "${BUILDS[@]}"; do
    if [ "${GATE_CLEAN:-0}" = 1 ] && { [ "${GATE_SKIP_INSTALL:-0}" = 1 ] || ! is_install "$d"; }; then
      gradle "$d" clean || FAIL=1
    fi
    gradle "$d" build || FAIL=1
  done
  # testmine is not published and has no unit tests of its own, but its webapp war is the only
  # in-repo consumer of the plugin's war composition and of the published intermine artefacts
  # (im-jqz.52: ~12 s). Only when the intermine suite is in the gate.
  if [ $FAIL = 0 ] && is_build intermine && [ "${GATE_SKIP_TESTMINE:-0}" != 1 ]; then
    gradle testmine :dbmodel:copyMineProperties build -x test || FAIL=1   # copyMineProperties explicit for the 5.1.1 line, where :webapp:mergeProperties still needs it
  fi
fi

# ---------- 4. checkstyle ----------
if [ $FAIL = 0 ] && [ "${GATE_SKIP_CHECKSTYLE:-0}" != 1 ]; then
  CS=0
  for d in "${BUILDS[@]}"; do
    case $d in intermine|bio|bio/sources|bio/postprocess) gradle "$d" checkstyleMain || FAIL=1; CS=1 ;; esac
  done
  if [ $CS = 1 ]; then
    run_step checkstyle-report . "$PY" "$WT/config/lib/parse_checkstyle_report.py" "$WT" || FAIL=1
  fi
fi

# ---------- 5. test reports ----------
for d in "${BUILDS[@]}"; do
  [ $BUILT = 1 ] || break
  case $d in
    bio/postprocess) ls "$WT"/bio/postprocess/*/build/test-results/test/*.xml >/dev/null 2>&1 || continue ;;
  esac
  [ -d "$WT/$d" ] || continue
  run_step "test-report-$(echo "$d" | tr / -)" . "$PY" "$WT/config/lib/parse_test_report.py" "$WT/$d" || FAIL=1
done

TOTAL=$(( $(date +%s) - TOTAL_START ))

# ---------- summary ----------
"$PY" - "$WT" "$LOGS" "$TOTAL" "${BUILDS[@]}" <<'EOF' | tee "$LOGS/summary.txt"
import glob, os, re, sys
import xml.etree.ElementTree as ET
wt, logs, total = sys.argv[1], sys.argv[2], int(sys.argv[3])
builds = sys.argv[4:]
steps = {}
for line in open(os.path.join(logs, "steps.tsv")):
    n, st, s, m = line.rstrip("\n").split("\t")
    steps[n] = (st, int(s), int(m))
def fmt(s): return "%d:%02d:%02d" % (s // 3600, s % 3600 // 60, s % 60)
failed = []
rows = []
for b in builds:
    tot = [0, 0, 0, 0]
    sub = {}
    for x in glob.glob(os.path.join(wt, b, "*", "build", "test-results", "test", "*.xml")):
        proj = x[len(os.path.join(wt, b)) + 1:].split(os.sep)[0]
        try:
            r = ET.parse(x).getroot()
        except ET.ParseError as e:
            failed.append("%s: unparseable %s (%s)" % (b, x, e)); continue
        suites = [r] if r.tag == "testsuite" else r.findall("testsuite")
        for s in suites:
            for tc in s.findall("testcase"):
                k = 0
                if tc.find("failure") is not None: k = 1
                elif tc.find("error") is not None: k = 2
                elif tc.find("skipped") is not None: k = 3
                c = sub.setdefault(proj, [0, 0, 0, 0])
                c[0] += 1; tot[0] += 1
                if k:
                    c[k] += 1; tot[k] += 1
                if k in (1, 2):
                    failed.append("%s %s %s.%s" % (("FAILURE", "ERROR")[k - 1], b, tc.get("classname"), tc.get("name")))
    key = b.replace("/", "-")
    st, secs, mem = steps.get(key + "-build", ("not run", 0, 0))
    rows.append((b, st, tot, secs, mem, sub))
print("\n%-22s %-9s %6s %6s %6s %6s %9s %8s" % ("build", "gradle", "tests", "fail", "error", "skip", "wall", "peakMB"))
for b, st, t, secs, mem, sub in rows:
    print("%-22s %-9s %6d %6d %6d %6d %9s %8d" % (b, st, t[0], t[1], t[2], t[3], fmt(secs), mem))
with open(os.path.join(logs, "per-subproject.txt"), "w") as f:
    for b, st, t, secs, mem, sub in rows:
        for p in sorted(sub):
            c = sub[p]
            f.write("%s/%s\t%d\t%d\t%d\t%d\n" % (b, p, c[0], c[1], c[2], c[3]))
other = [(n, v) for n, v in steps.items() if not n.endswith("-build")]
print("\nother steps: " + ", ".join("%s %s %s" % (n, v[0], fmt(v[1])) for n, v in other))
with open(os.path.join(logs, "failed-tests.txt"), "w") as f:
    f.write("\n".join(failed) + ("\n" if failed else ""))
if failed:
    print("\n%d failed/errored tests (first 30; full list in .gate-logs/failed-tests.txt):" % len(failed))
    for x in failed[:30]: print("  " + x)
# deprecation warnings, counted apart (im-8dd.6): Gradle's own (--warning-mode all: "Deprecated Gradle features were used in this
# build", "The X has been deprecated ...") versus javac's: "Note: F.java uses or overrides a deprecated API" and, with
# -Xlint, "F.java:12: warning: [deprecation] m() in C has been deprecated" / "[removal]", which say "has been deprecated" too.
# Any other line that mentions "deprecat" (a test's output, a Gradle task named after a deprecated alias) is in neither count.
JAVAC = re.compile(r"^Note: |\[(?:deprecation|removal)\]|\.(?:java|groovy):\d+: warning:|uses or overrides a deprecated API|-Xlint:deprecation")
GRADLE = re.compile(r"Deprecated Gradle features|has been deprecated|is deprecated|scheduled to be removed in Gradle|will fail with an error in Gradle")
# Gradle 8 on JDK 8 always says this once per Gradle call; it is Gradle's, but not a deprecation of the build scripts
JVM_NOTE = "Executing Gradle on JVM versions 16 and lower has been deprecated"
gdep, jdep, odep = {}, {}, {}
for lf in sorted(glob.glob(os.path.join(logs, "*.log"))):
    step = os.path.basename(lf)[:-4]
    for line in open(lf, errors="replace"):
        if not re.search(r"deprecat", line, re.I) or line.lstrip().startswith("at "):
            continue
        msg = re.sub(r"\s+", " ", line.strip())
        if JAVAC.search(msg):
            msg = re.sub(r"^Note: \S+/", "Note: <file> ", msg) if "uses or overrides" in msg and "/" in msg else msg
            msg = re.sub(r"^\S+/(\S+\.(?:java|groovy)):\d+: warning:", r"\1: warning:", msg)
            d = jdep
        elif GRADLE.search(msg):
            d = gdep
        else:
            d = odep
        e = d.setdefault(msg, [0, set()]); e[0] += 1; e[1].add(step)
with open(os.path.join(logs, "deprecations.txt"), "w") as f:
    for title, d in (("Gradle deprecation warnings", gdep), ("javac deprecation notes and warnings", jdep),
                     ("other lines that mention 'deprecat' (in neither count)", odep)):
        f.write("== %s (%d distinct)\n" % (title, len(d)))
        for m, (c, st) in sorted(d.items(), key=lambda kv: -kv[1][0]):
            f.write("%6d  %s\n        in: %s\n" % (c, m, " ".join(sorted(st))))
gline = sum(c for c, st in gdep.values()); jline = sum(c for c, st in jdep.values())
gact = [m for m in gdep if not m.startswith(JVM_NOTE)]
with open(os.path.join(logs, "gradle-deprecations.count"), "w") as f:
    f.write("%d\n" % len(gact))
print("\nGradle deprecation warnings: %d distinct (%d lines; %d besides the JDK 8 note); javac deprecation notes/warnings: %d distinct (%d lines); other: %d distinct (.gate-logs/deprecations.txt)"
      % (len(gdep), gline, len(gact), len(jdep), jline, len(odep)))
print("total wall time: %s" % fmt(total))
EOF

# Files the build/tests leave in the source tree that git does not ignore (e.g. bio/core/obo-converter-tgt.xml
# written by a bio-core test). Reported so they are not committed by accident; they do not fail the gate.
untracked=$(git -C "$WT" status --porcelain --untracked-files=all 2>/dev/null | grep '^??' | cut -c4-)
if [ -n "$untracked" ]; then
  echo "untracked files left by the build (do not commit):" | tee -a "$LOGS/summary.txt"
  echo "$untracked" | sed 's/^/  /' | tee -a "$LOGS/summary.txt"
fi
if [ $FAIL = 0 ] && [ -s "$LOGS/failed-tests.txt" ]; then FAIL=1; fi
# Gradle's own deprecations (not javac's, not the JDK 8 note) fail the gate only when asked: GATE_FAIL_ON_GRADLE_DEPRECATION=1
if [ "${GATE_FAIL_ON_GRADLE_DEPRECATION:-0}" = 1 ] && [ "$(cat "$LOGS/gradle-deprecations.count" 2>/dev/null || echo 0)" != 0 ]; then
  echo "Gradle deprecation warnings found (GATE_FAIL_ON_GRADLE_DEPRECATION=1): see $LOGS/deprecations.txt" | tee -a "$LOGS/summary.txt"; FAIL=1
fi
if [ $FAIL = 0 ]; then echo "GATE PASSED" | tee -a "$LOGS/summary.txt"; else echo "GATE FAILED (logs: $LOGS)" | tee -a "$LOGS/summary.txt"; fi
exit $FAIL
