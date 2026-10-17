# Python Test and Coverage Baseline (P0-T14)

Timestamp: 2026-09-28T21-52
Command: poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/cov-762-baseline.json ; poetry run python SCRATCH/py-cov-files.py SCRATCH/cov-762-baseline.json TOTAL
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Pytest summary: `1 failed, 5209 passed, 6 skipped in 65.03s (0:01:05)` (collected total 5216).
- term-missing TOTAL row: `TOTAL                                                               16109   1115   5842    574    91%`
- A7: `COVERAGE file=TOTAL LinePercent=93.08 BranchPercent=85.86`
- Baseline Python coverage (scripts.dev_tools): line 93.08%, branch 85.86%.
- KL-510: STATE-ONLY
  - Only failing node: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
  - Assertion message (verbatim): `AssertionError: Repo file missing from bundle: .claude\state\current-session-id`
  - The path's first two components are `.claude` and `state`; no output line contains "Bundle content differs from repo for:".
