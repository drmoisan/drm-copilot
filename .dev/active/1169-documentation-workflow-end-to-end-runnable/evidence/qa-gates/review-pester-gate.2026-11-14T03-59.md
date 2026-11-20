# Reviewer Pester Gate at the Reviewed Head (R4 Re-audit)

Timestamp: 2026-11-14T03-59
Command: sh SCRATCH/rv-pester.sh (cd <worktree root>; pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <worktree root>; exit $r.ExitCode); then reviewer parse of artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary:
- Head: 0580d77d765737653b3eda1a7cd4a1f53766ad4c (the main-sync merge of f9e817b2a). The worktree was clean apart from the untracked review artifact before the run.
- Reason for the run: the executor's final Pester run (final-qc-pester.2026-11-14T03-21.md) wrote the coverage report at 03:19:50Z, before the commits 2a587e635 (03:26:45Z) and 0580d77d7 (03:33:59Z) that change PowerShell test files. It also did not exercise the merged legacy-codex-hook-contracts.Tests.ps1 or the PowerShell files that the main sync brought in. This run refreshes the report at the reviewed head.
- Gate: one Invoke-PoshQCParallelTest run, 8 shard processes, every shard exit 0, wall-clock 869.09 s, run from 03:44:24Z to 03:58:54Z; merged reports written.
- JUnit: 23059 tests, 0 failures, 0 errors, 10 disabled.
- Named suites (tests, 0 failures each): enforce-gate-suites.EpicStateIsolation.Discovery 559; claude-hooks enforce-orchestration-preimplementation-gate.Cleanup 41; codex-hooks enforce-orchestration-preimplementation-gate-cleanup 36; enforce-model-routing-receipt.Cleanup 9; enforce-orchestration-preimplementation-gate.DocsEstate 52; codex-hooks enforce-orchestration-preimplementation-gate-docs 55; enforce-model-routing-receipt.DocsEstate 33; hook-docs-estate-context 52; hook-docs-estate-context.Parity 3; docs-estate-workflow.EndToEnd 11; documentation-workflow.CommitStage 42; enforce-docs-complete-gate 156; legacy-codex-hook-contracts 44; enforcement-hooks-no-python-invocation 35; hook-dependency-guard-completeness 743; FileSizePolicy.RepoGate 5.
- Repo-wide line coverage: 95.89% (39564 of 41259).
- Per-file line coverage of the branch's production files (Claude and Codex copies): enforce-docs-complete-gate.ps1 95.00%; enforce-model-routing-receipt-docs.ps1 95.06%; enforce-model-routing-receipt.ps1 96.00%; Claude enforce-orchestration-preimplementation-gate-docs.ps1 97.04%; Codex copy 93.33%; Claude enforce-orchestration-preimplementation-gate.ps1 96.36%; Codex copy 100.00%; hook-docs-estate-context.ps1 100.00% (both); Claude hook-docs-only-diff.ps1 98.46%; Codex copy 97.69%; DocsCompleteGate.psm1 100.00%; DocsLedgerCommands.psm1 99.67%; DocsProfileCommands.psm1 97.33%; DocsReceiptRevision.psm1 100.00%; DocsValidateCommands.psm1 100.00%; Invoke-DocsCommand.ps1 90.82%.
- Changed-line coverage against the merge base f9e817b2a (instrumented added lines of the 17 production files): 97.41% (677 of 695).
- The per-file figures equal those of the executor's 03:19:50Z report. No production file in the branch changed after that run.
