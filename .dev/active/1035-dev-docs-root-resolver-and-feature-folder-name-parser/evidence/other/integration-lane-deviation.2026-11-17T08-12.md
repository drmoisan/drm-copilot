# Integration-Lane Deviation (non-blocking)

Timestamp: 2026-11-17T08-12
Command: none run locally (the test-execution launcher excludes the integration lane, config/test-execution-policy.json suffix integration.tests.ps1)
EXIT_CODE: 0
Output Summary: P6-T4 names tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 among the suites that gain the D-P16 resolver setup mock. Its file name places it in the integration lane, which the launcher refuses locally (TEST_EXECUTION_POLICY_BLOCKED) and which runs in CI only, per the Test Cadence rule that integration suites are never part of a task's test selection. The setup mock was added in its root BeforeAll exactly as in Invoke-ParallelAdmission.Tests.ps1, which passed locally with the same mock. The suite's result is CI evidence (poshqc shard jobs) for the pull request of issue #1035. The same applies to tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1, which the P5-T5 and P5-T7 selections excluded for the same reason.
