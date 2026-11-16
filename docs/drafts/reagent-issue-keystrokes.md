<!-- DRAFT for reagent-project/reagent. Not posted. Show to Gos first. -->

# Title

Controlled `<input>`/`<textarea>` still drops keystrokes with 2.0.1 when `:on-change` dispatches asynchronously (re-frame), with React 18 and React 19 (follow-up to #619)

# Body

## Summary

With Reagent 2.0.1 (`reagent.dom.client`, `createRoot`) a controlled text input whose `:on-change` hands the text to a state container that updates **asynchronously** (a re-frame event: re-frame's router runs the handler on a later tick) still loses typed characters at normal typing speed. The loss is not smaller than with 1.2.0: it disappears in the inputs where 1.2.0 lost keys because `:on-change` writes a ratom, and it gets worse in the inputs where `:on-change` dispatches a re-frame event. React 18.3.1 and React 19.3.1 behave the same.

This is a data point for #619 (controlled input workaround); I could not find an existing issue about this exact case, so I am filing it separately. Happy to move it into #619 if you prefer.

## Environment

- Reagent 1.2.0 and 2.0.1 (`reagent.dom.client/create-root` + `render`, default class compiler)
- React / react-dom 18.3.1, and 19.3.1 (npm, shadow-cljs 2.28.18, ClojureScript 1.11.132)
- re-frame 1.4.7
- Cypress 13.17.0 (Electron 118, headless), Node 22; release (advanced) build
- App: BlueGenes (InterMine web app), about 90 inputs of this kind

## Measurements

Each test types 40 characters (`abcdefghijklmnopqrstuvwxyz0123456789ABCD`) with `cy.type` at its default speed (10 ms per key), 5 times per input (`cy.clear()` first), waits 400 ms, and compares the value of the input with the text typed. Keys lost = 40 - length of the longest common subsequence of typed and actual text (nothing was ever added). 7 tests, 8 inputs, 1600 keys per configuration.

| Configuration | Keys lost / typed |
|---|---|
| Reagent 1.2.0, React 18.3.1 | 27 / 1600 (every input lost some: 3/400, 3/200, 3/200, 4/200, 6/200, 5/200, 3/200) |
| Reagent 2.0.1, React 18.3.1 | 100 / 1600 |
| Reagent 2.0.1, React 19.3.1 | 80 / 1600 |

Reagent 2.0.1 per input (React 18 / React 19):

| Input (`:on-change` does ...) | lost / 200 (React 18) | lost / 200 (React 19) |
|---|---|---|
| feedback email + textarea (`reset!` on a ratom) | 0 (of 400) | 0 (of 400) |
| list filter, template filter, XML textarea (`reset!` on a local ratom; the filters dispatch to re-frame only after a debounce) | 0 | 0 |
| constraint value input (`re-frame/dispatch`) | 35 (5 of 5 runs affected) | 28 (5 of 5) |
| export file name input (`re-frame/dispatch`) | 45 (5 of 5) | 36 (5 of 5) |
| search typeahead (`re-frame/dispatch`) | 20 (5 of 5) | 16 (5 of 5) |

(An earlier run of the 2.0.1 / React 18 configuration lost 28/200 and 15/200 in the constraint and typeahead inputs: the numbers vary by a third between runs, the pattern does not.)

A lost key looks like "PPARG" typed fast ending up as "PARG": the text in the DOM node goes back to an older value in the middle of typing, and the next key is appended to that older text.

Typing speed matters: `cy.type` uses its default 10 ms delay between keys, which is faster than the 16 ms animation frame in which Reagent flushes its render queue.

## Minimal repro (description)

I do not have a standalone project yet; this is the shape of the failing component, which the Cypress spec above drives:

```clojure
(rf/reg-event-db :set-text (fn [db [_ t]] (assoc db :text t)))
(rf/reg-sub :text (fn [db _] (:text db)))

(defn field []
  [:input {:type "text"
           :value @(rf/subscribe [:text])
           :on-change #(rf/dispatch [:set-text (.. % -target -value)])}])
```

Mount with `(rdomc/render (rdomc/create-root el) [field])`, focus the input and type 40 characters with 10 ms between keys (Cypress `cy.type`, or `userEvent.type` with `delay: 10`). The final value is regularly shorter than the text typed. The inputs of the same app whose `:on-change` is a ratom `reset!` lost 0 keys with 2.0.1 (table above). I have not yet measured whether `rf/dispatch-sync` avoids the loss.

## Mechanism, as far as I can tell (reagent.impl.input, 2.0.1)

`input-render-setup` takes `:value` away from React and keeps three things on the wrapper: `cljsRenderedValue` (the value of the last render), `cljsDOMValue` (the text last seen in the node) and the node. Two places write the rendered value into the node:

1. `input-handle-change` sets `cljsDOMValue`, queues `input-component-set-value` with `batch/do-after-render` (so that an `:on-change` that ignores the key gets the old text put back), then calls `on-change`.
2. `:component-did-update` is `input-component-set-value`: after every render of the input, if `cljsRenderedValue` differs from `cljsDOMValue`, it writes `cljsRenderedValue` into the node (`input-node-set-value`).

Both assume that the rendered value is at least as new as the text in the node. With a synchronous `:on-change` that is true. When `:on-change` dispatches an event that the state container handles on a later tick, it is not: key *n* has reached the node and `cljsDOMValue`, but the state, and so the next render, still holds the text after key *n-1* (or older). The render that is triggered by key *n-1* therefore ends in `input-component-set-value` with `cljsRenderedValue` = text after n-1 and `cljsDOMValue` = text after n, and writes the older text into the node. Key *n+1* typed before the state catches up is appended to the older text, and key *n* is lost.

Reagent 2.0 runs the render queue inside `react-dom/flushSync` (`batch/run-queue`, #630). That removes the other gap of 1.2.0 (the `do-after-render` callback of 1. running before React has rendered the new state under `createRoot`), which is why the ratom inputs no longer lose keys. But it makes renders of a lagging state happen right away, one per animation frame, so gap 2 is hit more often: the three re-frame inputs lose about twice as many keys as under 1.2.0 (e.g. 35 versus 6 in the constraint input).

## What fixes it (for reference)

In BlueGenes we monkey-patch `reagent.impl.input` at start-up (about 100 lines) so that the node is the truth while the user types:

- `input-handle-change` no longer queues the after-render reset, and remembers the texts the user typed;
- `component-did-update` does not write a rendered value that is one of the typed texts (the state catching up); any other new rendered value (a Reset button, a route that sets the text) is written as before, with the cursor handling of `input-node-set-value`;
- a render whose value has not changed writes nothing, so an `:on-change` that wants to reject a key has to set the node's text itself.

With that patch 0 / 6400 keys were lost with 1.2.0 (our earlier measurement, same spec at 10 repetitions), and 0 / 1600 with 2.0.1 on React 18.3.1 and on React 19.3.1 (same Cypress spec). So the change is small, but it changes the documented behaviour that an `:on-change` that ignores a key gets the old text back, so I do not propose it as a pull request without discussing it.

Possible directions for Reagent itself, in order of how little they change:

1. Do not write `cljsRenderedValue` into the node in `component-did-update` when the node's text differs from it **and** the node has had a change event since the last render that Reagent has not yet seen a matching value for (a "pending typed texts" list, as above).
2. If controlled inputs are only supported with a state update that is synchronous in `:on-change`, say so in the documentation (and in the re-frame docs), since re-frame's `dispatch` is the idiomatic way to write the handler.
3. Whether the workaround is still needed at all with React 18/19 `createRoot` (React treats `input` events as discrete and flushes them synchronously) is a question for the maintainers; I have not tested Reagent without it.

## Links

- #619 Controlled inputs meta problem
- #630 flushSync in `run-queue` (2.0.0)
- Our measurements and patch: decision 0007 in our planning repo (can paste the relevant parts)
