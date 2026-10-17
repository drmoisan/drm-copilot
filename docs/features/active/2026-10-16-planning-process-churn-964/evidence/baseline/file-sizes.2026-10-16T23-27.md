# Baseline — Physical Line Counts

Timestamp: 2026-10-16T23-27
Task: [P0-T9]
Command: sh SCRATCH/issue-964-sizes.sh (runs `wc -l` on every non-Markdown path of the plan's `## Files Written` list that exists)
EXIT_CODE: 0
Output Summary:
- Every existing listed file is at or below 500 physical lines (`OVER_500=0`).
- Near-limit files: `extensions/drm-copilot/jest.config.cjs` 489; `.claude/hooks/validate-planner-output.ps1` 442; `scripts/dev_tools/plan_gate_discrimination.py` 405; `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` 400.

## Counts (existing files)

| Lines | Path |
|---|---|
| 231 | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` |
| 132 | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` |
| 442 | `.claude/hooks/validate-planner-output.ps1` (bundle copy 442) |
| 291 | `.claude/hooks/validate-task-researcher-output.ps1` (bundle copy 291) |
| 324 | `.claude/hooks/validate-executor-output.ps1` (bundle copy 324) |
| 405 | `scripts/dev_tools/plan_gate_discrimination.py` |
| 293 | `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` |
| 489 | `extensions/drm-copilot/jest.config.cjs` |
| 210 | `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` |
| 233 | `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` |
| 400 | `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` |
| 204 | `tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1` |
| 127 | `tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1` |
| 319 | `tests/scripts/claude-hooks/validate-executor-output.Tests.ps1` |
| 164 | `.codex/agents/atomic-executor.toml`, its five variants, and the six bundle copies (each 164) |
| 105 | `.codex/agents/atomic-planner.toml`, its five variants, and the six bundle copies (each 105) |
| 105 | `.codex/agents/task-researcher.toml`, its five variants, and the six bundle copies (each 105) |
| 211 | `.codex/agents/orchestrator.toml`, its five variants, and the six bundle copies (each 211) |

Files to be created by this item (absent at baseline): `.claude/hooks/premortem-section.ps1` and its bundle copy, `scripts/dev_tools/plan_gate_document.py`, `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts`, and the eleven new test files.
