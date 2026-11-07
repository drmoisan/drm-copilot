# Census Derivation: Epic-State Isolation After the New Import (Issue 1105, Cycle 1)

Timestamp: 2026-11-07T16-23
Task: [P1-T3]
Command: sh SCRATCH/issue-1105-census.sh <label> (pwsh -NoProfile -File SCRATCH/issue-1105-census.ps1: dot-sources `EpicStateIsolation.Discovery.Helpers.ps1`, `EpicStateIsolation.Helpers.ps1`, and `EpicStateIsolation.Compliance.Helpers.ps1` from `tests/scripts/claude-hooks/`, then calls `Get-EpicStateSuiteCompliance` (AC-4) and `Get-EpicStateProbeFinding` (AC-6) for every `*.Tests.ps1`; a static source scan, not a test run)
EXIT_CODE: 0
Output Summary:
- Scan before the edits (`tests/scripts/claude-hooks`, 213 suites): 56 AC-4 findings, 0 AC-6 findings. 28 suites, each missing the outermost-`BeforeAll` mock of both `Get-WorktreeItemCheckpointText` and `Get-WorktreeItemLiveRoot`.
- Scope extension (micro-action): `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` enumerates both hook-suite surfaces. A debug run of that suite reported 3 further suites under `tests/scripts/codex-hooks`, each with the same 2 seams (6 AC-4 findings): `feature-review-coverage-floor-parity.Tests.ps1`, `feature-review-coverage-narrowing-parity.Tests.ps1`, `validate-feature-review-coverage.Coverage.Tests.ps1`. They load the Claude coverage hook. The census script was widened to both surfaces, and these suites were edited the same way.
- Scan after the edits (both surfaces, 299 suites): 0 findings (AC-4 and AC-6).

## Edit set (31 suites; seams `Get-WorktreeItemCheckpointText`, `Get-WorktreeItemLiveRoot` in every case)

`tests/scripts/claude-hooks/`:

- `subagentstop-target-worktree.Tests.ps1`
- `validate-executor-output.Tests.ps1`, `.Envelope.Tests.ps1`, `.LightRemediation.Tests.ps1`, `.Preflight.Tests.ps1`, `.Reentry.Tests.ps1`, `.TargetWorktree.Tests.ps1`
- `validate-feature-review-coverage.Tests.ps1`, `.Coverage.Tests.ps1`, `.Issue824.Tests.ps1`, `.TargetWorktree.Tests.ps1`, `.ThresholdsGuard.Tests.ps1`
- `validate-planner-output.Tests.ps1`, `.Coverage.Tests.ps1`, `.PreMortem.Tests.ps1`, `.Reentry.Tests.ps1`, `.TargetWorktree.Tests.ps1`
- `validate-prd-feature-output.Tests.ps1`, `.Coverage.Tests.ps1`, `.TargetWorktree.Tests.ps1`
- `validate-required-artifact-output.Tests.ps1`, `.Envelope.Tests.ps1`, `.Reentry.Tests.ps1`, `.TargetWorktree.Tests.ps1`
- `validate-task-researcher-output.Tests.ps1`, `.Coverage.Tests.ps1`, `.PreMortem.Tests.ps1`, `.TargetWorktree.Tests.ps1`

`tests/scripts/codex-hooks/`: the three suites named above.

`validate-feature-review-coverage-freshness.Tests.ps1` and the guard suites reported no finding and were not edited.

## Edit form

- Each outermost `BeforeAll`, after its last dot-source: dot-source `EpicStateIsolation.Baseline.Helpers.ps1`, then `Register-EpicStateBaselineMock -Seam 'Get-WorktreeItemCheckpointText', 'Get-WorktreeItemLiveRoot' -Surface 'Claude'`. The Codex Coverage suite already dot-sourced the helper and gained only the register call.
- One `It 'baseline mock interception probe'` per suite. It sits in a new first `Describe 'epic-state baseline isolation (issue #1105)'` after a top-level `BeforeAll`, or first in the `Describe` whose `BeforeAll` registers. The probe runs before any case that reloads a hook.
- Exception: `validate-feature-review-coverage.Issue824.Tests.ps1` carries the probe `Describe` last. The static-structure case `E4-ST6` in `validate-feature-review-coverage.Tests.ps1` reads that file's first `Describe`.
- No `ParameterFilter`, existing mock, or assertion was edited.

## Test-isolation leak found and fixed (micro-action)

- Leaker: `validate-feature-review-coverage.ThresholdsGuard.Tests.ps1` dot-sources and runs the bundle copy of the hook in-process. Through the helper's new import, that copy loads `WorktreeItemResolution.psm1` from the bundle `lib/` path beside the repository copy. Any later suite in the same process then fails `Register-EpicStateBaselineMock` with "Multiple script or manifest modules named 'WorktreeItemResolution' are currently loaded".
- Fix: an `AfterAll` in that suite's `Describe` removes the modules whose path lies under `extensions/drm-copilot/resources/claude-customizations/`.
- Debug-only confirmation: `ThresholdsGuard` followed by `validate-planner-output.Tests.ps1` in one process went from 26 failures to 0. The victim helper `EpicStateIsolation.Baseline.Helpers.ps1` is outside this plan's file set and was not edited.
