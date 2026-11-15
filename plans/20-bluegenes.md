# BlueGenes: maintenance plan

This document covers the maintenance plan for BlueGenes, the ClojureScript front end for InterMine (ClojureScript 1.10.520, lein-cljsbuild, Cypress 6), together with the sibling libraries it depends on (imcljs, im-tables-3, bluegenes-tool-store). BlueGenes is the long-lived asset of the project, so unlike the Java back end it gets a real toolchain modernisation (shadow-cljs, current ClojureScript/re-frame/React, Node LTS, current Cypress). The document lists what was found, the build-tool decision, the two workstreams (toolchain, then tests and CI) and the rules for verifying changes.

Related: [00-overview.md](00-overview.md) (master plan), [10-intermine-backend.md](10-intermine-backend.md), [30-testbed.md](30-testbed.md) (the local mine the Cypress tests will target), [40-agent-execution.md](40-agent-execution.md) (branching, gates, agents, schedule).

## Context

BlueGenes has had almost no maintenance since 2022. The grant application (APP77434, "Scaling InterMine and AllianceMine") makes BlueGenes generate SPARQL and read LinkML/ShACL models, and adds TogoStanza tools. All grant-direction UI work therefore builds on BlueGenes, which is why it deserves a modern toolchain rather than only minimal patches.

## Findings

Repository `repos/bluegenes`: fork `gmicklem/bluegenes` `dev` is identical to upstream `intermine/bluegenes` `dev` at 9f340692; version 1.4.5; the last real change was in Jan 2025.

- **Toolchain**: lein-cljsbuild plus lein-figwheel 0.5.19, re-frame 0.12, reagent 0.10 (React 16 via cljsjs), less 1.7.5, a Node 10 engine pin, Cypress 6.9.1, and ws 7.3.1 (known DoS advisories). CI is CircleCI only (`.circleci/config.yml`); there is no `.github/`.
- **Tests**: 35 kaocha-cljs unit tests that need a real Chrome, and 22 Cypress specs (about 151 tests) run against a local **Biotestmine** at `localhost:9999/biotestmine` (built via `intermine_boot`) plus live FlyMine.
- **Sibling libraries**: BlueGenes depends on `org.intermine/imcljs 1.6.0`, `im-tables 0.15.0` and `bluegenes-tool-store 0.2.3`. These repos were not in the sandbox at the start, so they must be cloned (`intermine/imcljs`, `intermine/im-tables-3`, `intermine/bluegenes-tool-store`, forked under `gmicklem/`). A toolchain modernisation must include them.

## Strategy decision

4. **BlueGenes: migrate to shadow-cljs plus deps.edn**, with current ClojureScript, re-frame 1.4 / reagent 1.2 (React 18), Node 22 and Cypress 13+. CI moves to GitHub Actions with a local mine from the rdfc2im stack, replacing CircleCI and `intermine_boot`. imcljs, im-tables and bluegenes-tool-store are upgraded in lockstep.

The dependency hygiene rules (the weak-dependency census, vetting of replacement packages, and logging in `decisions/package-vetting.md`) also apply to BlueGenes (Clojure, ClojureScript and npm) and to the sibling libraries; they are written out in [10-intermine-backend.md](10-intermine-backend.md). The `dependsOn` rule is Gradle-specific and does not apply here.

## Baseline (Epic A, bluegenes part)

Run `lein cljfmt check`, `lein kaocha` with chromium, and the `lein prod` uberjar, and record the results in `baselines/`. A dependency and CVE inventory for bluegenes (from the project files and the GitHub advisory DB) goes in `inventory/dependencies.md`, and the usage census in `inventory/dependency-usage.md`.

## Workstreams

Each workstream is a beads epic; bullets become issues.

### E. BlueGenes toolchain

- **E1** shadow-cljs plus deps.edn build reproducing the `dev`, `prod` and `kaocha` targets; keep a `lein` shim or document the switch; Node 22; drop `less 1.7.5` for the current lessc; Docker image on temurin 21.
- **E2** Library bumps: ClojureScript current, re-frame 1.4.x, reagent 1.2.x (React 18), reitit, cljs-http/clj-http, ring 1.12, timbre; fix breakage.
- **E3** imcljs / im-tables-3 / bluegenes-tool-store: same toolchain; release to Clojars (a human step) or consume via git deps during the sprint.
- **E4** CDN assets: pin versions with SRI or bundle them; bump vega/vega-lite.
- **E5** Security: ws, wait-on, xmlhttprequest; `npm audit` clean.

### F. BlueGenes tests and CI

- kaocha unit tests green under the new toolchain (headless chromium).
- Cypress 13+ migration (`cy.server/route` -> `cy.intercept`); target the rdfc2im stack's mine instead of Biotestmine (fixtures need re-recording against the demo mine); tag FlyMine-dependent specs `external`.
- GitHub Actions: cljfmt plus kaocha on PR; nightly Cypress using a cached rdfc2im build.

## Verification (bluegenes)

- **Every task**: the gate script passes in the worktree. For bluegenes that is `cljfmt check` plus kaocha plus the prod build (`scripts/gate-bluegenes.sh` in the planning repo). Cypress runs at merge time.
- **Every merge to `maint-2026`**: the full gate on the merged tree.
- **Baselines** in `baselines/` are the reference: no regression in passing test count relative to baseline is allowed.
- **End of sprint**: `maint-2026` of bluegenes (and of the sibling libraries) is pushed and CI is green on GitHub Actions for the integration branch.
