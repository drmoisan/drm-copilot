# Fail-Before: GUARD Alone on the Pre-Fix Tree (P1-T2, Shape S0)

Timestamp: 2026-11-04T00-53
Command: sh SCRATCH/issue-1066-launch-list.sh issue-1066-list-guard.txt guard-alone-prefix.xml issue-1066-p1t2.log (SCRATCH/issue-1066-run-list.ps1 over tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 alone; JUnit to RAW/guard-alone-prefix.xml); outcomes by SCRATCH/issue-1066-junit-sets.ps1 -ListAll
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary:
- Pester: Total=3 Passed=2 Failed=1 FailedBlocks=0 FailedContainers=0.
- `nested harness leaves the process environment unchanged for an empty container`: Passed (control testcase passes).
- `run-actionlint.Tests.ps1 leaves every process environment variable unchanged`: Failed. Failure message: `Expected $null or empty, because run-actionlint.Tests.ps1 must restore every environment variable it changes; differing keys: PATH, but got 'PATH'.` The only differing key is `PATH`.
- `run-actionlint.Tests.ps1 leaves global LASTEXITCODE as the nested harness leaves it`: Passed.
- Control run and the sentinel: the nested control run did not leave `$global:LASTEXITCODE` at the sentinel 41; a separate probe (pwsh -NoProfile -Command: set `$global:LASTEXITCODE = 41`, run the DD2 nested configuration over the in-memory control container, print the value) printed `CONTROL-PASSED 1 LASTEXITCODE-AFTER 0`. Pester itself leaves 0, and the pre-fix TARGET also leaves 0, so the LASTEXITCODE testcase cannot distinguish the pre-fix tree on this host; the environment testcase carries the fail-before.

## Testcase outcomes

```text
FIRST: Total=3 Failed=1
  F1 tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1|run-actionlint.Tests.ps1 environment isolation.run-actionlint.Tests.ps1 leaves every process environment variable unchanged
  O1 Passed tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1|run-actionlint.Tests.ps1 environment isolation.nested harness leaves the process environment unchanged for an empty container
  O1 Failed tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1|run-actionlint.Tests.ps1 environment isolation.run-actionlint.Tests.ps1 leaves every process environment variable unchanged
  O1 Passed tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1|run-actionlint.Tests.ps1 environment isolation.run-actionlint.Tests.ps1 leaves global LASTEXITCODE as the nested harness leaves it
```
