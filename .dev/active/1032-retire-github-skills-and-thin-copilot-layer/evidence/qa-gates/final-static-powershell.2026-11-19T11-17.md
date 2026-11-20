# Final Static QC: PowerShell ([P2-T1])

Timestamp: 2026-11-19T11-17
Plan: plan.2026-10-30T18-39.md
Command: sh SCRATCH/issue-1032-static.sh final (PS_FILES = the 18 PowerShell files changed between MB and HEAD, passed as one comma-separated value: 14 suites and the helper under `tests/scripts/claude-runtime/` and `tests/scripts/dev-tools/`, including the new `copilot-layer-retirement.Tests.ps1`, and 3 parity suites under `tests/scripts/claude-hooks/`)
EXIT_CODE: 0
Output Summary: formatter comparison and PSScriptAnalyzer clean over all 18 changed PowerShell files; 0 findings in each step. PowerShell has no type-check step.

| Step | Command | EXIT_CODE | Findings |
| --- | --- | --- | --- |
| Format | `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` compared with each file's text (SCRATCH helper) | 0 | 0 files differ |
| Lint | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` (SCRATCH helper) | 0 | 0 |
| Type check | not applicable for PowerShell | — | — |
