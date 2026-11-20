# Final Per-File Coverage Verification (Remediation Cycle 1, Phase 4)

- **Issue:** #415
- **Task:** [P4-T3]
- **Finding:** R1

Timestamp: 2026-07-26T11-41

Command: re-extraction per C4 (package-qualified on `package/@name` ending `.codex/hooks`) from the [P4-T2] run of
`pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`,
parsing `artifacts/pester/powershell-coverage.xml`.

EXIT_CODE: 0

Output Summary: **PASS.** All nine files in the C7 verdict set meet the 85% per-file line-coverage threshold on the RAW number, so the RI-1 residual computation is not invoked for any file. The shared module is at 100.00% raw. Repo-wide line coverage is 2869 / 3042 = 94.31%, above the 85% gate. No exercisable line remains uncovered in any C7 file; the seven residual uncovered lines all carry per-line justification below. The FAILURE BRANCH is not taken.

## (i) Per-file table — all 10 measured `.codex/hooks` files

| # | File | Covered | Missed | Total | Raw percent | >= 85% raw? |
|---|---|---:|---:|---:|---:|---|
| 1 | `codex-pretooluse-file-mapping.ps1` | 101 | 0 | 101 | **100.00%** | YES |
| 2 | `check-python-test-purity.ps1` | 67 | 0 | 67 | **100.00%** | YES |
| 3 | `check-powershell-test-purity.ps1` | 62 | 0 | 62 | **100.00%** | YES |
| 4 | `enforce-python-batch-budget.ps1` | 84 | 3 | 87 | **96.55%** | YES |
| 5 | `enforce-powershell-batch-budget.ps1` | 84 | 3 | 87 | **96.55%** | YES |
| 6 | `enforce-evidence-locations.ps1` | 41 | 0 | 41 | **100.00%** | YES |
| 7 | `enforce-checkpoint-monotonic.ps1` | 103 | 1 | 104 | **99.04%** | YES |
| 8 | `enforce-orchestration-preimplementation-gate.ps1` | 98 | 0 | 98 | **100.00%** | YES |
| 9 | `enforce-completion-consistency.ps1` | 136 | 0 | 136 | **100.00%** | YES |
| 10 | `enforce-completion-helpers.ps1` (out of verdict set) | 33 | 10 | 43 | 76.74% | n/a |

C7 verdict-set totals (rows 1–9): covered **776**, missed **7**, instrumented **783** → **99.11%** (baseline at [P1-T3] was 241 / 783 = 30.78%).

Movement from the [P1-T3] first measurement, per file:

| File | [P1-T3] | Final | Newly covered lines |
|---|---:|---:|---:|
| `codex-pretooluse-file-mapping.ps1` | 79 / 101 (78.22%) | 101 / 101 (100.00%) | +22 |
| `check-python-test-purity.ps1` | 0 / 67 (0.00%) | 67 / 67 (100.00%) | +67 |
| `check-powershell-test-purity.ps1` | 0 / 62 (0.00%) | 62 / 62 (100.00%) | +62 |
| `enforce-python-batch-budget.ps1` | 26 / 87 (29.89%) | 84 / 87 (96.55%) | +58 |
| `enforce-powershell-batch-budget.ps1` | 26 / 87 (29.89%) | 84 / 87 (96.55%) | +58 |
| `enforce-evidence-locations.ps1` | 0 / 41 (0.00%) | 41 / 41 (100.00%) | +41 |
| `enforce-checkpoint-monotonic.ps1` | 5 / 104 (4.81%) | 103 / 104 (99.04%) | +98 |
| `enforce-orchestration-preimplementation-gate.ps1` | 38 / 98 (38.78%) | 98 / 98 (100.00%) | +60 |
| `enforce-completion-consistency.ps1` | 67 / 136 (49.26%) | 136 / 136 (100.00%) | +69 |
| **Total** | **241 / 783 (30.78%)** | **776 / 783 (99.11%)** | **+535** |

