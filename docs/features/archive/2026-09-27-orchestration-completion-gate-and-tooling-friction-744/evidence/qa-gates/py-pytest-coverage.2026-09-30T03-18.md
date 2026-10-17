# QA Gate: Python Tests With Coverage (Full Suite)

Timestamp: 2026-10-02T01-47
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-744-final.json --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -q -p no:cacheprovider
EXIT_CODE: 0
Loop iteration: 1
Output Summary:
- Result line: `6376 passed, 6 skipped, 1 deselected in 67.59s (0:01:07)`; no `failed` or `error`.
- Passed count 6376 = N_py_passed (6331, P0-T16) + 45 (15 first-occurrence items + 30 documentation-contract items).
- Deselection reason: issue #510; the node runs separately (P11-T4, passed locally) and in CI, which is authoritative.
- TOTAL row: `TOTAL                                                                 17244   1115   6230    572    92%`
- term-missing row: `scripts\dev_tools\pr_context\verification_evidence.py                    56      0     16      1    99%   98->97`
- `artifacts/python/coverage-744-final.json` written (intermediate tool output; values transcribed in python-coverage-final.2026-09-30T03-18.md).
- Command note: `-q -p no:cacheprovider` appended, as in P0-T16 (deviation D-TOOLS).
