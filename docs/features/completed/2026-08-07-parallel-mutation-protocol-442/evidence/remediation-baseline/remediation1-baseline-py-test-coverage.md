# Remediation Cycle 1 — Python Test and Coverage Baseline

Timestamp: 2026-08-09T06-23

Task: [P0-T5]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1
HEAD at capture: a9e2463c
Working tree at capture: clean (no remediation edit applied yet)

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Separate line and branch figures extracted with the companion command
`poetry run coverage json` over the same coverage database (no re-run of the suite).

## Output Summary

- Tests: **3386 passed, 0 failed**, 0 errors, in 12.27s.
- Statements: `num_statements 13922`, `covered_lines 12815`, `missing_lines 1107`.
- Branches: `num_branches 5122`, `covered_branches 4312`, `missing_branches 810`, `num_partial_branches 556`.
- **Line coverage (baseline): 92.04855624191926% (92.0486%)**
- **Branch coverage (baseline): 84.18586489652479% (84.1859%)**
- Combined `percent_covered` as reported by the `TOTAL` row of the term report: 90%. The
  policy thresholds are evaluated against the separate statement and branch percentages above,
  not against the combined figure.

These two numeric values are the comparison basis for [P7-T8]. They match the plan's stated
expected starting point (line 92.05%, branch 84.19%) exactly.

### Per-file coverage of the seven F6 production modules

| File | Stmts | Miss | Branch | BrPart | Cover |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/_parallel_mutation_entries.py` | 13 | 0 | 0 | 0 | 100% |
| `scripts/dev_tools/_parallel_mutation_errors.py` | 34 | 0 | 0 | 0 | 100% |
| `scripts/dev_tools/_parallel_mutation_models.py` | 95 | 0 | 30 | 0 | 100% |
| `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` | 66 | 0 | 32 | 0 | 100% |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` | 67 | 0 | 28 | 0 | 100% |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` | 62 | 0 | 10 | 0 | 100% |
| `scripts/dev_tools/parallel_mutation_protocol.py` | 44 | 0 | 22 | 0 | 100% |

All seven F6 production modules are at 100% line and 100% branch coverage at the
pre-remediation baseline. No placeholder value appears in this artifact.

## Threshold Verdicts at Baseline

| Threshold | Required | Baseline | Verdict |
| --- | --- | --- | --- |
| Line coverage (policy floor) | >= 85% | 92.0486% | PASS |
| Branch coverage (policy floor) | >= 75% | 84.1859% | PASS |
| Line coverage (no-regression figure for this cycle) | >= 92.05% | 92.0486% | this IS the baseline figure |
| Branch coverage (no-regression figure for this cycle) | >= 84.19% | 84.1859% | this IS the baseline figure |
