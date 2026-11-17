---
name: laptop-sleep-plan
description: "Gos will sleep the Mac around 10:00 UK Mon 16 Nov 2026; sandbox pauses, workers die on wake; procedure agreed"
metadata:
  node_type: memory
  type: project
  originSessionId: 0492e8a9-74f1-4807-9fab-46d9cc2516dd
  modified: 2026-11-15T17:07:37.447Z
---

Gos said (15 Nov 2026, 17:00 UTC) he will probably need to sleep the laptop around 10:00 UK on Mon 16 Nov 2026 and will say so beforehand; he will say "back" afterwards. Until then: run at full speed.

**Why:** the sandbox is a VM on his Mac; sleep pauses everything and in-flight API calls fail on wake, which usually kills running worker agents. Running hot in a bag with `pmset disablesleep` risks a thermal shutdown (equivalent to a power cut for the VM), so plain sleep was agreed for short trips.

**How to apply:** when he announces the sleep, stop launching workers, let running gates finish or stop them, run the checkpoint routine (dashboard, transcript, sprint report, LOG.md, commit, push, artifact). On "back", check `/tasks` for dead workers and relaunch them from their worktrees (commits survive; only in-flight work is lost). See [[intermine-maintenance-sprint]].

Update 16 Nov 11:45 UTC: Gos woke the laptop ~11:35 UTC. Next: moving buildings at 13:55 UK (= UTC) without sleeping, internet may drop for a minute or two (remote ops may fail transiently; retry, do not treat as auth failure). Laptop sleep again ~17:00 UK for ~30 min: take a checkpoint before 16:55, avoid launching gates that would be mid-run; relaunch dead workers on "back".
