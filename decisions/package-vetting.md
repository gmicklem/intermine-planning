# Package vetting log

Every time a dependency is **replaced by a different package** (not merely bumped), the worker records
the vet here, even when the verdict is "safe". Entries are for discussion with Gos.

Checklist: source fetched and read; maintainers and release cadence; install/build scripts;
network calls; eval/reflection on untrusted input; obfuscation or binary blobs; code clarity.

| Date | Repo | Replaced | With | Verdict | Reasons / notes | Issue |
|---|---|---|---|---|---|---|
