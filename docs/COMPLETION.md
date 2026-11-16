# Completing the 2026 maintenance work: gates, releases and upstream pull requests

For Gos. This is the ordered list of everything between "the integration branches are green" and
"InterMine 5.1.1 and 6.0.0, the BlueGenes libraries and BlueGenes are released and merged upstream".
Work through it top to bottom. Each item says **what**, **who** (Gos, Agent = the orchestrator or a
worker it starts, Expert = an outside InterMine/ClojureScript developer), **needs** (what must be done
first), the **commands**, how to **check** it worked and how to **undo** it.

Facts below were read on **16 Nov 2026, 18:00-18:20 UTC** from the checkouts in the sandbox and from
GitHub. Anything not checked is marked *(unverified)*. Companion documents:

- [HUMAN_TESTING.md](HUMAN_TESTING.md): the manual test plan. Passing it is a gate before any tag.
- [EXPERT_TO_CHECK.md](EXPERT_TO_CHECK.md): the technical review queue.
- [HUMAN-STEPS.md](HUMAN-STEPS.md): the short list of things only you can do (this file is the long form).
- [RELEASING-siblings.md](RELEASING-siblings.md): the Clojars steps for imcljs, im-tables, tool store.
- intermine `docs/RELEASING.md` (on both branches; the 5.1.1 copy has the "5.1.1 changes" list),
  `docs/UPGRADING-build.md` (deployer migration guide), `docs/BUILDING.md`, `docs/TESTING.md`.

Nothing here is urgent. If a step does not do what it says, stop and ask the orchestrator; every step
before a Maven Central "Publish" or a pushed tag can be undone.

---

## 0. Git safety (read first)

### Rules

1. **Look before and after.** Before and after every git command that changes anything, run
   `git status` and `git log --oneline -3`. Check the branch name and the top commit are what the step
   expects.
2. **Never force-push** (`--force`, `-f`, `--force-with-lease`) to `dev`, `master`, `main`,
   `maint-2026` or `release/*`, on any remote. If git says "rejected (non-fast-forward)", stop and ask.
3. **Never push to `intermine/*` or `intermineorg/*` directly.** Code reaches them only through pull
   requests that you merge on GitHub. The one exception is a release tag, pushed from your release
   clone after Maven Central or Clojars has published (steps 4.9, 5.7, 6.x).
4. **Tags are permanent once pushed.** Other people and tools fetch them, and a version on Maven Central
   can never be changed or deleted. Create a tag locally, build and publish from it, and push it only
   after the publish succeeded.
5. **Merge pull requests with "Create a merge commit"**, never "Squash and merge" or "Rebase and merge"
   (reasons in section 7.2). On the command line: `gh pr merge <n> --merge`.
6. **Releases are built in a fresh clone** of the upstream repository, on a machine you control, never
   in the agents' worktrees.
7. **Stuck in the middle of something:** `git merge --abort`, `git rebase --abort`,
   `git cherry-pick --abort` put you back where you were. Uncommitted changes you are unsure about:
   `git stash` (keeps them). `git reset --hard` destroys uncommitted work: use it only in a throwaway
   clone.
8. **Undo:** a local commit that is not pushed: `git reset --soft HEAD~1` (keeps the changes). A pushed
   commit: `git revert <sha>` (adds a new commit). A merged pull request: the "Revert" button on the PR
   page (opens a new PR that undoes it). Never undo by rewriting history.
9. **Check who you are** before anything that pushes: `gh api user -q .login` must print `gmicklem`.

### The remotes, as configured in the sandbox checkouts

The checkouts under `/Users/gos/claude_projects/update_intermine_planning/repos/` (visible on your Mac)
do not use the remote names consistently. **In most of them `origin` is the upstream InterMine
repository, and your account has admin rights there**, so `git push origin ...` would really push to
InterMine. Output of `git remote -v` (fetch and push URLs are the same in every case):

| Checkout (`repos/...`) | `origin` | `fork` | `upstream` |
|---|---|---|---|
| `intermine` (and every `worktrees/intermine/*`) | intermine/intermine | gmicklem/intermine | - |
| `bluegenes` | **gmicklem/bluegenes** | gmicklem/bluegenes | **not configured** |
| `imcljs` | intermine/imcljs | gmicklem/imcljs | - |
| `im-tables-3` | intermine/im-tables-3 | gmicklem/im-tables-3 | - |
| `bluegenes-tool-store` | intermine/bluegenes-tool-store | gmicklem/bluegenes-tool-store | - |
| `humanmine` | intermine/humanmine | gmicklem/humanmine | - |
| `flymine` | intermine/flymine | gmicklem/flymine | - |
| `humanmine-bio-sources` | **gmicklem/humanmine-bio-sources** | - | intermine/humanmine-bio-sources |
| `flymine-bio-sources` | **gmicklem/flymine-bio-sources** | - | intermine/flymine-bio-sources |
| `mine-tests` | intermineorg/mine-tests | gmicklem/mine-tests | - |
| `rdfc2im` | intermineorg/rdfc2im | gmicklem/rdfc2im | - |
| `intermine-planning` | gmicklem/intermine-planning | - | - |

In your fresh release clones (sections 4-6) `origin` is the upstream repository, because you clone it
from there. That is intended: the only thing you push from them is the release tag.

- [ ] **0.1 Make accidental pushes to upstream impossible in the sandbox checkouts.**
  Who: Agent. Needs: nothing. Commands (one per upstream remote; the fetch URL stays, so fetching still works):
  ```bash
  R=/Users/gos/claude_projects/update_intermine_planning/repos
  for r in intermine imcljs im-tables-3 bluegenes-tool-store humanmine flymine mine-tests rdfc2im; do
    git -C $R/$r remote set-url --push origin DISABLED; done
  for r in humanmine-bio-sources flymine-bio-sources; do
    git -C $R/$r remote set-url --push upstream DISABLED; done
  git -C $R/bluegenes remote add upstream https://github.com/intermine/bluegenes.git
  git -C $R/bluegenes remote set-url --push upstream DISABLED
  git -C $R/bluegenes fetch upstream --tags
  ```
  Check: `git -C $R/intermine remote -v` shows `origin DISABLED (push)`. Undo:
  `git -C $R/<repo> remote set-url --push origin <the fetch URL>`.

### Where things live

- `repos/` is your Mac's disk (mounted into the sandbox). `worktrees/`, `/home/agent` and the Docker
  volumes of the demo stacks are on the sandbox's own 20 GB disk: **invisible on the Mac and lost when
  the sandbox is removed**. Everything that matters is pushed to a `gmicklem/*` fork; step 8.3 checks
  that before the sandbox goes.
- The intermine checkout used below for counts is `worktrees/intermine/merge-maint-2026` (branch
  `maint-2026`, a worktree of `repos/intermine`).

---

## 1. State today (16 Nov 2026, 18:15 UTC)

"Over upstream" counts commits on the integration branch that the upstream default branch lacks
(`git rev-list --count <upstream>..<branch>`, non-merge commits in brackets); every listed branch is
already pushed to its `gmicklem/*` fork at the same head, and none is behind its upstream except intermine (see the note below the table).

