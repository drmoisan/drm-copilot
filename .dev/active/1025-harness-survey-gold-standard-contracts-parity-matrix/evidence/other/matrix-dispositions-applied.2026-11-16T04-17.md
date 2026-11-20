# Matrix Dispositions Applied (P1-T2)

Timestamp: 2026-11-16T04-17
Command: pwsh -NoProfile -File SCRATCH/issue-1025-matrix-decisions.ps1 (plan B `## Decision Application Rules` rules 0 to 3a against survey/difference-approval.md; writes config/harness-parity-matrix.json sorted by id; Import-HarnessParityMatrix and Get-HarnessParityMatrixViolation against Get-HarnessInventory of the live tree)
EXIT_CODE: 0
Output Summary: 80 Disposition Proposals rows (43 feature ids, 37 single-ecosystem skills); 0 feature-id override rows; 9 disposition changes; 37 entries carry an `approved:` note; Violations 0.

UnmatchedApprovalIds: 0
OverridesWithoutRule: 0
NativeOverrideWithTargets: 0
Violations: 0
Entries overridden to native: 0

## Changed Dispositions

| id | Old | New | Rule |
| --- | --- | --- | --- |
| `claude:skill:parallel-close` | native | shared | rule 2 (single-ecosystem skill approved shared) |
| `claude:skill:parallel-orchestrate` | native | shared | rule 2 (single-ecosystem skill approved shared) |
| `claude:skill:epic-progress-report` | native | shared | rule 2 (single-ecosystem skill approved shared) |
| `claude:skill:parallel-add` | native | shared | rule 2 (single-ecosystem skill approved shared) |
| `claude:skill:mermaid-diagram` | native | shared | rule 2 (single-ecosystem skill approved shared) |
| `claude:skill:parallel-run` | native | shared | rule 2 (single-ecosystem skill approved shared) |
| `claude:skill:cleanup-merged-worktrees` | native | shared | rule 2 (single-ecosystem skill approved shared) |
| `claude:skill:parallel-remove` | native | shared | rule 2 (single-ecosystem skill approved shared) |
| `claude:skill:parallel-plan` | native | shared | rule 2 (single-ecosystem skill approved shared) |

Every other proposal keeps its plan A disposition: the 43 `copilot:skill:*` rows are already `dropped`, and the 28 single-ecosystem skills approved `native` keep `native` with the note `approved: native`.
