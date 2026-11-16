#!/usr/bin/env bash
# im-testenv.sh - isolated InterMine test environment (private HOME + private Postgres DBs) for one task.
#
# Usage:
#   im-testenv.sh <task-id> [create|reset|drop|destroy|env|status] [--src <intermine-checkout>] [--role|--role-ci]
#
#   create   (default) make the task home, (re)write ~/.intermine/*.properties, drop+create the
#            task's databases (and, with --role/--role-ci, the task's Postgres role), write
#            <taskhome>/env.sh and print the export lines.
#   reset    drop and re-create the task's databases only (properties untouched).
#   drop     drop the task's databases.
#   destroy  drop the task's databases (and the task's role, if any) and delete the task home.
#   env      print the export lines (does not touch anything).
#   status   list the task's databases (and role) that currently exist.
#
#   --src DIR  intermine checkout whose config/ci.properties, config/ci-bio.properties and
#              config/testmodel.properties are used as templates. Default: the worktree you are in
#              (if it is an intermine checkout), else repos/intermine (read only).
#   --role     non-superuser test role (im-8dd.7 / im-rkn.8), also IM_PG_ROLE_MODE=1. See "Role mode".
#   --role-ci  like --role but laid out exactly as CI does (see "Role mode"), also IM_PG_ROLE_MODE=ci.
#
# Typical use by a worker:
#   eval "$(scripts/im-testenv.sh im-rkn.3 create --src "$WT")"   # or: source <taskhome>/env.sh
#   scripts/gate-intermine.sh "$WT"
#   scripts/im-testenv.sh im-rkn.3 destroy                         # when the task is finished
#
# What it produces (task id "im-rkn.3" -> suffix "_im_rkn_3"):
#   /home/agent/taskhomes/im-rkn.3/
#     .gradle/                           (the task's own GRADLE_USER_HOME, see "Gradle isolation")
#       caches  -> /home/agent/.gradle/caches    (shared: downloaded artefacts, no re-download)
#       wrapper -> /home/agent/.gradle/wrapper   (shared: unpacked Gradle distributions)
#       jdks    -> /home/agent/.gradle/jdks      (shared: toolchain JDKs)
#       daemon/ native/ workers/ notifications/  (private, created by Gradle on first use)
#     .m2     -> /home/agent/.m2         (shared Maven local repo)
#     .intermine/intermine-test.properties      (from config/ci.properties)
#     .intermine/intermine-bio-test.properties  (from config/ci-bio.properties)
#     .intermine/testmodel.properties           (from config/testmodel.properties)
#     .pg-role                                  (only in role mode: "<mode> <role>", read by reset/drop/destroy/env)
#     env.sh                                    (export HOME=... GRADLE_USER_HOME=... PSQL_*=... IM_*=...)
#     .m2-intermine/repository   (created later by gate-intermine.sh: task-private target of
#                                 `./gradlew install`, so tasks do not overwrite each other's
#                                 org.intermine:*:5.1.1 artefacts in the shared ~/.m2)
#   These are exactly the three files config/lib/install_intermine.py copies into ~/.intermine, with
#   the same names, so install_intermine.py (and config/ci/init.sh) see them as already present and
#   skip them ("Skipping ... as it already exists"). PSQL_HOST/USER/PWD are substituted as
#   install_intermine.py does, and every db.*.datasource.databaseName gets the suffix, e.g.
#   unittest -> unittest_im_rkn_3, userprofile-test -> userprofile-test_im_rkn_3,
#   bio-test -> bio-test_im_rkn_3. The databases created are exactly the databaseName values found
#   in the generated files (10 DBs), owned by the DB user (test).
#
# Gradle isolation (im-8dd.7). Gradle keeps its daemon registry (daemon/<version>/registry.bin) under
#   GRADLE_USER_HOME. When every task symlinked ~/.gradle to the shared /home/agent/.gradle, a
#   `gradle --stop` (or a crash that cleaned the registry) in one task stopped the daemons of every other task
#   (15 Nov: lost gate runs). Now each task has its own GRADLE_USER_HOME=<taskhome>/.gradle, exported by
#   env.sh / `env`, so the daemon registry, native libs and worker state are private, while
#   caches/, wrapper/ and jdks/ are symlinks into the shared /home/agent/.gradle (Gradle's cache locking is
#   built for several processes sharing one caches dir, and locks live inside caches/, so sharing stays safe;
#   there is no separate registry setting to point elsewhere). Consequences:
#     - `gradle --stop` / `./gradlew --stop` run with a task's env stops only that task's daemons, so it can no
#       longer hurt another task. It still stops every daemon of its own task, INCLUDING the single-use daemon of
#       that task's running gate (measured: `--stop` with the gate's own env aborted `intermine-build` with
#       "Gradle build daemon has been stopped: stop command received"), so do not run it while a gate of the same
#       task is in progress. Never run it with the real HOME/GRADLE_USER_HOME: that still reaches daemons under
#       /home/agent/.gradle (workers that skipped im-testenv.sh).
#     - Nothing is downloaded again: the task shares the artefact cache and the unpacked wrapper dists.
#     - A task home created by an older version of this script (".gradle" symlink to the shared dir) is
#       converted by `create`.
#     - JAVA_TOOL_OPTIONS=-Duser.home is NOT set: JDK 8 ignores $HOME for user.home, but Gradle uses
#       GRADLE_USER_HOME (wrapper and daemon both honour the variable) and the InterMine build scripts read
#       ~/.intermine through System.env.HOME. Setting JAVA_TOOL_OPTIONS would also replace the sandbox's
#       proxy settings, which arrive in that variable. If a tool is found that really needs user.home,
#       append -Duser.home=$HOME to the existing value (JAVA_TOOL_OPTIONS="$JAVA_TOOL_OPTIONS -Duser.home=$HOME").
#
# Role mode (im-rkn.8). By default the databases belong to the Postgres *superuser* `test`, so local gates cannot see
#   privilege problems. --role creates a dedicated role im_<id> (the task id sanitised as in the DB suffix,
#   no doubled "im_"; e.g. im-8dd7r -> im_8dd7r) with LOGIN CREATEDB NOSUPERUSER NOCREATEROLE and password
#   $IM_PG_PWD (test), owns all task databases (CREATE DATABASE ... OWNER role) and is written into the task's
#   ~/.intermine/*.properties (db.*.datasource.user/password) and env.sh (PSQL_USER/PSQL_PWD).
#   --role-ci copies CI's layout instead (config/ci/init.sh `createuser test`, then testresources'
#   createUnitTestDatabases): role without CREATEDB, databases owned by postgres, and only
#   `GRANT ALL ON DATABASE` + `GRANT ALL ON SCHEMA public` to the role, so the role is not the owner of the
#   public schema's database. Note PostgreSQL 15+ no longer lets non-owners create tables in schema public.
#   In both modes the Gradle tasks createUnitTestDatabases still use the hardcoded role `test` (as in CI,
#   where it is the role); that is harmless. `destroy` drops the databases and then the role. The mode is
#   remembered in <taskhome>/.pg-role so reset/drop/destroy/env/status need no flag.
#
# Environment overrides: IM_PG_HOST (localhost), IM_PG_PORT (5432), IM_PG_USER/IM_PG_PWD (test/test),
#   IM_PG_SUPERUSER/IM_PG_SUPERPWD (postgres/postgres), IM_TASKHOMES (/home/agent/taskhomes),
#   IM_REAL_HOME (/home/agent), IM_PG_ROLE_MODE (1|owner|ci, same as --role / --role-ci). If IM_PG_PORT is not 5432, "db.X.datasource.port=" lines are added.
#
# Caveats (see baselines/intermine-2026-11-15.md):
#   - Gradle's createUnitTestDatabases tasks in intermine/testresources and bio/testresources still
#     create the *unsuffixed* DB names via `sudo -u postgres psql -h localhost` (port 5432). Those
#     stay empty because the tests use the suffixed names from the properties; harmless.
#   - Java's user.home comes from /etc/passwd, not $HOME, so Maven (~/.m2) resolves to the real home
#     anyway; the .m2 symlink makes the task home self-consistent for tools that use $HOME. Gradle is
#     steered by GRADLE_USER_HOME (above), not by user.home.
set -euo pipefail

