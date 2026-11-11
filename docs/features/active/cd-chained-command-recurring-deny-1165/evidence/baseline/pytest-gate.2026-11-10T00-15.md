# Pytest Phase 0 Baseline (issue #1165)

Timestamp: 2026-11-10T00-15
Command: env -u VIRTUAL_ENV poetry run pytest -n auto tests/scripts/dev_tools -q -p no:cacheprovider --junitxml=SCRATCH/pytest-p0.xml (from the item worktree root through sh SCRATCH/issue-1165-pytest.sh)
EXIT_CODE: 0
Output Summary:
- Result line: "8844 passed, 6 skipped in 21.56s"
- passed=8844 failed=0 skipped=6
- Pre-existing failures: none.
- Coverage: no Python production file is in scope for this item, so no coverage obligation applies to this gate (plan Pre-Mortem, Coverage).
