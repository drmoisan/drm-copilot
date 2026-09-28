Timestamp: 2026-09-07T10-56

Sources read in full:
- docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/issue.md
- docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/spec.md
- docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/user-story.md
- docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/research/2026-09-06T23-15-cleanup-worktrees-consolidation-pr-merge-gate-research.md

Determination: `spec.md` is the sole acceptance-criteria source for this `full-bug` work-mode
feature, per the `full-bug` row of the AC-source table in
`.claude/skills/acceptance-criteria-tracking/SKILL.md`. `user-story.md` carries no acceptance
criteria and no checkbox items by its own header statement (see "Why this file exists in a
`full-bug` feature"), and is not tracked for delivery.

AC inventory (fifteen criteria, AC-1 through AC-15, no gap, no duplicate), reproduced verbatim
from `spec.md` `## Acceptance Criteria` (lines 592-606):

- AC-1 — (a) Step 5 of the End-to-End Workflow in `.claude/skills/cleanup-merged-worktrees/SKILL.md` names the human as the actor and states the merge occurs outside the agent session. Assertion: `rg -F -n "human-performed" .claude/skills/cleanup-merged-worktrees/SKILL.md` reports at least one match, and every reported match line lies within the End-to-End Workflow step 5 item.
- AC-2 — (b) Step 5 names the merge gate's deny reason. Assertion: `rg -F -n "EPIC_MERGE_GATE_BLOCKED" .claude/skills/cleanup-merged-worktrees/SKILL.md` reports at least one match within the End-to-End Workflow step 5 item.
- AC-3 — (b) Step 5 names the project permission allow-list as a blocker. Assertion: `rg -F -n "permissions.allow"` and `rg -F -n "settings.json"` each report at least one match within step 5.
- AC-4 — (c) Step 5 states the up-to-date-branch precondition the ruleset imposes. Assertion: `rg -F -n "strict_required_status_checks_policy"` reports at least one match within step 5.
- AC-5 — (c) Step 5 discloses that the wait for the merge is not bounded within a session. Assertion: `rg -F -n "unbounded"` reports at least one match within step 5.
- AC-6 — (d) `## Prohibited Shortcuts` forbids writing/editing an orchestration checkpoint to satisfy the merge gate. Assertion: `rg -F -n "epic_mode"` and `rg -F -n "step9_status"` each report at least one match, all within `## Prohibited Shortcuts`.
- AC-7 — (e) `## Cross-References` names the merge gate. Assertion: `rg -F -n "enforce-epic-merge-gate.ps1"` reports at least one match within `## Cross-References`.
- AC-8 — The two SKILL.md copies are byte-identical. Assertion: the push-down parity pytest node exits 0.
- AC-9 — The merge gate hook is unmodified. Assertion: `git diff origin/epic/cleanup-merged-worktrees-hardening-integration -- .claude/hooks/enforce-epic-merge-gate.ps1` produces empty output.
- AC-10 — The merge gate's test file is unmodified. Assertion: `git diff` against the test file produces empty output.
- AC-11 — No out-of-scope surface is modified. Assertion: `git diff` against `.claude/hooks .claude/settings.json scripts/bash` produces empty output.
- AC-12 — No cleanup checkpoint contract is introduced anywhere. Assertion: `rg -F -n "cleanup-worktrees-state" .claude scripts tests extensions` reports no match.
- AC-13 — A fail-before exception dossier is recorded under the canonical evidence location.
- AC-14 — A manual read-through record is captured under the canonical evidence location.
- AC-15 — The `docs-validation / Documentation Validation` required check reports a `success` conclusion on this feature's pull request. (Deferred out of this plan's executable phases per Phase 3 P3-T4; no pull request exists during atomic execution.)

Count check: 15 lines, AC-1 through AC-15, no gap, no duplicate — confirmed by direct read of
spec.md lines 592-606.
