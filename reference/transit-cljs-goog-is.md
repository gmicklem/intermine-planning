# im-7os.48: goog.isArray / goog.isString in the transit bundle (finding, 16 Nov 2026)

## Where the calls really are
`com.cognitect.transit.types` (`types.print`, used by `printMap`/`printSet`, i.e. the toString of a transit map or set value) is part of **transit-js**
(`com.cognitect/transit-js`), not of transit-cljs. transit-cljs 0.8.256 only pulls it in.
Which transit-js 0.8.256 brings in depends on who reads the pom: the Maven Central pom of transit-cljs 0.8.256 says
transit-js **0.8.846**, its `project.clj` says 0.8.861; both still call `goog.isArray(x)` / `goog.isString(x)`.
The bluegenes dev build confirms it: `repos/bluegenes/target/bundle-dev/cljs-runtime/com.cognitect.transit.types.js` lines 429 and 431.
Latent only: the two calls sit in `types.print`, reached from toString of a transit map/set value, which BlueGenes never prints.

## Fix upstream
* transit-js commit `7dec8cdf` (26 Apr 2021, "goog.isArray & goog.isString removed, switch to goog.typeOf"), released as
  **transit-js 0.8.874** (tag v0.8.874; also on master): `goog.typeOf(x) === "array"` / `"string"`. Verified in the 0.8.874 jar in ~/.m2
  (`com/cognitect/transit/types.js` has no `goog.is*`). Releases 0.8.865 to 0.8.867 still have the old calls.
* transit-cljs depends on that version from **0.8.269** (commit `a82af2c1`, "update transit-js to 0.8.874") and **0.8.280** (the latest and last release,
  22 Jun 2022; nothing since except SECURITY.md in 2024). Both are on Maven Central (repo1.maven.org); 0.8.280 and transit-js 0.8.874 are already in ~/.m2.
* GitHub shows no "releases", only tags; the newest transit-cljs tag is v0.8.280, the newest transit-js tag is v0.8.874.

## Options for BlueGenes (not done here; deps.edn is another worker's)
1. Smallest change, recommended: add an explicit top-level `com.cognitect/transit-js {:mvn/version "0.8.874"}` to bluegenes `deps.edn`
   (top-level deps win over transit-cljs 0.8.256's 0.8.846/0.8.861). transit-cljs stays at 0.8.256, so no API difference.
2. Bump `com.cognitect/transit-cljs` 0.8.256 -> **0.8.280** (brings transit-js 0.8.874; shadow-cljs 2.28.18 already depends on 0.8.280 itself).
   0.8.256 -> 0.8.280 changes transit-cljs behaviour: reader option keys are renamed (`:prefersStrings` typo fixed to `:preferStrings`, kebab-case
   keys accepted), a `:default` read handler is supported, `aget/aset` become `gobj/get/set`, Transit UUID extends IUUID, write-handler config like
   transit-clj, RedNode/BlackNode handled. BlueGenes only requires `cognitect.transit` in `src/cljs/bluegenes/effects.cljs`, so it is probably fine, but
   the gate's cljs tests would need to run. cljs-http 0.1.49 asks for 0.8.256; the top-level pin overrides it.

## Gate step 4b (scripts/gate-bluegenes.sh, closure-preds)
After either option the compiled `com.cognitect.transit.types.js` no longer contains `goog.is(Array|String)`, so the allowlist
`grep -v 'com.cognitect.transit.types.js'` (line 299) and the comment on lines 295-296 can go (the step then needs no exception). Do that in the same change as the
deps bump, and check `.gate-logs/closure-preds.txt` is empty after a dev build. The planning repo's gate script is not edited here.
