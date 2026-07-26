# Per-File Coverage Extraction and Gap Identification (Remediation Cycle 1, Phase 1)

- **Issue:** #415
- **Task:** [P1-T3]
- **Finding:** R1

Timestamp: 2026-07-26T11-41

## Commands

1. Test invocation producing the XML ([P1-T2] command 4, CI-equivalent path):
   `pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`
   EXIT_CODE: 0
2. XML parse (C4, package-qualified): parse `artifacts/pester/powershell-coverage.xml`; select `package/@name` ending in `.codex/hooks`; for each `sourcefile`, a line is covered when `line/@ci > 0` and missed when `line/@ci = 0`; missed line numbers from `sourcefile/line[@ci='0']/@nr`.
   EXIT_CODE: 0

The [P1-T2] MCP `run_poshqc_test` call also completed with EXIT_CODE 0 but, for the transport reason documented in `evidence/other/remediation-phase1-poshqc-loop.2026-07-26T11-41.md`, its XML does not contain the 8 newly configured paths. The extraction below uses the CI-equivalent workspace-module run.

## Output Summary

Repo-wide line coverage: **2334 / 3042 = 76.73%** (missed 708). Ten sourcefiles are present under the `.codex/hooks` package. Of the 9 files in the C7 verdict set, one (`codex-pretooluse-file-mapping.ps1`) is above 70% and eight are below the 85% per-file threshold; three are at 0%. No in-process entrypoint case (C6 `SetIn` pattern) exists for any of the 8 guarded hooks — verified by `grep -rn "SetIn\|StringReader" tests/` returning no match and `grep -rn '& \$' tests/scripts/codex-hooks/*.ps1` returning no match.

## (i) Per-file table — all 10 measured `.codex/hooks` files

Package key: `C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-25T16-53/.codex/hooks`

| # | File | Covered | Missed | Total instrumented | Percent | In C7 verdict set |
|---|---|---:|---:|---:|---:|---|
| 1 | `codex-pretooluse-file-mapping.ps1` | 79 | 22 | 101 | 78.22% | yes (module) |
| 2 | `check-python-test-purity.ps1` | 0 | 67 | 67 | 0.00% | yes |
| 3 | `check-powershell-test-purity.ps1` | 0 | 62 | 62 | 0.00% | yes |
| 4 | `enforce-python-batch-budget.ps1` | 26 | 61 | 87 | 29.89% | yes |
| 5 | `enforce-powershell-batch-budget.ps1` | 26 | 61 | 87 | 29.89% | yes |
| 6 | `enforce-evidence-locations.ps1` | 0 | 41 | 41 | 0.00% | yes |
| 7 | `enforce-checkpoint-monotonic.ps1` | 5 | 99 | 104 | 4.81% | yes |
| 8 | `enforce-orchestration-preimplementation-gate.ps1` | 38 | 60 | 98 | 38.78% | yes |
| 9 | `enforce-completion-consistency.ps1` | 67 | 69 | 136 | 49.26% | yes |
| 10 | `enforce-completion-helpers.ps1` | 33 | 10 | 43 | 76.74% | **no** |

C7 verdict-set totals (rows 1–9): covered 241, missed 542, instrumented 783 → 30.78%.

### Package-qualification necessity (C4)

Six of these file names also exist under the `.claude/hooks` package, where they measure much higher. Name-only extraction would silently report those passing numbers:

| File name | `.codex/hooks` (this branch) | `.claude/hooks` (counterpart) |
|---|---:|---:|
| `check-python-test-purity.ps1` | 0/67 = 0.00% | 60/60 = 100.00% |
| `check-powershell-test-purity.ps1` | 0/62 = 0.00% | 54/55 = 98.18% |
| `enforce-python-batch-budget.ps1` | 26/87 = 29.89% | 78/81 = 96.30% |
| `enforce-powershell-batch-budget.ps1` | 26/87 = 29.89% | 78/81 = 96.30% |
| `enforce-completion-consistency.ps1` | 67/136 = 49.26% | 113/123 = 91.87% |
| `enforce-completion-helpers.ps1` | 33/43 = 76.74% | 40/43 = 93.02% |

All figures in this artifact are package-qualified to `.codex/hooks`.

## Guard-line positions (C6 basis, measured at HEAD)

Measured with `grep -n "InvocationName -eq '\.'"`:

| File | Guard line | Total file lines |
|---|---:|---:|
| `check-python-test-purity.ps1` | 145 | 166 |
| `check-powershell-test-purity.ps1` | 145 | 166 |
| `enforce-python-batch-budget.ps1` | 217 | 254 |
| `enforce-powershell-batch-budget.ps1` | 219 | 256 |
| `enforce-evidence-locations.ps1` | 192 | 196 |
| `enforce-checkpoint-monotonic.ps1` | 312 | 339 |
| `enforce-orchestration-preimplementation-gate.ps1` | 231 | 265 |
| `enforce-completion-consistency.ps1` | 414 | 438 |
| `codex-pretooluse-file-mapping.ps1` | none (entrypoint-free) | 474 |

These reproduce the positions recorded in plan convention C6 exactly.

## (a) Guarded-entrypoint missed lines — C6-justified exclusions

**None, for any file.** Per C6 (preflight RC-10), a missed line may be classified `guarded-entrypoint-unreachable` only with BOTH (1) an attempted in-process entrypoint case invoking `& $hookPath` with stdin redirected via `[System.Console]::SetIn([System.IO.StringReader]::new(...))` and readers restored in `finally`, and (2) a named per-line reason it cannot be reached after that attempt.

No such attempt exists anywhere in the repository at this point in execution. Verified:

- `grep -rn "SetIn\|StringReader" tests/` → no matches.
- `grep -rn '& \$' tests/scripts/codex-hooks/*.ps1` → no matches.

Therefore section (a) is empty for all 9 verdict-set files, and every post-guard missed line falls to sections (b) and (c) as C6 requires.

## (b) Dot-source-reachable missed lines

Post-guard lines are listed separately for bookkeeping only; per C6 they are counted as dot-source-reachable here because no entrypoint attempt exists yet.

### 1. `codex-pretooluse-file-mapping.ps1` — 22 missed, all dot-source-reachable

No guard exists; the module is entrypoint-free, so all missed lines are dot-source-reachable and the >= 85% threshold applies to the raw per-file number with no residual allowance.

Missed: 121, 122, 126, 128, 133, 136, 139, 140, 143, 224, 231, 243, 261, 266, 271, 385, 427, 433, 434, 456, 457, 468

- Pre-guard (n/a — no guard): 22
- Post-guard: 0

### 2. `check-python-test-purity.ps1` — 67 missed

Missed: 35, 45, 46, 47, 48, 49, 62, 63, 73, 74, 78, 80, 83, 84, 85, 88, 89, 92, 93, 94, 95, 96, 99, 100, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 128, 129, 130, 131, 135, 136, 139, 140, 142, 145, 153, 154, 155, 156, 157, 158, 159, 162, 164, 165

- Below/at guard (<= 145): 57 lines
- Post-guard (> 145): 153, 154, 155, 156, 157, 158, 159, 162, 164, 165 — 10 lines

### 3. `check-powershell-test-purity.ps1` — 62 missed

Missed: 38, 48, 49, 50, 51, 52, 65, 66, 76, 77, 81, 84, 87, 88, 89, 92, 93, 96, 97, 98, 100, 101, 104, 105, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 128, 129, 130, 131, 135, 136, 139, 140, 142, 145, 153, 154, 155, 156, 157, 158, 159, 162, 164, 165

- Below/at guard (<= 145): 52 lines
- Post-guard (> 145): 153, 154, 155, 156, 157, 158, 159, 162, 164, 165 — 10 lines

### 4. `enforce-python-batch-budget.ps1` — 61 missed

Missed: 74, 75, 76, 77, 78, 80, 123, 132, 141, 142, 144, 147, 156, 159, 160, 161, 164, 168, 169, 173, 175, 178, 179, 180, 183, 184, 185, 188, 189, 190, 193, 194, 196, 198, 199, 201, 205, 206, 208, 210, 214, 224, 225, 226, 227, 228, 234, 235, 236, 237, 238, 241, 242, 243, 244, 245, 246, 247, 250, 252, 253

- Below/at guard (<= 217): 41 lines
- Post-guard (> 217): 224, 225, 226, 227, 228, 234, 235, 236, 237, 238, 241, 242, 243, 244, 245, 246, 247, 250, 252, 253 — 20 lines

### 5. `enforce-powershell-batch-budget.ps1` — 61 missed

Missed: 76, 77, 78, 79, 80, 82, 125, 134, 143, 144, 146, 149, 158, 161, 162, 163, 166, 170, 171, 175, 177, 180, 181, 182, 185, 186, 187, 190, 191, 192, 195, 196, 198, 200, 201, 203, 207, 208, 210, 212, 216, 226, 227, 228, 229, 230, 236, 237, 238, 239, 240, 243, 244, 245, 246, 247, 248, 249, 252, 254, 255