| Repo | Integration branch (on the gmicklem fork) | Head | CI on that head | Over upstream | What it is, in one line |
|---|---|---|---|---|---|
| intermine, 6.0.0 line | `maint-2026` | `5351d0c301` | InterMine CI and Checkstyle running (dispatched 18:00); previous head `dab8b39d01` green | 278 (212) over intermine/intermine `dev` `787f779b7a` | Gradle 8.14.6, build on JDK 17 (8 and 21 work), version 6.0.0 in one catalog entry, Tier 1 security bumps, Byte Buddy for cglib, own DDL generator for Torque, commons-lang3 only, Central Portal publishing, new CI, webapp/API bug fixes |
| intermine, 5.1.1 line | `release/5.1.1-candidate` | `b9355b129e` | both green (16:29) | 100 (87) | Gradle 6.9.4, JDK 8, Tier 1 security fixes and the 22 items of "5.1.1 changes" in its RELEASING.md; its plugin still runs in Gradle 4.9 mines |
| bluegenes | `maint-2026` | `38260724` | CI green (17:09); Nightly Cypress last green at `31b3d59a`, 20 commits older | 142 (119) over intermine/bluegenes `dev` `9f340692` | shadow-cljs + deps.edn, React 18 / reagent 1.2 / re-frame 1.4, Node 22, Cypress 13, GitHub Actions CI and nightly end-to-end run, keystroke patch, list-save fix; version `1.5.0-SNAPSHOT`; siblings as git dependencies |
| imcljs | `maint-2026` | `d96a3eb` | no CI on the fork (CircleCI config only); local gate | 12 (10) over `dev` `920f7180` | deps.edn/tools.build, list save from results fixed; `1.7.0-SNAPSHOT` |
| im-tables-3 | `maint-2026` | `1be6530` | as imcljs | 40 (30) over `dev` `b972ded2` | deps.edn, filter/dropdown/toolbar fixes, code export without cdn.intermine.org; `0.16.0-SNAPSHOT` |
| bluegenes-tool-store | `maint-2026` | `da4f23b` | no CI | 19 (15) over `master` `676831b2` | deps.edn, path containment and package-name validation, tarball integrity, cookie policy; `0.3.0-SNAPSHOT` |
| humanmine | `maint-2026` | `c0731c5` | no CI | 9 (5) over `master` `afdd8e9c` | build files converted to Gradle 8.14.6 and InterMine `6.0.+` |
| flymine | `maint-2026` | `118eb07a` | no CI | 9 (5) over `master` `a507ed84` | same as humanmine |
| humanmine-bio-sources | `maint-2026` | `20ad5a2` | green (16 Nov 19:45 UTC): the job builds InterMine `maint-2026` itself until 6.0.0 is on Central | 10 over `master` `3456960` | converted to the 6.0 line (Gradle 8.14.6, maven-publish, commons-lang3) |
| flymine-bio-sources | `maint-2026` | `e9af505` | green (16 Nov 19:45 UTC), same mechanism | 9 over `master` `18f5ede` | same |
| mine-tests | `maint-2026` | `cbbef24` | no run on this branch | 7 (6) over intermineorg `main` `f5bf8d00` | `[mines.local]` demo-mine entry, capability flags, `MINE_TESTS_BROWSER_PATH` |
| rdfc2im | `maint/im-ore.1-intermine-src` (plus `maint/im-rkn.5-testbed-baseline`) | `27da569` | not checked | 25 over intermineorg `main` | `--intermine-src`, `--stack-name`, offline cache, demo-data fixes |
| intermine-planning | `main` | `65303aa` | - | - | plans, decisions, gates, status (this repo) |

Notes:

- **Upstream intermine `dev` moved on 11 Nov**: `787f779b7a` adds two commits (a README update of the
  mine list by the intermineorg account) that neither of our intermine branches has. A trial merge
  (`git merge-tree`) shows both `release/5.1.1-candidate` and `maint-2026` merge into it **without
  conflicts**. The local `origin/dev` ref in the sandbox is stale (`77cf7068da`): fetch before counting.
- **`release/5.1.1-candidate` and `maint-2026` conflict with each other in about 34 files** (the 5.1.1
  fixes are backports, not identical commits). This matters only after 5.1.1 is merged into upstream
  `dev`; step 5.1 deals with it.
- Last releases: intermine `intermine-5.1.0` (26 Aug 2022, annotated tag on `master`, message
  "InterMine 5.1.0", GitHub release "InterMine 5.1.0 (RDF & SPARQL)"); BlueGenes `v1.4.5`; Clojars
  has bluegenes 1.4.5, imcljs 1.6.0, im-tables 0.15.0, bluegenes-tool-store 0.2.3.
- `gmicklem/intermine`'s default branch is `maint-2026`; the others keep upstream's default.
- The demo testbed: default stack (`:8090` mine, `:5000` BlueGenes) runs the **published 5.0.8**
  artefacts (`/service/version` 34, `/service/version/intermine` "5.0.8"); the `ut` stack (`:18090`,
  `:15000`) is down, being rebuilt from `maint-2026`. Both stacks serve the **released BlueGenes
  1.4.5**, not `maint-2026` BlueGenes (HUMAN_TESTING.md section 0 explains how the new one is started).

---

## 2. Freeze and final gates

Nothing is tagged until every box in this section is ticked. The agent steps are listed so you can see
what "the orchestrator ran the gates" means.

- [ ] **2.1 Freeze.** Who: Agent. Needs: the open beads that are meant for this release merged (or
  deferred in writing). What: stop merging into `maint-2026` and `release/5.1.1-candidate` in every repo;
  record the frozen heads in `status/LOG.md` as "Freeze" with one line per repo (same columns as the table
  in section 1). Any later change goes through a task branch, a full gate and a new LOG line. Check:
  `git -C <repo> rev-parse --short fork/maint-2026` equals the LOG line. Undo: lift the freeze in a new
  LOG line.

- [ ] **2.2 intermine full gates on both lines.** Who: Agent. Commands (from the planning repo; one task
  env per run, as the gate requires):
  ```bash
  cd /Users/gos/claude_projects/update_intermine_planning/repos/intermine-planning
  # 6.0.0 line on JDK 17 and on JDK 8
  eval "$(scripts/im-testenv.sh freeze-60 create --src /Users/gos/claude_projects/update_intermine_planning/worktrees/intermine/merge-maint-2026)"
  export GATE_CLEAN=1
  export GATE_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
  scripts/gate-intermine.sh /Users/gos/claude_projects/update_intermine_planning/worktrees/intermine/merge-maint-2026
  export GATE_JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
  scripts/gate-intermine.sh /Users/gos/claude_projects/update_intermine_planning/worktrees/intermine/merge-maint-2026
  # 5.1.1 line on JDK 8 (its Gradle 6.9.4 does not run on 17), in a detached worktree at the frozen head
  git -C /Users/gos/claude_projects/update_intermine_planning/repos/intermine worktree add --detach /Users/gos/claude_projects/update_intermine_planning/worktrees/intermine/freeze-511 b9355b129e
  eval "$(scripts/im-testenv.sh freeze-511 create --src /Users/gos/claude_projects/update_intermine_planning/worktrees/intermine/freeze-511)"
  export GATE_CLEAN=1 GATE_JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64
  scripts/gate-intermine.sh /Users/gos/claude_projects/update_intermine_planning/worktrees/intermine/freeze-511
  ```
  Check: exit status 0 and `ALL TESTS PASSED`; test counts not below the baseline
  (`baselines/intermine-2026-11-15.md`; the two `testBatchesCache` tests are known to be flaky). Takes
  6-9 minutes per run on the baseline line, longer with `GATE_CLEAN=1` *(6.0 timing unverified)*. At most
  two at once (15 GB RAM).

- [ ] **2.3 CI on GitHub for the frozen heads.** Who: Agent. CI on `gmicklem/intermine` does not start on
  push from the sandbox, so dispatch it:
  ```bash
  for b in maint-2026 release/5.1.1-candidate; do for w in im-build.yml checkstyle.yml; do
    gh workflow run $w --repo gmicklem/intermine --ref $b; done; done
  gh run list --repo gmicklem/intermine -L 8      # wait for 4 x "completed success"
  ```
  BlueGenes CI runs on push (green at `38260724`). Check: every row "success" for the frozen sha.

