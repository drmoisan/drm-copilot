# Final QA — PowerShell Step 3, Tests with Coverage (FULL SUITE) — [P15-T3]

Timestamp: 2026-08-15T18-30

Command (two runs, both recorded):

1. `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and no narrowed `scan_folders` (full suite).
2. Authoritative coverage run: `pwsh -NoProfile` importing `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1`, `PoshQC.FileDiscovery.psm1`, and `PoshQC.Testing.psm1` from the repository, then `Invoke-PoshQCTest -Root <worktree> -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

EXIT_CODE: 0 (both runs)

Output Summary: FULL SUITE GREEN in one pass — 2732 total tests, **0 failures, 0 errors**, 9 pre-existing skipped, 102.39 s. This is the first full-suite Pester run of the plan and it includes the guard's repository-scan `It`s, now green with zero findings. Report-level line coverage **95.73%** (5088/5315), instruction coverage 95.56% (7128/7459), 64 files analyzed. **Branch coverage is NOT EMITTED by this toolchain** (instrument limitation, established in the `[P0-T4]` baseline). All twelve new modules meet the 85% line floor with large headroom. **Two modified hooks fall below the 85% line floor** — see the Floor Failure section. `SKIPPED` was not used as a task outcome.

## Why Two Runs Were Required

The MCP `run_poshqc_test` tool resolves its Pester settings from **bundled extension
resources** rather than from the repository working tree. Under those stale settings only 52
files were analyzed and none of the twelve new `.claude/lib/**` modules appeared in the
coverage report, even though `[P2-T7]`, `[P4-T6]`, `[P5-T6]`, `[P6-T6]`, `[P7-T6]`,
`[P8-T4]`, and `[P9-T6]` registered every one of them as a coverage target in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. This limitation was already
recorded in the `[P2-T8]` evidence artifact and handled the same way there.

The second run invokes the repository's own PoshQC entry point with the repository's settings
file. It analyzes **64 files** (52 + the twelve new modules) and writes the canonical
`artifacts/pester/powershell-coverage.xml`. Every numeric value below is read from that XML,
not inferred from an exit code (`CoveragePercentTarget = 0` in
`pester.runsettings.psd1:148` means PoshQC does not fail on coverage).

Both runs report identical test outcomes: 2732 tests, 0 failures, 0 errors.

## Report-Level Coverage

| Counter | Covered | Total | Percent |
| --- | --- | --- | --- |
| LINE | 5088 | 5315 | **95.73%** |
| INSTRUCTION | 7128 | 7459 | 95.56% |
| METHOD | 422 | 448 | 94.20% |
| CLASS | 62 | 64 | 96.88% |
| BRANCH | — | — | **NOT EMITTED** |

Branch coverage: Pester 5's JaCoCo exporter records command/line hit data only and never
populates branch arcs. Verified in `[P0-T4]`: no `counter type="BRANCH"` element exists at
report, package, class, or sourcefile level, and summing the `mb`/`cb` attributes across every
`<line>` node yields 0/0. The 75% branch floor is therefore **unmeasurable with this
instrument**. This is recorded factually. **No threshold is relaxed and no check is dropped**;
the branch figure is unavailable at the instrument level, not waived.

## Per-File Coverage — The Sixteen Named Targets Plus the Sibling Split

