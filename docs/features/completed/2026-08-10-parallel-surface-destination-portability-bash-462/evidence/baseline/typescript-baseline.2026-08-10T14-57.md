# TypeScript Baseline — Issue #462

Timestamp: 2026-08-10T14-57

Task: [P0-T4]
Command: `npm --prefix extensions/drm-copilot run test:coverage`
EXIT_CODE: 0

The command is extension-scoped because every TypeScript file this feature touches lives
under `extensions/drm-copilot/`, and root npm scripts do not reach `extensions/**`. The
extension package exposes `test:coverage` (not `test:unit:coverage`). This is the same
lane the [P7-T9] final run uses, so the [P7-T11] delta compares one coverage universe.

A preparatory `npm ci` was required in `extensions/drm-copilot/` before the run: the
workspace had no `node_modules`, and `run-jest.cjs` failed with
`Cannot find module 'jest/bin/jest'`. `npm ci` added 457 packages, 0 vulnerabilities.

## Output Summary

- Result: 182 test suites passed / 182 total; 2472 tests passed / 2472 total; 0 failed;
  0 snapshots; 8.777 s.
- Statements: 96.55% (40624/42072)
- Branches: 89.86% (5774/6425)
- Functions: 90.09% (1173/1302)
- Lines: 96.55% (40624/42072)

Both baseline gate values clear the uniform thresholds in `.claude/rules/quality-tiers.md`
(line >= 85%, branch >= 75%). These are the reference values for the [P7-T11] delta.
