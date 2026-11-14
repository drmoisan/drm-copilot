# Final QC: Pester Gate (P7-T4)

Timestamp: 2026-11-14T17-11
Command: sh SCRATCH/issue-1173-pester.sh final (one Invoke-PoshQCParallelTest over tests/ with the repository configuration, 4 workers); pwsh SCRATCH/issue-1173-pester-summary.ps1 -Root <worktree> -ListFile SCRATCH/issue-1173-cov-final.txt (JUnit totals and per-file line coverage from artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary:
- One parallel run: exit 0, wall-clock 994 s; JUnit tests=24333, failures=0, errors=0, disabled=10.
- Repo-wide line coverage 95.99% (40706 covered, 1700 missed); Phase 0 baseline 95.94%.
- Per-file line coverage of every PowerShell file in `## Coverage Targets`:

| File | Covered | Missed | Line % |
|---|---|---|---|
| .claude/lib/docs/DocsLedgerBatch.psm1 (new) | 166 | 0 | 100.00 |
| .claude/lib/docs/DocsLedgerBindRefs.psm1 (new) | 48 | 0 | 100.00 |
| .claude/lib/docs/DocsReferenceSplit.psm1 (new) | 87 | 0 | 100.00 |
| .claude/lib/docs/DocsProfileSourceRoot.psm1 (new) | 45 | 1 | 97.83 |
| .claude/lib/docs/DocsLedgerCommands.psm1 | 325 | 1 | 99.69 |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 190 | 19 | 90.91 |
| .claude/lib/docs/DocsReferencePlan.psm1 | 168 | 0 | 100.00 |
| .claude/lib/docs/DocsReferenceWriter.psm1 | 231 | 0 | 100.00 |
| .claude/lib/docs/DocsProfile.psm1 | 82 | 0 | 100.00 |
| .claude/lib/docs/DocsProfileCommands.psm1 | 87 | 2 | 97.75 |
| .claude/lib/docs/DocsPageLinks.psm1 | 120 | 0 | 100.00 |
| .claude/lib/docs/DocsInventorySnapshot.psm1 | 102 | 0 | 100.00 |
| .claude/lib/docs/DocsPythonCliArgparse.psm1 | 191 | 0 | 100.00 |
| .claude/lib/docs/DocsAnalyzerPythonCli.psm1 | 159 | 0 | 100.00 |
| .claude/lib/docs/DocsJson.psm1 | 120 | 0 | 100.00 |
| .claude/lib/docs/DocsValidation.psm1 | 154 | 2 | 98.72 |
| .claude/lib/docs/DocsReceipt.psm1 | 95 | 0 | 100.00 |
| .claude/lib/docs/DocsLedgerMutation.psm1 | 61 | 1 | 98.39 |
| .claude/lib/docs/DocsValidateCommands.psm1 | 102 | 0 | 100.00 |
| .claude/lib/docs/DocsSurfaceDeltaCommands.psm1 | 73 | 2 | 97.33 |
| .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 135 | 0 | 100.00 |
| .claude/lib/docs/DocsAnalyzerExtensionImport.psm1 | 195 | 0 | 100.00 |
| .claude/hooks/docs-role-contract.ps1 | 80 | 0 | 100.00 |
| .claude/hooks/validate-docs-role-output.ps1 | 41 | 0 | 100.00 |

- Every file is at or above 85% line coverage. The `## Mirror Contract Tests` Pester suites (docs-authoring-roles Mirrors, Skills and WorkflowText, documentation-workflow.CommitStage, hook-dependency-guard-completeness) ran in this gate with 0 failures.
- Expected failures: none.
