# TypeScript Test and Coverage Baseline — [P0-T12]

Timestamp: 2026-08-26T08-00
Task: [P0-T12]
Command: `npm test -- --coverage --coverageReporters=text`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6b0c3b38073271d8/extensions/drm-copilot`
EXIT_CODE: 0

## Resolved command

```
> drm-copilot@1.1.4 test
> node run-jest.cjs --coverage --coverageReporters=text
```

## Result block, quoted verbatim

```
Test Suites: 197 passed, 197 total
Tests:       2677 passed, 2677 total
Snapshots:   0 total
Time:        7.118 s
Ran all test suites.
```

**Passed: 2677. Failed: 0.** Test suites: 197 passed of 197 total.

The failed count is 0 established independently of the exit code: Jest prints a `Tests: N failed, M passed, T total` line whenever any test fails, and the line here names only a passed count and a total that equals it. A search of the captured output for `fail` and for `threshold` returned no match, so no test failed and no per-file coverage threshold was violated.

## Coverage table header, fixing the column order

```
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
```

The columns are, in order: statements, branch, functions, lines. The line percentage is the **fourth** numeric column and the branch percentage is the **second**. This is recorded explicitly because the two are easy to transpose, and the plan's thresholds differ between them (>= 85% line, >= 75% branch).

## The three required rows

```
  plan-gate-commands.ts                                     |   96.24 |    85.13 |     100 |   96.24 | 132-139,157-158,161-162,210-211
  plan-gate-rules.ts                                        |   97.71 |    89.55 |     100 |   97.71 | 162-163,273-274,298-299,374-375,430-431
  plan-gate-discrimination.ts                               |     100 |    97.91 |   52.17 |     100 | 199
```

| Module | Line % | Branch % | Statements % | Functions % |
| --- | --- | --- | --- | --- |
| `plan-gate-commands.ts` | **96.24** | **85.13** | 96.24 | 100 |
| `plan-gate-rules.ts` | **97.71** | **89.55** | 97.71 | 100 |
| `plan-gate-discrimination.ts` | **100** | **97.91** | 100 | 52.17 |

All three baseline line percentages are at or above the 85% uniform threshold and all three branch percentages are at or above 75%.

Two of the three are modified by this change: `plan-gate-commands.ts` gains the `taskText` field in [P1-T4], and `plan-gate-discrimination.ts` gains the rule-group call and re-exports in [P3-T5]. `plan-gate-rules.ts` is required by [P3-T5] to remain **unmodified**, so its row is recorded here as the reference that acceptance condition is checked against. The new module `plan-gate-observability.ts` does not yet exist and has no baseline row; [P3-T8] adds its per-file threshold entry to `jest.config.cjs`.

The `plan-gate-discrimination.ts` functions percentage of 52.17 is a pre-existing baseline value, recorded as observed. It is not a line or branch figure and no threshold in this repository's policy applies to it; `.claude/rules/quality-tiers.md` sets uniform gates on line and branch coverage only.

## Enclosing totals

```
All files                                                   |   96.69 |    90.12 |   89.78 |   96.69 |
 src/lib/validate                                           |   97.15 |    91.92 |   94.49 |   97.15 |
```

**Repository-wide TypeScript baseline: 96.69% line, 90.12% branch.** The `src/lib/validate` directory that holds every module this change touches stands at 97.15% line and 91.92% branch. These are the figures the no-regression comparison at [P8-T10] reads.

## Why the explicit `text` reporter is required

The task specifies `--coverageReporters=text` rather than the default or `text-summary`, and the distinction is load-bearing. `text-summary` prints only aggregate totals and would have supplied no per-file row, so the three module percentages this task must record would have had no source in the output. The `text` reporter is what prints the per-file table quoted above.

This is the TypeScript analogue of the reporter problem rule G9 exists to report on the Python side: an acceptance condition asserting over a printed per-file percentage is unfalsifiable when the command's reporter never prints one.

## Exit-code capture method

Output redirected to a file; exit code read from `$?` with no pipe in the chain.

## Output Summary

`npm test -- --coverage --coverageReporters=text` exited 0. **2677 passed, 0 failed** across 197 test suites. Per-file baselines read from the printed `text` table: `plan-gate-commands.ts` 96.24% line / 85.13% branch; `plan-gate-rules.ts` 97.71% line / 89.55% branch; `plan-gate-discrimination.ts` 100% line / 97.91% branch. Enclosing totals: `src/lib/validate` 97.15% line / 91.92% branch; all files 96.69% line / 90.12% branch. No coverage threshold was violated. All values are real numbers read from the terminal table; no placeholder is recorded.
