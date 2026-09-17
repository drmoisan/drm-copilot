Timestamp: 2026-09-17T14:08Z
Command: git diff --name-only 499e288a; git status --porcelain --untracked-files=all; then wc -l over every non-Markdown path in the union
EXIT_CODE: 0
Output Summary: The change set union contains 84 paths; all `docs/**/*.md` and `*.runbook.md` paths are Markdown and exempt from the cap. The 22 non-Markdown paths (all under `extensions/drm-copilot/`) and their line counts:

- jest.config.cjs: 290
- src/lib/pr-context/collector-output.ts: 494
- src/lib/pr-context/diff-emptiness.ts: 96
- src/lib/pr-context/index.ts: 123
- src/lib/pr-context/pr-context-service-call.ts: 174
- src/lib/pr-context/summary-helpers.ts: 460
- src/mcp-repo-automation-tool-definitions.ts: 425
- src/mcp-tool-definitions.ts: 462
- src/mcp-tool-inputs.ts: 483
- src/mcp-tools.ts: 360
- src/repo-automation-service-contract.ts: 213
- src/repo-automation-service.ts: 498
- test/extension.collect-pr-context.test.ts: 499
- test/extension.integration.test.ts: 481
- test/lib/pr-context/collector-output-head-source.test.ts: 128
- test/lib/pr-context/diff-emptiness.test.ts: 124
- test/lib/pr-context/pr-context-service-call-target.test.ts: 247
- test/lib/pr-context/pr-context-service-call.test.ts: 286
- test/mcp-repo-automation-tool-definitions.test.ts: 490
- test/mcp-tool-inputs.push-down-codex.test.ts: 57
- test/mcp-tool-inputs.test.ts: 495
- test/repo-automation-dispatch-pr-context-verification.test.ts: 187
- test/repo-automation-dispatch.test.ts: 499

Maximum observed count: 499 (test/extension.collect-pr-context.test.ts and test/repo-automation-dispatch.test.ts). Every path reports 500 or fewer lines; no path exceeds the cap.
