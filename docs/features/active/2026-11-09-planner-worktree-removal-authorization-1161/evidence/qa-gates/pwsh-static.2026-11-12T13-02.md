# PowerShell final-QC static loop ([P4-T1])

Timestamp: 2026-11-12T13-02
Command: sh SCRATCH/issue-1161-psstatic.sh (PowerShell 7 in the item worktree, running SCRATCH/issue-1161-psstatic.ps1; `git status --porcelain` captured before and after)
EXIT_CODE: 0
Output Summary: Format 0 files would change of 181; PSScriptAnalyzer 0 findings; leak scan 0 failures; `git status --porcelain` identical before and after (14 entries, all pre-existing uncommitted changes of this phase). Clean pass after one restart.

## Steps

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| 1. Format (check mode) | for each .ps1, .psm1, .psd1 under `.claude/hooks` and `.codex/hooks` (161 files) and the 20 PowerShell test files this branch adds or edits, compare the file text with `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` output | 0 | 0 files would change |
| 2. Analyze | `Invoke-ScriptAnalyzer -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `.claude/hooks` and `.codex/hooks`, then per file over the same 20 test files | 0 | 0 (0 in hooks; baseline 0) |
| 3. Leak scan | `Import-Module scripts/powershell/PoshQC/PoshQC.psd1`; `Invoke-PoshQCLeakScan -Root <worktree>` | 0 | 748 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures (baseline 741 files, 0 failures); warning that configured folder `tests/powershell` does not exist |
| Type check | not applicable for PowerShell | n/a | n/a |

Formatter tree observation: `git status --porcelain` output was captured before step 1 and after step 3 and compared byte for byte: unchanged.

## Loop history

- Pass 1 (same command, earlier the same session): format 0, leak scan 0 failures, analyzer 14 findings introduced by this branch (10 in the two helper copies, 4 in new test files). Fixed as recorded in `evidence/other/task-check.P4-T1.2026-11-12T13-00.md`.
- Pass 2 (this artifact): clean.