usage() { sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }
[ $# -ge 1 ] || usage
TASK_ID=$1; shift
CMD=create
SRC=
ROLE_MODE=
case ${IM_PG_ROLE_MODE:-} in ''|0) ;; 1|owner) ROLE_MODE=owner ;; ci) ROLE_MODE=ci ;; *) echo "bad IM_PG_ROLE_MODE: $IM_PG_ROLE_MODE" >&2; exit 2 ;; esac
while [ $# -gt 0 ]; do
  case $1 in
    create|reset|drop|destroy|env|status) CMD=$1 ;;
    --src) SRC=$2; shift ;;
    --role) ROLE_MODE=owner ;;
    --role-ci) ROLE_MODE=ci ;;
    -h|--help) usage ;;
    *) echo "unknown argument: $1" >&2; usage ;;
  esac
  shift
done

ROOT=/Users/gos/claude_projects/update_intermine_planning
REAL_HOME=${IM_REAL_HOME:-/home/agent}
TASKHOMES=${IM_TASKHOMES:-/home/agent/taskhomes}
PG_HOST=${IM_PG_HOST:-localhost}
PG_PORT=${IM_PG_PORT:-5432}
PG_USER=${IM_PG_USER:-test}
PG_PWD=${IM_PG_PWD:-test}
PG_SUPER=${IM_PG_SUPERUSER:-postgres}
PG_SUPERPWD=${IM_PG_SUPERPWD:-postgres}