- [ ] **2.4 BlueGenes and sibling gates, nightly Cypress on the frozen head.** Who: Agent.
  ```bash
  cd /Users/gos/claude_projects/update_intermine_planning/repos/intermine-planning
  scripts/gate-bluegenes.sh <bluegenes worktree at 38260724> --with-prod
  scripts/gate-imcljs.sh <imcljs worktree>; scripts/gate-im-tables.sh <im-tables worktree>; scripts/gate-tool-store.sh <tool-store worktree>
  gh workflow run nightly-cypress.yml --repo gmicklem/bluegenes --ref maint-2026
  gh run list --repo gmicklem/bluegenes -w nightly-cypress.yml -L 1   # "success", about 20 minutes
  ```
  The nightly does not run by itself: the schedule only fires from the default branch (`dev`), which has
  no such workflow. Check: all PASS; the nightly's job summary shows 0 failed (the 23 skipped are the
  region and sequence specs, which need Location data the demo mine does not have).

- [ ] **2.5 Release-time sweeps on both lines** (RELEASING.md, "Changelog and tag", items 2 and 3). Who:
  Agent. The EL sweep (`docs/tools/ElSweep.java` with the newest Tomcat 9 `el-api.jar`/`jasper-el.jar`,
  must print `failures=0`), the three webapp sweeps of `docs/tools/README-webapp-sweeps.md`
  (`msgkeys.py` "unused 0", `tilescheck.py` silent, `classrefs.py` silent), and the `cdn.intermine.org`
  grep plus `sha256sum -c SHA256SUMS` in `intermine/webapp/src/main/webapp/vendor`. Check: as stated;
  results in a LOG line.

- [ ] **2.6 Testbed rebuilds of both lines, side by side.** Who: Agent. Needs: 2.2 green. The default
  stack (`:8090`/`:5000`) is rebuilt from the 5.1.1 candidate, the `ut` stack (`:18090`/`:15000`) from
  `maint-2026`; same cached data, so the two mines must hold identical data. The stacks run one at a time
  (about 9 GB peak each); run with the per-stack `TRIAL_HOME`/`HOME`/`RDFC2IM_DATA_ROOT` the orchestrator
  already uses for `ut` (rdfc2im `BUILD.md`, "A second stack").
  ```bash
  cd /Users/gos/claude_projects/update_intermine_planning/worktrees/rdfc2im/im-ore.1-intermine-src
  tools/full-build.sh --use-cached-data --intermine-src /Users/gos/claude_projects/update_intermine_planning/worktrees/intermine/freeze-511
  export MINE_BASE=http://localhost:8090/humanmine SOLR_BASE=http://localhost:8983
  make test-live
  tools/full-build.sh --use-cached-data --intermine-src /Users/gos/claude_projects/update_intermine_planning/worktrees/intermine/merge-maint-2026 --stack-name ut
  export MINE_BASE=http://localhost:18090/humanmine SOLR_BASE=http://localhost:18983
  make test-live
  cd /Users/gos/claude_projects/update_intermine_planning/repos/mine-tests
  /home/agent/venvs/mine-tests/bin/python -m pytest --mine local tests/service          # default stack (5.1.1)
  export MINE_TESTS_LOCAL_URL=http://localhost:15000 MINE_TESTS_LOCAL_SERVICE_URL=http://localhost:18090/humanmine/service
  /home/agent/venvs/mine-tests/bin/python -m pytest --mine local tests/service          # ut stack (6.0.0)
  ```
  Check: `curl -s localhost:8090/humanmine/service/version/intermine` prints `"5.1.1"` and
  `curl -s localhost:18090/humanmine/service/version/intermine` prints `"6.0.0"` (checked on the `ut`
  stack at 18:30 UTC; the 5.1.1 string is unverified, the published 5.0.8 printed "5.0.8"); `make test-live` 20/20 on both; mine-tests failures only the known
  CDN/favicon ones listed in its README. About 10 minutes per stack with warm caches.

- [ ] **2.7 Bundle rehearsal (the Central bundle has never been uploaded).** Who: Agent. In a scratch
  copy of each frozen intermine head, with a throwaway GPG key in a temporary `GNUPGHOME`, run the five
  `centralBundle` builds of RELEASING.md section 3 and inspect the zips as in its step 3 (every artefact
  with `.asc`, `.md5`, `.sha1`; no `maven-metadata*`; `intermine-webapp` POM packaging `war`; POM has
  name, description, url, licence, developers and scm). Delete the throwaway key afterwards. This finds
  layout problems before you spend a Portal upload on them. (Signatures from a throwaway key would fail
  Portal validation, so nothing is uploaded.) `central.sonatype.com` answered HTTP 200 from the sandbox at
  18:10 UTC, so a real upload from the sandbox may now be possible *(unverified)*.

- [ ] **2.8 Manual testing gate.** Who: **Gos**. Needs: 2.6 (both stacks up) and the new BlueGenes started
  on `:5001`/`:15001` (HUMAN_TESTING.md section 0). Work through [HUMAN_TESTING.md](HUMAN_TESTING.md),
  filling in its tables. **Pass rule:** no FAIL in sections 1-3 and 7 for the line being released, or
  each FAIL has a bead that is either fixed (then the affected gate in 2.2-2.6 is re-run) or accepted by
  you in writing as a known issue for the release notes. Sections 4-6 may be finished after 5.1.1, but
  before 6.0.0. Commit the filled-in file (the agent can do it for you).

- [ ] **2.9 Go / no-go.** Who: **Gos**. Write one line in `status/LOG.md` (or tell the orchestrator):
  "Go 5.1.1 at b9355b129e" (and later "Go 6.0.0 at <sha>"). Undo: a "No-go" line.

---

## 3. Expert review

[EXPERT_TO_CHECK.md](EXPERT_TO_CHECK.md) has six open items. You have decided all of them; the review is
a second opinion from someone who knows InterMine's history, not a blocker that the agents can clear.

| # | Item | Lines affected | Hit by | Must be reviewed before | Reversion (from the entry) |
|---|---|---|---|---|---|
| 1 | KeySigner: hand-written X.509 writer replaces Bouncy Castle | 5.1.1 and 6.0.0 | mines with `security.publickey.*` (JWT keys); not HumanMine/FlyMine | 5.1.1 tag, ideally; low risk | restore bcprov at a current version + revert `KeySigner` (one dependency line plus a small revert) |
| 2 | BlueGenes reagent input monkey-patch (`a2894c0d`) | BlueGenes 1.5.0 | every text input | BlueGenes PR merge (6.7) | revert `a2894c0d` and use uncontrolled inputs instead (larger change) |
| 3 | Byte Buddy replaces cglib (`fb900f033f`, `f7dfc76a7b`) | 6.0.0 | multi-class objects (`DynamicBean`) | 6.0.0 tag | `git revert f7dfc76a7b fb900f033f` and restore the cglib dependency |
| 4 | bio-source POMs: most dependencies in runtime scope | 5.1.1 and 6.0.0 | deployers compiling against bio-source jars | 5.1.1 tag, ideally | `implementation` -> `api` in `bio/sources/build.gradle` and `bio/postprocess/build.gradle`; check the POMs show `compile` |
| 5 | chado-db `SequenceProcessor` always-true comparison kept | both (unchanged behaviour) | chado loads (FlyMine-style) | nothing (behaviour unchanged) | none needed; the fix, if wanted, is `!Objects.equals(currentFeatureId, featureId)` |
| 6 | Own DDL generator replaces Torque/velocity (`e16f6f194d`, `a554fdc28b`) | 6.0.0 | every `buildDB` | 6.0.0 tag | `git revert a554fdc28b e16f6f194d` |

