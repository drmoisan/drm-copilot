# Remediation Cycle 1 — Final QA: Python Tests and Coverage

Timestamp: 2026-08-09T08-58

Task: [P7-T4]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Separate line and branch figures extracted with the companion command
`poetry run coverage json` over the same coverage database (no re-run of the suite).

## Output Summary

- Tests: **3407 passed, 0 failed**, 0 errors, in 10.79s.
- Statements: `num_statements 13923`, `covered_lines 12816`, `missing_lines 1107`.
- Branches: `num_branches 5124`, `covered_branches 4314`, `missing_branches 810`.
- **Post-change line coverage: 92.04912734324499% (92.0491%)**
- **Post-change branch coverage: 84.19203747072599% (84.1920%)**
- Combined `TOTAL` row as printed by the term report: 90%. The policy thresholds are evaluated
  against the separate statement and branch percentages above, not the combined figure.

Test-count delta: baseline 3386 -> **3407**, a net **+21**. The gross change is larger: 62 test cases
were added across the five new modules and the R2 binding tests, while 41 cases were removed from the
two edited modules by the class relocations (whose cases now run from their new homes) and the three
authorized replacements. `<FEATURE>/evidence/regression-testing/remediation1-scenario-inventory.md`
accounts for every pre-remediation test name.

## Per-File Coverage of the Seven F6 Production Modules

| File | Stmts | Miss | Branch | BrPart | Line cover | Branch cover |
| --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/parallel_mutation_protocol.py` | 49 | 0 | 24 | 0 | **100%** | **100%** |
| `scripts/dev_tools/_parallel_mutation_models.py` | 93 | 0 | 30 | 0 | **100%** | **100%** |
| `scripts/dev_tools/_parallel_mutation_entries.py` | 13 | 0 | 0 | 0 | **100%** | n/a (no branch) |
| `scripts/dev_tools/_parallel_mutation_errors.py` | 34 | 0 | 0 | 0 | **100%** | n/a (no branch) |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` | 62 | 0 | 10 | 0 | **100%** | **100%** |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` | 65 | 0 | 28 | 0 | **100%** | **100%** |
| `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` | 66 | 0 | 32 | 0 | **100%** | **100%** |

**All seven F6 production modules remain at 100% line and 100% branch coverage.** No placeholder
value appears in this artifact.

Statement-count changes reflect this cycle's edits: `parallel_mutation_protocol.py` rose 44 -> 49
(the negative-`current_cohort` guard, the `crosses_pinned` computation, the `cohort_offset` branch,
and the union in `decide_admission`), with branches 22 -> 24; `_parallel_mutation_models.py` fell
95 -> 93 and `_parallel_orchestrator_state_mutations.py` fell 67 -> 65, each by the two deleted local
op-classification tuple declarations replaced by imports ([P6-T1], [P6-T2]). Every added statement
and every added branch is covered.

## Threshold Verdicts

| Threshold | Required | Measured | Verdict |
| --- | --- | --- | --- |
| Line coverage (policy floor) | >= 85% | 92.0491% | **PASS**, margin +7.05 pp |
| Branch coverage (policy floor) | >= 75% | 84.1920% | **PASS**, margin +9.19 pp |
| Line coverage (no regression below baseline) | >= 92.05% | 92.0491% | **PASS** — see the note below |
| Branch coverage (no regression below baseline) | >= 84.19% | 84.1920% | **PASS** |

Note on the line figure: the exact baseline was 92.04855624191926% and the exact post-change figure
is 92.04912734324499%, a **delta of +0.00057 pp — an INCREASE, not a regression**. Both round to
92.05% at two decimal places, so the "`>= 92.05%`" threshold is met on the exact comparison that
matters. Branch coverage rose from 84.18586489652479% to 84.19203747072599%, a delta of
**+0.00617 pp**.

**Both coverage axes improved. There is no coverage regression on either axis.**