SAN=$(printf '%s' "$TASK_ID" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g; s/__*/_/g; s/^_//; s/_$//')
[ -n "$SAN" ] || { echo "task id sanitises to empty string" >&2; exit 2; }
SUFFIX=_$SAN
TH=$TASKHOMES/$TASK_ID
PROPS=$TH/.intermine
GRADLE_HOME_TASK=$TH/.gradle
ROLE_FILE=$TH/.pg-role
OLD_ROLE= OLD_MODE=
if [ -f "$ROLE_FILE" ]; then read -r OLD_MODE OLD_ROLE < "$ROLE_FILE" || true; fi
# the mode is chosen by `create`; every other command follows what create recorded
if [ "$CMD" != create ]; then ROLE_MODE=$OLD_MODE; fi
ROLE=
if [ -n "$ROLE_MODE" ]; then
  case $SAN in im_*) ROLE=$SAN ;; *) ROLE=im_$SAN ;; esac
  PG_USER=$ROLE
  PG_PWD=${IM_PG_PWD:-test}
fi

if [ -z "$SRC" ]; then
  top=$(git rev-parse --show-toplevel 2>/dev/null || true)
  if [ -n "$top" ] && [ -f "$top/config/ci.properties" ] && [ -f "$top/config/lib/install_intermine.py" ]; then
    SRC=$top
  else
    SRC=$ROOT/repos/intermine
  fi
fi

psql_super() {
  PGPASSWORD=$PG_SUPERPWD PGOPTIONS='-c client_min_messages=warning' psql -X -q -v ON_ERROR_STOP=1 -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPER" -d postgres "$@"
}

# databaseName values of the generated property files (one per line, unique)
db_names() {
  ls "$PROPS"/*.properties >/dev/null 2>&1 || return 0
  sed -n 's/^[[:space:]]*db\.[^=]*\.datasource\.databaseName[[:space:]]*=[[:space:]]*//p' "$PROPS"/*.properties \
    | sed 's/[[:space:]]*$//' | sort -u
}

