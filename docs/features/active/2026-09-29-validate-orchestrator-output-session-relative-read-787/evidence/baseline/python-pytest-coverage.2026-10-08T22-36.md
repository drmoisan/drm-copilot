# Python Test and Coverage Baseline (P0-T29)

Timestamp: 2026-10-08T22-36

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/py-coverage-base.json
EXIT_CODE: 0
Output Summary:
- Summary line: `6603 passed, 6 skipped in 105.50s (0:01:45)`
- Terminal TOTAL row: `TOTAL 17556 1111 6338 566 92%`
- Failed node ids (baseline failure set): none
- KL-510: PASSED (node `test_bundled_claude_payload_contains_all_repo_runtime_contracts` reported no failure and is not among the six SKIPPED nodes)

Command: sh SCRATCH/run-ps.sh SCRATCH/py-coverage-totals.ps1 -Path SCRATCH/py-coverage-base.json
EXIT_CODE: 0
Output Summary: PY-COVERAGE LinePercent=93.67 BranchPercent=87.09 CombinedPercent=91.93

BASE_PY_LINE=93.67
BASE_PY_BRANCH=87.09

Scratch-script deviation (mechanical micro-action): the first A20 run exited 1 because the coverage.py JSON report contains a property whose name is the empty string, which `ConvertFrom-Json` rejects without `-AsHashtable`. A20 was changed in SCRATCH only, from `ConvertFrom-Json).totals` to `ConvertFrom-Json -AsHashtable).totals`; member access on the resulting hashtable reads the same `totals` keys, and the output format is unchanged. The line value cross-checks against the terminal TOTAL row: (17556 - 1111) / 17556 = 93.67%.

Result: PASS (summary, failure set, KL-510 disposition, and numeric LinePercent/BranchPercent recorded).
