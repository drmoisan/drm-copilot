# Baseline — Per-Changed-File Coverage ([P0-T9])

Timestamp: 2026-08-25T09-28

Command: node "$SCRATCH/lcov-extract.cjs" extensions/drm-copilot/coverage/lcov.info src/lib/potential-to-issue/gh-client.ts src/lib/potential-to-issue/potential-to-issue-service-call.ts src/mcp-tools.ts src/repo-automation-service-contract.ts

EXIT_CODE: 0

`$SCRATCH` is the session scratchpad directory
`C:\Users\DANMOI~1\AppData\Local\Temp\claude\C--Users-DanMoisan-repos-drm-copilot-wt-2026-08-23T20-24\52ac2030-ba56-47de-a115-b912d0d4409c\scratchpad`.
The script is a read-only lcov parser held outside the repository tree; see the Method Note below.
The same figures can be read directly from the report without it — each file's `LF`, `LH`, `BRF`, and
`BRH` counters are quoted verbatim in the spot-check section below.

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a38eff9588c69b6ec`
Branch: `bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`
Source report: `extensions/drm-copilot/coverage/lcov.info`, produced by the [P0-T8] run of
`npm --prefix extensions/drm-copilot run test:coverage` (EXIT_CODE 0).

## Output Summary

Four rows, one per pre-change file named in [P0-T9]. Every line and branch value is a real number read
from the lcov report; no value is a placeholder.

| # | File | Line coverage | Lines hit/found | Branch coverage | Branches hit/found |
| --- | --- | --- | --- | --- | --- |
| 1 | `extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts` | 100.00% | 330 / 330 | 79.31% | 23 / 29 |
| 2 | `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` | 100.00% | 209 / 209 | 83.33% | 15 / 18 |
| 3 | `extensions/drm-copilot/src/mcp-tools.ts` | 92.50% | 296 / 320 | 82.76% | 48 / 58 |
| 4 | `extensions/drm-copilot/src/repo-automation-service-contract.ts` | 0.00% | 0 / 176 | 0.00% | 0 / 1 |

Percentages are computed as `LH / LF` and `BRH / BRF` from the lcov counters, rounded to two decimal
places.

## Verbatim Extraction Output

```
src/lib/potential-to-issue/gh-client.ts	lines=100.00% (330/330)	branches=79.31% (23/29)
src/lib/potential-to-issue/potential-to-issue-service-call.ts	lines=100.00% (209/209)	branches=83.33% (15/18)
src/mcp-tools.ts	lines=92.50% (296/320)	branches=82.76% (48/58)
src/repo-automation-service-contract.ts	lines=0.00% (0/176)	branches=0.00% (0/1)
```

## Raw lcov Counters (spot-check)

The extraction was cross-checked against the raw report. For the two `potential-to-issue` files:

```
SF:src\lib\potential-to-issue\gh-client.ts
LF:330
LH:330
BRF:29
BRH:23
```

Each of the four target files resolves to exactly one `SF:` record in `lcov.info`, at report lines
25018, 25406, 5309, and 9343 respectively, so no row above is the result of an ambiguous path match.
The report writes `SF:` paths with backslash separators; the extraction normalizes separators before
matching.

## Observations Bearing on Later Phases

- **Rows 1 and 2 are the files the fix will modify most.** Both are at 100.00% line coverage today,
  so any uncovered line added by Phases 2 through 4 will show as a line-coverage regression on a
  changed file. `.claude/rules/general-unit-test.md` makes coverage regression on changed lines a
  blocking condition.
- **Row 1 branch coverage, 79.31%, is the narrowest margin among the gated files.** It clears the
  75% floor by 4.31 points. [P4-T6] adds a per-file threshold entry of 75 branches for this file, so
  the added `repo` selector branches must be covered by the [P1-T2], [P4-T1], and [P4-T2] tests or
  this entry will fail.
- **Row 4 reports 0.00% on both metrics.** `repo-automation-service-contract.ts` is an interface-only
  contract file; its type declarations are erased at transpile time and it is never executed, so it
  legitimately reports zero executable coverage. `.claude/rules/general-unit-test.md` and
  `.claude/rules/typescript.md` both permit interface/type-only files with no executable behavior to
  be omitted from the threshold gate; this is a clarification and does not lower any threshold. This
  is the file [P4-T6] records as remaining outside the per-file threshold map. Adding the optional
  `targetRepository` property in [P3-T6] cannot change this row, because a property declaration on an
  interface emits no executable statement.
- **Row 3 is at 92.50% lines and 82.76% branches.** [P3-T7] adds a conditional spread to the
  projection helper in this file, which introduces a new branch; [P4-T4] and [P4-T5] cover both
  arms of it.

## Baseline Overall Figures for Reference

Carried from [P0-T8] so the [P6-T5] delta comparison has both scopes in one place:

- Overall line coverage: 96.66% (43084 / 44571)
- Overall branch coverage: 90.05% (6128 / 6805)

## Method Note

`npm --prefix extensions/drm-copilot run test:coverage` pins `--coverageReporters=lcov
--coverageReporters=text-summary`. The `text-summary` reporter emits whole-project totals only and no
per-file rows, so the per-file figures above are read from the `lcov` reporter output of that same
run rather than from a separate coverage execution. No additional test run was performed for this
task. The extraction script is a throwaway read-only parser held outside the repository tree in the
session scratchpad; it writes nothing and is not part of the change set.
