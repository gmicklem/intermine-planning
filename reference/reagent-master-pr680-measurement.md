# im-7os.62: reagent master b708d451 (PR 680) without our input patch

Worktree: .../worktrees/bluegenes/im-7os.62-reagent-master (branch maint/im-7os.62-reagent-master, base 2785384e).
Nothing committed: M-off is NOT clean (see below). The worktree holds the M-off change, uncommitted
(copy in /home/agent/taskhomes/im-7os.62/Moff.diff).

## Change (M-off)
deps.edn:  reagent/reagent {:mvn/version "1.2.0"}
        -> reagent/reagent {:git/url "https://github.com/reagent-project/reagent.git" :git/sha "b708d451f7d6b96e236a16ac70756764b1aecf55"}
(reagent's root deps.edn has {:paths ["src"]}, so it works as a git dep; version on master is still 2.0.1.)
core.cljs: require of bluegenes.reagent-inputs and the (reagent-inputs/install!) call commented out with #_.
M-on = deps.edn change only. Baseline = untouched tree (reagent 1.2.0, patch on). Nothing else needed to compile.

## Keystrokes lost (cypress/integration/keystrokes_test.js, measuring copy: value recorded instead of asserted;
## 8 inputs x 40 keys x 5 reps = 1600 keys)
| config | lost / 1600 | per input |
|---|---|---|
| M-off (master, patch off) | 0 | all 8 inputs 0 |
| M-on (master, patch on) | 0 | all 8 inputs 0 |
| baseline (1.2.0, patch on) | 0 | all 8 inputs 0 |
(per input: home email 0/200, home textarea 0/200, lists filter 0/200, templates filter 0/200, QB XML textarea 0/200,
 QB constraint 0/200, im-tables export name 0/200, search typeahead 0/200)

## But M-off loses keys elsewhere: upload wizard textarea after another page
Probe zz_upload_count.js (keep/): report page -> click Upload -> type "PPARG, HFE, GSTP1, CYP2D6" into .wizard textarea, 20 reps.
| config | reps with wrong text | keys lost |
|---|---|---|
| M-off | 9 / 20 | 209 / 800 (value ends '6', '2D6', 'P2D6', ...) |
| M-on | 0 / 20 | 0 / 800 |
Same probe opening /upload directly, or via /lists then Upload: 0 / 20 on M-off (so it needs the report-page-first sequence, i.e. busy start-up).
Real test affected: report_page_test.js "can check if the gene is present in any list" (types GENES_A via createGeneList):
fails intermittently on M-off (8 of 20 runs of the spec incl. 2 full suites); M-on 0 of 6+; baseline 0 of 8.
Failure cause (from cy.intercept log): the saved list had 3 genes (PPARG missing) or none, so the report shows "isn't in any lists".
Hypothesis (not proven): master's revert check only forgets values on-change reported. A render of the value from before the first keystroke
(state lags, parent re-renders for another reason, e.g. organisms list arriving) is not one of them, so the check writes it back and wipes the
text; our patch ignores a render whose value did not change.

## Tests (M-off)
- npm run test:unit: 42 tests, 208 assertions, 0 failures, 0 errors (guard test reagent-wrapper-is-the-patched-one still PASSES against master's
  input.cljs: input-component-set-value is still :component-did-update, no :component-did-mount; the guard does not notice that the wrapper now has its own fix).
- Full Cypress (retries=0): run 1: 146 pass / 1 fail; run 2: 146 pass / 1 fail (the report-page test above). Baseline 147 pass / 0 fail / 33 pending.
  keystrokes_test.js 7/7 pass.

## Commands
export CYPRESS_BASE_URL=http://localhost:5290 CYPRESS_MINE_URL=http://localhost:18090/humanmine CYPRESS_ADMIN_USER=superuser@intermine.org CYPRESS_ADMIN_PASSWORD=intermine
npm ci; clojure -T:build release            # bin/build.sh <label>, release app.485a07b.js (M-off) / app.f32bfda.js (M-on) / app.3b3cb7d.js (baseline)
bin/serve.sh                                 # clojure -M -m bluegenes.core on :5290, default mine http://localhost:18090/humanmine
bin/count.sh <label>                         # CYPRESS_KEYSTROKE_REPS=5 CYPRESS_COUNT_OUT=... npx cypress run --spec cypress/integration/zz_keystroke_count.js
bin/cy.sh full-<label>                       # full suite, retries=0
bin/upl.sh <label>                           # upload probe
npm run test:unit
Scripts and logs: /home/agent/taskhomes/im-7os.62/{bin,keep,count-*.txt,cy-*.log,diag-*.jsonl,upl-*.jsonl,unit-Moff.log}
