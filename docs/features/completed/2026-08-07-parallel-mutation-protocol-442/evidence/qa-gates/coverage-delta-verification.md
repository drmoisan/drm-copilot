# Coverage Delta and Threshold Verification ([P7-T8])

Timestamp: 2026-08-09T03-45

Task: [P7-T8] Verify the coverage delta and thresholds against the Phase 0 baselines.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
Reconciliation base: `c939b5b8`

Command: comparison of four evidence artifacts already on disk (no new toolchain command; the figures
below are transcribed from the recorded runs, not re-measured):
- `<FEATURE>/evidence/baseline/baseline-py-test-coverage.md` (P0-T4)
- `<FEATURE>/evidence/baseline/baseline-ps-test-coverage.md` (P0-T6)
- `<FEATURE>/evidence/qa-gates/final-py-test-coverage.md` (P7-T4)
- `<FEATURE>/evidence/qa-gates/final-ps-test-coverage.md` (P7-T7)

EXIT_CODE: 0

## Python — Baseline vs Post-Change vs New/Changed Code

| Figure | Baseline (P0-T4) | Post-change (P7-T4) | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Line (statement) coverage | **91.82%** (12432 / 13539) | **92.05%** (12815 / 13922) | **+0.23 pp** | >= 85% | PASS (+7.05 pp margin) |
| Branch coverage | **83.80%** (4190 / 5000) | **84.19%** (4312 / 5122) | **+0.39 pp** | >= 75% | PASS (+9.19 pp margin) |
| Missing statements | 1107 | 1107 | 0 | n/a | no new uncovered statement |
| Missing branches | 810 | 810 | 0 | n/a | no new uncovered branch |
| Tests passed | 3007 | 3386 | +379 | n/a | PASS |
| Tests failed | 0 | 0 | 0 | 0 | PASS |
| Excluded lines | 387 | 400 | +13 | n/a | from the pre-existing `__main__` / `TYPE_CHECKING` rules applying to new modules; no new `exclude` pattern was added to any config |

**New/changed-code coverage (Python): 383 of 383 statements covered = 100.00%; 122 of 122 new branches
covered = 100.00%.**

Composition of the new/changed set:

| File | Kind | Stmts | Miss | Line cov | Branches | Miss br | Branch cov |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/parallel_mutation_protocol.py` | new | 44 | 0 | 100.00% | 22 | 0 | 100.00% |
| `scripts/dev_tools/_parallel_mutation_models.py` | new | 95 | 0 | 100.00% | 30 | 0 | 100.00% |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` | new | 62 | 0 | 100.00% | 10 | 0 | 100.00% |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` | new | 67 | 0 | 100.00% | 28 | 0 | 100.00% |
| `scripts/dev_tools/_parallel_mutation_errors.py` | new (delegate) | 34 | 0 | 100.00% | 0 | 0 | n/a |
| `scripts/dev_tools/_parallel_mutation_entries.py` | new (delegate) | 13 | 0 | 100.00% | 0 | 0 | n/a |
| `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` | new (delegate) | 66 | 0 | 100.00% | 32 | 0 | 100.00% |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | changed (+2 stmts) | 2 changed | 0 | 100.00% | 0 new | 0 | n/a |
| **Total new/changed** | | **383** | **0** | **100.00%** | **122** | **0** | **100.00%** |

**No regression on changed lines.** The only pre-existing Python file F6 modifies is
`validate_parallel_orchestrator_state.py`. Its statement count rose 82 → 84 (the one added import line
and the one added call line) while its missing-statement count stayed at 2, so both added lines are
covered. Its line coverage moved 97.56% (80/82) → 97.62% (82/84), and its branch coverage is unchanged
at 94.12% (32/34). The two uncovered line numbers changed from 226, 265 to 227, 266 — the same
pre-existing pair, shifted by the single import line inserted above them, not new misses.

## PowerShell — Baseline vs Post-Change vs New Code

| Figure | Baseline (P0-T6) | Post-change (P7-T7) | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Line coverage | **94.34%** (3148 / 3337) | **94.34%** (3148 / 3337) | **0.00 pp** | >= 85% | PASS (+9.34 pp margin) |
| Instruction coverage | 93.95% (4316 / 4594) | 93.95% (4316 / 4594) | 0.00 pp | not a policy threshold | unchanged |
| Branch coverage | not produced | not produced | n/a | >= 75% (Python-measurable only) | NOT MEASURABLE — Pester's JaCoCo output emits no `BRANCH` counter; recorded at baseline as a toolchain property, not a gap introduced by this feature |
| Tests passed | 2021 | 2043 | +22 | n/a | PASS |
| Tests failed | 1 (pre-existing) | 1 (same pre-existing test) | 0 | baseline-equal | PASS |
| Skipped | 9 | 9 | 0 | n/a | unchanged |

**New-code coverage (PowerShell): `.claude/hooks/enforce-parallel-abandon-gate.ps1` = 86.96% line
(40 covered / 46 lines), 84.21% instruction (48 / 57), exercised by 22 passing Pester cases.**

This figure comes from the supplementary targeted `Invoke-Pester` measurement recorded in P7-T7,
because the aggregate report does not include the file. Reason, restated for this verification: the MCP
test tool resolves its `CodeCoverage.Path` allowlist from the installed extension bundle rather than
from `workspace_root`, so the P5-phase allowlist append (present and identical in both in-repo copies)
does not alter the current session's measured file set. The value is a real measurement, not a
placeholder and not an inferred zero. The 6 uncovered hook lines are the mocked read-seam body (line 56)
and the post-dot-source-guard entry point (lines 251-259); no decision logic is uncovered.

**No regression on changed lines.** The aggregate line, instruction, method, and class counters are
byte-identical to baseline, so no pre-existing PowerShell file lost coverage. No pre-existing PowerShell
production file was modified by this feature; the only pre-existing PowerShell-adjacent files touched are
the two `pester.runsettings.psd1` copies, which are configuration and carry no measured lines.

## Threshold Summary

| Language | Metric | Required | Achieved | Verdict |
| --- | --- | --- | --- | --- |
| Python | Line coverage | >= 85% | 92.05% | PASS |
| Python | Branch coverage | >= 75% | 84.19% | PASS |
| Python | New/changed-code line coverage | no regression on changed lines | 100.00% | PASS |
| Python | Per-module coverage, 7 new production modules | >= 85% line / >= 75% branch | 100% line and 100% branch on every module | PASS |
| Python | Shared-file regression | none | +0.06 pp line, branch unchanged | PASS |
| PowerShell | Line coverage | >= 85% | 94.34% (unchanged from baseline) | PASS |
| PowerShell | New-file line coverage | >= 85% | 86.96% | PASS |
| PowerShell | Branch coverage | >= 75% | not produced by Pester's JaCoCo output | NOT APPLICABLE — toolchain does not emit a branch counter; recorded as such at baseline, not a value withheld |

Every required value is available as a number. No required value is below its threshold. No changed line
lost coverage in either language.

Output Summary: Python line coverage rose **91.82% → 92.05%** (+0.23 pp) and branch coverage rose
**83.80% → 84.19%** (+0.39 pp), both above threshold, with missing statements and missing branches both
unchanged at 1107 and 810 and tests up from 3007 to 3386 passing with zero failures. New/changed Python
code is **100.00% covered (383/383 statements, 122/122 branches)**, and the one shared Python file gained
two statements with its missing count unchanged, so no changed line regressed. PowerShell line coverage
is **94.34% → 94.34%** (unchanged, above threshold), passing tests rose 2021 → 2043 (+22, the new
abandon-gate suite, 0 failures), and the single failing test is the same pre-existing out-of-scope
`enforce-pr-author-skill.Tests.ps1` case as at baseline. The new PowerShell hook measures **86.96% line
coverage (40/46)** via the targeted run required by the bundled-settings resolution property. PowerShell
branch coverage is not produced by Pester's JaCoCo output — a toolchain property recorded at baseline,
not a missing value introduced here.

Verdict: **PASS.** All thresholds met with numeric evidence; no coverage regression on changed lines in
either language. Remediation is not required.
