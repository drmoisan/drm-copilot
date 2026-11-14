# Scoped Pester Proof (remediation cycle 1, P1-T2)

Timestamp: 2026-11-14T13-19
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/powershell/PoshQC/PoshQC.ParallelScoped.Tests.ps1 tests/scripts/claude-skills/test-execution-policy/Invoke-PesterSuite.Tests.ps1 (through SCRATCH/issue-1158-run-suite.sh); counts read from artifacts/pester/pester-junit.xml
EXIT_CODE: 0
Output Summary: the launcher exited 0. The log line reads "Invoke-PoshQCParallelTest: workers=2; wall-clock=151.58s; exit code=0", so the worker count is 2, capped by the two selected files. The merged JUnit holds 2 suites and 32 tests, 32 passed, 0 failures, 0 errors, 0 skipped: PoshQC.ParallelScoped.Tests.ps1 12 cases and Invoke-PesterSuite.Tests.ps1 20 cases (10 cases for each of the .claude and .agents copies), which is every test case of the two files.

## Reach Without a Launcher or Hook Change

- Launcher: Invoke-PesterSuite.ps1 reads the declared parameter names of Invoke-PoshQCParallelTest, so -TestPath became a key with no launcher change; the new case "reads TestPath through the default GetParameterName as the scoped entry (C1)" records TestPath equal to tests/a.Tests.ps1 and tests/dir in order and no WorkerCount key, for both copies.
- Hook: tests/scripts/claude-hooks/enforce-test-execution-policy.Tests.ps1 gained the allow row for the launcher pester suite with -TestPath and the deny row "a scoped Pester lane path" (-TestPath tests/x/Foo.integration.tests.ps1, integration-lane reason); the file's 157 cases passed in a scoped launcher run (workers=1).

## Note

A scoped run's merged files under artifacts/pester/ cover its selection only and are not gate evidence.
