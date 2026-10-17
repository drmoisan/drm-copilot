# Baseline Targeted Pester (P0-T12)

Timestamp: 2026-10-11T23-30
Command: CR-PESTER-LIST (scratchpad route) with <LIST> = LIST-CLAUDE-SUITES (T1, T2, T3, T4, T5, tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1, tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1, tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1, tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1), T6, T9, tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1, tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1, LIST-AUX (tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1); <TAGS-IN> empty; <TAGS-OUT> = E4-Regression; <PATTERNS> = T824-*, F824-*, TG*, S1:*.claude/hooks/validate-feature-review-coverage.ps1*, S2:*.claude/hooks/validate-feature-review-coverage.ps1*, S6:*.claude/hooks/validate-feature-review-coverage.ps1*, N1:*
EXIT_CODE: 0
Output Summary: TOTAL: Passed=1038 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0; EXIT_CODE_COMPUTED: 0; S1/S2/S6 guard rows Passed=2 | Failed=0 each; N1:* Passed=2 | Failed=0.

N1-BASELINE: PASSING
PRE-EXISTING: NONE (no FAILED: line was printed)

## Output (CONTAINER, SUITE, NAMED, FAILED, TOTAL, and exit lines; Pester progress lines omitted)

```
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
CONTAINER: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | Passed=11 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1 | Passed=140 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1 | Passed=12 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=43 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | Passed=17 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | Passed=4 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | Passed=6 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | Passed=32 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 | Passed=598 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/claude-runtime/hook-imported-modules-no-stdout.Tests.ps1 | Passed=25 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 | Passed=3 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | Passed=75 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | Passed=43 | Failed=0 | Skipped=0 | NotRun=0
SUITE: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=29 | Failed=0 | Skipped=0 | NotRun=0
NAMED: T824-* | Passed=11 | Failed=0 | NotRun=0 | Total=11
NAMED: F824-* | Passed=17 | Failed=0 | NotRun=0 | Total=17
NAMED: TG* | Passed=6 | Failed=0 | NotRun=0 | Total=6
NAMED: S1:*.claude/hooks/validate-feature-review-coverage.ps1* | Passed=2 | Failed=0 | NotRun=0 | Total=2
NAMED: S2:*.claude/hooks/validate-feature-review-coverage.ps1* | Passed=2 | Failed=0 | NotRun=0 | Total=2
NAMED: S6:*.claude/hooks/validate-feature-review-coverage.ps1* | Passed=2 | Failed=0 | NotRun=0 | Total=2
NAMED: N1:* | Passed=2 | Failed=0 | NotRun=0 | Total=2
TOTAL: Passed=1038 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
