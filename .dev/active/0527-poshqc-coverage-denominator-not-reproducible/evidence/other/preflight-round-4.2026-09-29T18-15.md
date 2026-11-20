# Preflight Round 4 — Plan for Issue #527

Timestamp: 2026-09-29T18-15
Plan: docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/plan.2026-09-29T15-32.md (version 1.3)
Reviewer: atomic-executor (DIRECTIVE: PREFLIGHT VALIDATION ONLY)
Result: PREFLIGHT: REVISIONS REQUIRED
Convergence: CONVERGENCE: NO FURTHER ROUNDS EXPECTED (single-sentence delta; one confirming round expected to clear)

## Verified

- Round-3 deltas 1-3 applied verbatim (plan lines 66, 306, 398, 400).
- Seam rewrite verified against PoshQC.Testing.psm1 (463 lines): R1-R3 reach the coverage block and fail on assertion pre-fix; R4-R6 fail on parameter binding pre-fix; F, C, P tests fail on command resolution pre-fix; no test reaches the real Invoke-Pester or filesystem. Two Pester probes (StrictMode Latest; mismatch message contains `Expected`) run in the session scratchpad.
- Counts 13 + 10 = 23 titles, PASSED >= 30; AC mapping consistent; no regression of rounds 1-3; validator exit 0 with the three G7 false-positive warnings.

## Defect and delta

1. D1 (implemented in P3-T2): parameter mandatoriness is unstated; an executor following `PoshQC.ScanConfig.psm1` line 35 style could declare Mandatory `[string[]]` parameters, which reject empty arrays and would break the four TestingCoveragePruning tests (`-ResolveScanConfig { @() }` at lines 64, 115, 175, 238), test P6, and empty `roots`. Delta: append to the first sentence of D1 (after "…through `InModuleScope PoshQC`."): "No parameter of the four functions is declared `Mandatory`: an empty `-Roots` or `-ScanFolderRoots` array and an empty or omitted `-SettingsFile` bind without error. The D3 (a) default seam passes an empty `-ScanFolderRoots` whenever `-ScanFolders` is absent and `-ResolveScanConfig` returns nothing (as in `PoshQC.TestingCoveragePruning.Tests.ps1` lines 64, 115, 175, and 238). Test P6 supplies no scan folders, an empty `roots` array reaches `-Roots`, and D2 treats a blank `-SettingsFile` as not caller-supplied."

## Non-defect notes for the executor

- R6 states no `-Root` and defaults to `$PWD`; all filesystem seams are injected.
- The `Get-ChildItem` mock must read `$LiteralPath`; the R1/R2 `-TestPathExists` must normalize separators; F7 and P7 empty assertions must use the pipeline form of `Should -Be @()`.
