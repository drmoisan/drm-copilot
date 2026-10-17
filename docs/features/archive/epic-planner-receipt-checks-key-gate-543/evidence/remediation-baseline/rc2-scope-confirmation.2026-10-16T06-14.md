# Remediation Cycle 2 Scope Confirmation (P0-T2)

Timestamp: 2026-10-16T06-14
Command: read code-review.2026-10-16T04-40.md (findings table lines 38-44), policy-audit.2026-10-16T04-40.md (section 8, lines 365-380), feature-audit.2026-10-16T04-40.md (evaluation table and readiness), remediation-plan.2026-10-16T01-36.md (## Plan Deviations, lines 682-695), spec.md (acceptance-criteria checkboxes, lines 221-238)
EXIT_CODE: 0
Output Summary: Inputs read; scope recorded below. Feature audit: Overall Feature Readiness READY, 17 PASS, AC18 unchecked (CI-dependent).

Work Mode: full-bug (issue.md line 12)

Cycle findings: CR-6, CR-9 (plus pre-existing uncovered lines in the six touched files), CR-8, CR-10
Not in scope: CR-3, CR-4 (no edit to epic-planner-state-core.ts), CR-7, PA-N1

## Write set (seventeen paths)

Production (4):
1. scripts/dev_tools/epic_planner_git_integrity.py
2. scripts/dev_tools/epic_planner_readiness.py
3. extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts
4. extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts

Tests edited (5):
5. tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py
6. tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py
7. tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py
8. tests/scripts/dev_tools/test_epic_planner_git_integrity.py
9. extensions/drm-copilot/test/lib/validate/epic-planner-git-integrity-feature-indices.test.ts

Tests new (8):
10. tests/scripts/dev_tools/typescript_twin_test_support.py
11. tests/scripts/dev_tools/test_validate_epic_planner_state_shape_errors.py
12. tests/scripts/dev_tools/test_epic_orchestrator_state_launch_binding_edges.py
13. tests/scripts/dev_tools/test_epic_planner_readiness_relative_paths.py
14. extensions/drm-copilot/test/lib/validate/epic-planner-state-shape-errors.test.ts
15. extensions/drm-copilot/test/lib/validate/epic-planner-state-wave-rethrow.test.ts
16. extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-launch-binding-edges.test.ts
17. extensions/drm-copilot/test/lib/validate/epic-planner-readiness-relative-paths.test.ts

## Out of scope (must remain unchanged)

- Spec AC13 list: scripts/dev_tools/validate_orchestration_artifacts.py, .claude/**, .github/**, .agents/**, .codex/**, extensions/drm-copilot/resources/**, extensions/drm-copilot/jest.config.cjs, extensions/drm-copilot/src/mcp-tool-inputs.ts, extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts, extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts, tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py.
- Production neighbours: scripts/dev_tools/validate_epic_planner_state.py, scripts/dev_tools/_epic_orchestrator_state_launch_binding.py, extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts, extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts, extensions/drm-copilot/src/lib/validate/epic-wave-computation.ts, scripts/dev_tools/epic_planner_launch_evidence.py, extensions/drm-copilot/src/lib/validate/epic-planner-launch-evidence.ts.
- Existing tests not in the edit list, including tests/scripts/dev_tools/test_epic_planner_readiness.py, extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts, extensions/drm-copilot/test/lib/validate/epic-planner-git-integrity.test.ts, both launch-evidence test-support modules, extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-indices.test.ts.
- spec.md, plan.2026-10-15T07-42.md, remediation-plan.2026-10-16T01-36.md.

## CR-6 decision

Use the tuples. Each of the three cycle-1 Python feature test files gains test_asserted_messages_match_typescript_twin, which asserts every ASSERTED_MESSAGES member appears as a double-quoted literal in its TypeScript twin test file, via one shared helper tests/scripts/dev_tools/typescript_twin_test_support.py. Reason: the cycle-1 evidence commands (rc1-byte-identical-strings, rc1-git-byte-identical-strings) import the tuples by name, so deleting them would make those recorded Command: lines non-reproducible; using them converts the one-off identity evidence into a standing test.

## CR-10 direction and evidence searched

Direction: TypeScript is aligned to Python (dot and empty segments dropped, empty result becomes "."; every Python rejection kept). Evidence searched: no Python or TypeScript test asserts acceptance or rejection of a "." segment or an empty segment (the only path-rejection tests use ../outside/preflight.md: tests/scripts/dev_tools/test_epic_planner_readiness.py line 403, extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts line 438); no spec or document under docs/features/ states a rule for dot segments in readiness paths. Python behaviour does not change.

## Observations (recorded, not implemented)

- O-1: Python _relative_path accepts drive-qualified C:/docs/x; TypeScript rejects it. repositoryRelativePath keeps the drive rule, so the divergence remains; recommendation is to add the drive rejection to Python in a follow-up decision.
- O-2: Python accepts plan_path == feature_folder; TypeScript requires the folder/ prefix. Not changed.
- O-3: readiness modules carry pre-existing uncovered lines outside this cycle's scope; TypeScript lines 37-40 and 42-43 move into the git-integrity module and are covered by the CR-10 tests; the rest are recorded, not targeted.
