# Fail-First: PoshQC.Coverage.Tests.ps1 Against Pre-Fix Code (P2-T4)

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P2-T4 (replaces TR args 'tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1', ''). Source: workflow `_poshqc.yml` (workflow_dispatch) on temporary branch `tmp/527-phase2-failfirst` at PHASE2_SHA bb233fe7 (Phase 2 tests present, fix absent), run https://github.com/drmoisan/drm-copilot/actions/runs/36983544629, job https://github.com/drmoisan/drm-copilot/actions/runs/36983544629/job/110763320058, step `Test PowerShell` (`Invoke-PoshQCTest -Root <CI_ROOT>`). Failing test names and messages read with the Read and Grep tools from the downloaded job log `artifacts/ci/run-36983544629/job.log` (git-ignored) at lines 1250-1330. The temporary branch is deleted by the orchestrator; the run URL is the durable reference.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Test step failed as expected: `Tests Passed: 6489, Failed: 30, Skipped: 10` (job log line 1471), `Process completed with exit code 1` (line 1474). All 13 nodes of PoshQC.Coverage.Tests.ps1 failed (R1-R6, F1-F7); the other 17 failures are the PoshQC.CoverageConfig.Tests.ps1 nodes (P2-T5). TR-equivalent line for this file: PASSED=0 FAILED=13 SKIPPED=0 MISSING_REQUIRED=0 FAILED_CONTAINERS=0 (no container or discovery failure line in the log).
- Acceptance: R1, R2, R3 messages each contain `Expected` and contain neither `CommandNotFoundException` nor `A parameter cannot be found`. Met (see FAILED_TEST lines below). R4-R6 fail on parameter binding and F1-F7 on command resolution, as the task states is expected.

## FAILED_TEST lines (job log; CI root written `<CI_ROOT>`)

```text
FAILED_TEST Invoke-PoshQCTest coverage population (issue #527).measures an identical population for the repository and bundled settings copies over the same workspace :: Expected @('/cov-root/scripts/a.ps1', '/cov-root/scripts/b.psm1', '/cov-root/.claude/hooks/h.ps1'), but got @('/cov-root/scripts/a.ps1', '/cov-root/.claude/hooks/h.ps1'). at $secondPopulation | Should -Be $firstPopulation, <CI_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.Coverage.Tests.ps1:136
FAILED_TEST Invoke-PoshQCTest coverage population (issue #527).measures only the consumer production file when a stale bundled allow-list names pushed-down files :: Expected strings to be the same, but they were different. Expected length: 29 Actual length: 41 Strings differ at index 10. Expected: '/cov-root/scripts/Sample.psm1' But was: '/cov-root/.claude/hooks/validate-bash.ps1' at $population | Should -Be @('/cov-root/scripts/Sample.psm1'), <CI_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.Coverage.Tests.ps1:162
FAILED_TEST Invoke-PoshQCTest coverage population (issue #527).logs the population source and file count before Pester runs :: Expected 'Code coverage population: source=config; files=3' to be found in collection PESTER-INVOKED, but it was not found. at $script:covLogs | Should -Contain $populationLine, <CI_ROOT>\tests\scripts\powershell\PoshQC\PoshQC.Coverage.Tests.ps1:178
FAILED_TEST Invoke-PoshQCTest coverage population (issue #527).resolves a relative Root to an absolute path before building run, coverage, and output paths :: ParameterBindingException: A parameter cannot be found that matches parameter name 'ResolveCoveragePopulation'. (line 197)
FAILED_TEST Invoke-PoshQCTest coverage population (issue #527).disables coverage, logs once, and still runs Pester when the derived population is empty :: ParameterBindingException: A parameter cannot be found that matches parameter name 'ResolveCoveragePopulation'. (line 223)
FAILED_TEST Invoke-PoshQCTest coverage population (issue #527).hands the scan-configuration folders to the coverage resolver when -ScanFolders is absent :: ParameterBindingException: A parameter cannot be found that matches parameter name 'ResolveCoveragePopulation'. (line 249)
FAILED_TEST Get-PoshQCCoverageFileSet (issue #527).returns the same ordinally sorted list for shuffled enumeration order :: CommandNotFoundException: The term 'Get-PoshQCCoverageFileSet' is not recognized ... (line 297)
FAILED_TEST Get-PoshQCCoverageFileSet (issue #527).collapses case-variant duplicates to one entry :: CommandNotFoundException: The term 'Get-PoshQCCoverageFileSet' is not recognized ... (line 314)
FAILED_TEST Get-PoshQCCoverageFileSet (issue #527).collapses files reached through overlapping roots :: CommandNotFoundException: The term 'Get-PoshQCCoverageFileSet' is not recognized ... (line 330)
FAILED_TEST Get-PoshQCCoverageFileSet (issue #527).excludes *.Tests.ps1 files, the root-level tests tree, and default excluded directories :: CommandNotFoundException: The term 'Get-PoshQCCoverageFileSet' is not recognized ... (line 352)
FAILED_TEST Get-PoshQCCoverageFileSet (issue #527).keeps only .ps1 and .psm1 files :: CommandNotFoundException: The term 'Get-PoshQCCoverageFileSet' is not recognized ... (line 366)
FAILED_TEST Get-PoshQCCoverageFileSet (issue #527).skips a nonexistent root with one warning naming the root :: CommandNotFoundException: The term 'Get-PoshQCCoverageFileSet' is not recognized ... (line 380)
FAILED_TEST Get-PoshQCCoverageFileSet (issue #527).returns an empty set when every root is missing :: CommandNotFoundException: The term 'Get-PoshQCCoverageFileSet' is not recognized ... (line 396)
```

## Check of the R1-R3 condition

| Test | Contains `Expected` | Contains `CommandNotFoundException` | Contains `A parameter cannot be found` |
| --- | --- | --- | --- |
| R1 | yes | no | no |
| R2 | yes | no | no |
| R3 | yes | no | no |
