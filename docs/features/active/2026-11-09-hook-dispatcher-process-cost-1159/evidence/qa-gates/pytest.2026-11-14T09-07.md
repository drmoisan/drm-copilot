# Remediation cycle 2 — final pytest gate ([P1-T9])

Timestamp: 2026-11-14T09-07
Command: sh SCRATCH/issue-1159-c2-pytest.sh (from the worktree root: env -u VIRTUAL_ENV poetry run pytest -n auto -p no:cacheprovider --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/issue-1159-pytest-coverage.json -rfE -q); totals read from the JSON report by sh SCRATCH/issue-1159-c2-covt.sh
EXIT_CODE: 0
Output Summary: 16723 passed, 6 skipped, 0 failed, 0 errors in 251.79s (pytest-xdist, -n auto). Repo-wide line coverage 97.13% (34574 of 35595 statements); branch coverage 94.42% (12785 of 13540 branches; 555 partial), from the JSON report. Term TOTAL 96%.

## Comparison with the greatest pre-cycle record (pytest.2026-11-14T07-50.md)

| Measure | Pre-cycle | Final | Change |
|---|---|---|---|
| Passed / skipped / failed | 16723 / 6 / 0 | 16723 / 6 / 0 | unchanged |
| Line | 97.13% (34574/35595) | 97.13% (34574/35595) | no drop |
| Branch | 94.42% (12785/13540) | 94.42% (12785/13540) | no drop |

The run includes test_committed_quality_tiers_yml_matches_live_tree and test_committed_quality_tiers_yml_assigns_spec_tiers (tests/scripts/dev_tools/test_quality_tiers_contract_classification.py), test_core_manifest_contains_registered_hook_closure_and_resolver_paths (tests/scripts/dev_tools/test_codex_core_manifest_closure.py), and the push-down contract tests named in the execution-environment brief's '## Contract Tests That Pin Mirrored Files'; the run reports no failure and no error, so all of them pass. No Python file changed this cycle.
