# [P0-T16] TypeScript test and coverage baseline (Jest)

Timestamp: 2026-08-29T20-53

Command: `cd extensions/drm-copilot && npx jest --coverage --coverageReporters=text --coverageReporters=text-summary`

EXIT_CODE: 0

Output Summary: All 201 Jest suites and all 2722 tests passed with exit code 0. Repository-wide
coverage for the extension is 96.71 percent lines and 90.15 percent branches. The
`claude-customizations.ts` row, which [P5-T3] modifies, stands at 100 percent lines and 93.93 percent
branches. No row exists for `claude-gitignore-merge.ts`, because that file does not yet exist. The
TypeScript test baseline is clean.

## Result lines, verbatim

```
Test Suites: 201 passed, 201 total
Tests:       2722 passed, 2722 total
```

Failed count is 0 on both lines.

## Coverage-table header row, verbatim

Quoted so the column order is fixed for the [P7-T10] comparison:

```
------------------------------------------------------------|---------|----------|---------|---------|-------------------------------------------------------------------------------------
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s                                                                   
------------------------------------------------------------|---------|----------|---------|---------|-------------------------------------------------------------------------------------
```

Column order is: `% Stmts`, `% Branch`, `% Funcs`, `% Lines`, `Uncovered Line #s`. The line
percentage is the **fourth** numeric column, not the first; the first and fourth happen to be equal
on several rows, so the column position is recorded here explicitly to prevent a later misreading.

## `All files` row, verbatim

```
All files                                                   |   96.71 |    90.15 |   89.88 |   96.71 |                                                                                     
```

| Metric | Value |
| --- | --- |
| `% Stmts` | 96.71 |
| `% Branch` | **90.15** |
| `% Funcs` | 89.88 |
| `% Lines` | **96.71** |

Baseline `All files` **line coverage: 96.71 percent**; **branch coverage: 90.15 percent**.

The `text-summary` reporter's aggregate block corroborates those two figures with their underlying
counts:

```
=============================== Coverage summary ===============================
Statements   : 96.71% ( 44024/45518 )
Branches     : 90.15% ( 6273/6958 )
Functions    : 89.88% ( 1288/1433 )
Lines        : 96.71% ( 44024/45518 )
================================================================================
```

Recomputed independently from those counts: lines `100 * 44024 / 45518 = 96.71` percent; branches
`100 * 6273 / 6958 = 90.15` percent. Both agree with the table row.

## `claude-customizations.ts` row, verbatim

The row sits under the ` src/lib/push-down` section of the table:

```
  claude-customizations.ts                                  |     100 |    93.93 |   63.63 |     100 | 129,194                                                                             
```

| Metric | Value |
| --- | --- |
| `% Stmts` | 100 |
| `% Branch` | **93.93** |
| `% Funcs` | 63.63 |
| `% Lines` | **100** |
| Uncovered lines | 129, 194 |

Baseline `claude-customizations.ts` **line coverage: 100 percent**; **branch coverage: 93.93
percent**. This is the file [P5-T3] edits, so these are the changed-code comparison figures for
[P7-T12].

For context, its enclosing directory row is:

```
 src/lib/push-down                                          |   98.57 |    91.03 |    94.9 |   98.57 |                                                                                     
```

## `claude-gitignore-merge.ts` row

**There is as yet no row for `claude-gitignore-merge.ts`.** A search of the full coverage table
returned no match for that filename. This is expected: the module is created by [P4-T1] and does not
exist in the tree at baseline. [P7-T10] records its row for the first time, and that row is the
new-code coverage figure for TypeScript in [P7-T12].

## Reporter-flag rationale

`--coverageReporters=text` is required because the project config sets
`coverageReporters: ["lcov", "text-summary"]` (`extensions/drm-copilot/jest.config.cjs:18`), and
`text-summary` alone prints only the aggregate block shown above, supplying no per-file row. Without
the `text` reporter the `claude-customizations.ts` figures could not be read at all.

## Prohibited flags

None of `--passWithNoTests`, `--onlyChanged`, or `--lastCommit` was used. Each converts zero
discovered tests into a green run (issue #423) and all three are prohibited throughout this plan.

## Observed-state clause

The observed-state clause was **not** triggered. The command exited 0, so no `ExpectedExitCode:` is
recorded (an absent expectation defaults to 0) and the `BLOCKED: TypeScript baseline not clean`
branch does not apply.
