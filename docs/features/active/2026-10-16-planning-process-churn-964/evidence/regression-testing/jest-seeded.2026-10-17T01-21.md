# Isolation Run — Seeded Randomized Jest

Timestamp: 2026-10-17T00-59
Task: [P6-T9]
Command: sh SCRATCH/issue-964-jest-seeds.sh 964964 20261016 31337 (node run-jest.cjs --randomize --seed=<n> in extensions/drm-copilot, once per seed)
EXIT_CODE: 0
Output Summary:
- Seed 964964: Test Suites 281 passed of 281; Tests 4103 passed of 4103.
- Seed 20261016: Test Suites 281 passed of 281; Tests 4103 passed of 4103.
- Seed 31337: Test Suites 281 passed of 281; Tests 4103 passed of 4103.
- Seeds recorded above; Jest printed `Seed: <n>` for each run.

## Order Dependence Found and Fixed

The first seeded run (2026-10-17T00-54, seed 964964) failed 9 tests in `test/extension.test.ts`. Cause: the test "helloPowerShell preserves C:/extension on POSIX hosts" called `jest.resetModules()` in its `finally` block, so every later test in the file re-required `src/extension` into a fresh module graph bound to new `node:fs` and `node:child_process` mock instances, while the harness kept configuring the original instances. In the default order the test runs last in its block, so the dependence was hidden.

- Leaker side: the POSIX-path tests in `test/extension.test.ts` and `test/repo-automation-dispatch.test.ts` now load their fresh module graph inside `jest.isolateModulesAsync` with the new `mockPosixPathResolve` helper (`test/runtime-test-helpers.ts`), so the shared registry is never reset; the registry-resetting helper was removed.
- Victim side: `test/extension-test-harness.ts` keeps the primary `src/extension` instance (loaded in `resetExtensionHarnessState`, before any test body), so a registry reset cannot hand a test a module bound to unconfigured mocks.
- After both fixes all three seeds passed, including 964964.
