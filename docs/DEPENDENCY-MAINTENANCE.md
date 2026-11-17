# Dependency maintenance: design for a daily, mostly automatic routine

Status: proposal, 17 Nov 2026. Author: orchestrator, for Gos. Decision needed on the tool (section 3)
and the automerge policy (section 5).

## 1. What each repository depends on, and what can watch it

| Repository (gmicklem fork) | Manifests | CI today | Dependabot can read | Renovate can read |
|---|---|---|---|---|
| intermine | Gradle, `gradle/libs.versions.toml` + 7 builds; GitHub Actions | im-build.yml, checkstyle.yml (push + dispatch only; push never fires on the fork, so dispatched by hand) | gradle (catalog supported), github-actions | gradle, github-actions |
| bluegenes | `deps.edn` (Clojure/ClojureScript), `package.json` (npm), Dockerfile, Actions | ci.yml (push + PR), nightly-cypress.yml (schedule, now live) | npm, github-actions, docker; **not deps.edn** | clojure (deps.edn), npm, docker, github-actions |
| imcljs | `deps.edn`, `project.clj`, `package.json` (dev), shadow-cljs | none | npm only | clojure, leiningen, npm |
| im-tables-3 | same as imcljs | none | npm only | clojure, leiningen, npm |
| bluegenes-tool-store | `deps.edn`, `project.clj` | none | nothing | clojure, leiningen |
| intermine-registry | `deps.edn`, Dockerfile, Actions | ci.yml (push + PR) | docker, github-actions; **not deps.edn** | clojure, docker, github-actions |
| humanmine, flymine | `build.gradle` (imVersion/bioVersion pins), Actions | none | gradle | gradle |
| humanmine-/flymine-bio-sources | `build.gradle`, Actions | build.yml (push) | gradle, github-actions | gradle, github-actions |
| mine-tests | `requirements.txt` (pytest, Playwright), Actions | nightly.yml | pip, github-actions | pip, github-actions |
| rdfc2im | `requirements.txt`, compose images | none | pip, docker | pip, docker-compose |
| intermine-planning | Python scripts, no manifest | none | nothing to watch | nothing to watch |

So every repository except the planning repo has something to watch, but the two tools differ on
the one ecosystem that matters most for the front end: **GitHub's Dependabot does not read
`deps.edn` or `project.clj`**, and GitHub's dependency graph does not either, so Dependabot
*alerts* will never mention a vulnerable Clojure library (the sprint found them by querying the
Advisory Database by hand: clojure 1.10.1, clj-http's bundled HttpClient, commons-compress in the
tool store, Jetty 9.4 under Ring). Renovate reads all of them.

## 2. What a "maintenance action" has to do

For a bump to be safe it must pass the same gate a human change passes: intermine's full test
suite (about 45 min on Actions), BlueGenes' unit tests + release build (+ Cypress nightly for
anything touching reagent/re-frame/React), the registry's tests, the forks' mine builds. That gate
already exists as CI on four repositories; it does not exist yet as a pull-request trigger on
intermine (push/dispatch only), nor at all on imcljs, im-tables-3, the tool store, humanmine,
flymine, rdfc2im. Automation is only as good as the gate, so step one is gates, not bots.

## 3. Tool: Renovate, with Dependabot alerts kept on

Recommendation: install the **Renovate GitHub App** (Mend; free for public repositories) on the
gmicklem account for the eleven repositories above, with one shared configuration preset kept in
this planning repository, and keep **Dependabot alerts** enabled as a second opinion for npm/
Gradle/pip advisories (they cost nothing and reach Gos by email).

Why Renovate and not Dependabot version updates:
- It covers deps.edn and Leiningen; Dependabot cannot, and Clojure is where BlueGenes lives.
- One config for all repositories (`extends` a preset), grouping (all `org.clojure/*` in one PR,
  all Gradle plugins in one PR), schedules, and automerge rules per package pattern.
- It can pin Clojars git-sha dependencies and version catalogs, and it rebases its PRs itself.
- Lock-file maintenance for npm (`package-lock.json`) as a weekly PR.

Why not a scheduled Claude agent as the *first* line: an agent costs about 28 min of Sonnet per
bump (sprint median over 32 runs; 90th percentile 62 min) and the majority of bumps are
mechanical. The agent is the second line (section 6), for the bumps that fail the gate.

## 4. Rollout steps

