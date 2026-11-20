# Phase 4 — Coverage Delta Record (P4-T12)

Timestamp: 2026-08-25T22-34

Task: [P4-T12]
Class: **record-only task.** This task executes no command of its own, so per the plan's evidence
accounting rule it records `Timestamp:` and the substantive content the task text prescribes, and
carries **no** `Command:` row and **no** `EXIT_CODE:` row. Each of the six values below is cited to
the task that measured it and to that task's own artifact, so every command and exit code remains
auditable one hop away.

Working directory for every cited command: the resolved repository root
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad22fbcf94d2d5359` (resolved by P0-T2).

---

## Why all six values originate in a JSON report

The terminal coverage reporter prints **neither** policy metric when branch measurement is on: its
`Cover` cell is the combined statements-plus-branches ratio and its `BrPart` cell is the
partial-branch count rather than the missing-branch count. Line coverage
(`totals.percent_statements_covered`) and branch coverage (`totals.percent_branches_covered`) are
therefore read from a `--cov-report=json` report in all three cases. No value below is a
placeholder and no value below is derived from a terminal `TOTAL` row.

---

## The six values

### Baseline pair — read from the [P0-T8] artifact

Source: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/corrected-coverage-command-repro.md`,
command 2 of 4, which recorded the printed line `14953 92.6302414231258 85.21485797523671` from
`artifacts/python/coverage.json` with `EXIT_CODE: 0`.

| Metric | Baseline value |
| --- | --- |
| Line coverage | **92.6302414231258** |
| Branch coverage | **85.21485797523671** |

### Post-change pair — read from the [P4-T5] artifact

Source: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/workflow-command-coverage-json.md`,
command 2 of 4, which recorded the printed line `15014 92.64686292793392 85.2161278605158` from
`artifacts/python/coverage.json` with `EXIT_CODE: 0`.

| Metric | Post-change value |
| --- | --- |
| Line coverage | **92.64686292793392** |
| Branch coverage | **85.2161278605158** |

### New-code pair for the added module — read from the [P3-T10] artifact

Source: `docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/qa-gates/checker-module-coverage.md`,
command 2 of 2, which recorded the printed line `96.72131147540983 85.71428571428571` from
`artifacts/python/checker-coverage.json` with `EXIT_CODE: 0`. The measured module is the one this
work item adds, `scripts/dev_tools/check_python_coverage_thresholds.py`, targeted by the
importable dotted form `--cov=scripts.dev_tools.check_python_coverage_thresholds`.

| Metric | New-module value |
| --- | --- |
| Line coverage | **96.72131147540983** |
| Branch coverage | **85.71428571428571** |

---

## Consolidated delta table

| Measurement | Line coverage | Branch coverage | Source task | Source artifact |
| --- | --- | --- | --- | --- |
| Baseline | 92.6302414231258 | 85.21485797523671 | [P0-T8] | `evidence/baseline/corrected-coverage-command-repro.md` |
| Post-change | 92.64686292793392 | 85.2161278605158 | [P4-T5] | `evidence/qa-gates/workflow-command-coverage-json.md` |
| New module (added code) | 96.72131147540983 | 85.71428571428571 | [P3-T10] | `evidence/qa-gates/checker-module-coverage.md` |

### Delta against baseline

| Metric | Baseline | Post-change | Delta | Direction |
| --- | --- | --- | --- | --- |
| Line coverage | 92.6302414231258 | 92.64686292793392 | **+0.01662150480812** | increase |
| Branch coverage | 85.21485797523671 | 85.2161278605158 | **+0.00126988527909** | increase |

Both policy metrics **increased** against baseline. The statement denominator rose from 14953 to
15014 — a difference of 61, exactly the statement count of the added module recorded by P3-T10 —
and the added module's own line coverage of 96.72131147540983% is well above the repository
aggregate, which is why the aggregate moved up rather than down.

---

## Acceptance

| Condition | Result |
| --- | --- |
| All six values are numeric with no placeholder | **PASS** — 92.6302414231258, 85.21485797523671, 92.64686292793392, 85.2161278605158, 96.72131147540983, 85.71428571428571 |
| The post-change line value is at or above 85 | **PASS** — 92.64686292793392 >= 85 |
| The post-change branch value is at or above 75 | **PASS** — 85.2161278605158 >= 75 |
| The post-change pair is not lower than the baseline pair (line) | **PASS** — 92.64686292793392 >= 92.6302414231258 |
| The post-change pair is not lower than the baseline pair (branch) | **PASS** — 85.2161278605158 >= 85.21485797523671 |
| No decrease against baseline, so the phase does not halt for remediation | **PASS** — both metrics increased |

Supplementary, against the uniform thresholds in `.claude/rules/quality-tiers.md`: the new module's
own line coverage of 96.72131147540983% is at or above the 85% floor and its branch coverage of
85.71428571428571% is at or above the 75% floor, so the added code does not rely on the aggregate
to clear either gate.

Verdict: **PASS.**
