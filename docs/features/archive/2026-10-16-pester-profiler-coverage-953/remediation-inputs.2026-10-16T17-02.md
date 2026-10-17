# Remediation Inputs: pester-profiler-coverage (Issue #953) - Re-Audit After Cycle 2

Review-Verdict: REMEDIATION_REQUIRED

- Timestamp: 2026-10-16T17-02
- Reviewed head: `44fb400970655d1eb5838b1f4ae88568f9481e74` (branch `bug/pester-profiler-coverage-953`, PR #959)
- Base: `origin/main` @ `d72ec6a1010223f7036b9c3d15dad102ae262f98`
- Cycle 2 resolved the previous round's `autonomous` finding (CR-7) and the related findings CR-8 to CR-13 and CR-17. Remediation is triggered by one new `autonomous` finding (PA-3 / CR-21): CI on HEAD fails in shard 1. PA-1 and PA-2 are `awaiting_ci` and are listed so the count is complete.

Artifacts:
- docs/features/active/2026-10-16-pester-profiler-coverage-953/policy-audit.2026-10-16T17-02.md
- docs/features/active/2026-10-16-pester-profiler-coverage-953/code-review.2026-10-16T17-02.md
- docs/features/active/2026-10-16-pester-profiler-coverage-953/feature-audit.2026-10-16T17-02.md

## Remediation-Required Findings

### PA-3 / CR-21 - HEAD CI shard 1 fails on an order-dependent existing suite after the cycle 2 shard reshuffle

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The defect is in repository test code (a test suite and its helper), it reproduces from a repository command on a Windows checkout, and the fix needs no external service, approval, or new CI result to be made.
- Failure: CI runs 38936152953 (HEAD `44fb40097`) and 38935591244 (`8acac63e7`, same PowerShell tree) both fail `poshqc / PowerShell QC shard 1` with one failed test: `issue #850 changed-file constraints.baseline mock interception probe` at `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1:80`, message "Expected Get-EpicScopeCheckpointText in module EpicScopeResolution to be called 1 times exactly, but was called 0 times". The result-gate step then fails `poshqc / PowerShell QC`. Shards 2 and 3 and every other CI job pass.
- Cause (verified part): the TS04 edit in `8acac63e7` changed the size of `PoshQC.TestingShard.Tests.ps1`; the size-weighted assignment then moved 20 of the 130 shard 1 files (comparison of `shard-files.json` from the shard 1 artifacts of runs 38929655043 and 38935591244). `session-root-reads-850.Constraints.Tests.ps1` moved into shard 1 together with, among others, `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.RunTarget.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1`. The 850 suite passed in its previous shard and in the local unsharded run.
- Cause (hypothesis, to confirm): `EpicStateIsolation.Baseline.Helpers.ps1` imports `EpicScopeResolution.psm1` without `-Force` and mocks `Get-EpicScopeCheckpointText` by module name; `EpicScopeResolution.RunTarget.Tests.ps1` imports the same module with `-Force`. The probe appears to call through a module instance other than the one the mock was registered on, depending on which file ran earlier in the process.
- Files: `tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1` and/or `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1`, or the predecessor suite once identified.
- Expected: the 850 suite passes regardless of which test files run before it in the same Pester process, and all three CI shards pass on the new head.
- Verification: reproduce the failure first with `Invoke-PoshQCTest -ShardIndex 1 -ShardCount 3` on a Windows checkout of HEAD (self-hosted PoshQC module; store fail-before output under `evidence/regression-testing/`); bisect the shard 1 file list to the predecessor; after the fix, a single Pester invocation of the predecessor followed by the 850 suite passes, `Invoke-PoshQCTest -ShardIndex <n> -ShardCount 3` passes for n = 1, 2, and 3, and the full self-hosted toolchain loop (format, analyze, full test run with coverage) passes in one pass; evidence under `evidence/regression-testing/` and `evidence/qa-gates/`.
- Not acceptable as the fix: changing shard weights, file sizes, or the matrix length to move the suite to another shard. Any later test-size change reshuffles the shards.

### PA-1 - Modified workflow `_poshqc.yml` has no green run on the final head

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: The workflow change itself is correct (the result-gate step failed the check as designed in all three recent runs). A green `CI` run on the final PR head is needed after PA-3 is fixed and pushed; that result can only come from CI.
- Action: the S9 CI green gate records `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.

### PA-2 - CI-dependent acceptance criteria AC-08 to AC-12 are pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: AC-08 to AC-12 in `spec.md` are evaluated from the final PR-head `poshqc-test-results` artifact and job timings; plan tasks P8-T19 and P8-T20 are owned by the orchestrator and run after CI completes on that head.
- Action at S9: execute P8-T19 and P8-T20. Reselect the AC-08 baseline at merge base `d72ec6a10` (policy audit PA-N1). State in the AC-10 evidence that per-shard `Test PowerShell` step timings replace the single step (PA-N5). For AC-11, record the completeness-guard output line of the final head's merge job.

## Not Remediation-Required

- PA-N1, PA-N5: S9 procedure notes (see PA-2 action).
- PA-N2 (assumption): Python coverage verdict recorded as PASS; the only changed Python file is a test module.
- PA-N3, PA-N4: pre-existing coverage population boundaries (bundle copies; `.devcontainer/` and `.github/codex/` outside kcov roots).
- PA-N6: profiler mode alone did not shorten the unsharded step in the samples available; report to the user.
- PA-N7: size-balanced shards reduced the slowest shard step from 603 s to 396 s in one sample; spread 113 s remains.
- CR-15, CR-16 (Info, carried forward); CR-18 (negative weight not rejected), CR-19 (README determinism wording), CR-20 (duration-based weighting follow-up), all Info. CR-18 and CR-19 are in files this item changes and may be included in the same cycle.

## Constraints

- Do not edit `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1` or other #936-owned test files (spec D4). If bisection identifies that file as the predecessor, fix the 850 suite or its helper instead; if no fix is possible without editing a #936-owned file, stop and request an orchestrator decision.
- Do not edit `.github/workflows/ci.yml`, any workflow `on:` block, `.claude/rules/**`, or `.github/instructions/**`.
- Keep repository and bundle PoshQC copies byte-identical; the parity pytest must pass.
- No file over 500 lines; tests create no temporary files.
- Do not add a failing CI coverage threshold (D3).
