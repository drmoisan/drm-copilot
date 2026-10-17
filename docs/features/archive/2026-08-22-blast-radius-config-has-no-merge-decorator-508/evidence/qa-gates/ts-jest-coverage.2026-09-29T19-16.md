# TypeScript Full Test Suite with Coverage (P7-T5, iteration 1)

Timestamp: 2026-09-29T19-16
Command: node run-jest.cjs --coverage --coverageReporters=json-summary --coverageReporters=text-summary --coverageReporters=lcov   (cwd: extensions/drm-copilot; output captured to a session scratchpad file); then read extensions/drm-copilot/coverage/coverage-summary.json with `poetry run python -c "<single-line json read>"` from the repository root
EXIT_CODE: 0
Output Summary:
- lcov freshness: `stat -c %Y extensions/drm-copilot/coverage/lcov.info` before the run: absent (stat exit 1, `No such file or directory`); after the run: 1790723813 (stat exit 0).
- `Test Suites: 233 passed, 233 total`
- `Tests:       3221 passed, 3221 total` (0 failed).
- No `coverage threshold` failure message in the output.
- text-summary: Statements 96.98% (48998/50520), Branches 91.04% (7078/7774), Functions 90.87% (1464/1611), Lines 96.98% (48998/50520).
- coverage-summary.json total.lines.pct: 96.98; total.branches.pct: 91.04.
- Per-file (repository-relative to extensions/drm-copilot):
  - src/lib/push-down/claude-blast-radius-overlay.ts: lines.pct 99.55 (445/447), branches.pct 95.87 (93/97)
  - src/lib/push-down/claude-customizations.ts: lines.pct 100 (419/419), branches.pct 95.74 (45/47)
  - src/lib/push-down/claude-routing-merge.ts: lines.pct 99.35 (310/312), branches.pct 96.36 (53/55)
- Overlay file gate: lines 99.55 >= 85 and branches 95.87 >= 75.
- Acceptance: PASS.
