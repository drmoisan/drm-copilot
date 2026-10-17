# Cycle 2 final: ten-file pytest group with coverage

Timestamp: 2026-10-16T02-41
Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py -q -rs -p no:cacheprovider --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
135 passed in 2.11s
SKIPPED lines: none
Table header: `Name                                                    Stmts   Miss Branch BrPart  Cover   Missing`
Module row: `scripts\dev_tools\validate_orchestration_artifacts.py     149      9     56      5    92%   75, 365, 409, 411, 413, 435-440`
TOTAL row: `TOTAL                                                     149      9     56      5    92%`
FinalGroupPassed: 135
FinalGroupSkipped: 0
FinalGroupFailed: 0
FinalGroupCollected: 135
FinalModuleStmts: 149
FinalModuleMiss: 9
FinalModuleBranch: 56
FinalModuleBrPart: 5
FinalModuleCover: 92%
Comparison with baseline (ExpectedExitCode 0, passed 135, skipped 0, collected 135, Stmts 149, Miss 9, Branch 56, BrPart 5): all equal.