1. **Gates on pull requests** (agent work, one bead each):
   - intermine: add `pull_request` (and `schedule: weekly`) to im-build.yml and checkstyle.yml with
     path filters so docs-only PRs skip the 45-minute build; keep the concurrency group.
   - imcljs, im-tables-3, bluegenes-tool-store: add ci.yml running the existing gate scripts
     (`scripts/gate-im-tables.sh`, `gate-tool-store.sh` equivalents: cljfmt check, unit tests,
     release build) on push and pull_request.
   - humanmine, flymine: a build workflow that builds the mine's dbmodel against the published
     intermine artefacts (like the bio-sources forks' build.yml) on pull_request.
   - mine-tests, rdfc2im: a lint + unit/pytest job (`pytest -m "not live"`) on pull_request.
2. **Renovate preset** in intermine-planning: `renovate/default.json` with
   `extends: ["config:recommended", ":semanticCommitsDisabled", "group:allNonMajor"]`, schedule
   "before 6am on Monday" for version bumps and "at any time" for security bumps, `labels:
   ["dependencies"]`, Clojure grouping, `ignoreDeps` for the deliberately pinned ones (e.g. reagent
   stays at 1.2.0 until decision 0007 is lifted; bootstrap 3 until BlueGenes moves), `rangeStrategy:
   pin` for npm. Each repository gets a two-line `renovate.json` that extends it.
3. **Human steps (Gos)**: install the Renovate app (GitHub Marketplace, "Renovate", choose the
   eleven repositories); enable "Allow auto-merge" in each repository's settings; add a branch
   protection rule on `maint-2026` requiring the CI check to pass. Dependabot alerts: already on.
4. **First week**: Renovate opens its onboarding PR per repository; merge after reading its
   dependency dashboard; expect a burst of PRs on day one (the inventories list roughly 20 bumps in
   intermine and 15 in the BlueGenes family that are minor/patch-level).
5. **Measure** (section 7) for two weeks, then decide the automerge policy.

## 5. Automerge policy (proposal, start conservative)

| Class | Example | Action |
|---|---|---|
| GitHub Actions versions | `actions/checkout` v4 to v5 | automerge when CI green |
| npm devDependencies patch/minor | eslint, less | automerge when CI green |
| Java/Clojure patch releases | jackson 2.18.11 to 2.18.12, ring 1.13.0 to 1.13.1 | automerge when CI green |
| Minor releases of libraries with an API surface in our code | Jena, solrj, re-frame, Postgres JDBC | PR waits for a human or the agent |
| Majors | Cypress 16, Jena 5, Jetty 12 via Ring, reagent 2 | PR opened, labelled `major`, never automerged; becomes a bead |
| Security (any level) | | PR opened immediately regardless of schedule; patch/minor automerge; major to the agent |

"Automerge" means Renovate merges when the required check is green and the PR has sat for the
configured minimum age (`minimumReleaseAge: 3 days` guards against pulled releases and
supply-chain attacks on freshly published versions; the sprint's vetting rule in
decisions/package-vetting.md stays for any *replacement* package, which Renovate never proposes).

## 6. The agent stage (second line)

A scheduled Claude Code routine (cloud, daily at 06:30 UK, the `schedule` facility) or, while the
sandbox exists, a `/loop` here, with this brief: list open Renovate PRs across the eleven
repositories whose CI is red; for each, in a worktree, read the failure, make the smallest change
that lets the bump pass the gate (a changed API, a transitive conflict, a test fixture), push to the
Renovate branch, re-run the gate; report in one message per day what was fixed, what it could not
fix (which becomes a bead), and the time and tokens spent. It never merges: merging stays with
Renovate's rules or with Gos. Expected volume from the sprint's experience: one or two red PRs a
week, 30 to 60 minutes each. A cloud routine does not depend on the laptop being awake; the sandbox
loop does.

## 7. What to measure (to decide whether it is worth it)

`scripts/dependency-prs.py` (to write): for every PR labelled `dependencies` across the forks,
record opened-at, first-green-at, merged-at, who merged (Renovate, Gos, agent), and for agent fixes
the run's minutes and tokens from status/agent-runs.csv. Hourly status gains a line: "dependency
PRs: N open, M red, median time-to-merge". After two weeks: PRs per week, share automerged, share
needing the agent, agent minutes per week, and the number of advisories still open. If the agent
share is below one PR a week the routine can run weekly instead of daily.

## 8. What has no dependencies, or should stay manual

- intermine-planning: scripts only; nothing to watch.
- The `intermine.development.*` artefacts and the bio-sources forks' `imVersion` pins are
  *ours*; Renovate must not bump them (ignore pattern `org.intermine:*`), releases do that.
- Tomcat/Postgres/Solr images in docker_template and rdfc2im: watched (docker manager) but never
  automerged; a database or search-server major is a deployment decision.
