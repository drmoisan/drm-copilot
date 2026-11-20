# Final QC — Coverage Delta and Thresholds (P5-T10) (Issue #393)

Timestamp: 2026-07-21T18-45

## Python coverage (baseline P0-T5 vs final P5-T8)

| Metric | Baseline (P0-T5) | Final (P5-T8) | Delta | Gate | Verdict |
|--------|------------------|---------------|-------|------|---------|
| Statements (total) | 12474 | 12252 | -222 (shell_qc.py removed) | — | — |
| Statements missed | 1336 | 1114 | -222 | — | — |
| Line coverage | 89.3% (11138/12474) | 90.9% (11138/12252) | +1.6 pts | >= 85% | PASS |
| Combined TOTAL (term) | 87% | 88% | +1 pt | — | PASS |
| Branches (total) | 4530 | 4446 | -84 (all from shell_qc.py) | — | — |
| Branch partial | 564 | 564 | 0 | — | — |

Branch note: the 84 removed branches belonged entirely to the deleted, fully-unexecuted
`shell_qc.py`. Removing a file whose branches were all missed reduces the branch denominator
and the missing-branch count equally, which raises (never lowers) the branch rate; therefore
no branch regression is possible from this change. Branch coverage remains >= 75%.

Changed-code coverage: the only changed Python production file is
`scripts/dev_tools/fix_all_branches.py` (three command-list literals repointed). Its behavior
is exercised by the 37-test fix_all suites (P3-T2, all passing); no coverage loss on the
changed lines. The deleted `shell_qc.py` contributed 0% coverage and its removal cannot reduce
coverage.

Python verdict: PASS (no regression; line and branch thresholds satisfied; improvement from
removing the untested module).

## Bash coverage (baseline P0-T9 vs final P5-T4/P5-T9)

| Metric | Baseline (P0-T9) | Final (P5-T4/P5-T9) | Verdict |
|--------|------------------|---------------------|---------|
| Bash line coverage | DEFERRED (local kcov absent; CI-sourced) | DEFERRED (CI-sourced at P5-T9) | REMEDIATION-REQUIRED until CI value recorded |

Bash note: kcov is unavailable on the executor host, so both the baseline and final bash
line-coverage numbers are sourced from the green `_shell-coverage.yml` CI run (P5-T9), which is
deferred to the orchestrator/CI. The two new files `scripts/bash/shell-qc.sh` and
`scripts/bash/shell_qc_lib.sh` enter the kcov denominator; their effect on the headline and any
regression versus baseline must be evaluated once the CI value is available. Per the plan, if a
required numeric value is unavailable the verdict is remediation-required, never PASS.

Bash verdict: REMEDIATION-REQUIRED (numeric bash line coverage pending the P5-T9 CI run). This
does not block the Python QA gates, which PASS.

## Overall
- Python: PASS.
- Bash: numeric coverage pending CI (P5-T9); recorded as remediation-required until the CI
  `Bash coverage (lines): NN.N%` value is captured and reconciled here.
