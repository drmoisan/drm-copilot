# Refreshed Coverage Comparison (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P6-T8]
- **Finding:** R1

Timestamp: 2026-07-26T11-41

Command: C4 package-qualified extraction from `artifacts/pester/powershell-coverage.xml` produced by the [P6-T3] test gate, compared against `evidence/remediation-baseline/phase0-poshqc-test.2026-07-26T11-41.md` ([P0-T5]) and `evidence/qa-gates/coverage-comparison.2026-07-25T21-06.md` (pre-rebase delivered cycle).

EXIT_CODE: 0

## Three comparison points

| Point | Covered | Missed | Total instrumented | Line coverage |
|---|---:|---:|---:|---:|
| **A — pre-rebase delivered cycle** (`coverage-comparison.2026-07-25T21-06.md`) | 2151 | 235 | 2386 | 90.15% |
| **B — [P0-T5] remediation baseline** (post-rebase anchor) | 2160 | 235 | 2395 | 90.19% |
| **C — [P6-T3] post-remediation** | 2869 | 173 | 3042 | **94.31%** |

Point A was measured before the rebase onto `fb483b8468204e4385b5583c3b3ec4c0a987eede` and is not reproducible at HEAD; it is recorded for continuity only. Point B is the authoritative pre-remediation anchor.

## Movement explained numerically

### Term 3 — rebase-induced movement (explains A → B)

The rebase brought issue #412 changes to two modules already present in `CodeCoverage.Path`:

| Module | Instrumented at A | Instrumented at B | Covered at B | Percent at B | Δ instrumented | Δ covered |
|---|---:|---:|---:|---:|---:|---:|
| `.claude/lib/model-routing/ModelRouting.psm1` | 43 | 46 | 46 | 100.00% | +3 | +3 |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 100 | 106 | 103 | 97.17% | +6 | +6 |
| **Total** | | | | | **+9** | **+9** |

A → B arithmetic: 2151 + 9 = **2160** covered; 2386 + 9 = **2395** instrumented; missed unchanged at 235. This fully accounts for the A → B delta with no residual, and both modules remain above the 85% per-file threshold. Neither module is in this branch's diff.

### Term 1 — denominator growth from the 8 newly measured files (contributes to B → C)

The [P1-T1] `CodeCoverage.Path` addition brought the 8 C5 paths into measurement:

| Newly measured file | Instrumented lines added |
|---|---:|
| `.codex/hooks/codex-pretooluse-file-mapping.ps1` | 101 |
| `.codex/hooks/check-python-test-purity.ps1` | 67 |
| `.codex/hooks/check-powershell-test-purity.ps1` | 62 |
| `.codex/hooks/enforce-python-batch-budget.ps1` | 87 |
| `.codex/hooks/enforce-powershell-batch-budget.ps1` | 87 |
| `.codex/hooks/enforce-evidence-locations.ps1` | 41 |
| `.codex/hooks/enforce-checkpoint-monotonic.ps1` | 104 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 98 |
| **Total denominator growth** | **+647** |

2395 + 647 = **3042** instrumented at point C. Exact match; no other file entered or left measurement.

At the moment the paths were added and before any new test existed ([P1-T2]), 174 of those 647 lines were already covered incidentally, giving 2334 / 3042 = 76.73% — the expected intermediate dip.

### Term 2 — numerator growth from the Phase 2, 3, and 4 additive tests (completes B → C)

Per-file newly covered lines, measured from [P1-T3] to [P4-T3]:

| File | [P1-T3] covered | [P4-T3] covered | Newly covered | Batch |
|---|---:|---:|---:|---|
| `codex-pretooluse-file-mapping.ps1` | 79 | 101 | +22 | 2 |
| `enforce-orchestration-preimplementation-gate.ps1` | 38 | 98 | +60 | 2 |
| `enforce-completion-consistency.ps1` | 67 | 136 | +69 | 2 (+57) and 4 (+12) |
| `check-python-test-purity.ps1` | 0 | 67 | +67 | 3 |
| `check-powershell-test-purity.ps1` | 0 | 62 | +62 | 3 |
| `enforce-python-batch-budget.ps1` | 26 | 84 | +58 | 3 |
| `enforce-powershell-batch-budget.ps1` | 26 | 84 | +58 | 3 |
| `enforce-evidence-locations.ps1` | 0 | 41 | +41 | 3 |
| `enforce-checkpoint-monotonic.ps1` | 5 | 103 | +98 | 3 |
| **Total** | **241** | **776** | **+535** | |

Full reconciliation of B → C:

