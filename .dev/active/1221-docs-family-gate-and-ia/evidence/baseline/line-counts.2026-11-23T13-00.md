# Baseline - Logical Line Counts (P0-T2)

Timestamp: 2026-11-23T12-59
Command: awk 'END{print NR}' <file> for each listed file (logical lines; a trailing terminator adds no line)
EXIT_CODE: 0
Output Summary: six files counted; DocsLedgerCommands.psm1 is 758 logical lines (growth cap +3 -> 761). Finding count: 0.

| File | Logical lines |
|---|---|
| .claude/lib/docs/DocsValidation.psm1 | 367 |
| .claude/lib/docs/DocsValidateCommands.psm1 | 250 |
| .claude/lib/docs/DocsCoverageReport.psm1 | 163 |
| .claude/lib/docs/DocsLedgerCommands.psm1 | 758 |
| tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1 | 581 |
| tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1 | 553 |
