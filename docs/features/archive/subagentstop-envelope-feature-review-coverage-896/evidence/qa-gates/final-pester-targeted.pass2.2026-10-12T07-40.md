# Final QC pass 2: targeted Pester (P11-T6)

Timestamp: 2026-10-12T07-40
Command: scratchpad route; CR-PESTER-LIST with <LIST> = LIST-CLAUDE-SUITES plus LIST-CODEX-SUITES plus LIST-AUX; no tag filters; <PATTERNS> = E4-TR*, E4-ST*, E4-PX*, E4-TG*, TG*, F824-*, T824-*, and the four GUARD-PATTERNS
EXIT_CODE: 0
Output Summary: S1, S2, S6 GUARD-PATTERN lines Passed=2 Failed=0; N1 Passed=2 Failed=0; every P0-T12 suite present (14 of 14) plus T7 and T8; enforcement-hooks-no-python-invocation Passed=32 Failed=0 (as P0-T12); TOTAL: Passed=1142 Failed=0 Skipped=0 NotRun=0 FailedBlocks=0 FailedContainers=0; EXIT_CODE_COMPUTED: 0

## Output (e896-qc-targeted)

```
[95m
[95mStarting discovery in 16 files.[0m
[95mDiscovery found 1142 tests in 4.52s.[0m
[95mRunning tests.[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1[0m[90m 1.05s (617ms|296ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1[0m[90m 1.12s (956ms|132ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.Issue824.Tests.ps1[0m[90m 262ms (194ms|47ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.ThresholdsGuard.Tests.ps1[0m[90m 411ms (364ms|34ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\feature-review-coverage-thresholds.Tests.ps1[0m[90m 129ms (74ms|41ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1[0m[90m 7.92s (7.12s|201ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1[0m[90m 4.68s (1.48s|41ms)[0m
[32m[+] <repo>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1[0m[90m 11.48s (11.05s|324ms)[0m
[32m[+] <repo>\tests\scripts\claude-runtime\hook-imported-modules-no-stdout.Tests.ps1[0m[90m 10.78s (10.73s|34ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1[0m[90m 534ms (466ms|46ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\feature-review-coverage-thresholds.Tests.ps1[0m[90m 75ms (36ms|26ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\feature-review-coverage-floor-parity.Tests.ps1[0m[90m 138ms (106ms|20ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1[0m[90m 12.93s (12.85s|51ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1[0m[90m 3.29s (2.91s|100ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1[0m[90m 15.69s (15.66s|20ms)[0m
[32m[+] <repo>\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1[0m[90m 1.97s (1.88s|62ms)[0m
[97mTests completed in 72.5s[0m
[32mTests Passed: 1142, [0m[90mFailed: 0, [0m[90mSkipped: 0, [0m[90mInconclusive: 0, [0m[37m[0m[90mNotRun: 0[0m
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | Passed=21 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | Passed=148 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | Passed=14 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=72 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | Passed=17 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | Passed=27 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | Passed=8 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | Passed=32 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | Passed=598 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | Passed=25 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | Passed=3 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1 | Passed=3 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1 | Passed=21 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | Passed=76 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | Passed=43 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=34 | Failed=0 | Skipped=0 | NotRun=0
NAMED: E4-TR* | Passed=43 | Failed=0 | NotRun=0 | Total=43
NAMED: E4-ST* | Passed=17 | Failed=0 | NotRun=0 | Total=17
NAMED: E4-PX* | Passed=24 | Failed=0 | NotRun=0 | Total=24
NAMED: E4-TG* | Passed=2 | Failed=0 | NotRun=0 | Total=2
NAMED: TG* | Passed=6 | Failed=0 | NotRun=0 | Total=6
NAMED: F824-* | Passed=17 | Failed=0 | NotRun=0 | Total=17
NAMED: T824-* | Passed=11 | Failed=0 | NotRun=0 | Total=11
NAMED: S1:*.claude/hooks/validate-feature-review-coverage.ps1* | Passed=2 | Failed=0 | NotRun=0 | Total=2
NAMED: S2:*.claude/hooks/validate-feature-review-coverage.ps1* | Passed=2 | Failed=0 | NotRun=0 | Total=2
NAMED: S6:*.claude/hooks/validate-feature-review-coverage.ps1* | Passed=2 | Failed=0 | NotRun=0 | Total=2
NAMED: N1:* | Passed=2 | Failed=0 | NotRun=0 | Total=2
TOTAL: Passed=1142 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
