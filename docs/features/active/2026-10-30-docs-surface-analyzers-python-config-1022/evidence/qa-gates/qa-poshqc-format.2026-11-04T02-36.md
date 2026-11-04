# [P6-T1] PoshQC format QA gate (issue #1022)

Timestamp: 2026-11-04T02-36
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p6t1-format.ps1 -WorktreeRoot <item worktree> (imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat -Root <item worktree> in write mode with the default WriteFile seam and a collecting -Logger scriptblock)
EXIT_CODE: 0
Output Summary: Formatted lines: 0 (baseline [P0-T4]: 0). Already formatted lines: 640 (baseline 621; the difference is the files added by this plan). Zero `Formatted:` lines for any file this plan created or changed. `git status --porcelain` captured before and after the run compared byte-identical (`cmp` exit 0, `STATUS_IDENTICAL`; both empty, the branch is fully committed). No `LIB` file was rewritten, so [P5-T1] is not repeated.

## Counts

| Log line | This run | [P0-T4] baseline |
|---|---|---|
| `Formatted:` | 0 | 0 |
| `Already formatted:` | 640 | 621 |

## Status check

- Before: `git status --porcelain` saved to `SCRATCH/issue-1022-p6t1-status-before.txt` (empty).
- After: `git status --porcelain` saved to `SCRATCH/issue-1022-p6t1-status-after.txt` (empty).
- `cmp` of the two files: identical.
