# Interim Per-File Coverage and Batch-3 Gap List (Remediation Cycle 1, Phase 3)

- **Issue:** #415
- **Task:** [P3-T3]
- **Finding:** R1

Timestamp: 2026-07-26T11-41

Command: re-extraction per C4 (package-qualified on `package/@name` ending `.codex/hooks`) from the [P3-T2] run of
`pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`,
parsing `artifacts/pester/powershell-coverage.xml`.

EXIT_CODE: 0

Output Summary: all nine C7 verdict-set files now measure at or above the 85% per-file threshold on the RAW number, and repo-wide line coverage is 2857 / 3042 = 93.92%. One C7 file (`enforce-completion-consistency.ps1`) still carries 12 remaining exercisable missed lines, which constitute the Phase 4 batch-3 work. The final verdict is not recorded here; it lives at [P4-T3].

## (i) Per-file table — all 10 measured `.codex/hooks` files

| # | File | Covered | Missed | Total | Percent | Δ vs [P2-T4] | >= 85% raw? |
|---|---|---:|---:|---:|---:|---:|---|
| 1 | `codex-pretooluse-file-mapping.ps1` | 101 | 0 | 101 | **100.00%** | 0 | YES |
| 2 | `check-python-test-purity.ps1` | 67 | 0 | 67 | **100.00%** | +67 | YES |
| 3 | `check-powershell-test-purity.ps1` | 62 | 0 | 62 | **100.00%** | +62 | YES |
| 4 | `enforce-python-batch-budget.ps1` | 84 | 3 | 87 | **96.55%** | +58 | YES |
| 5 | `enforce-powershell-batch-budget.ps1` | 84 | 3 | 87 | **96.55%** | +58 | YES |
| 6 | `enforce-evidence-locations.ps1` | 41 | 0 | 41 | **100.00%** | +41 | YES |
| 7 | `enforce-checkpoint-monotonic.ps1` | 103 | 1 | 104 | **99.04%** | +98 | YES |
| 8 | `enforce-orchestration-preimplementation-gate.ps1` | 98 | 0 | 98 | **100.00%** | 0 | YES |
| 9 | `enforce-completion-consistency.ps1` | 124 | 12 | 136 | **91.18%** | 0 | YES |
| 10 | `enforce-completion-helpers.ps1` (out of verdict set) | 33 | 10 | 43 | 76.74% | 0 | n/a |

C7 verdict-set totals (rows 1–9): covered 764, missed 19, instrumented 783 → **97.57%** (was 48.53%).

## (ii) Accumulated `NO-GAP` / `NO-FURTHER-GAP` records

- **[P2-T1]** — branch condition did not apply (module was at 78.22%). Gap closed by the new file `tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1` (411 lines). Module now **100.00% raw**.
- **[P2-T2]** — `NO-GAP` was not recordable for any of the 8 guarded hooks (all had exercisable missed lines and none had an attempted in-process entrypoint case). Batch-1 closure delivered for `enforce-orchestration-preimplementation-gate.ps1` (**100.00%**) and `enforce-completion-consistency.ps1` (**91.18%**), with an itemized remainder carried forward.
- **[P3-T1]** — branch condition did not apply ([P2-T4] section (iii) listed remaining exercisable lines in six hooks and section (iv) showed 81.30% repo-wide). `NO-FURTHER-GAP` was therefore NOT recorded. Three new test files were created under `tests/scripts/codex-hooks/`, each ≤ 500 lines, using the cluster split fixed by the plan:

  | New file | Lines | Hooks covered | Cases | Result |
  |---|---:|---|---:|---|
  | `codex-test-purity-hooks.Tests.ps1` | 304 | `check-python-test-purity.ps1`, `check-powershell-test-purity.ps1` | 36 | 100.00% / 100.00% |
  | `codex-batch-budget-hooks.Tests.ps1` | 346 | `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1` | 48 | 96.55% / 96.55% |
  | `codex-evidence-and-checkpoint-hooks.Tests.ps1` | 400 | `enforce-evidence-locations.ps1`, `enforce-checkpoint-monotonic.ps1` | 50 | 100.00% / 99.04% |

  Every file dot-sources the ROOT hooks in-process, uses `Describe`/`Context`/`It` with Arrange–Act–Assert and one behaviour per `It`, and includes an in-process entrypoint case per C6 for each covered hook. No temporary file is created; no production file was changed; no assertion was weakened.

