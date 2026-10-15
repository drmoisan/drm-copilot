# Blocked State (remediation cycle 1)

Timestamp: 2026-10-10T10-05
Halting task: [P2-T6] (cycle 1)
Halt rule: remediation plan section 3 R-VALID ("An invalid run halts (rule 4) with blocked state PROBE INVALID, because the loss predicate is then not defined") applied through remediation plan rule 4 and main-plan rule 14.
Blocked state: PROBE INVALID

## Recorded values

- First bisection probe: label bis-c1-k140; list = the first 140 PRE containers of the C0 JUnit order, then S (61 containers); 201 containers; ORDER-PRESERVED: yes.
- R-VALID-DIFF: tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1 | reference (X-S) passed=75 failed=0 | candidate passed=74 failed=1.
- Failing row: `baseline mock interception probe` | Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times.
- LOSS for that run (not usable as the predicate): no.
- Evidence: evidence/other/r1-coverage-diagnosis.md, sections [P2-T2] to [P2-T6], Cycle 1.

## Diagnosis state at the halt

- [P2-T2] X-S (S only): every T-SET file at or above 85.00; S-ONLY-FLOOR: met; ORDER-PRESERVED: yes; 1652 passed.
- [P2-T3] CONTROL-LOSS: yes (C0 against X-S; lost lines in all six T-SET files, concentrated in hook entry-point and tail paths).
- [P2-T4] SIDE-RUN pre (PRE then S): LOSS: no. SIDE-RUN post (S then POST): LOSS: no. X1 (full list L): LOSS: yes on hook-dependency-guard.ps1 (57.89), validate-bash.ps1 (80.25), and enforce-orchestration-preimplementation-gate.ps1 (86.55), the same values as C0; enforce-epic-child-worktree-binding.ps1 and enforce-epic-planning-only.ps1 are not lost in X1. SIDE: neither; PROBE-FIDELITY: reproduced. All three runs satisfy R-VALID.
- [P2-T5] NC1-LOSS: no; NC2-LOSS: no; NC3-LOSS: no; NC4: CleanupWorktreeManifestGateMatrix.Tests.ps1 22, hook-dependency-failure.Claude.Tests.ps1 1, hook-dependency-failure.Codex.Tests.ps1 1, activate.Tests.ps1 1.
- Probe-host observation: in every R-COVPROBE run that contains it, tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 fails 38 rows (`Get-OrchestratorStateIssueAdoptionResult` is not recognized), while R-PESTER (C0) reports it passing. R-PESTER hosts Invoke-Pester through a global trampoline function (scripts/powershell/PoshQC/PoshQC.Testing.psm1:264-276); R-COVPROBE calls Invoke-Pester from script scope as section 3 specifies.

## Reverted paths

None. No production or test file was edited in this cycle.

## Plan-revision input

