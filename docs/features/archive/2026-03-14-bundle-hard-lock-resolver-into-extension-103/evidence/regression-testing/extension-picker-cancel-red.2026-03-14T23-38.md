Timestamp: 2026-03-14T23-38
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "returns early when the feature plan picker is cancelled"
EXIT_CODE: 1
Output Summary:
- Expected red test reproduced.
- Jest test `returns early when the feature plan picker is cancelled` failed.
- Failure reason: missing command handler `drmCopilotExtension.resolveExecuteHardLockPrompt`.
