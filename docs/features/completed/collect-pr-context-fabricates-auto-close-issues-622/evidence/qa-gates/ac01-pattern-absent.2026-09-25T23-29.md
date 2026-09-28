# AC 1 Pattern Absent (P10-T1)

Timestamp: 2026-09-26T20-27
Branch: N588

Command: git grep --untracked -n -F -e "[A-Z][A-Z0-9]+-" -- "scripts/dev_tools/pr_context/*.py" "extensions/drm-copilot/src/lib/pr-context/*.ts"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: No output. The former JIRA-key pattern fragment appears in no Python or TypeScript pr-context production file (tracked or untracked). Exit 1 equals the expected exit code.
