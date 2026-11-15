# Whole-system testbed: rdfc2im, docker_template and mine-tests

This document describes the whole-system testbed for InterMine: `rdfc2im`, which builds a working HumanMine-style mine in roughly 5-12 minutes, `docker_template`, which is the production deployment template, and `mine-tests`, which tests a deployed mine by URL. It records what each does and what it needs, the sandbox and network figures that constrain running it, workstream G (making the testbed consume locally built back-end artefacts), and why the testbed is the end-to-end acceptance test for back-end changes.

Related: [00-overview.md](00-overview.md) (master plan), [10-intermine-backend.md](10-intermine-backend.md) (the changes the testbed accepts), [20-bluegenes.md](20-bluegenes.md) (BlueGenes will use this stack's mine for Cypress), [40-agent-execution.md](40-agent-execution.md) (concurrency limits and schedule).

## Findings

- **rdfc2im**: `rdfc2im/tools/full-build.sh` (18 phases, documented in `BUILD.md`) builds a HumanMine-style mine from RDF Portal into its own Compose stack (`rdfc2im/trial/docker-compose.yml`): webapp on :8090, BlueGenes on :5000, Postgres on :15432, Solr on :8983.
  - It needs JDK 8, the Gradle 4.9 zip, Docker Compose v2, a Python venv, and network access to rdfportal.org, togovar, NLM and reactome.
  - It takes about 5 minutes warm and about 12 minutes with a fresh cache, with a 9 GB peak RAM.
  - It consumes **published** `org.intermine` 5.0.8 artefacts from Maven. Testing *our* back-end changes therefore requires pointing it at locally built artefacts (mavenLocal) and our webapp war.
- **docker_template** is the production deployment template (HumanMine/FlyMine). It is not the 5-minute path.
- **mine-tests** (pytest plus Playwright 1.58) tests a deployed mine by URL, configured through `mines.toml` and `--url-override`.

## Sandbox resources and network

- Sandbox: Ubuntu 26.04 arm64 VM, 10 cores, **15 GB RAM** (not the Mac's 32), 653 GB free on the project mount, passwordless sudo, Docker 29, Go 1.27, Node 22, Python 3.14, JDK 25 only. apt has openjdk-8/11/17/21, postgresql-18, leiningen 2.11.2 and chromium.
- The rdfc2im stack peaks at 9 GB, so it runs alone (see the concurrency limits in [40-agent-execution.md](40-agent-execution.md)).
- Reachable: GitHub, clojars, repo.maven.apache.org, plugins.gradle.org, services.gradle.org, npm, PyPI, Ubuntu apt, Docker Hub, rdfportal.org, humanmine.org, flymine.org.
- Blocked at the time of planning, pending approval: `repo1.maven.org` (intermine's configured Maven Central URL), `intermine.org` (contribution guide), `download.clojure.org`, `api.adoptium.net`, `oss.sonatype.org`, `jitpack.io`. Gos has since run the approval for `repo1.maven.org`, `intermine.org` and `download.clojure.org`.
- Public HumanMine and FlyMine are approved for read-only use in tests.

## Baseline (Epic A, testbed part)

Run `rdfc2im/tools/full-build.sh`, then `make test-live` and `mine-tests` with `--url-override`. Record time and failures in `baselines/`. Cache `cached_raw_data/` for reuse.

## Workstream G. Whole-system testbed

- Make `rdfc2im/tools/full-build.sh` consume local `org.intermine` artefacts (`mavenLocal()` / `intermine.development.*` dirs) and the webapp war from a given intermine worktree, through a flag `--intermine-src DIR`.
- Run `mine-tests` against the local stack, and add fixtures for the demo mine (a `mines.toml` entry named `local`).
- This is the end-to-end acceptance test for the back-end workstreams B and C: "modernised intermine builds the demo mine and mine-tests pass".

## How the testbed is used as acceptance

- Per-task gates for intermine (Gradle builds and unit tests, see [10-intermine-backend.md](10-intermine-backend.md)) are fast and local. The testbed is the heavier check on top.
- Once G lands, every merge to `maint-2026` for intermine also runs `rdfc2im/tools/full-build.sh --intermine-src` plus `make test-live` plus `mine-tests`.
- The baseline of passing tests recorded from the unmodified stack is the reference; no regression is allowed.
- BlueGenes Cypress tests (workstream F) will target this stack's mine instead of Biotestmine, with a nightly run using a cached rdfc2im build (see [20-bluegenes.md](20-bluegenes.md)).
