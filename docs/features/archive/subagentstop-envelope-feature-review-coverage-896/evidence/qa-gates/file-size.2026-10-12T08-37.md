# File sizes (P12-T1, AC-10)

Timestamp: 2026-10-12T08-37
Command: scratchpad route; CR-LINES with <LIST> = LIST-PROD plus LIST-TEST plus tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
EXIT_CODE: 0
Output Summary: Design target 300 lines, hard cap below 500. LINES-OVER-CAP: 0. Production files: H1 205, H2 180, H3 195, H4 85, H6 85 (all WITHIN-TARGET); H5 .codex/hooks/validate-feature-review-coverage.ps1 316 (OVER-TARGET, the expected file; baseline 304). T9 count=497. Test files above 300: T1 447, T2 475, T10 398 (all below the 500 cap).

## Output (e896-p12t1-lines)

```
LINES: .claude/hooks/validate-feature-review-coverage.ps1 | count=205 | WITHIN-TARGET
LINES: .claude/hooks/validate-feature-review-coverage-metrics.ps1 | count=180 | WITHIN-TARGET
LINES: .claude/hooks/validate-feature-review-coverage-rules.ps1 | count=195 | WITHIN-TARGET
LINES: .claude/hooks/feature-review-coverage-thresholds.ps1 | count=85 | WITHIN-TARGET
LINES: .codex/hooks/validate-feature-review-coverage.ps1 | count=316 | OVER-TARGET
LINES: .codex/hooks/feature-review-coverage-thresholds.ps1 | count=85 | WITHIN-TARGET
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | count=447 | OVER-TARGET
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | count=475 | OVER-TARGET
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | count=267 | WITHIN-TARGET
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 | count=139 | WITHIN-TARGET
LINES: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 | count=104 | WITHIN-TARGET
LINES: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | count=274 | WITHIN-TARGET
LINES: tests/scripts/codex-hooks/feature-review-coverage-thresholds.Tests.ps1 | count=75 | WITHIN-TARGET
LINES: tests/scripts/codex-hooks/feature-review-coverage-floor-parity.Tests.ps1 | count=68 | WITHIN-TARGET
LINES: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | count=497 | OVER-TARGET
LINES: tests/scripts/claude-hooks/validate-feature-review-coverage.E4.Helpers.ps1 | count=125 | WITHIN-TARGET
LINES: tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py | count=398 | OVER-TARGET
LINES-OVER-CAP: 0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
