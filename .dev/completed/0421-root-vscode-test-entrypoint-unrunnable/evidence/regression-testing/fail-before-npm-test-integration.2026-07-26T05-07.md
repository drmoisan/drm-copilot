# Fail-Before — Root `npm run test:integration` (#421)

Timestamp: 2026-07-26T05-07

Task: [P0-T5] `[expect-fail]` — a non-zero exit is the expected and required outcome for this task.

Command:

```
npm run test:integration
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab68fbeb0ce28fc0d` (repository/worktree root)

EXIT_CODE: 1

## Raw Output (verbatim)

```
> drm-copilot@1.0.0 test:integration
> vscode-test

Error: Could not find a .vscode-test file in this directory or any parent. You can specify one with the --config option.
    at loadDefaultConfigFile (file:///C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab68fbeb0ce28fc0d/node_modules/@vscode/test-cli/out/cli/config.mjs:33:11)
    at main (file:///C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab68fbeb0ce28fc0d/node_modules/@vscode/test-cli/out/bin.mjs:20:21)
    at file:///C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ab68fbeb0ce28fc0d/node_modules/@vscode/test-cli/out/bin.mjs:14:1
    at ModuleJob.run (node:internal/modules/esm/module_job:430:25)
    at process.processTicksAndRejections (node:internal/process/task_queues:104:5)
    at async onImport.tracePromise.__proto__ (node:internal/modules/esm/loader:661:26)
    at async asyncRunEntryPointWithESMLoader (node:internal/modules/run_main:101:5)
```

## Verbatim Error Text

```
Error: Could not find a .vscode-test file in this directory or any parent. You can specify one with the --config option.
```

## Analysis

- `test:integration` has no `pre`-script, so the failure is immediate: the `vscode-test` binary exits inside `loadDefaultConfigFile` at `node_modules/@vscode/test-cli/out/cli/config.mjs:33:11`.
- This reproduces the exact failure recorded in the spec's Actual Behavior section and in the prior #414 evidence at `docs/features/active/2026-07-25-npm-audit-brace-expansion-dos-414/evidence/baseline/test-integration-root-baseline.2026-07-25T17-12.md`.
- Zero tests execute. Removing this script therefore removes no test coverage.

Output Summary: Root `npm run test:integration` fails with EXIT_CODE 1 as expected. The `vscode-test` binary exits inside `@vscode/test-cli` `loadDefaultConfigFile` with `Error: Could not find a .vscode-test file in this directory or any parent.` before any test runner starts; zero tests execute.
