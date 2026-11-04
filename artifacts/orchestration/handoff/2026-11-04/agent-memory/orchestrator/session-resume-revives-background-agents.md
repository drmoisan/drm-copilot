---
name: session-resume-revives-background-agents
description: After a `claude --resume` restart, a background executor that has made no commits and whose scratch files are gone can still be alive; relaunching it creates two executors in one worktree
metadata:
  type: feedback
---

After the host or session restarts (`claude --resume`), assume a background subagent started before the restart is still alive until its own completion notification arrives. On 2026-11-04 (#1034), these signals looked like death but were not:
- no commit for two hours
- the SCRATCH folder was missing
- no Pester process was running

The relaunched executor and the revived original both started the same task in the same worktree and overwrote each other's SCRATCH launchers. The revived executor stopped by itself, so no damage resulted.

**Why:** two executors in one worktree race on commits, `artifacts/pester/*.xml`, and evidence filenames.

**How to apply:**
- After a resume, wait for a completion notification, or for a fresh commit or edit, before relaunching an executor.
- If the run is plainly stalled, record it in the checkpoint and ask the coordinator.

Related: [[orchestrator-stalls-on-dead-background-child]]
