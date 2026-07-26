# Fail-Before — Root `npm test` (#421)

Timestamp: 2026-07-26T05-06

Task: [P0-T4] `[expect-fail]` — a non-zero exit is the expected and required outcome for this task. This artifact is the fail-before evidence for AC8(a).

Command:

```
npm test
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ab68fbeb0ce28fc0d` (repository/worktree root)

EXIT_CODE: 1

## Raw Output (verbatim)

```
> drm-copilot@1.0.0 pretest
> npm run compile && npm run compile:integration-tests && npm run lint


> drm-copilot@1.0.0 compile
> node -e "...tsc -p ./ ..."


> drm-copilot@1.0.0 compile:integration-tests
> node -e "...tsconfig.vscode-test.json guard..."

Skipping compile:integration-tests: tsconfig.vscode-test.json not found.

> drm-copilot@1.0.0 lint
> node run-node-tool.cjs eslint/bin/eslint.js --no-error-on-unmatched-pattern src tests


> drm-copilot@1.0.0 test
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

## Verbatim Error Text (AC8(a) evidence)

```
Error: Could not find a .vscode-test file in this directory or any parent. You can specify one with the --config option.
```

## Analysis

- The failure occurs inside `@vscode/test-cli`'s `loadDefaultConfigFile` (`node_modules/@vscode/test-cli/out/cli/config.mjs:33:11`), before any test runner is started. Zero tests execute. This substantiates the AC8(a) claim that repointing `test` away from `vscode-test` removes no test execution: the script has never executed a test.
- `pretest` runs to completion successfully (compile, compile:integration-tests, lint). `compile:integration-tests` self-skips with `Skipping compile:integration-tests: tsconfig.vscode-test.json not found.`, confirming the Root Cause Analysis finding that this script is unconditionally inert on this lineage.
- The failure is independent of the `.claude` dot-directory worktree artifact (#414 Condition 3): the process exits in `@vscode/test-cli` config resolution and never reaches jest.

Output Summary: Root `npm test` fails with EXIT_CODE 1 as expected. `pretest` (compile + compile:integration-tests + lint) succeeds; `compile:integration-tests` self-skips because `tsconfig.vscode-test.json` is absent. The `test` script (`vscode-test`) then exits inside `@vscode/test-cli` `loadDefaultConfigFile` with `Error: Could not find a .vscode-test file in this directory or any parent.` No test runner starts and zero tests execute.
