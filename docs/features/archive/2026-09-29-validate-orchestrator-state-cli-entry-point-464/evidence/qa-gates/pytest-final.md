# Pytest Final, Repository Python Suite, Coverage (Issue #464)

Timestamp: 2026-09-30T09-48
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Final line: `5718 passed, 6 skipped in 81.45s (0:01:21)`; 0 failed.
- TOTAL row: Stmts 16974, Miss 1127, Branch 6110, BrPart 583, Cover 92%.
- Environment note (issue #510): the test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates the filesystem and fails whenever the gitignored `.claude/state/python-batch-budget.*.json` file exists. The file was moved aside for the single pytest process and restored afterwards (`git hash-object` `a3b7c65507d342053a06490a2de80112f48b6784` before and after; not deleted, so the batch budget is unchanged). The unisolated result for that one test is a failure unrelated to issue #464 (see `evidence/qa-gates/mirror-parity-test.md`).
