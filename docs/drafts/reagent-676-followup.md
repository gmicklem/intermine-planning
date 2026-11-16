<!-- DRAFT comment for reagent-project/reagent#676 (closed via #680). Not posted. Gos to approve. -->

Thank you for the quick fix. I measured master (b708d451, with #680) against the same application tonight; one case still loses keys, so I am reporting it here rather than opening a new issue.

**What #680 fixes.** The 8-input keystroke test from the issue (40 characters at 10 ms per key, 5 repetitions per input, 1600 keys) now loses 0 keys with master and no workaround, where 2.0.1 lost 100. The three inputs whose `:on-change` dispatches a re-frame event are fixed.

**What still loses keys.** A textarea whose parent re-renders while the user types, with the *previous* rendered value (not one that `:on-change` reported). In our app that is the list-upload textarea reached from a report page: a background request (an organism list) finishes a moment after the user starts typing and re-renders the parent, and the textarea is written back to its pre-typing value.

| Configuration | Keys lost / 800 (25 keys typed at 10 ms, 20 repetitions) |
|---|---|
| master b708d451, no workaround | 209 (9 of 20 repetitions ended with the wrong text, e.g. `6` or `2D6` for `PPARG, HFE, GSTP1, CYP2D6`) |
| master b708d451 + our start-up patch | 0 |
| 2.0.1 / 1.2.0 + our patch | 0 |

Opening the same page directly (no background request in flight) loses 0 of 800 on master, so the trigger is a render during typing whose value is the old text. As far as I can tell from `reagent.impl.input`, master ignores a render only when its value is one of the values `:on-change` reported since the last match; a render of the *previous rendered value* is not in that list, so it is written to the node with the cursor restored, and the keys typed since are gone.

Our workaround (which still passes everything) additionally skips a render whose value has not changed since the last render, so a parent re-render that carries the same stale value writes nothing. Would a condition like that be acceptable upstream, or is there a reason the write-back of an unchanged rendered value is needed?

Reproduction shape: a form-2 component holding a textarea with `:value @text` and `:on-change #(rf/dispatch [:set-text ...])`, whose parent dereferences a subscription that updates ~200-500 ms after mount; type 25 characters at 10 ms per key starting at mount. Happy to turn this into a Playwright e2e case for the suite from #679 if useful.
