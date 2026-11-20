# Baseline — `npm run test:integration`, Repository Root (#414, [P0-T17], [expect-fail])

Timestamp: 2026-07-25T17-12

Command: `npm run test:integration` (working directory: repository root, BEFORE any manifest edit)
EXIT_CODE: 1

Expected outcome for this task: exit 1 with a `@vscode/test-cli` configuration error. This artifact establishes that the failure is a pre-existing repository condition.

## Verbatim Output

```text
> drm-copilot@1.0.0 test:integration
> vscode-test

Error: Could not find a .vscode-test file in this directory or any parent. You can specify one with the --config option.
    at loadDefaultConfigFile (file:///C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5f77ee3b34398ec5/node_modules/@vscode/test-cli/out/cli/config.mjs:33:11)
    at main (file:///C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5f77ee3b34398ec5/node_modules/@vscode/test-cli/out/bin.mjs:20:21)
    at file:///C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5f77ee3b34398ec5/node_modules/@vscode/test-cli/out/bin.mjs:14:1
    at ModuleJob.run (node:internal/modules/esm/module_job:430:25)
    at process.processTicksAndRejections (node:internal/process/task_queues:104:5)
    at async onImport.tracePromise.__proto__ (node:internal/modules/esm/loader:661:26)
    at async asyncRunEntryPointWithESMLoader (node:internal/modules/run_main:101:5)
```

## Pre-Existing Condition Confirmed

The failure occurs in `loadDefaultConfigFile` before `@vscode/test-cli` starts any test runner. No mocha process is launched, so no test is executed and no dependency of the runner is loaded.

Absence of the required configuration, verified in the repository root:

Command: `ls -a | grep -i vscode-test` (repository root)
EXIT_CODE: 1 (grep no-match)

```text
(no output — no .vscode-test.json, .vscode-test.js, .vscode-test.cjs, or .vscode-test.mjs exists)
```

Command: `ls tsconfig*` (repository root)
EXIT_CODE: 0

```text
tsconfig.jest.json
tsconfig.json
tsconfig.tests.json
```

`tsconfig.vscode-test.json` is absent, consistent with the root `compile:integration-tests` script, which self-skips when that file is missing.

The condition is environment-independent: `@vscode/test-cli` searches the working directory and all parents for a `.vscode-test` config file, and none exists in the repository, so the same error occurs on a CI runner. No workflow under `.github/workflows/**` invokes root `test:integration`.

This is a separate pre-existing defect, recorded in `spec.md` under "Rollout & Follow-up" as an item to be reported as a potential issue. It is out of scope for #414 and is not caused by the `overrides`/lockfile change. [P4-T6] re-runs this command post-change and compares against this baseline.

Output Summary: FAIL as expected, pre-existing. `npm run test:integration` exits 1 in the repository root before any #414 edit with `Error: Could not find a .vscode-test file in this directory or any parent.` from `@vscode/test-cli`'s `loadDefaultConfigFile`. No `.vscode-test.{json,js,cjs,mjs}` exists in the repository or any parent directory and `tsconfig.vscode-test.json` is absent, so the CLI exits before starting a runner. The failure is independent of the #414 change and is the comparison basis for [P4-T6].
