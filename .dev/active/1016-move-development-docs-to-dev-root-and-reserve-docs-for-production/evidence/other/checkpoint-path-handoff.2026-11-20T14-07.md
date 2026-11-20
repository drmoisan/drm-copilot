# Checkpoint-path handoff ([P3-T1], run 1 end, R5, A20)

Timestamp: 2026-11-20T14-07
Command: ls <NEW_FEATURE>/evidence/other (no checkpoint-path-update.*.md present); git -C <worktree> rev-parse HEAD; git -C <worktree> log --format='%H %s' -4
EXIT_CODE: 0
Output Summary: No checkpoint-path-update.*.md exists, so run 1 ends here with BLOCKED: checkpoint-path-update-pending and [P3-T1] stays unchecked. The six handoff values are below. The orchestrator updates the feature-folder and plan-path fields of artifacts/orchestration/orchestrator-state.json to NEW_FEATURE before run 2, writes NEW_FEATURE/evidence/other/checkpoint-path-update.<timestamp>.md, and delegates run 2, which resumes at [P3-T1] (hook-root precondition record first).

| Value | Recorded |
| --- | --- |
| Old FEATURE | docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016 |
| New FEATURE | .dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production |
| Old plan path | docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T23-35.md |
| New plan path | .dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/plan.2026-10-30T23-35.md |
| Moved DECISIONS path | .dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/evidence/other/folder-rename-decisions.2026-11-20T12-24.json |
| Apply commit identifier | 42e4581d8506403b434579a4a5bf5ab371c75f7f ("feat(1016): move development records to .dev and reserve docs for production") |

Apply commit note: the plan names `git rev-parse HEAD` as the source, written for a HEAD that is the apply commit. Run 1 committed the Phase 2 gate auto-fixes and evidence afterwards, so `git rev-parse HEAD` now prints e213f375e2818e3a6b35190168dc7c563603f77d ("style(1016): format tool-rewritten tests and record the Phase 2 gate"), whose parent is the apply commit above. Both commits are pushed to origin/feature/dev-docs-root-migration-phases-2-3-1016. Recommended-option decision under OD-1: record the apply commit itself as the identifier and name the later HEAD here.

Statement: the orchestrator updates the checkpoint feature-folder fields (and the plan-path field) to NEW_FEATURE before run 2. Run 1 did not write artifacts/orchestration/orchestrator-state.json.

Run 1 state: [P0-T1] to [P2-T4] checked; [P3-T1] unchecked. Commits pushed by this run: 46b122d221966cd0c0ab3b67e73b07b97420734b, 0918676aa8c35cc62a517da0576524e727e6d737, 42e4581d8506403b434579a4a5bf5ab371c75f7f, e213f375e2818e3a6b35190168dc7c563603f77d. This handoff record and its task check are written after the last push and are left for the orchestrator to commit, per `## Scope and Conventions` (the orchestrator commits the run-1 evidence written after the apply commit).
