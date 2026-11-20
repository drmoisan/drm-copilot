# TypeScript Contract Stage (P7-T6, iteration 1)

Timestamp: 2026-09-29T19-16
Command: env -u AI_AGENT -u CLAUDECODE node run-jest.cjs --verbose claude-blast-radius-overlay-parity claude-customizations   (cwd: extensions/drm-copilot; AI_AGENT and CLAUDECODE unset so jest prints the verbose listing, as in P3-T8)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 3 passed, 3 total`; `Tests:       28 passed, 28 total` (0 failed).
- Suites: test/extension.push-down-claude-customizations.test.ts, test/lib/push-down/claude-customizations.test.ts, test/lib/push-down/claude-blast-radius-overlay-parity.test.ts.
- Title `issue #508 AC13 AC17 merged-path registry and preserved exports`, every case passed:
  - lists exactly the two merged paths
  - matches the distinct decorator paths in first-seen order
  - excludes the destination overlay from publication
  - keeps the AC17 routing and derive exports
- Title `issue #508 AC16 overlay composition corpus`, every case passed:
  - discovers at least six corpus files
  - composes conflict-tolerance-nested.json / empty-overlay.json / list-union.json / module-add-and-replace.json / scalar-and-overlay-only-keys.json / version-equal.json to its expected text
- Acceptance: PASS.
