# Python targeted routing coverage final QA (P5-T8)

Timestamp: 2026-09-30T07-43
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py --cov=scripts.dev_tools._orchestrator_state_routing --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p5-t8.json -p no:cacheprovider
(The trailing `-p no:cacheprovider` only disables the pytest cache directory, as in the P0-T15 baseline.)
EXIT_CODE: 0
Output Summary:
- Passed: 32 (`32 passed in 0.35s`), failed 0. P0-T15 passed count 17 plus 15 equals 32.
- File scripts/dev_tools/_orchestrator_state_routing.py, `summary` object in artifacts/python/cov-p5-t8.json (read with a one-line node script): percent_statements_covered 83.6 (183 of 219 statements); percent_branches_covered 68.8 (77 of 112 branches).
- Printed row verbatim cells: Stmts 219, Miss 36, Branch 112, BrPart 31, Cover 79%.
