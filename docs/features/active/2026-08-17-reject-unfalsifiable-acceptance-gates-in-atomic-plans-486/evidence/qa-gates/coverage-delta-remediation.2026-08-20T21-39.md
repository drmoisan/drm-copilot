# Remediation Cycle 3 — Baseline versus Final Coverage Delta (Issue #486)

Timestamp: 2026-08-20T21-39
Task: [P4-T9]

Sources compared:

- Python: [P0-T3] `evidence/remediation-baseline/python-test.2026-08-20T21-39.md` (single-module,
  pre-split) against [P4-T4] `evidence/qa-gates/python-test-final.2026-08-20T21-39.md`
  (two-module combined, post-split).
- TypeScript: [P0-T4] `evidence/remediation-baseline/typescript-test.2026-08-20T21-39.md` against
  [P4-T8] `evidence/qa-gates/typescript-test-final.2026-08-20T21-39.md`.

Every row must show a non-negative delta. Percentages are carried to two decimals; deltas are stated
in percentage points (pp).

## Python gate logic — [P0-T3] single module versus [P4-T4] combined pair

| Metric | Baseline (pre-split, `plan_gate_discrimination.py` alone) | Final (post-split, both modules) | Delta | Verdict |
| --- | --- | --- | --- | --- |
| Line coverage | 98.28% (171/174) | **98.31% (174/177)** | **+0.03 pp** | PASS |
| Branch coverage | 90.54% (67/74) | **90.54% (67/74)** | **0.00 pp** | PASS |
| Missed statements (absolute) | 3 | 3 | 0 | PASS |
| Partial branches (absolute) | 7 | 7 | 0 | PASS |

Per-module breakdown of the post-split figure, for reference:

| Module | Line % | Branch % |
| --- | --- | --- |
| `scripts/dev_tools/plan_gate_coverage.py` (new) | 100.00% (48/48) | 100.00% (22/22) |
| `scripts/dev_tools/plan_gate_discrimination.py` | 97.67% (126/129) | 86.54% (45/52) |

The absolute miss counts are identical before and after, so no line or branch moved from covered to
uncovered. The line percentage rose because the extracted module contributes 3 additional covered
statements (its own imports and constants) to the denominator with zero additional misses.

## Python repo-wide (`--cov=scripts --cov-branch`)

| Metric | Baseline floor (recorded in remediation inputs and `policy-audit.2026-08-20T17-11.md` line 211) | Final (measured this session) | Delta | Verdict |
| --- | --- | --- | --- | --- |
| Line coverage | 92.59% (13815/14920) | **92.60% (13818/14923)** | **+0.01 pp** | PASS |
| Branch coverage | 85.16% (4667/5480) | **85.16% (4667/5480)** | **0.00 pp** | PASS |

Measured with `poetry run pytest -q --cov=scripts --cov-branch --cov-report=term` followed by
`poetry run coverage json`, which reports `percent_statements_covered = 92.59532265630236` and
`percent_branches_covered = 85.16423357664233` against the baseline's 92.5938% and 85.1642%.

## TypeScript gate modules — [P0-T4] versus [P4-T8]

| Module | Metric | Baseline | Final | Delta | Verdict |
| --- | --- | --- | --- | --- | --- |
| `src/lib/validate/plan-gate-rules.ts` | Line | 97.71% (427/437) | **97.71% (427/437)** | **0.00 pp** | PASS |
| `src/lib/validate/plan-gate-rules.ts` | Branch | 89.55% (60/67) | **89.55% (60/67)** | **0.00 pp** | PASS |
| `src/lib/validate/plan-gate-discrimination.ts` | Line | 100.00% (269/269) | **100.00% (269/269)** | **0.00 pp** | PASS |
| `src/lib/validate/plan-gate-discrimination.ts` | Branch | 97.92% (47/48) | **97.92% (47/48)** | **0.00 pp** | PASS |

Repo-wide TypeScript coverage is likewise unchanged at 96.65% statements (42960/44447), 90%
branches (6099/6776), 89.65% functions (1257/1402), and 96.65% lines. All four per-module values are
byte-identical to baseline because no TypeScript file was modified in this cycle.

## Verdict

**Every row shows a non-negative delta: PASS.** No coverage regression is introduced by the R6
module split in either runtime. Two rows improve marginally (combined Python gate-logic line
coverage and Python repo-wide line coverage), and all remaining rows are exactly unchanged. No
`coverageThreshold` was weakened, no coverage `exclude` was added for a production path, and both
new-code figures — 100.00% line and 100.00% branch on `scripts/dev_tools/plan_gate_coverage.py` —
exceed the uniform 85% / 75% thresholds.
