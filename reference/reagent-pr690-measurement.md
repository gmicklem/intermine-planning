# im-7os.62: reagent PR #690 (input-drop-auto-revert) with and without our input patch

Worktree: .../worktrees/bluegenes/im-7os.62-reagent-pr690 (branch maint/im-7os.62-reagent-pr690, base maint-2026 7e51e9ca).
UNCOMMITTED. Holds the S-off state: deps.edn reagent -> git dep, and core.cljs with the reagent-inputs require and (install!) commented
out with #_ (Soff-full.diff; S-on = the deps.edn change only).

Commit measured: d7474c24af1045ef510ec3f06330522d3e5e2a67 (branch claude/input-drop-auto-revert); `gh pr view 690 --json headRefOid` at the start
returned that sha, same as the one in the brief (it had not moved).
Consumed as a git dependency, no local build: reagent/reagent {:git/url "https://github.com/reagent-project/reagent" :git/sha "d7474c24..."}.
That commit has a deps.edn; the classpath resolves to /home/agent/.gitlibs/libs/reagent/reagent/d7474c24.../src only (no reagent jar).
Bundle check: release builds are advanced-compiled and reject-change! is dead code in BlueGenes, so it is not in the js (the debug warning is
elided too). Instead: .shadow-cljs/builds/app/release/ana/reagent/impl/input.cljs.cache.transit.json and core.cljs.cache.transit.json (the
release analysis cache) contain reject_change_BANG_, and the git source has it (4 occurrences in impl/input.cljs). Release builds: S-off app.4cca0af.js,
S-on app.51f1f52.js; both built with no errors, 6 JVM WARNING lines (Unsafe notices) as in earlier runs.
Mine: ut demo mine http://localhost:18090/humanmine (200 before each batch, no outage), BlueGenes on :5295.