No file lost a previously covered line.

## (ii) Shared module verification (C6 — raw number, no residual allowance)

`.codex/hooks/codex-pretooluse-file-mapping.ps1` is entrypoint-free (474 file lines, 101 instrumented, no dot-source guard), so C6 requires the >= 85% threshold to be met by the RAW per-file number with no residual allowance.

- covered = **101**
- missed = **0**
- instrumented = **101**
- **raw line coverage = 101 / 101 = 100.00%** — **>= 85%: PASS**

## (iii) RI-1 residual computation for guarded hooks below 85% raw

**Not applicable. No guarded hook is below 85% raw.**

All eight guarded hooks measure at or above the threshold on the raw number:

| Guarded hook | Raw | Residual computation required? |
|---|---:|---|
| `check-python-test-purity.ps1` | 100.00% | no |
| `check-powershell-test-purity.ps1` | 100.00% | no |
| `enforce-python-batch-budget.ps1` | 96.55% | no |
| `enforce-powershell-batch-budget.ps1` | 96.55% | no |
| `enforce-evidence-locations.ps1` | 100.00% | no |
| `enforce-checkpoint-monotonic.ps1` | 99.04% | no |
| `enforce-orchestration-preimplementation-gate.ps1` | 100.00% | no |
| `enforce-completion-consistency.ps1` | 100.00% | no |

Because every raw number already clears 85%, no denominator is reduced anywhere in this remediation, no post-guard line is excluded from any denominator, and RI-1's transparent residual formula `covered / (instrumented − justified-guarded-entrypoint instrumented)` is never evaluated. The threshold is met on the unadjusted measurement.

## (iv) RI-5 confirmation — no exercisable line remains uncovered

Seven lines remain uncovered across the C7 verdict set. Each is classified non-exercisable with a named enclosing region and a per-line reason, and each guarded hook involved has an attempted in-process entrypoint case as C6 requires.

### `enforce-checkpoint-monotonic.ps1:261` — 1 line

- **Enclosing region:** the body of `if (-not $payload.PSObject.Properties.Name -contains 'completed_steps')` (line 260).
- **Reason invocation is impossible without changing the hook:** PowerShell binds `-not` more tightly than `-contains`, so the condition evaluates as `(-not $payload.PSObject.Properties.Name) -contains 'completed_steps'` — a containment test of the string `'completed_steps'` against a Boolean scalar. For a payload with properties the left operand is `$false`; for a payload with none it is `$true`; neither Boolean contains the string, so the condition is `$false` for every possible input and the branch body is unreachable. Reaching line 261 would require editing the hook's condition, which Hard Constraint 3 (no `.codex/hooks/*.ps1` production edit in this plan) and Hard Constraint 4 (no policy-function change) both forbid.
- **Behavioural note:** the dead branch is benign today. A payload with no `completed_steps` falls through to `$steps = @()`, produces no out-of-order pair and no missing prerequisite, and reaches the same `allow` the dead branch would have returned. Recorded as a follow-up defect in `evidence/other/remediation-followups.2026-07-26T11-41.md`.
- **C6 entrypoint requirement:** satisfied — three in-process entrypoint cases exist in `codex-evidence-and-checkpoint-hooks.Tests.ps1`, and every other post-guard line (323–325, 327–332, 335, 337–338) is covered.

### `enforce-python-batch-budget.ps1:245, 246, 247` and `enforce-powershell-batch-budget.ps1:247, 248, 249` — 3 lines each

