# Baseline — Python Test + Coverage (Issue #401)

Timestamp: 2026-07-22T15-53

Command: poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term (from repo/worktree root)

EXIT_CODE: 0

Output Summary:
- Tests: 1981 passed.
- TOTAL coverage: 88% (statements 12252, missed 1114, branches 4446, partial 564).
- Per-file for scripts/dev_tools/potential_to_issue.py: 200 statements, 18 missed, 66 branches, 21 partial, 85% line coverage.
- scripts/dev_tools/potential_to_issue_content.py: 95 statements, 4 missed, 28 branches, 6 partial, 92%.
- Baseline module-under-change line coverage (potential_to_issue.py) 85% >= 85%.
