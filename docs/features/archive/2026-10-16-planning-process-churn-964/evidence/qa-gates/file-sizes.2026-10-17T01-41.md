# QA Gate — Physical Line Counts

Timestamp: 2026-10-17T01-41
Task: [P6-T10]
Command: sh SCRATCH/issue-964-sizes.sh (`wc -l` on every non-Markdown file of `## Files Written`, including the related-finding files of the executor note); the [P6-T11] scope script also measures every changed non-Markdown path
EXIT_CODE: 0
Output Summary:
- Every listed file is at or below 500 physical lines (`OVER_500=0`); the scope script reports `NON_MD_OVER_500=0` over all 192 changed paths.
- Near-limit files (baseline [P0-T9] count, then now): `extensions/drm-copilot/jest.config.cjs` 489 to 493; `.claude/hooks/validate-planner-output.ps1` 442 to 454 (acceptance cap 470); `.claude/hooks/validate-executor-output.ps1` 324 to 449 (acceptance cap 450); `scripts/dev_tools/plan_gate_discrimination.py` 405 to 411; `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` 400 to 402.
- Related-finding files: `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` 500; `extensions/drm-copilot/test/extension-test-harness.ts` 495; `scripts/dev_tools/codex_native_converter/rewrites.py` 489; `extensions/drm-copilot/src/lib/codex-native-converter/rewrites-rules.ts` 324; `scripts/dev_tools/generate_codex_agent_variants.py` 295.

## Counts (new and changed files)

| Lines | Path |
|---|---|
| 149 | `.claude/hooks/premortem-section.ps1` (bundle copy 149) |
| 454 | `.claude/hooks/validate-planner-output.ps1` (bundle copy 454) |
| 310 | `.claude/hooks/validate-task-researcher-output.ps1` (bundle copy 310) |
| 449 | `.claude/hooks/validate-executor-output.ps1` (bundle copy 449) |
| 333 | `scripts/dev_tools/plan_gate_document.py` |
| 411 | `scripts/dev_tools/plan_gate_discrimination.py` |
| 337 | `extensions/drm-copilot/src/lib/validate/plan-gate-document.ts` |
| 302 | `extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts` |
| 493 | `extensions/drm-copilot/jest.config.cjs` |
| 233 | `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` |
| 133 | `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` |
| 254 | `tests/scripts/dev_tools/test_plan_gate_document.py` |
| 162 | `tests/scripts/dev_tools/test_plan_gate_document_parity.py` |
| 159 | `tests/scripts/dev_tools/test_plan_gate_document_docs.py` |
| 396 | `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py` |
| 289 | `tests/scripts/dev_tools/test_single_pass_preflight_contracts.py` |
| 245 | `extensions/drm-copilot/test/lib/validate/plan-gate-document.test.ts` |
| 107 | `extensions/drm-copilot/test/lib/validate/plan-gate-document-parity.test.ts` |
| 171 | `tests/scripts/claude-hooks/premortem-section.Tests.ps1` |
| 115 | `tests/scripts/claude-hooks/validate-planner-output.PreMortem.Tests.ps1` |
| 138 | `tests/scripts/claude-hooks/validate-task-researcher-output.PreMortem.Tests.ps1` |
| 360 | `tests/scripts/claude-hooks/validate-executor-output.Preflight.Tests.ps1` |
| 220 | `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` |
| 247 | `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py` |
| 402 | `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` |
| 207 | `tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1` |
| 141 | `tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1` |
| 319 | `tests/scripts/claude-hooks/validate-executor-output.Tests.ps1` (unchanged) |
| 168 / 108 / 111 / 214 | `.codex/agents/atomic-executor.toml` / `atomic-planner.toml` / `task-researcher.toml` / `orchestrator.toml`, each variant and bundle copy the same |
| 489 | `scripts/dev_tools/codex_native_converter/rewrites.py` |
| 324 | `extensions/drm-copilot/src/lib/codex-native-converter/rewrites-rules.ts` |
| 225 | `tests/scripts/dev_tools/codex_native_converter/test_rewrites.py` |
| 243 | `extensions/drm-copilot/test/lib/codex-native-converter/rewrites.test.ts` |
| 295 | `scripts/dev_tools/generate_codex_agent_variants.py` |
| 233 | `tests/scripts/dev_tools/test_generate_codex_agent_variants.py` |
| 495 | `extensions/drm-copilot/test/extension-test-harness.ts` |
| 395 | `extensions/drm-copilot/test/extension.test.ts` |
| 500 | `extensions/drm-copilot/test/repo-automation-dispatch.test.ts` |
| 151 | `extensions/drm-copilot/test/runtime-test-helpers.ts` |
