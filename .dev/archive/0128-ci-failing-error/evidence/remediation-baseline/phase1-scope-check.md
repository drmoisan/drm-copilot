Timestamp: 2026-04-05T20:42:28.8607822-04:00
Scope Summary:
- Shared POSIX fresh-module helper logic now lives in test/runtime-test-helpers.ts.
- extension.test.ts was reduced to the core hello-command coverage plus the two preserved Windows-root POSIX regressions.
- Additional command coverage moved into test/extension.workflow-commands.test.ts.
- repo-automation-service.test.ts now consumes the shared helper module.
Touched Test/Helper Files:
- extensions/drm-copilot/test/extension.test.ts
- extensions/drm-copilot/test/extension.workflow-commands.test.ts
- extensions/drm-copilot/test/extension-test-harness.ts
- extensions/drm-copilot/test/runtime-test-helpers.ts
- extensions/drm-copilot/test/repo-automation-service.test.ts
Line Counts:
- extension.test.ts = 251
- extension.workflow-commands.test.ts = 393
- extension-test-harness.ts = 244
- runtime-test-helpers.ts = 135
- repo-automation-service.test.ts = 234
Scope Guard:
- No production files were edited during remediation.
- extensions/drm-copilot/src/command-runtime.ts was left unchanged from the current fix.
- Preserved exact scenario names: helloPython preserves C:/extension on POSIX hosts; helloPowerShell preserves C:/extension on POSIX hosts; collectCommitContext preserves C:/extension on POSIX hosts; newPotentialEntry preserves C:/extension on POSIX hosts.