- [ ] **3.1 Find reviewers.** Who: **Gos**. Candidates are people who released InterMine before: the
  5.1.0 tag was made by Daniela Butano, and the Clojars `org.intermine` group lists `dani`, `julie`,
  `sergio`, `uosl` and `yo` (Java items 1, 3-6: an InterMine back-end developer; item 2: a ClojureScript
  developer, ideally one who knows reagent).
- [ ] **3.2 Hand it over.** Who: **Gos** (the agent can draft the text). Open one GitHub issue on
  `gmicklem/intermine-planning` per reviewer, or a single one with a checklist, titled "Review request:
  EXPERT_TO_CHECK items 1-6", linking the file at its commit
  (`https://github.com/gmicklem/intermine-planning/blob/<sha>/docs/EXPERT_TO_CHECK.md`), the commits named
  in each entry, `decisions/package-vetting.md` and, for item 2, `decisions/0007-reagent-input-patch.md`
  and `docs/drafts/reagent-issue-keystrokes.md`. Add the reviewers as reviewers of the upstream PRs too
  (section 7) so their comments land where the code is.
- [ ] **3.3 Act on the verdicts.** Who: Agent (a task branch per change, full gate, then the testbed),
  Gos decides. A verdict "revert" before a release means the reversion above on a task branch, gated,
  merged, then 2.2-2.6 again for that line. After a release it means a patch release (5.1.2 / 6.0.1).
  Move each checked item to the bottom of EXPERT_TO_CHECK.md with the reviewer's verdict and date.

---

## 4. Release InterMine 5.1.1 (from `release/5.1.1-candidate`)

The InterMine guide's release process: the release manager merges `dev` into `master`, tags that merge
with the version and publishes release notes on the Releases page (section 7.1). As admin of
`intermine/intermine` you are the release manager. So: 5.1.1 goes into `dev` by pull request, `dev`
into `master` by pull request, and the tag `intermine-5.1.1` goes on the `master` merge commit, which
is what gets built and published.

### One-time setup (start these now: they may take days)

- [ ] **4.1 Maven Central Portal access to the `org.intermine` namespace.** Who: **Gos**. The namespace
  belongs to whoever published 5.1.0 through the old OSSRH service; OSSRH accounts were moved to the
  Central Portal in 2025 *(unverified for this account)*. Either (a) the current owner logs in at
  https://central.sonatype.com and gives your Portal account access to `org.intermine`, or (b) you ask
  Central support to transfer it, which may require proving control of the `intermine.org` domain with a
  DNS TXT record *(unverified)*; who controls that DNS is an open question in
  [INTERMINE_ORG_HOSTING.md](INTERMINE_ORG_HOSTING.md). Check: Portal, Publishing > Namespaces, lists
  `org.intermine` as verified for your account. Nothing in sections 4-5 can be published without this.
- [ ] **4.2 Portal user token.** Who: **Gos**. Portal > Account > Generate User Token. It has a username
  and a password part (not your login password). Keep both in your password manager.
- [ ] **4.3 GPG signing key.** Who: **Gos**. On the machine you will release from:
  ```bash
  gpg --full-generate-key                         # RSA 4096 (or ed25519), your name, gmicklem@... address, a passphrase
  gpg --list-secret-keys --keyid-format long      # note the key id after "sec   rsa4096/"
  gpg --keyserver keys.openpgp.org --send-keys <KEYID>   # keys.openpgp.org e-mails you a link to publish the identity
  gpg --keyserver keyserver.ubuntu.com --send-keys <KEYID>
  gpg --armor --export-secret-keys <KEYID> > ~/intermine-signing-key.asc   # back it up offline, then delete this file
  ```
  Check: `curl -s "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x<KEYID>" | head -1` prints
  `-----BEGIN PGP PUBLIC KEY BLOCK-----`. Undo: `gpg --delete-secret-and-public-key <KEYID>` (before use).
- [ ] **4.4 A machine to release from.** Who: **Gos**. You need JDK 8 (for 5.1.1; its Gradle 6.9.4 does
  not run on 17), JDK 17 (for 6.0.0), git, curl, unzip, Python 3.10+, gpg. Two options:
  (a) your Mac: Temurin 17 from adoptium.net; for JDK 8 on Apple silicon, Azul Zulu 8 has an arm64 build
  *(unverified)*; or (b) the sandbox, which has `/usr/lib/jvm/java-8-openjdk-arm64` and
  `java-17-openjdk-arm64`, from a terminal you open yourself (not through the Claude chat), with a
  release-only signing subkey. Never paste a token or key into the chat.

### The release

- [ ] **4.5 Prepare the release branch.** Who: Agent. Needs: 2.9 "Go 5.1.1". On
  `release/5.1.1-candidate`: add the `InterMine 5.1.1 (<month> 2026)` section at the top of
  `RELEASE_NOTES` (the file still starts with 5.1.0; same format: one line per change, from the 22 items
  of "5.1.1 changes" in its `docs/RELEASING.md`), gate, push to `fork`. Draft the PR text from the
  template in 7.4 into `docs/drafts/pr-intermine-5.1.1.md` in this repo. Check: `git -C <worktree> show
  HEAD:RELEASE_NOTES | head -12`.
- [ ] **4.6 Pull request 5.1.1 -> intermine `dev`.** Who: **Gos**.
  ```bash
  gh api user -q .login        # gmicklem
  gh pr create --repo intermine/intermine --base dev --head gmicklem:release/5.1.1-candidate \
    --title "InterMine 5.1.1: Gradle 6.9.4, security fixes and bug fixes" \
    --body-file /Users/gos/claude_projects/update_intermine_planning/repos/intermine-planning/docs/drafts/pr-intermine-5.1.1.md
  ```
  Check: the PR page shows "Able to merge", both checks ("InterMine CI", "Checkstyle") green (they run in
  `intermine/intermine`'s Actions; the PR diff is large, about 126,000 added lines, mostly the vendored
  JavaScript of `vendor/`). Undo: close the PR.
- [ ] **4.7 Merge it.** Who: **Gos**, after any reviewer comments. On the PR page choose **"Create a merge
  commit"** in the merge button's menu, or `gh pr merge <n> --repo intermine/intermine --merge`.
  Check: `git ls-remote https://github.com/intermine/intermine refs/heads/dev` shows a new sha whose
  commit is "Merge pull request #<n> from gmicklem/release/5.1.1-candidate". Undo: the PR's "Revert"
  button.
- [ ] **4.8 `dev` -> `master`.** Who: **Gos**.
  ```bash
  gh pr create --repo intermine/intermine --base master --head dev --title "Release InterMine 5.1.1" \
    --body "Release 5.1.1: merges dev into master (contribution guide, Release Process)."
  gh pr merge <n> --repo intermine/intermine --merge
  ```
  Check: `git ls-remote https://github.com/intermine/intermine refs/heads/master` changed; then the
  Agent runs the full gate (2.2, JDK 8) on exactly that `master` sha and reports green. Undo: Revert PR.
