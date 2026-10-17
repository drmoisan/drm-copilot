# Baseline line counts (issue #543)

Timestamp: 2026-10-02T05-01
Task: P0-T6
Command: `awk 'END{print NR}' <path>` once per path (D3 substitute for `@(Get-Content -LiteralPath <path>).Count`; counts physical lines)
EXIT_CODE: 0
Route: native (D3)

Output Summary (24 counts):

| Path | Count | Planning-time |
|---|---|---|
| `scripts/dev_tools/validate_epic_planner_state.py` | 354 | 354 |
| `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | 298 | 298 |
| `scripts/dev_tools/epic_planner_launch_evidence.py` | 345 | 345 |
| `scripts/dev_tools/epic_planner_readiness.py` | 371 | 371 |
| `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | 460 | 460 |
| `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` | 325 | 325 |
| `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts` | 455 | 455 |
| `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts` | 364 | 364 |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | 363 | 363 |
| `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | 224 | 224 |
| `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py` | 271 | 271 |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | 416 | 416 |
| `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` | 224 | 220 (differs) |
| `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts` | 223 | 223 |
| `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` | 178 | 166 (differs) |
| `tests/scripts/dev_tools/test_epic_planner_readiness.py` | 491 | 491 |
| `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts` | 495 | 495 |
| `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` | 508 | 508 |
| `.agents/skills/epic-plan/SKILL.md` | 230 | 230 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md` | 230 | 230 |
| `.agents/skills/epic-run/SKILL.md` | 39 | 39 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md` | 39 | 39 |
| `.codex/agents/epic-orchestrator.toml` | 96 | 96 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml` | 96 | 96 |

Differences from planning-time values (D1 merge-adaptation, not stop conditions):
- `epic-planner-state-launch-binding.test.ts`: 224 vs 220 (+4; `isRecord` helper added by the origin/main merge, `record()` now calls it).
- `validate-orchestration-service-call.test.ts`: 178 vs 166 (+12; `VirtualFileSystem` `exists`/`isDirectory`/`listDirectory` stubs added by the merge).

All other 22 counts equal their planning-time values.
