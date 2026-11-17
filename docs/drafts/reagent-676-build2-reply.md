<!-- POSTED as https://github.com/reagent-project/reagent/issues/676#issuecomment-6951981693 (17 Nov 2026); measurement: reference/reagent-2.1.0-snapshot-build2-measurement.md (im-7os.63/64). -->

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

I'm not proposing that removal as the fix, because it also drops the automatic revert when `:on-change` rejects a key. Our workaround has the same trade-off and handles rejects explicitly. I also tried a narrower variant: skip the deferred write when the input has not rendered a new value since the change it was scheduled for, while values are pending. (Comparing `cljsRenderedValue` with `cljsCommittedValue`, as `input-component-did-update` does, doesn't work in the deferred check, because did-update makes them equal after every commit; so the change handler records `cljsRenderedValue` instead.) Against cad0b51c:

```diff
--- a/src/reagent/impl/input.cljs
+++ b/src/reagent/impl/input.cljs
@@ -138,12 +138,18 @@
       ;; updated on a later tick (setTimeout, re-frame dispatch) is rendered
       ;; first. Only the check of the latest change runs, so it isn't done
       ;; before the state for that change had a chance to update.
-      (let [n (inc (or (.-cljsChangeCount this) 0))]
+      ;; Skip it if the input hasn't rendered a new value since this change
+      ;; while on-change values are pending: its state still lags behind the
+      ;; DOM, as in input-component-did-update.
+      (let [n (inc (or (.-cljsChangeCount this) 0))
+            rendered-value (.-cljsRenderedValue this)]
         (set! (.-cljsChangeCount this) n)
         (js/setTimeout (fn []
                          (batch/do-after-render
                           (fn []
-                            (when (== n (.-cljsChangeCount this))
+                            (when (and (== n (.-cljsChangeCount this))
+                                       (not (and (some? (.-cljsPendingValues this))
+                                                 (= rendered-value (.-cljsRenderedValue this)))))
                               (input-component-set-value this)))))
                        0)))))
 
```

With that and our workaround removed, nothing was lost: upload textarea 0 of 800 (0 of 20 reps), 8-input test 0 of 1600, and the gene-list test passed 5 of 5. The same build without the diff lost 205 of 800 (9 of 20). Our input that rejects keys (the region-extension field, 10 reps) still ends with the right text, but only because it puts the text back itself. Reagent's own revert is gone, as expected. On your tests, cad0b51c passes 246 unit and 28 e2e tests. With the variant, 8 unit tests fail (`on-change-rejects-key`, `async-on-change-rejects-key`, `async-on-change-rejects-key-with-rerender` and `strict-mode-rejects-first-key`, fn and class; e.g. state `"12"`, input `"1x2"`), and both e2e "rejected change is reverted" tests fail (the input keeps `ab1c2d`). For the same reason the known issue `number-nozero-sync` now passes. So the variant fixes our case only by leaving a rejected key in the input until the input renders a different value.
