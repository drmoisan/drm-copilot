# Jest Back-Compat Suite Against the Unmodified Validator (P1-T7)

Timestamp: 2026-09-30T14-48
Command: (from `extensions/drm-copilot`) npm run test:unit -- test/lib/validate/orchestrator-state-blocked-reason-backcompat.test.ts
EXIT_CODE: 0
Output Summary: `Test Suites: 1 passed, 1 total`; `Tests:       28 passed, 28 total`. 27 stem-by-mode cases (9 stems by 3 modes) plus the fixture-count case. Count matches the plan expectation of 28.

Execution route: scratchpad `.sh` file run with `sh` (changes to the worktree `extensions/drm-copilot` directory, then runs the command).

Capture context: `extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts` is unmodified. The `typescript` section of `tests/fixtures/orchestrator_state_blocked_reason_backcompat_expected.json` was produced by bundling a scratchpad capture script (outside the repository) with the repository's `esbuild` and running it under `node`; the script called `validateOrchestratorStateText` on each committed fixture with only one option set per mode (`requireComplete` with the injected `ROUTING_MATRIX` declared as in `orchestrator-state-core.completion.test.ts`). The section was merged into the expected file with the `python` object verified unchanged.
