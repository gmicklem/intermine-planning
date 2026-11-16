# Manual test plan: InterMine 5.1.1 and 6.0.0 (and BlueGenes 1.5.0)

For Gos. A progressive set of manual checks, from what a user sees to what a deployer does: the
BlueGenes interface first, then the legacy webapp, the web services, the documentation, installing and
building from scratch, building a mine, and a side-by-side comparison of the two lines. Passing it is the
manual-testing gate in [COMPLETION.md](COMPLETION.md) step 2.8.

Every test says what to do, what you should see, and **"Automated:"** where an automated test already
covers it (Cypress spec in `bluegenes/cypress/integration/`, rdfc2im `tests/test_live_mine.py` run by
`make test-live`, `mine-tests` test, or the intermine gate / CI), so you can tell new ground from a
second look. "Automated: none" is where your test is the only one.

Facts were checked on 16 Nov 2026, 18:00-18:40 UTC against the running stacks (5.0.8 on the default
stack before it was taken down, then 6.0.0 on the `ut` stack). Anything not checked is *(unverified)*.

---

## 0. Setup

### 0.1 What runs where

| | 5.1.1 line | 6.0.0 line |
|---|---|---|
| InterMine webapp (legacy UI) | http://localhost:8090/humanmine | http://localhost:18090/humanmine |
| Web services | http://localhost:8090/humanmine/service | http://localhost:18090/humanmine/service |
| **BlueGenes under test** (`maint-2026` `38260724`, to become 1.5.0) | http://localhost:5001 | http://localhost:15001 |
| BlueGenes 1.4.5 (the stack's own, released; for "was it already like this?") | http://localhost:5000 | http://localhost:15000 |
| Solr / Postgres | :8983 / :15432 | :18983 / :25432 |
| Built from | `release/5.1.1-candidate` `b9355b129e` (rdfc2im `--intermine-src`) | `maint-2026` (rdfc2im `--intermine-src --stack-name ut`) |

State on 16 Nov 19:00 UTC: **both stacks are up and built from the sprint branches**: the default
stack from `release/5.1.1-candidate` b9355b129e (`/service/version/intermine` "5.1.1"), the `ut` stack from
`maint-2026` 5351d0c301 (`/service/version/intermine` "6.0.0"; two small commits behind the branch head,
which only adds webapp fixes). Both pass the 20 live tests and return identical counts for 13 reference
queries (113 genes, 13,546 proteins, 2,883 pathways, 78,100 GO terms, 450 gene-pathway rows, ...). Before
this afternoon the default stack ran the published 5.0.8; mentions of 5.0.8 below are measurements taken
then and kept for comparison. Both stacks' own BlueGenes on 5000/15000 are the old released 1.4.5 (they still
load scripts from cdn.intermine.org, cdn.jsdelivr.net and code.jquery.com), which is why the new BlueGenes
is started separately on 5001/15001.

**New BlueGenes (maint-2026 669ae3ee) is running** since 16 Nov 19:00 UTC: http://localhost:15001 (against the
6.0.0 mine) and http://localhost:5001 (against the 5.1.1 mine), both bound to 0.0.0.0. Restart and stop recipes:
`/home/agent/taskhomes/im-bg-serve/README.txt` in the sandbox. To reach everything from the Mac, run on the host
(sandbox name `claude-repos`):

```bash
for p in 15001 5001 8090 18090 5000 15000; do sbx ports claude-repos --publish $p:$p/tcp; done
```

The browser calls the mine web services directly on 8090/18090, so those two must be published too.
Known cosmetic items on both mines: `/service/version/release` returns the placeholder `@RELEASE_VERSION@`
(the demo build never fills it), and the branding reads "rdfc2im: 113 gene food/drug-metabolism panel".
The sandbox blocks the home-page RSS feed (one console error) which will not happen on the Mac.

**Logins.** Superuser on both mines: `superuser@intermine.org` / `intermine` (set by rdfc2im's
`full-build.sh`; a demo account, not a secret). For ordinary-user tests register your own account
(e.g. `gos-test-1@example.org`) on each line. Accounts and lists disappear whenever a stack is rebuilt.

**The demo data** (rdfc2im `BUILD.md`): a HumanMine-model mine of a 113-gene food/drug-metabolism panel
from RDF Portal: 113 genes, 13,546 proteins, 2,883 pathways (Reactome), 6,781 publications, 78,100 GO
terms (the ontology only), 23,201 GWAS results, 53,105 alleles (ClinVar), 2,505 SNPs, 22 chromosomes,
one organism (H. sapiens), 9 data sets, 9 public templates, 5 list widgets. Useful identifiers (from
`bluegenes/cypress/support/data.js`): genes `PPARG, HFE, GSTP1, CYP2D6` (list A) and
`CYP2D6, CYP3A4, CYP2C9, VKORC1` (list B): union 7, intersection 1, symmetric difference 6, A minus B 3;
template `Gene_Protein` on list A gives 135 rows; `CYP2D6` (NCBI gene 1565) has 58 proteins; `PPARG`
(5468) has every report-page section; proteins `P37231, P08684`. What the demo mine lacks is in
section 8: read it before section 1 so that a missing feature is not taken for a bug.

### 0.2 Before you start (the orchestrator does these)

- [ ] Both stacks built from the frozen heads, `make test-live` 20/20 on each (COMPLETION.md 2.6).
- [ ] The new BlueGenes started twice, from the CI uberjar of `38260724` (run 43915440190, artefact kept
  until 23 Nov), each in its own directory so each has its own tool store:
  ```bash
  gh run download 43915440190 --repo gmicklem/bluegenes -n bluegenes-uberjar -D /home/agent/taskhomes/manual-test/bg-jar
  mkdir -p /home/agent/taskhomes/manual-test/bg-5001 /home/agent/taskhomes/manual-test/bg-15001
  cd /home/agent/taskhomes/manual-test/bg-15001
  export SERVER_PORT=15001 BLUEGENES_DEFAULT_SERVICE_ROOT=http://localhost:18090/humanmine
  export BLUEGENES_DEFAULT_MINE_NAME=HumanMine BLUEGENES_DEFAULT_NAMESPACE=humanmine HIDE_REGISTRY_MINES=true
  /usr/lib/jvm/java-21-openjdk-arm64/bin/java -jar /home/agent/taskhomes/manual-test/bg-jar/bluegenes.jar   # in the background
  # and the same in bg-5001 with SERVER_PORT=5001 BLUEGENES_DEFAULT_SERVICE_ROOT=http://localhost:8090/humanmine
  curl -s localhost:15001/version; curl -s localhost:5001/version
  ```
  These are the settings of the nightly Cypress job. Agents start the `java` and `socat` processes with
  the Bash tool's `run_in_background`, with the variables exported on their own lines (SANDBOX-NOTES.md). On first start the tool store downloads the
  `@intermine` BlueGenes tools from npm into `./tools`.
