# Final QC — coverage delta, baseline against post-change — [P8-T10]

Timestamp: 2026-08-26T10-38
Task: [P8-T10]
Command: read of the four recorded artifacts named below; no new command was executed for this task
EXIT_CODE: 0

Output Summary: for Python the baseline TOTAL is 91% and the post-change TOTAL is 91%, an arithmetic difference of **0 percentage points**, with the new module `plan_gate_observability.py` at **96%**. For TypeScript the baseline all-files line coverage is 96.69% and the post-change all-files line coverage is 96.71%, an arithmetic difference of **+0.02 percentage points**, with the new module `plan-gate-observability.ts` at **98.38% line / 91.91% branch**. The post-change percentage is not below the baseline percentage for either runtime. No placeholder value is recorded anywhere in this artifact.

## Sources

Every figure below is read from a recorded artifact, not re-measured here.

| Runtime | Baseline artifact | Post-change artifact |
| --- | --- | --- |
| Python | `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/baseline/python-test-coverage.2026-08-24T00-00.md` ([P0-T7]) | `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/python-test-final.2026-08-24T00-00.md` ([P8-T4]) |
| TypeScript | `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/baseline/typescript-test-coverage.2026-08-24T00-00.md` ([P0-T12]) | `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/typescript-test-final.2026-08-24T00-00.md` ([P8-T9]) |

The new-module figures are read from `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/python-new-module-coverage.2026-08-24T00-00.md` ([P8-T5]) and from the [P8-T9] artifact respectively.

## Python

| Quantity | Value |
| --- | --- |
| Baseline TOTAL coverage ([P0-T7]) | 91% |
| Post-change TOTAL coverage ([P8-T4]) | 91% |
| Arithmetic difference | 91 - 91 = **0** percentage points |
| Post-change below baseline? | **No** |
| New-module coverage, `scripts/dev_tools/plan_gate_observability.py` ([P8-T5]) | **96%** |
| New-module threshold | >= 85 |

Supporting counts: the baseline run reported 4151 passed, 0 failed, 5 skipped over 15014 statements and 5506 branches. The post-change run reported 4195 passed, 0 failed, 5 skipped over 15180 statements and 5576 branches. The statement count rose by 166 and the branch count by 70, which is the new module plus the seam additions, and the TOTAL percentage held at 91.

Per-module comparison for the files this change touches:

| Module | Baseline | Post-change | Direction |
| --- | --- | --- | --- |
| `plan_gate_commands.py` | 100% | 98% | down 2 points, see note |
| `plan_gate_coverage.py` | 100% | 100% | unchanged |
| `plan_gate_discrimination.py` | 94% | 95% | up 1 point |
| `plan_gate_observability.py` | not present at baseline | 96% | new |

Note on `plan_gate_commands.py`: [P1-T2] added the `task_text` field and its window-close assignment to that module, and the post-change row reports 99 statements with 1 missed and 36 branches with 2 partial, giving 98%. That is above the 85 line threshold and above the 75 branch threshold, and the module-level movement does not reduce the TOTAL, which held at 91.

## TypeScript

| Quantity | Value |
| --- | --- |
| Baseline all-files line coverage ([P0-T12]) | 96.69% |
| Post-change all-files line coverage ([P8-T9]) | 96.71% |
| Arithmetic difference | 96.71 - 96.69 = **+0.02** percentage points |
| Baseline all-files branch coverage ([P0-T12]) | 90.12% |
| Post-change all-files branch coverage ([P8-T9]) | 90.14% |
| Arithmetic difference | 90.14 - 90.12 = **+0.02** percentage points |
| Post-change below baseline? | **No**, on either measure |
| New-module coverage, `extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts` ([P8-T9]) | **98.38% line / 91.91% branch** |
| New-module thresholds | line >= 85, branch >= 75 |

Per-file comparison for the files this change touches:

| File | Baseline line / branch | Post-change line / branch | Direction |
| --- | --- | --- | --- |
| `plan-gate-commands.ts` | 96.24 / 85.13 | 95.93 / 84.88 | down 0.31 line, down 0.25 branch, see note |
| `plan-gate-rules.ts` | 97.71 / 89.55 | 97.71 / 89.55 | unchanged, as [P3-T5] evidenced |
| `plan-gate-discrimination.ts` | 100 / 97.91 | 100 / 98.14 | line unchanged, branch up 0.23 |
| `plan-gate-observability.ts` | not present at baseline | 98.38 / 91.91 | new |

Note on `plan-gate-commands.ts`: [P1-T4] added the `taskText` field and its window-close assignment to that file, which is the same additive change made on the Python side. Both figures remain above their thresholds (95.93 against 85, 84.88 against 75), and the enclosing `src/lib/validate` directory rose from 97.15 / 91.92 to 97.19 / 91.89 on line coverage while its branch figure moved by 0.03 of a point. The all-files totals, which are the figures this task compares, both rose.

Enclosing-directory comparison:

| Scope | Baseline line / branch | Post-change line / branch |
| --- | --- | --- |
| `src/lib/validate` | 97.15 / 91.92 | 97.19 / 91.89 |
| All files | 96.69 / 90.12 | 96.71 / 90.14 |

## Verdict

**PASS.** Both runtimes record a real numeric baseline, a real numeric post-change value, an explicit arithmetic difference, and a real numeric new-module value. Neither post-change total is below its baseline: Python is level at 91% and TypeScript rose by 0.02 of a point on both line and branch coverage. No placeholder value such as `UNVERIFIED` appears in this artifact.
