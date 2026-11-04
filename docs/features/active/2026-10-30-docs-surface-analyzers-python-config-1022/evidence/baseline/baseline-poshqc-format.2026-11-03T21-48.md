# [P0-T4] PoshQC format baseline (issue #1022)

Timestamp: 2026-11-03T21-48
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p0t4-format-baseline.ps1 -WorktreeRoot <item worktree> (imports scripts/powershell/PoshQC/PoshQC.psd1 and runs Invoke-PoshQCFormat -Root <item worktree> with -WriteFile replaced by a scriptblock that records the path and writes nothing, and -Logger replaced by a collecting scriptblock)
EXIT_CODE: 0
Output Summary: Formatted lines: 0 (no pre-existing drift). Already formatted lines: 621. Files the seam would have written: 0. `git status --porcelain` captured before and after the run compared byte-identical (`cmp` exit 0); the only entries are the untracked 1022 evidence files written by [P0-T1] to [P0-T3].

## Counts

| Log line | Count |
|---|---|
| `Formatted:` | 0 |
| `Already formatted:` | 621 |

## Status check

- Before: `git status --porcelain` saved to `SCRATCH/issue-1022-p0t4-status-before.txt`.
- After: `git status --porcelain` saved to `SCRATCH/issue-1022-p0t4-status-after.txt`.
- `cmp` of the two files: identical (`STATUS_IDENTICAL`).
- Tracked files changed by the run: none.
