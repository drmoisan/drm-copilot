# Fail-First Regression Run (P1-T5; AC-24 base half)

Timestamp: 2026-10-12T00-05
Command: CR-PESTER-LIST (scratchpad route) with <LIST> = tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1, tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1, tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1; <TAGS-IN> = E4-Regression; <TAGS-OUT> empty; <PATTERNS> = E4-TR1:*, E4-TR4:*, E4-TR5-P*, E4-TR7:*
EXIT_CODE: 1
ExpectedExitCode: 1
Base: ebf4504ae6f881c5b34b91082b3df474c04d13f2
Output Summary: run against the unchanged base production files (H1, H4, H5 as merged from the integration ref). Every regression test fails as expected: E4-TR1 Failed=1, E4-TR4 Failed=1, E4-TR5-P* Failed=6, E4-TR7 Failed=1; TOTAL Passed=0 | Failed=9 | NotRun=86 (untagged tests filtered out); EXIT_CODE_COMPUTED: 1; process exit code 1.

Route note: the first execution of this step through the scratchpad route reported process exit 0 with EXIT_CODE_COMPUTED: 1, because the runner dot-sourced the CR body and an `exit` inside a dot-sourced file does not set the `-File` process exit code. The runner was corrected to inline the CR body into the executed file, a probe confirmed that a computed 1 now yields process exit 1, and this step was rerun. The output below is from the rerun; its NAMED and FAILED lines are identical to the first execution.

PI-3 note (E4-TR4): on the base, `Invoke-FeatureReviewCoverageValidation` has no `-InputText` parameter, so E4-TR4 fails at parameter binding ("A parameter cannot be found that matches parameter name 'InputText'.") before it reaches the root CLAUDE.md read. The behavioral defect is recorded in research Q4 (research/research.2026-10-11T08-10.md lines 152-165): the unwrapped CLAUDE.md read at base line 444 propagates its exception and the process ends with exit 1, which does not block. E4-TR1 fails because the base entry point reads CLAUDE_HOOK_INPUT and ends through Write-Error (exit 1 path); the E4-TR5 positive rows fail because the base resolver keeps the default 85/75; E4-TR7 fails because the base Codex hook accepts 80.5% against its 80% floor and emits no continuation.

## CR-PESTER-LIST output (CONTAINER, SUITE, NAMED, FAILED, TOTAL lines)

```
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Result=Failed
CONTAINER: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | Result=Failed
CONTAINER: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Result=Failed
SUITE: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | Passed=0 | Failed=6 | Skipped=0 | NotRun=14
SUITE: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=0 | Failed=2 | Skipped=0 | NotRun=43
SUITE: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | Passed=0 | Failed=1 | Skipped=0 | NotRun=29
NAMED: E4-TR1:* | Passed=0 | Failed=1 | NotRun=0 | Total=1
NAMED: E4-TR4:* | Passed=0 | Failed=1 | NotRun=0 | Total=1
NAMED: E4-TR5-P* | Passed=0 | Failed=6 | NotRun=0 | Total=6
NAMED: E4-TR7:* | Passed=0 | Failed=1 | NotRun=0 | Total=1
FAILED: validate-feature-review-coverage coverage (issue #786).E4 (issue #896).E4-TR1: the entry point exits 2 for an envelope without review-artifact tokens :: feature-review hook: CLAUDE_HOOK_INPUT is empty; cannot validate review output.
FAILED: validate-feature-review-coverage coverage (issue #786).E4 (issue #896).E4-TR4: an unreadable root CLAUDE.md blocks with a structured message and exit 2 :: A parameter cannot be found that matches parameter name 'InputText'.
FAILED: feature-review-coverage-thresholds (issue #824).E4-TR5-P1 resolves line coverage: 70% minimum :: Expected 70, because the governing line threshold for 'line coverage: 70% minimum', but got 85.
FAILED: feature-review-coverage-thresholds (issue #824).E4-TR5-P2 resolves line coverage 80% at least :: Expected 80, because the governing line threshold for 'line coverage 80% at least', but got 85.
FAILED: feature-review-coverage-thresholds (issue #824).E4-TR5-P3 resolves line coverage of 80% or more :: Expected 80, because the governing line threshold for 'line coverage of 80% or more', but got 85.
FAILED: feature-review-coverage-thresholds (issue #824).E4-TR5-P4 resolves branch coverage: 60% or higher :: Expected 60, because the governing branch threshold for 'branch coverage: 60% or higher', but got 75.
FAILED: feature-review-coverage-thresholds (issue #824).E4-TR5-P5 resolves line coverage 81% or above :: Expected 81, because the governing line threshold for 'line coverage 81% or above', but got 85.
FAILED: feature-review-coverage-thresholds (issue #824).E4-TR5-P6 resolves branch coverage 62% or greater :: Expected 62, because the governing branch threshold for 'branch coverage 62% or greater', but got 75.
FAILED: Codex validate-feature-review-coverage coverage (issue #786).entry point.E4-TR7: with no CLAUDE.md figure an 80.5% line row fails against the 85% floor :: Expected a value, but got $null or empty.
TOTAL: Passed=0 | Failed=9 | Skipped=0 | NotRun=86 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 1
PROCESS_EXIT: 1
```

## Branch-head run

Timestamp: 2026-10-12T08-39
Command: scratchpad route; CR-PESTER-LIST with <LIST> = T2, T5, T6; <TAGS-IN> = E4-Regression; <TAGS-OUT> empty; <PATTERNS> = E4-TR1:*, E4-TR4:*, E4-TR5-P*, E4-TR7:* (branch head b32ea7d75)

```
NAMED: E4-TR1:* | Passed=1 | Failed=0 | NotRun=0 | Total=1
NAMED: E4-TR4:* | Passed=1 | Failed=0 | NotRun=0 | Total=1
NAMED: E4-TR5-P* | Passed=6 | Failed=0 | NotRun=0 | Total=6
NAMED: E4-TR7:* | Passed=1 | Failed=0 | NotRun=0 | Total=1
```

HEAD_RUN_EXIT_CODE: 0
