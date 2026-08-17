# Coverage Delta Verification — [P16-T13] (satisfies [P15-T8] in full)

Timestamp: 2026-08-15T19-18

Command (comparison inputs, all numeric values read from coverage reports, never inferred from exit codes):

- PowerShell baseline: `evidence/baseline/baseline-poshqc-test.2026-08-15T19-16.md` (values from `artifacts/pester/powershell-coverage.xml`)
- PowerShell failing intermediate state: `evidence/qa-gates/final-poshqc-test.2026-08-15T18-30.md` (`[P15-T3]`)
- PowerShell post-remediation: `evidence/qa-gates/phase16-final-poshqc-test.2026-08-15T19-10.md` (`[P16-T8]`; values read from `artifacts/pester/powershell-coverage.xml`, produced by the repository's own PoshQC entry point with the repository settings file)
- Python baseline: `evidence/baseline/baseline-pytest.2026-08-15T19-21.md` (values from `poetry run coverage json`)
- Python post-remediation: `evidence/qa-gates/phase16-final-pytest.2026-08-15T19-16.md` (`[P16-T12]`; values from `poetry run coverage json`)

EXIT_CODE: 0

Output Summary: **PASS.** Both discovery hooks have recovered above the 85% line floor —
`enforce-discovery-artifact-gate.ps1` **82.76% -> 91.38%** (48/58 -> 53/58) and
`validate-discovery-artifact-gate.ps1` **83.61% -> 91.80%** (51/61 -> 56/61) — and both now
exceed their own pre-change baselines (87.27% and 87.93%). All sixteen named PowerShell
coverage targets plus the sibling split meet the 85% line floor, and **no file regressed**
against the `[P15-T3]` values. PowerShell suite line coverage rose to 95.92% (5098/5315) from
the 94.85% baseline. Python is byte-identical to baseline at 92.30% line / 84.66% branch, both
above their floors. PowerShell branch coverage remains not emitted by the toolchain (instrument
limitation established in the `[P0-T4]` baseline); recorded factually, no threshold relaxed.

## PowerShell — Suite Level

| Metric | Baseline `[P0-T4]` | `[P15-T3]` (failing) | `[P16-T8]` (final) | Delta vs baseline | Floor | Status |
| --- | --- | --- | --- | --- | --- | --- |
| Line coverage | 94.85% (4019/4237) | 95.73% (5088/5315) | **95.92%** (5098/5315) | +1.07 pts | >= 85% | MET |
| Instruction coverage | 94.46% (5457/5777) | 95.56% (7128/7459) | 95.78% (7144/7459) | +1.32 pts | — | — |
| Branch coverage | NOT EMITTED | NOT EMITTED | NOT EMITTED | — | >= 75% | **UNMEASURABLE** |
| Files analyzed | 52 | 64 | 64 | +12 | — | — |
| Tests | 2233 | 2732 | 2740 | +507 | — | — |
| Failures | 0 | 0 | 0 | 0 | — | — |

The +12 analyzed files are the twelve new `.claude/lib/**` modules. The +8 tests between
`[P15-T3]` and `[P16-T8]` are exactly the 4+4 `It`s added by `[P16-T2]` and `[P16-T3]`.

### Branch Coverage — Instrument Limitation, Not a Waiver

Pester 5's JaCoCo exporter records command/line hit data only and never populates branch arcs.
Re-verified on the `[P16-T8]` run: the `report` element carries `INSTRUCTION`, `LINE`,
`METHOD`, and `CLASS` counters and no `BRANCH` counter at report, package, class, or sourcefile
level. The 75% PowerShell branch floor cannot be evaluated with this instrument. This is
recorded as a measurement gap. **No threshold was relaxed, no check was dropped, and no
coverage target was removed.**

## PowerShell — Per-File, New Files

New files created by this feature; no baseline exists, so the floor is evaluated absolutely.
Values unchanged from `[P15-T3]` (Phase 16 added no test exercising them).

| File | `[P16-T8]` line % | 85% floor |
| --- | --- | --- |
| `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` | 100.00% (112/112) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1` | 100.00% (90/90) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1` | 100.00% (80/80) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1` | 100.00% (80/80) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` | 100.00% (73/73) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` | 100.00% (28/28) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1` | 100.00% (65/65) | MET |
| `.claude/lib/codex-routing/CodexDeployment.psm1` | 100.00% (67/67) | MET |
| `.claude/lib/codex-routing/CodexTopology.psm1` | 100.00% (108/108) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` | 99.06% (105/106) | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` | 98.99% (98/99) | MET |
| `.claude/lib/discovery-validation/DiscoveryValidation.psm1` | 94.44% (102/108) | MET |

New-code line coverage across the twelve new modules: **1008 covered / 1015 total = 99.31%.**

## PowerShell — Per-File, Modified Files (floor AND no-regression)

| File | Baseline `[P0-T4]` | `[P15-T3]` | `[P16-T8]` | Delta vs baseline | 85% floor |
| --- | --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 87.27% (48/55) | 82.76% (48/58) | **91.38%** (53/58) | **+4.11 pts** | **MET** |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 87.93% (51/58) | 83.61% (51/61) | **91.80%** (56/61) | **+3.87 pts** | **MET** |
| `.claude/hooks/validate-orchestrator-output.ps1` | 92.16% (94/102) | 94.55% (104/110) | 94.55% (104/110) | +2.39 pts | MET |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | 97.17% (103/106) | 100.00% (108/108) | 100.00% (108/108) | +2.83 pts | MET |
| `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` | 100.00% (50/50) | 100.00% (96/96) | 100.00% (96/96) | 0.00 pts | MET |
| `.claude/lib/model-routing/ModelRouting.psm1` (unmodified, listed in baseline) | 100.00% (46/46) | 100.00% (46/46) | 100.00% (46/46) | 0.00 pts | MET |

**No-regression versus `[P15-T3]`:** fifteen of the seventeen targets are numerically identical
to their `[P15-T3]` values; the two discovery hooks improved. Zero files regressed.

## Changed-Code Coverage — The Remediated Lines

The `[P15-T3]` failure was caused by exactly five newly added statements per hook, all in the
replacement `Invoke-DiscoveryValidatorExe` body, none of which executed because that function
is the universally mocked seam:

| File | Previously uncovered new lines | Status after `[P16-T8]` |
| --- | --- | --- |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 64, 66, 67, 70, 71 | **all 5 now covered** |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 67, 69, 70, 73, 74 | **all 5 now covered** |

Changed-code line coverage for the two hooks' new seam bodies: **10 covered / 10 total = 100%.**
Covered-line counts moved 48 -> 53 and 51 -> 56; the totals (58 and 61) are unchanged, which
confirms no line was deleted to raise the percentage.

The remaining 5 uncovered lines in each file (224, 227, 228, 231, 233 and 251, 252, 253, 254,
257) are pre-existing main-entry lines that were uncovered at baseline as well.

### How the Recovery Was Achieved

**Additive tests only.** Two new sibling suites invoke the real, unmocked seam:

- `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1`
- `tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1`

Each drives the module-not-found early return with a Context-scoped `Mock Test-Path { $false }`
whose `-ParameterFilter` matches only the `DiscoveryValidation.psm1` literal path, and drives
the resolution/import/delegation path with fully real invocations. The plan's recorded fallback
(a minimal injectable module-path seam on the hooks) was NOT needed and NOT taken.

### Actions Deliberately Not Taken

- The 85% line floor was **not relaxed**; `CoveragePercentTarget` was not changed.
- Neither hook was removed from the coverage-target list in
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (still registered at lines 91-92).
  That file was not edited in Phase 16.
- No check row, error-string template, or threshold was weakened or deleted anywhere.
- No existing test, `Mock` registration, or `Should -Invoke` assertion was modified. All 15
  pinned `Mock Invoke-DiscoveryValidatorExe` registrations remain at their pinned line numbers
  (26, 38, 51, 67, 87, 96, 107, 118, 137 and 25, 38, 51, 63, 102, 120), and all 11 pinned
  `Should -Invoke Invoke-DiscoveryValidatorExe` assertions remain (7 and 4).
- No Python invocation of any kind was added; the AST guard's repository scan remains green.
- No temporary file was created.
- No production file was modified in Phase 16 (see
  `evidence/other/phase16-mirror-disposition.2026-08-15T19-01.md`), so the `[P15-T10]`
  self-gating audit's clause (a) hash set is untouched and its conclusion remains truthful.

## Python

| Metric | Baseline `[P0-T8]` | `[P15-T7]` | `[P16-T12]` | Delta vs baseline | Floor | Status |
| --- | --- | --- | --- | --- | --- | --- |
| Line (statement) coverage | 92.30% (13288/14396) | 92.30% (13288/14396) | 92.30% (13288/14396) | 0.00 pts | >= 85% | MET |
| Branch coverage | 84.68% (4476/5286) | 84.66% (4475/5286) | 84.66% (4475/5286) | −0.02 pts | >= 75% | MET |
| Passed | 3785 | 3785 | 3785 | 0 | — | — |
| Failed | 0 | 0 | 0 | 0 | — | — |
| Skipped | 5 | 5 | 5 | 0 | — | — |

**Changed/new Python code coverage: not applicable — there is none.** This feature adds no
Python production code and does not modify `scripts/dev_tools/*.py` (verified in `[P15-T9]`
clause (i)); Phase 16 added no Python file either. The −0.02 point branch delta versus baseline
is a single arc (covered 4476 -> 4475, partial 556 -> 557) in already-covered pre-existing
code, not a regression on changed lines.

## Verdict

| Criterion | Result |
| --- | --- |
| PowerShell suite line floor (>= 85%) | MET — 95.92% |
| PowerShell branch floor (>= 75%) | UNMEASURABLE — instrument emits no branch data |
| PowerShell new-file line floors | MET — all twelve, 99.31% aggregate |
| PowerShell modified-file line floors | **MET — all six, including both remediated hooks** |
| PowerShell no-regression versus `[P15-T3]` | **MET — zero files regressed** |
| PowerShell changed-code coverage (the 10 new seam-body lines) | MET — 100% |
| Python line floor (>= 85%) | MET — 92.30% |
| Python branch floor (>= 75%) | MET — 84.66% |
| Python no-regression on changed lines | MET — no changed Python code |

**Plan outcome on this task: PASS.** `[P15-T8]` and spec `AC-16` are checked off on the basis
of these numbers.
