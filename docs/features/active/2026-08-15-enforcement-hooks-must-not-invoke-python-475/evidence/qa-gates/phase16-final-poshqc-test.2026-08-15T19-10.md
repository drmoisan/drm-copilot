# Phase 16 Final QA — PowerShell Step 3, Tests with Coverage (FULL SUITE) — [P16-T8]

Timestamp: 2026-08-15T19-10

Command (two runs, both recorded, mirroring `[P15-T3]`):

1. `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and no narrowed `scan_folders` (full suite).
2. Authoritative coverage run: `pwsh -NoProfile` importing `scripts/powershell/PoshQC/PoshQC.ScanConfig.psm1`, `PoshQC.FileDiscovery.psm1`, and `PoshQC.Testing.psm1` from the repository, then `Invoke-PoshQCTest -Root <worktree> -SettingsPath './scripts/powershell/PoshQC/settings/pester.runsettings.psd1'`.

Coverage read: `[xml](Get-Content artifacts/pester/powershell-coverage.xml -Raw)`, `report.counter` and `report.package.class` LINE counters.

EXIT_CODE: 0 (both runs)

Output Summary: FULL SUITE GREEN in one clean pass — **2740 total tests, 2731 passed, 0 failures, 0 errors, 9 pre-existing skipped**, 101.3 s, 129 test files discovered. Run 2 analyzed **64 files** and reports instruction coverage 95.78% and report-level **line coverage 95.92% (5098/5315)**, up from `[P15-T3]`'s 95.73% (5088/5315). **Both discovery hooks have recovered above the 85% line floor**: `enforce-discovery-artifact-gate.ps1` 82.76% -> **91.38%**, `validate-discovery-artifact-gate.ps1` 83.61% -> **91.80%**. No coverage target regressed. **Branch coverage is NOT EMITTED by this toolchain.** `SKIPPED` was not used as a task outcome.

The full-suite total moved from 2732 to 2740 tests: exactly the 8 `It`s added by `[P16-T2]` and `[P16-T3]` (4 each). No test was removed, disabled, or newly skipped; the skipped count is unchanged at 9.

## Why Two Runs Were Required

Unchanged from `[P15-T3]`: the MCP `run_poshqc_test` tool resolves its Pester settings from
bundled extension resources rather than from the repository working tree, and under those
settings only 52 files are analyzed for coverage. The repository's own entry point with the
repository settings file analyzes 64 files and writes the canonical
`artifacts/pester/powershell-coverage.xml`. Every numeric value below is read from that XML,
not inferred from an exit code (`CoveragePercentTarget = 0` means PoshQC does not fail on
coverage). Both runs report identical test outcomes.

## Report-Level Coverage

| Counter | Covered | Total | Percent | `[P15-T3]` |
| --- | --- | --- | --- | --- |
| LINE | 5098 | 5315 | **95.92%** | 95.73% (5088/5315) |
| INSTRUCTION | 7144 | 7459 | 95.78% | 95.56% (7128/7459) |
| METHOD | 424 | 448 | 94.64% | 94.20% |
| CLASS | 64 | 64 | 100.00% | 96.88% |
| BRANCH | — | — | **NOT EMITTED** | NOT EMITTED |

Line total is unchanged at 5315; covered rose by exactly 10 (5088 -> 5098), which is the 5+5
newly executed statements of the two `Invoke-DiscoveryValidatorExe` bodies.

### Branch coverage

Pester 5's JaCoCo exporter records command/line hit data only and never populates branch arcs.
Re-verified on this run: the `report` element carries `INSTRUCTION`, `LINE`, `METHOD`, and
`CLASS` counters and **no `BRANCH` counter** at report, package, class, or sourcefile level.
The 75% branch floor is therefore **unmeasurable with this instrument**. This is recorded
factually. **No threshold was relaxed and no check was dropped**; the branch figure is
unavailable at the instrument level, not waived.

## Per-File Coverage — The Sixteen Named Targets Plus the Sibling Split

| File | `[P15-T3]` | This run | Line % | 85% floor | Regression |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 48/58 (82.76%) | **53/58** | **91.38%** | MET | none (+8.62 pts) |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 51/61 (83.61%) | **56/61** | **91.80%** | MET | none (+8.19 pts) |
| `.claude/hooks/validate-orchestrator-output.ps1` | 104/110 (94.55%) | 104/110 | 94.55% | MET | none |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | 67/67 (100.00%) | 67/67 | 100.00% | MET | none |
| `.claude/lib/codex-routing/CodexTopology.psm1` | 108/108 (100.00%) | 108/108 | 100.00% | MET | none |
| `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | 102/108 (94.44%) | 102/108 | 94.44% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 108/108 (100.00%) | 108/108 | 100.00% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` | 65/65 (100.00%) | 65/65 | 100.00% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1` | 80/80 (100.00%) | 80/80 | 100.00% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1` | 80/80 (100.00%) | 80/80 | 100.00% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` | 96/96 (100.00%) | 96/96 | 100.00% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` | 98/99 (98.99%) | 98/99 | 98.99% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1` | 90/90 (100.00%) | 90/90 | 100.00% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` | 112/112 (100.00%) | 112/112 | 100.00% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` | 105/106 (99.06%) | 105/106 | 99.06% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` | 73/73 (100.00%) | 73/73 | 100.00% | MET | none |
| `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` | 28/28 (100.00%) | 28/28 | 100.00% | MET | none |

**Every coverage target meets the 85% line floor and no file regressed against `[P15-T3]`.**
Fifteen of the seventeen are numerically identical; the two discovery hooks improved.

## Files Outside This Feature's Change Set

Three files in the 64-file analyzed set sit below 85% line coverage. All three are
**pre-existing and untouched by this feature** (none appears in `git status` as modified, and
none is in the `[P15-T3]` target list): `.claude/hooks/validate-bash.ps1` 31/38 (81.58%),
`.codex/hooks/enforce-completion-helpers.ps1` 33/43 (76.74%), and
`scripts/dev-tools/new-claude-worktree-session.ps1` 46/75 (61.33%). They carried the same
values in `[P15-T3]`'s run. Recorded factually; no action taken and none in scope.

## QA Loop Restart — 2026-08-15T19-25

The PowerShell loop was restarted after a comment-only correction to the two files authored by
`[P16-T2]` and `[P16-T3]` (see the restart section of
`phase16-final-poshqc-format.2026-08-15T19-02.md`). This full-suite step was re-run through the
repository entry point with the repository settings file after the restarted format and analyze
steps. Results are numerically identical to the first pass:

| Metric | First pass | Restarted pass |
| --- | --- | --- |
| Tests / failures / errors | 2740 / 0 / 0 | **2740 / 0 / 0** |
| Report LINE coverage | 5098 covered / 217 missed (95.92%) | **5098 covered / 217 missed (95.92%)** |
| `enforce-discovery-artifact-gate.ps1` | 53 covered / 5 missed (91.38%) | **53 covered / 5 missed (91.38%)** |
| `validate-discovery-artifact-gate.ps1` | 56 covered / 5 missed (91.80%) | **56 covered / 5 missed (91.80%)** |

The loop therefore completed format -> analyze -> test in one clean pass with no file changed
at any step.

## Constraint Compliance

- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` was NOT edited in Phase 16.
  Both discovery hooks remain registered as coverage targets at lines 91-92 and
  `CoveragePercentTarget = 0` is unchanged.
- No check, error-string template, or threshold was weakened or deleted.
- No production file was modified in Phase 16 (see
  `evidence/other/phase16-mirror-disposition.2026-08-15T19-01.md`).
- All 26 pinned `Invoke-DiscoveryValidatorExe` references passed in this full-suite run: the
  15 `Mock` registrations remain at their pinned lines (26, 38, 51, 67, 87, 96, 107, 118, 137
  in `enforce-discovery-artifact-gate.Tests.ps1`; 25, 38, 51, 63, 102, 120 in
  `validate-discovery-artifact-gate.Tests.ps1`) and the 11 `Should -Invoke` assertions are
  intact (7 and 4 respectively).

## Guard Suite in the Full Run

`tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` ran as part of
this full suite, including both repository-scan `It`s, with zero failures. The two additive
test files introduce no Python invocation, so the guard remains green.
