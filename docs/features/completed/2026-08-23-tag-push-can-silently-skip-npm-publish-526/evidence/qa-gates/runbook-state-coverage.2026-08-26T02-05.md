# Runbook State Coverage — P6-T2

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position, as the plan's "Evidence filename timestamps" rule
directs. The path prefix and base name are unchanged.

Command: `grep -nE "NO_RUN|RUN_FAILED|STEP_SKIPPED|STEP_MISSING|UNRESOLVED|VERSION_CONSUMED_ELSEWHERE|^### (Precondition|Human decision)" docs/engineering/missed-npm-publish.runbook.md`

EXIT_CODE: 0

Target file: `docs/engineering/missed-npm-publish.runbook.md`

## Located items — nine, each a single-line literal

Every item below is a single-line literal. No item is a multi-word prose search. The line number
recorded for each state token is the line of that token's own dedicated section heading in the
runbook; the "first occurrence" column records the earliest line on which the token appears anywhere
in the file, which is its row in the state summary table.

### Six state tokens

| # | Item | Section-heading line | First-occurrence line |
|---|---|---|---|
| 1 | `NO_RUN` | 35 | 18 |
| 2 | `RUN_FAILED` | 56 | 19 |
| 3 | `STEP_SKIPPED` | 69 | 20 |
| 4 | `STEP_MISSING` | 81 | 21 |
| 5 | `UNRESOLVED` | 93 | 22 |
| 6 | `VERSION_CONSUMED_ELSEWHERE` | 106 | 23 |

### Three heading literals

| # | Item | Line |
|---|---|---|
| 7 | `### Precondition 1 — version resolves nowhere` | 139 |
| 8 | `### Precondition 2 — no successful run for the tag` | 151 |
| 9 | `### Human decision — consumed version disposition` | 171 |

Output Summary: All nine items located. Six state tokens each have a dedicated recovery section at
lines 35, 56, 69, 81, 93, and 106, and each also appears in the state summary table at lines 18
through 23. The three mandated heading literals appear verbatim, each on its own single line, at
lines 139, 151, and 171. Zero items missing. Each heading was additionally confirmed with an
anchored whole-line match (`^### ...$`), so no item was located by a partial or wrapped match.
