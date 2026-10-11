# P17-T2 Full pytest Run on the Final Tree

Timestamp: 2026-10-10T10-10
Command: poetry run pytest
EXIT_CODE: 0
Output Summary:
- Run in the background (output captured to the git-ignored scratch file artifacts/orchestration/widening-pytest-full-final.log).
- rootdir header: repository-relative tail `.` (the worktree root).
- Summary line: `6785 passed, 6 skipped in 22.72s`.
- FAILED lines: none. ERROR lines: none (count 0).
- KL-510 did not occur.
- Passed count 6785 is at least WIDEN_PY_PASSED 6785 (P12-T5); WIDEN_PY_FAILED is none and no test failed, so no failure lies in PARITY-SET or in tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py.
- Tree state: HEAD b8efe6c36a1cdf91241587f805430d6d68b27c91 plus uncommitted FEATURE-only artifacts and plan check-offs.

Result: PASS
