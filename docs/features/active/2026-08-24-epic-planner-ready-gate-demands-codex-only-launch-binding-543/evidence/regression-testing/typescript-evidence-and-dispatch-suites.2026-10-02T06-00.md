# TypeScript launch-evidence and dispatch suites (issue #543)

Timestamp: 2026-10-02T06-00
Task: P5-T10
Command: `node run-jest.cjs test/lib/validate/epic-planner-launch-evidence.test.ts test/lib/validate/validate-orchestration-service-call.test.ts --verbose` (in `extensions/drm-copilot/`); supplementary title listing: the same command with `--json --outputFile=<scratchpad>/p5t10.json` in place of `--verbose`
EXIT_CODE: 0

Output Summary:
- `Test Suites: 2 passed, 2 total`; `Tests:       33 passed, 33 total` (0 failed).
- Per-title status from the supplementary `--json` run (exit 0, `numPassed 33 numFailed 0`; D1.4, `--verbose` prints no titles under this configuration):
  - passed: `skips a feature without launch keys when requireLaunchPaths is set`
  - passed: `still rejects a partial launch key when requireLaunchPaths is set`
  - passed: `threads the Codex flags into epic-planner-state`
- Title-selected acceptance runs: P5-T7 and P5-T8 each `Tests: 25 skipped, 1 passed, 26 total` (exit 0); P5-T9 `Tests: 6 skipped, 1 passed, 7 total` (exit 0).
- The P5-T8 substring `launch status path must identify a launch artifact in this repository.` is character-for-character the P4-T8 substring.
- D1: `validate-orchestration-service-call.test.ts` carried 178 lines before the edit (planning-time 166) because of the merged `VirtualFileSystem` `exists`/`isDirectory`/`listDirectory` stubs; the new test uses only `readTextFile` and `isFile`.
