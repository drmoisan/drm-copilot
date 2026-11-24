# Remediation Baseline - PowerShell Static (cycle 1)

Plan: remediation-plan.2026-11-24T08-32.md
Task: [P0-T1]
Timestamp: 2026-11-24T08-48
Command: sh SCRATCH/issue-1221-static.sh <six files> (pwsh 7: per file, Invoke-Formatter -ScriptDefinition over the LF-normalized text with scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared in memory, no write; Invoke-ScriptAnalyzer -Settings pssa.settings.psd1 -Severity Error, Warning, Information; logical lines = @(Get-Content).Count)
EXIT_CODE: 0
Output Summary:
- Check-only format: 0 of 6 files need formatting (the formatter has no check switch; the in-memory comparison writes nothing).
- Analyzer findings: 0 in total.

| File | Format | Analyzer findings | Logical lines |
|---|---|---|---|
| .claude/lib/docs/DocsFamilyCheck.psm1 | already formatted | 0 | 284 |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | already formatted | 0 | 624 |
| tests/scripts/claude-lib/docs/DocsFamilyCheck.Tests.ps1 | already formatted | 0 | 438 |
| tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 | already formatted | 0 | 499 |
| tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1 | already formatted | 0 | 589 |
| tests/scripts/claude-lib/docs/DocsLedger.TestSupport.Tests.ps1 | already formatted | 0 | 236 |

No write-mode formatter ran before this capture.
