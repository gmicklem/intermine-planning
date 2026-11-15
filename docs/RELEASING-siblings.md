# Releasing the three sibling libraries (human step: Clojars credentials)

Issue im-7os.19. Until this is done, everything consumes the siblings as git
dependencies (`:git/url` + `:git/sha`) because Clojars only has imcljs 1.6.0,
im-tables 0.15.x and bluegenes-tool-store 0.2.x. The pins on the branches
`maint/im-7os.19-imcljs-pin` (im-tables-3, bluegenes-tool-store) move im-tables and the
tool store from the Clojars imcljs (1.6.0 / 1.4.3) to the git sha of imcljs maint-2026
(98c0f103, 1.7.0-SNAPSHOT). The order below replaces them all with Maven coordinates.

Credentials: `build.clj` of imcljs and im-tables deploys with deps-deploy, which reads
`CLOJARS_USERNAME` (your Clojars user) and `CLOJARS_PASSWORD` (a Clojars deploy token, not
the account password). bluegenes-tool-store has no deploy task in `build.clj`; its README
says `lein deploy` (project.clj has `:deploy-repositories {"clojars" {:sign-releases false}}`
and no credential variables, so lein asks for them or reads `~/.lein/credentials.clj.gpg`).
Do not commit tokens.

## Order

Each step needs the previous one to be live on Clojars (check with
`curl -sI https://repo.clojars.org/org/intermine/<artifact>/<version>/<artifact>-<version>.pom`).

### 1. imcljs 1.7.0 (repos/imcljs, branch maint-2026)

1. `VERSION`: `1.7.0-SNAPSHOT` -> `1.7.0`; `project.clj` `(defproject org.intermine/imcljs "1.7.0-SNAPSHOT"` -> `"1.7.0"`
   (must equal VERSION); `CHANGELOG.md` heading `## Unreleased (1.7.0-SNAPSHOT)` -> `## 1.7.0 (<date>)`.
2. Commit, tag `v1.7.0` (the pom scm tag is `v<version>`).
3. `export CLOJARS_USERNAME=... CLOJARS_PASSWORD=<deploy token>`
   `clojure -T:build jar` (check `target/imcljs-1.7.0.jar`), then `clojure -T:build:deploy deploy`.
4. Bump VERSION/project.clj to `1.7.1-SNAPSHOT` (or 1.8.0-SNAPSHOT) afterwards.

### 2. im-tables 0.16.0 (im-tables-3, branch maint-2026)

1. `deps.edn`: replace
   ```clojure
   org.intermine/imcljs       {:git/url "https://github.com/gmicklem/imcljs.git"
                               :git/sha "98c0f103bbb87812c8f948c7d7478ad349298957"} ; 1.7.0-SNAPSHOT
   ```
   (and its comment) with `org.intermine/imcljs       {:mvn/version "1.7.0"}`.
2. `project.clj`: `[org.intermine/imcljs "1.6.0"]` -> `[org.intermine/imcljs "1.7.0"]` (drop the
   "lein stays" comment). The gate depcheck then compares plain versions again; the
   git-dependency tolerance proposed in the im-7os.19 gate-mod is no longer needed, but harmless.
3. `VERSION` and `project.clj` defproject: `0.16.0-SNAPSHOT` -> `0.16.0`. (The `jar` step of
   `gate-im-tables.sh` requires a SNAPSHOT version, so gate before this commit, not after.)
4. Commit, tag `v0.16.0`, then with the same two env vars:
   `npm ci && clojure -T:build jar` (compiles the CSS into the jar; check the jar contains
   `public/css/im-tables.css`), then `clojure -T:build:deploy deploy`.

### 3. bluegenes-tool-store 0.3.0 (branch maint-2026)

1. `deps.edn`: replace the imcljs git coordinate (and comment) with
   `org.intermine/imcljs {:mvn/version "1.7.0"}`.
2. `project.clj`: `[org.intermine/imcljs "1.4.3"]` -> `[org.intermine/imcljs "1.7.0"]`. This
   matters because the published pom comes from `lein deploy`, i.e. from project.clj; if
   left at 1.4.3 the released 0.3.0 would depend on imcljs 1.4.3.
3. Version `0.3.0-SNAPSHOT` -> `0.3.0` in BOTH `project.clj` (defproject line 1) and
   `build.clj` (`(def version "0.3.0-SNAPSHOT")`, line 15). Gate (the jar step wants a
   SNAPSHOT) before this commit. Commit, tag `v0.3.0`.
4. `lein deploy` (see README, "Deploying to Clojars"; use the upstream lein at
   `/home/agent/tools/lein/lein`, `LEIN_HOME=/home/agent/tools/lein/home`, with your Clojars
   credentials). Follow-up worth doing: add a `:deploy` alias to its `build.clj` like the
   other two so that the three releases use the same two env vars.

### 4. bluegenes switches back to Maven coordinates (repos/bluegenes, maint-2026)

`deps.edn` (lines 31-39 and 76-77 at 0adc0ad8):
```clojure
;; :deps
org.intermine/imcljs {:mvn/version "1.7.0"}
org.intermine/bluegenes-tool-store {:mvn/version "0.3.0"}
;; :aliases :cljs :extra-deps
org.intermine/im-tables {:mvn/version "0.16.0"}
```
and delete the comment above the first pair ("pinned as git dependencies until they are
released to Clojars (README, ...)"). Then drop the git-dependency workarounds:

- `.github/workflows/ci.yml`, job `library-jar`, lines 179-188: the "consumer" step. Remove
  the comment (lines 179-182) and the `clojure -M -e "(spit ... (filter (comp :git/sha val)) ...)"`
  line 186 that copies the git coordinates into the bare consumer `deps.edn`; keep the consumer
  `deps.edn` as just `{:deps {org.intermine/bluegenes {:mvn/version "$BLUEGENES_VERSION"}}}`
  (written with a plain `echo`/`spit`). Line 188 (`grep -E '\.jar$|/\.gitlibs/'`) can lose the
  `|/\.gitlibs/` alternative.
- `build.clj`, `git-lib-version` (line 206-215) and `pom-basis` (217-228) plus its use
  `:basis (pom-basis basis)` at line 240: they exist only to write the git dependencies into
  the pom as Maven versions; with Maven coordinates `write-pom` lists them itself, so use
  `:basis basis` and delete both functions.
- `.github/actions/setup-build/action.yml` (the `~/.gitlibs` cache path, line ~70),
  `docs/building.md` line 22 and the README line 39 paragraph about git dependencies and the
  `deps.local.edn` override: rewrite for Maven coordinates (the `:local/root` override still
  works for developing against a checkout). `bundle-hash` in `build.clj` (comment on git pins,
  line ~76) needs no change: it hashes the jars on the classpath.
- `src/clj/bluegenes/prep.clj` `copy-im-tables-css` (lines 15-43): the less-compile fallback
  for an im-tables source tree from git can stay (it only runs when the jar lacks the CSS);
  delete it only if you also want to drop the `lessc` call from bluegenes.
- Verify: `clojure -Sforce -Spath` resolves with no `.gitlibs` entries, then run the
  bluegenes gate and the CI.

Until step 3 is done, bluegenes pins the tool store at sha 8606215 (imcljs 1.4.3 in its
deps.edn); the top-level imcljs git coordinate in bluegenes wins, so this is harmless, but
move that sha to the merged im-7os.19 tool-store commit when it lands.
