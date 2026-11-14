# Preflight Fixes (Stage G, confirming pass)

Timestamp: 2026-11-08T03-26
Plan: docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/plan.2026-11-07T12-43.md

## Fixes

1. `## Re-derived Dispositions` and `## Surfaces and Baseline-Adjacent Places` | stale anchor | The revision labelled the step 5 and step 8 alignment `(G5)`, but `## Design` defines G1 to G4 only. The disposition row now cites `[P2-T3]` and the `.claude` surfaces row cites the Keep row of `## Re-derived Dispositions`. No task, file set, or assertion changed.
2. `## Test Dispositions`, row for `test_push_down_issue_824_follow_ups.py` and four other suites | inaccurate disposition reason | The reason stated that step 8 is not edited, which the revision made untrue. It now states that step 8 changes only by the "beneath the item worktree" clause on its absent-artifact trigger, which keeps `governing thresholds` and adds no `80%` or `90%`. `test_review_workflow_step_eight_uses_governing_thresholds` asserts exactly those two properties, so the disposition stays Unchanged.

## Confirmed without change

- The fallback is gone: the plan holds no `committed test-gate` or fallback instruction in any task, in the `0009` entry description of [P2-T8], or in the [P2-T7] test list; the one remaining mention states that no fallback is added. Research section 4 has no row for an absent coverage artifact, so the Keep disposition leaves the first `[G]` criterion intact.
- Step 8 matches step 5: in the `.claude` and `.agents` workflow copies the step 5 bullet `If no coverage artifact exists for a language that has changed files` and the step 8 trigger `coverage artifact absent for any language that has changed files` each match one line, and [P2-T3] gives both the same clause. The `.github` copy has neither line.
- D13: neither edited line, and no added clause, matches `baseline|regression|pre-change|Phase 0`; the adjacent step 8 threshold bullet that holds `Phase 0 baseline` is unchanged. Search of `tests/` and `extensions/drm-copilot/test/` found no test pinning either line; the `beneath the item worktree` matches are in hook suites that assert hook messages.
- Chain prototype re-run in SCRATCH with the revised edits (step 5 and step 8 clauses, no feature-review step 4 edit): patch of 53 files with 1 create hunk; ledger valid with 9 rows; entry `0009` valid with its `PatchPath`; full chain 0 errors; `-StopBefore` replays for `0009`, `0008`, `0006`, and `0001` 0 errors each; all 16 source paths replayed at `0008` equal to the pre-edit text and the new test absent; baseline-token line lists equal on all 52 surface paths.
- Validators: the branch-current Python CLI and the installed MCP validator both pass the plan; it holds 20 tasks and 168 physical lines.
