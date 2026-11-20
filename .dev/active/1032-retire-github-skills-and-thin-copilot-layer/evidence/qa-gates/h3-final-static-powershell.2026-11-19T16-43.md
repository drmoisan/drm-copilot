# H3 Final Static Loop: PowerShell ([P2-T1])

Timestamp: 2026-11-19T16-43
Plan: plan-h3-sync-writer-retirement.md
Command: pwsh -NoProfile -File SCRATCH/issue-1032-psstatic.ps1 -Mode format and -Mode analyze over tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1 scripts/harness-generation/HarnessInstructions.psm1 (SCRATCH/issue-1032-static.sh with PS_FILES; Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary: one pass, no file changed, no restart needed.

| Step | Command | EXIT_CODE | Findings |
| --- | --- | --- | --- |
| Format | Invoke-Formatter comparison, 2 files | 0 | 0 (TOTAL 0, no drift) |
| Lint | Invoke-ScriptAnalyzer, 2 files | 0 | 0 (TOTAL 0) |
| Type check | not applicable to PowerShell | — | — |

`scripts/harness-generation/HarnessInstructions.psm1` is included because this run reworded its writer reference before the final loop (see `writer-reference-resolution-h3.2026-11-19T16-43.md`).
