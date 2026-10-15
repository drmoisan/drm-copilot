# Rule-edit old-phrase absence check (issue #886)

Timestamp: 2026-10-12T11-20

ExpectedExitCode: 1

Command: git grep -c -F "appends it to" -- .claude/rules/orchestrator-state.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md

EXIT_CODE: 1

Output Summary: no line printed. Neither file carries the old phrase `appends it to` after the edit (git grep -c prints a `<path>:<count>` line only for a file that still matches).