The [P2-T6] predicate requires every probe that contains S to reproduce the X-S counts of every S container. A PRE prefix of 140 containers changes the result of one S row (the #737 baseline interception probe of hook-dependency-failure.Codex.Tests.ps1, which binds mocks to the EpicScopeResolution module instance), so R-VALID fails for at least this midpoint and the bisection cannot proceed as written. Options for the planner (not selected by the executor):
1. Define R-VALID over S rows other than `baseline mock interception probe` rows, recording those rows separately, so a module-instance rebinding outside the coverage question does not void the predicate.
2. Keep R-VALID as written and add a cleanup container (for example K-MOD) between the selected PRE prefix and S in every bisection probe, recording that the predicate then measures loss with module residue removed.
3. Bisect the X1 list directly (S fixed, PRE and POST prefixes varied) with R-VALID restricted to the six T-SET-relevant suites.
4. Record the R-COVPROBE versus R-PESTER hosting difference (global trampoline) and decide whether the probe body should host Invoke-Pester the same way.

## Resolution

Timestamp: 2026-10-10T11-20

RESUMED: [P2-T2] cycle 1 under hosting H2 after plan revision of 2026-10-10

The plan revision (remediation-plan.2026-10-10T06-50.md, H2 hosting, INTERCEPTION-LOSS, R-VALID over non-interception rows, two-stage bisection) resolves the PROBE INVALID halt above. The H2 X-S reference run h2-xs-c1 is green (passed=1652, failed=0, every interception row passed).

## Halt at [P2-T10] (remediation cycle 1, hosting H2)

Timestamp: 2026-10-10T18-55
Halting task: [P2-T10] (cycle 1)
Halt rule: remediation plan [P2-T10] (`VERDICT: measurement artifact` applies rule 5 and halts), rule 5, and rule 4 (main-plan rule 14).
Blocked state: MEASUREMENT ARTIFACT - OPERATOR-DECISION-REQUIRED: AC-24 coverage measurement route

## Recorded values

- VERDICT: measurement artifact
- FIX-CLASS: none
- FIX-SUBJECT: none
- HOSTING-PARITY: yes (X1 under H2 equals the C0 R-PESTER control: 341 testsuites, same order, equal counts, equal per-file values)
- REPRODUCER-LOSS: k=234 | m=42 (culprits tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1 pre, tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 post; both confirmed)
- ILOSS-REPRODUCER: k=125 | m=0 (culprit tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1)
- SHARED-CULPRIT: no | no container removes both signals
- MECHANISM: other (both Q)
- Trials: E0a, E0b, E1, E2, E3 not applicable for both Q; E4 fail (restored, E4-RESTORE-DIFF-EXIT-CODE: 0)
- PROBE-COUNT: 23 | cap=36 ([P2-T6]); 8 [P2-T7] runs; 1 [P2-T9] run
- Deviation record: evidence/other/deviations.md, section `## Remediation cycle 1: coverage measurement artifact`, line `OPERATOR-DECISION-REQUIRED: AC-24 coverage measurement route`
- Evidence: evidence/other/r1-coverage-diagnosis.md (sections `Cycle 1 (H2)` and `## Verdict`)

## Reverted paths

- .claude/hooks/validate-orchestrator-output.ps1: the E4 trial edit (line 51 deleted) was installed through R-INSTALL (P2-T9#E4-1) and restored to its original bytes through R-INSTALL (P2-T9#E4-2) in [P2-T9]; `git diff --exit-code df0965aeaa8a3905fe4966fcbb4b49143d566941 -- .claude/hooks/validate-orchestrator-output.ps1` exits 0. No other production or test file was edited in this cycle, and no fix from an earlier cycle exists.

## Not executed

[P3-T1] to [P3-T5], [P4-T1] to [P4-T4], [P5-T1] to [P5-T11], and [P6-T1] to [P6-T6] are not executed. AC-6 and AC-24 stay unchecked in spec.md. AC-6 was amended in Phase 1 and its verification ([P6-T1]) belongs to Phase 6, which this halt does not reach.

## Resolution

Timestamp: 2026-10-10T17-36

DECISION: AC-24 reads "measured per file from the Pester coverage XML" and does not name the combined run. For the Codex files in T-SET whose combined-run value is below 85% or below baseline, AC-24 is evaluated from a per-surface Pester coverage XML: the Codex suite set S (tests/scripts/codex-hooks/) run alone through the H2/R-PESTER hosting on the current tree, and the same S scope on the BASE tree extraction (the [P0-T10] r1-base extraction of 86e457a0…) for the "no changed line loses coverage" clause. The combined-run figures are retained and reported unchanged next to the per-surface figures. The final gate route, thresholds, exclusions and PoshQC configuration remain unchanged. No production or test code change is required for AC-24 under this decision.

RESUMED: [P2-T11] cycle 1 closed at [P2-T10] with VERDICT: measurement artifact; execution continues at [P3-T1] under the orchestrator AC-24 decision of 2026-10-10
