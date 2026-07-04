# Baseline — Test and Coverage (Issue #189)

Timestamp: 2026-06-16T13-49
Command: `node run-jest.cjs --coverage` (from `extensions/drm-copilot`)
EXIT_CODE: 0
Output Summary:
- Test result: 348 passed / 348 total; 32 suites passed.
- Coverage headline (All files): line 95.5%, branch 87.03%, funcs 95.87%, stmts 95.5%.
- In-scope production files at baseline:
  - `claude-worktree-session.ts`: line 100%, branch 100%, funcs 100%.
  - `extension.ts`: line 98.59%, branch 89.28%, funcs 100% (uncovered lines 213-214, 220-221, unrelated to this feature).
- `--coverage` is wired into `run-jest.cjs` (passthrough to jest); numeric coverage values reported above.
