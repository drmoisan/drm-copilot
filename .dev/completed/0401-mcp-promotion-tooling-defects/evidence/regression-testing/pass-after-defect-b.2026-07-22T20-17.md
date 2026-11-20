# Pass-After — Defect B (heading mapping reorder, TS + Python) (Issue #401)

Timestamp: 2026-07-22T20-17

Command: npm run test -- --testMatch 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4396e634050c686d/extensions/drm-copilot/test/**/*.test.ts' --testPathPatterns 'lib/potential-to-issue/' (from extensions/drm-copilot/, via pwsh)
EXIT_CODE: 0

Command: poetry run pytest tests/scripts/dev_tools/test_potential_to_issue.py tests/scripts/dev_tools/test_potential_to_issue_content.py tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py (from repo root)
EXIT_CODE: 0

Output Summary:
- TypeScript: Test Suites 6 passed, 6 total; Tests 94 passed, 94 total. Includes the (bug, minor-audit) regression (promotion.test.ts) and the AC-2 routing matrix + AC-1 edge partial-sections cases (promotion.matrix.test.ts).
- Python: 38 passed (test_potential_to_issue.py 29, test_potential_to_issue_content.py 8, test_potential_to_issue_missing_label_regression.py 1). Includes the mirrored (bug, minor-audit) regression and the reorder-updated minor-audit routing assertions.
- Both parity twins now route promotion_type == "bug" through the bug body before the minor-audit branch. The fail-before state recorded in expect-fail-ts-bug-minor-audit and expect-fail-py-bug-minor-audit is resolved.