- [ ] **4.9 Tag, build, upload, publish, push the tag.** Who: **Gos**. Needs: 4.1-4.4, 4.8 gate green.
  ```bash
  mkdir -p ~/intermine-release && cd ~/intermine-release
  git clone https://github.com/intermine/intermine.git intermine-5.1.1 && cd intermine-5.1.1
  git checkout master && git status && git log --oneline -3     # top: "Merge pull request #<n> from intermine/dev"
  git tag -a intermine-5.1.1 -m "InterMine 5.1.1"               # local only for now
  git describe --exact-match                                    # prints intermine-5.1.1
  export JAVA_HOME=<JDK 8 home> PATH=<JDK 8 home>/bin:$PATH; java -version   # 1.8
  export LANG=C.UTF-8 LC_ALL=C.UTF-8 PSQL_HOST=localhost PSQL_USER=test PSQL_PWD=test
  export SIGNING_KEY="$(gpg --armor --export-secret-keys <KEYID>)" SIGNING_PASSWORD='<passphrase>'
  export CENTRAL_USERNAME='<token user part>' CENTRAL_PASSWORD='<token password part>'
  python3 -I config/lib/install_intermine.py --clean           # writes gradle.properties, installs the jars locally
  for b in plugin intermine bio bio/sources bio/postprocess; do
    (cd $b && ./gradlew --no-daemon centralBundle) || break; done   # 5 x BUILD SUCCESSFUL
  unzip -Z1 intermine/build/central-bundle/intermine-bundle.zip | grep -v '/$' | head -30   # .asc .md5 .sha1 beside each file
  ```
  Then upload, as RELEASING.md section 3 step 4, with one change for macOS (`base64` there has no `-w0`):
  ```bash
  TOKEN=$(printf '%s:%s' "$CENTRAL_USERNAME" "$CENTRAL_PASSWORD" | base64 | tr -d '\n')
  for z in plugin/build/central-bundle/plugin-bundle.zip intermine/build/central-bundle/intermine-bundle.zip \
           bio/build/central-bundle/bio-bundle.zip bio/sources/build/central-bundle/bio-sources-bundle.zip \
           bio/postprocess/build/central-bundle/bio-postprocess-bundle.zip; do
    n=$(basename "$z" .zip)
    curl --fail-with-body -sS -X POST -H "Authorization: Bearer $TOKEN" -F "bundle=@$z" \
      "https://central.sonatype.com/api/v1/publisher/upload?name=$n-5.1.1&publishingType=USER_MANAGED"
    echo "  <- deployment id for $n"; done
  ```
  Wait until https://central.sonatype.com/publishing/deployments shows **all five VALIDATED**. Only then
  press Publish on each of the five (one after the other, within a few minutes). **Publishing cannot be
  undone.** Then:
  ```bash
  git push origin intermine-5.1.1          # origin of this clone is intermine/intermine
  ```
  Check: after up to an hour `https://repo1.maven.org/maven2/org/intermine/plugin/5.1.1/` and
  `.../intermine-webapp/5.1.1/` list the war, `-classes`, `-sources`, `-javadoc`, POM and `.asc` files.
  Undo before Publish: drop the deployments in the Portal and `git tag -d intermine-5.1.1`. After
  Publish: none (a fix is 5.1.2).

  **If the upload or validation fails** (nothing is public until you press Publish):

  | Symptom | Cause | What to do |
  |---|---|---|
  | `curl` returns 401 or 403 | token wrong (account password used, or parts swapped), or no rights on `org.intermine` | regenerate the token (4.2); check the namespace page (4.1) |
  | Deployment FAILED: "Namespace not verified" | 4.1 not done | 4.1, then upload again |
  | FAILED: invalid signature / public key not found | key not on a keyserver yet, or keys.openpgp.org identity not confirmed | 4.3 check, wait 15 minutes, drop and upload again |
  | FAILED: missing checksum or signature | bundle not made by `centralBundle`, or edited by hand | rebuild with the loop above |
  | FAILED: POM missing name/description/url/licence/developers/scm, or missing javadoc/sources | publishing configuration (`config/gradle/publishing.gradle`) | drop all five; Agent fixes it on a branch; a new PR to `dev`, `dev` -> `master`, delete the local tag (`git tag -d intermine-5.1.1`) and restart 4.9 on the new `master` |
  | Four VALIDATED, one FAILED | any of the above for that bundle | do **not** publish the four; drop all five, fix, upload all five again |
  | Stuck in VALIDATING for over an hour | Portal side | wait; then Central support *(contact route unverified)* |
  | `centralBundle` stops: "needs the armoured PGP private key" / "No signatory" | `SIGNING_KEY` empty, wrong passphrase, or a subkey needs `SIGNING_KEY_ID` | RELEASING.md "Troubleshooting" |

- [ ] **4.10 GitHub release and README badge.** Who: **Gos** (release), Agent (badge PR). Release:
  https://github.com/intermine/intermine/releases/new, tag `intermine-5.1.1`, title "InterMine 5.1.1",
  body: the `RELEASE_NOTES` 5.1.1 section plus a link to `docs/UPGRADING-build.md` ("5.0.x or 5.1.0 to
  5.1.1"). The README badge (`badge/version-5.1.0-blue`) names the last *published* version: the Agent
  raises it to 5.1.1 in a small PR to `dev` (and in `maint-2026`). Check: the release page shows the tag.
- [ ] **4.11 After 5.1.1.** Who: Agent. RELEASING.md section 5 checks (POM against 5.1.0, resolve from a
  clean cache with only Maven Central); rebuild the default testbed stack from the published 5.1.1
  without `--intermine-src` *(the published-artefact path of `full-build.sh` is pinned to 5.0.8 today;
  needs a small change)*.

---

## 5. Release InterMine 6.0.0 (from `maint-2026`, after 5.1.1)

- [ ] **5.1 Bring `maint-2026` up to the new `dev`.** Who: Agent. Needs: 4.8. Upstream `dev` now contains
  the 5.1.1 backports, which conflict with their originals in about 34 files.
  ```bash
  W=/Users/gos/claude_projects/update_intermine_planning/worktrees/intermine/merge-maint-2026
  git -C $W fetch origin && git -C $W status && git -C $W log --oneline -3
  git -C $W log --no-merges --cherry-pick --right-only --oneline maint-2026...release/5.1.1-candidate   # 33 lines today
  git -C $W merge --no-ff origin/dev
  ```
  Resolve each conflict towards the `maint-2026` version, after checking that each of the 33 5.1.1-only
  commits listed is superseded on `maint-2026` (they are backports of `maint-2026` commits, but the
  RELEASE_NOTES 5.1.1 entry and any 5.1.1-only wording must survive). Then full gates (2.2, JDK 17 and 8),
  CI (2.3), testbed `ut` (2.6), nightly (2.4) on the merge, push to `fork`. Check: `git -C $W rev-list
  --count maint-2026..origin/dev` prints 0; gates green. Undo before push: `git -C $W merge --abort` or
  `git -C $W reset --hard fork/maint-2026` (this worktree only).
- [ ] **5.2 Release notes for 6.0.0.** Who: Agent. `RELEASE_NOTES` section "InterMine 6.0.0", leading
  with the breaking changes and pointing to `docs/UPGRADING-build.md` as the migration guide: mines must
  move to Gradle 8.14.6 with the 6.0.0 plugin and `imVersion`/`bioVersion` `6.0.+`; build on JDK 17 (8 still
  works, with a Gradle deprecation notice; jars are Java 8 bytecode); cglib gone (Byte Buddy); commons-lang
  2 gone from every classpath; Torque gone (`schemafile` ignored); OpenID 2.0 login, Bouncy Castle and
  Xalan removed; DWR exposes only listed methods; bio-source POM scopes; registry lookup timeouts; plus the
  5.1.1 items. Gos reads and approves the text.
- [ ] **5.3 Expert review items 3 and 6 answered** (or accepted by you as is). Who: Gos.
- [ ] **5.4 Manual testing of the 6.0.0 column complete** (HUMAN_TESTING.md sections 1-8) and "Go 6.0.0 at
  <sha>" (2.9). Who: Gos.
- [ ] **5.5 Pull request `maint-2026` -> intermine `dev`, merge, then `dev` -> `master`.** Who: **Gos**.
  As 4.6-4.8 with `--head gmicklem:maint-2026`, title "InterMine 6.0.0: Gradle 8.14, JDK 17, dependency
  and security modernisation", body from `docs/drafts/pr-intermine-6.0.0.md` (Agent drafts it, 7.4).
  Merge commits both times. Then the Agent gates the `master` sha on JDK 17.
- [ ] **5.6 Tag, build, upload, publish.** Who: **Gos**. As 4.9, with these differences: clone into
  `~/intermine-release/intermine-6.0.0`; tag `intermine-6.0.0` with message "InterMine 6.0.0"; JDK 17;
  first check `grep '^intermine = ' gradle/libs.versions.toml` prints `intermine = "6.0.0"`; `name=$n-6.0.0`
  in the upload URL. Same failure table.
- [ ] **5.7 Push the tag, GitHub release, badge.** Who: Gos / Agent. `git push origin intermine-6.0.0`;
  GitHub release "InterMine 6.0.0" with the RELEASE_NOTES section and a prominent link to
  `docs/UPGRADING-build.md` ("5.1.1 to 6.0.0"); README badge to 6.0.0 (Agent, PR).
- [ ] **5.8 Mine and bio-source forks against the published 6.0.0.** Who: Agent. `humanmine`, `flymine`,
  `humanmine-bio-sources`, `flymine-bio-sources` already ask for `6.0.+` on `maint-2026`. With only Maven
  Central (no `mavenLocal()` content): `./gradlew --refresh-dependencies :dbmodel:tasks` in each mine
  resolves the plugin; publish the bio-source forks to `mavenLocal` and build each mine's war
  (UPGRADING-build.md, "Check"); remove the "build InterMine maint-2026 in the job" steps from the bio-sources workflows (their CI is
  green with them since 16 Nov). Whether the bio-source
  repositories are themselves published to Central is your call (HUMAN-STEPS.md item 6; same Portal
  credentials).
- [ ] **5.9 Testbed re-pin.** Who: Agent. rdfc2im: the `--intermine-src` path needs no change (it reads the
  version from the checkout); add or switch the published-artefact path from 5.0.8 to 6.0.0 and BlueGenes
  from 1.4.5 to 1.5.0 once that is out (6.8); re-pin BlueGenes' nightly (`RDFC2IM_REF` in
  `.github/workflows/nightly-cypress.yml`) to the rdfc2im commit that does so.
