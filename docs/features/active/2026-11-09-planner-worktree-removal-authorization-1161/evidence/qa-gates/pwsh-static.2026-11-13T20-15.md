# PowerShell final-QC static loop ([P4-T1], loop restart after the P4-T6 host-path fix)

Timestamp: 2026-11-13T20-15
Command: sh SCRATCH/issue-1161-psstatic.sh (PowerShell 7 in the item worktree, running SCRATCH/issue-1161-psstatic.ps1; `git status --porcelain` captured before and after)
EXIT_CODE: 0
Output Summary: Format 0 files would change of 187; PSScriptAnalyzer 0 findings; leak scan 768 files, 0 failures; `git status --porcelain` identical before and after (0 entries). Clean single pass.

Reason for the re-run: the P4-T6 host-path scan found the drive-rooted synthetic value `Z:\synthetic\A` in a path-equality row of `tests/scripts/claude-hooks/hook-planner-worktree-removal.Tests.ps1`. The plan's test terms require synthetic roots without a drive letter, so the row now uses a synthetic UNC pair (`\\synthetic-host\share\A` and `//synthetic-host/share/a`), which exercises the same ordinal-ignore-case branch of `Test-PlannerWorktreePathEqual`. Task check: Invoke-Formatter and Invoke-ScriptAnalyzer on the suite (0 and 0), and Pester over the suite and the discovery guard: 768 passed, 0 failed. The loop restarts from step 1.

| Step | Command | EXIT_CODE | Findings |
|---|---|---|---|
| 1. Format (check mode) | for each .ps1, .psm1, .psd1 under `.claude/hooks` and `.codex/hooks` (165 files) and the 22 PowerShell test files this branch adds or edits, compare the file text with `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` output | 0 | 0 files would change |
| 2. Analyze | `Invoke-ScriptAnalyzer -Recurse -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over `.claude/hooks` and `.codex/hooks`, then per file over the same 22 test files | 0 | 0 (0 in hooks; baseline 0) |
| 3. Leak scan | `Import-Module scripts/powershell/PoshQC/PoshQC.psd1`; `Invoke-PoshQCLeakScan -Root <worktree>` | 0 | 768 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures |
| Type check | not applicable for PowerShell | n/a | n/a |

Formatter tree observation: `git status --porcelain` output was captured before step 1 and after step 3 and compared byte for byte: unchanged (0 entries).

Python and TypeScript: no file in their scope changed since `python-static.2026-11-13T18-55.md`, `typescript-static.2026-11-13T18-55.md`, `pytest-gate.2026-11-13T20-08.md`, and `jest-gate.2026-11-13T20-09.md`, so those results stand.
