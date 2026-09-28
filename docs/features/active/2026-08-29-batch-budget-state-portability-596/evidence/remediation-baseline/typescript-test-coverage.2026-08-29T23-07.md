# TypeScript test coverage baseline (remediation cycle 1)

Timestamp: 2026-08-30T01-00

Task: [P0-T16]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Command (plan command text, quoted verbatim):

```
cd extensions/drm-copilot && npx jest --coverage --coverageReporters=text --coverageReporters=text-summary
```

Executed with the working directory set to the absolute path `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/extensions/drm-copilot`. The plan states the `cd` operand worktree-relative; the absolute path above is the form actually used.

EXIT_CODE: 0

ExpectedExitCode: 0

## Result lines, verbatim

```
Test Suites: 203 passed, 203 total
Tests:       2733 passed, 2733 total
```

Failed count is 0 in both: Jest omits the `failed` segment when the failure count is zero, and the run exited 0.

## Coverage-table header row, verbatim

Quoted so the column order is fixed and the numeric readings below are unambiguous:

```
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
```

Column order is `% Stmts`, `% Branch`, `% Funcs`, `% Lines`, `Uncovered Line #s`. Note that `% Branch` precedes `% Funcs` and `% Lines`, so `% Lines` is the fourth numeric column, not the last.

## Asserted rows

### `All files`

Row, verbatim:

```
All files                                                   |   96.72 |    90.16 |   89.93 |   96.72 |
```

| Metric | Value |
| --- | --- |
| **% Lines** | **96.72** |
| **% Branch** | **90.16** |
| % Stmts | 96.72 |
| % Funcs | 89.93 |

### `claude-gitignore-merge.ts`

Row, verbatim (from the `src/lib/push-down` package block):

```
  claude-gitignore-merge.ts                                 |   98.78 |       90 |     100 |   98.78 | 151-152
```

| Metric | Value |
| --- | --- |
| **% Lines** | **98.78** |
| **% Branch** | **90** |
| % Stmts | 98.78 |
| % Funcs | 100 |
| Uncovered Line #s | 151-152 |

Both values are real numbers read from the printed per-file row, not placeholders.

The uncovered range `151-152` is the `appendManagedBlock` trailing-blank loop at `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts:151-152`. This is advisory finding N-6, which the plan places explicitly out of scope. It sits in the same file as the D-2 edit but on the no-opening-sentinel path, which D-2 does not touch, so it is expected to remain uncovered after the remediation. Consistent with that, no task in this plan asserts a rise in this file's line percentage; the acceptance is the 85 percent floor only.

## Why `--coverageReporters=text` is required

`extensions/drm-copilot/jest.config.cjs:18` reads:

```javascript
  coverageReporters: ["lcov", "text-summary"],
```

`text-summary` prints only the aggregate `Coverage summary` block and emits no per-file row. Without the explicit `--coverageReporters=text` on the command line, the per-file `claude-gitignore-merge.ts` percentage this acceptance condition demands would never be printed and the condition could not be read from the output. Passing `text` is what produces the table quoted above.

For completeness, the aggregate block that `text-summary` contributed:

```
=============================== Coverage summary ===============================
Statements   : 96.72% ( 44232/45728 )
Branches     : 90.16% ( 6296/6983 )
Functions    : 89.93% ( 1295/1440 )
Lines        : 96.72% ( 44232/45728 )
================================================================================
```

The aggregate line and branch percentages agree with the `All files` table row, as expected.

## Armed threshold for the target file

`extensions/drm-copilot/jest.config.cjs:213-216` reads:

```javascript
    "./src/lib/push-down/claude-gitignore-merge.ts": {
      lines: 85,
      branches: 75,
    },
```

The threshold is armed at 85 lines and 75 branches for exactly the file this remediation edits. A violation would print a `coverage threshold for` line and fail the run. **No such line appeared in the output**, and the observed values of 98.78 lines and 90 branches both clear their thresholds with margin.

## Disposition

`EXIT_CODE: 0` was observed, so the TypeScript coverage baseline is clean and the `BLOCKED: TypeScript baseline not clean` branch is not taken. Under this task's stated terms a non-zero exit would have been recorded with `ExpectedExitCode:` set to that same integer, stated to be pre-existing, and reported as blocked. `ExpectedExitCode: 0` is recorded, which renders identically to omitting the field.

These four numbers are the pre-change coverage baseline against which the Phase 5 final-QC coverage capture measures regression. Under `.claude/rules/typescript.md` line 52, coverage regression on changed lines is a blocking finding.

## Output Summary

`npx jest --coverage --coverageReporters=text --coverageReporters=text-summary` exited 0 with `Test Suites: 203 passed, 203 total` and `Tests: 2733 passed, 2733 total`, zero failures. Coverage-table header quoted to fix column order. `All files`: **% Lines 96.72**, **% Branch 90.16**. `claude-gitignore-merge.ts`: **% Lines 98.78**, **% Branch 90**, uncovered lines 151-152 (advisory N-6, out of scope, expected to stay uncovered). Both clear the armed per-file thresholds of 85 lines and 75 branches at `jest.config.cjs:213-216`; no `coverage threshold for` line was printed. No BLOCKED branch taken.
