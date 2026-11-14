# Pass-After: GUARD Alone on the Fixed Tree (P2-T3)

Timestamp: 2026-11-04T00-58
Command: sh SCRATCH/issue-1066-launch-list.sh issue-1066-list-guard.txt guard-alone-postfix.xml issue-1066-p2t3.log (SCRATCH/issue-1066-run-list.ps1 over tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1 alone; JUnit to RAW/guard-alone-postfix.xml)
EXIT_CODE: 0
Output Summary:
- Pester: Total=3 Passed=3 Failed=0 Skipped=0 FailedBlocks=0 FailedContainers=0 (GuardForm b: 3 testcases).
- Passed: `nested harness leaves the process environment unchanged for an empty container`.
- Passed: `run-actionlint.Tests.ps1 leaves every process environment variable unchanged` (failed on the pre-fix tree naming PATH; see evidence/regression-testing/fail-before-guard.2026-11-04T00-53.md).
- Passed: `run-actionlint.Tests.ps1 leaves global LASTEXITCODE as the nested harness leaves it`.
