# Analyzer and Formatter Baseline (issue 1024, remediation cycle 1)

Timestamp: 2026-11-04T14-48
Task: [P0-T3]
Command: sh SCRATCH/issue-1024-static-baseline.sh (git status --porcelain before; PowerShell 7 script SCRATCH/issue-1024-static.ps1 runs, per file, Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared ordinally with the file text, nothing written back, and Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; git status --porcelain after, compared with cmp)
EXIT_CODE: 0
Output Summary: All three files: 0 diagnostics and formatter text equal to the file text. git status --porcelain was identical before and after the run (PORCELAIN-IDENTICAL).

| File | PSSA diagnostics | Formatter |
|---|---|---|
| `.claude/lib/docs/DocsReferenceFrontMatter.psm1` | 0 | equal |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | 0 | equal |
| `tests/scripts/claude-lib/docs/DocsReferenceFrontMatter.Tests.ps1` | 0 | equal |

Note: a first launch passed the three paths as one comma-joined argument and failed to read the file (EXIT_CODE 1, no output for any file); the script was corrected to split the argument and re-run with the result above.