- [ ] **So that your Mac's browser can reach them.** The stacks publish their ports on the sandbox's
  `127.0.0.1` only, and the sandbox forwards only ports bound on its network interface. The agent starts
  relays (same port numbers, because the mine's own URLs say `localhost:18090` etc.):
  ```bash
  IP=$(hostname -I | cut -d' ' -f1)          # 172.17.0.29 today
  for p in 8090 5000 18090 15000; do socat TCP-LISTEN:$p,bind=$IP,fork,reuseaddr TCP:127.0.0.1:$p & done
  ```
  and you run on the Mac, once per port (8090, 5000, 5001, 18090, 15000, 15001):
  ```bash
  sbx ports claude-repos --publish 18090:18090
  ```
  *(unverified: neither the relays nor port publishing have been tried from the Mac; the BlueGenes
  processes on 5001/15001 are expected to listen on all interfaces and need no relay.)*
- [ ] Sanity check from the Mac (expected values are the 6.0.0 stack's on 16 Nov; 5.1.1 expected *(unverified)*):
  ```bash
  curl -s http://localhost:18090/humanmine/service/version/intermine   # "6.0.0"
  curl -s http://localhost:8090/humanmine/service/version/intermine    # "5.1.1"
  curl -s http://localhost:15001/version; echo                          # answers (BlueGenes up)
  ```

### 0.3 How to record

- Fill the tables: **PASS**, **FAIL** (with a few words), **SKIP** (why) or **N/A**. Notes column for
  anything odd even when it passes.
- Suggested rhythm: one section on 6.0.0, then the same section on 5.1.1. The web front ends of the two
  lines are meant to behave the same (nearly every webapp fix was backported); the expected differences
  are listed where they occur.
- When something fails: note the URL, what you did, what you saw, the time (UTC), take a screenshot, and
  copy any red lines from the browser console (Chrome: View > Developer > JavaScript Console; Firefox:
  Tools > Browser Tools > Web Developer Tools > Console). Then check the same thing on the 1.4.5 BlueGenes
  (ports 5000/15000) or on public HumanMine (https://www.humanmine.org/humanmine, read-only): if it is
  broken there too, it is not a regression of this work, but still worth a bead. Tell the orchestrator
  "FAIL 1.6 on 6.0.0: ..." and it files a bead.
- Browsers: a current Chrome is the main one (Cypress runs in Chrome/Electron); 1.19 adds Firefox and Safari.
- Use a private window per line if you want to keep logins apart (local storage is per port anyway).

---

## 1. BlueGenes user interface (start here)

URLs: 6.0.0 http://localhost:15001, 5.1.1 http://localhost:5001. Routes are under `/humanmine/`
(`/humanmine/search`, `/humanmine/lists`, `/humanmine/querybuilder`, `/humanmine/templates`,
`/humanmine/upload`, `/humanmine/regions`, `/humanmine/report/Gene/<id>`, `/humanmine/profile`,
`/humanmine/admin`, `/humanmine/tools`).

**1.1 Home page.** Open the BlueGenes URL. See: the header with the mine name "rdfc2im: 113 gene
food/drug-metabolism panel", the search box, template shortcuts, data source tiles, footer; no error
banner; the browser console has no red errors. Automated: `main_page_test.js`; mine-tests
`test_home_page_is_bluegenes`.

**1.2 Navigation.** Click each header tab (Upload, Lists, Templates, Regions, Query Builder) and each
home-page shortcut; Back and Forward buttons work; reload on each page keeps you there. Automated:
`main_page_test.js`.

**1.3 Keyword search with facets.** Header search: `CYP2D6`, Enter. See about 47 results with category
counts Publication 38, Allele 7, Gene 1, Protein 1, and an organism facet "H. sapiens". Click the Gene
category: 1 result. Clear it and apply the organism facet "H. sapiens": results stay (9 objects carry an
organism). Then try `CYP2*` (partial), `CYP2D6 OR CYP3A4`, `"cytochrome P450"` (phrase). See sensible
results, no error. (A facet value with a space returned nothing before 5.1.1, item 14 of the 5.1.1
changes; on 5.0.8 the web service answered 0 hits, checked 16 Nov.) Automated: `search_test.js` (single
term, OR, phrase, partial, boolean, category filter, organism filter *offered*); applying the organism
facet in the UI: none.

**1.4 Autocomplete.** Type `PPA` slowly in the header search: suggestions appear (PPARG); pick one: its
report page opens. Automated: `pr_test.js` "Gives suggestion results"; rdfc2im
`test_autocomplete_*`.

**1.5 Report page.** Open PPARG (search, then click). See: summary (symbol, name, identifiers 5468 /
Ensembl id, organism); the left-hand section list; sections collapse and expand; filtering the section
list; proteins, pathways, publications, GWAS and ClinVar tables with counts; "copy permanent URL"; the
"Lists" box. Tools: a "Tools"/visualisation area where installed tools draw something or show their own
message; none shows "No data found!" as a rejection and none breaks the page (fixed: tools got
`window.imjs`, React globals, and no longer request widgets the mine lacks). Sequence and location
sections are absent or empty (no data, section 8). Then open CYP2D6: 58 proteins. Automated:
`report_page_test.js` (sections, filter, permanent URL, lists; the region and sequence tests skip);
the tool-drawing test is `@external` (only against public HumanMine); mine-tests
`test_report_page_served`. Tools on the demo mine: none.

**1.6 Save a list from results (the fixed list-save bug).** Templates > `Gene_Protein`, run it for
`CYP2D6` (or Query Builder: Gene, symbol, constraint symbol = `CYP*`, Show results). In the results
table click "Save list" (save as Gene). See: a unique default name is offered; Save gives a success
message; the list appears under Lists with **the same number of objects as the table has distinct
genes** (and not more: the old #797 bug). Repeat with a name that already exists: you get a visible
error message, nothing is lost. Do it once logged out and once logged in. (Saving from results failed
with HTTP 400 on the toolchain upgrade until imcljs `d96a3eb`, im-7os.51/54.) Automated: **none**
(the Cypress "Saves the list from an upload" test in `pr_test.js` is commented out).

**1.7 Upload (identifier resolution).** Upload tab; paste `PPARG HFE GSTP1 CYP2D6 NOTAGENE`; type Gene;
the organism is pre-selected as H. sapiens (it was sometimes blank or out of step with the dropdown,
fixed); Continue. See 4 matches and `NOTAGENE` not found. Save the list as `manual-A`. Then paste
`pparg` with "Identifiers are case sensitive" ticked: no match (the option used to lower-case the input).
Paste the list B genes and save `manual-B`. Automated: `lists_test/upload_test.js`, `pr_test.js`
"Upload page resolved IDs".

**1.8 Lists page: combine, tags, folders, delete.** Lists tab. Select `manual-A` and `manual-B`: union
gives 7, intersection 1, symmetric difference 6, A minus B 3. Add a tag, filter by it, move a list to a
folder, copy it, sort by name/date/size, delete one (and undo if offered). As superuser make a list
public (tag `im:public`) and check an anonymous window sees it. Automated: `lists_test/multiple_lists_test.js`,
`sort_lists_test.js`, `single_list_test.js`, `admin_account_list_test.js`, `user_account_test.js`.

**1.9 List analysis and enrichment.** Open the union list (7 genes). See the widgets: pathway enrichment,
publication enrichment (and the SNP ones if relevant); no GO enrichment (section 8). Change the p-value,
the test correction, the background population; open one result; download all and checked results.
Automated: `lists_test/enrichment_test.js`.

**1.10 Query builder and constraint types.** Query Builder: start from Gene in the model browser;
select attributes (symbol, name, proteins > primaryAccession); remove one, sort them; add constraints of
each kind that the model offers: `=`, `!=`, `CONTAINS`/`LIKE` with wildcards on a string, `<`/`>` on an
integer (e.g. Publication year), `ONE OF`, `IS NULL`/`IS NOT NULL`, `LOOKUP`, `IN` a list (`manual-A`),
a Boolean attribute if one is offered, a subclass (type) constraint; switch a join to outer join; edit the
constraint logic to `(A or B) and C`; preview, then Show results; save the query, clear, load it again.
See: results match what the constraints say; no request error. Dates: the demo model has **no Date
attribute** (only String, Integer, Double, Boolean, Clob), so date constraints need the mock mine below.
Automated: `query_builder_test/*.js` (attributes, length constraint, logic, outer join, NULL, save/load);
`date_constraint_test.js` is `@external`.

  *Optional, date constraints:* the agent runs `node script/date-mock-mine.js 8095` in the bluegenes
  checkout (adds a fake `Gene.lastReviewed` date in front of the 6.0.0 mine) and a BlueGenes on 5081
  against `http://localhost:8095/humanmine` (header of `date_constraint_test.js`). Then: Query Builder,
  Gene.lastReviewed, each operator with a picked date and a typed date; the constraint applies when you
  pick or type, not only when the field loses focus (fixed). Only meaningful on one line (it fakes the mine).

**1.11 Templates.** Templates tab: filter by text and by category; run `Gene_Protein` with list
`manual-A`: 135 rows; change a constraint, run again; Reset; view the web service URL; "Edit template"
opens it in the query builder. Automated: `templates_test.js`, `pr_test.js`.

**1.12 Results table (im-tables).** On any results: sort a column, filter a column through its dropdown
(the filter dropdown and the first click on the toolbar were fixed in im-tables), open a column summary,
add and remove columns, page through, change page size, export (TSV, CSV, JSON, XML; FASTA/GFF3/BED need
sequences or locations: section 8), with preview. Automated: partly, inside the list/template specs;
export formats: none.

**1.13 Code export.** Results table > code generation, each language offered (Python, Perl, Java,
JavaScript, Ruby, R, XML *(list unverified)*). See: code that names `http://localhost:<port>/humanmine`;
the JavaScript/HTML snippet loads im-tables and its fonts from the mine itself, **not** from
cdn.intermine.org. Optional: run the Python snippet with `pip install intermine`. Automated:
`results_code_export_test.js` (JavaScript only).

**1.14 Regions search.** Regions tab: the page loads, "Show example" fills the box, Clear empties it,
typing in it is not laggy (per-input debounce, fixed); a search returns no results with a clear message,
not an error (the demo mine has no locations). Automated: `regions_test/*` skip on this mine; `pr_test.js`
region test.

**1.15 Account: register, login, logout, profile.** Register a new user, log out, log in, wrong password
gives an error, empty fields are refused; Profile: preferences (the inputs stay disabled until saved
preferences have loaded, fixed), generate an API key, change the password, delete the account.
Automated: `user_account/register_user.spec.js`, `login_logout_user.spec.js`, `user_account_test.js`.

**1.16 Admin pages (superuser).** Log in as superuser; Admin (`/humanmine/admin`): home page notice
(set, see it on the home page, remove); report page layout (add a category, move classes, collapse,
update, delete; then check a report page and put it back); manage templates (export XML, precompute,
summarise, edit tags, delete one you created; import the exported XML again). Tools page
(`/humanmine/tools`): installed tools listed with previews; install or update one *(depends on npm being
reachable from the sandbox)*. Automated: `admin_account_test/admin_account_test.js`,
`report_page_layout_test.js`; template import/export and tool install: none.

**1.17 Keystrokes in text inputs (the reagent patch).** In each of: header search, upload text box,
list name in the save dialog, a query builder constraint value, a template constraint, the Lists page
filter, a results column filter, the login e-mail and password, profile fields. Type a long string fast
(`the quick brown fox 1234567890` twice), hold a key down for auto-repeat, paste a 200-character text,
delete in the middle with Backspace, move the cursor and insert. Try an accented character with a dead
key (Option-e then e for `é` on a Mac) and, if you use one, an input method (Japanese/Chinese). See: no
character lost, added, reordered or reverted to older text; Enter submits what is in the box. Compare
with the 1.4.5 BlueGenes if in doubt. (Under React 18 the unpatched build dropped 57 of 5,600 keys;
`decisions/0007-reagent-input-patch.md`; EXPERT_TO_CHECK.md item 2 asks for IME review.) Automated:
`keystrokes_test.js` (40 keys x 5 into eight inputs, no IME, no paste, no auto-repeat).

**1.18 Mobile width.** Chrome DevTools device toolbar (Cmd-Opt-M), iPhone-size (about 390 px) and
tablet: the header collapses to a menu, every page in 1.1-1.11 is usable, tables scroll sideways, dialogs
fit. Automated: none.

**1.19 Other browsers.** Firefox and Safari: 1.1, 1.3, 1.5, 1.6, 1.17 (short versions). Automated: none
(Cypress runs Chrome/Electron).

**1.20 jQuery 3.7.1 popovers and dropdowns.** BlueGenes now loads jQuery 3.7.1 (was 3.1.0) from cdnjs
with Subresource Integrity (HUMAN-STEPS.md item 5). Hover popovers in result cells and on report-page
links, the settings cog menu, the user menu, the column dropdowns: they open, close, and position
correctly; no jQuery error in the console. Automated: Cypress clicks some of them; none looks at them.

**1.21 No third-party hosts.** With the browser's Network tab open (Disable cache ticked), click through
1.1-1.11. See requests only to `localhost` ports, `cdnjs.cloudflare.com` (jQuery and other pinned
libraries), `registry.npmjs.org`-style tool assets only through the BlueGenes server, the mine logo from
www.humanmine.org (the mine's branding), and whatever an individual tool calls (e.g. EBI/PDB). No
`cdn.intermine.org`, `cdn.jsdelivr.net`, `code.jquery.com`, `cdn.rawgit.com`. Google Tag Manager only if
an analytics id is configured (it is not). Automated: mine-tests `test_page_scripts_load` and
`test_no_failed_requests_to_the_mine` (browser tests, not run against the local stack so far).

| Test | 5.1.1 result | 6.0.0 result | Notes |
|---|---|---|---|
| 1.1 Home page | | | |
| 1.2 Navigation | | | |
| 1.3 Search with facets | | | |
| 1.4 Autocomplete | | | |
| 1.5 Report page and tools | | | |
| 1.6 Save list from results | | | |
| 1.7 Upload | | | |
| 1.8 Lists: combine, tags, folders | | | |
| 1.9 Enrichment | | | |
| 1.10 Query builder, constraint types | | | |
| 1.10 optional: date constraints (mock mine) | n/a | | |
| 1.11 Templates | | | |
| 1.12 Results table | | | |
| 1.13 Code export | | | |
| 1.14 Regions | | | |
| 1.15 Account | | | |
| 1.16 Admin pages, tools | | | |
| 1.17 Keystrokes | | | |
| 1.18 Mobile width | | | |
| 1.19 Firefox / Safari | | | |
| 1.20 Popovers, dropdowns | | | |
| 1.21 No third-party hosts | | | |

---

## 2. Legacy webapp user interface

URLs: 6.0.0 http://localhost:18090/humanmine, 5.1.1 http://localhost:8090/humanmine. This is the
JSP/Struts interface many existing users still know; the grant direction retires it, so the aim is
"nothing broken", not new features.

**2.1 Home page** (`/begin.do`). Loads with the demo templates, data categories, footer; no broken image;
console free of red errors. Network tab: page **scripts** come only from the mine itself (on 6.0.0 the
page has no third-party `src=` at all, checked 16 Nov; on 5.0.8 it loaded 7 scripts from
cdn.intermine.org and one from www.google.com). Expected difference: none on this page. Automated:
rdfc2im `test_classic_ui_webconfig_is_valid`; mine-tests `test_classic_webapp`; console: none.

**2.2 Keyword search with facets and special characters** (`/keywordSearchResults.do`). Search
`CYP2D6`: about 47 hits with facets. Click the organism facet "H. sapiens": 9 hits (on 5.0.8 this gave
0). Click Category Gene. Then search each of these and check you get a results page (possibly empty),
never an error page: `a:b`, `a"b`, `"cytochrome P450"`, `Homo sapiens & co`, `CYP2D6 AND`, `(`. Facet
links on the results page must work after such a search. Automated: unit tests of the search fixes
(5.1.1 items 14 and 18); the UI: none.

**2.3 Report page** (`/report.do?id=<id>`; click PPARG from search). Summary, the collections with counts,
displayers (pathways, publications, proteins), the "lists containing" box, export links on each table;
every inline table expands and pages; no JSP error, no "JasperException" (the EL keyword fixes). A
chart or tracks tab draws without Google Charts. Automated: rdfc2im live tests reach the pages; none
renders them.

**2.4 Lists: upload, confirm, analysis page with charts** (`/bag.do`). Paste list A, type Gene, Go. The
confirm page shows 4 matches and its controls work (this page referenced the dead cdn.intermine.org,
im-jqz.43). Save as `legacy-A`. The list analysis page (`/bagDetails.do?bagName=legacy-A`): widgets
draw: pathway and publication enrichment tables, chromosome distribution chart (may be empty, no
locations). **Expected difference:** on 6.0.0 the charts are drawn by a local shim and the page loads
nothing from Google; on 5.1.1 this one page still loads `www.gstatic.com/charts/loader.js` (5.1.1 change
10). Then MyMine > Lists: union/intersect/subtract `legacy-A` with a second list, rename, tag, delete.
Automated: widget services in CI web-service tests (testmine); the page: none.

**2.5 Templates** (`/templates.do`, then one template). Run `Gene_Protein` on `legacy-A`: 135 rows. The
template form renders (it used `dec.boolean`, which current Tomcat rejects); type in a constraint: the
autocompleter offers values (the DWR `getContent` method had to be re-listed, 5.1.1 item 22). As
superuser, edit a template, tag it `im:frontpage`, see it on the home page, remove the tag. Automated:
`DwrIncludesTest` (that the method is listed); the page: rdfc2im checked `template.do` returns 200 with a
full page.

**2.6 Query builder** (`/customQuery.do`). Start from Gene, add a constraint, choose output columns, run;
the autocompleter in constraint fields; save the query; MyMine > Saved queries shows it; Query history;
import a query as XML (`/importQueries.do`) using the XML from "Export XML" of the saved query. Also
open this link (a query without a `trail` parameter, which used to throw an exception, 5.1.1 item 20):
`http://localhost:18090/humanmine/loadQuery.do?method=xml&skipBuilder=true&query=%3Cquery%20model%3D%22genomic%22%20view%3D%22Gene.symbol%22%3E%3C%2Fquery%3E`
(port 8090 for 5.1.1): you get a results page with 113 genes. Automated: none for the pages.

**2.7 MyMine, login, API key** (`/login.do`, `/mymine.do`). Log in as your own user and as superuser;
tabs Lists, Saved queries, Templates, Account; on Account generate an API key (and see the token page);
change the password; log out. The login page offers no OpenID block on 6.0.0 (removed; it was never
active). Automated: none for the pages; the token web services in CI.

**2.8 API page** (`/api.do`). The client library tabs (Python, Perl, Java, Ruby, JavaScript) with
download links and examples; the code generated for a query (results page > "Python" etc.) and its
JavaScript version, which loads im-tables from the mine (5.1.1 item 8). Automated: none.

**2.9 Export from a results table.** Export dialog: TSV, CSV, XML, JSON; Galaxy: the "Send to Galaxy"
option appears and builds a link to usegalaxy.org (do not follow it through) *(whether it is enabled on
the demo mine unverified)*; FASTA/GFF3 need sequences (section 8). Automated: none.

**2.10 RDF/XML and N-Triples.** From a results table, or the web service links in 3.3: `format=rdf` and
`format=ntriples` give RDF, also for classes without an ontology term (Pathway, GOTerm used to give HTTP
500, 5.1.1 item 17). A gene's permanent URL (report page, "permanent URL") opens its report page.
Automated: unit tests (im-jqz.58); 3.3 below.

**2.11 DWR debug pages are gone.** Open `/dwr/index.html`: HTTP 501, not a list of Java classes (5.1.1
item 16; 501 checked on 6.0.0, 200 on 5.0.8). Automated: unit test of the include list.

**2.12 Session survives a redeploy** *(agent assistance needed)*. Log in, have the agent restart the
mine's Tomcat (`docker restart rdfc2im-ut-mine rdfc2im-ut-bluegenes`), reload: on the second and later
redeploys you stay logged in (forms have `serialVersionUID`, 5.1.1 item 20; the first redeploy after
upgrading cannot restore old sessions). Optional. Automated: none.

| Test | 5.1.1 result | 6.0.0 result | Notes |
|---|---|---|---|
| 2.1 Home page, no third-party scripts | | | |
| 2.2 Keyword search, facets, special characters | | | |
| 2.3 Report page | | | |
| 2.4 Lists, confirm page, analysis page with charts | | | |
| 2.5 Templates, autocompleter | | | |
| 2.6 Query builder, import, loadQuery link | | | |
| 2.7 MyMine, login, API key | | | |
| 2.8 API page, generated code | | | |
| 2.9 Export, Galaxy entry | | | |
| 2.10 RDF/XML, N-Triples | | | |
| 2.11 /dwr/index.html is 501 | | | |
| 2.12 Session after redeploy (optional) | | | |

---

## 3. Web services

Run from a terminal (Mac, after 0.2, or in the sandbox). Set the line once per run:

```bash
export M=http://localhost:18090/humanmine/service     # 6.0.0; for 5.1.1 use http://localhost:8090/humanmine/service
export U=gos-ws-1@example.org P=test-password-1         # a throwaway account, created in 3.7
Q='<query model="genomic" view="Gene.symbol Gene.primaryIdentifier"><constraint path="Gene.symbol" op="=" value="CYP2D6"/></query>'
```

**3.1 Versions.** `curl -s $M/version; echo; curl -s $M/version/intermine; echo` gives `35` and
`"6.0.0"` on 6.0.0 (checked); on 5.1.1 `"5.1.1"` and `35` *(unverified)*. `curl -s $M/version/release`
gives `"@RELEASE_VERSION@"` on both lines and on 5.0.8 (a placeholder the demo build never fills; cosmetic).
Automated: mine-tests `test_version`, `test_release_and_intermine_version`; rdfc2im `test_mine_serves_version`.

**3.2 Model.** `curl -s "$M/model?format=json" | head -c 300` (JSON) and `curl -s $M/model | head -3`
(XML, `<model name="genomic" ...>`). Automated: mine-tests `test_model_has_core_classes`; rdfc2im
`test_mine_serves_model`.

**3.3 Query results in every format.**
```bash
for f in tab csv json jsonobjects xml count rdf ntriples; do
  echo "== $f"; curl -s "$M/query/results" --data-urlencode "query=$Q" --data-urlencode format=$f | head -c 300; echo; done
for c in Pathway GOTerm; do      # classes without an ontology term: used to be HTTP 500 in RDF
  curl -s -o /tmp/rdf-$c.xml -w "$c %{http_code}\n" "$M/query/results" \
    --data-urlencode "query=<query model=\"genomic\" view=\"$c.identifier $c.name\"></query>" --data-urlencode size=5 --data-urlencode format=rdf
  python3 -c "import sys,xml.dom.minidom as m; m.parse(sys.argv[1]); print('well-formed')" /tmp/rdf-$c.xml; done
curl -s "$M/query/results" --data-urlencode 'query=<query model="genomic" view="Gene.symbol"></query>' \
  --data-urlencode size=3 --data-urlencode format=ntriples | grep -c 'rdf-syntax-ns#type> <>'    # 0
```
See: `CYP2D6	1565` in tab; RDF/XML and N-Triples with `http://localhost:<port>/humanmine/gene:1565`
subjects and `rdf:type` `obo/SO_0000704`; both classes "200 well-formed"; 0 empty types (all checked on
6.0.0, 16 Nov; on 5.0.8 `format=rdf` silently returned tab output). Automated: CI web-service tests
(testmine, JS and Python clients); RDF fix unit tests; formats against the demo mine: none.

**3.4 Templates.**
```bash
curl -s "$M/templates?format=json" | python3 -c "import sys,json; print(sorted(json.load(sys.stdin)['templates']))"   # 9 names
curl -s "$M/template/results?name=Gene_Protein&constraint1=Gene&op1=LOOKUP&value1=CYP2D6&extra1=&format=tab&size=3"
```
See the 9 template names (All_Proteins_In_Organism_To_Publications, GOTerm_Structure,
GWASResult_AssociatedGene, Gene_ClinVar_Alleles, Gene_MultiSource_Identifiers, Gene_Protein,
Gene_Publications, Gene_UniProt_Proteins, Organism_Protein) and three rows `1565 CYP2D6 "" A0A0F7...`.
Automated: mine-tests `test_templates_available`.

**3.5 Keyword search and facets.**
```bash
curl -s "$M/search?q=CYP2D6&format=json" | head -c 200; echo                                     # totalHits 47
curl -s "$M/search?q=CYP2D6&facet_organism.shortName=H.%20sapiens&format=json" | head -c 120; echo  # totalHits 9 (0 on 5.0.8)
curl -s "$M/search?q=a%3Ab&format=json" | head -c 200; echo                                        # wasSuccessful true, no Solr error
```
Automated: rdfc2im `test_keyword_search_*`; mine-tests `test_keyword_search_finds_fixture_gene`; the
facet with a space: unit tests only.

**3.6 Widgets and enrichment.**
```bash
curl -s "$M/widgets?format=json" | python3 -c "import sys,json; print([w['name'] for w in json.load(sys.stdin)['widgets']])"
curl -s "$M/list/enrichment?ids=1000940,1000002&type=Gene&widget=pathway_enrichment&maxp=1&correction=None&format=json" | head -c 300; echo
```
See 5 widgets (chromosome_distribution_for_snp, publication_enrichment, chromosome_distribution_for_gene,
pathway_enrichment, snp_publication_enrichment) and an enrichment answer with `"populationCount":110`
*(the object ids 1000940/1000002 are CYP2D6 and HFE on the 16 Nov 6.0.0 build; ids change on rebuild:
look them up with `format=jsonobjects`)*. Automated: CI web-service tests (testmine widgets); here none.

**3.7 Users and tokens.**
```bash
curl -s -X POST "$M/users" --data-urlencode name=$U --data-urlencode password=$P | head -c 200; echo   # wasSuccessful true
curl -s -u $U:$P "$M/user/whoami?format=json" | head -c 200; echo                                      # username = $U
curl -s -u $U:$P "$M/user/token" | head -c 200; echo                                                   # a token (shape unverified)
curl -s -u superuser@intermine.org:intermine "$M/user/whoami?format=json" | head -c 200; echo         # "superuser":true
```
JWT bearer authentication is **not configured** on the demo mine (no `security.publickey.*`, no JWT
issuer), so it cannot be tested here; it is covered by the CI web-service tests on testmine
(`jwt.verification.strategy = ANY`) and by `KeySignerTest` (EXPERT_TO_CHECK item 1). Automated: CI
web-service tests; Cypress creates accounts through `POST /service/users`.

**3.8 Lists: create, rename, tag, combine, delete.**
```bash
curl -s -u $U:$P -X POST -H 'Content-Type: text/plain' --data-binary 'PPARG HFE GSTP1 CYP2D6' "$M/lists?name=ws-A&type=Gene" | head -c 300; echo
curl -s -u $U:$P -X POST -H 'Content-Type: text/plain' --data-binary 'CYP2D6 CYP3A4 CYP2C9 VKORC1' "$M/lists?name=ws-B&type=Gene" | head -c 100; echo
curl -s -u $U:$P "$M/lists?format=json" | python3 -c "import sys,json; print([(l['name'],l['size']) for l in json.load(sys.stdin)['lists']])"
curl -s -u $U:$P -X POST "$M/lists/union?name=ws-U&lists=ws-A;ws-B" | head -c 100; echo              # size 7
curl -s -u $U:$P -X POST "$M/lists/intersect?name=ws-I&lists=ws-A;ws-B" | head -c 100; echo          # size 1
curl -s -u $U:$P -X POST "$M/lists/rename?oldname=ws-I&newname=ws-I2" | head -c 100; echo
curl -s -u $U:$P -X POST "$M/list/tags?name=ws-A&tags=manual" | head -c 100; echo
curl -s -u $U:$P -X DELETE "$M/lists?name=ws-I2" | head -c 100; echo
```
See `wasSuccessful: true` everywhere, sizes 4, 4, 7, 1 *(the exact parameter forms of union/intersect
and rename follow the InterMine web-service documentation and are unverified here)*. Automated: CI
web-service tests (testmine).

**3.9 Concurrent requests for the same list name and the same tag** (5.1.1 items 11 and 19).
```bash
for i in 1 2 3 4 5; do
  curl -s -o /tmp/race-$i.json -w "%{http_code}\n" -u $U:$P -X POST -H 'Content-Type: text/plain' \
    --data-binary 'CYP2D6 CYP3A4' "$M/lists?name=race-1&type=Gene" & done; wait
curl -s -u $U:$P "$M/lists?format=json" | python3 -c "import sys,json; print([l['name'] for l in json.load(sys.stdin)['lists']])"
for i in 1 2 3 4 5; do curl -s -o /dev/null -w "%{http_code}\n" -u $U:$P -X POST "$M/list/tags?name=ws-A&tags=race-tag" & done; wait
```
See: exactly one `200`, the other uploads `400` (the list already exists), never `500`; one `race-1` and
no `race-1_temp_*` in the list of lists; five `200` for the tags. Automated: unit tests of the fixes
(im-jqz.36, im-jqz.57); against a running mine: none.

**3.10 Delete the user** (5.1.1 item 11: `DELETE /service/user` returned 500 for a user owning a list
without a description). Deregistration is two steps *(exact form unverified)*:
```bash
curl -s -u $U:$P -X POST "$M/user/deregistration" | head -c 200; echo                 # gives a deregistration token
curl -s -u $U:$P -X DELETE "$M/user?deregistrationToken=<token from above>" | head -c 200; echo   # 200, no 500
```
Automated: Cypress `after:run` deregisters its accounts (after deleting their lists first, because of
this very bug on 5.0.8).

**3.11 Generated code.** `curl -s "$M/query/code?lang=py" --data-urlencode "query=$Q" | head -5` and
`lang=js`: code that names the mine's URL and, for JavaScript, no cdn.intermine.org. Automated: none here.

| Test | 5.1.1 result | 6.0.0 result | Notes |
|---|---|---|---|
| 3.1 Versions | | | |
| 3.2 Model | | | |
| 3.3 Query results, all formats incl. RDF | | | |
| 3.4 Templates | | | |
| 3.5 Search, facets | | | |
| 3.6 Widgets, enrichment | | | |
| 3.7 Users, tokens (JWT: n/a) | | | |
| 3.8 Lists create/rename/tag/combine/delete | | | |
| 3.9 Concurrent same-name uploads and tags | | | |
| 3.10 Delete user | | | |
| 3.11 Generated code | | | |

---

## 4. Documentation (read as a deployer would)

Each line has its own copy of the intermine docs: 5.1.1 at
`https://github.com/gmicklem/intermine/blob/release/5.1.1-candidate/docs/<file>`, 6.0.0 at
`https://github.com/gmicklem/intermine/blob/maint-2026/docs/<file>`. Read them on GitHub (links and
anchors are tested that way). For each: could you follow it without help? Is anything out of date,
contradictory, or assuming knowledge you do not have? Note the paragraph.

**4.1 intermine README.md and CONTRIBUTING.md.** The badges, what the project is, where to start; the
PR rules (target `dev`, CI must be green). Automated: none.

**4.2 docs/BUILDING.md.** Requirements (JDK, Python, Postgres only for tests, `LANG=C.UTF-8`), the seven
builds and their order, `install_intermine.py`, common commands. You will use it in 5.2. Automated: none
(the gate runs the commands).

**4.3 docs/TESTING.md.** What the tests need, how CI decides pass/fail, running one build's tests
locally. You will use it in 5.2. Automated: none.

**4.4 docs/UPGRADING-build.md** (the migration guide for deployers). 5.1.1 line: "5.0.x or 5.1.0 to
5.1.1" and the two webapp warnings (EL keywords, dead CDN). 6.0.0 line: "Which versions go together",
"Three edits that almost every mine needs", "5.1.1 to 6.0.0" steps 1-8, the HumanMine worked example
(compare it with the real change: `git -C /Users/gos/claude_projects/update_intermine_planning/repos/humanmine diff --stat origin/master fork/maint-2026`),
"cglib/commons-lang 2/Torque are gone", "Removed from"/"Changed in the webapp". Ask: would a mine
maintainer know what to do, in what order, and how to check it worked? This becomes the announcement's
main link. Automated: none (the steps were run on HumanMine and FlyMine by agents).

**4.5 docs/RELEASING.md, dry read.** Every command in sections 1-5 for both lines (the 5.1.1 copy has the
"5.1.1 changes" list): do you understand what each does and what you would type? List every word you
had to look up. Compare with COMPLETION.md sections 4-5. Automated: none (2.7 rehearses the bundles).

**4.6 BlueGenes docs** (`docs/building.md`, `docs/configuring.md`, README) and the libraries' READMEs,
plus [RELEASING-siblings.md](RELEASING-siblings.md). Same questions. Automated: none.

**4.7 rdfc2im BUILD.md** (the demo testbed), if you will do 5.5. Automated: none.

| Test | 5.1.1 result | 6.0.0 result | Notes |
|---|---|---|---|
| 4.1 README, CONTRIBUTING | | | |
| 4.2 BUILDING.md | | | |
| 4.3 TESTING.md | | | |
| 4.4 UPGRADING-build.md | | | |
| 4.5 RELEASING.md dry read | | | |
| 4.6 BlueGenes and library docs | n/a | | one column: BlueGenes has one line |
| 4.7 rdfc2im BUILD.md | | | |

---

## 5. Installation and build from scratch on a clean machine

Goal: someone with only the docs gets InterMine built and tested. The agents never did this on a
machine without their caches. Use a clean environment: (a) a fresh Ubuntu 24.04 container in the
sandbox, which an agent drives while you watch (`docker run -it --name im-clean ubuntu:24.04 bash`,
with ports published if you want to open a webapp), or (b) a fresh Linux VM on the Mac *(any tool;
unverified)*. Times are from the baselines and BUILD.md on warm caches; a first run also downloads
Gradle, a few hundred MB of dependencies and Docker images, so expect it to be clearly slower
*(first-run times unverified)*.

**5.1 Toolchain.** As BUILDING.md says: JDK 17 (and JDK 8 for the 5.1.1 line), Python 3.10+, git,
PostgreSQL. `apt-get install openjdk-17-jdk openjdk-8-jdk-headless python3 python3-venv git postgresql`
on Ubuntu *(JDK 8 package name on 24.04 unverified)*. CI uses PostgreSQL 14 and 16; the agents used 18.
Automated: CI matrix (JDK 8/17 x Postgres 14/16).

**5.2 Build and unit tests, 6.0.0 on JDK 17.** `git clone -b maint-2026 https://github.com/gmicklem/intermine.git`;
then only TESTING.md "Running one build's tests locally": the `test` role, `install_intermine.py`
(writes the properties and publishes the five builds: about 4-6 minutes warm), `./gradlew ... build` in
`intermine` (6-9 minutes) and `parse_test_report.py`. See "no failures" from the report script; Checkstyle
clean. Repeat on **PostgreSQL 14 and 16** if you can. Automated: CI and the gate (but never from a clean machine).

**5.3 5.1.1 on JDK 8.** Same with `git clone -b release/5.1.1-candidate ...` and JDK 8 (Gradle 6.9.4 does
not run on 17). Then 6.0.0 on JDK 8 too (it still works, with one Gradle deprecation notice).
Automated: CI.

**5.4 The testmine webapp.** TESTING.md: "For the web service tests use the steps of `config/ci/init.sh`
for the suite `ws`": Solr in Docker (`config/ci/init-solr-docker.sh`), then `testmine/setup.sh <checkout>`,
which loads the test data and starts the testmine webapp with Cargo on port 8080
(`http://localhost:8080/testmine` *(path unverified)*). Open it, run a query. Automated: CI `ws-tests`
(JS and Python clients against testmine).

**5.5 The demo testbed from scratch.** rdfc2im `BUILD.md`: its prerequisites (JDK 8, the Python venv, the
Gradle 4.9 launcher, Docker Compose v2), `tools/full-build.sh --dry-run`, then a real build against an
InterMine checkout (`--intermine-src <the clone from 5.2>`); with `--use-cached-data` about 10 minutes
(599-638 s recorded), from RDF Portal about a quarter of an hour more for the SPARQL fetch; peak about
9 GB RAM. Then `make test-live`: 20/20. Automated: the BlueGenes nightly does this on a GitHub runner
(cached data, about 9 minutes for the mine).

**5.6 BlueGenes from source.** BlueGenes `docs/building.md` Quickstart: JDK 17+, Node 22, the Clojure
CLI; `npm ci`, `clojure -T:build uber` (about 2 minutes warm), run `target/bluegenes.jar` against the mine
from 5.5 (settings as in 0.2). Automated: BlueGenes CI `check` job.

| Test | 5.1.1 result | 6.0.0 result | Notes |
|---|---|---|---|
| 5.1 Toolchain from the docs | | | |
| 5.2 Build + tests, JDK 17, Postgres 14/16 | n/a | | |
| 5.3 Build + tests, JDK 8 | | | |
| 5.4 testmine webapp | | | |
| 5.5 Demo testbed from scratch | | | |
| 5.6 BlueGenes from source | n/a | | one BlueGenes line |

---

## 6. Building a mine database

What a deployer actually does: take a real mine's build (HumanMine), move it to the new release, build its
database and webapp, load real data. The agents ran `buildDB` and `war` for HumanMine and FlyMine;
**loading data into a real mine and deploying its war to Tomcat were not done** (UPGRADING-build.md says
so).

**6.1 HumanMine on the 6.0 line.** Before 6.0.0 is on Maven Central, publish the 6.0.0 checkout to the
local Maven repository (UPGRADING-build.md "Before you start"), and the HumanMine data sources
(`gmicklem/humanmine-bio-sources` `maint-2026`: `./gradlew publishToMavenLocal -x test`). After the release,
skip that: `6.0.+` resolves from Central. Then in `gmicklem/humanmine` `maint-2026`: a
`~/.intermine/humanmine.properties` with your database settings, empty databases, and UPGRADING-build.md
"5.1.1 to 6.0.0" step 7 ("Check") and step 8 ("Look inside the war"):
```bash
./gradlew --warning-mode all :dbmodel:tasks :webapp:tasks --dry-run   # configures, no deprecation
./gradlew --warning-mode all :dbmodel:buildDB
./gradlew --warning-mode all :webapp:war
```
See: no deprecation from the mine's files; 132 jars in `WEB-INF/lib`, about 68.5 MB; the step-8 checks
print what the guide says. Automated: agents ran exactly this (im-ee7 series), not from a clean machine.

**6.2 A Gradle 4.9 mine on 5.1.1.** Take upstream `intermine/humanmine` `master` (Gradle 4.9,
`imVersion=5.0.+`) and apply only UPGRADING-build.md "5.0.x or 5.1.0 to 5.1.1" (it stays on Gradle 4.9,
or moves to 6.9.4); point it at the 5.1.1 artefacts (`mavenLocal` until 5.1.1 is published); `buildDB` and
`war`. This is the promise of 5.1.1: an existing mine needs only a version bump plus the three edits.
Automated: a smoke build of a copy of FlyMine on 6.9.4 (agents).

**6.3 The bio-source forks' own tests.** In `repos/humanmine-bio-sources` and `repos/flymine-bio-sources`
(`maint-2026`, JDK 17, with 6.0.0 in `mavenLocal`): `./gradlew build`. See: green. (Their GitHub CI is red
for an unrelated reason: an old "Set up python 2.7" step; COMPLETION.md 5.8.) Automated: none in CI.

**6.4 A real data load of two sources.** In the HumanMine build from 6.1, load two sources whose data is
small and public: `so` (the Sequence Ontology file shipped with the mine) and `go` (GO ontology):
```bash
mkdir -p /micklem/data/go-annotation/current
curl -L -o /micklem/data/go-annotation/current/go-basic.obo https://purl.obolibrary.org/obo/go/go-basic.obo
./gradlew integrate -Psource=so --stacktrace
./gradlew integrate -Psource=go --stacktrace
./gradlew postProcess --stacktrace      # or only the post-processes that apply
```
(`project.xml` expects `go-basic.obo` at that path; change it there if you keep data elsewhere.) See: each
task logs its progress (the 6.0 plugin prints the loaders' log4j output again) and ends `BUILD
SUCCESSFUL`; then `psql` on the production database: `select count(*) from soterm;` and
`select count(*) from goterm;` are in the thousands and tens of thousands *(exact numbers unverified)*.
Timing: minutes, not hours *(unverified)*. Automated: the demo testbed loads ten sources this way
(`integrate_sources`), but through the generic Items-XML loader, not HumanMine's own converters.

**6.5 Deploy that war to Tomcat 9 and open it** *(optional, agent-assisted)*: the war from 6.1 with the
data from 6.4 in a Tomcat 9 (the testbed's `tomcat` image will do), then the home page, a GO term report
page and a query. Automated: none for a real mine's war.

| Test | 5.1.1 result | 6.0.0 result | Notes |
|---|---|---|---|
| 6.1 HumanMine buildDB + war on the 6.0 line | n/a | | |
| 6.2 Gradle 4.9 mine on 5.1.1 | | n/a | |
| 6.3 Bio-source forks' tests | n/a | | |
| 6.4 Real load: so, go | | | |
| 6.5 Deploy the war (optional) | | | |

---

## 7. The two lines side by side

Both stacks are built from the same cached RDF Portal data, so every count must be **identical** on
5.1.1 and 6.0.0. The reference column was measured on **both** the published 5.0.8 stack and the 6.0.0
stack on 16 Nov 2026 and was the same on both.

```bash
M5=http://localhost:8090/humanmine/service M6=http://localhost:18090/humanmine/service
cnt() { curl -s "$1/query/results" --data-urlencode "query=$2" --data-urlencode format=count; }
for c in Gene Protein Pathway Publication GOTerm GWASResult Allele SNP DataSet DataSource Organism Chromosome OntologyTerm; do
  printf '%-14s %8s %8s\n' $c "$(cnt $M5 "<query model=\"genomic\" view=\"$c.id\"></query>")" "$(cnt $M6 "<query model=\"genomic\" view=\"$c.id\"></query>")"; done
for v in 'Gene.primaryIdentifier Gene.pathways.identifier' 'Pathway.identifier Pathway.proteins.primaryAccession' 'Gene.primaryIdentifier Gene.publications.pubMedId'; do
  printf '%-55s %8s %8s\n' "$v" "$(cnt $M5 "<query model=\"genomic\" view=\"$v\"></query>")" "$(cnt $M6 "<query model=\"genomic\" view=\"$v\"></query>")"; done
```

| Query | Reference (5.0.8 = 6.0.0, 16 Nov) | 5.1.1 | 6.0.0 |
|---|---|---|---|
| Gene | 113 | | |
| Protein | 13,546 | | |
| Pathway | 2,883 | | |
| Publication | 6,781 | | |
| GOTerm | 78,100 | | |
| GWASResult | 23,201 | | |
| Allele | 53,105 | | |
| SNP | 2,505 | | |
| DataSet / DataSource | 9 / 137 | | |
| Organism / Chromosome | 1 / 22 | | |
| OntologyTerm | 79,874 | | |
| gene-pathway rows | 450 | | |
| pathway-protein rows | 50,283 | | |
| gene-publication rows | 170 | | |
| CYP2D6 proteins | 58 | | |
| search `CYP2D6` hits (Publication/Allele/Gene/Protein) | 47 (38/7/1/1) | | |
| search `CYP2D6` + facet organism H. sapiens | 9 on 6.0.0; **0 on 5.0.8** (the bug) | | |
| templates / widgets | 9 / 5 | | |

**7.1 Counts.** Fill the table. Any difference between 5.1.1 and 6.0.0 is a FAIL to investigate (first
check that both stacks were built from the same cache: `full-build.sh` log). Automated: rdfc2im
`test_gene_panel_is_panel_sized`, `test_pathways_have_protein_participants`, `test_genes_have_pathways`
check shapes, not equality across lines.

**7.2 Same answers, byte for byte** (apart from the port in URLs and the `executionTime` field):
```bash
for f in tab csv json xml; do
  diff <(curl -s "$M5/query/results" --data-urlencode "query=$Q" --data-urlencode format=$f | sed -E 's/"executionTime":"[^"]*"//; s/:8090\//:PORT\//g') \
       <(curl -s "$M6/query/results" --data-urlencode "query=$Q" --data-urlencode format=$f | sed -E 's/"executionTime":"[^"]*"//; s/:18090\//:PORT\//g') \
    && echo "$f same"; done
diff <(curl -s "$M5/model") <(curl -s "$M6/model") && echo "model same"
diff <(curl -s "$M5/templates?format=xml") <(curl -s "$M6/templates?format=xml") && echo "templates same"
```
Expected: all "same". Expected differences elsewhere: `/version/intermine` (5.1.1 vs 6.0.0); possibly the
RDF output if the lines differ in RDF handling *(both carry the RDF fix; unverified that the output is
identical)*. Automated: none across lines.

**7.3 Against production HumanMine, shape only** (read-only; the data differ, the structure should not).
```bash
curl -s https://www.humanmine.org/humanmine/service/version/intermine; echo
curl -s "https://www.humanmine.org/humanmine/service/query/results" --data-urlencode "query=$Q" --data-urlencode format=json | python3 -c "import sys,json; print(sorted(json.load(sys.stdin)))"
curl -s "$M6/query/results" --data-urlencode "query=$Q" --data-urlencode format=json | python3 -c "import sys,json; print(sorted(json.load(sys.stdin)))"
```
Production HumanMine answered `"5.0.8"` on 16 Nov 2026. See the same JSON keys from both (a client
written for production works against the new versions).
Automated: mine-tests runs the same service tests against public HumanMine and the demo mine.

| Test | 5.1.1 result | 6.0.0 result | Notes |
|---|---|---|---|
| 7.1 Counts identical | | | |
| 7.2 Same answers, model, templates | | | |
| 7.3 Same JSON shape as production | | | |

---

## 8. Known limitations: what not to expect from the demo mine

From rdfc2im `BUILD.md` ("What the demo mine does not have") and what the tests skip. None of these is a
bug of 5.1.1 or 6.0.0; mark such tests N/A, not FAIL.

- **113 genes, one organism.** A food/drug-metabolism panel, not the genome: enrichment p-values and
  population counts (110) are not biologically meaningful; there is nothing from other organisms, so no
  homologues and no organism switching.
- **No GO annotations**, so no GO enrichment widget: the GO ontology (78,100 terms) is loaded, but no
  gene or protein is annotated with a term.
- **No chromosome locations and no sequences.** Chromosomes exist without lengths; no `Location` or
  `Sequence` objects. So: region search finds nothing, FASTA/GFF3/BED export and sequence sections are
  empty or absent, the chromosome distribution widgets have nothing to draw, and 23 Cypress tests skip.
- **No JBrowse**, no protein structures (PDB): structure-based tools show their own error text.
- **No Date attribute** in the model: date constraints need the mock mine of 1.10.
- **BlueGenes tools** are installed by the tool store from npm on first start; on a machine that cannot
  reach npm there are none (mine-tests treats the local mine as `has_tool_store = false`).
- **No OAuth2/OpenID Connect login and no JWT keys** configured *(unverified for OAuth2)*; no outgoing
  e-mail, so password-reset and registration e-mails do not arrive *(unverified)*.
- **The public mine registry is hidden** (`HIDE_REGISTRY_MINES=true`), so the mine switcher lists only
  the demo mine; the `@external` Cypress tests (switching to FlyMine) use the public mines instead.
- **Localhost only.** `webapp.baseurl` and the BlueGenes service root are `http://localhost:<port>`, so
  links and code snippets work only in a browser that reaches those exact ports (0.2).
- **Nothing persists across a rebuild.** Users, lists and saved queries vanish, and object ids change
  (that is why the tests look genes up by identifier).
- `/service/version/release` answers the placeholder `"@RELEASE_VERSION@"` (also on 5.0.8).
- The mine's logo comes from www.humanmine.org (its branding property), so the header logo needs the
  internet.
- The stacks' own BlueGenes on 5000/15000 is the released 1.4.5 and still loads scripts from dead or
  third-party CDNs: test the new BlueGenes on 5001/15001.

| Check | 5.1.1 result | 6.0.0 result | Notes |
|---|---|---|---|
| 8.1 Read this section before section 1 | | | |
| 8.2 Every N/A in sections 1-7 is one of the items above | | | |
