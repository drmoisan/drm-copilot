# Python targeted coverage baseline for the routing module (P0-T15)

Timestamp: 2026-09-30T07-19
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py --cov=scripts.dev_tools._orchestrator_state_routing --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p0-t15.json -p no:cacheprovider
(The trailing `-p no:cacheprovider` only disables the pytest cache directory.)
EXIT_CODE: 0
Output Summary:
- Passed: 17 (`17 passed in 0.27s`), failed 0.
- File scripts/dev_tools/_orchestrator_state_routing.py, `summary` object in artifacts/python/cov-p0-t15.json: percent_statements_covered 83.1 (182 covered lines of 219 statements); percent_branches_covered 67.9 (76 of 112 branches).
- Printed row verbatim cells: Stmts 219, Miss 37, Branch 112, BrPart 32, Cover 78%.
- Note: this targeted figure covers only the one test file the task names; the module is not edited by this plan.
