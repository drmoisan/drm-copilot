# TypeScript Fail-Before (P1-T3) [expect-fail]

Timestamp: 2026-09-29T18-41
Command: node run-jest.cjs claude-config-carriage claude-blast-radius-overlay   (cwd: extensions/drm-copilot)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Test Suites: 2 failed, 2 total
- Tests: 2 failed, 17 passed, 19 total
- Failed 1: `issue #508 AC08 AC12 the destination overlay survives two pushes › writes byte-identical output on two pushes and never writes the overlay`
  - Fails at claude-config-carriage.test.ts line 480: `expect(text).toContain('"Directory.Build.props"')` - `Expected substring: "\"Directory.Build.props\""`. The preceding `expect(second).toBe(first)` (line 478) passed.
- Failed 2: `issue #508 AC11 overlay never shipped › does not publish a source-side overlay file`
  - Fails at claude-blast-radius-overlay.test.ts line 36: `expect(seeded.isFile("/dest/config/blast-radius.local.json")).toBe(false)` - `Received: true` (the source-side overlay is published pre-fix).
- Every other case in the two files passed (17).
- The failure set matches the plan; the regression reproduces the defect.
