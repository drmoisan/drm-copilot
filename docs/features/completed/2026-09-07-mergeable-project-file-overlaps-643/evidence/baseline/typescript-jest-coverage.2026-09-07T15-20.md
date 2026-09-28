# Baseline — TypeScript tests and coverage (issue #643, task [P0-T11])

- Timestamp: 2026-09-07T15:20Z
- Command: `pwsh -NoProfile -Command 'Push-Location extensions/drm-copilot; npm run test:coverage -- --coverageReporters=text; $code = $LASTEXITCODE; Pop-Location; exit $code'` (run from the worktree root)
- EXIT_CODE: 0

## Output Summary

### Test result lines (verbatim)

```text
Test Suites: 203 passed, 203 total
Tests:       2735 passed, 2735 total
```

Passed test count for later comparison (plan task [P8-T9] requires at least this value plus 12): 2735.

### Coverage table header and `All files` row (verbatim)

```text
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s                                                                   
All files                                                   |   96.72 |    90.17 |   89.93 |   96.72 |                                                                                     
```

Column values of the `All files` row, named:

- statements (`% Stmts`): **96.72**
- branches (`% Branch`): **90.17**
- functions (`% Funcs`): **89.93**
- lines (`% Lines`): **96.72**

Numeric line and branch percentages required by the acceptance condition: line **96.72**,
branch **90.17**. Both are above the uniform thresholds (line >= 85%, branch >= 75%).

### Row for the file this plan splits (recorded for the [P8-T9] comparison)

```text
  claude-blast-radius-derive-core.ts                        |     100 |    95.83 |     100 |     100 | 246,406
```