| config | keystroke spec lost/1600 | upload probe lost/800 | upload reps wrong/20 | report_page_test fails/10 | full suite (retries=0) |
|---|---|---|---|---|---|
| **S-off (PR #690 d7474c24, patch off)** | **0** | **0** | **0** | **0 of 10** | **147 pass / 0 fail / 33 pending** |
| **S-on (PR #690 d7474c24, patch on)** | **0** | **0** | **0** | not run | not run |
| (build 2 cad0b51c, patch off) | 4 (typeahead, 1 rep) | 303 | 14 | 2 (runs 5, 10) | 146 pass / 1 fail / 33 pending |
| (build 2 cad0b51c, patch on) | 0 | 0 | 0 | not run | not run |
| (variant V on cad0b51c, patch off) | 0 | 0 | 0 | 0 of 5 | not run |
| (build 1 f655d00f, patch off) | 0 | 233 | 10 | 3 (runs 5, 7, 8) | 146 pass / 1 fail |
| (master b708d451, patch off) | 0 | 209 | 9 | 8 of 20 | 146/1 twice |
| (baseline 1.2.0, patch on) | 0 | - | - | 0 of 8 | 147/0/33 pending |

S-off: keystroke spec 8 inputs x 40 keys x 5 reps, every input 0/200 (home page email + textarea 0/400); upload probe 20 reps, every rep exact both
immediately after typing and settled; report_page_test.js x10, retries=0, 7 of 7 tests pass each time; full suite 26 specs, 180 tests,
147 pass, 0 fail, 33 pending (the 1.2.0 baseline result; the earlier snapshot runs had one failing test, the report page one).
S-on: the patch still installs and works on this commit: keystroke 0/1600, upload 0/800 (0/20 reps wrong). Nothing in it breaks at
build time or run time, because the pieces it overrides (input-handle-change, input-spec :component-did-mount/:component-did-update,
input-node-set-value with 5 args) all still exist. It simply replaces #690's input-handle-change, so with the patch on, #690's logic
(including r/reject-change!, which needs the binding #690's input-handle-change sets) is not what runs: r/reject-change! would warn and do nothing.
Unit tests (S-on): npm run test:unit 42 tests, 208 assertions, 1 failure, 0 errors: reagent-wrapper-is-the-patched-one
(ri/reagent-wrapper-unchanged? false: #690 has a :component-did-mount, as build 2 had), the guard, as designed.
Not run: reject probe (zz_reject_probe.js, regions extend-region input) and reagent's own tests: not asked.

## Breaking-change inventory (step 5)
#690 removes the automatic revert of an :on-change that leaves the state unchanged. Searched every :on-change in BlueGenes src/cljs (100 hits)
and im-tables-3 src (34 hits); most only copy the target value or dispatch a toggle (checkboxes, radios, selects, files, ranges, re-frame events
that assoc the value as typed). No max-length/pattern attributes and no handler that truncates or filters, other than these two, which already use
bluegenes.components.ui.inputs/reject-input! (written for our patch, so they keep working with or without #690, and would be the two places to switch to r/reject-change!):
- src/cljs/bluegenes/pages/regions/views.cljs:179 input-slider text input: on-change accepts only what parse-bp matches (digits, one dot, k/m suffix), else reject-input! with the current region.
- src/cljs/bluegenes/components/viz/cases.cljs:86 number-input (:type "number"): on-change keeps only positive integers, else reject-input! with the current atom value.
Checked and not affected: constraint.cljs date input (stores the text as typed, validates by timer), upload/views.cljs:84 (stores typed text, submits on separator),
idresolver list-name, imtables export size/offset (range inputs), pagination/page-size selects, trimmer text inputs (im-tables head/controls.cljs:440-458, stored as typed;
parsing happens later), text filters. None of them needs r/reject-change!.

## Commands
Same as reagent-2.1.0-snapshot-build2-measurement.md, with paths changed (scripts copied from im-7os.63 to /home/agent/taskhomes/im-7os.62-pr690/bin-snap):
git worktree add .../im-7os.62-reagent-pr690 -b maint/im-7os.62-reagent-pr690 maint-2026; git apply Soff.diff; deps.edn reagent -> git dep (sha above)
clojure -Sforce -A:cljs -Spath | tr ':' '\n' | grep reagent; npm ci; bin-snap/build.sh Soff; bin-snap/serve.sh; bin-snap/count.sh Soff; bin-snap/upl.sh Soff
bin-snap/cy.sh report-Soff-rN cypress/integration/report_page_test.js (x10); bin-snap/cy.sh full-Soff
S-on: git checkout src/cljs/bluegenes/core.cljs (Soff-core.diff re-applies it); build.sh Son; serve.sh; count.sh Son; upl.sh Son; npm run test:unit
Logs: /home/agent/taskhomes/im-7os.62-pr690/ (counts-*.txt/jsonl, upls-*.jsonl, cys-*.log/tsv, releases-*.log, unit-Son.log, Soff-full.diff, Soff-core.diff, run-*.out).
Build artefacts (node_modules, .shadow-cljs, .cpcache, target, resources/public/js/compiled) deleted from the worktree afterwards.

---

## Draft reply for reagent-project/reagent#676 (not posted)

I ran BlueGenes against #690 at d7474c24 (`claude/input-drop-auto-revert`) and it fixes everything we had measured.

With reagent taken as a git dependency at that sha, and our own monkey-patch of `reagent.impl.input` switched off, against a local mine:

| | keys lost | wrong uploads |
|---|---|---|
| keystroke spec, 8 controlled inputs x 40 keys x 5 reps | 0 / 1600 | 0 / 40 reps |
| upload textarea (re-frame, 25 keys, 20 reps) | 0 / 800 | 0 / 20 reps |
| the report page test that failed on master, x10, no retries | 0 failures | |
| full Cypress suite, no retries | 147 pass, 0 fail, 33 pending (same as with 1.2.0) | |

For comparison, the same measurements on the 2.1.0-SNAPSHOT that had #686 and #689 (cad0b51c, our patch off) lost 4 of 1600 keys, 303 of 800 in the upload probe (14 of 20 reps wrong), and the report page test failed 2 of 10 times. With our patch left on top of #690 we also lose nothing (0/1600, 0/800), so the two do not collide, though ours then replaces your `input-handle-change`.

On the breaking change: I went through every `:on-change` in BlueGenes (100) and in im-tables (34). Only two reject input: a text input on our regions page that takes digits, one dot and a k/m suffix, and a positive-integer number input. Both already put the old text back themselves, so they would simply move to `r/reject-change!`. Nothing else truncates or filters, and there are no maxlength inputs, so nothing else is affected.

What I did not test: only Chromium under Cypress, and I did not run your own test suites. The numbers come from one run of each, apart from the x10 and x20 repeats above.
