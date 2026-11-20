# Final QA Gate — `npm run test:integration`, Repository Root (#414, [P4-T6])

Timestamp: 2026-07-25T22-04

Command: `npm run test:integration` (working directory: repository root, AFTER the manifest edit, lockfile regeneration, and [P4-T1] `npm ci`)
EXIT_CODE: 1

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

`EXIT_CODE: SKIPPED` was not used; the command was executed and its true exit code is recorded above.

## Baseline Comparison

| | [P0-T17] pre-edit baseline | [P4-T6] post-change |
|---|---|---|
| Artifact | `evidence/baseline/test-integration-root-baseline.2026-07-25T17-12.md` | this artifact |
| EXIT_CODE | 1 | 1 |
| Error | `Could not find a .vscode-test file in this directory or any parent.` | identical |
| Failing frame | `loadDefaultConfigFile` (`@vscode/test-cli/out/cli/config.mjs:33:11`) | identical |
| Stack trace | 7 frames | identical, same line numbers |

Status: **MET by baseline parity.** The post-change output is the same `@vscode/test-cli` configuration error with the same exit code and the same stack as the pre-edit baseline. The change introduced no new failure on this command.

## Pre-Existing Condition, Out of Scope for #414

The failure occurs in `loadDefaultConfigFile` before `@vscode/test-cli` starts any test runner, so no mocha process launches and no runner dependency is loaded. The repository root defines `test:integration` as `vscode-test`, but no `.vscode-test.{json,js,cjs,mjs}` configuration file exists in the repository or any parent directory, and `tsconfig.vscode-test.json` is absent (verified at baseline, [P0-T17]).

The condition is environment-independent: `@vscode/test-cli` searches the working directory and all parents for the config file, and none exists in the repository, so the same error occurs on a CI runner. No workflow under `.github/workflows/**` invokes root `test:integration`, so this command is not a runnable gate in this repository.

**This missing root `vscode-test` configuration is a separate pre-existing defect to be reported as a potential issue. It is out of scope for #414** and is not caused by the `overrides`/lockfile change. It is recorded for separate filing in [P6-T6] (Condition B) and is already noted in `spec.md` under "Rollout & Follow-up".

## Consequence for Verification Coverage

Because this command cannot execute, mocha's `minimatch` call site is not exercised by any runnable gate in this repository. That call site is verified directly instead in [P6-T4], which resolves `minimatch` from mocha's own resolution root and exercises a brace-containing pattern with the options mocha passes.

## QA Loop Disposition

Acceptance is met by baseline parity, which is the dispositioned acceptance for this gate (derived from the [P0-T17] expect-fail disposition). The command wrote no files. The Phase 4 loop continues to [P4-T7] rather than restarting.

Output Summary: `npm run test:integration` exits 1 in the repository root after the change with the identical `@vscode/test-cli` `Could not find a .vscode-test file` error, exit code, and stack trace recorded at the [P0-T17] pre-edit baseline. Acceptance is met by baseline parity: the change introduced no new failure. The missing root `.vscode-test.{json,js,cjs,mjs}` configuration is a pre-existing, environment-independent defect to be reported separately and is out of scope for #414. Mocha's otherwise-unexercised `minimatch` call site is verified directly in [P6-T4].
