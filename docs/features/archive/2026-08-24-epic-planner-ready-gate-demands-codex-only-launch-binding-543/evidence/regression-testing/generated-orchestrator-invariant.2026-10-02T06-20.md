# Generated-orchestrator invariant (issue #543)

Timestamp: 2026-10-02T05-36
Timestamp-Correction: original value 2026-10-02T06-20 was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T05-58.md), an upper bound on the command run time.
Task: P7-T3
Command:
1. Grep tool, fixed string `require_generated_orchestrator=True` over `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` (D3 substitute for `Select-String ... -SimpleMatch`)
2. Grep tool, fixed string `requireGeneratedOrchestrator: true` over `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` (D3 substitute)
3. `poetry run pytest tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py -k "test_rejects_invalid_delegation_binding and agent_name" -v`
4. `node run-jest.cjs test/lib/validate/epic-planner-state-launch-binding.test.ts -t "rejects delegation agent_name mismatch"` (in `extensions/drm-copilot/`)
Route: native (D3) for commands 1 and 2
EXIT_CODE: 0

Output Summary:
- Command 1: exactly one match, line 277. `def validate_epic_planner_child_launch_bindings(` starts at line 262 and the next top-level function `def validate_epic_child_launch_bindings(` starts at line 283, so line 277 lies inside the body of `validate_epic_planner_child_launch_bindings` (span 262-282).
- Command 2: exactly one match, line 301. `export function validateEpicPlannerChildLaunchBindings(` starts at line 294 and `export function validateEpicChildLaunchBindings(` starts at line 308, so line 301 lies inside the body of `validateEpicPlannerChildLaunchBindings` (span 294-307).
- Command 3: exit 0; `test_rejects_invalid_delegation_binding[agent_name-atomic-planner-c3-elevated-.agent_name must name a generated orchestrator agent.] PASSED`; `1 passed, 23 deselected`.
- Command 4: exit 0; `Tests:       18 skipped, 1 passed, 19 total` (1 passed for the title).
