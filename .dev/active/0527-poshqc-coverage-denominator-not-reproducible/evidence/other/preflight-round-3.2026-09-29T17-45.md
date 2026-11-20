# Preflight Round 3 — Plan for Issue #527

Timestamp: 2026-09-29T17-45
Plan: docs/features/active/2026-08-23-poshqc-coverage-denominator-not-reproducible-527/plan.2026-09-29T15-32.md (version 1.2)
Reviewer: atomic-executor (DIRECTIVE: PREFLIGHT VALIDATION ONLY)
Result: PREFLIGHT: REVISIONS REQUIRED
Convergence: CONVERGENCE: FURTHER ROUNDS LIKELY (one confirming round expected; deltas are text-only)

## Verified

- Round-2 deltas A and B applied verbatim (plan lines 66 and 400).
- Seam parameters exist on `Invoke-PoshQCTest`: `$EnsureModule` 160, `$TestPathExists` 167, `$LoadSettings` 168, `$BuildConfiguration` 169, `$Logger` 256-260, `$InvokePester` 261-281, `$CopyCoverage` 282-285; file 463 lines.
- All 18 AC check-off tasks (P6-T31..P6-T48) match spec.md lines 266-283 in order; tokens single-line; P6-T48 sentinels exist.
- No regression of round-1 or round-2 resolutions. Validator exit 0 with the same three G7 warnings (false positives).

## Defects and deltas

1. D13 last sentence and P2-T2 R4/R5: R4 and R5 never reach `-InvokePester` (R1 settings have no `Run.Path`; default `-EnumerateTests` returns nothing, so the function returns early after logging "No Pester test files found"; default `-ResolveScanConfig` reads the real filesystem).
   - D13: replace "an `-InvokePester` seam that records `$Config` and returns `$null`," with "`-TestPathExists` answering true for every path, `-ResolveScanConfig { @() }` unless the test text names another, an `-EnumerateTests` seam returning one fake test object, an `-InvokePester` seam that records `$Config` and returns `$null`,".
   - P2-T2 R4: replace "`-Root '.'`; default `-ExpandRunPaths`;" with "`-Root '.'`; `-LoadSettings` returns the R1 first settings table plus `Run = @{ Path = @('tests') }`; default `-ExpandRunPaths`;".
   - P2-T2 R4: replace "Asserts every captured `Run.Path` entry," with "Asserts the captured `Run.Path` has at least one entry and that every captured `Run.Path` entry,".
2. P6-T41 (AC-11): replace "after P2-T7 and P6-T17 pass," with "after P1-T5, P2-T7, P6-T16, and P6-T17 pass,".
3. P6-T39 (AC-09): replace "after P6-T2 and P6-T23 pass." with "after P5-T8, P6-T2, and P6-T23 pass.".
