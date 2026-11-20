# Interim Per-File Coverage and Batch-2 Gap List (Remediation Cycle 1, Phase 2)

- **Issue:** #415
- **Task:** [P2-T4]
- **Finding:** R1

Timestamp: 2026-07-26T11-41

Command: re-extraction per C4 (package-qualified on `package/@name` ending `.codex/hooks`) from the [P2-T3] run of
`pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`,
parsing `artifacts/pester/powershell-coverage.xml`.

EXIT_CODE: 0

Output Summary: three of the nine C7 verdict-set files now meet or exceed the 85% per-file threshold (`codex-pretooluse-file-mapping.ps1` 100.00%, `enforce-orchestration-preimplementation-gate.ps1` 100.00%, `enforce-completion-consistency.ps1` 91.18%). Six remain below threshold and constitute the Phase 3 batch-2 scope. Repo-wide line coverage is 2473 / 3042 = 81.30%.

## (i) Per-file table — all 10 measured `.codex/hooks` files

| # | File | Covered | Missed | Total | Percent | Δ vs [P1-T3] | >= 85%? |
|---|---|---:|---:|---:|---:|---:|---|
| 1 | `codex-pretooluse-file-mapping.ps1` | 101 | 0 | 101 | **100.00%** | +22 | YES |
| 2 | `check-python-test-purity.ps1` | 0 | 67 | 67 | 0.00% | 0 | no |
| 3 | `check-powershell-test-purity.ps1` | 0 | 62 | 62 | 0.00% | 0 | no |
| 4 | `enforce-python-batch-budget.ps1` | 26 | 61 | 87 | 29.89% | 0 | no |
| 5 | `enforce-powershell-batch-budget.ps1` | 26 | 61 | 87 | 29.89% | 0 | no |
| 6 | `enforce-evidence-locations.ps1` | 0 | 41 | 41 | 0.00% | 0 | no |
| 7 | `enforce-checkpoint-monotonic.ps1` | 5 | 99 | 104 | 4.81% | 0 | no |
| 8 | `enforce-orchestration-preimplementation-gate.ps1` | 98 | 0 | 98 | **100.00%** | +60 | YES |
| 9 | `enforce-completion-consistency.ps1` | 124 | 12 | 136 | **91.18%** | +57 | YES |
| 10 | `enforce-completion-helpers.ps1` (out of verdict set) | 33 | 10 | 43 | 76.74% | 0 | n/a |

C7 verdict-set totals (rows 1–9): covered 380, missed 403, instrumented 783 → 48.53% (was 30.78%).

## (ii) `NO-GAP` records from [P2-T1] and [P2-T2]

**[P2-T1] — shared module.** The branch condition did NOT apply: [P1-T3] measured `codex-pretooluse-file-mapping.ps1` at 78.22% raw, below 85%, so `NO-GAP` was not recordable. The gap-closure path was taken: `tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1` was created (411 lines, ≤ 500), dot-sourcing the ROOT module in-process, with 37 cases targeting exactly the 22 dot-source-reachable missed lines identified at [P1-T3] plus the four additional lines (459, 460, 470, 473) that the first isolated measurement exposed. Result: **101 / 101 = 100.00%**, verified raw with no residual allowance (C6: the module is entrypoint-free). No production change, no temporary file, no assertion weakened.

**[P2-T2] — guarded hooks, batch 1.** `NO-GAP` was not recordable for any of the 8 guarded hooks: [P1-T3] item (c) listed exercisable missed lines for every one of them, and no hook had an attempted in-process entrypoint case. Per the [P2-T2] text, `NO-GAP` MUST NOT be recorded for a hook whose entrypoint has never been attempted in-process, so the gap-closure path was taken for the two prioritized hooks.

Work performed in this batch (0 production files, 3 test files total for Phase 2 — 1 new from [P2-T1] plus 2 edited here):

- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — 278 → **478** lines (200 added, headroom 222 respected). Added `Context 'enforce-orchestration-preimplementation-gate in-process behaviour (issue #415 R1)'`: dot-sourced unit cases for `Test-ImplementationPath`, `Test-ImplementationCommand`, `Test-ImplementationDelegation`, `Test-OrchestrationReady`, `Get-CheckpointContent`, and `Invoke-OrchestrationPreimplementationGateDecision`, plus **four in-process entrypoint cases** (C6) invoking `& $script:GateHookPath` with `[System.Console]::SetIn([System.IO.StringReader]::new($PayloadRaw))` and `[System.Console]::SetError(...)`, with both readers restored in `finally`. Result: **98 / 98 = 100.00%**.
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1` — 269 → **489** lines (220 added, headroom 231 respected). Added `Context 'enforce-completion-consistency in-process behaviour (issue #415 R1)'`: dot-sourced unit cases for `Get-CheckpointFileContent`, `Get-CheckpointStringValue`, `Test-CompletionAsserted`, `Resolve-EditedCheckpointContent`, `Get-MissingCompletionEvidence`, and `Invoke-CompletionConsistencyDecision`, plus **three in-process entrypoint cases** (C6) using the same `SetIn` pattern. Result: **124 / 136 = 91.18%**.

No hook file, policy function, deny-path assertion, or fail-closed assertion was changed. No temporary file was created: process-level cases continue to use `ProcessStartInfo` with `RedirectStandardInput`, and the new in-process cases use `SetIn` with a `StringReader`.

## (iii) Remaining exercisable missed lines per C7 file — the Phase 3 batch-2 work

Guard positions are unchanged from [P1-T3]. Post-guard lines that still lack a C6 justification (no attempted in-process entrypoint case for that hook) are counted as dot-source-reachable and exercisable per C6/RI-5.

### `codex-pretooluse-file-mapping.ps1` — CLOSED
Remaining exercisable missed lines: **none** (0 missed). Entrypoint-free module; no entrypoint case is applicable.

### `enforce-orchestration-preimplementation-gate.ps1` — CLOSED
Remaining exercisable missed lines: **none** (0 missed).

### `enforce-completion-consistency.ps1` — 12 remaining, all exercisable, carried to Phase 4
Missed: 248, 254, 255, 256, 259, 260, 261, 262, 384, 385, 386, 400.
All are below the guard at line 414 and therefore dot-source-reachable. Enclosing regions:
- 248, 254, 255, 256, 259, 260, 261, 262 — the `pr_gate` evidence block inside `Get-MissingCompletionEvidence`, reachable only when `Test-RouteRequiresPrGate` returns `$true`, which requires an injected `RoutingMatrixReader` returning a matrix whose selected route sets `requires_pr_gate = $true`.
- 384, 385, 386 — the invalid-checkpoint-JSON deny branch of `Invoke-CompletionConsistencyDecision`.
- 400 — the all-evidence-present allow branch of `Invoke-CompletionConsistencyDecision`.
The two existing test files edited in this batch are at 478 and 489 lines against the 500-line cap, so this remainder does not fit in Phase 2 capacity and is carried forward exactly as [P2-T2] anticipated. This hook is already above the 85% threshold at 91.18%; the carried work raises it further.

### `check-python-test-purity.ps1` — 67 remaining, all exercisable
Missed: 35, 45, 46, 47, 48, 49, 62, 63, 73, 74, 78, 80, 83, 84, 85, 88, 89, 92, 93, 94, 95, 96, 99, 100, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 128, 129, 130, 131, 135, 136, 139, 140, 142, 145, 153, 154, 155, 156, 157, 158, 159, 162, 164, 165. Guard at 145; 57 below the guard, 10 post-guard and unjustified.

### `check-powershell-test-purity.ps1` — 62 remaining, all exercisable
Missed: 38, 48, 49, 50, 51, 52, 65, 66, 76, 77, 81, 84, 87, 88, 89, 92, 93, 96, 97, 98, 100, 101, 104, 105, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 128, 129, 130, 131, 135, 136, 139, 140, 142, 145, 153, 154, 155, 156, 157, 158, 159, 162, 164, 165. Guard at 145; 52 below, 10 post-guard and unjustified.

### `enforce-python-batch-budget.ps1` — 61 remaining, all exercisable
Missed: 74, 75, 76, 77, 78, 80, 123, 132, 141, 142, 144, 147, 156, 159, 160, 161, 164, 168, 169, 173, 175, 178, 179, 180, 183, 184, 185, 188, 189, 190, 193, 194, 196, 198, 199, 201, 205, 206, 208, 210, 214, 224, 225, 226, 227, 228, 234, 235, 236, 237, 238, 241, 242, 243, 244, 245, 246, 247, 250, 252, 253. Guard at 217; 41 below, 20 post-guard and unjustified.

### `enforce-powershell-batch-budget.ps1` — 61 remaining, all exercisable
Missed: 76, 77, 78, 79, 80, 82, 125, 134, 143, 144, 146, 149, 158, 161, 162, 163, 166, 170, 171, 175, 177, 180, 181, 182, 185, 186, 187, 190, 191, 192, 195, 196, 198, 200, 201, 203, 207, 208, 210, 212, 216, 226, 227, 228, 229, 230, 236, 237, 238, 239, 240, 243, 244, 245, 246, 247, 248, 249, 252, 254, 255. Guard at 219; 41 below, 20 post-guard and unjustified.

### `enforce-evidence-locations.ps1` — 41 remaining, all exercisable
Missed: 46, 63, 65, 66, 79, 80, 81, 82, 86, 103, 104, 105, 106, 107, 126, 127, 131, 134, 137, 138, 139, 142, 143, 146, 163, 169, 170, 171, 172, 173, 176, 177, 178, 179, 180, 181, 184, 186, 187, 192, 196. Guard at 192; 40 below, 1 post-guard (196) and unjustified.

### `enforce-checkpoint-monotonic.ps1` — 99 remaining, all exercisable
Missed: 82, 99, 100, 101, 102, 108, 125, 126, 127, 128, 129, 133, 134, 135, 136, 137, 138, 139, 140, 146, 160, 171, 172, 173, 174, 175, 177, 178, 182, 183, 184, 185, 186, 187, 188, 193, 204, 218, 219, 223, 226, 229, 230, 231, 234, 235, 236, 242, 243, 244, 245, 246, 251, 254, 255, 256, 260, 261, 264, 265, 266, 267, 271, 272, 273, 275, 276, 279, 280, 281, 282, 283, 284, 285, 290, 291, 292, 293, 294, 296, 297, 299, 300, 301, 302, 303, 308, 323, 324, 325, 327, 328, 329, 330, 331, 332, 335, 337, 338. Guard at 312; 87 below, 12 post-guard and unjustified.

**Phase 3 batch-2 assignment (per plan [P3-T1] cluster split):**
- `codex-test-purity-hooks.Tests.ps1` → `check-python-test-purity.ps1` + `check-powershell-test-purity.ps1` (129 lines to cover).
- `codex-batch-budget-hooks.Tests.ps1` → `enforce-python-batch-budget.ps1` + `enforce-powershell-batch-budget.ps1` (122 lines to cover).
- `codex-evidence-and-checkpoint-hooks.Tests.ps1` → `enforce-evidence-locations.ps1` + `enforce-checkpoint-monotonic.ps1` (140 lines to cover).

Any remainder after Phase 3 carries to Phase 4 batch 3, together with the 12 `enforce-completion-consistency.ps1` lines listed above.

## In-process entrypoint case status (C6), per hook — after batch 1

| Hook | Attempted in-process entrypoint case exists? |
|---|---|
| `enforce-orchestration-preimplementation-gate.ps1` | **YES** (4 cases, `legacy-codex-hook-contracts.Tests.ps1`) |
| `enforce-completion-consistency.ps1` | **YES** (3 cases, `codex-pretooluse-transport.Tests.ps1`) |
| `check-python-test-purity.ps1` | NO |
| `check-powershell-test-purity.ps1` | NO |
| `enforce-python-batch-budget.ps1` | NO |
| `enforce-powershell-batch-budget.ps1` | NO |
| `enforce-evidence-locations.ps1` | NO |
| `enforce-checkpoint-monotonic.ps1` | NO |
| `codex-pretooluse-file-mapping.ps1` | n/a (entrypoint-free module) |

Both hooks with attempted entrypoint cases reached 100.00% and 91.18% respectively, and neither has any post-guard line still uncovered — so no C6 justified exclusion is claimed or needed for either.

## (iv) Current repo-wide line percentage

- covered = **2473**
- missed = **569**
- total instrumented = **3042**
- **line coverage = 2473 / 3042 = 81.30%** (was 76.73% at [P1-T2])
- The >= 85% gate binds at [P4-T3] and [P6-T3], not here.

## Pre-existing, out-of-scope file statement

`.codex/hooks/enforce-completion-helpers.ps1` remains at 33 / 43 = 76.74%, unchanged from the [P0-T5] baseline. It is pre-existing and unchanged on this branch, outside the C7 verdict set, and not a regression introduced by [P1-T1].
