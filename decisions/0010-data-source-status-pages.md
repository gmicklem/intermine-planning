# 0010: Data-source status pages: where each kind of information lives

Status: accepted (Gos, 18 Nov 2026, in conversation). Bead im-9n4.42 (epic im-9n4).

Prompted by HumanMine's "All data sources" page (64 DataSet records with name, free-text version, URL
and sometimes a licence; no fetch date or time, nothing about which fields are loaded).

| What | Where it lives |
|---|---|
| Field mappings: what each loader reads from its source and writes to the model, and what it ignores | Beside each loader: humanmine-bio-sources for its sources, intermine for the generic ones; rdfc2im's mapping files for the RDF sources. (First version: under `rdfc2im/data/stock_mappings/`, to move upstream later.) |
| Per-build facts: URL, release, fetch date and time, checksum, licence, scope, records read, kept and loaded | A build manifest written by every build (rdfc2im `out/_mine/source_manifest.json`); not in the loader repositories, because it changes with every build |
| Status pages: one per source plus an index, with fields marked "loaded (n)" / "not loaded (n)" | Generated from the two above and committed to the **humanmine** repository (`docs/data-sources/`), not humanmine-bio-sources |
| The link from the mine | Each DataSet record links to its page; the detail itself stays out of the mine |

Counts state what they were counted over (the whole upstream file where it is cached unfiltered, else
the scoped extract) and the build scope (panel-filtered or full). Loaded fields carry counts too.

Start with the hybrid demo's sources (10 RDF, 16 or 17 stock). Related: [[0009-hybrid-humanmine-testbed]].