drop_dbs() {
  local db
  for db in $(db_names); do
    # refuse to touch anything that is not suffixed for this task
    case $db in *"$SUFFIX") ;; *) echo "refusing to drop unsuffixed DB '$db'" >&2; continue ;; esac
    psql_super -c "DROP DATABASE IF EXISTS \"$db\" WITH (FORCE);" >/dev/null
    echo "dropped $db" >&2
  done
}

# Task role (role mode only). Safe to call repeatedly; refuses names that are not im_*.
ensure_role() {
  [ -n "$ROLE" ] || return 0
  case $ROLE in im_?*) ;; *) echo "refusing role '$ROLE'" >&2; exit 1 ;; esac
  local attrs='LOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB'
  [ "$ROLE_MODE" = owner ] && attrs='LOGIN NOSUPERUSER NOCREATEROLE CREATEDB'
  if psql_super -tA -c "select 1 from pg_roles where rolname='$ROLE'" | grep -q 1; then
    psql_super -c "ALTER ROLE \"$ROLE\" $attrs PASSWORD '$PG_PWD';" >/dev/null
  else
    psql_super -c "CREATE ROLE \"$ROLE\" $attrs PASSWORD '$PG_PWD';" >/dev/null
    echo "created role $ROLE ($ROLE_MODE)" >&2
  fi
}

drop_role() {  # drop_role <role>: the databases are gone by now, so nothing is left to own
  case ${1:-} in im_?*) ;; *) return 0 ;; esac
  psql_super -c "DROP ROLE IF EXISTS \"$1\";" >/dev/null
  echo "dropped role $1" >&2
}

create_dbs() {
  local db
  ensure_role
  for db in $(db_names); do
    case $db in *"$SUFFIX") ;; *) echo "refusing to create unsuffixed DB '$db'" >&2; exit 1 ;; esac
    if [ "$ROLE_MODE" = ci ]; then
      # as testresources' createUnitTestDatabases: postgres owns the DB, the role only gets grants
      psql_super -c "CREATE DATABASE \"$db\";" >/dev/null
      psql_super -c "GRANT ALL PRIVILEGES ON DATABASE \"$db\" TO \"$ROLE\";" >/dev/null
      psql_super -d "$db" -c "GRANT ALL ON SCHEMA public TO \"$ROLE\";" >/dev/null
    else
      psql_super -c "CREATE DATABASE \"$db\" OWNER \"$PG_USER\";" >/dev/null
    fi
    echo "created $db" >&2
  done
}

gen_props() {
  local src_name=$1 dest_name=$2 src_file=$SRC/config/$1
  [ -f "$src_file" ] || { echo "missing $src_file" >&2; exit 1; }
  {
    echo "# FILE AUTOMATICALLY GENERATED by im-testenv.sh $TASK_ID FROM $src_file. DO NOT EDIT!"
    sed -e "s/PSQL_HOST/$PG_HOST/g" -e "s/PSQL_USER/$PG_USER/g" -e "s/PSQL_PWD/$PG_PWD/g" \
        -e "s/^\([[:space:]]*db\.[^=]*\.datasource\.databaseName[[:space:]]*=[[:space:]]*[^[:space:]]*\)[[:space:]]*$/\1$SUFFIX/" \
        "$src_file"
    if [ "$PG_PORT" != 5432 ]; then
      echo
      echo "# non-default Postgres port"
      sed -n 's/^[[:space:]]*\(db\.[^=]*\.datasource\.\)serverName[[:space:]]*=.*/\1port='"$PG_PORT"'/p' "$src_file"
    fi
  } > "$PROPS/$dest_name"
  echo "written $PROPS/$dest_name" >&2
}

