# Remediation Cycle 1 Baseline Python Full Suite (P0-T13)

Timestamp: 2026-10-16T03-49
Command: poetry run pytest -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts --cov=scripts.dev_tools --cov-branch --cov-report=term > SCRATCH/rc1/py-full-baseline.txt; grep -e ' passed' -e ' failed' SCRATCH/rc1/py-full-baseline.txt; grep -e '^TOTAL' SCRATCH/rc1/py-full-baseline.txt
EXIT_CODE: 0
Output Summary:
- Result line: 7100 passed, 6 skipped, 1 deselected in 83.32s (0:01:23) (deselected 1: the known local-only #510 node)
- TOTAL row (verbatim): TOTAL                                                                 17644   1090   6372    504    92%
- Failed: none
