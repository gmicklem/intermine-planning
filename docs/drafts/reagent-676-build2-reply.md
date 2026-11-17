<!-- DRAFT for Gos to approve; not posted. Measurement: reference/reagent-2.1.0-snapshot-build2-measurement.md (im-7os.63). -->

Thanks for #686. I rebuilt BlueGenes against the new snapshot, `2.1.0-20261117.092548-2` (Clojars build 2, revision cad0b51c; your comment names `-20261116.204953-1`, which is the previous build), with our workaround removed, and measured the same way as last time.

The list-upload textarea still loses keys in our app; the rate is about the same as with build 1.

| Configuration | Upload textarea: 25 keys at 10 ms, 20 reps | 8-input keystroke test: 1600 keys |
|---|---|---|
| build 2 (cad0b51c), no workaround | 303 of 800 lost; 14 of 20 reps wrong | 4 lost (one rep of the typeahead input) |
| build 1 (f655d00f), no workaround | 233 of 800 lost; 10 of 20 wrong | 0 |
| build 2 + our workaround | 0 of 800; 0 of 20 | 0 |
| build 2, revert check removed from `input-handle-change` (diagnostic only) | 0 of 800; 0 of 20 | 0 |

In 7 of the 14 bad reps the textarea is **empty** right after the last key and 400 ms later holds only `6` or `2D6`; the other 7 keep a tail such as `D6` or ` GSTP1, CYP2D6`. Our Cypress test that types a gene list there failed in 2 of 10 runs, and once in a full-suite run.

The last row is build 2 with a single change: `input-handle-change` no longer schedules the `setTimeout` → `do-after-render` → `input-component-set-value` check. Everything else, including #686's `input-component-did-update`, is as shipped. With that change nothing is lost, so the remaining loss seems to come from that check rather than from the path #686 fixed. My reading: the check runs after the next render flush, but in our case that flush is for the parent, and the textarea has not yet re-rendered with the state from its re-frame `:on-change`. Its `cljsRenderedValue` is therefore still the value from before typing (`""`). That value is not in `cljsPendingValues`, so it is written to the node.

I'm not proposing that removal as the fix, because it also drops the automatic revert when `:on-change` rejects a key. Our workaround has the same trade-off and handles rejects explicitly. A narrower option might be to skip the deferred write when the input has not rendered since the change it was scheduled for, i.e. `cljsRenderedValue` still equals `cljsCommittedValue` while values are pending, which is the same condition `input-component-did-update` now uses. But that would leave a rejected change unreverted until the next render of the input. I can try that variant against our tests if it is useful.
