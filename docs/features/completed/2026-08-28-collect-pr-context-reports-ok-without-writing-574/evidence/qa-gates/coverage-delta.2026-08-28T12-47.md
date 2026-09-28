# Phase 8 — Coverage Delta Comparison, Both Runtimes

Timestamp: 2026-08-28T12-47

Task: [P8-T11]

## Sources read

Baseline artifacts:

- `evidence/baseline/ts-coverage.2026-08-28T12-47.md` (`[P0-T8]`)
- `evidence/baseline/py-pytest-coverage.2026-08-28T12-47.md` (`[P0-T12]`)
- `evidence/baseline/py-pr-context-coverage.2026-08-28T12-47.md` (`[P0-T13]`)

Final artifacts:

- `evidence/qa-gates/final-ts-coverage.2026-08-28T12-47.md` (`[P8-T5]`)
- `evidence/qa-gates/final-py-pytest-coverage.2026-08-28T12-47.md` (`[P8-T9]`)
- `evidence/qa-gates/final-py-pr-context-coverage.2026-08-28T12-47.md` (`[P8-T10]`)

## How each number is read

- **TypeScript** line and branch percentages are read directly from the `% Lines` and `% Branch`
  columns of the Jest text reporter, which prints them separately.
- **Python** line and branch percentages are the `percent_statements_covered` and
  `percent_branches_covered` values defined by the Python coverage-reading convention at the head
  of the plan: from the `totals` object for a run-level figure, and from the `summary` object of a
  file's entry under `files` for a per-file figure. They are never derived from the terminal
  columns. The raw terminal columns are carried beside them below.

---

## Overall, per runtime

| Runtime | Metric | Baseline | Post-change | Delta | Regressed |
| --- | --- | --- | --- | --- | --- |
| TypeScript | line | 96.71 | 96.71 | 0.00 | no |
| TypeScript | branch | 90.14 | 90.15 | +0.01 | no |
| Python | line | 92.69433465085639 | 92.70778537611783 | +0.01345 | no |
| Python | branch | 85.27618364418939 | 85.29939046253138 | +0.02321 | no |

Neither runtime regressed at the run level. Both Python run-level values rose.

---

## Per-file, the five production files in scope that existed at baseline

### TypeScript, read from the Jest columns

| File | Line base | Line post | Branch base | Branch post |
| --- | --- | --- | --- | --- |
| `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts` | 100 | **100** | 100 | **87.5** |
| `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | 97.57 | **97.73** | 81.01 | **82.27** |
| `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts` | 93.09 | **93.55** | 87.14 | **87.83** |

### Python, read from the JSON, with the raw terminal columns beside them

| File | Line base | Line post | Branch base | Branch post |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/pr_context/collector.py` | 92.44444444444444 | **93.54838709677419** | 84.88372093023256 | **86.36363636363636** |
| `scripts/dev_tools/pr_context/summary_helpers.py` | 90.9090909090909 | **91.30434782608695** | 81.42857142857143 | **81.42857142857143** |

Raw terminal columns, baseline then post-change:

```
baseline  scripts\dev_tools\pr_context\collector.py           225     17     86     13    90%
post      scripts\dev_tools\pr_context\collector.py           186     12     66      9    92%

baseline  scripts\dev_tools\pr_context\summary_helpers.py     154     14     70      9    88%
post      scripts\dev_tools\pr_context\summary_helpers.py     161     14     70      9    88%
```

`collector.py` shows a smaller `Stmts` and `Branch` denominator post-change because `[P4-T1]`
moved two document-assembly blocks out of it into a new module. That module is measured separately
below, so no measured code left the denominator overall.

---

## The one production file created by this change

| File | Line post | Branch post |
| --- | --- | --- |
| `scripts/dev_tools/pr_context/collector_documents.py` | **91.66666666666667** | **86.36363636363636** |

Raw terminal columns:

```
scripts\dev_tools\pr_context\collector_documents.py      60      5     22      3    90%
```

It has no baseline because it did not exist at baseline, so no regression comparison applies to it.
Both thresholds are met.

---

## Per-file statement required by this task

**`extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`** — post-change line
coverage 100 is at or above 85; post-change branch coverage 87.5 is at or above 75. Line coverage
did not regress, holding at 100. **Branch coverage fell from 100 to 87.5.**

That single decrease is explained and is not a coverage loss on previously covered behaviour. At
baseline the file contained no branching code at all beyond the optional-log spread, so its branch
denominator was trivially satisfied. `[P2-T3]` added the read-back verification helper, which
introduces genuine new branches: the `catch` path, the `error instanceof Error` narrowing, and the
content-inequality path. Line 56 is the one uncovered line — the non-`Error` arm of the
`error instanceof Error` narrowing in the read-back catch, reachable only if the injected
filesystem throws a non-`Error` value, which neither `RealFileSystem` nor any test double does. The
absolute floor the repository sets is 75, and 87.5 is above it. Every one of the three negative
paths this change added is covered by a named test, proved by mutation in `[P5-T1]`: removing the
verification fails all three.

**`extensions/drm-copilot/src/lib/pr-context/collector-output.ts`** — post-change line coverage
97.73 is at or above 85; post-change branch coverage 82.27 is at or above 75. Neither regressed:
line rose 97.57 to 97.73, branch rose 81.01 to 82.27.

**`extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts`** — post-change line coverage
93.55 is at or above 85; post-change branch coverage 87.83 is at or above 75. Neither regressed:
line rose 93.09 to 93.55, branch rose 87.14 to 87.83.

**`scripts/dev_tools/pr_context/collector.py`** — post-change line coverage 93.54838709677419 is at
or above 85; post-change branch coverage 86.36363636363636 is at or above 75. Neither regressed:
line rose 92.44444444444444 to 93.54838709677419, branch rose 84.88372093023256 to
86.36363636363636.

An earlier pass measured this file's branch coverage at 84.84848484848484, a decrease of 0.035
points against its baseline. That was treated as a failure of this task, not a note, and repaired
by covering the changed-file bucketing loop's fall-through exit. Phase 8 was then restarted from
`[P8-T1]`.

**`scripts/dev_tools/pr_context/summary_helpers.py`** — post-change line coverage
91.30434782608695 is at or above 85; post-change branch coverage 81.42857142857143 is at or above
75. Neither regressed: line rose 90.9090909090909 to 91.30434782608695, and branch is exactly
equal to its baseline of 81.42857142857143, which is not a regression.

**`scripts/dev_tools/pr_context/collector_documents.py`** — created by this change, so no baseline
comparison applies. Post-change line coverage 91.66666666666667 is at or above 85 and post-change
branch coverage 86.36363636363636 is at or above 75.

## Verdict

Every production file in scope meets both thresholds. **No file regressed on either metric.** The
one decrease anywhere in this table, the branch figure on
`pr-context-service-call.ts`, is a denominator change caused by adding genuinely branching
verification code to a file that previously had almost none, and the resulting value remains
comfortably above the repository floor.

No placeholder value appears in this artifact.
