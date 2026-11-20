# Existing PoshQC Tests Before Adaptation (P4-T2)

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P4-TR (replaces TR args '<the ten existing PoshQC test files>', ''). Source: workflow `_poshqc.yml` (workflow_dispatch) on temporary branch `tmp/527-phase3-preadapt` at PHASE3_SHA 94853dca5206bf1276ab91a0df958613ff326207 (fix present, Phase 4 adaptation absent), run https://github.com/drmoisan/drm-copilot/actions/runs/36983547210, job https://github.com/drmoisan/drm-copilot/actions/runs/36983547210/job/110763325528. Job log `artifacts/ci/run-36983547210/job.log` searched with the Grep tool for `##[error][-]`, container/discovery failure lines, and the Pester summary line.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: the full suite ran with `Tests Passed: 6515, Failed: 4, Skipped: 10` (job log line 1300); exactly four `##[error][-]` lines, each naming one of the four D14 tests; FAILED_CONTAINERS=0 (no container or discovery failure line in the log). The full CI run covers the ten existing PoshQC test files named by the task plus all other suites, so no failure outside the D14 set exists in those ten files or anywhere else.
- Acceptance: FAILED_CONTAINERS=0 and every FAILED_TEST line names a D14 test. Met. No ESCALATION condition.
- EXIT_CODE 1 is the expected outcome on this pre-adaptation head (four predicted failures); ExpectedExitCode 1 is recorded for that reason.

## FAILED_TEST lines (job log)

```text
line 1255: Invoke-PoshQCTest.When coverage is enabled.Should generate Koverage copy by default when coverage is enabled   (tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1; D14)
line 1265: Invoke-PoshQCTest.When coverage is enabled.Should use custom KoverageOutputPath when provided   (tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1; D14)
line 1280: Invoke-PoshQCTest post-run summary branches (issue #392).replays coverage report lines up to the Missed commands marker and stops (lines 410-415, 417-420, 427-428, 437-439)   (PoshQC.TestingInvokeSummary.Tests.ps1; D14)
line 1287: Invoke-PoshQCTest post-run summary branches (issue #392).falls back to the first raw line when the Missed commands marker is the first line seen (lines 423-424, 427-428, 437-439)   (PoshQC.TestingInvokeSummary.Tests.ps1; D14)
```

Representative message (line 1282): `Expected 'Name  Coverage' to be found in collection @('Code coverage population: source=fallback; files=0', 'Code coverage disabled for this invocation: no configured coverage path exists under root '/summary-root'.', ...)`, which matches the D14 prediction (an empty settings `Path` now resolves a population and the population log line changes the log sequence).
