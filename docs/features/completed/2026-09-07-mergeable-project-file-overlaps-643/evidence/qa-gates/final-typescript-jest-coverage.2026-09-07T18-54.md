# Final QA — TypeScript tests with coverage (Jest)

Timestamp: 2026-09-07T18-54

Command: `pwsh -NoProfile -Command 'Push-Location extensions/drm-copilot; npm run test:coverage -- --coverageReporters=text; $code = $LASTEXITCODE; Pop-Location; exit $code'`

EXIT_CODE: 0

## Output Summary

Verbatim `Test Suites:` and `Tests:` lines:

```text
Test Suites: 205 passed, 205 total
Tests:       2751 passed, 2751 total
```

Verbatim `All files` row and the two rows the task names:

```text
All files                                                   |   96.73 |    90.19 |   89.86 |   96.73 |
  claude-blast-radius-derive-core.ts                        |     100 |     97.5 |   88.88 |     100 | 306
  claude-blast-radius-derive-manifests.ts                   |     100 |    95.65 |     100 |     100 | 122
```

Column order is `% Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s`.

### Threshold checks

- `All files` `% Lines` = **96.73**, at or above 85.
- `All files` `% Branch` = **90.19**, at or above 75.
- `claude-blast-radius-derive-core.ts`: `% Lines` = **100**, `% Branch` = **97.5**; both clear.
- `claude-blast-radius-derive-manifests.ts`: `% Lines` = **100**, `% Branch` = **95.65**; both clear.

Jest exits non-zero when any `coverageThreshold` entry is unmet, including the per-file entry [P4-T3]
added for `claude-blast-radius-derive-manifests.ts`. The run exited 0, so every configured threshold
was met.

### Passed-count check

The [P0-T11] baseline recorded `Tests: 2735 passed, 2735 total`. The required floor is that count
plus 12, that is 2747. The observed count is 2751, which clears the floor by 4.

## Loop iteration

This run is part of iteration 2 of the TypeScript loop. The loop restarted once, at [P8-T6], because
Prettier rewrote `test/lib/validate/parallel-orchestrator-state-core.test.ts` on iteration 1. No
source change occurred after the iteration-2 format step, so this test run observes the final tree.

## Post-final-change re-verification

The PowerShell loop restarted after this artifact was first written, and its iteration-3 fix changed
tracked source under `.claude/lib/` and `tests/`. To keep the [P8-T13] statement true — that every
recorded pass observed the tree after the last source change — this step was re-run at
2026-09-07T19-30 against the final tree. Observed result: `Tests: 2751 passed, 2751 total`; `All files` 96.73 / 90.19 / 89.86 / 96.73; both named rows 100 lines with 97.5 and 95.65 branches — every value identical to the run recorded above; exit 0.

The re-run required no source change, so no further restart followed it.
