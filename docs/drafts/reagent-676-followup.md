<!-- DRAFT reply for reagent-project/reagent#676 (maintainer asked us to try 2.1.0-SNAPSHOT). Not posted. Gos to approve. -->

Thank you, and for the quick turnaround. I rebuilt BlueGenes against 2.1.0-SNAPSHOT (Clojars build 20261116.204953-1, revision f655d00f) with our start-up workaround removed, and measured the same way as before.

**Fixed.** The 8-input keystroke test from the issue (40 characters at 10 ms per key, 5 repetitions per input, 1600 keys) lost 0 keys on the snapshot without the workaround, where 2.0.1 lost 100. The inputs whose `:on-change` dispatches a re-frame event are fine now.

**Still loses keys: a textarea whose parent re-renders while the user types.** Our list-upload textarea is reached from a gene report page; a background request (an organism list) finishes a moment after the user starts typing and re-renders the parent. The render carries the textarea's *previous rendered value*, not a value `:on-change` reported, so it is written back to the node and the keys typed since are gone.

| Configuration | Upload textarea: 25 keys at 10 ms, 20 repetitions |
|---|---|
| 2.1.0-SNAPSHOT, no workaround | 233 of 800 keys lost; 10 of 20 repetitions end with the wrong text (typically only the last 1-3 characters remain, e.g. `6` or `2D6` for `PPARG, HFE, GSTP1, CYP2D6`) |
| master b708d451 (#680), no workaround | 209 of 800 lost; 9 of 20 wrong |
| 2.1.0-SNAPSHOT + our workaround | 0 of 800 lost; 0 of 20 wrong |

Opening the same page directly (no request in flight) loses nothing, so the trigger is a render during typing whose value is the old text. Our Cypress test that types a gene list into that textarea failed in 3 of 10 isolated runs without the workaround and 0 of 5 with it; in the one full-suite run without it, one further test lost a single keystroke in a typeahead input.

As far as I can tell from `reagent.impl.input` on master, a render is ignored only when its value is one of the values `:on-change` reported since the last match; a render of the previous rendered value is not in that list, so it is written with the caret restored. Our workaround additionally skips a render whose value has not changed since the last render, which covers this case. Would a condition like that be acceptable upstream?

Reproduction shape: a form-2 component with a textarea `:value @text` and `:on-change #(rf/dispatch [:set-text ...])`, whose parent dereferences a subscription that updates 200-500 ms after mount; type 25 characters at 10 ms per key starting at mount. I can turn this into a Playwright case for the e2e suite if that helps.
