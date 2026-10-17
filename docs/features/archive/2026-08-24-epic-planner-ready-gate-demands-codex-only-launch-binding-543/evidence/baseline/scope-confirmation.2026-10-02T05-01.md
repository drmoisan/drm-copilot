# Scope confirmation (issue #543)

Timestamp: 2026-10-02T05-01
Task: P0-T2
Sources read: `spec.md`, `issue.md`, `research/research.2026-09-29T16-10.md` (this feature folder). Work Mode: full-bug; AC source: `spec.md` `## Acceptance Criteria` (20 items).

## Write set (21 paths)

Production, Python (4):
1. `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`
2. `scripts/dev_tools/epic_planner_launch_evidence.py`
3. `scripts/dev_tools/epic_planner_readiness.py`
4. `scripts/dev_tools/validate_epic_planner_state.py`

Production, TypeScript (5):
5. `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts`
6. `extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts`
7. `extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts`
8. `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`
9. `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`

Codex guidance, byte-identical root and bundle pairs (6):
10. `.agents/skills/epic-plan/SKILL.md`
11. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-plan/SKILL.md`
12. `.agents/skills/epic-run/SKILL.md`
13. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-run/SKILL.md`
14. `.codex/agents/epic-orchestrator.toml`
15. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml`

Tests, Python (3):
16. `tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py`
17. `tests/scripts/dev_tools/test_epic_planner_launch_evidence.py`
18. `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py`

Tests, TypeScript (3):
19. `extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts`
20. `extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts`
21. `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`

## Explicitly out of scope

- `scripts/dev_tools/validate_orchestration_artifacts.py`
- `tests/scripts/dev_tools/test_validate_epic_planner_state.py`
- `tests/scripts/dev_tools/test_epic_planner_readiness.py`
- `extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts`
- `extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts`
- `extensions/drm-copilot/src/mcp-tool-definitions.ts`
- `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`
- `extensions/drm-copilot/jest.config.cjs`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- `.claude/**` and `.github/**`
- Remaining Codex-only receipts in the ready gate (per-feature `model_routing_receipt` / `topology_receipt`, top-level planner `topology_receipt`); follow-up issue left to orchestrator closeout.

## Evidence location

EVIDENCE_LOCATION_OVERRIDE_REJECTED: evidence/regression/ replaced with docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/regression-testing/

## Deviations in force

- D1 merge-adaptation: origin/main `ef80c57d` merged (merge commit `1b6b06e2`); two write-set test files changed by the merge (`epic-planner-state-launch-binding.test.ts` +4, `validate-orchestration-service-call.test.ts` +12). Planning-time line citations are re-derived before each edit.
- D2 merge-base anchor: `ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd`.
- D3 PowerShell rule: no sh-pwsh route; substitutions per `evidence/other/pwsh-task-classification.2026-10-02T05-00.md`.
