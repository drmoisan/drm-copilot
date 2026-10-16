# Remediation Inputs — Cycle 2 (issue #935)

Review-Verdict: REMEDIATION_REQUIRED

Timestamp: 2026-10-16T07-55
Source: orchestrator S9 observation on PR #956 (CI run 38868578476, head da4ccf4f0565c332d74052ee0bc1ce8c10438f95) plus the related non-blocking findings of `code-review.2026-10-16T07-30.md`.
Prior review: `remediation-inputs.2026-10-16T07-30.md` (verdict AWAITING_CI; COV-1 awaiting_ci, to be settled by P7-T6 from the PR CI coverage file, and to become autonomous again if that figure is below 85% or below the baseline).

## BLOCKING COV-1: PR CI line coverage below the baseline and below main at the same merge-base

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: CI coverage file `powershell-coverage.xml` from artifact `poshqc-test-results` of run 38868578476 (job `poshqc / PowerShell QC`, https://github.com/drmoisan/drm-copilot/actions/runs/38868578476/job/116867037235).

Observed (D-COV, root `report` LINE counter):
- PR head da4ccf4f0: covered 16395, missed 1767, total 18162, 90.27%.
- Baseline (P7-T1, main adb9aa5f0, run 38730332356): covered 16381, missed 1735, total 18116, 90.42%.
- main at the current merge-base b6be46b5e (run 38864801904): covered 16425, missed 1737, total 18162, 90.44%.

Attribution (per-file LINE diff of main-at-merge-base vs PR head): exactly one file differs.
- `.claude/lib/worktree-resolution/WorktreeResolution.psm1`: covered 142 / missed 2 on main (identical at adb9aa5f0 and b6be46b5e) versus covered 112 / missed 32 on the PR head.
- Lines recorded covered on main and uncovered on the PR head: 79, 144, 150, 247, 254, 255, 284, 318, 319, 321, 322, 323, 325, 326, 327, 328, 329, 331, 363, 376, 377, 378, 379, 382, 383, 384, 446, 453, 454, 460 (the `.git`-file branch of `Get-WorktreeResolutionGitEntryKind`, `ConvertTo-WorktreeResolutionNormalizedPath`, `Test-WorktreeResolutionRootMarker`, `Find-WorktreeResolutionRoot`, `Get-WorktreeResolutionCommonGitDirectory`, `Get-WorktreeResolutionWorktreeRoot`, `ConvertTo-WorktreeResolutionRepoRelativePath`).
- The suites that exercise these functions ran with identical testcase counts and all passed in both runs: `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1` (48), `WorktreeTargetResolution.Tests.ps1` (51), `EpicScopeResolution.Tests.ps1` (24), `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1` (49), `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` (25).
- Interpretation (unverified): the lines most likely still execute but are not attributed under Pester breakpoint coverage, for example because a suite added or reordered by this item (the four new suite files change the run order) causes `WorktreeResolution.psm1` to be loaded first through a path whose breakpoint binding differs, or replaces the module instance on which the breakpoints are set. Main recently merged #936 (hook coverage attribution gaps), which addresses a related mechanism.
- A rerun of job `poshqc / PowerShell QC` on the same head was requested at 2026-10-16T07:55Z to separate run-to-run variance from a repeatable effect; the orchestrator supplies its result to the planner.

Expected: post-change line coverage not lower than the baseline and not lower than main at the same merge-base (AC-24), with no production file excluded and no coverage configuration changed. Pester stays on breakpoint coverage (coordinator decision).

## Non-blocking related findings (fixed in this cycle; same files, introduced by this item)

- CR-R1 (Low): `Test-EpicStateIsolationSeparateValue` in `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1` has no direct rows for its edge cases (last element, followed by another parameter, attached argument, abbreviated name), and its value-taking parameter list omits common parameters such as `-ErrorAction`. Effect limited to the report-only F-3 output.
- CR-R2 (Info): residual duplication in the HookReference helper (hook-name exclusion written twice; Join-Path and variable predicates redefined in several functions).
- CR-R3 (Info): the CR-N3 `-Credential` row in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` calls `.Replace('__SPAWN__', ...)` on a fixture with no placeholder, so the call has no effect.
