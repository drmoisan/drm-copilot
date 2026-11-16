# Phase Gate: Phase 1 (Tests First, Remediation Cycle 1)

Timestamp: 2026-11-14T16-07
Command: sh SCRATCH/issue-1182-phasegate.sh r1p1 (stages 1-6: Black --check, Ruff, Pyright; PoshQC format check-only and PSScriptAnalyzer over all PowerShell files; one pytest -n auto run; one Invoke-PoshQCParallelTest run)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- The only failure is the named [expect-fail] row "(h) starts no worktree listing for an absolute non-receipt path", confirmed failing on the listing invocation count ("Expected Get-OrchestrationGateWorktreeList ... to be called 0 times exactly, but was called 1 time"). EXIT_CODE 1 is the Pester gate exit that this failure produces.
- Stage 1 format: Black --check exit 0; PoshQC format check-only FORMAT_CHANGED=0. git status --porcelain identical before and after the gate.
- Stage 2 lint: Ruff exit 0; PSScriptAnalyzer exit 0 (0 findings, 0 analyzer errors).
- Stage 3 type check: Pyright exit 0. PowerShell has no type-check stage.
- Stage 4 architecture-boundary tests: none cover the changed PowerShell test file; dependency-cruiser is TypeScript-only and no TypeScript file changed.
- Stage 5 pytest: one pytest -n auto run, 16824 passed, 6 skipped, 0 failed (includes the bundle and pack-manifest contract tests).
- Stage 5 Pester: one Invoke-PoshQCParallelTest run, ExitCode 1; from the 8 shard JUnit files: tests 25399, passed 25382, failed 1, skipped 16. The single failure is the expect-fail row above; every other test passes (Phase 0 baseline failed 0).
- Stage 6 contract checks: covered by the pytest run above.
- Line coverage read from the shard coverage files (merged coverage is not written on a failing run): repo-wide 96.03% (42206/43950); .claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1 100.00% (32/32).
