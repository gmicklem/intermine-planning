---
name: sandbox-environment-notes
description: Sandbox quirks - 15 GB RAM cap, blocked hosts, GitHub token identity check, host-mount fsync clone failures
metadata:
  type: project
---

- Sandbox VM (`sbx run claude .`, name `claude-repos`) has 15 GB RAM and 10 cores, not the Mac's 32 GB. Cap: 2 concurrent intermine test runs, rdfc2im stack (9 GB peak) alone.
- GitHub token is a sandbox secret; it once authenticated as intermineorg. Always check `gh api user --jq .login` == gmicklem before pushing.
- Hosts needing `sbx policy allow network`: repo1.maven.org and intermine.org were allowed 15 Nov 2026; www.intermine.org, api.adoptium.net, oss.sonatype.org, jitpack.io still blocked. intermine.org https has a TLS failure; http works.
- Cloning some repos onto the host mount fails with "fsync error ... Directory not empty"; use `git -c core.fsync=none clone` or clone under /home/agent and move.
- The sandbox root overlay is only 20 GB and fills up: each intermine task env (private ~/.m2 repo + 10 Postgres DBs) costs ~0.3-0.5 GB and Docker images/caches add up. At every checkpoint destroy task envs of merged tasks (`scripts/im-testenv.sh <id> destroy`) and prune merged worktrees.
- JDKs come from apt (openjdk-8/11/17/21); sdkman/adoptium are blocked.

**Why:** Each of these cost time to discover.
**How to apply:** Check before assuming a tool or host works. Related: [[intermine-maintenance-sprint]].

**Disk layout (found 15 Nov 2026):** only `/Users/gos/claude_projects/update_intermine_planning/repos` is the host virtiofs mount (641 GB free). `worktrees/`, `transcript.md` at the project top level, `/home/agent` and `/var/lib/docker` are all on the sandbox's 20 GB root overlay and invisible on the Mac. The transcript is therefore written to `repos/transcript.md` (top-level `transcript.md` is a symlink). Large scratch data (rdfc2im TRIAL_HOME, compose volumes) goes under `repos/.sandbox-disk/`. Loop devices do not exist in the VM kernel (no /dev/loop-control), so a loopback disk image is not an option; the root overlay cannot be grown from inside a running sandbox.

**Cypress in the sandbox (15 Nov 2026):** Cypress 13.17.0 arm64 binary installs once download.cypress.io and cdn.cypress.io are allowed (they are now). Electron needs Xvfb/GTK libs that are not installed; a worker extracted them to `/home/agent/tools/cypress-sysdeps` and `. /home/agent/tools/cypress-sysdeps/env.sh` must be sourced before `npx cypress run`. Playwright's own Chromium needs `PLAYWRIGHT_HOST_PLATFORM_OVERRIDE=ubuntu24.04-arm64` and 8 apt libs; the third-party Chromium at /home/agent/browser-scratch works with `--disable-dev-shm-usage` (/dev/shm is 64 MB).

**DNS inside the sandbox is a proxy placeholder:** every external host resolves to 133.39.78.111; the proxy does the real lookup. Identical IPs for different hosts mean nothing. The flymine/humanmine/rdfportal outage on 15 Nov 2026 (~03:40-12:30 UTC) was the sites themselves; they came back at ~12:30.

**`sed -i` on the virtiofs mount recreates the file with mode 0600** (loses the executable bit, and git then commits 100644). After any in-place edit of a script under repos/, run `chmod +x` before committing.
- npm 10.9.2 installed globally 15 Nov 19:05 UTC (/usr/local/bin/npm; Debian npm 9.2.0 cannot read the bluegenes xmldom alias override)

- cdn.jsdelivr.net and cdn.intermine.org approved by Gos 16 Nov 2026. cdn.intermine.org is DEAD (Gos; 502 from the sandbox): never treat it as a dependency to allow, treat references to it as bugs to remove.

- 16 Nov 2026: im-testenv.sh gives each task its own GRADLE_USER_HOME (caches/wrapper/jdks symlinked to /home/agent/.gradle); gate-intermine.sh refuses to run with the shared Gradle home unless GATE_ALLOW_REAL_HOME=1, so orchestrator re-gates must source a task env (im-testenv.sh <id> create --src WT; eval "$(im-testenv.sh <id> env)"). `gradle --stop` with a task's own env aborts its running gate.

- 16 Nov 2026 18:35 UTC: push URLs of every remote pointing at github.com/intermine/* or intermineorg/* are set to DISABLED_UPSTREAM_PUSH in all checkouts (Gos's account has admin on upstream, so a plain `git push origin` would have reached InterMine). Fetch still works. Re-enable with `git remote set-url --push <remote> <url>` only when Gos opens upstream PRs.

- 18 Nov 2026: `/var/lib/docker` is its OWN 10 GB volume (/dev/vdd), not the root overlay: pruning Docker
  images or build cache does not free the root disk. Root-disk hogs are worktree copies of rdfc2im
  `in/` + `out/` (about 950 MB per build worktree), the session scratchpad under /tmp/claude-1000
  (workers leave extracted tarballs and test builds: 2.9 GB found, including the PREVIOUS session's
  directory), /home/agent/.gradle (3.9 GB, needed) and package caches. Clean worker scratch after each
  merge; tell workers to put large scratch under repos/.sandbox-disk/.
