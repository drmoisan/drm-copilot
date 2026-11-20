# Determinism Comparison, Runs A, B, C (P6-T11) — partial: run C pending

Timestamp: 2026-10-02T08-45
Command: comparison of the values recorded in `evidence/qa-gates/final-pwsh-coverage-run-a.2026-10-02T08-45.md` (P6-T5) and `evidence/qa-gates/final-pwsh-coverage-run-b.2026-10-02T08-45.md` (P6-T8); `cmp artifacts/ci/run-36983551836/cx.txt artifacts/ci/run-36984586891/cx.txt` (exit 0, no output). Run C (P6-T9, P6-T10) is an operator-run blocker (classification row P6-T9, P6-T10) and has not run.
EXIT_CODE: 0
Output Summary: A == B on all three values (LINE_TOTAL=15738, FILES=174, KEYS_SHA256=6a803e82ff66245e1dd760c850bc8e3636465509d6540193b6de39b4235d5953). Run C pending; the three-way acceptance condition cannot be evaluated, so P6-T11 stays unchecked and AC-01 stays unchecked.

| Run | Source | LINE_TOTAL | FILES | KEYS_SHA256 |
| --- | --- | --- | --- | --- |
| A | CI run 36983551836 (a987ebfb) | 15738 | 174 | 6a803e82ff66245e1dd760c850bc8e3636465509d6540193b6de39b4235d5953 |
| B | CI run 36984586891 (a987ebfb) | 15738 | 174 | 6a803e82ff66245e1dd760c850bc8e3636465509d6540193b6de39b4235d5953 |
| C | pending (operator run from a different current directory) | pending | pending | pending |

- Acceptance (AC-01): three identical KEYS_SHA256 values and three identical LINE_TOTAL values. Not yet evaluable (run C pending). A and B agree.
- Operator commands for run C are recorded in `evidence/other/plan-deviations.2026-10-02T07-45.md` (DEV-P6-T9-T10).
