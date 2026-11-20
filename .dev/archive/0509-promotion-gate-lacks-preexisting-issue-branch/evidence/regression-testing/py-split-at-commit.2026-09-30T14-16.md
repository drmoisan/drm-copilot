# Split Suites at the Split Commit (AC-1 evidence)

Timestamp: 2026-09-30T14-16
Task: P1-T14
Working directory: worktree root

## Command 1

Command: git status --porcelain -- scripts/dev_tools tests/scripts/dev_tools
EXIT_CODE: 0
Output Summary: empty listing; the working tree equals the commit for both directories.

## Command 2

Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: `5a3278df71bd14237a2a7bdeb1857728f5077de3`, equal to SPLIT_COMMIT_SHA.

## Command 3

Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py tests/scripts/dev_tools/test_validate_orchestrator_state_preparation_route.py tests/scripts/dev_tools/test_orchestrator_state_routing_split.py
EXIT_CODE: 0
Output Summary: `============================= 62 passed in 0.17s ==============================`. Passed 62 = PY_ROUTING_BASELINE_PASSED (29) + 33. Zero failed.

Result: PASS
