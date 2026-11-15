# 0004. BlueGenes build tool: migrate to shadow-cljs and deps.edn

Status: Accepted, 2026-11-15, decided by Gos Micklem with Claude.

## Context

Facts from `plans/20-bluegenes.md` and `plans/00-overview.md`:

- BlueGenes (`repos/bluegenes`, version 1.4.5) is the long-lived asset. The grant (APP77434) has it
  generate SPARQL, read LinkML/ShACL models and host TogoStanza tools, so all grant-direction UI work
  builds on it.
- Current toolchain: ClojureScript 1.10.520, lein-cljsbuild plus lein-figwheel 0.5.19, re-frame 0.12,
  reagent 0.10 (React 16 via cljsjs), less 1.7.5, a Node 10 engine pin, Cypress 6.9.1, and ws 7.3.1
  (known DoS advisories).
- CI is CircleCI only (`.circleci/config.yml`); there is no `.github/`.
- Tests: 35 kaocha-cljs unit tests that need a real Chrome, and 22 Cypress specs (about 151 tests)
  against a local Biotestmine at `localhost:9999/biotestmine` (built via `intermine_boot`) plus live
  FlyMine.
- BlueGenes depends on sibling libraries `org.intermine/imcljs 1.6.0`, `im-tables 0.15.0` and
  `bluegenes-tool-store 0.2.3`, which were not in the sandbox at the start.
- The rdfc2im stack provides a mine and BlueGenes on :5000 (`plans/30-testbed.md`).

## Decision

Strategy decision 4: migrate BlueGenes to **shadow-cljs plus deps.edn**, with current ClojureScript,
re-frame 1.4 and reagent 1.2 (React 18), Node 22 and Cypress 13+.

- E1: a shadow-cljs build reproducing the `dev`, `prod` and `kaocha` targets; keep a `lein` shim or
  document the switch; drop `less 1.7.5` for the current lessc; Docker image on temurin 21.
- E2/E3: library bumps, with imcljs, im-tables-3 and bluegenes-tool-store upgraded in lockstep.
- F: CI moves to GitHub Actions with a local mine from the rdfc2im stack, replacing CircleCI and
  `intermine_boot`; Cypress `cy.server/route` becomes `cy.intercept`.
- The dependency hygiene rules (census, vetting log) apply; the Gradle `dependsOn` rule does not.

## Consequences

Positive:
- A maintained build tool and a React 18 stack for the grant-direction UI work.
- Clears known advisories (ws, wait-on, xmlhttprequest; `npm audit` clean is E5).
- CI on GitHub Actions alongside the intermine repo.

Negative:
- Breakage from the library bumps must be fixed (E2).
- Cypress fixtures need re-recording against the demo mine, and FlyMine-dependent specs are tagged
  `external`.
- The sibling libraries must be cloned, forked under `gmicklem/` and modernised too; releasing them to
  Clojars is a human step, so git deps may be used during the sprint.

Follow-ups:
- Baseline first: `lein cljfmt check`, `lein kaocha` with chromium, and `lein prod`, recorded in
  `baselines/`; no regression in passing test count is allowed afterwards.
- E4: pin CDN assets with SRI or bundle them, and bump vega/vega-lite.

## Alternatives considered

- **Stay on lein-cljsbuild and figwheel with minimal patches.** Rejected: BlueGenes is the long-lived
  asset and deserves a real toolchain modernisation rather than minimal patches.
- **Bump versions inside the Leiningen setup only.** Not chosen: the plans specify shadow-cljs plus
  deps.edn as the target; a `lein` shim is kept or the switch documented as a transition aid.

## Review trigger

Revisit if the E1 spike cannot reproduce the `dev`, `prod` and `kaocha` targets, if the React 18 move
breaks im-tables or the tool store in ways the lockstep upgrade cannot resolve, or if the grant-direction
UI work chooses a different front-end stack.
