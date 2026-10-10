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
