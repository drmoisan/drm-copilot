Timestamp: 2026-03-14T23-38
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "reuses the active feature plan editor before opening the picker"
EXIT_CODE: 1
Output Summary:
- Expected red test reproduced.
- Jest test `reuses the active feature plan editor before opening the picker` failed.
- Failure reason: missing command handler `drmCopilotExtension.resolveExecuteHardLockPrompt`.
