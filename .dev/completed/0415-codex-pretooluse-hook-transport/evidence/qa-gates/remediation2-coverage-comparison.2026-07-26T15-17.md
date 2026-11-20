# Coverage Comparison — Baseline vs Final (Remediation Cycle 2)

- **Issue:** #415
- **Task:** [P7-T4]
- **Plan:** `docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-26T18-10.md`
- **Finding:** R-COV
- **Baseline source:** `FEATURE/evidence/remediation-baseline/phase0-poshqc-test-authoritative.2026-07-26T14-37.md` ([P0-T6], authoritative local run)
- **Final source:** `FEATURE/evidence/qa-gates/remediation2-final-poshqc-test.2026-07-26T15-17.md` ([P7-T3], authoritative local run)

Timestamp: 2026-07-26T15-17

Command: `pwsh -NoProfile -Command "Import-Module '<REPO>/scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root '<REPO>'"` at both points, followed by C3 extraction over `artifacts/pester/powershell-coverage.xml`

EXIT_CODE: 0 (both runs)

## Output Summary

Repo-wide line coverage **rose** from 94.31% to 94.34% while the measured denominator grew by 295 lines.
Both changed production hooks moved from unmeasured to measured and both clear the >= 85% per-file gate on
raw numbers. No file was removed from measurement, no threshold was lowered, and no previously covered
line lost coverage.

### Repo-wide LINE coverage, numeric

| Point | Files measured | Covered | Missed | Total | Percent |
|---|---|---|---|---|---|
| Baseline ([P0-T6]) | 39 | 2869 | 173 | 3042 | **94.31%** |
| Final ([P7-T3]) | 41 | 3148 | 189 | 3337 | **94.34%** |
| **Delta** | **+2** | **+279** | **+16** | **+295** | **+0.03** |

Verdict versus the >= 85% repo-wide gate: **PASS** at both points; PASS at the final point with a
9.34-point margin.

### Movement explained

The +295 total is **denominator growth** from the two newly measured hooks added to `CodeCoverage.Path` at
[P4-T1]:

| Newly measured hook | Instrumented lines |
|---|---|
| `.codex/hooks/enforce-epic-child-worktree-binding.ps1` | 160 |
| `.codex/hooks/enforce-epic-planning-only.ps1` | 135 |
| **Total added to the denominator** | **295** |

The +279 covered is **numerator growth** from the tests added across Phases 1, 2, and 5:

| Phase | Tests added | Cases |
|---|---|---|
| [P1-T2] | `codex-detached-head-transport.Tests.ps1` (C1 `Describe`) | 5 |
| [P2-T2] | `codex-detached-head-transport.Tests.ps1` (A1 `Describe`) | 7 |
| [P5-T1] | `codex-worktree-binding-hook.Tests.ps1` | 21 |
| [P5-T1] | `codex-planning-only-hook.Tests.ps1` | 10 |
| **Total** | | **43** |

Test count moved 1659 → 1702 (+43), 0 failed at both points.

Reconciliation: of the 295 lines added to the denominator, 279 are covered and 16 are not
(7 in the worktree-binding hook, 9 in the planning-only hook). Because 279/295 = 94.58% exceeds the
pre-existing 94.31% rate, the repo-wide percentage rose rather than fell. The intermediate dip recorded at
[P4-T3] (93.50%, immediately after [P4-T1] added the entries but before [P5-T1] wrote the closure tests)
is the visible cost of honest measurement, and it was closed by writing tests rather than by shrinking the
denominator.

### Per-file verdicts — the two changed hooks

| Sourcefile | Baseline | Final | Basis | Gate (>= 85%) |
|---|---|---|---|---|
| `.codex/hooks/enforce-epic-child-worktree-binding.ps1` | **not measured** | 153 / 160 = **95.62%** | **raw** | **PASS** |
| `.codex/hooks/enforce-epic-planning-only.ps1` | **not measured** | 126 / 135 = **93.33%** | **raw** | **PASS** |

