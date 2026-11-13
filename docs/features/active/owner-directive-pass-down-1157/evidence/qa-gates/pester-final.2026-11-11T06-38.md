# Pester final gate, run 3 (issue #1157, P6-T5)

Timestamp: 2026-11-11T06-38
Command: sh SCRATCH/issue-1157-pester.sh (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root <item worktree>)
EXIT_CODE: 1
Output Summary:
- Invoke-PoshQCParallelTest: workers=8; wall-clock=952.24s; ExitCode 1. Shard 4 exited 1 (one failure) and shard 6 exited 248; shards 1, 2, 3, 5, 7, and 8 exited 0. No merged JUnit or coverage file was written, so this run supplies no pass count or coverage figure.
- Cause: host runtime, not the change under test. The shard 6 log carries 104 occurrences of "Could not load file or assembly 'System.IO.Pipelines, Version=10.0.0.0'" (FileNotFoundException), raised from System.Text.Json disposal in unrelated modules as well as in this item's modules (for example `ConvertFrom-DocsJsonText` in .claude/lib/docs/DocsJson.psm1 and the Docs*, assess, guard-run, and OrchestratorStateEpicWaveBarrier parity suites). The single shard 4 failure is `validate-pr-author-output.ps1 script entrypoint (end-to-end)`, whose child pwsh process exited -2147450726 (a .NET host start failure) instead of 2.
- A probe after the run loaded System.IO.Pipelines 10.0.0.0 in a fresh pwsh 7.6.10 process without error, and the same suites passed in run 2 on the same tree apart from the two coverage test files added since run 2. The gate is re-run unchanged.
