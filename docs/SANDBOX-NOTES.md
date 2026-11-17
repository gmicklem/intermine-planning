# Sandbox notes (agent environment)

Things about the sandbox that are not derivable from the repositories. Updated 16 Nov 2026.

## Worker agents hanging on permission prompts (im-8dd.8)

Four workers were lost before the cause was understood: a Bash call that does not match the
allow rules in `repos/.claude/settings.local.json` raises a permission prompt nobody can answer,
and the worker waits for ever. Rules now in `CLAUDE.md` and every worker brief:

- `rm` only with absolute paths (never `./*`), under `/home/agent/taskhomes/`, `/tmp/claude-1000/` or
  the worker's own worktree.
- Allow rules match the command prefix: never put `env VAR=x`, `VAR=x`, `cd dir &&`, `time`, `sudo`
  or `nice` in front of an allowed command; export variables on their own line first.
- Long jobs through the Bash tool's `run_in_background`, never `nohup ... &` plus sleep.
- Never `gradle --stop` with another task's env (per-task `GRADLE_USER_HOME` since 16 Nov).
- Never `pkill -f` on a pattern that could match the caller's own shell (it did, once, to the orchestrator).

Detection: the orchestrator runs a Monitor that parses the last `"timestamp"` in each worker's
transcript JSONL (file mtime is unreliable on the mount) and reports 20 to 25 minutes of silence.
Recovery: `TaskStop` the agent, then `SendMessage` to the same id (it resumes with its context)
naming the call that hung and asking it to redo it with absolute paths.

## Cypress on the sandbox (im-rkn.10)

Cypress' Electron needs Xvfb and GTK libraries that the base image lacks. A worker extracted the
Debian packages into `/home/agent/tools/cypress-sysdeps/` (`root/` tree, `bin/`, `env.sh` to source);
`scripts/gate-bluegenes.sh` and the workers' Cypress helper scripts source that file. The proper fix
on a new sandbox is `apt-get install xvfb libgtk-3-0t64 libgbm1 libxss1` (names for Ubuntu 26.04).

## Other

- Memory: 15 GB. At most two Gradle gates (about 5 GB each) plus the two demo stacks (about 3 GB
  each); the rdfc2im rebuild peaks at 9 GB and waits for 6 GB free.
- Root overlay disk: 20 GB. Eight concurrent workers filled it on 16 Nov; worker briefs now ask for
  `df -h /` >= 2.5 GB before a build and build-dir deletion afterwards. Large scratch data lives under
  `repos/.sandbox-disk/` (the host mount).
- Test environments: `scripts/im-testenv.sh <id> create|env|destroy --src DIR` (per-task Postgres
  databases, `~/.intermine` properties, `GRADLE_USER_HOME` with shared caches; `--role` / `--role-ci`
  non-superuser modes).
- GitHub: pushes as gmicklem through the sandbox proxy; `gh api user` is checked before every remote
  operation. Push events never fire the intermine workflows on the fork: dispatch
  `im-build.yml` and `checkstyle.yml` with `gh workflow run --ref <branch>`; the concurrency group
  cancels an in-progress run when a newer one starts on the same branch.

## Long-lived servers started from the Bash tool

A `run_in_background` Bash call is killed when its timeout (max 10 min) expires, taking a foreground
server with it (the first registry demo on port 3300 died that way on 17 Nov). Start daemons as
`nohup <cmd> > log 2>&1 & disown` from a short foreground call instead; socat forwarders and the
BlueGenes/registry demo servers all run that way now (restart recipes in
`/home/agent/taskhomes/im-bg-serve/README.txt`).
