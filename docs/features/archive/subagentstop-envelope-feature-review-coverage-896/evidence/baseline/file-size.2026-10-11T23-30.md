# Baseline File Sizes (P0-T11)

Timestamp: 2026-10-11T23-30
Command: CR-LINES (scratchpad route) with <LIST> = LIST-PROD-BASE (.claude/hooks/validate-feature-review-coverage.ps1, .claude/hooks/feature-review-coverage-thresholds.ps1, .codex/hooks/validate-feature-review-coverage.ps1) plus LIST-TEST-BASE (T1-T6, T9) plus tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
EXIT_CODE: 0
Output Summary: 11 files measured; LINES-OVER-CAP: 0; H1 477, H4 77, H5 304, T1 135, T2 296, T3 289, T4 121, T5 51, T6 199, T9 497 (legacy-codex-hook-contracts.Tests.ps1 at count=497 as expected), T10 356.

## Output

```
LINES: .claude/hooks/validate-feature-review-coverage.ps1 | count=477 | OVER-TARGET
LINES: .claude/hooks/feature-review-coverage-thresholds.ps1 | count=77 | WITHIN-TARGET
LINES: .codex/hooks/validate-feature-review-coverage.ps1 | count=304 | OVER-TARGET
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | count=135 | WITHIN-TARGET
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | count=296 | WITHIN-TARGET
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | count=289 | WITHIN-TARGET
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | count=121 | WITHIN-TARGET
LINES: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | count=51 | WITHIN-TARGET
LINES: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | count=199 | WITHIN-TARGET
LINES: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | count=497 | OVER-TARGET
LINES: tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py | count=356 | OVER-TARGET
LINES-OVER-CAP: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
