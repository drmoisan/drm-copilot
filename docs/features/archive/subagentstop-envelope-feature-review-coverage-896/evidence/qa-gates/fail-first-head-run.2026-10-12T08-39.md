# Fail-first head run (P12-T3, AC-24)

Timestamp: 2026-10-12T08-39
Command: scratchpad route; CR-PESTER-LIST with <LIST> = T2, T5, T6; <TAGS-IN> = E4-Regression; <PATTERNS> = E4-TR1:*, E4-TR4:*, E4-TR5-P*, E4-TR7:*
EXIT_CODE: 0
Output Summary: E4-TR1 1/0, E4-TR4 1/0, E4-TR5-P 6/0, E4-TR7 1/0 on the branch head; TOTAL Passed=9 Failed=0; EXIT_CODE_COMPUTED: 0. The base failures of the same rows are in the P1-T5 artifact evidence/regression-testing/fail-first.2026-10-12T00-05.md, which now carries a Branch-head run section.

## Output (e896-p12t3)

```
[95m
[95mStarting discovery in 3 files.[0m
[95mDiscovery found 127 tests in 208ms.[0m
[95mRunning tests.[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1[0m[90m 835ms (374ms|315ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\feature-review-coverage-thresholds.Tests.ps1[0m[90m 128ms (58ms|53ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1[0m[90m 254ms (201ms|30ms)[0m
[97mTests completed in 1.24s[0m
[32mTests Passed: 9, [0m[90mFailed: 0, [0m[90mSkipped: 0, [0m[90mInconclusive: 0, [0m[37m[0m[37mNotRun: 118[0m
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | Passed=6 | Failed=0 | Skipped=0 | NotRun=15
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=2 | Failed=0 | Skipped=0 | NotRun=70
SUITE: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=1 | Failed=0 | Skipped=0 | NotRun=33
NAMED: E4-TR1:* | Passed=1 | Failed=0 | NotRun=0 | Total=1
NAMED: E4-TR4:* | Passed=1 | Failed=0 | NotRun=0 | Total=1
NAMED: E4-TR5-P* | Passed=6 | Failed=0 | NotRun=0 | Total=6
NAMED: E4-TR7:* | Passed=1 | Failed=0 | NotRun=0 | Total=1
TOTAL: Passed=9 | Failed=0 | Skipped=0 | NotRun=118 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
