# Constraints AC-26 temporary-file clause (P12-T7)

Timestamp: 2026-10-12T08-41
Command: git grep -n -F -e New-TemporaryFile -e GetTempFileName -e TestDrive -e '$env:TEMP' -- tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.E4.Helpers.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1 tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: no output; git grep exits 1 because none of the four temporary-file literals occurs in the eleven tracked test and test-support files.

## Output

```
(no output)
```