- Below/at guard (<= 219): 41 lines
- Post-guard (> 219): 226, 227, 228, 229, 230, 236, 237, 238, 239, 240, 243, 244, 245, 246, 247, 248, 249, 252, 254, 255 — 20 lines

### 6. `enforce-evidence-locations.ps1` — 41 missed

Missed: 46, 63, 65, 66, 79, 80, 81, 82, 86, 103, 104, 105, 106, 107, 126, 127, 131, 134, 137, 138, 139, 142, 143, 146, 163, 169, 170, 171, 172, 173, 176, 177, 178, 179, 180, 181, 184, 186, 187, 192, 196

- Below/at guard (<= 192): 40 lines
- Post-guard (> 192): 196 — 1 line

### 7. `enforce-checkpoint-monotonic.ps1` — 99 missed

Missed: 82, 99, 100, 101, 102, 108, 125, 126, 127, 128, 129, 133, 134, 135, 136, 137, 138, 139, 140, 146, 160, 171, 172, 173, 174, 175, 177, 178, 182, 183, 184, 185, 186, 187, 188, 193, 204, 218, 219, 223, 226, 229, 230, 231, 234, 235, 236, 242, 243, 244, 245, 246, 251, 254, 255, 256, 260, 261, 264, 265, 266, 267, 271, 272, 273, 275, 276, 279, 280, 281, 282, 283, 284, 285, 290, 291, 292, 293, 294, 296, 297, 299, 300, 301, 302, 303, 308, 323, 324, 325, 327, 328, 329, 330, 331, 332, 335, 337, 338

- Below/at guard (<= 312): 87 lines
- Post-guard (> 312): 323, 324, 325, 327, 328, 329, 330, 331, 332, 335, 337, 338 — 12 lines

### 8. `enforce-orchestration-preimplementation-gate.ps1` — 60 missed

Missed: 50, 53, 63, 64, 65, 68, 69, 70, 71, 74, 75, 76, 77, 81, 82, 89, 90, 91, 94, 102, 103, 106, 107, 116, 126, 133, 134, 145, 146, 148, 156, 157, 158, 159, 190, 195, 204, 205, 206, 208, 213, 217, 222, 226, 236, 237, 242, 243, 244, 245, 247, 253, 254, 255, 256, 257, 258, 261, 263, 264

- Below/at guard (<= 231): 44 lines
- Post-guard (> 231): 236, 237, 242, 243, 244, 245, 247, 253, 254, 255, 256, 257, 258, 261, 263, 264 — 16 lines

### 9. `enforce-completion-consistency.ps1` — 69 missed

Missed: 90, 91, 93, 125, 133, 154, 162, 163, 164, 165, 170, 171, 172, 173, 177, 195, 205, 214, 230, 234, 248, 254, 255, 256, 259, 260, 261, 262, 295, 296, 297, 299, 300, 303, 304, 305, 308, 309, 311, 314, 315, 317, 321, 346, 353, 358, 363, 371, 372, 373, 374, 375, 384, 385, 386, 391, 400, 422, 423, 424, 426, 427, 428, 429, 430, 431, 434, 436, 437

- Below/at guard (<= 414): 57 lines
- Post-guard (> 414): 422, 423, 424, 426, 427, 428, 429, 430, 431, 434, 436, 437 — 12 lines

This reproduces the empirical anchor stated in plan interpretation RI-5 exactly (57 dot-source-reachable below the guard, 12 post-guard).

## (c) Exercisability partition of the (b) lines (RI-5)

RI-5: a dot-source-reachable missed line is EXERCISABLE unless the enclosing function or script region cannot be invoked by a dot-sourced in-process test without changing the hook. For every line classified non-exercisable, the enclosing function/region must be named and the reason invocation is impossible must be stated.

