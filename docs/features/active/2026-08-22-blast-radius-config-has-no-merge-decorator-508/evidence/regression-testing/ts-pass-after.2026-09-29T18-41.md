# TypeScript Pass-After (P3-T8)

Timestamp: 2026-09-29T18-41
Command: node run-jest.cjs --verbose claude-config-carriage claude-blast-radius-overlay claude-customizations   (cwd: extensions/drm-copilot)
Command actually executed: env -u AI_AGENT -u CLAUDECODE node run-jest.cjs --verbose claude-config-carriage claude-blast-radius-overlay claude-customizations
Reason: the installed Jest suppresses the per-test verbose listing when it detects an AI-agent environment (`AI_AGENT`, `CLAUDECODE`); a first run of the plan command exited 0 with `Tests: 92 passed, 92 total` but printed no per-test lines. Unsetting the two variables restores the listing; the test selection and assertions are unchanged.
EXIT_CODE: 0
Output Summary:
- Test Suites: 5 passed, 5 total (claude-blast-radius-overlay-parity, claude-customizations, claude-config-carriage, claude-blast-radius-overlay, extension.push-down-claude-customizations)
- Tests: 92 passed, 92 total (0 failed)
- Verbose listing, the two P1-T3 cases:
  - `√ writes byte-identical output on two pushes and never writes the overlay` (claude-config-carriage.test.ts)
  - `√ does not publish a source-side overlay file` (claude-blast-radius-overlay.test.ts)
- Also listed: `√ issue #508 AC09 regenerates the main file; destination-local content is carried by the overlay`
- Fail-before reference: evidence/regression-testing/ts-fail-before.2026-09-29T18-41.md
