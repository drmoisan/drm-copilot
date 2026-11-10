# Pester Phase 0 Baseline (P0-T4)

Timestamp: 2026-11-10T04-17
Command: sh SCRATCH/issue-1158-pester-baseline.sh (pwsh 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCParallelTest -Root .; exit with the result's ExitCode), then sh SCRATCH/issue-1158-pester-report.sh reading artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: Phase 0 baseline, one Invoke-PoshQCParallelTest run (8 workers, wall clock 2341.98 s, ExitCode 0). JUnit: 21311 tests, 0 failures, 0 errors, 10 skipped, 714 test suites (pass count 21301). Repo-wide line coverage 95.80% (37558 covered, 1645 missed).

## Per-file line coverage (artifacts/pester/powershell-coverage.xml)

| File | Covered | Missed | Line coverage |
|---|---|---|---|
| scripts/powershell/PoshQC/PoshQC.Testing.psm1 | 192 | 13 | 93.66% |
| scripts/powershell/PoshQC/PoshQC.Parallel.psm1 | 148 | 4 | 97.37% |
| scripts/dev-tools/run-poshqc-suite.ps1 | 0 | 5 | 0.00% |

## Integration-named test files (testcase count from the JUnit report)

| File | Tests |
|---|---|
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | 12 |
| tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1 | 3 |
| tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1 | 15 |
| tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | 11 |
| Total | 41 |
