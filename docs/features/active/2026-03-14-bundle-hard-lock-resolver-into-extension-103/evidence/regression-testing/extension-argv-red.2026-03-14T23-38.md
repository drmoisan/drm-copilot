Timestamp: 2026-03-14T23-38
Command: npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/extension.resolve-hard-lock-prompt.test.ts -t "passes the wrapper path plus --target and --workspace argument pairs"
EXIT_CODE: 1
Output Summary:
- Expected red test reproduced.
- Jest test `passes the wrapper path plus --target and --workspace argument pairs` failed.
- Failure reason: missing command handler `drmCopilotExtension.resolveExecuteHardLockPrompt`.
