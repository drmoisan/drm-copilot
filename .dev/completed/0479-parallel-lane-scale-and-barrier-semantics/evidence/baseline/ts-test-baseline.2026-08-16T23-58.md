# TypeScript Test + Coverage Baseline (Issue #479)

Timestamp: 2026-08-16T23-58

Command: `npm run test:coverage` (cwd `extensions/drm-copilot`; resolves to `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`)

EXIT_CODE: 0

## Output Summary

### Test counts

`Test Suites: 185 passed, 185 total` / `Tests: 2552 passed, 2552 total` / `Snapshots: 0 total`.

### Numeric text-summary totals

- Statements: **96.61%** (41738/43200)
- Branches: **89.96%** (5901/6559)
- Functions: **90.11%** (1221/1355)
- Lines: **96.61%** (41738/43200)

Both uniform thresholds are met (line >= 85%, branch >= 75%).

### Per-file values read from `extensions/drm-copilot/coverage/lcov.info`

The `test:coverage` script's reporters are `lcov` and `text-summary`, so per-file values are
read from the lcov record (`LH/LF` for lines, `BRH/BRF` for branches).

| File | Lines | Branches |
|---|---|---|
| `src/lib/validate/parallel-orchestrator-state-core.ts` | 320/322 = **99.38%** | 35/38 = **92.11%** |
| `src/lib/validate/parallel-planner-state-core.ts` | 453/453 = **100.00%** | 48/49 = **97.96%** |
