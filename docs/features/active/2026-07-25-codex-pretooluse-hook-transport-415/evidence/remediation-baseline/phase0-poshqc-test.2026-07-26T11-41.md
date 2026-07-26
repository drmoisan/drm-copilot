# Phase 0 — Baseline PoshQC Test + Coverage (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P0-T5]

Timestamp: 2026-07-26T11-41

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`

EXIT_CODE: 0

Raw result:

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-07-25T16-53'."}
```

Coverage extraction command (C4 method, package-qualified): parse `artifacts/pester/powershell-coverage.xml`, key on `package/@name` and `sourcefile/@name`; a line is covered when `line/@ci > 0`, missed when `line/@ci = 0`.

## Output Summary

### Test counts (from `artifacts/pester/pester-junit.xml`, `testsuites` root element)

- tests = **1429**
- failures = **0**
- errors = **0**
- disabled/skipped = 9
- time = 124.189 s
- Verdict: **all suites green**

### Repo-wide line coverage (PRE-REMEDIATION MEASURED BASELINE — the post-rebase anchor)

From the report-level `<counter type="LINE">`:

- covered = **2160**
- missed = **235**
- total instrumented = **2395**
- **line coverage = 2160 / 2395 = 90.19%**

Comparison to the pre-rebase delivered-cycle figure: `evidence/qa-gates/coverage-comparison.2026-07-25T21-06.md` recorded 2151 / 2386 = 90.15%. As the plan predicted (RI-4, [P0-T5] text), this figure does not reproduce exactly. The delta is +9 covered / +9 instrumented, entirely accounted for by the two rebase-affected `.claude/lib` modules (see next section): their instrumented totals grew from 43 → 46 (`ModelRouting.psm1`, +3) and 100 → 106 (`OrchestratorState.psm1`, +6), and all 9 added lines are covered by the 208 lines of new Pester tests the rebase brought in. Missed count is unchanged at 235.

### Rebase-affected modules (issue #412 changes to files already in `CodeCoverage.Path`)

| Package | File | Covered | Missed | Total | Percent |
|---|---|---:|---:|---:|---:|
| `.claude/lib/model-routing` | `ModelRouting.psm1` | 46 | 0 | 46 | 100.00% |
| `.claude/lib/orchestrator-state` | `OrchestratorState.psm1` | 103 | 3 | 106 | 97.17% |

Rebase-induced movement term for [P6-T8]: **+9 covered / +9 instrumented / +0 missed** relative to the pre-rebase measurement (43 and 100 instrumented respectively). Both modules are above the 85% per-file threshold; neither is in this branch's diff.

### Currently measured `.codex/hooks` files (C4 package-qualified extraction, package `.../.codex/hooks`)

| File | Covered | Missed | Total | Percent |
|---|---:|---:|---:|---:|
| `enforce-completion-consistency.ps1` | 67 | 69 | 136 | **49.26%** |
| `enforce-completion-helpers.ps1` | 33 | 10 | 43 | **76.74%** |

`enforce-completion-consistency.ps1` is a changed production file on this branch and is in the C7 verdict set. `enforce-completion-helpers.ps1` is measured but is NOT in this branch's diff; it is outside the C7 verdict set and its 76.74% is pre-existing.

Package-name disambiguation confirmed: the `.claude/hooks` package contains same-named counterparts measuring 91.87% (`enforce-completion-consistency.ps1`, 113/123) and 93.02% (`enforce-completion-helpers.ps1`, 40/43). Name-only extraction would have reported those passing figures. The C4 package-qualified method is therefore mandatory and was used.

### The 8 C5 paths are NOT yet measured

None of the 8 paths listed in convention C5 appears in `artifacts/pester/powershell-coverage.xml` at baseline. The `.codex/hooks` package contains exactly two sourcefiles (the two tabulated above). This is finding R1 in measured form: the shared module `codex-pretooluse-file-mapping.ps1` (474 lines) and 7 of the 8 rewired hooks are unmeasured production surface.

### Branch coverage — documented toolchain limitation

PowerShell branch coverage is not separately measurable in this toolchain (`spec.md:248`). The JaCoCo XML emitted by `run_poshqc_test` contains report-level counters of type `INSTRUCTION` (missed=338, covered=2947), `LINE`, `METHOD` (missed=28, covered=167), and `CLASS` (missed=2, covered=29) only — there is no `BRANCH` counter, and every `line` element's `mb`/`cb` (missed-branch / covered-branch) attributes are 0. The >= 75% branch threshold is therefore evaluated for Python only in this remediation; the PowerShell branch figure is unavailable by tooling limitation, not by omission.
