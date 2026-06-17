# Final QC — Jest Test and Coverage (Issue #194)

Timestamp: 2026-06-17T16-56
Command: node run-jest.cjs --coverage
Working directory: extensions/drm-copilot/
EXIT_CODE: 0

Output Summary:
- Test Suites: 33 passed, 33 total
- Tests: 388 passed, 388 total
- All files coverage (headline, post-change):
  - Line coverage: 95.65%
  - Branch coverage: 87.04%
  - Statements: 95.65%
  - Functions: 96.03%
- New-module coverage:
  - src/remove-worktrees.ts: 98.42% line, 90.32% branch, 100% func (uncovered: 103-105, the malformed-block guard)
  - src/remove-worktrees-runner.ts: 100% line, 85% branch, 100% func (uncovered branch defaults on lines 69, 113, 148)
  - src/extension.ts (modified): 96.82% line, 86.84% branch, 100% func
- Both line (>= 85%) and branch (>= 75%) thresholds satisfied for the package and the new modules.
