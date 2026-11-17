# im-7os.63: reagent 2.1.0-SNAPSHOT build 2 (#686, #689) with and without our input patch

Worktree: .../worktrees/bluegenes/im-7os.63-reagent-snap2 (branch maint/im-7os.63-reagent-snap2, base 2785384e, same base as build 1's run).
UNCOMMITTED. Holds the S-off state: deps.edn reagent -> {:mvn/version "2.1.0-SNAPSHOT"} and core.cljs with the reagent-inputs
require and (install!) call commented out with #_ (Soff.diff, unchanged from im-7os.62; S-on = deps.edn change only).
(The im-7os.62 worktree no longer existed; its scripts and probe specs were copied from /home/agent/taskhomes/im-7os.62.)

Resolved artifact: reagent-2.1.0-20261117.092548-2.jar (snapshot timestamp 2026-11-17 09:25:48 UTC, build 2), 45497 bytes,
sha256 57b4d37ce179ebaca427605469a4fe7ad08672d3fdcc5fce2bfdda3763661209, from clojars (build 1's directory was deleted first, so only
build 2 is in ~/.m2/repository/reagent/reagent/2.1.0-SNAPSHOT/; reagent-2.1.0-SNAPSHOT.jar is byte-identical). Its META-INF pom.properties:
version=2.1.0-SNAPSHOT, revision=cad0b51c2bba17502d4ce39e9534320c8f1e878a (master with #686, #687, #689).
Note: Deraen's comment (17 Nov 09:27 UTC) names `2.1.0-20261116.204953-1`, which is build 1; the jar carrying #686/#689 is build 2.
Changes in reagent/impl/input.cljs vs build 1 (copy in reagent-src/input-build2.cljs): new :component-did-update
input-component-did-update (skips the write when on-change values are pending and the rendered value equals the last committed one),
new :component-did-mount input-mount (StrictMode remount, #688). input-handle-change is unchanged: it still schedules a revert check
(setTimeout 0, then do-after-render -> input-component-set-value) after every change.
Mine: ut demo mine http://localhost:18090/humanmine, BlueGenes on :5295. Release builds: S-off app.5d3d67c.js, S-on app.dba2c51.js,
diagnostic D app.2613442.js (build 1 run: S-off app.e6a8e82.js, S-on app.a68cb6f.js).

| config | keystroke spec lost/1600 | upload probe lost/800 | upload reps wrong/20 | report_page_test fails/10 | full suite (retries=0) |
|---|---|---|---|---|---|
| **S-off (build 2, patch off)** | **4** (typeahead, 1 rep) | **303** | **14** | **2 (runs 5, 10)** | **146 pass / 1 fail / 33 pending** |
| **S-on (build 2, patch on)** | **0** | **0** | **0** | not run | not run |
| D (build 2, patch off, deferred revert check removed; diagnostic) | 0 | 0 | 0 | not run | not run |
| (build 1 f655d00f, patch off) | 0 | 233 | 10 | 3 (runs 5, 7, 8) | 146 pass / 1 fail |
| (build 1 f655d00f, patch on) | 0 | 0 | 0 | 0 of 5 | not run |
| (master b708d451, patch off) | 0 | 209 | 9 | 8 of 20 | 146/1 twice |
| (baseline 1.2.0, patch on) | 0 | - | - | 0 of 8 | 147/0/33 pending |

S-off keystroke spec: 7 of 8 inputs 0/200; search typeahead lost 4/200, all in rep 0: typed 'abcdefghijklmnopqrstuvwxyz0123456789ABCD',
value 'abcdefgijklmnopqrstuvwxy02345679ABCD' (h, z, 1, 8 missing: scattered single keys, not a revert). Reps 1-4 exact.
S-off upload probe: 14 of 20 reps wrong. Value right after typing / 400 ms later: 7 reps '' / '6' or '2D6' (textarea emptied, then a
pending value written back), 7 reps a tail on both reads (' GSTP1, CYP2D6', '1, CYP2D6', 'D6', '6', ' CYP2D6'). Worse than build 1 (233, 10/20).
S-off report_page_test.js x10: runs 5 and 10 fail "can check if the gene is present in any list": r5 "Expected to find element: `a`, but
never found it" (as with build 1); r10 the upload never left /upload/save (no identifiers to resolve). Same test in the full suite (r5 form).
Full suite S-off: 26 specs, 180 tests, 146 pass, 1 fail (above), 33 pending. keystrokes_test.js passed in that run.
Unit tests (S-on): npm run test:unit 42 tests, 208 assertions, 1 failure, 0 errors: reagent-wrapper-is-the-patched-one (the guard), as
designed: build 2's input-spec now has :component-did-mount and a different :component-did-update.
Builds: all three succeeded, 6 WARNING lines each, identical to build 1's S-off log apart from the worktree path. No errors.

## Diagnostic D: what still loses the keys
D = S-off plus one override installed at start-up (Dnodefer.diff): build 2's input-handle-change without the deferred
setTimeout/do-after-render revert check, everything else build 2 as shipped. Upload probe 0/800 (0/20), keystroke spec 0/1600.
So the remaining loss comes from that check, not from the did-update path #686 fixed. Reading of the code: the check runs after the next
render flush; if the textarea itself has not re-rendered with newer state by then (re-frame event not yet handled, the flush was for the
parent), cljsRenderedValue is still the pre-typing value (''), which is not in cljsPendingValues, so input-component-set-value writes it
and wipes the node. Removing the check also removes reagent's automatic revert of a rejected change (an on-change that ignores the key);
our patch has the same trade-off and handles rejects explicitly (bluegenes.components.ui.inputs/reject-input!). D is not a proposed fix.

## Commands
export CYPRESS_BASE_URL=http://localhost:5295 CYPRESS_MINE_URL=http://localhost:18090/humanmine CYPRESS_ADMIN_USER=superuser@intermine.org CYPRESS_ADMIN_PASSWORD=intermine
git worktree add .../im-7os.63-reagent-snap2 -b maint/im-7os.63-reagent-snap2 maint-2026; git apply Soff.diff
rm -rf /home/agent/.m2/repository/reagent/reagent/2.1.0-SNAPSHOT
clojure -Sforce -A:cljs -Spath | tr ':' '\n' | grep reagent      # downloads build 2; unzip -p <jar> META-INF/maven/reagent/reagent/pom.properties
npm ci; bin-snap/build.sh <label>                                 # clojure -T:build release
bin-snap/serve.sh                                                 # clojure -M -m bluegenes.core on :5295
bin-snap/count.sh <label>      # CYPRESS_KEYSTROKE_REPS=5 spec zz_keystroke_count.js (8 inputs x 40 keys x 5 reps)
bin-snap/upl.sh <label>        # zz_upload_count.js: search gene -> report page -> Upload -> type GENES_A (25 keys), 20 reps
bin-snap/cy.sh report-Soff-rN cypress/integration/report_page_test.js   # x10, retries=0
bin-snap/cy.sh full-Soff       # full suite, retries=0
npm run test:unit              # S-on
Scripts, probe specs (keep/), diffs, logs: /home/agent/taskhomes/im-7os.63/ (cys-*.log/tsv, counts-*.txt/jsonl, upls-*.jsonl,
releases-*.log, unit-Son.log, snap-path.txt, reagent-src/input-build2.cljs, Soff.diff, Dnodefer.diff).
Build artefacts (node_modules, .shadow-cljs, .cpcache, compiled js/css, target) deleted from the worktree afterwards.
