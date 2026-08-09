# TypeScript Test and Coverage Baseline — Issue #440 F7 Remediation Cycle 1

- **Task:** [P0-T6]
- **Plan of record:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md`

Timestamp: 2026-08-09T00-19

Command: `npm run test:coverage` (run from `extensions/drm-copilot/`; resolves to `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`)

EXIT_CODE: 0

## Output Summary

**Suites: 180 passed, 180 total. Tests: 2434 passed, 2434 total. Snapshots: 0. Time: 8.771 s. Zero failures, zero skipped.**

Repository-wide coverage headline, verbatim from the `text-summary` reporter:

```
=============================== Coverage summary ===============================
Statements   : 96.52% ( 40213/41659 )
Branches     : 89.74% ( 5686/6336 )
Functions    : 90.02% ( 1164/1293 )
Lines        : 96.52% ( 40213/41659 )
================================================================================
```

- **Repository-wide line coverage: 96.52%** (40213 of 41659 lines). Above the uniform 85% floor.
- **Repository-wide branch coverage: 89.74%** (5686 of 6336 branches). Above the uniform 75% floor.

### Per-file figures parsed from `extensions/drm-copilot/coverage/lcov.info`

| File | LF | LH | Line % | BRF | BRH | Branch % |
|---|---|---|---|---|---|---|
| `src/lib/validate/parallel-orchestrator-state-core.ts` | 320 | 318 | **99.38%** | 38 | 35 | **92.11%** |
| `src/lib/validate/orchestration-artifacts.ts` | 284 | 284 | **100.00%** | 67 | 66 | **98.51%** |

Both files are well above the uniform line >= 85% / branch >= 75% floors before this cycle begins. The `LF=320` figure for `parallel-orchestrator-state-core.ts` corroborates the 320-line pre-change file length that P1-T2's acceptance criterion depends on (P1-T2 must take the file to 322 lines).

All coverage percentages above are numeric values computed from the emitted `lcov.info` line and branch counters, not placeholders.

## Determination

Exit code 0 with a fully green suite and both repository-wide coverage figures above their gates. P4-T4 compares against these values for the no-regression condition, and P4-T10 consumes the repository-wide line and branch percentages as the TypeScript baseline for the coverage-delta record.
