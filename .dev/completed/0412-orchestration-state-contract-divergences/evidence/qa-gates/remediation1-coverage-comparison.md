# Coverage Comparison Against Recorded Baselines (Issue #412, Cycle 1)

Timestamp: 2026-07-25T20-22

Command: no new command executed. This task compares values already recorded in the following
artifacts:

- Source (baseline): `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/evidence/remediation-baseline/poshqc-test-baseline.md` ([P0-T5])
- Source (post-change PowerShell): `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/evidence/qa-gates/remediation1-phase2-poshqc-test.md` ([P2-T4])
- Source (Python): `docs/features/active/2026-07-25-orchestration-state-contract-divergences-412/evidence/qa-gates/remediation1-pytest-guard.md` ([P2-T6])

Extraction commands used to produce those artifacts (recorded here for traceability):

- PowerShell: `pwsh -NoProfile -Command "... [xml](Get-Content artifacts/pester/powershell-coverage.xml) ..."` reading `report/counter` and `report/package/sourcefile/counter` nodes.
- Python: `poetry run python -c "import coverage; cov = coverage.Coverage(); cov.load(); ..."` reading the loaded coverage data.

EXIT_CODE: 0

## (a) PowerShell overall coverage

| Metric | Recorded baseline | Post-change ([P2-T4]) | Delta |
|---|---|---|---|
| Command coverage (`INSTRUCTION`) | 89.73% (2945 / 3282) | **89.73% (2945 / 3282)** | **0.00 pp** |
| Line coverage (`LINE`) | 90.26% (2159 / 2392) | **90.26% (2159 / 2392)** | **0.00 pp** |

Post-change overall line coverage of 90.26% is above the >= 85% policy floor. No regression.

The [P0-T5] baseline run measured 2944 / 3281 commands (89.73%), one command lower in both numerator
and denominator than the recorded baseline; the post-change run returns to 2945 / 3282 because the
membership test adds one analyzed command and that command is covered.

## (b) `OrchestratorState.psm1` per-file coverage

| Metric | Recorded baseline | Post-change ([P2-T4]) | Delta |
|---|---|---|---|
| Commands | 96.64% (144 / 149) | **96.67% (145 / 150)** | **+0.03 pp** |
| Lines | 97.17% (103 / 106) | **97.17% (103 / 106)** | 0.00 pp |

No regression on the changed file. The analyzed command count rose by one because
`@('pending', 'blocked', 'blocked_remediation_loop_limit') -contains $field.Value` contributes one
more command than the two-literal comparison it replaced. The covered count rose by the same one,
so the changed line is fully exercised — by the [P1-T1] test
(`returns ExitCode 1 when a readiness step is blocked_remediation_loop_limit`) together with the
pre-existing `pending` and `blocked` rejection cases. Per-file command coverage is **96.67%**,
above the 96.64% baseline. Analyzed lines are unchanged at 103 / 106 because the `.DESCRIPTION`
reflow removed one comment-based-help line, which is not an analyzable line.

## (c) Python coverage (guard only; no Python change in this cycle)

| Metric | Value ([P2-T6]) | Policy floor | Status |
|---|---|---|---|
| Tests passed | 2123 (baseline 2123, delta 0) | n/a | Pass |
| Line coverage | **91.00% (11175 / 12280)** | >= 85% | Pass |
| Branch coverage | **81.84% (3642 / 4450)** | >= 75% | Pass |

No Python file was modified, so no Python delta is expected and none is observed in the pass count.

## Tooling limitation note

Pester 5 with the `CoverageGutters` format reports **command** coverage, not branch coverage. The
PowerShell branch-coverage figure is therefore not obtainable from this tooling. This is a tooling
limitation rather than a missing measurement, and no value in this artifact is recorded as
`UNVERIFIED`. Python branch coverage is reported directly by coverage.py and is recorded above.

Output Summary: All values are numeric. PowerShell overall command coverage is unchanged at
**89.73% (2945/3282)** and overall line coverage unchanged at **90.26% (2159/2392)**, above the
>= 85% floor. `OrchestratorState.psm1` per-file command coverage rose from 96.64% (144/149) to
**96.67% (145/150)** — no regression; the added command from the membership test is covered by the
[P1-T1] test. Python line coverage **91.00%** and branch coverage **81.84%**, both above policy
floors, with the pass count holding at the 2123 baseline. PowerShell branch coverage is not
obtainable (Pester 5 CoverageGutters measures commands).