- Covered: 2160 (B) + 174 (already-covered lines inside the newly measured files) + 535 (newly covered by the additive tests) = **2869** (C). Exact match.
- Instrumented: 2395 (B) + 647 (Term 1) = **3042** (C). Exact match.
- Missed: 235 (B) + 647 − 709 covered-in-new-files = **173** (C). Exact match.

No line outside the 8 newly measured files changed state; the 235 baseline misses are wholly contained in the 173 final misses plus the 62 that were closed inside the previously measured `.codex/hooks/enforce-completion-consistency.ps1` (69 missed at B → 0 at C, of which 69 were in an already-measured file). Restating precisely: `enforce-completion-consistency.ps1` was already measured at B with 67/136; its 69 misses are part of the 235, and all 69 were closed. 235 − 69 = 166 baseline misses remain, plus 7 residual misses inside the newly measured files = **173**. Exact match.

## Repo-wide verdict

**2869 / 3042 = 94.31% >= 85% — PASS.**

## Per-file verdicts — all 9 files in the C7 verdict set

| # | File | Covered | Instrumented | RAW percent | Verdict | RI-1 residual required? |
|---|---|---:|---:|---:|---|---|
| 1 | `.codex/hooks/codex-pretooluse-file-mapping.ps1` | 101 | 101 | 100.00% | **PASS (raw >= 85%)** | no |
| 2 | `.codex/hooks/check-python-test-purity.ps1` | 67 | 67 | 100.00% | **PASS (raw >= 85%)** | no |
| 3 | `.codex/hooks/check-powershell-test-purity.ps1` | 62 | 62 | 100.00% | **PASS (raw >= 85%)** | no |
| 4 | `.codex/hooks/enforce-python-batch-budget.ps1` | 84 | 87 | 96.55% | **PASS (raw >= 85%)** | no |
| 5 | `.codex/hooks/enforce-powershell-batch-budget.ps1` | 84 | 87 | 96.55% | **PASS (raw >= 85%)** | no |
| 6 | `.codex/hooks/enforce-evidence-locations.ps1` | 41 | 41 | 100.00% | **PASS (raw >= 85%)** | no |
| 7 | `.codex/hooks/enforce-checkpoint-monotonic.ps1` | 103 | 104 | 99.04% | **PASS (raw >= 85%)** | no |
| 8 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 98 | 98 | 100.00% | **PASS (raw >= 85%)** | no |
| 9 | `.codex/hooks/enforce-completion-consistency.ps1` (preflight RC-7) | 136 | 136 | 100.00% | **PASS (raw >= 85%)** | no |

**No RI-1 residual computation is reproduced here because none was required.** Every verdict-set file clears 85% on the unadjusted raw number, so no post-guard line was excluded from any denominator anywhere in this remediation. The seven residual uncovered lines (1 in `enforce-checkpoint-monotonic.ps1`, 3 in each batch-budget hook) are documented with per-line non-exercisability justification in `per-file-coverage-final.2026-07-26T11-41.md` section (iv); they sit inside the denominators used above, not outside them.

## No-regression and no-removal statements

- **No previously covered line lost coverage.** Every file measured at [P0-T5] retained or increased its covered count: the 22 `.claude/hooks` files, 3 `.claude/lib` modules, 5 `scripts/dev-tools` scripts, 2 `scripts/powershell` files, 2 `scripts/powershell/PoshQC` modules, and the 2 previously measured `.codex/hooks` files. `enforce-completion-helpers.ps1` is unchanged at 33/43; `enforce-completion-consistency.ps1` improved from 67/136 to 136/136.
- **No file was removed from measurement.** `CodeCoverage.Path` gained 8 entries and lost none; the measured file count rose from 31 to 39 (`Covered … in 39 Files` versus 31 at baseline).
- **No coverage threshold was lowered** and **no denominator was adjusted**. Every percentage in this artifact is a raw measured value.

## Pre-existing, out-of-scope file statement (preflight Section 7 advisory)

`.codex/hooks/enforce-completion-helpers.ps1` measures **33 / 43 = 76.74%**, below the 85% per-file threshold. It is **pre-existing and unchanged on this branch** — absent from `git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD`, added to `CodeCoverage.Path` by issue #301, and identical to its [P0-T5] baseline figure including the same ten missed lines (52, 79, 87, 93, 100, 135, 144, 152, 156, 160). It is **outside the C7 verdict set**, no verdict is owed for it, and it is **not a regression introduced by [P1-T1]**.

## Branch-coverage limitation

PowerShell branch coverage is not separately measurable in this toolchain (`spec.md:248`). The JaCoCo output carries `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters only, with no `BRANCH` counter and all `mb`/`cb` attributes at 0. The >= 75% branch threshold is evaluated for Python only, where it passes at 81.84% (`python-coverage.2026-07-26T11-41.md`).
