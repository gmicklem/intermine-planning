#!/usr/bin/env bash
# im-testenv.sh - isolated InterMine test environment (private HOME + private Postgres DBs) for one task.
#
# Usage:
#   im-testenv.sh <task-id> [create|reset|drop|destroy|env|status] [--src <intermine-checkout>]
#
#   create   (default) make the task home, (re)write ~/.intermine/*.properties, drop+create the
#            task's databases, write <taskhome>/env.sh and print the export lines.
#   reset    drop and re-create the task's databases only (properties untouched).
#   drop     drop the task's databases.
#   destroy  drop the task's databases and delete the task home.
#   env      print the export lines (does not touch anything).
#   status   list the task's databases that currently exist.
#
#   --src DIR  intermine checkout whose config/ci.properties, config/ci-bio.properties and
#              config/testmodel.properties are used as templates. Default: the worktree you are in
#              (if it is an intermine checkout), else repos/intermine (read only).
#
# Typical use by a worker:
#   eval "$(scripts/im-testenv.sh im-rkn.3 create --src "$WT")"   # or: source <taskhome>/env.sh
#   scripts/gate-intermine.sh "$WT"
#   scripts/im-testenv.sh im-rkn.3 destroy                         # when the task is finished
#
# What it produces (task id "im-rkn.3" -> suffix "_im_rkn_3"):
#   /home/agent/taskhomes/im-rkn.3/
#     .gradle -> /home/agent/.gradle     (shared Gradle caches + wrapper dists)
#     .m2     -> /home/agent/.m2         (shared Maven local repo)
#     .intermine/intermine-test.properties      (from config/ci.properties)
#     .intermine/intermine-bio-test.properties  (from config/ci-bio.properties)
#     .intermine/testmodel.properties           (from config/testmodel.properties)
#     env.sh                                    (export HOME=... PSQL_*=... IM_*=...)
#   These are exactly the three files config/lib/install_intermine.py copies into ~/.intermine, with
#   the same names, so install_intermine.py (and config/ci/init.sh) see them as already present and
#   skip them ("Skipping ... as it already exists"). PSQL_HOST/USER/PWD are substituted as
#   install_intermine.py does, and every db.*.datasource.databaseName gets the suffix, e.g.
#   unittest -> unittest_im_rkn_3, userprofile-test -> userprofile-test_im_rkn_3,
#   bio-test -> bio-test_im_rkn_3. The databases created are exactly the databaseName values found
#   in the generated files (10 DBs), owned by the DB user (test).
#
# Environment overrides: IM_PG_HOST (localhost), IM_PG_PORT (5432), IM_PG_USER/IM_PG_PWD (test/test),
#   IM_PG_SUPERUSER/IM_PG_SUPERPWD (postgres/postgres), IM_TASKHOMES (/home/agent/taskhomes),
#   IM_REAL_HOME (/home/agent). If IM_PG_PORT is not 5432, "db.X.datasource.port=" lines are added.
#
# Caveats (see baselines/intermine-2026-11-15.md):
#   - Gradle's createUnitTestDatabases tasks in intermine/testresources and bio/testresources still
#     create the *unsuffixed* DB names via `sudo -u postgres psql -h localhost` (port 5432). Those
#     stay empty because the tests use the suffixed names from the properties; harmless.
#   - Java's user.home comes from /etc/passwd, not $HOME, so Gradle/Maven caches resolve to the real
#     home anyway; the symlinks make the task home self-consistent for tools that use $HOME.
set -euo pipefail

usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 2; }
[ $# -ge 1 ] || usage
TASK_ID=$1; shift
CMD=create
SRC=
while [ $# -gt 0 ]; do
  case $1 in
    create|reset|drop|destroy|env|status) CMD=$1 ;;
    --src) SRC=$2; shift ;;
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

create_dbs() {
  local db
  for db in $(db_names); do
    case $db in *"$SUFFIX") ;; *) echo "refusing to create unsuffixed DB '$db'" >&2; exit 1 ;; esac
    psql_super -c "CREATE DATABASE \"$db\" OWNER \"$PG_USER\";" >/dev/null
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
export IM_TASK_ID=$TASK_ID
export IM_TASK_HOME=$TH
export IM_DB_SUFFIX=$SUFFIX
export IM_PG_PORT=$PG_PORT
export PSQL_HOST=$PG_HOST
export PSQL_USER=$PG_USER
export PSQL_PWD=$PG_PWD
EOF
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
    link_cache .gradle
    link_cache .m2
    drop_dbs                      # drop DBs named by any previous properties first
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
    case $TH in "$TASKHOMES"/?*) rm -rf "$TH"; echo "removed $TH" >&2 ;; esac
    ;;
  env)    env_lines ;;
  status)
    for db in $(db_names); do
      if psql_super -tA -c "select 1 from pg_database where datname='$db'" | grep -q 1; then echo "present $db"; else echo "MISSING $db"; fi
    done
    ;;
esac
