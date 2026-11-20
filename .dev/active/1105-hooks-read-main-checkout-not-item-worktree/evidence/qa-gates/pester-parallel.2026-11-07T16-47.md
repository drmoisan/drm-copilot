# QA gate: Pester parallel run (issue 1105, remediation cycle 1)

Timestamp: 2026-11-07T16-47
Task: [P3-T2]
Command: sh SCRATCH/issue-1105-pester.sh c1final2 (pwsh -NoProfile: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree>`; output to SCRATCH/issue-1105-c1final2-pester.log)
EXIT_CODE: 0
Output Summary:
- Returned ExitCode: 0 (8 workers, every shard exit 0, wall clock 499.02 s).
- Run history: this is the second gate run. The first (`c1final1`) returned ExitCode 1; shard 3 failed 2 new cases in `validate-feature-review-coverage.TargetWorktree.Tests.ps1`.
  - Cause: those cases filtered on `$Root`, a parameter the hook does not pass. Under the PoshQC host, the filter resolved `$Root` from PoshQC's own scope.
  - Fix: the filter now matches on `Path` alone. The fix was committed, and the loop restarted from [P3-T1].
- Totals from `artifacts/pester/pester-junit.xml`: 15758 tests, 15748 passed, 0 failed, 0 errors, 10 skipped (JUnit `disabled`).
- Named suites (tests / failures):
  - subagentstop-target-worktree.Tests.ps1: 39 / 0
  - validate-task-researcher-output.TargetWorktree.Tests.ps1: 9 / 0
  - validate-prd-feature-output.TargetWorktree.Tests.ps1: 12 / 0
  - validate-required-artifact-output.TargetWorktree.Tests.ps1: 10 / 0
  - validate-planner-output.TargetWorktree.Tests.ps1: 10 / 0
  - validate-executor-output.TargetWorktree.Tests.ps1: 19 / 0
  - validate-feature-review-coverage.TargetWorktree.Tests.ps1: 21 / 0
  - enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1: 486 / 0 (AC-4 and AC-6 rows included)
  - hook-dependency-guard-completeness.Tests.ps1: 671 / 0
  - hook-dependency-failure.Claude.Tests.ps1: 191 / 0
  - enforcement-hooks-no-python-invocation.Tests.ps1: 33 / 0
  - FileSizePolicy.RepoGate.Tests.ps1: 5 / 0
- Repository line coverage (`artifacts/pester/powershell-coverage.xml`, same run): 94.06% (24264 covered, 1533 missed).
- Per-file line coverage (`.claude/hooks/`, same run):
  - subagentstop-target-worktree.ps1: 98.91% (91/92), at or above 85%
  - validate-feature-review-coverage-freshness.ps1: 97.96% (48/49)
  - validate-task-researcher-output.ps1: 98.33% (118/120)
  - validate-prd-feature-output.ps1: 100.00% (80/80)
  - validate-required-artifact-output.ps1: 98.73% (78/79)
  - validate-planner-output.ps1: 99.55% (221/222)
  - validate-executor-output.ps1: 100.00% (164/164)
  - validate-feature-review-coverage.ps1: 100.00% (124/124)