- [ ] **5.10 Announce.** Who: **Gos**. The guide: "announcements are posted on twitter and the mailing lists
  and discussed in detail on the community calls". A short post: what 6.0.0 is (maintenance major
  release, no data-model change), who must act (every mine: build upgrade, `UPGRADING-build.md`), that
  5.1.1 is the drop-in update for mines that cannot move yet, and the support route (GitHub issues).
  Whether the `intermine/im-docs` documentation site needs a 6.0 version is open *(unverified)*.

---

## 6. BlueGenes libraries to Clojars, then BlueGenes

Order is fixed by the dependencies: imcljs 1.7.0, then im-tables 0.16.0 and bluegenes-tool-store 0.3.0
(both depend on imcljs 1.7.0), then BlueGenes 1.5.0 (depends on all three). Each library goes upstream by
PR first and is tagged and deployed from the merged upstream commit, as the BlueGenes README asks ("Make
sure that you push to the intermine repository, not just your fork!"). The detailed file edits are in
[RELEASING-siblings.md](RELEASING-siblings.md).

- [ ] **6.1 Clojars rights.** Who: **Gos**. The `org.intermine` group at
  https://clojars.org/groups/org.intermine lists `dani`, `julie`, `sergio`, `uosl`, `yo`; you are not a
  member. Create a Clojars account and ask one of them to add you to the group; then create a **deploy
  token** (Clojars > Dashboard > Deploy Tokens). `CLOJARS_USERNAME` = your Clojars user,
  `CLOJARS_PASSWORD` = the token. Start this now.
- [ ] **6.2 imcljs 1.7.0.** Who: Agent, then **Gos**.
  1. Agent: on `gmicklem/imcljs` `maint-2026`, gate, then one commit "release: 1.7.0" (VERSION,
     project.clj, CHANGELOG heading `## 1.7.0 (<date>)`), push.
  2. Gos: `gh pr create --repo intermine/imcljs --base dev --head gmicklem:maint-2026 --title "imcljs 1.7.0" --body-file <draft>`;
     merge with a merge commit.
  3. Gos, in a fresh clone:
     ```bash
     cd ~/intermine-release && git clone https://github.com/intermine/imcljs.git && cd imcljs
     git checkout dev && git log --oneline -3 && cat VERSION          # 1.7.0
     git tag -a v1.7.0 -m "Release v1.7.0"
     export CLOJARS_USERNAME=<user> CLOJARS_PASSWORD=<deploy token>
     clojure -T:build jar && ls target/imcljs-1.7.0.jar
     clojure -T:build:deploy deploy
     curl -sI https://repo.clojars.org/org/intermine/imcljs/1.7.0/imcljs-1.7.0.pom | head -1   # HTTP 200
     git push origin v1.7.0
     ```
  4. Agent: VERSION/project.clj to `1.7.1-SNAPSHOT` on the fork (goes upstream with the next PR).
  Undo: before `deploy`, `git tag -d v1.7.0`. A Clojars release cannot be overwritten: a mistake is 1.7.1.
- [ ] **6.3 im-tables 0.16.0.** Who: Agent, then Gos. Agent: `deps.edn` and `project.clj` to imcljs
  `1.7.0` (Maven), gate, then "release: 0.16.0" commit, push. Gos: PR to `intermine/im-tables-3` `dev`,
  merge commit; fresh clone; tag `v0.16.0`; `npm ci && clojure -T:build jar`; check
  `unzip -l target/im-tables-0.16.0.jar | grep public/css/im-tables.css` *(jar file name unverified)*;
  `clojure -T:build:deploy deploy`; curl check; `git push origin v0.16.0`.
- [ ] **6.4 bluegenes-tool-store 0.3.0.** Who: Agent, then Gos. Agent: imcljs `1.7.0` in `deps.edn` **and**
  `project.clj` (the published POM comes from `project.clj`), version `0.3.0` in `project.clj` and
  `build.clj`, gate before the version commit, push. Gos: PR to `intermine/bluegenes-tool-store`
  **`master`** (its only branch), merge commit; fresh clone; tag `v0.3.0`; `lein deploy clojars` (it asks
  for the user and token); curl check; push the tag.
- [ ] **6.5 BlueGenes back to Maven coordinates.** Who: Agent. RELEASING-siblings.md step 4: `deps.edn`
  `:mvn/version` for the three; delete the git-dependency workaround in `.github/workflows/ci.yml`
  (job `library-jar`) and `build.clj` (`git-lib-version`, `pom-basis`); update `docs/building.md` and the
  README; `clojure -Sforce -Spath` shows no `.gitlibs`; gate `--with-prod`; CI and nightly green.
- [ ] **6.6 BlueGenes 1.5.0 changelog and version.** Who: Agent, Gos approves. `CHANGELOG.md` has no entry
  after 1.4.5: add `## 1.5.0` (toolchain, React 18, fixes: list save, keystrokes, date constraints, upload
  organism, tools globals, jQuery 3.7.1 with SRI, no cdn.intermine.org); `build.clj` `version` to
  `"1.5.0"`. Push.
- [ ] **6.7 BlueGenes PR, merge, release.** Who: **Gos**. Needs: 6.5, 6.6, expert item 2 answered or
  accepted, HUMAN_TESTING section 1 passed.
  ```bash
  gh pr create --repo intermine/bluegenes --base dev --head gmicklem:maint-2026 --title "BlueGenes 1.5.0: toolchain modernisation" --body-file <draft>
  gh pr merge <n> --repo intermine/bluegenes --merge
  gh pr create --repo intermine/bluegenes --base master --head dev --title "Release BlueGenes 1.5.0" --body "dev -> master for 1.5.0"
  gh pr merge <m> --repo intermine/bluegenes --merge
  cd ~/intermine-release && git clone https://github.com/intermine/bluegenes.git && cd bluegenes
  git checkout master && git log --oneline -3 && grep 'def version' build.clj     # "1.5.0"
  git tag -a v1.5.0 -m "Release v1.5.0"
  npm ci && export CLOJARS_USERNAME=<user> CLOJARS_PASSWORD=<deploy token>
  clojure -T:build:deploy deploy
  git push origin v1.5.0
  ```
  Then the BlueGenes README's remaining release steps: Docker image `intermine/bluegenes:1.5.0` and
  `:latest` (needs push rights to the `intermine` organisation on Docker Hub *(unverified that you have
  them)*; a Mac builds arm64 images, so use `docker buildx build --platform linux/amd64,linux/arm64
  --build-arg BLUEGENES_VERSION=v1.5.0 -t intermine/bluegenes:1.5.0 -t intermine/bluegenes:latest --push .`
  *(unverified)*); the Dokku step (`git push dokku dev:master`) only if InterMine's Dokku host still serves
  BlueGenes *(unverified)*; the GitHub release from the tag with the CHANGELOG text and links to Clojars and
  Docker Hub. Check: `curl -sI https://repo.clojars.org/org/intermine/bluegenes/1.5.0/bluegenes-1.5.0.pom`.
- [ ] **6.8 Consumers of BlueGenes.** Who: Agent. rdfc2im's `phase_resolve_bluegenes_deps` (pinned to
  `org.intermine:bluegenes:1.4.5`) and the mines' `systemProp.blueGenesVersion` to 1.5.0, each on a task
  branch, gated, testbed rebuilt.

