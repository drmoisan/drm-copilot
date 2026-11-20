# TypeScript Test and Coverage Baseline (P0-T31)

Timestamp: 2026-09-27T15-18
Command: npm --prefix extensions/drm-copilot run test -- --coverage --coverageReporters=text --coverageReporters=lcov ; poetry run python SCRATCH/changed-lines-cov.py lcov extensions/drm-copilot/coverage/lcov.info HEAD extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts
EXIT_CODE: 0
Output Summary: Jest exited 0. Test Suites: 228 passed, 228 total. Tests: 3143 passed, 3143 total. No line begins "FAIL " (TypeScript baseline failure set: empty). claude-blast-radius-derive-core.ts row: % Lines 100, % Branch 97.5 (% Stmts 100, % Funcs 88.88, uncovered line 306). All files: % Lines 96.95, % Branch 90.91. The B42 lcov run printed Found=True for the derivation core (ExecutableLines=380). Stop condition not reached.

## Jest summary lines (verbatim)

```text
Test Suites: 228 passed, 228 total
Tests:       3143 passed, 3143 total
Snapshots:   0 total
Time:        9.136 s
```

## Lines beginning "FAIL "

None. A search of the full Jest log for lines beginning "FAIL " returned no match.

## Coverage table rows (verbatim)

```text
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
All files                                                   |   96.95 |    90.91 |   90.65 |   96.95 |
  claude-blast-radius-derive-core.ts                        |     100 |     97.5 |   88.88 |     100 | 306
```

| File | % Lines | % Branch |
| --- | --- | --- |
| claude-blast-radius-derive-core.ts | 100 | 97.5 |

## B42 changed-lines run (lcov; exit 0)

```text
CHANGED file=extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts Found=True ExecutableLines=380 ChangedExecutable=0 Covered=0 ChangedLinePercent=100.00
```

The lcov matcher found the derivation core's SF record (Found=True). ChangedExecutable is 0 because the
file is unchanged relative to HEAD at baseline.
