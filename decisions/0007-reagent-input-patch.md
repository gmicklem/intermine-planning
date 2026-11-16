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
