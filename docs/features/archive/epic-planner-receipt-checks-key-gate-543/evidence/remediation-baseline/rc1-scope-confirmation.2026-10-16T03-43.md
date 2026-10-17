# Remediation Cycle 1 Scope Confirmation (P0-T2)

Timestamp: 2026-10-16T03-43
Command: read remediation-inputs.2026-10-16T01-36.md, code-review.2026-10-16T01-36.md, policy-audit.2026-10-16T01-36.md, feature-audit.2026-10-16T01-36.md, and spec.md (## Acceptance Criteria) in docs/features/active/epic-planner-receipt-checks-key-gate-543/
EXIT_CODE: 0
Work Mode: full-bug
Cycle findings: R1, PA-N2/CR-2, CR-5 (ready gate, dependency waves, planner launch binding, git-integrity planning_commit), CR-4 (conditional)
Not in scope: CR-3, PA-N1

Write set (10):
- scripts/dev_tools/validate_epic_planner_state.py
- scripts/dev_tools/_epic_orchestrator_state_launch_binding.py
- scripts/dev_tools/epic_planner_git_integrity.py
- extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts
- extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts
- extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts
- tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py (new)
- tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py (new)
- extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-indices.test.ts (new)
- extensions/drm-copilot/test/lib/validate/epic-planner-git-integrity-feature-indices.test.ts (new)

Conditional (2, only when P3-T6 records Contingency: triggered):
- extensions/drm-copilot/src/lib/validate/epic-planner-worthiness.ts
- extensions/drm-copilot/test/lib/validate/epic-planner-worthiness.test.ts

Out of scope (must remain unchanged):
- extensions/drm-copilot/jest.config.cjs (AC13), scripts/dev_tools/validate_orchestration_artifacts.py, .claude/**, .github/**, .agents/**, .codex/**, extensions/drm-copilot/resources/**, extensions/drm-copilot/src/mcp-tool-inputs.ts, extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts
- scripts/dev_tools/validate_epic_orchestrator_state.py, extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts, scripts/dev_tools/epic_planner_readiness.py, extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts, scripts/dev_tools/epic_planner_launch_evidence.py, extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts
- Every existing test file (the fourteen listed in the plan), spec.md, and plan.2026-10-15T07-42.md

Further-site search: no additional compacted-list site. Every other features[ prefix on the epic-planner validation path (_extract_features / extractFeatures, _validate_feature_files / validateFeatureFiles, epic_planner_launch_evidence prefixes) already uses the original index from a raw enumeration; the epic-orchestrator-state messages carry no index. Python production file count stays at 3.

Launch-binding caller analysis: validate_epic_planner_child_launch_bindings / validateEpicPlannerChildLaunchBindings have exactly one caller each (the epic-planner state validator); the epic-orchestrator-state callers use validate_epic_child_launch_bindings / validateEpicChildLaunchBindings with the raw features list and a folder-based prefix; those stay unchanged.

Git-integrity caller analysis: validate_planning_git_integrity / validatePlanningGitIntegrity have one production caller each (the readiness modules, not edited) plus direct test callers whose entries carry no plan_path. The fix keeps the exported signature, pairs each plan in order to the next object entry whose plan_path yields it, and falls back to the previous positional pairing over object entries when any plan has no matching entry, so the direct-test callers see byte-identical results.

Pairing consequence: for the readiness caller, when a non-object or plan-less entry precedes a plan's entry, the git-integrity loop reads planning_commit and plan_hash from the entry that owns the plan rather than from the entry at the compacted position. No message text changes; checkpoints without such an entry are unaffected.

Output Summary: Review verdict REMEDIATION_REQUIRED with one blocking finding (R1 = PA-1 / CR-1, TypeScript lcov artifact absent). Non-blocking PA-N2/CR-2 (no repository-wide Python figure), CR-4 (core file at 488 of 500 lines), and CR-5 (compacted feature indices) are in scope by orchestrator decision; CR-3 and PA-N1 (AC18, S9) are not. spec.md has AC1-AC17 checked and AC18 unchecked.
