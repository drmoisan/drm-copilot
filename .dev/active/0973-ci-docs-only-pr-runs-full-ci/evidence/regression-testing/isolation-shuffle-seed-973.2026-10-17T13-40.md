# Isolation: Seeded Shuffled File-Order Run, Seed 973 (Issue #973)

Timestamp: 2026-10-17T13-40
Command: sh SCRATCH/issue-973-iso.sh <worktree> (PowerShell 7; issue-973-isolation.ps1 -Seed 973: Fisher-Yates shuffle of the six suites with System.Random seeded 973, one Invoke-Pester process with Run.Path in the shuffled order, coverage off, JUnit to artifacts/pester/pester-junit.xml; then issue-973-report.ps1)
EXIT_CODE: 0

Seed: 973

File order used (also the suite order recorded in the JUnit file):

1. `tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1`
2. `tests/scripts/workflows/CiWorkflow.Tests.ps1`
3. `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1`
4. `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1`
5. `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`
6. `tests/scripts/ci/CiChangeScope.Tests.ps1`

Counts from `artifacts/pester/pester-junit.xml` (written 2026-10-17T13-40): 208 test cases, 208 passed, 0 failed, 0 skipped; no container errors.

Output Summary: seed 973, failed count 0 (208 passed). No order dependence observed.
