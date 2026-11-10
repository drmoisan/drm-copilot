# Python Coverage Gate (issue #1165, reviewer run)

Timestamp: 2026-11-10T01-28
Command: from the item worktree root, env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch -q -p no:cacheprovider (pyproject addopts write artifacts/python/lcov.info); run by the feature-review agent to satisfy the validate-feature-review-coverage Stop hook (finding PA-1 of policy-audit.2026-11-10T01-15.md)
EXIT_CODE: 0
Output Summary:
- Result line: "16598 passed, 6 skipped in 200.65s (0:03:20)"; 0 failed.
- Run window: 2026-11-10T01:24:51Z to 2026-11-10T01:28:16Z; head eaf42f48d8792c7099ef5c411025d43413f0dca2, clean worktree.
- artifacts/python/lcov.info written 2026-11-10T01:28:11Z.
- Repo-wide line coverage: 97.11% (34334 of 35355); branch coverage: 94.38% (12669 of 13424); thresholds 85% line, 75% branch (defaults; root CLAUDE.md states none).
- No Python production file changed on the branch.
