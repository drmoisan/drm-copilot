# 500-line limit gate (P5-T17)

Timestamp: 2026-09-30T07-57
Command: wc -l extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-tools.test.ts extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.promotion-type.test.ts extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary:
- extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts: 51
- extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts: 455 (P0-T4 baseline 451; increase 4)
- extensions/drm-copilot/jest.config.cjs: 363
- extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-tools.test.ts: 194
- extensions/drm-copilot/test/lib/validate/orchestrator-state-routing.promotion-type.test.ts: 177
- extensions/drm-copilot/test/lib/validate/orchestrator-state-promotion-type-parity.test.ts: 231
- tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py: 218
- tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1: 114
- Every count is below 500. The twelve fixture files are JSON data and are not counted.
