---
name: gos-working-preferences
description: How Gos wants agent work done - dependency hygiene, vetting replacements, testing every commit, gmicklem GitHub account
metadata:
  type: feedback
---

- Every commit must pass the repo gate script before commit; orchestrator re-runs on merge.
- Remove weak dependencies (used once or trivially replaceable) rather than upgrading them; use judgement if used several times but easy to remove; one removal per commit.
- When swapping a package for a different one, read its source for malware/convoluted code first and log the vet in `decisions/package-vetting.md` even if safe, flagged for discussion.
- Prefer removing explicit Gradle `dependsOn` in favour of task input/output wiring.
- All GitHub work under the gmicklem account (not intermineorg). Public HumanMine/FlyMine may be used read-only for tests.
- Breaking changes for deployers are acceptable once Tier 1 security + Gradle 6.9.4 can ship as a non-breaking 5.1.1.

**Why:** Gos wants the codebase to shrink and stay auditable, and wants a clear record of anything an agent decided alone.
**How to apply:** Put these rules verbatim into worker prompts. Related: [[intermine-maintenance-sprint]].

**Public mine for tests (15 Nov 2026):** when choosing between FlyMine and HumanMine for live tests, use HumanMine (read-only); it is the service Gos cares most about. Local rdfc2im demo mine first where public data is not needed.

- 16 Nov 2026: Gos decided HumanMine is the BlueGenes product default (im-7os.26). The other items in intermine-planning docs/HUMAN-STEPS.md (Clojars releases, Central Portal, reagent patch, bio-source scopes, version bump, commons-lang, KeySigner) are deferred: Gos has no time now and expects help/discussion before acting. Do not treat them as blockers; keep them listed and bring short decision summaries when asked.

- 16 Nov 2026: KeySigner decision: keep the hand-written DER writer (bcprov stays removed). Gos wants a running log of issues for an InterMine expert developer to check: repos/intermine-planning/docs/EXPERT_TO_CHECK.md; add an entry whenever a change is correct by tests but touches history-laden code.

- 16 Nov 2026 (17:50 UTC): Gos agreed the maint-2026 line becomes 6.0.0 (major maintenance release); decisions taken today: keep KeySigner DER writer, keep reagent input patch (upstream issue reagent-project/reagent#676 posted from gmicklem), drop commons-lang 2 on 6.0 (forks migrated), keep runtime scope in bio-source POMs. Gos plans manual testing once the beads are nearly done; expert review log docs/EXPERT_TO_CHECK.md must carry reversion steps for every entry.

- 18 Nov 2026 (Gos): whenever a host is blocked by the sandbox, tell him the exact
  `sbx policy allow network <host>` command at once, and add the host to
  repos/intermine-planning/docs/SANDBOX-NETWORK.md (section "Requested, not yet allowed", moved up once
  he has run it), so a new session on a new machine can be set up from that file. **Why:** he had to
  ask which hosts were needed; the file is the single list. Also from 18 Nov: STATUS.md shows beads and
  epics before the agent list; questions needing research go in docs/TO_INVESTIGATE.md; licences must
  be read from the sources as stated today, never carried over from old notes; show him an image
  before committing it.

- 18 Nov 2026 (Gos), **permanent session-close policy:** before a session ends or the sandbox is
  restarted, run `scripts/save-agent-memory.sh` in intermine-planning (copies these notes to
  `agent-memory/`), write a LOG.md checkpoint, remove `repos/.sandbox-disk/scratch/` and merged
  worktrees, commit and push. **Why:** at the end of the 17 Nov session he nearly restarted the sandbox
  with more memory, which wipes the sandbox home and these notes; it was caught just in time. The
  hourly status loop now saves them too. Large scratch goes under `repos/.sandbox-disk/scratch/<task>/`
  (his instruction: scratch inside the repos directory, cleaned up at the end of the session).
