# AC 8 and AC 27 Absence Checks (P10-T4)

Timestamp: 2026-09-26T20-31
Branch: N588
ExpectedExitCode: 1

Command: git grep --untracked -n -F -e "Detected issue references (classified)" -- "scripts/dev_tools/pr_context/*.py" "extensions/drm-copilot/src/lib/pr-context/*.ts"
EXIT_CODE: 1

Command: git grep --untracked -n -F -e "ABC-123" -- "scripts/dev_tools/pr_context/*.py" "extensions/drm-copilot/src/lib/pr-context/*.ts"
EXIT_CODE: 1

Output Summary: Both commands printed no output and exited 1, equal to the expected exit code. The classified-promotion heading (AC 8) and the JIRA example key in docstrings or TSDoc (AC 27) appear in no Python or TypeScript pr-context production file, tracked or untracked.
