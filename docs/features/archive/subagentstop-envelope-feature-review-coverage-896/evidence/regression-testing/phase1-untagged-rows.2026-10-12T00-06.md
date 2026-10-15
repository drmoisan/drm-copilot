# Phase 1 Untagged Rows (P1-T6)

Timestamp: 2026-10-12T00-06
Command: CR-PESTER-LIST (scratchpad route) with <LIST> = T2, T5, T6; <TAGS-IN> empty; <TAGS-OUT> = E4-Regression; <PATTERNS> = E4-TR5-N*, T824-*
EXIT_CODE: 0
Output Summary: NAMED: E4-TR5-N* | Passed=3 | Failed=0; NAMED: T824-* | Passed=11 | Failed=0; TOTAL: Passed=86 | Failed=0 | NotRun=9 (the nine E4-Regression tests excluded); EXIT_CODE_COMPUTED: 0.

## CR-PESTER-LIST output

```
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | Result=Passed
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Result=Passed
SUITE: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | Passed=14 | Failed=0 | Skipped=0 | NotRun=6
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=43 | Failed=0 | Skipped=0 | NotRun=2
SUITE: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=29 | Failed=0 | Skipped=0 | NotRun=1
NAMED: E4-TR5-N* | Passed=3 | Failed=0 | NotRun=0 | Total=3
NAMED: T824-* | Passed=11 | Failed=0 | NotRun=0 | Total=11
TOTAL: Passed=86 | Failed=0 | Skipped=0 | NotRun=9 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
