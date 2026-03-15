Timestamp: 2026-03-14T23-38
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "surfaces a missing python runtime error for resolveExecuteHardLockPrompt"
EXIT_CODE: 1
Output Summary:
- Expected red test reproduced.
- Jest test `surfaces a missing python runtime error for resolveExecuteHardLockPrompt` failed.
- Failure reason: missing command handler `drmCopilotExtension.resolveExecuteHardLockPrompt`.
