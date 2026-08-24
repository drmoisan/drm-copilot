# Plan Self-Validation via MCP — EXECUTION BLOCKED

Timestamp: 2026-08-20T13-38
Task: [P12-T11]
Issue: #486

Status: BLOCKED. `[P12-T11]` is NOT checked off in the plan. This artifact does not satisfy the task's acceptance criterion and must not be read as satisfying it.

Command the task requires: the `mcp__drm-copilot__validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path: docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/plan.2026-08-17T15-00.md`

EXIT_CODE: not obtained

Obstacle: the executing agent session was provisioned with only four MCP tools from the `drm-copilot` server — `run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`, and `run_poshqc_analyze_autofix`. `mcp__drm-copilot__validate_orchestration_artifacts` was not in the session tool set, so the tool call could not be issued.

No substitute was improvised. In particular, the Python CLI form was NOT used as a stand-in: the CLI is the subject of the separate task `[P12-T12]`, and the MCP surface `[P12-T11]` names is the TypeScript path, which is a distinct implementation whose behavior this feature also changed. Running the Python CLI and recording it against `[P12-T11]` would assert TypeScript-surface evidence from a Python-surface run.

Required follow-up: an agent or session that has `mcp__drm-copilot__validate_orchestration_artifacts` available must run the task's stated call and record `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/plan-self-validation.<ts>.md` with `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and the verbatim success summary string, then check off `[P12-T11]`.

Supporting evidence that the TypeScript surface is nonetheless exercised, recorded for the reviewer and NOT as a substitute: `[P12-T9]`'s coverage run passed all 193 suites, including `extensions/drm-copilot/test/mcp-plan-gate-warning-projection.test.ts` and `extensions/drm-copilot/test/lib/validate/orchestration-artifacts-plan-gates.test.ts`, which exercise the MCP projection and the plan route in-process.
