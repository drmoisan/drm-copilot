# Remediation Cycle 2 — Pre-fix Pytest Coverage Baseline

Timestamp: 2026-07-18T12-32

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 1

Output Summary: 1 failed, 1768 passed in 9.47s. The sole failure is `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (the blocking bundled-payload-drift finding named in P0-T5). No other test failed.

Coverage (baseline, pre-fix):
- Line coverage: 88.62% (10292/11614 statements covered)
- Branch coverage: 79.25% (3400/4290 branches covered)
- coverage.py combined headline display: 86% (TOTAL row: 11614 stmts, 1322 miss, 4290 branch, 550 brpart)

Threshold status (baseline): line 88.62% >= 85% PASS; branch 79.25% >= 75% PASS. The baseline is captured before the bundle mirror; the mirrored files are Markdown resources and are not expected to change Python coverage.
