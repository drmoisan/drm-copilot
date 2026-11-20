# Pester Phase 0 Baseline (P0-T4)

Timestamp: 2026-11-14T07-12
Command: sh SCRATCH/issue-1173-pester.sh baseline (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <worktree> -WorkerCount 4; launcher exits with the returned ExitCode); summary read by SCRATCH/issue-1173-pester-summary.ps1 from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
- One Invoke-PoshQCParallelTest run, 4 shard processes, elapsed 1,379 s; returned ExitCode 0.
- JUnit: tests=24065, failures=0, errors=0, disabled=10 (shard logs: passed 6170 + 5031 + 6732 + 6122 = 24055, failed 0, skipped 1 + 2 + 7 + 0 = 10).
- Repo-wide line coverage (JaCoCo LINE counter): 40128 covered, 1699 missed, 95.94%.
- Per-file line coverage of the existing PowerShell files in `## Coverage Targets` is in the table below. The four new modules (DocsLedgerBatch, DocsLedgerBindRefs, DocsReferenceSplit, DocsProfileSourceRoot) have no pre-change run.

| File | Covered | Missed | Line % |
|---|---|---|---|
| .claude/lib/docs/DocsLedgerCommands.psm1 | 302 | 1 | 99.67 |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 188 | 19 | 90.82 |
| .claude/lib/docs/DocsReferencePlan.psm1 | 159 | 0 | 100.00 |
| .claude/lib/docs/DocsReferenceWriter.psm1 | 178 | 0 | 100.00 |
| .claude/lib/docs/DocsProfile.psm1 | 81 | 0 | 100.00 |
| .claude/lib/docs/DocsProfileCommands.psm1 | 73 | 2 | 97.33 |
| .claude/lib/docs/DocsPageLinks.psm1 | 118 | 0 | 100.00 |
| .claude/lib/docs/DocsInventorySnapshot.psm1 | 93 | 0 | 100.00 |
| .claude/lib/docs/DocsPythonCliArgparse.psm1 | 130 | 0 | 100.00 |
| .claude/lib/docs/DocsAnalyzerPythonCli.psm1 | 119 | 0 | 100.00 |
| .claude/lib/docs/DocsJson.psm1 | 103 | 0 | 100.00 |
| .claude/lib/docs/DocsValidation.psm1 | 154 | 2 | 98.72 |
| .claude/lib/docs/DocsReceipt.psm1 | 95 | 0 | 100.00 |
| .claude/lib/docs/DocsLedgerMutation.psm1 | 61 | 1 | 98.39 |
| .claude/lib/docs/DocsValidateCommands.psm1 | 102 | 0 | 100.00 |
| .claude/lib/docs/DocsSurfaceDeltaCommands.psm1 | 73 | 2 | 97.33 |
| .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 135 | 0 | 100.00 |
| .claude/lib/docs/DocsAnalyzerExtensionImport.psm1 | 195 | 0 | 100.00 |
| .claude/hooks/docs-role-contract.ps1 | 79 | 0 | 100.00 |
| .claude/hooks/validate-docs-role-output.ps1 | 41 | 0 | 100.00 |
