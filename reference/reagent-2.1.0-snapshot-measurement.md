# im-7os.62: reagent 2.1.0-SNAPSHOT (Clojars) with and without our input patch

Worktree: .../worktrees/bluegenes/im-7os.62-reagent-snapshot (branch maint/im-7os.62-reagent-snapshot, base 2785384e).
UNCOMMITTED. Currently holds the S-off state: deps.edn reagent -> {:mvn/version "2.1.0-SNAPSHOT"} and core.cljs with
the reagent-inputs require and (install!) call commented out with #_ (diff of both in Soff.diff; S-on = deps.edn change only).

Resolved artifact: reagent-2.1.0-20261116.204953-1.jar (snapshot timestamp 2026-11-16 20:49:53 UTC, build 1), 45180 bytes, from clojars,
in ~/.m2/repository/reagent/reagent/2.1.0-SNAPSHOT/ (reagent-2.1.0-SNAPSHOT.jar is the same file). Its META-INF pom.properties:
version=2.1.0-SNAPSHOT, revision=f655d00f1fa495ee2525a203871117a352e75d90. Clojars is one of tools.deps' default repos, no change needed.
Mine: ut demo mine http://localhost:18090/humanmine, BlueGenes on :5295. Release builds: S-off app.e6a8e82.js, S-on app.a68cb6f.js.

| config | keystroke spec lost/1600 | upload probe lost/800 | upload reps wrong/20 | report_page_test fails/10 | full suite |
|---|---|---|---|---|---|
| S-off (2.1.0-SNAPSHOT, patch off) | 0 | 233 | 10 | 3 (runs 5, 7, 8) | 146 pass / 1 fail (see below) / 0 pending reported |
| S-on (2.1.0-SNAPSHOT, patch on) | 0 | 0 | 0 | 0 of 5 (extra) | not run |
| (earlier, master b708d451 patch off) | 0 | 209 | 9 | 8 of 20 | 146/1 twice |
| (earlier, baseline 1.2.0 patch on) | 0 | - | - | 0 of 8 | 147/0/33 pending |

S-off full suite (retries=0): 146 pass, 1 fail: keystrokes_test.js "search typeahead (text-input control)":
expected 'abcdefghijklmnopqrstuvwxyz0123456789ABCD', value was 'abcdefghijklmnopqrstuvwxyz012345689ABCD' (the '7' lost).
report_page_test.js passed in that run. (The 3 report_page_test failures above: "Expected to find element: `a`, but never found it" in
"can check if the gene is present in any list", same test as with master b708d451.)
Upload probe S-off values left in the textarea: '2D6', '6', 'D6' (only the tail of "PPARG, HFE, GSTP1, CYP2D6" survives).
Unit tests (S-on): npm run test:unit 42 tests, 208 assertions, 0 failures, 0 errors; the guard test passes.
Builds succeeded (6 compiler WARNING lines in each release log, not compared with the earlier logs). No errors.

## Commands
export CYPRESS_BASE_URL=http://localhost:5295 CYPRESS_MINE_URL=http://localhost:18090/humanmine CYPRESS_ADMIN_USER=superuser@intermine.org CYPRESS_ADMIN_PASSWORD=intermine
sed -i 's|reagent/reagent {:mvn/version "1.2.0"}|reagent/reagent {:mvn/version "2.1.0-SNAPSHOT"}|' deps.edn
npm ci; clojure -Sforce -A:cljs -Spath | tr ':' '\n' | grep reagent        # resolves and downloads the snapshot
git apply --include=src/cljs/bluegenes/core.cljs Soff.diff                 # S-off only (comments out reagent-inputs)
clojure -T:build release                                                   # bin-snap/build.sh <label>
bin-snap/serve.sh                                                          # clojure -M -m bluegenes.core on :5295
bin-snap/count.sh <label>      # CYPRESS_KEYSTROKE_REPS=5 spec zz_keystroke_count.js (8 inputs x 40 keys x 5 reps)
bin-snap/upl.sh <label>        # zz_upload_count.js: report page -> Upload -> 25 keys x 20 reps
bin-snap/cy.sh report-<label>-rN cypress/integration/report_page_test.js   # x10, retries=0
bin-snap/cy.sh full-Soff       # full suite, retries=0
(bin-snap/ = bin/ with the worktree path and port changed; npm run test:unit for the unit tests.)
Logs: cys-*.log/tsv, counts-*.txt, upls-*.jsonl, unit-Son.log, in this directory.
