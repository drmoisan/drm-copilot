# Acceptance-Criteria Reconciliation — [P15-T11]

Timestamp: 2026-08-15T18-55

Command: read `spec.md` (AC-1..AC-29 plus the Done-When block) and `user-story.md` (US-1..US-12); verify each criterion against the evidence artifacts and test paths named below; check off only criteria genuinely satisfied.

EXIT_CODE: 1

Output Summary: **28 of 29 spec AC checked, 12 of 12 US checked. One criterion, AC-16, is NOT checked** because two modified files fall below the 85% line-coverage floor. Per this task's own acceptance text the run is reported **REMEDIATION-REQUIRED**, naming the unmet item. No criterion was deleted, reworded, or marked deferred. No pull request was created and `pr-author` was not delegated to, per the recorded stop condition.

## Spec Acceptance Criteria — AC-1 through AC-29

| AC | Status | Evidence |
| --- | --- | --- |
| AC-1 | [x] | `.claude/lib/orchestrator-state/OrchestratorState.psm1` (probe deleted, portable preflight default); `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` (`invokes the portable readiness function as the default, with no branch to bypass it`; four seam-injection tests at `:250-273` unmodified); `evidence/qa-gates/preflight-orchestratorstate-verify.2026-08-15T18-00.md` |
| AC-2 | [x] | `.claude/hooks/validate-orchestrator-output.ps1`; `OrchestratorState.Tests.ps1` (`names no python, python3, py, or poetry command anywhere in the default invoker`); `evidence/qa-gates/completion-hook-verify.2026-08-15T17-51.md` |
| AC-3 | [x] | `tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1`; PD-3 recorded in dispatch comments at `validate-orchestrator-output.ps1:157-159, 221-222, 268-269` |
| AC-4 | [x] | `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` (D-1 regression fixtures) |
| AC-5 | [x] | `evidence/qa-gates/discovery-hooks-verify.2026-08-15T20-20.md`; all 26 seam references green unmodified |
| AC-6 | [x] | `tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1` (empty-success-output assertion); hook-level allow-verdict tests added by `[P3-T4]` |
| AC-7 | [x] | `.claude/lib/discovery-validation/DiscoveryValidation.psm1`; `DiscoveryValidation.Tests.ps1` (40 tests) |
| AC-8 | [x] | `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`; `evidence/regression-testing/guard-scan-zero-findings.2026-08-15T18-40.md` (allowlist entry count 0). **Shape deviation recorded inline, not a silent mismatch:** the spec text describes ONE repository-scan `It`; the shipped guard carries TWO — Assertion A (`reports no Python invocation beyond the allowlist across the guarded tree`) and Assertion B (`carries no stale allowlist entry`). This is the deliberate strengthening authorized by the plan's AC-8 matrix row: Assertion B exists so that any future allowlist entry which goes stale fails the suite. It is vacuously green over the empty allowlist. |
| AC-9 | [x] | `evidence/regression-testing/guard-fixtures.2026-08-15T19-31.md` (detection classes 1-4 each proven) |
| AC-10 | [x] | `evidence/regression-testing/guard-fixtures.2026-08-15T19-31.md` (non-detection fixtures); `evidence/regression-testing/guard-scan-zero-findings.2026-08-15T18-40.md` (0 findings over 55 files; six incidental hooks byte-unchanged); `evidence/regression-testing/guard-scan-mirror-tree.2026-08-15T18-42.md` |
| AC-11 | [x] | `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` (negative-invocation AST assertion replacing the source-text test); `evidence/other/final-constraint-sweep.2026-08-15T18-45.md` clause (a) |
| AC-12 | [x] | `OrchestratorState.Tests.ps1` (item 1), `validate-orchestrator-output.Tests.ps1` (item 2), `validate-orchestrator-output.model-routing.Tests.ps1` (item 3), `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` (item 4) |
| AC-13 | [x] | `evidence/qa-gates/bundle-mirror-pytest.2026-08-15T18-15.md` (17-file byte-identity ledger, `MISMATCH_COUNT = 0`; 12 modules registered in `core.json`; 46 pytest contract assertions passed) |
| AC-14 | [x] | `docs/features/potential/2026-08-15-portable-hook-validation-residuals.md` (records D-2's avoided-not-redesigned disposition, the PowerShell 7.4+ constraint, and the explicit no-deferral statement) |
| AC-15 | [x] | `evidence/other/final-constraint-sweep.2026-08-15T18-45.md` clause (d); `.claude/settings.json` unchanged; `test_parallel_orchestrator_surface_contracts.py` green in `[P12-T10]` and `[P15-T7]` |
| **AC-16** | **[ ] NOT MET** | See the Unmet Criterion section below. |
| AC-17 | [x] | Per-site gates `[P2-T8]`, `[P3-T5]`, `[P4-T6]`, `[P5-T6]`, `[P6-T6]`, `[P7-T6]`, `[P8-T4]`, `[P9-T6]`, `[P10-T6]`, `[P11-T5]`; final loop `evidence/qa-gates/final-poshqc-format.2026-08-15T18-21.md` (0 files changed), `final-poshqc-analyze.2026-08-15T18-24.md` (0 findings), `final-poshqc-test.2026-08-15T18-30.md` (2732 tests, 0 failures) — one clean pass, no restart |
| AC-18 | [x] | `.claude/lib/discovery-validation/DiscoveryValidation.psm1` module header |
| AC-19 | [x] | `evidence/other/parity-coverage.2026-08-15T18-30.md` — **85/85 rows mapped, 0 unmapped, 0 deferred**. Checked off against the artifact's recount (6 pre-existing check rows + 2 pre-existing formulas backing `U6.C5`/`U6.M4` + 79 ported), **not** the research artifact's prose total of "7 of 85"; the row-by-row artifact is authoritative and records the discrepancy as a prose arithmetic error, not an unmapped row and not a deferral |
| AC-20 | [x] | `.claude/lib/codex-routing/CodexDeployment.psm1`, `CodexTopology.psm1`; `CodexDeployment.Parity.Tests.ps1` (27 tests), `CodexTopology.Parity.Tests.ps1` (36 tests); resolver-reuse assertions in the U6.X/U6.T suites |
| AC-21 | [x] | `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` (pinned constants, no validation-time disk read, documented rationale); `OrchestratorStateRoutingMatrix.Tests.ps1` (config-parity test, 31 tests) |
| AC-22 | [x] | `OrchestratorStateCompletion.Tests.ps1` (`emits a malformed model_routing_receipts error exactly once`, `emits a malformed complexity_assessments error exactly once`, `emits no duplicate line anywhere in the completion output`, plus the two reuse assertions) |
| AC-23 | [x] | PD-3 recorded in `validate-orchestrator-output.ps1:157-159, 221-222, 268-269` and in `spec.md`; `evidence/other/final-constraint-sweep.2026-08-15T18-45.md` clause (g) — no artifact describes the epic/parallel structural check as a deferral |
| AC-24 | [x] | `spec.md:113` Decision Record section intact (clause (g)); oracle-intent headers verified present in 15 parity/manifest suites under `tests/scripts/claude-lib/**` |
| AC-25 | [x] | `OrchestratorStateReceipts.psm1` (U6.H1-U6.H5 with inventory strings); `Test-HumanInteractionShape` byte-unchanged; both-layers test in `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` |
| AC-26 | [x] | `DiscoveryValidation.psm1` version-floor check; `DiscoveryValidation.VersionFloor.Tests.ps1` (13 tests) |
| AC-27 | [x] | `DiscoveryValidation.psm1` comment-based help |
| AC-28 | [x] | `DiscoveryValidation.VersionFloor.Tests.ps1` (injectable seam; no `$PSVersionTable` mutation, confirmed by clause (a) of the constraint sweep) |
| AC-29 | [x] | `evidence/qa-gates/self-gating-audit.2026-08-15T18-50.md` — clauses (a)/(b)/(c) all PASS, zero accommodation changes; verbatim invariant quoted in `[P10-T6]`, `[P11-T5]`, and the audit |

## Unmet Criterion — AC-16

AC-16 has three legs. Two are satisfied; one is not.

| Leg | Status | Evidence |
| --- | --- | --- |
| All new `.claude/lib` modules added to the coverage target list in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | MET | 12 modules registered (lines 96-113); confirmed measured — 64 files analyzed vs 52 before |
| Manifest-pinning tests extended for every new module | MET | `OrchestratorState.Manifest.Tests.ps1` (6 tests, 11 paths pinned), `DiscoveryValidation.Manifest.Tests.ps1` (4 tests), `CodexRouting.Manifest.Tests.ps1` (5 tests) — all green |
| **The 85% line / 75% branch floors hold for all modified and new files** | **NOT MET** | `evidence/qa-gates/coverage-delta.2026-08-15T18-38.md` |

Two modified files fall below the 85% line floor:

| File | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 87.27% (48/55) | **82.76%** (48/58) | −4.51 pts |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 87.93% (51/58) | **83.61%** (51/61) | −4.32 pts |

Covered-line counts are unchanged (48, 51); each file gained 3 uncovered lines. The new lines
are the replacement body of `Invoke-DiscoveryValidatorExe` from `[P3-T2]`/`[P3-T3]`, which is
unreachable in the suite by design because that function is the universally mocked seam and
the Hard Constraints require all 26 seam references to survive unmodified.

Separately, PowerShell **branch** coverage is not emitted by the Pester JaCoCo exporter
(established in the `[P0-T4]` baseline by three independent checks), so the 75% branch floor
is unmeasurable for the PowerShell surface. Recorded factually; no threshold relaxed.

AC-16 is therefore left **unchecked**. Its text was not reworded, weakened, or marked deferred.

## User-Story Acceptance Criteria — US-1 through US-12

| US | Status | Evidence |
| --- | --- | --- |
| US-1 | [x] | `evidence/regression-testing/guard-scan-zero-findings.2026-08-15T18-40.md` (0 findings over 55 files, verified structurally by AST, not by PATH manipulation) |
| US-2 | [x] | `evidence/qa-gates/preflight-orchestratorstate-verify.2026-08-15T18-00.md`, `completion-hook-verify.2026-08-15T17-51.md`; prefixes preserved per constraint-sweep clause (d) |
| US-3 | [x] | `validate-orchestrator-output.artifact-type-dispatch.Tests.ps1` |
| US-4 | [x] | Hook-level allow-verdict tests; `DiscoveryValidation.Tests.ps1` empty-success-output assertion |
| US-5 | [x] | `guard-fixtures.2026-08-15T19-31.md` (detection), `guard-scan-fail-before.2026-08-15T19-53.md` (5 findings before), `guard-scan-zero-findings.2026-08-15T18-40.md` (0 findings after; six incidental hooks unmodified); guard runs in the full suite per `final-poshqc-test.2026-08-15T18-30.md` |
| US-6 | [x] | `evidence/other/parity-coverage.2026-08-15T18-30.md` (85/85, 0 deferred; divergences limited to the U1 note and PD-1/PD-2/PD-3) |
| US-7 | [x] | `evidence/qa-gates/bundle-mirror-pytest.2026-08-15T18-15.md`; `evidence/regression-testing/guard-scan-mirror-tree.2026-08-15T18-42.md` (identical behavior: 55 files, 0 findings in both trees) |
| US-8 | [x] | `DiscoveryValidation.psm1` module header; `docs/features/potential/2026-08-15-portable-hook-validation-residuals.md` |
| US-9 | [x] | `OrchestratorStateRoutingMatrix.psm1` + config-parity test; no validation-time config read |
| US-10 | [x] | `spec.md:113` Decision Record intact; oracle-intent headers in 15 suites |
| US-11 | [x] | `DiscoveryValidation.VersionFloor.Tests.ps1` (13 tests through the injectable seam) |
| US-12 | [x] | `evidence/qa-gates/self-gating-audit.2026-08-15T18-50.md` |

## Done-When Block (spec.md)

| Item | Status | Note |
| --- | --- | --- |
| All acceptance criteria above are checked off with evidence | [ ] | Blocked by AC-16 |
| User-story acceptance criteria in `user-story.md` are checked off | [x] | 12/12 |
| Toolchain pass completed in one clean pass: format → analyze → test, plus Python-side pytest contract tests | [x] | PowerShell 0 changes / 0 findings / 0 failures; Python Black-Ruff-Pyright-pytest all clean; `[P12-T10]` contract suites green |
| Feature-review completes with zero blocking findings | [ ] | Feature-review has not run. It is the orchestrator's next step and is outside this execution group (Phases 12-15). Not a defect of this run. |

## Verdict

Nothing was deferred and nothing was silently dropped. **The run is reported
REMEDIATION-REQUIRED on the single unmet criterion AC-16 (coverage floor on two modified
files).** Per the recorded stop condition, no pull request was created and `pr-author` was not
delegated to.
