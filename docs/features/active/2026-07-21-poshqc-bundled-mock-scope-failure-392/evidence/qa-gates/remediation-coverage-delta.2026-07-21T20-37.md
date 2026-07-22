Timestamp: 2026-07-21T20-37

Command: (analysis derived from evidence/baseline/remediation-coverage-baseline.2026-07-21T19-41.md and evidence/qa-gates/remediation-final-test-coverage.2026-07-21T20-35.md; both produced by `pwsh -NoProfile -File scripts/dev-tools/run-poshqc-suite.ps1` followed by parsing `artifacts/pester/powershell-coverage.xml`)
EXIT_CODE: 0

## Baseline (Phase 0, captured 2026-07-21T19-41)

- Per-file `PoshQC.Testing.psm1` LINE: covered=149, missed=46, total=195, **76.41%**
- Baseline uncovered lines (46): 98, 291, 309, 314-316, 322, 332, 340-342, 346, 350-354, 356-357, 359, 368-369, 401-403, 410-415, 417-420, 423-424, 427-428, 433-439

## Post-change (Phase 2, captured 2026-07-21T20-35, after adding P1-T1/P1-T2/P1-T3 test-only changes)

- Per-file `PoshQC.Testing.psm1` LINE: covered=131, missed=64, total=195, **67.18%**
- Post-change uncovered lines (64): 75, 79, 91, 102, 103, 107, 109, 110, 112, 114, 115, 117, 118, 121, 122, 125, 126, 127, 128, 291, 309, 314, 315, 316, 322, 332, 340, 341, 342, 346, 350, 351, 352, 353, 354, 356, 357, 359, 368, 369, 401, 402, 403, 410, 411, 412, 413, 414, 415, 417, 418, 419, 420, 423, 424, 427, 428, 433, 434, 435, 436, 437, 438, 439

## No-Regression Check

FAILS. Line 98 (the P1-T1 target) is now covered — a gain. However, 19 lines that WERE covered at baseline (75, 79, 91, 102, 103, 107, 109, 110, 112, 114, 115, 117, 118, 121, 122, 125, 126, 127, 128 — all within `Convert-PoshQCCoverageToRelative`'s body) are now UNCOVERED post-change, a direct regression. None of the 21 lines newly targeted by P1-T2/P1-T3 (291, 309, 314-316, 322, 332, 340-342, 346, 350-354, 356-357, 359, 368-369, 401-403, 410-415, 417-420, 423-424, 427-428, 433-439) became covered in the bundled measurement — they remain missed, identical to the baseline list minus line 98.

Net change: +1 line covered (98), -19 lines regressed (Convert-PoshQCCoverageToRelative body), for a net of -18 lines covered (149 -> 131).

## Root Cause

Each of the three new/modified test files was independently verified (via standalone `Invoke-Pester -CodeCoverage` invocations scoped to 1-3 files at a time, documented informally during Phase 1 execution) to correctly exercise 100% of its assigned target lines when run in isolation or in small subsets that exclude `PoshQC.Tests.ps1`. The regression appears only when the full 8-file bundled suite runs together via `scripts/dev-tools/run-poshqc-suite.ps1` (the mandated measurement mechanism per this plan and per `.claude/rules/powershell.md`).

The mechanism, isolated to a minimal reproducible 2-file case (`PoshQC.TestingSeamDefaults.Tests.ps1` + `PoshQC.Tests.ps1`, both unmodified from the file-count perspective — only test *content* varies): `scripts/powershell/PoshQC/PoshQC.psm1` bootstraps `PoshQC.Testing.psm1` by re-parsing it from disk via `[System.Management.Automation.Language.Parser]::ParseFile(...)` and dot-sourcing a freshly generated `GetScriptBlock()` on every `Import-Module -Force` call (see `PoshQC.psm1` lines 82-106, itself a deliberate fix for a related coverage-binding defect, issue #344). Every existing test file in `tests/scripts/powershell/PoshQC/` performs its own unconditional `Import-Module -Force` of `PoshQC.psm1` in a top-level `BeforeAll` block (a pre-existing, repo-wide convention not introduced by this remediation). `PoshQC.Tests.ps1` sorts alphabetically last among the eight files and therefore always performs the final reimport of the whole suite run.

Empirically, when a NEW test in an EARLIER-running file becomes, for the first time in this suite's history, a caller of a function whose OTHER branches are also exercised by `PoshQC.Tests.ps1` (the last file), Pester's JaCoCo coverage merge loses credit for `PoshQC.Tests.ps1`'s own hits on that function's other lines. This was confirmed by: (a) reverting the P1-T1 addition to a no-op placeholder, which restored the original 46-missed baseline exactly; (b) re-adding a call to `Convert-PoshQCCoverageToRelative` from `PoshQC.TestingSeamDefaults.Tests.ps1` (regardless of real vs. fake path arguments, or whether the call is wrapped in `InModuleScope`), which reproducibly regressed the same 19 lines every time. The same mechanism explains why P1-T2/P1-T3's own newly-targeted lines (all within `Invoke-PoshQCTest`, also extensively tested by `PoshQC.Tests.ps1`) never gain bundled-suite coverage credit despite being correctly covered in isolation.

This is a discovered, pre-existing infrastructure limitation of the test suite's per-file `Import-Module -Force` convention interacting with Pester's code-coverage instrumentation across multiple reimports in one `Invoke-Pester` run. It is not a defect in the new tests themselves, and it cannot be remediated within this plan's permitted change set (new/extended files under `tests/scripts/powershell/PoshQC/` only, specifically `PoshQC.TestingSeamDefaults.Tests.ps1` plus the two named new sibling files) because the files whose `BeforeAll` reimport pattern would need to change to fix the underlying cause (`PoshQC.Tests.ps1`, `PoshQC.Comprehensive.Tests.ps1`, or `PoshQC.psm1`'s sub-module bootstrap loop) are all outside the plan's Scope Constraints (the latter two are explicitly prohibited-edit targets; `PoshQC.Tests.ps1` is not in the permitted list at all).

## THRESHOLD VERDICT: FAIL

The per-file `PoshQC.Testing.psm1` LINE coverage measured through the mandated bundled-suite mechanism (67.18%) is below the required >= 85% floor and below the Phase 0 baseline (76.41%), and the no-regression requirement is violated (19 previously-covered lines are now uncovered). Per this plan's own Phase 2 text, a FAIL verdict means this cycle is not yet complete. This executor's investigation found the root cause to be a pre-existing test-suite infrastructure defect outside the plan's permitted change set; P1 tasks as literally specified cannot be revised, within the current Scope Constraints, to close this gap. This finding is escalated to `atomic-planner`/the orchestrating agent for a scope or plan revision rather than reported as a false PASS.
