# Final QC - PowerShell Static (remediation cycle 1)

Plan: remediation-plan.2026-11-24T08-32.md
Task: [P1-T6]
Timestamp: 2026-11-24T10-06
Command: sh SCRATCH/issue-1221-static.sh <eight files> (per file, one bounded pwsh 7 process: check-only Invoke-Formatter comparison with scripts/powershell/PoshQC/settings/pssa.settings.psd1, then Invoke-ScriptAnalyzer -Settings pssa.settings.psd1 -Severity Error, Warning, Information, then the logical line count); git -C <worktree> status --porcelain -- <eight files> before and after
EXIT_CODE: 0
Output Summary:
- Step 1, format (check-only): exit 0; finding count 0 (0 of 8 files need formatting).
- Step 2, analyzer: exit 0; finding count 0. One PSScriptAnalyzer null-reference error on the first attempt for DocsLedger.TestSupport.psm1 was retried after a module reload, as PoshQC's analyzer does; the retry reported 0 findings.
- Step 3, type check: not applicable for PowerShell.
- `git status --porcelain` over the eight files: identical before and after the formatter step (8 lines, each ` M`); the loop made one clean pass with no restart.

| File | Format | Analyzer findings | Logical lines | Limit |
|---|---|---|---|---|
| .claude/lib/docs/DocsFamilyCheck.psm1 | already formatted | 0 | 297 | <= 800 |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | already formatted | 0 | 632 | <= 800 |
| tests/scripts/claude-lib/docs/DocsFamilyCheck.Tests.ps1 | already formatted | 0 | 528 | < 700 |
| tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 | already formatted | 0 | 512 | < 700 |
| tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1 | already formatted | 0 | 596 | < 700 |
| tests/scripts/claude-lib/docs/DocsLedger.TestSupport.Tests.ps1 | already formatted | 0 | 250 | < 700 |
| extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsFamilyCheck.psm1 | already formatted | 0 | 297 | <= 800 |
| extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/Invoke-DocsCommand.ps1 | already formatted | 0 | 632 | <= 800 |
