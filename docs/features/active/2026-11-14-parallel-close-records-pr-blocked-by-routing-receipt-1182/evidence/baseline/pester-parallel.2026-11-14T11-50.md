# Phase 0 Baseline: Pester Parallel Gate

Timestamp: 2026-11-14T11-36
Command: sh SCRATCH/issue-1182-basegate.sh (pwsh: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <worktree>; exit $r.ExitCode), one run
EXIT_CODE: 0
Output Summary:
- Invoke-PoshQCParallelTest ExitCode 0; every shard exited 0; run window 2026-11-14T11-36 to 2026-11-14T11-48 (UTC).
- The run measured the pre-change tree: the two untracked [P1-T1] suites were moved to SCRATCH for the duration of the run and restored afterwards, so no issue #1182 file was in the run.
- Counts from the merged artifacts/pester/pester-junit.xml: tests 25297, passed 25281, failed 0, errors 0, skipped 16.
- Failing tests: none.
- Repo-wide line coverage from the merged artifacts/pester/powershell-coverage.xml: 96.02% (42083/43827).
- Per-file line coverage:
  - .claude/hooks/enforce-model-routing-receipt.ps1: 96.00% (96/100)
  - .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: 96.47% (164/170)
- Logical line counts: .claude/hooks/enforce-model-routing-receipt.ps1 406; .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 487 (486 line terminators, no terminator after the last line).
