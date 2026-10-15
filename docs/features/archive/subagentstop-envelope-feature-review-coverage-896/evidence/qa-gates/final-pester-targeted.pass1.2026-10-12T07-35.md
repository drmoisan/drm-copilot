# Final QC pass 1: targeted Pester (P11-T6) - restart cause

Timestamp: 2026-10-12T07-35
Command: scratchpad route; CR-PESTER-LIST with <LIST> = LIST-CLAUDE-SUITES plus LIST-CODEX-SUITES plus LIST-AUX; no tag filters; <PATTERNS> = E4-TR*, E4-ST*, E4-PX*, E4-TG*, TG*, F824-*, T824-*, and the four GUARD-PATTERNS
EXIT_CODE: 1
Output Summary: FAILED (not PEF; P0-T12 recorded enforcement-hooks-no-python-invocation at Passed=32 Failed=0): enforcement-hooks-no-python-invocation reported .claude/hooks/validate-feature-review-coverage.ps1:78 [DynamicInvocation] for the Phase 5 '$finding = & { ... }' script-block invocation. Restart cause for pass 2: the decision body was moved from the script-block invocation into a single-pass do { ... } while ($false) block whose findings exit with break (same control flow, no function added), the H1 mirror was re-copied, and the loop restarted from P11-T1. All other suites and named patterns passed (TOTAL Passed=1141 Failed=1).

## Output (e896-qc-targeted)

```
[95m
[95mStarting discovery in 16 files.[0m
[95mDiscovery found 1142 tests in 4.46s.[0m
[95mRunning tests.[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1[0m[90m 1.03s (599ms|301ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1[0m[90m 1.17s (1.02s|120ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.Issue824.Tests.ps1[0m[90m 338ms (252ms|64ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\validate-feature-review-coverage.ThresholdsGuard.Tests.ps1[0m[90m 433ms (385ms|35ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\feature-review-coverage-thresholds.Tests.ps1[0m[90m 130ms (68ms|49ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1[0m[90m 8.03s (7.24s|200ms)[0m
[32m[+] <repo>\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1[0m[90m 4.73s (1.56s|47ms)[0m
[32m[+] <repo>\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1[0m[90m 12.09s (11.57s|405ms)[0m
[32m[+] <repo>\tests\scripts\claude-runtime\hook-imported-modules-no-stdout.Tests.ps1[0m[90m 11.1s (11.04s|30ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1[0m[90m 538ms (472ms|46ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\feature-review-coverage-thresholds.Tests.ps1[0m[90m 82ms (39ms|28ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\feature-review-coverage-floor-parity.Tests.ps1[0m[90m 146ms (111ms|23ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1[0m[90m 11.63s (11.55s|64ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1[0m[90m 3.29s (2.93s|90ms)[0m
[32m[+] <repo>\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1[0m[90m 13.86s (13.81s|28ms)[0m
[-] enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree 814ms (813ms|1ms)
 at @($residual).Count | Should -Be 0 -Because (, <repo>\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1:442
 at <ScriptBlock>, <repo>\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1:442
 Expected 0, because residual Python invocation sites:
 .claude/hooks/validate-feature-review-coverage.ps1:78 [DynamicInvocation] in Invoke-FeatureReviewCoverageValidation: command position is not a literal constant, so its target cannot be verified statically (fail-closed), but got 1.
[97mTests completed in 70.46s[0m
[97mTests Passed: 1141, [0m[91mFailed: 1, [0m[90mSkipped: 0, [0m[90mInconclusive: 0, [0m[37m[0m[90mNotRun: 0[0m
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
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | Result=Failed
SUITE: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | Passed=21 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | Passed=148 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | Passed=14 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=72 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | Passed=17 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | Passed=27 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | Passed=8 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | Passed=31 | Failed=1 | Skipped=0 | NotRun=0
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
FAILED: enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree :: Expected 0, because residual Python invocation sites: .claude/hooks/validate-feature-review-coverage.ps1:78 [DynamicInvocation] in Invoke-FeatureReviewCoverageValidation: command position is not a literal constant, so its target cannot be verified statically (fail-closed), but got 1.
TOTAL: Passed=1141 | Failed=1 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 1
PROCESS_EXIT: 1
```
