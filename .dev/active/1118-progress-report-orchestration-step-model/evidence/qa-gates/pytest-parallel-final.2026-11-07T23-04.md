# pytest Parallel Final Gate (P7-T4, issue #1118)

Timestamp: 2026-11-07T23-04
Command: sh SCRATCH/issue-1118-pytest.sh final (from the item worktree: PYTHONPATH=<item worktree>/packages/discovery-runtime/src env -u VIRTUAL_ENV poetry run pytest -n auto -rfE --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1118-pytest-final.json --cov)
EXIT_CODE: 0
Output Summary:
- Result line: 16213 passed, 6 skipped in 226.90s; 0 failed and 0 errors (no `-rfE` FAILED or ERROR lines).
- The run collects the whole test tree with no selection, so it includes tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, and test_push_down_pack_manifest_dependency_closure.py, which pin the ten-file bundle mirror and the four new core.json entries.
- Repo-wide totals from the JSON report beside the P0-T4 baseline (pytest-parallel-baseline.2026-11-07T22-09.md):
  - Lines: 32456 of 33464 covered, 96.99% (baseline 96.99%).
  - Branches: 11828 of 12560 covered, 94.17% (baseline 94.16%).
  - Combined percent_covered: 96.22% (baseline 96.22%).
- Pass count equals the baseline (16213); no Python file is changed by issue #1118.
