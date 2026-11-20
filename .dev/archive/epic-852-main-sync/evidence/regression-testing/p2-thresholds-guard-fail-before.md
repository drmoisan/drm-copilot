# Phase 2 ThresholdsGuard Fail-Before Run [expect-fail]

Timestamp: 2026-10-11T00-11
Task: [P2-T2]
Command: cd <WORKSPACE_ROOT> && sh <SCRATCHPAD>/r.sh rscoped tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1

Hook state: unfixed merged hook (unguarded `. (Join-Path $PSScriptRoot 'feature-review-coverage-thresholds.ps1')` at line 49 of both copies).

PassedCount: 0
FailedCount: 6
FailedBlocksCount: 0
FailedContainersCount: 0

```text
CONTAINER: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | result=Failed | passed=0 | failed=6
FAILED: validate-feature-review-coverage.ps1 thresholds dot-source guard (issue #852).TG1: claude exits 2 naming feature-review-coverage-thresholds.ps1 when the thresholds dot-source fails
FAILED: validate-feature-review-coverage.ps1 thresholds dot-source guard (issue #852).TG1: bundle exits 2 naming feature-review-coverage-thresholds.ps1 when the thresholds dot-source fails
FAILED: validate-feature-review-coverage.ps1 thresholds dot-source guard (issue #852).TG2: claude records the thresholds load failure through Add-HookDependencyFailure when dot-sourced
FAILED: validate-feature-review-coverage.ps1 thresholds dot-source guard (issue #852).TG2: bundle records the thresholds load failure through Add-HookDependencyFailure when dot-sourced
FAILED: validate-feature-review-coverage.ps1 thresholds dot-source guard (issue #852).TG3: claude Invoke-FeatureReviewCoverageValidation returns ExitCode 2 when the thresholds dependency failure is recorded
FAILED: validate-feature-review-coverage.ps1 thresholds dot-source guard (issue #852).TG3: bundle Invoke-FeatureReviewCoverageValidation returns ExitCode 2 when the thresholds dependency failure is recorded
```

Failure cause (Pester detail): TG1 and TG3 rows raise `RuntimeException: simulated load failure: feature-review-coverage-thresholds.ps1` out of the hook (the unguarded dot-source throws instead of exiting 2); TG2 rows report `Expected $null or empty, because the guarded dot-source must not throw, but got simulated load failure: feature-review-coverage-thresholds.ps1.`

TG1_CLAUDE_FAILED: yes
TG1_BUNDLE_FAILED: yes

Output Summary: expected failure observed. FailedCount 6 (non-zero); both `TG1: claude` and `TG1: bundle` rows failed because the unguarded thresholds dot-source throws.