- **Enclosing region:** the deny arm inside the entrypoint's `foreach ($path in $budgetPaths)` loop — `$decision.Remove('state')`, the `Write-Output` of the deny decision, and `exit 0`. These are post-guard lines (guards at 217 and 219).
- **C6 requirement 1 — attempted in-process entrypoint case exists:** yes. `codex-batch-budget-hooks.Tests.ps1` contains four in-process entrypoint cases per hook using `& $HookPath` with `[System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))` and both console readers restored in `finally`. They cover every other post-guard line in each hook (224–244 and 250–253 for the Python hook; 226–246 and 252–255 for the PowerShell hook).
- **C6 requirement 2 — named per-line reason:** reaching the deny arm requires the per-session budget file for that language to already be at its cap before the hook runs. The entrypoint derives its state root from `$PSScriptRoot` (`$repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`) and exposes no injection seam at the script level, so the only way to satisfy that precondition is to create and populate `<repo>/.codex/state/<language>-batch-budget.<session>.json` on disk. That is prohibited three times over: the no-temporary-files rule (`.claude/rules/general-unit-test.md`; plan Hard Constraint 4), the prohibition on mutable global state shared between tests (an on-disk counter would also make the suite order-dependent and non-deterministic), and plan Hard Constraint 2 (no batch-budget state may be created, reset, or overridden). The suite was verified not to create that state: `Test-Path .codex/state` is **False** after the full run.
- **Compensating coverage:** the deny decision these three lines serialize is fully covered at the unit level. `Invoke-PythonBatchBudgetDecision` / `Invoke-PowerShellBatchBudgetDecision` and `Invoke-PythonBatchBudgetHook` / `Invoke-PowerShellBatchBudgetHook` each produce and assert the cap-exceeded deny (including the reason text, the cap value, and the state-file path) through injected in-memory seams.

**Conclusion for (iv):** every dot-source-reachable, exercisable line in all nine C7 verdict-set files is covered. The seven residual lines are non-exercisable under the plan's hard constraints, each with its enclosing region named and its reason stated, and each guarded hook carries an attempted in-process entrypoint case.

## (v) Repo-wide line percentage and verdict

- covered = **2869**
- missed = **173**
- total instrumented = **3042**
- **repo-wide line coverage = 2869 / 3042 = 94.31%**
- **>= 85% verdict: PASS**

Trajectory across the remediation:

| Point | Covered | Missed | Instrumented | Percent |
|---|---:|---:|---:|---:|
| [P0-T5] baseline (before R1 measurement change) | 2160 | 235 | 2395 | 90.19% |
| [P1-T2] after adding the 8 C5 paths, before new tests | 2334 | 708 | 3042 | 76.73% |
| [P2-T3] after batch 1 | 2473 | 569 | 3042 | 81.30% |
| [P3-T2] after batch 2 | 2857 | 185 | 3042 | 93.92% |
| [P4-T2] after batch 3 (final) | 2869 | 173 | 3042 | 94.31% |

PowerShell branch coverage is not separately measurable in this toolchain (`spec.md:248`): the JaCoCo output carries `INSTRUCTION`, `LINE`, `METHOD`, and `CLASS` counters only, with all `mb`/`cb` attributes at 0.

## (vi) Pre-existing, out-of-scope file statement (preflight Section 7 advisory)

`.codex/hooks/enforce-completion-helpers.ps1` measures **33 / 43 = 76.74%**, below the 85% per-file threshold. This file is **pre-existing and unchanged on this branch**: it does not appear in `git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD`, it entered `CodeCoverage.Path` under issue #301, and its figure is byte-for-byte identical to the [P0-T5] pre-remediation baseline (33 / 43, same ten missed lines: 52, 79, 87, 93, 100, 135, 144, 152, 156, 160). It is therefore **outside the C7 verdict set**, no verdict is owed for it, and it is **not a regression introduced by [P1-T1]**.

## Constraint compliance

- No file was removed from `CodeCoverage.Path`.
- No coverage threshold was lowered.
- No denominator was adjusted or shrunk; every percentage above is the raw measured value.
- No assertion was weakened and no analyzer suppression was added.
- No production file was modified in Phases 2–4; the only production change in this remediation is the [P1-T1] measurement-configuration edit to the two `pester.runsettings.psd1` copies.