---

## 7. Upstream pull requests

### 7.1 What the InterMine contribution guide says

From http://intermine.org/im-docs/docs/intermine/get-involved/ (read 16 Nov 2026; the 5.0.0 and "Next"
versions are identical):

- Branches: "`master` The current public release." "`dev` The working branch. Features are merged onto
  this branch for integration testing."
- "Development does not happen on the master or dev branch. The recommended practice is to fork the
  intermine repo and maintain development branches in your own repository."
- "Code contributions should be discrete units of code. They should do one thing (be that fix a bug or add
  a feature) and not be code dumps. Ideally they should refer to existing issues in the InterMine issue
  tracker."
- "Commit, commit, commit. Using detailed commit messages." ... "create a new pull request requesting that
  the head of you/womblier be merged into intermine/dev."
- "It is probably a good idea to regularly merge the head of intermine/dev into you/womblier ... These
  merges should probably be rebase merges."
- "Hot fix branches (serious bugs that are critical fixes to the current release) should be branched from
  master rather than dev, and their pull requests should likewise be for master."
- The release manager "is the only person permitted to push into master and dev. All code contributions
  for these branches must pass review by the release manager". Acceptance criteria: passing unit test for
  new code, passes all tests (the guide still says Travis; it is GitHub Actions now), documentation,
  single purpose, detailed commit messages, well commented code, Checkstyle. The release manager merges
  the target branch into the feature branch ("If there are any conflicts, push the pull-request back to
  the developer"), tests, then merges into `dev`.
- "Once all pull requests and tickets for a specific milestone are tested and complete, the release
  manager merges the dev branch onto the master branch, tagging the merge with the milestone's label. The
  release notes are available on the Releases page, and announcements are posted on twitter and the
  mailing lists and discussed in detail on the community calls."
- Versioning policy (http://intermine.org/im-docs/docs/intermine/intermine-versions/): semantic versioning;
  "MAJOR incompatible API changes", "PATCH backwards-compatible bug fixes". Hence 5.1.1 (patch) and 6.0.0
  (major, build-incompatible).
- intermine's own `CONTRIBUTING.md` (on `maint-2026`) adds: "Branch from `dev` and open your pull request
  against `dev`. `master` only receives releases." and that "InterMine CI" and "Checkstyle" must be green.
  Its PR template is `docs/PULL_REQUEST_TEMPLATE.md` (checklist: targets `dev`, tests, docs, single purpose,
  detailed commit messages, comments, Checkstyle).
- The guide names no changelog file; intermine keeps `RELEASE_NOTES` (one line per issue), BlueGenes and
  the libraries keep `CHANGELOG.md`.

### 7.2 Merge commit or squash? Recommendation: keep the history, merge commits, one PR per release line

`decisions/0006-branching-and-gates.md` planned "squashed into reviewable chunks"; its own review trigger
is "when the PRs to intermine:dev are prepared", which is now. Recommendation: **do not squash; merge each
pull request with a merge commit**, one pull request per release line per repository, and make it
reviewable through the description rather than by rewriting history. Reasons:

1. **Every commit on `maint-2026` was gated** (the gate ran before the commit and again on the merge
   result). Squashing throws away 212 tested steps and leaves one untested-as-a-unit lump for `git bisect`
   to land on.
2. **Reversion instructions depend on the commit ids.** EXPERT_TO_CHECK.md says, for example, `git revert
   a554fdc28b e16f6f194d`; decisions, LOG lines, beads and the package-vetting log cite shas. A squash or
   rebase gives every commit a new id and breaks all of them.
3. **A merge commit keeps your fork's commits in upstream's history**, so a tag made on a fork commit (6.x)
   is still reachable upstream, and future `git merge` between the fork and upstream stays clean.
4. The guide's "single purpose" and "not code dumps" are about what a contribution is for; each commit is
   single-purpose with a detailed message (`<area>: <summary> [<bead-id>]`), and the PR as a whole has one
   purpose: "the 5.1.1 release" or "the 6.0.0 release". Say this in the description.
5. The guide's "rebase merges" advice for keeping a feature branch current would rewrite 278 commits;
   use a plain merge of upstream `dev` into the branch instead (5.1). Mention this deviation in the PR.

If a reviewer wants smaller pieces, split without rewriting: open stacked PRs from branches that point at
existing first-parent merge commits of `maint-2026` (each was gated when it was made), e.g. "Gradle 6.9.4"
up to `d178eb5cbe`, then "Gradle 8.14" up to the milestone merge, then the rest. Never cherry-pick or
rebase to build them.

### 7.3 The pull requests, in order

| # | Upstream repo | From (fork branch) | Into | When | Notes |
|---|---|---|---|---|---|
| 1 | intermine/intermine | `gmicklem:release/5.1.1-candidate` | `dev`, then `dev` -> `master` | 4.6-4.8 | merges cleanly into current `dev` |
| 2 | intermine/intermine | `gmicklem:maint-2026` | `dev`, then `dev` -> `master` | 5.5, after #1 and 5.1 | needs the merge of post-5.1.1 `dev` first |
| 3 | intermine/humanmine-bio-sources | `gmicklem:maint-2026` | `master` | after 6.0.0 is on Central and its CI is fixed (5.8) | |
| 4 | intermine/flymine-bio-sources | `gmicklem:maint-2026` | `master` | as #3 | |
| 5 | intermine/humanmine | `gmicklem:maint-2026` | **ask first** | after #3 | **Production HumanMine may be built from `master`** *(unverified)*: merging Gradle 8.14 build files there breaks a Gradle 4.9 production build. Agree with whoever runs production; otherwise target a new branch such as `intermine-6.0` |
| 6 | intermine/flymine | `gmicklem:maint-2026` | **ask first** | after #4 | same caution as #5 |
| 7 | intermine/imcljs | `gmicklem:maint-2026` | `dev` | 6.2 | |
| 8 | intermine/im-tables-3 | `gmicklem:maint-2026` | `dev` | 6.3 | |
| 9 | intermine/bluegenes-tool-store | `gmicklem:maint-2026` | `master` | 6.4 | only branch |
| 10 | intermine/bluegenes | `gmicklem:maint-2026` | `dev`, then `dev` -> `master` | 6.7 | needs 6.5 (Maven coordinates) |
| 11 | intermineorg/mine-tests | `gmicklem:maint-2026` | `main` | any time | gmicklem has read access only: merge as intermineorg |
| 12 | intermineorg/rdfc2im | `gmicklem:maint/im-ore.1-intermine-src` (then `maint/im-rkn.5-testbed-baseline`) | `main` | any time; before 5.9 is easiest | as #11 |

Before each: `gh api user -q .login` (gmicklem), the fork branch head equals the gated, frozen sha, and a
trial merge is clean: `git merge-tree --write-tree <upstream>/<base> fork/<branch>` exits 0.

### 7.4 Pull request description template

The Agent drafts one per PR into `docs/drafts/pr-<repo>-<version>.md`; you edit and use `--body-file`.

```markdown
## Details

<One paragraph: what this release line is and why (maintenance after 2022; plans/00-overview.md in
https://github.com/gmicklem/intermine-planning).>

- Branch `gmicklem:<branch>` at `<sha>`: <N> commits (<M> non-merge) over `<base>` `<base sha>`.
  Merge with "Create a merge commit": every commit passed the gate (scripts/gate-*.sh in the planning
  repo) before it was committed and again when merged; reversion notes refer to these commit ids.
- Commit messages are `<area>: <summary> [<bead-id>]`; bead ids are listed with their titles in
  `status/beads-final.md` of the planning repo.
- Upstream `dev` was merged into the branch with a plain merge (not a rebase) to keep the ids.

### Contents, by theme
<Grouped bullet list with the merge commit ids: build/Gradle, publishing, security dependencies,
removed dependencies, webapp fixes, API fixes, docs, CI. For intermine 5.1.1: the 22 items of
"5.1.1 changes" in docs/RELEASING.md.>

### For deployers
<Non-breaking (5.1.1) / breaking (6.0.0). Migration guide: docs/UPGRADING-build.md, section ...>

## Testing

- CI on the fork for `<sha>`: <links to "InterMine CI" and "Checkstyle" / BlueGenes CI and Nightly Cypress runs>.
- Gate: <tests run, failures 0, JDKs>; baseline comparison: baselines/<file>.
- Whole system: demo mine built from this branch (rdfc2im tools/full-build.sh --intermine-src),
  make test-live <n>/<n>, mine-tests <pass>/<fail>.
- Manual: docs/HUMAN_TESTING.md results at <planning repo commit link>.
- How a reviewer can try it: <the 2-3 commands that matter>.

## For reviewers

- Items for an expert: docs/EXPERT_TO_CHECK.md items <n> (with the decision taken and the reversion).
- Decisions: decisions/*.md; every package swap with its vet: decisions/package-vetting.md.

## Checklist

- [ ] Targets the `dev` branch (not `master`)
- [ ] Passing unit test for new or updated code (if applicable)
- [ ] Passes all tests (GitHub Actions "InterMine CI" and "Checkstyle" green)
- [ ] Documentation (if applicable)
- [ ] Single purpose (one release line)
- [ ] Detailed commit messages
- [ ] Well commented code
- [ ] Checkstyle
```

When an agent writes the draft, it ends with the line `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.

### 7.5 What reviewers need

- The PR description (7.4) and the files it links: `docs/EXPERT_TO_CHECK.md`, `decisions/*.md`,
  `decisions/package-vetting.md`, `baselines/`, `inventory/` (dependency and CVE inventories).
- [ ] **7.5.1 Make bead ids resolvable.** Who: Agent (the orchestrator, the only beads writer). Export
  every bead (id, title, status, closing note) to `status/beads-final.md` in this repo and push, so a
  `[im-jqz.58]` in a commit message can be looked up without the beads database.
- Reviewers can reproduce the demo mine with rdfc2im's `BUILD.md`.

---

## 8. Housekeeping

- [ ] **8.1 Production is not touched.** Nothing in this sprint deploys to, or changes, the production
  HumanMine (www.humanmine.org) or FlyMine (www.flymine.org); they were only read (public web services)
  by some tests. Moving them to 5.1.1 or 6.0.0 is a separate decision for whoever runs them, using
  `docs/UPGRADING-build.md`. See also the caution at PRs #5 and #6.
- [ ] **8.2 Final planning-repo state.** Who: Agent. Final `status/STATUS.md`, a closing `status/LOG.md`
  entry (the release shas and tags), `status/sprint-report.md`, `status/beads-final.md` (7.5.1), the
  transcript (`/Users/gos/claude_projects/update_intermine_planning/repos/transcript.md`, regenerated by
  `scripts/transcript.py`; decide whether it is committed or kept privately: it contains the whole chat),
  this file and HUMAN_TESTING.md with results; commit and push to `gmicklem/intermine-planning`; annotated
  tag `sprint-2026-11` on that commit.
- [ ] **8.3 Nothing left only in the sandbox.** Who: Agent, before the sandbox is removed. `worktrees/`,
  `/home/agent` and the Docker volumes disappear with it.
  ```bash
  for w in /Users/gos/claude_projects/update_intermine_planning/worktrees/*/*; do
    echo "== $w"; git -C "$w" status -sb | head -3; git -C "$w" log --oneline @{u}.. 2>/dev/null | head -3; done
  for r in /Users/gos/claude_projects/update_intermine_planning/repos/*/; do
    [ -d "$r/.git" ] && { echo "== $r"; git -C "$r" log --branches --not --remotes --oneline | head -5; }; done
  ```
  (The second loop prints commits on local branches that no remote has; empty output is the goal.)
  Every branch with unpushed commits is pushed to its fork or recorded as abandoned. Optional: `pg_dump`
  of the two demo databases (rdfc2im `BUILD.md`, "Persistence"); the raw-data cache is already a release
  asset on `gmicklem/rdfc2im`.
- [ ] **8.4 Branch tidy-up after upstream merges.** Who: Agent, optional. Task branches `maint/*` on the
  forks can be deleted once their content is in upstream (`git push fork --delete maint/<id>-<slug>`);
  keep `maint-2026` and `release/5.1.1-candidate` until both releases are out. A `5.1.x` branch for
  future 5.1 hot fixes can be made later from the tag (`git branch 5.1.x intermine-5.1.1`).
- [ ] **8.5 Credentials.** Who: **Gos**. When the sprint ends, revoke or rotate the GitHub token stored as
  the sandbox secret (it has `repo` and `workflow` scope on your account), and revoke the Clojars deploy
  token and Portal user token if they were only for this release. Keep the GPG key (backed up) for future
  releases.
- [ ] **8.6 What to archive.** The planning repo (tagged), the forks with their `maint-2026` branches, the
  upstream releases and tags, the rdfc2im data asset. Possibly transfer `gmicklem/intermine-planning` to
  `intermineorg/` (the name first proposed in plans/00-overview.md).
