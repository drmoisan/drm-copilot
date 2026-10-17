# Remediation Cycle 1 Baseline Line Counts (P0-T7)

Timestamp: 2026-10-16T03-46
Command: grep -c -e '' <path> (once per production file); ls tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-indices.test.ts extensions/drm-copilot/test/lib/validate/epic-planner-git-integrity-feature-indices.test.ts
Equivalent-To: (Get-Content <path>).Count
EXIT_CODE: 0 (each grep -c); ls exit 2 by design
Output Summary:
- scripts/dev_tools/validate_epic_planner_state.py: 397 (planning value 397)
- scripts/dev_tools/_epic_orchestrator_state_launch_binding.py: 307 (planning value 307)
- scripts/dev_tools/epic_planner_git_integrity.py: 269 (planning value 269)
- extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts: 488 (planning value 488)
- extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts: 334 (planning value 334)
- extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts: 291 (planning value 291)
- ls: "No such file or directory" for all four new test paths (exit 2), as expected.
- All six counts equal the planning values; the tree has not moved and the cited line numbers apply.
