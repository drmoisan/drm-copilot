---
name: completion-hook-checks-folder-at-session-root
description: enforce-completion-consistency.ps1 tests the relative feature-folder against the session root, so step8/9/10 "completed" is denied when the folder exists only in the item worktree
metadata:
  type: project
---

`.claude/hooks/enforce-completion-consistency.ps1` treats any of `step8_status`, `step9_status`, `step10_status` == `completed` (or `next_step` complete / `S12_complete`) as a completion assertion. It then runs `Test-Path` on the relative `feature-folder` from the hook process root, which is the session-root checkout, not the checkpoint's item worktree. Observed 2026-11-04 on issue 1067: the session root was a main checkout older than the merge, so writing `step10_status: completed` was denied with COMPLETION_CONSISTENCY_BLOCKED even after PR #1078 merged.

**Why:** the folder is created on the item branch and reaches the session-root checkout only after that checkout is updated past the merge.

**How to apply:**
- Keep `step8_status: delegated` (not `completed`) after the pr-author handoff; `completed` trips this hook early.
- Do not use `sed` on the checkpoint: it skips this hook and can silently write a completion assertion (happened once in this run).
- At completion, either the session-root checkout must contain the folder (fast-forward it, if the run is allowed to touch it) or the hook must resolve against the worktree; otherwise record `human_decision_required` with a `human_interaction` halt rather than bypassing.
- Related: [[green-ci-merge-must-be-unchained]], [[docs-only-head-blocks-merge]].
