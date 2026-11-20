# PowerShell final-QC static loop ([P4-T1], re-run after the origin/main merge)

Timestamp: 2026-11-13T18-53
Command: sh SCRATCH/issue-1161-psstatic.sh (PowerShell 7 in the item worktree, running SCRATCH/issue-1161-psstatic.ps1; `git status --porcelain` captured before and after)
EXIT_CODE: 0
Output Summary: Format 0 files would change of 187; PSScriptAnalyzer 0 findings; leak scan 768 files, 0 failures; `git status --porcelain` identical before and after (0 entries). Clean single pass.

Reason for the re-run: files changed after the earlier P4-T1 artifact (`pwsh-static.2026-11-12T13-02.md`): the origin/main merge and the P2-T6 line-cap and order-dependence fixes recorded in `evidence/other/task-check.P2-T6.2026-11-13T18-50.md`.

## Steps

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| 1. Format (check mode) | for each .ps1, .psm1, .psd1 under `.claude/hooks` and `.codex/hooks` (165 files) and the 22 PowerShell test files this branch adds or edits, compare the file text with `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` output | 0 | 0 files would change |
| 2. Analyze | `Invoke-ScriptAnalyzer -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `.claude/hooks` and `.codex/hooks`, then per file over the same 22 test files | 0 | 0 (0 in hooks; baseline 0) |
| 3. Leak scan | `Import-Module scripts/powershell/PoshQC/PoshQC.psd1`; `Invoke-PoshQCLeakScan -Root <worktree>` | 0 | 768 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures (baseline 0 failures); warning that configured folder `tests/powershell` does not exist |
| Type check | not applicable for PowerShell | n/a | n/a |

Formatter tree observation: `git status --porcelain` output was captured before step 1 and after step 3 and compared byte for byte: unchanged (0 entries).

The 22 test files are the 20 of the earlier artifact plus `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` and `tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1`.
