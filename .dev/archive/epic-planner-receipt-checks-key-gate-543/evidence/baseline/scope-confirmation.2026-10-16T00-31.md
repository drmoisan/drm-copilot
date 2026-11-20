# Scope Confirmation (P0-T2)

Timestamp: 2026-10-16T00-31
Command: read spec.md, issue.md, research/research.2026-10-15T08-05.md in docs/features/active/epic-planner-receipt-checks-key-gate-543/
EXIT_CODE: 0
Work Mode: full-bug
AC source: spec.md
AC count: 18

Code paths written (six):
- scripts/dev_tools/validate_epic_planner_state.py
- extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts
- tests/scripts/dev_tools/test_validate_epic_planner_state.py
- tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py (new)
- extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts (new)
- extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts

Conditional contingency paths (two; only when P3-T3 records Contingency: triggered):
- extensions/drm-copilot/src/lib/validate/epic-planner-ready-features.ts
- extensions/drm-copilot/test/lib/validate/epic-planner-ready-features.test.ts

Out of scope:
- scripts/dev_tools/validate_orchestration_artifacts.py
- .claude/**, .github/**, .agents/**, .codex/**, extensions/drm-copilot/resources/**
- extensions/drm-copilot/jest.config.cjs, extensions/drm-copilot/src/mcp-tool-inputs.ts, extensions/drm-copilot/src/mcp-tool-definitions.ts, extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts, extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts
- extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts and tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py (run, never edited)
- scripts/dev_tools/_epic_orchestrator_state_launch_binding.py `_validate_model_receipt` and all PR #829, PR #874, PR #912 behaviour

Output Summary: issue.md line 12 carries "- Work Mode: full-bug"; spec.md section "## Acceptance Criteria" holds 18 unchecked criteria (AC18 CI-dependent). Research recommends Candidate A (reuse key_gated / requireLaunchPaths with a per-key membership predicate inside the per-feature loop); contingency in research section 7.3.