Both verdicts rest on **raw** per-file line coverage. No C6 residual was computed, because C6 permits a
residual only for a hook below 85% raw and neither hook is. Reproduced from [P6-T3], which also records a
named per-line reason for each of the 16 remaining missed lines (15 post-guard entrypoint lines requiring
on-disk state that committed tests may not create, plus the single `Invoke-EpicPlanningGit` wrapper-seam
line whose body is the live-`git` invocation that the PowerShell rule file forbids unit tests from
calling).

### Cycle-1 measured `.codex/hooks` files — no regression

| Sourcefile | Baseline | Final | Regression |
|---|---|---|---|
| `check-powershell-test-purity.ps1` | 62/62 = 100.00% | 62/62 = 100.00% | no |
| `check-python-test-purity.ps1` | 67/67 = 100.00% | 67/67 = 100.00% | no |
| `codex-pretooluse-file-mapping.ps1` | 101/101 = 100.00% | 101/101 = 100.00% | no |
| `enforce-checkpoint-monotonic.ps1` | 103/104 = 99.04% | 103/104 = 99.04% | no |
| `enforce-completion-consistency.ps1` | 136/136 = 100.00% | 136/136 = 100.00% | no |
| `enforce-completion-helpers.ps1` (out of scope) | 33/43 = 76.74% | 33/43 = 76.74% | no |
| `enforce-evidence-locations.ps1` | 41/41 = 100.00% | 41/41 = 100.00% | no |
| `enforce-orchestration-preimplementation-gate.ps1` | 98/98 = 100.00% | 98/98 = 100.00% | no |
| `enforce-powershell-batch-budget.ps1` | 84/87 = 96.55% | 84/87 = 96.55% | no |
| `enforce-python-batch-budget.ps1` | 84/87 = 96.55% | 84/87 = 96.55% | no |

Cycle-1 changed-file reference band **96.55% – 100.00%** held exactly.

### Integrity statements

- **No previously covered line lost coverage.** Every one of the 39 baseline-measured files reports a
  covered/missed/total triple identical to baseline at the final point. The +16 missed lines are entirely
  attributable to the two newly measured files; the pre-existing missed set (173 lines) is unchanged.
- **No file was removed from measurement.** `CodeCoverage.Path` moved from 40 to 42 entries. The [P4-T1]
  diff contains zero deletions (`git diff | grep "^-"` produced no output).
- **No threshold was lowered.** `CoveragePercentTarget` remains `0` in both runsettings copies, and the
  policy gates (line >= 85%, branch >= 75%) are unchanged.
- **No denominator was shrunk.** All 295 newly instrumented lines remain in the denominator; no C6
  residual exclusion was applied.
- **No assertion was weakened and no analyzer suppression was added.**

### Branch coverage — documented limitation

PowerShell branch coverage is **not separately measurable in this toolchain**. Pester's coverage output
emits `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters but no `BRANCH` counter, which the C3
extraction confirms at both points (`REPO-WIDE BRANCH: not emitted by this toolchain`). This is the
documented limitation recorded at `spec.md:248`. The repository's >= 75% branch gate is therefore not
measurable for PowerShell and is neither satisfied nor violated by this cycle; nothing in this plan
changed branch-coverage measurability.

## Verdict

| Gate | Result |
|---|---|
| Repo-wide LINE >= 85% at final | **PASS** (94.34%) |
| Repo-wide LINE no regression vs baseline | **PASS** (94.31% → 94.34%, +0.03) |
| `enforce-epic-child-worktree-binding.ps1` >= 85% | **PASS** (95.62% raw) |
| `enforce-epic-planning-only.ps1` >= 85% | **PASS** (93.33% raw) |
| Cycle-1 per-file band no regression | **PASS** |
| No coverage removed / no threshold lowered / no denominator shrunk | **PASS** |

All values numeric; all verdicts pass.

EXIT_CODE: 0
