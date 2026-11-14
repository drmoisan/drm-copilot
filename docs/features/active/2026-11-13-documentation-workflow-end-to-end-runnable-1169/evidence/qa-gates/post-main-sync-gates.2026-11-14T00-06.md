# Post-main-sync parallel gates (issue #1169)

Timestamp: 2026-11-14T00-06
Context: origin/main (eb73f1dff) merged into the branch without conflicts, giving head acdee2cb6. Issue #1160 (PR #1174) was still open, so its gate edits are not on main yet. Both parallel gates were re-run on the merged head before the pull request was opened.

## Pester gate

Command: sh SCRATCH/issue-1169-pester.sh postmerge (imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCParallelTest against the item worktree root)
EXIT_CODE: 0
Output Summary:
- 8 shard processes, every shard exit 0, wall-clock 584.72 s.
- JUnit: 22653 tests, 22643 passed, 0 failed, 0 errors, 10 skipped.
- Repo-wide line coverage 95.84% (39196/40897); the final QA run on the pre-merge head recorded 95.83%.
- New and changed files of this item keep their final-QA per-file line coverage (for example enforce-orchestration-preimplementation-gate-docs.ps1 94.20%, enforce-model-routing-receipt-docs.ps1 95.06%, enforce-docs-complete-gate.ps1 95.00%).

## pytest gate

Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=json:artifacts/python/coverage.json --cov-report=term-missing -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- 16676 passed, 6 skipped, 0 failed in 169.13 s.
- Line coverage 97.13% (34525/35546); branch coverage 94.41% (12758/13514).
