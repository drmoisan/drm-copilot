# Stage R Cycle 3 Merge of origin/main (PR #1112)

Timestamp: 2026-11-07T20-12
Command: git fetch origin main (origin/main unchanged at the PR #1112 merge since the cycle inputs); git merge --no-commit --no-ff origin/main; resolution of docs/engineering/process-reductions/0001-parallel-only-test-gates.md; rebase of the 0006 and 0001 stored-patch hunks; sh-launched PowerShell 7 scripts under SCRATCH (SCRATCH/c3/issue-1097-c3-chain.ps1, SCRATCH/c3/issue-1097-c3-regen.ps1, and a pre-commit trial of the git-level gate that also walks MERGE_HEAD); git apply -R --check of the 0006 patch; git grep for conflict markers; git commit -F and git push
EXIT_CODE: 0
Output Summary:
  Merge commit: two parents (the branch head and the origin/main PR #1112 merge); subject carries reduction: 0001 and reduction: 0006; push succeeded.
  Conflict: one content conflict, in 0001 `## Revert Steps` step 1; every other section merged without conflict.
  git grep -n -e "^<<<<<<< " -e "^>>>>>>> " -- docs/engineering/process-reductions: no match (exit 1).
  Test-ProcessReductionLedger over Read-ProcessReductionLedger: valid, 0 errors.
  Invoke-ProcessReductionChain over Read-ProcessReductionChainInput: 6 entries, 2 patches, 298 paths; IsValid True, 0 errors. -StopBefore 0001 and -StopBefore 0006: IsValid True, 0 errors each.
  Get-ProcessReductionLanding of 0001: #1096 (22 blocks), then first (4 blocks).
  git apply -R --check of the 0006 patch on the live tree: exit 0.
  The six brief sections of the 0001 patch carry ` - Invoke-PoshQCLeakScan is the static check ...` as a context line (6 matches, both images).
  Pre-commit trial of the git-level gate: 0006 and 0001 git apply -R --cached --check exit 0; unattributed 0. Gate (c) of [P2-T4] is the recorded run.

## Resolution of 0001

- `## Summary`, `## Reason and Evidence`, and `## Partial Revert`: identical on both sides, kept.
- `## Files Changed`: main's two-part introduction and #1096 path list (merged without conflict).
- `## Stored Patch`: this branch's `Rebased for stage R` paragraph; a new `Rebased over PR #1112 (issue #1096)` paragraph; the check sentence extended with "and then this entry's later landings are reverted"; main's sentence that the patch does not hold the #1096 edits, ending `under ### Later Landing: #1096`.
- `## Prior Text`: main's first paragraph and every block kept; the heading `### Later Landing: #1096` inserted before the second `.claude/skills/execution-environment/SKILL.md` block, with main's `The #1096 landing adds the blocks` paragraph moved under it.
- `## Revert Steps`: step 1 is the plan text (later entries, then the #1096 later landing, then the patch); steps 2 to 4 unchanged; steps 5 and 6 carry main's #1096 additions.
- `## Revert Signals`: main's bullets.

## Rebased Records (each under its entry's token, in the merge commit)

- 0006 patch, 0001 entry hunk 1: `-` line is the new step 1 without the later-entry clause, `+` line is the new step 1; start 917.
- 0006 patch, 0001 entry hunk 2: first bullet context line is main's `A leak that Invoke-PoshQCLeakScan misses` bullet; start 928. Line counts unchanged. The single-space context lines were kept.
- 0006 entry `## Stored Patch`: paragraph `Rebased over PR #1112 (issue #1096)` added.
- 0001 patch, six execution-environment brief sections: the three `Invoke-PoshQCLeakScan` bullets inserted as context lines in the `## PowerShell Route and PoshQC MCP Limits`, `## CI-Only Failure Classes`, and end-of-file `## Test Isolation Checks` hunks; counts and starts recomputed against the -StopBefore 0001 state; the six sections stay identical apart from their paths.
- Further regions main moved, found by the chain check and the git-level trial (not named in the plan, rebased by its P1-T2 rule):
  - `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, 0001 hunks at +450 and +464 (chain errors before the rebase): main's #1096 commit `docs(skills): state the Pester leak scan in the execution-environment brief (#1096)`, which carries no `reduction:` token, added `"Invoke-PoshQCLeakScan"` after `"parallel gates govern"` (now a context line in both images) and three lines inside `test_brief_passages_state_parallel_gate_facts`, a function the 0001 patch adds (`+` lines, including the `## Test Runtime` assertion that main's step 5 names).
  - `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1`, a file the 0001 patch creates (git-level trial: `patch failed ... :1`; the in-memory chain does not compare a created file's content): PR #1113 (issue #1105) commit `test(hooks): add the item-resolution baseline mocks to the SubagentStop hook suites (#1105) [P1-T3]`, which carries no `reduction:` token, added four lines. The create section was regenerated from the merged file (167 lines, blob 1779305a4).
