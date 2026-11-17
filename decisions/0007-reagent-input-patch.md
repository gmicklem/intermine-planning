# 0007: Patch reagent's input wrapper at start-up rather than rewrite every input

Date: 15 Nov 2026. Status: implemented in bluegenes a2894c0d (maint-2026), **for Gos's review**.

## Problem

Under React 18 `createRoot`, reagent 1.2.0's controlled `<input>`/`<textarea>` wrapper writes the
rendered value back into the DOM node (a) in an after-render callback that runs before React has
actually rendered, and (b) after every render, even when a re-frame `:on-change` has left the
state a keystroke behind the node. A key pressed in either gap is lost ("PPARG" typed fast became
"PARG"). Reagent 2.0.1 has the same logic.

## Options measured (Cypress, 40 keys x 10 runs x 8 inputs, demo mine)

| Approach | Keys dropped |
|---|---|
| createRoot as it was | 57 / 5600 |
| Legacy `reagent.dom/render` (sync) | 277 / 6400 |
| createRoot + `flushSync` (what reagent 2.0 does) | 309 / 6400 |
| Drop only the after-render reset | 23 / 6400 |
| Echo-aware wrapper patch (chosen) | 0 / 6400 |
| Convert all ~108 sites to a custom `text-input` component | 0 (first 18 sites done by im-7os.31), large diff, misses im-tables' inputs |

Synchronous rendering widens gap (b), so it is not a fix.

## Decision

`src/cljs/bluegenes/reagent_inputs.cljs` reassigns `reagent.impl.input/input-handle-change` and
adds `:component-did-mount`/`:component-did-update` to `reagent.impl.input/input-spec` before the
first render. The node is the truth while the user types; a rendered value that equals text the
user typed is not written back; any other new value (Reset, route-set search term) is written as
before. im-tables' inputs are covered without changes there. `text-input` was removed again.

## Cost and guard

This is a monkey-patch of non-public reagent API. `test/cljs/bluegenes/reagent_inputs_test.cljs`
checks that reagent's wrapper is still the one the patch was written for, so a reagent upgrade
that changes it fails the unit tests rather than silently disabling the patch. Two inputs that
relied on reagent taking back an ignored key (regions extend-by, viz cases number) now call
`inputs/reject-input!` themselves. Alternative if Gos prefers no monkey-patch: revert to the
`text-input` component and convert the remaining ~90 sites (im-7os.35 history has the numbers).


## Update 16 Nov 2026

reagent 2.0.1 (React 18 and 19) measured: the loss persists without the patch (100 and 80 of 1600 keys, concentrated in inputs whose on-change dispatches a re-frame event) and is 0 with it (im-7os.53). Reported upstream as https://github.com/reagent-project/reagent/issues/676 (Gos approved posting).


## Update 16 Nov 2026, 20:50 UTC: fixed upstream

reagent-project/reagent#676 was closed as completed via PR #680 (merged 20:12 UTC, master b708d451f7d6b96e236a16ac70756764b1aecf55; not yet in a release, latest tag v2.0.1). The upstream fix in reagent.impl.input takes the same approach as this patch: the input remembers the values on-change reported, ignores renders whose value is one of them (lagging state), and runs the revert check after a setTimeout and the next render, only for the latest change; it also fixes Korean IME input (#587). Plan (bead im-7os.62): when a release carries it, bump reagent, delete the monkey-patch and its guard test, keep the keystroke Cypress spec. The reagent 2 readiness work (im-7os.57, im-7os.61) is already merged, so the bump is small.

## Measurement of reagent master with PR #680 (16 Nov 2026, 21:40 UTC)

Keystroke spec: 0/1600 lost with master and the patch off (fixed). But the list-upload textarea reached from a report page loses 209/800 keys on master without the patch when the organisms request finishes mid-typing and re-renders the parent with the pre-typing value; 0/800 with the patch; report_page_test fails 8 of 20 runs without it. Master ignores only renders whose value on-change reported; our patch also skips a render whose value has not changed. Decision: keep the patch; drop it only when a release carries #680 plus a fix for the unchanged-value re-render (follow-up comment drafted in docs/drafts/reagent-676-followup.md, Gos to approve); add the upload-after-report case to keystrokes_test.js (bead im-7os.62). Details: reference/reagent-master-pr680-measurement.md.

## reagent 2.1.0-SNAPSHOT (16 Nov 2026, 20:49 build f655d00f) measured 23:40 UTC

Keystroke spec 0/1600 without the patch (fixed). Upload-wizard textarea after a report page: 233/800 keys lost, 10/20 repetitions wrong without the patch; 0/800 with it. report_page_test fails 3/10 without, 0/5 with; the full suite without the patch 146/1 (one typeahead keystroke lost). Decision unchanged: keep the patch; reply drafted (docs/drafts/reagent-676-followup.md) for Gos to approve. Details: reference/reagent-2.1.0-snapshot-measurement.md.
