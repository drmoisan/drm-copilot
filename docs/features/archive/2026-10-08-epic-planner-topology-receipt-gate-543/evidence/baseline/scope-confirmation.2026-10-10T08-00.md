# Scope Confirmation (Issue #543)

Timestamp: 2026-10-10T08-00
Task: [P0-T2]
Sources read: `spec.md`, `issue.md`, `research/research.2026-10-08T14-00.md` in `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/`

Work Mode: full-bug
AC count: 14
AC source: `spec.md` section `## Acceptance Criteria` (lines 223-236). `user-story.md` is absent and is not created.

Code paths the diff will write (5):
1. `scripts/dev_tools/validate_epic_planner_state.py`
2. `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`
3. `tests/scripts/dev_tools/test_validate_epic_planner_state.py`
4. `extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts`
5. `extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts`

Explicitly out of scope:
- `scripts/dev_tools/validate_orchestration_artifacts.py` (495 lines; Python CLI unchanged).
- `.claude/**`, `.github/**`, `.agents/**`, `.codex/**`, `extensions/drm-copilot/resources/**`.
- `extensions/drm-copilot/jest.config.cjs` (no per-file threshold entry is added; research section 10).
- `extensions/drm-copilot/src/mcp-tool-inputs.ts`, `extensions/drm-copilot/src/mcp-tool-definitions.ts`, `extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts`, `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts`.
- The per-feature receipt checks (`scripts/dev_tools/validate_epic_planner_state.py` lines 222-276; `epic-planner-state-core.ts` lines 292-364) and the `REQUIRED_KEYS` / `REQUIRED_FEATURE_KEYS` contract gap (follow-up issue, not filed by this plan).

Design: research Approach A (key membership on the top-level `topology_receipt` key, reusing `key_gated` / `requireLaunchPaths`). The PR states "Partially addresses #543".
