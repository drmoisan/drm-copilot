# PowerShell Static Baseline (P0-T1)

Timestamp: 2026-11-14T06-46
Command: sh SCRATCH/issue-1173-p0t1.sh (pwsh 7: Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with file text, check mode, no write; then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary:
- Step 1 format check (no file rewritten): 20 files, 0 drift findings.
- Step 2 PSScriptAnalyzer: 20 files, 0 findings.

## Files (20)

- .claude/lib/docs/DocsLedgerCommands.psm1
- .claude/lib/docs/Invoke-DocsCommand.ps1
- .claude/lib/docs/DocsReferencePlan.psm1
- .claude/lib/docs/DocsReferenceWriter.psm1
- .claude/lib/docs/DocsProfile.psm1
- .claude/lib/docs/DocsProfileCommands.psm1
- .claude/lib/docs/DocsPageLinks.psm1
- .claude/lib/docs/DocsInventorySnapshot.psm1
- .claude/lib/docs/DocsPythonCliArgparse.psm1
- .claude/lib/docs/DocsAnalyzerPythonCli.psm1
- .claude/lib/docs/DocsJson.psm1
- .claude/lib/docs/DocsValidation.psm1
- .claude/lib/docs/DocsReceipt.psm1
- .claude/lib/docs/DocsLedgerMutation.psm1
- .claude/lib/docs/DocsValidateCommands.psm1
- .claude/lib/docs/DocsSurfaceDeltaCommands.psm1
- .claude/lib/docs/DocsAnalyzerRegistry.psm1
- .claude/lib/docs/DocsAnalyzerExtensionImport.psm1
- .claude/hooks/docs-role-contract.ps1
- .claude/hooks/validate-docs-role-output.ps1

New modules created later by the plan (DocsProfileSourceRoot, DocsLedgerBatch, DocsLedgerBindRefs, DocsReferenceSplit) have no pre-change file.
