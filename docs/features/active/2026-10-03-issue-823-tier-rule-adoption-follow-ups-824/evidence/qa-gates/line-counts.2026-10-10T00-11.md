# P8-T7 500-Line Limit (refresh)

Timestamp: 2026-10-10T00-11
Command: wc -l .claude/hooks/validate-feature-review-coverage.ps1 .claude/hooks/feature-review-coverage-thresholds.ps1 .codex/codex-web-setup.sh tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 tests/shell/test_codex_web_setup_codex_copy.bats
EXIT_CODE: 0
Supersedes: line-counts.2026-10-10T00-03.md (recorded 353 for test_push_down_issue_824_follow_ups.py before the OPS-3 edit)
Output Summary:
- Refresh at HEAD cdc7f01ce (working tree clean).
- 471 .claude/hooks/validate-feature-review-coverage.ps1 (FINAL_HOOK_LINES 471; BASE_HOOK_LINES recorded in P0-T10)
- 77 .claude/hooks/feature-review-coverage-thresholds.ps1
- 413 .codex/codex-web-setup.sh
- 493 tests/scripts/dev_tools/test_push_down_tier_rule_adoption_gate.py (FINAL_TIER_LINES 493)
- 356 tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
- 51 tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1
- 274 tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1
- 187 tests/shell/test_codex_web_setup_codex_copy.bats
- Every per-file count is at most 500 (maximum 493). Met.
- Result: PASS