Batch accounting for Phase 3: **0 production files, 3 test files** — within the per-batch cap.

## (iii) Remaining exercisable missed lines per C7 file — the Phase 4 batch-3 work

### `enforce-completion-consistency.ps1` — 12 remaining, ALL EXERCISABLE → Phase 4 scope

Missed: 248, 254, 255, 256, 259, 260, 261, 262, 384, 385, 386, 400. All are below the guard at line 414, so all are dot-source-reachable, and none has any C6 exclusion claim.

| Lines | Enclosing region | How a dot-sourced test reaches them |
|---|---|---|
| 248, 254, 255, 256, 259, 260, 261, 262 | the `pr_gate` evidence block of `Get-MissingCompletionEvidence` | call with an injected `RoutingMatrixReader` returning a matrix whose selected route sets `requires_pr_gate = $true`, then vary `pr_gate` presence, per-field completeness, and `head_sha` agreement with `ci_gate` |
| 384, 385, 386 | the invalid-checkpoint-JSON deny branch of `Invoke-CompletionConsistencyDecision` | supply a governed-checkpoint write whose `content` is not valid JSON |
| 400 | the all-evidence-present allow branch of `Invoke-CompletionConsistencyDecision` | supply a completion-asserting checkpoint carrying complete `issue-num`, `feature-folder`, and `ci_gate` evidence, with an injected `FolderExistsCheck` returning `$true` |

### All other C7 files — no remaining exercisable missed lines

- `codex-pretooluse-file-mapping.ps1`, `check-python-test-purity.ps1`, `check-powershell-test-purity.ps1`, `enforce-evidence-locations.ps1`, `enforce-orchestration-preimplementation-gate.ps1`: 0 missed lines.
- `enforce-checkpoint-monotonic.ps1`: 1 missed line, **non-exercisable** (see below).
- `enforce-python-batch-budget.ps1` / `enforce-powershell-batch-budget.ps1`: 3 missed lines each, all post-guard and each carrying its C6 justification (see below).

### Non-exercisable classifications (RI-5 per-line justification)

**`enforce-checkpoint-monotonic.ps1:261`** — enclosing region: the body of the guard
`if (-not $payload.PSObject.Properties.Name -contains 'completed_steps')` at line 260.
Reason invocation is impossible without changing the hook: PowerShell operator precedence binds `-not` tighter than `-contains`, so the condition evaluates as `(-not $payload.PSObject.Properties.Name) -contains 'completed_steps'` — a containment test of the string `'completed_steps'` against a Boolean scalar, which is `$false` for every possible payload. When the payload has properties the left operand is `$false`; when it has none the left operand is `$true`; neither Boolean contains the string. The branch body at line 261 is therefore unreachable for all inputs. Covering it would require editing the hook's condition, which Hard Constraint 3 (no production `.codex/hooks/*.ps1` edit) and Hard Constraint 4 (no policy-function change) forbid in this plan. **Recorded as a follow-up defect** alongside the [P5-T2] dossier; behaviourally the fall-through path already allows a payload with no `completed_steps`, so the dead branch causes no incorrect decision today.