env_lines() {
  cat <<EOF
export HOME=$TH
export GRADLE_USER_HOME=$GRADLE_HOME_TASK
export IM_TASK_ID=$TASK_ID
export IM_TASK_HOME=$TH
export IM_DB_SUFFIX=$SUFFIX
export IM_PG_PORT=$PG_PORT
export PSQL_HOST=$PG_HOST
export PSQL_USER=$PG_USER
export PSQL_PWD=$PG_PWD
EOF
  [ -z "$ROLE_MODE" ] || echo "export IM_PG_ROLE=$ROLE"
}

# Task-private GRADLE_USER_HOME: own daemon registry, shared caches/wrapper/jdks (see header).
setup_gradle_home() {
  local d
  if [ -L "$GRADLE_HOME_TASK" ]; then
    # old layout: .gradle -> shared dir. Replace by a real dir (never touches the link target).
    case $(readlink "$GRADLE_HOME_TASK") in "$REAL_HOME/.gradle"|"$REAL_HOME/.gradle/") rm "$GRADLE_HOME_TASK" ;;
      *) echo "$GRADLE_HOME_TASK is a symlink to somewhere else; leaving it" >&2; return ;; esac
  fi
  mkdir -p "$GRADLE_HOME_TASK"
  for d in caches wrapper jdks; do
    mkdir -p "$REAL_HOME/.gradle/$d"
    if [ -L "$GRADLE_HOME_TASK/$d" ]; then continue; fi
    if [ -e "$GRADLE_HOME_TASK/$d" ]; then echo "$GRADLE_HOME_TASK/$d exists and is not a symlink; leaving it" >&2; continue; fi
    ln -s "$REAL_HOME/.gradle/$d" "$GRADLE_HOME_TASK/$d"
  done
}

link_cache() {
  local name=$1
  mkdir -p "$REAL_HOME/$name"
  if [ -L "$TH/$name" ]; then return; fi
  if [ -e "$TH/$name" ]; then echo "$TH/$name exists and is not a symlink; leaving it" >&2; return; fi
  ln -s "$REAL_HOME/$name" "$TH/$name"
}

case $CMD in
  create)
    command -v psql >/dev/null || { echo "psql not found" >&2; exit 1; }
    psql_super -c 'select 1' >/dev/null || { echo "cannot connect to Postgres $PG_HOST:$PG_PORT as $PG_SUPER" >&2; exit 1; }
    mkdir -p "$PROPS"
    setup_gradle_home
    link_cache .m2
    drop_dbs                      # drop DBs named by any previous properties first
    # a previous create may have used another role (or none): free it before the new mode takes over
    if [ -n "$OLD_ROLE" ] && [ "$OLD_ROLE" != "$ROLE" ]; then drop_role "$OLD_ROLE"; fi
    if [ -n "$ROLE_MODE" ]; then echo "$ROLE_MODE $ROLE" > "$ROLE_FILE"; else rm -f "$ROLE_FILE"; fi
    gen_props ci.properties        intermine-test.properties
    gen_props ci-bio.properties    intermine-bio-test.properties
    gen_props testmodel.properties testmodel.properties
    drop_dbs
    create_dbs
    env_lines > "$TH/env.sh"
    echo "env file: $TH/env.sh (source it, or eval this script's stdout)" >&2
    env_lines
    ;;
  reset)  drop_dbs; create_dbs ;;
  drop)   drop_dbs ;;
  destroy)
    drop_dbs
    drop_role "$OLD_ROLE"
    case $TH in "$TASKHOMES"/?*) rm -rf "$TH"; echo "removed $TH" >&2 ;; esac
    ;;
  env)    env_lines ;;
  status)
    for db in $(db_names); do
      if psql_super -tA -c "select 1 from pg_database where datname='$db'" | grep -q 1; then echo "present $db"; else echo "MISSING $db"; fi
    done
    if [ -n "$ROLE" ]; then
      if psql_super -tA -c "select 1 from pg_roles where rolname='$ROLE'" | grep -q 1; then echo "present role $ROLE ($ROLE_MODE)"; else echo "MISSING role $ROLE"; fi
    fi
    ;;
esac
