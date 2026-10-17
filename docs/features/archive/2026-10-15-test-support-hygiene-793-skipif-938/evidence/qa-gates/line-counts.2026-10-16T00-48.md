# line-counts

Timestamp: 2026-10-16T00-48
Command: wc -l tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts
EXIT_CODE: 0
Output Summary:
```
    60 tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py
   457 tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py
   368 tests/scripts/dev_tools/test_validate_orchestration_artifacts.py
   221 tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py
   279 tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py
   449 tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py
   413 tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py
   200 tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py
   165 tests/scripts/dev_tools/test_codex_handoff_contract_parity.py
   475 extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts
  3087 total
```
Baseline counts (from the baseline line-counts artifact): test_validate_epic_orchestrator_state.py 496, test_validate_orchestration_artifacts.py 381, merge_status 223, dispatch 277, plan_gates 449, parallel_dispatch 413, discovery_dispatch 200, parity 174, epic-orchestrator-state-core.test.ts 475.
All ten counts are at most 500. test_validate_epic_orchestrator_state.py: 457 < 496. test_validate_orchestration_artifacts.py: 368 < 381.
