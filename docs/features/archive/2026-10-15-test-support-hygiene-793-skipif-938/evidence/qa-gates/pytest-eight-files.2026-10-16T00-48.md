# pytest-eight-files

Timestamp: 2026-10-16T00-48
Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py -q -rs -p no:cacheprovider --no-cov
EXIT_CODE: 0
Output Summary:
```
125 passed in 1.63s
```
SKIPPED lines: none
FinalEightFilePassed: 125
FinalEightFileSkipped: 0
FinalEightFileFailed: 0
FinalEightFileCollected: 125
Comparison: BaselineEightFileCollected 125 equals FinalEightFileCollected 125; BaselineEightFilePassed 125 equals FinalEightFilePassed 125.
