# Phase 5 — Gap 1 PowerShell Batch B (BLOCKED at [P5-T5])

Timestamp: 2026-08-08T12-05
Task: [P5-T5]

Status: **BLOCKED — [P5-T5] cannot be completed as written.** A second Pester test that asserts
the Gap 1 defect as intended behaviour was discovered. It is not the test the spec and research
identified, it is not authorized for modification by this plan, and it now fails because the Gap 1
fix works exactly as specified.

Command: `mcp__drm-copilot__run_poshqc_format` then `mcp__drm-copilot__run_poshqc_analyze` then
`mcp__drm-copilot__run_poshqc_test`, each with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a5c761b8f1a691079`.

EXIT_CODE: 0 (format), 0 (analyze), 3 (test)

## Stage results

| Stage | Command | EXIT_CODE | Result |
| --- | --- | ---: | --- |
| 1 Format | `run_poshqc_format` | 0 | 0 files modified (all five module hashes unchanged) |
| 2 Lint | `run_poshqc_analyze` | 0 | 0 PSScriptAnalyzer findings at every severity |
| 3 Test | `run_poshqc_test` | 3 | 1995 passed, 3 failed, 0 errors, 9 skipped of 2007 |

## The blocking finding

`tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1:248-262` now fails:

```
FILE: BlastRadius.Tests.ps1
TEST: Get-BlastRadius module and surface resolution.Shared surfaces.cannot reach a
      separator-free repository-root surface from plan text
MSG : Expected 0, but got 1.
```

The test body, verbatim:

```powershell
It 'cannot reach a separator-free repository-root surface from plan text' {
    # Arrange: a plan citing a repository-root shared surface that carries
    # no path separator.
    $plan = '- [ ] [P1-T1] Touch `poetry.lock`.'

    # Act: derive the radius.
    $radius = Get-BlastRadius -PlanText $plan -SpecText '' -FeatureFolder 'f' `
        -Config $script:TestConfig -ComputedAt 't'

    # Assert: token classification requires a separator, so a root-level
    # file is never extracted from plan text. This mirrors the Python
    # reference exactly; such surfaces reach a radius only through
    # Get-BlastRadiusFromObservedPaths, which takes paths verbatim.
    @($radius['shared_surfaces']).Count | Should -Be 0
}
```

Its `$script:TestConfig` declares `shared_surfaces = @('poetry.lock',
'config/orchestration-routing.json')`, so `poetry.lock` is a configured separator-free root
surface and Gap 1 is precisely the behaviour the test pins.

## The failure is the fix working, not a defect in the implementation

Direct verification against the same config the test uses:

```
paths           = [docs/features/active/f/**, poetry.lock]
shared_surfaces = [poetry.lock]
shared_surfaces count = 1
```

This is exactly what `spec.md` requires. The test asserts `Count -eq 0`, which is the Gap 1
under-report the whole change set exists to eliminate. Making the test pass by reverting the fix
would violate the spec; the assertion is not weakenable, it is invertible.

## Why this is a blocking condition rather than a micro-action

1. `spec.md` invariant 3 states: "Exactly one Pester test asserts the defect as intended behaviour
   and must be inverted: `tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1:309-316`."
   That is the Gap 2 test, scheduled for inversion at [P7-T1]. The research did not identify this
   second, Gap 1 defect-asserting test.
2. The execution hard constraints state: "No existing fixture expectation may be relaxed and no
   existing assertion weakened to make a test pass. The single authorized assertion change is the
   spec-mandated defect-test inversion at [P7-T1]."
3. Inverting `BlastRadius.Tests.ps1:248-262` is therefore an assertion change that no task in the
   approved plan authorizes. Performing it would be improvising a substitute task.

## Asymmetry: Python has no counterpart, so this is PowerShell-only

The Python suite has no equivalent derive-level assertion of the Gap 1 defect. The Phase 3 run
([P3-T12]) passed 2763 of 2763 tests over `tests/scripts/dev_tools/` after the identical Python
fix landed. The nearest Python test,
`test_compute_blast_radius.py::test_observed_radius_resolves_modules_and_shared_surfaces`, asserts
`radius.shared_surfaces == ("poetry.lock",)` through `radius_from_observed_paths`, which takes
paths verbatim and is unaffected. The two-language behavioural equivalence constraint therefore
requires the PowerShell test to be corrected, not the PowerShell implementation.

## Everything else in Phase 5 completed and verified

| Task | Status | Evidence |
| --- | --- | --- |
| [P5-T1] `Get-BlastRadius` passes `-RootSurface` to both call sites | done | both call sites bind the same `Get-ConfigRootSurface -Config $Config` value |
| [P5-T2] `Test-BlastRadius` passes `-RootSurface` to `Get-PlanPaths` | done | call site derives from the same `-Config` mapping |
| [P5-T3] mirrored config-shape assertion in the parity driver | done and PASSING | `BlastRadius.Parity.Tests.ps1` rose 52 -> 53 passed, 0 failed |
| [P5-T4] byte-for-byte mirror of `BlastRadius.psm1` and `BlastRadiusValidation.psm1` | done | `7325240eecf7fbef` 15242 B and `19db68754140c2de` 15269 B, identical both sides |
| [P5-T5] full PowerShell toolchain | **BLOCKED** | this artifact |

## Blast-radius suite state

| Suite | Passed | Failed |
| --- | ---: | ---: |
| `BlastRadius.Conflict.Tests.ps1` | 27 | 0 |
| `BlastRadius.Manifest.Tests.ps1` | 4 | 0 |
| `BlastRadius.Parity.Tests.ps1` | 53 | 0 |
| `BlastRadius.Tests.ps1` | 34 | **1** |
| `BlastRadius.Validation.Tests.ps1` | 31 | 0 |
| `BlastRadiusConfig.Tests.ps1` | 45 | 0 |
| `BlastRadiusExtraction.Path.Tests.ps1` | 45 | 0 |
| `BlastRadiusExtraction.Tests.ps1` | 21 | 0 |
| `BlastRadiusGlob.Tests.ps1` | 35 | 0 |
| **Total** | **295** | **1** |

The other two failures in the repository-wide run are the pre-existing environmental failures
recorded in the P0-T9 baseline (`enforce-pr-author-skill.Tests.ps1` and
`codex-pretooluse-integration.Tests.ps1`), unchanged and unrelated.

Output Summary: Format modified 0 files (exit 0) and PSScriptAnalyzer reported 0 findings (exit
0). The test stage exits 3 with 1995 passed / 3 failed of 2007. Two failures are the pre-existing
environmental baseline failures. The third is new and blocking:
`BlastRadius.Tests.ps1:248-262` asserts the Gap 1 defect as intended behaviour and now fails
because the fix works. Correcting it requires inverting an assertion that no task in the approved
plan authorizes, so execution stops at [P5-T5] pending a plan revision. No assertion was weakened,
no test was skipped, and the implementation was not reverted.
