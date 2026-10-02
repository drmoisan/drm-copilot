# Final line counts (issue #543)

Timestamp: 2026-10-02T05-47
Timestamp-Correction: original value 2026-10-02T06-50 was composed on a fixed schedule rather than read from the host clock; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T05-58.md), an upper bound on the command run time.
Task: P10-T5
Command: `awk 'END{print NR}' <path>` once per path (D3 substitute for `@(Get-Content -LiteralPath <path>).Count`)
Route: native (D3)
EXIT_CODE: 0

Output Summary (24 counts):

| Path | Final | Baseline (P0-T6) | <= 500 |
|---|---|---|---|
| `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` | 307 | 298 | yes |
| `scripts/dev_tools/epic_planner_launch_evidence.py` | 359 | 345 | yes |
| `scripts/dev_tools/epic_planner_readiness.py` | 383 | 371 | yes |
| `scripts/dev_tools/validate_epic_planner_state.py` | 369 | 354 | yes |
| `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts` | 334 | 325 | yes |
| `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts` | 469 | 455 | yes |
| `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts` | 370 | 364 | yes |
| `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts` | 471 | 460 | yes |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | 369 | 363 | yes |
| `.agents/skills/epic-plan/SKILL.md` | 231 | 230 | yes |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md` | 231 | 230 | yes |
| `.agents/skills/epic-run/SKILL.md` | 40 | 39 | yes |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md` | 40 | 39 | yes |
| `.codex/agents/epic-orchestrator.toml` | 97 | 96 | yes |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml` | 97 | 96 | yes |
| `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` | 396 | 224 | yes |
| `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py` | 309 | 271 | yes |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` | 436 | 416 | yes |
| `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts` | 343 | 224 | yes |
| `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts` | 263 | 223 | yes |
| `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts` | 225 | 178 | yes |
| `tests/scripts/dev_tools/test_epic_planner_readiness.py` (excluded) | 491 | 491 | unchanged |
| `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts` (excluded) | 495 | 495 | unchanged |
| `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts` (excluded) | 508 | 508 | unchanged |

- All 21 write-set counts are at or below 500 (maximum 471).
- The three excluded test files equal their P0 values (491, 495, 508), confirming no test was added to them. `orchestration-artifacts.test.ts` was already over 500 at baseline and is not modified by this change.