**`enforce-python-batch-budget.ps1:245, 246, 247` and `enforce-powershell-batch-budget.ps1:247, 248, 249`** — enclosing region: the deny arm of the entrypoint's `foreach ($path in $budgetPaths)` loop (`$decision.Remove('state')`, the `Write-Output` of the deny decision, and `exit 0`).
C6 justification, both parts present:
1. *Attempted in-process entrypoint case exists* — each hook has three in-process entrypoint cases in `codex-batch-budget-hooks.Tests.ps1` using `& $HookPath` with `[System.Console]::SetIn([System.IO.StringReader]::new(...))` and readers restored in `finally`; they cover the surrounding post-guard lines 224–244 / 226–246 and 250–253 / 252–255.
2. *Named per-line reason* — reaching the deny arm requires the per-session budget file for the language to already be at its cap. The entrypoint computes its state root from `$PSScriptRoot` (`$repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`) and offers no injection seam, so the only way to satisfy that precondition is to create and populate `<repo>/.codex/state/<lang>-batch-budget.<session>.json` on disk. That is prohibited three times over: the no-temporary-files rule (`.claude/rules/general-unit-test.md`, plan Hard Constraint 4), the prohibition on mutable global state between tests (which would also make the suite order-dependent), and plan Hard Constraint 2 (no batch-budget state may be created, reset, or overridden). The deny decision itself is fully covered at the unit level — `Invoke-…BatchBudgetDecision` and `Invoke-…BatchBudgetHook` both produce and assert the cap-exceeded deny with injected seams — so the uncovered lines are the entrypoint's serialization of an already-verified decision.

Both hooks are at 96.55% raw, above the 85% threshold, so no RI-1 residual computation is invoked for them.

## In-process entrypoint case status (C6), per hook — after batch 2

| Hook | Attempted in-process entrypoint case exists? | Location |
|---|---|---|
| `enforce-orchestration-preimplementation-gate.ps1` | **YES** (4) | `legacy-codex-hook-contracts.Tests.ps1` |
| `enforce-completion-consistency.ps1` | **YES** (3) | `codex-pretooluse-transport.Tests.ps1` |
| `check-python-test-purity.ps1` | **YES** (4) | `codex-test-purity-hooks.Tests.ps1` |
| `check-powershell-test-purity.ps1` | **YES** (4) | `codex-test-purity-hooks.Tests.ps1` |
| `enforce-python-batch-budget.ps1` | **YES** (4) | `codex-batch-budget-hooks.Tests.ps1` |
| `enforce-powershell-batch-budget.ps1` | **YES** (4) | `codex-batch-budget-hooks.Tests.ps1` |
| `enforce-evidence-locations.ps1` | **YES** (2 script-level + 4 entrypoint-function) | `codex-evidence-and-checkpoint-hooks.Tests.ps1` |
| `enforce-checkpoint-monotonic.ps1` | **YES** (3) | `codex-evidence-and-checkpoint-hooks.Tests.ps1` |
| `codex-pretooluse-file-mapping.ps1` | n/a (entrypoint-free module) | — |

All eight guarded hooks now have an attempted in-process entrypoint case, satisfying the first C6 requirement for every hook.

## (iv) Current repo-wide line percentage

- covered = **2857**
- missed = **185**
- total instrumented = **3042**
- **line coverage = 2857 / 3042 = 93.92%** (was 81.30% at [P2-T4])
- >= 85%: satisfied at this point; formally verified at [P4-T3] and [P6-T3].

## Phase 4 branch determination

The [P4-T1] `NO-FURTHER-GAP` branch condition requires ALL THREE of: no remaining exercisable missed lines in any C7 file, an attempted in-process entrypoint case for every C7 hook, and repo-wide >= 85%. Conditions two and three hold, but condition one does NOT: section (iii) lists 12 remaining exercisable missed lines in `enforce-completion-consistency.ps1`. **Phase 4 therefore performs gap-closure work**, creating one new test file for that remainder.

## Pre-existing, out-of-scope file statement

`.codex/hooks/enforce-completion-helpers.ps1` remains at 33 / 43 = 76.74%, identical to the [P0-T5] baseline. It is pre-existing and unchanged on this branch, outside the C7 verdict set, and not a regression introduced by [P1-T1].
