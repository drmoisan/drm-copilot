# Baseline Line Counts (P0-T6)

Timestamp: 2026-10-16T00-31
Command: grep -c -e '' <path> (one run per path, Bash tool, worktree root)
EXIT_CODE: 0
Equivalent-To: (Get-Content <path>).Count
Output Summary:
- scripts/dev_tools/validate_epic_planner_state.py: 375 (planning 375)
- extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts: 474 (planning 474)
- tests/scripts/dev_tools/test_validate_epic_planner_state.py: 424 (planning 424)
- extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts: 232 (planning 232)
- All four counts equal the planning-time values; no line re-location required.
