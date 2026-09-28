# P6-T12 — Final TypeScript coverage step

Timestamp: 2026-08-30T20-45

Command (from `extensions/drm-copilot`):

```
npm run test:coverage
```

EXIT_CODE: 0

Output Summary:

```
> drm-copilot@1.1.7 test:coverage
> node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary

=============================== Coverage summary ===============================
Statements   : 96.72% ( 44234/45730 )
Branches     : 90.17% ( 6297/6983 )
Functions    : 89.93% ( 1295/1440 )
Lines        : 96.72% ( 44234/45730 )
================================================================================

Test Suites: 203 passed, 203 total
Tests:       2735 passed, 2735 total
Snapshots:   0 total
Time:        5.95 s, estimated 7 s
Ran all test suites.
```

## Acceptance

Satisfied on all three clauses.

1. `EXIT_CODE: 0`.
2. The Jest `Tests:` line, verbatim: `Tests:       2735 passed, 2735 total` — 0 failed. The
   suite line `Test Suites: 203 passed, 203 total` is recorded alongside it.
3. The four `text-summary` percentages:

| Metric | Value | Covered / total |
| --- | --- | --- |
| Statements | 96.72% | 44234/45730 |
| Branches | 90.17% | 6297/6983 |
| Functions | 89.93% | 1295/1440 |
| Lines | 96.72% | 44234/45730 |

Both uniform gates from `.claude/rules/quality-tiers.md` are met: line coverage 96.72% against
the >= 85% floor, branch coverage 90.17% against the >= 75% floor.

## The conditional branch does not apply

The task's conditional branch is scoped to the case where P0-T12 recorded a non-zero baseline
exit code. It did not: `evidence/baseline/ts-coverage.2026-08-30T06-22.md` records
`EXIT_CODE: 0`, and this run also exits 0 with zero failing suites. There is therefore no failing
suite to name and no no-overlap confirmation to perform.

## Comparison against the P0-T12 baseline

All four percentages are identical to the baseline, to the digit and to the covered/total counts:

| Metric | P0-T12 baseline | P6-T12 post-change | Movement |
| --- | --- | --- | --- |
| Statements | 96.72% (44234/45730) | 96.72% (44234/45730) | none |
| Branches | 90.17% (6297/6983) | 90.17% (6297/6983) | none |
| Functions | 89.93% (1295/1440) | 89.93% (1295/1440) | none |
| Lines | 96.72% (44234/45730) | 96.72% (44234/45730) | none |

The denominators are unchanged because this feature changes no file under
`extensions/drm-copilot/src/`. The numerators are unchanged because P4-T6 and P4-T7 add
assertions to existing test files rather than exercising new production paths. The task's
allowance for a small non-decreasing movement — P4-T7 adds a fourth seeded file to the hermetic
push-down tree — was not needed on this run; the identity holds. The acceptance is that no
percentage decreased, which is satisfied.
