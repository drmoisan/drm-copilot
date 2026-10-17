# Final QC pass 3: targeted Pester (P11-T6)

Timestamp: 2026-10-12T08-09
Command: scratchpad route; CR-PESTER-LIST with <LIST> = LIST-CLAUDE-SUITES plus LIST-CODEX-SUITES plus LIST-AUX; no tag filters; <PATTERNS> = E4-TR*, E4-ST*, E4-PX*, E4-TG*, TG*, F824-*, T824-*, and the four GUARD-PATTERNS
EXIT_CODE: 0
Output Summary: S1, S2, S6 GUARD-PATTERN lines Passed=2 Failed=0; N1 Passed=2 Failed=0; every P0-T12 suite present (14 of 14) plus T7 and T8; TOTAL: Passed=1142 Failed=0 Skipped=0 NotRun=0 FailedBlocks=0 FailedContainers=0; EXIT_CODE_COMPUTED: 0

## Output (e896-qc-targeted)

```
[95m
[95mStarting discovery in 16 files.[0m
[95mDiscovery found 1142 tests in 4.56s.[0m
[95mRunning tests.[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1[0m[90m 1.05s (629ms|302ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1[0m[90m 1.15s (985ms|130ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.Issue824.Tests.ps1[0m[90m 254ms (187ms|47ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.ThresholdsGuard.Tests.ps1[0m[90m 458ms (413ms|34ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\feature-review-coverage-thresholds.Tests.ps1[0m[90m 140ms (82ms|45ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1[0m[90m 7.78s (7.02s|199ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1[0m[90m 4.79s (1.51s|44ms)[0m
[32m[+] <repo>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1[0m[90m 11.47s (11.03s|324ms)[0m
[32m[+] <repo>\tests\scripts\claude-runtime\hook-imported-modules-no-stdout.Tests.ps1[0m[90m 10.66s (10.6s|36ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1[0m[90m 534ms (462ms|50ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\feature-review-coverage-thresholds.Tests.ps1[0m[90m 78ms (35ms|27ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\feature-review-coverage-floor-parity.Tests.ps1[0m[90m 177ms (143ms|22ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1[0m[90m 11.65s (11.59s|42ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1[0m[90m 3.29s (2.9s|82ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1[0m[90m 13.74s (13.7s|22ms)[0m
[32m[+] <repo>\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1[0m[90m 1.85s (1.78s|46ms)[0m
[97mTests completed in 69.1s[0m
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