| File | Missed | Exercisable | Non-exercisable | Notes |
|---|---:|---:|---:|---|
| `codex-pretooluse-file-mapping.ps1` | 22 | 22 | 0 | Entrypoint-free module. Every missed line lies inside an exported or internal function (`ConvertFrom-CodexPreToolUsePayload`, `ConvertTo-CodexFileEditInput`, `ConvertTo-CodexAddedLineText`, `Test-CodexGovernedPath`, `Resolve-CodexUpdatedFileContent`) reachable by dot-sourcing the module and calling the function with the appropriate input. |
| `check-python-test-purity.ps1` | 67 | 67 | 0 | 57 below the guard are inside dot-source-callable policy/helper functions. The 10 post-guard lines are the script body after the guard; per C6 they count as exercisable because no in-process entrypoint attempt exists yet. |
| `check-powershell-test-purity.ps1` | 62 | 62 | 0 | Same structure; 52 below the guard, 10 post-guard. |
| `enforce-python-batch-budget.ps1` | 61 | 61 | 0 | 41 below the guard, 20 post-guard. |
| `enforce-powershell-batch-budget.ps1` | 61 | 61 | 0 | 41 below the guard, 20 post-guard. |
| `enforce-evidence-locations.ps1` | 41 | 41 | 0 | 40 below the guard, 1 post-guard (line 196, the terminal `exit`/stdin region). |
| `enforce-checkpoint-monotonic.ps1` | 99 | 99 | 0 | 87 below the guard, 12 post-guard. |
| `enforce-orchestration-preimplementation-gate.ps1` | 60 | 60 | 0 | 44 below the guard, 16 post-guard. |
| `enforce-completion-consistency.ps1` | 69 | 69 | 0 | 57 below the guard, 12 post-guard. Matches the RI-5 anchor. |
| **Total (C7 verdict set)** | **542** | **542** | **0** | |

No line is classified non-exercisable at this stage, so no per-line non-exercisability justification is owed. The classification is mechanical: all missed lines below each guard sit inside named functions that a dot-sourced test can call directly, and all post-guard lines lack the C6 justification (no entrypoint attempt exists), which C6 explicitly directs to be treated as dot-source-reachable and exercisable.

## In-process entrypoint case status (C6), per hook

| Hook | In-process entrypoint case exists? |
|---|---|
| `check-python-test-purity.ps1` | NO |
| `check-powershell-test-purity.ps1` | NO |
| `enforce-python-batch-budget.ps1` | NO |
| `enforce-powershell-batch-budget.ps1` | NO |
| `enforce-evidence-locations.ps1` | NO |
| `enforce-checkpoint-monotonic.ps1` | NO |
| `enforce-orchestration-preimplementation-gate.ps1` | NO |
| `enforce-completion-consistency.ps1` | NO |
| `codex-pretooluse-file-mapping.ps1` | n/a (entrypoint-free module) |

Existing `tests/scripts/codex-hooks/` suites drive these hooks by process spawn (`System.Diagnostics.ProcessStartInfo` with `RedirectStandardInput`), which contributes no in-process Pester coverage. This is the mechanical reason the newly measured files sit at or near 0% despite having behavioral test coverage.

## Pre-existing, out-of-scope file statement (preflight Section 7 advisory)

`.codex/hooks/enforce-completion-helpers.ps1` measures **33 / 43 = 76.74%**, which is below the 85% per-file threshold. This file is **pre-existing and unchanged on this branch**: it does not appear in `git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD`, it was added to `CodeCoverage.Path` by issue #301 (not by this remediation), and its 76.74% figure is identical to the [P0-T5] pre-remediation baseline. It is therefore **outside the C7 verdict set** and its number is **not a regression introduced by [P1-T1]**. No verdict is owed for it and no work in this plan targets it.

## Gap summary driving Phases 2–4

Lines that must be newly covered to bring each verdict-set file to the 85% per-file threshold (raw):

| File | Instrumented | Covered now | Needed for 85% | Newly covered required |
|---|---:|---:|---:|---:|
| `codex-pretooluse-file-mapping.ps1` | 101 | 79 | 86 | 7 |
| `check-python-test-purity.ps1` | 67 | 0 | 57 | 57 |
| `check-powershell-test-purity.ps1` | 62 | 0 | 53 | 53 |
| `enforce-python-batch-budget.ps1` | 87 | 26 | 74 | 48 |
| `enforce-powershell-batch-budget.ps1` | 87 | 26 | 74 | 48 |
| `enforce-evidence-locations.ps1` | 41 | 0 | 35 | 35 |
| `enforce-checkpoint-monotonic.ps1` | 104 | 5 | 89 | 84 |
| `enforce-orchestration-preimplementation-gate.ps1` | 98 | 38 | 84 | 46 |
| `enforce-completion-consistency.ps1` | 136 | 67 | 116 | 49 |
| **Total** | **783** | **241** | **668** | **427** |

Repo-wide implication: reaching 427 newly covered lines takes the repo-wide figure to 2761 / 3042 = 90.76%, comfortably above the 85% gate. Reaching 85% repo-wide alone requires 2586 covered, i.e. +252 newly covered lines; the per-file gates are the binding constraint, not the repo-wide gate.