| File | Covered/Total | Line % | 85% floor |
| --- | --- | --- | --- |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | 67/67 | 100.00% | MET |
| `.claude/lib/codex-routing/CodexTopology.psm1` | 108/108 | 100.00% | MET |
| `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | 102/108 | 94.44% | MET |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 108/108 | 100.00% | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` | 65/65 | 100.00% | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1` | 80/80 | 100.00% | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1` | 80/80 | 100.00% | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` | 96/96 | 100.00% | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` | 98/99 | 98.99% | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1` | 90/90 | 100.00% | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` | 112/112 | 100.00% | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` | 105/106 | 99.06% | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` | 73/73 | 100.00% | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` | 28/28 | 100.00% | MET |
| `.claude/hooks/validate-orchestrator-output.ps1` | 104/110 | 94.55% | MET |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 48/58 | **82.76%** | **FAILED** |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 51/61 | **83.61%** | **FAILED** |

Note on `OrchestratorState.psm1`: the plan predicted its percentage might tick down from the
97.17% baseline because `[P11-T2]` deletes currently-covered lines. It in fact rose to
100.00% (108/108). No increase was required; none is claimed as a goal.

## FLOOR FAILURE — Two Modified Hooks Below 85% Line Coverage

This is recorded as a failure, not accommodated.

| File | Baseline (`[P0-T4]`) | Post-change | Delta |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 48 covered / 7 missed = 87.27% | 48 covered / 10 missed = **82.76%** | −4.51 pts |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 51 covered / 7 missed = 87.93% | 51 covered / 10 missed = **83.61%** | −4.32 pts |

**Covered-line counts are unchanged** (48 and 51 respectively). The percentage fell because
each file gained **3 additional uncovered lines**; the denominator grew while the numerator
held.

### Root Cause

The newly uncovered lines are the replacement body of `Invoke-DiscoveryValidatorExe`
introduced by `[P3-T2]` and `[P3-T3]`:

- `enforce-discovery-artifact-gate.ps1` uncovered lines: **64, 66, 67, 70, 71** (the new
  seam body) plus 224, 227, 228, 231, 233 (pre-existing main-entry lines).
- `validate-discovery-artifact-gate.ps1` uncovered lines: **67, 69, 70, 73, 74** (the new
  seam body) plus 251, 252, 253, 254, 257 (pre-existing main-entry lines).

The new body resolves the module path, guards its existence, imports the module, and
delegates:

```powershell
$modulePath = Join-Path -Path $PSScriptRoot `
    -ChildPath '../lib/discovery-validation/DiscoveryValidation.psm1'
if (-not (Test-Path -LiteralPath $modulePath -PathType Leaf)) {
    return @{ ExitCode = 1; Output = "Discovery-validation module not found: $modulePath" }
}

Import-Module -Name $modulePath -Force -ErrorAction Stop
return Invoke-DiscoveryArtifactValidation -ValidatorArgs $ValidatorArgs
```

That body is longer than the single `& python -m ...` invocation it replaced. It is
**unreachable in the test suite by design**: `Invoke-DiscoveryValidatorExe` is the mocked
seam, and the plan's Hard Constraints require all 26 existing seam references to survive
unmodified (15 `Mock` registrations plus 11 `Should -Invoke` assertions). Every test that
reaches this hook replaces the function, so the real body never runs. The logic inside it is
covered instead through `DiscoveryValidation.psm1` at 94.44%.

### Disposition

Per `[P15-T8]`'s own acceptance text — "if any required numeric value is unavailable or any
floor fails, the plan outcome is remediation-required, not PASS" — the plan outcome is
**REMEDIATION-REQUIRED** on this criterion.

Actions deliberately NOT taken, per the plan's binding constraints:

- The 85% floor was **not relaxed**, and `CoveragePercentTarget` was **not** changed.
- No coverage-target registration was removed to hide the file (the coverage-exclusion policy
  in `.claude/rules/general-unit-test.md` forbids excluding production paths).
- No check row, error string, or threshold was weakened. The self-gating invariant holds:
  the reconciliation branch corrects the checkpoint, never the check — and a coverage floor
  is a threshold, which this run does not touch.
- No test files were added or modified. The Change-Budget Accounting for Phase 15 states
  "no production or test file changes; evidence, documentation, and AC checkoffs only", so
  adding seam-body tests is outside this plan's Phase 15 scope and is recorded as the
  remediation item rather than performed here.

Suggested remediation (for the remediation cycle, not executed here): add direct-invocation
tests for the `Invoke-DiscoveryValidatorExe` bodies that exercise the module-missing guard
and the delegation path without a mock, in a phase whose change budget permits test-file
edits.

## Skipped Tests

9 tests skipped, unchanged from the `[P0-T4]` baseline (which also recorded
"Disabled/skipped: 9"). No test was newly skipped by this feature.

## Guard Suite in the Full Run

`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` — 27 tests,
0 failures — ran as part of this full suite, including both repository-scan `It`s. The guard
therefore runs in the CI-equivalent suite, which is the standing regression protection
against a reintroduced Python invocation.
