# Bundle-Contract Tests After (Issue #464)

Timestamp: 2026-09-30T09-13
Command: poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q -p no:cacheprovider --no-cov
EXIT_CODE: 0 (isolated run); 1 (unisolated run)
Output Summary:
- Isolated run (gitignored batch-budget state file moved aside for the single pytest process and restored; `git hash-object` `a3b7c65507d342053a06490a2de80112f48b6784` before and after): `19 passed in 0.56s`, 0 failed. The count equals the 19 recorded in `evidence/baseline/bundle-tests-before.md`.
- Unisolated run: `1 failed, 18 passed`; the single failure is `test_bundled_claude_payload_contains_all_repo_runtime_contracts` reporting the gitignored `.claude/state/python-batch-budget.*.json` file as missing from the bundle (issue #510, environment-conditional, unrelated to the #464 change).
- See `evidence/qa-gates/mirror-parity-test.md` for the cause and the durable `git hash-object` parity check.
