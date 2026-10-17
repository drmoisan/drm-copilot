# Remediation Inputs: pester-profiler-coverage (Issue #953) - Re-Audit After Cycle 1 and Sharding Phase

Review-Verdict: REMEDIATION_REQUIRED

- Timestamp: 2026-10-16T14-11
- Reviewed head: `c1dab385e30b20bda8de77e11f848c3b48ec1e58` (branch `bug/pester-profiler-coverage-953`, PR #959)
- Base: `origin/main` @ `5d2d9a9728b3763cb4398bdae1e54ef84ee98936`
- Remediation is triggered by one `autonomous` finding (PA-3 / CR-7). PA-1 and PA-2 are `awaiting_ci` and are resolved by CI on the final PR head and the S9 tasks; they are listed so the count is complete.

Artifacts:
- docs/features/active/2026-10-16-pester-profiler-coverage-953/policy-audit.2026-10-16T14-11.md
- docs/features/active/2026-10-16-pester-profiler-coverage-953/code-review.2026-10-16T14-11.md
- docs/features/active/2026-10-16-pester-profiler-coverage-953/feature-audit.2026-10-16T14-11.md

## Remediation-Required Findings

### PA-3 / CR-7 - The required-check result step of the `poshqc` merge job has no test

- Severity: Blocking
- Remediability: autonomous
- Remediability-Evidence: The fix is one new Pester case in a repository test file that reads the checked-in workflow text; it needs no external service, approval, or CI result.
- Files: `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` (new case); `.github/workflows/_poshqc.yml` is not expected to change unless the test exposes a defect.
- Problem: the `poshqc` job (`_poshqc.yml:75-147`) runs under `if: always()` and its first step (`_poshqc.yml:82-90`) exits 1 when `needs.poshqc-static.result` or `needs.poshqc-shard.result` is not `success`. No test asserts that step, the job condition, or the step order. Removing or weakening the step would let a failing shard produce a green `poshqc / PowerShell QC` check.
- Expected: a `PoshQcWorkflow.Tests.ps1` case that asserts, within the `poshqc` job text, the job-level `if:` condition, a step that compares both `needs.poshqc-static.result` and `needs.poshqc-shard.result` with `'success'` and exits non-zero, and that this step appears before the `Verify shard completeness` and `Merge PowerShell shard coverage` steps. The test reads only the checked-in workflow file and creates no temporary files.
- Verification: the new case fails against a copy of the job text with the result-check step removed (fail-before evidence by asserting against an in-memory modified string, not a temp file) and passes against the committed workflow; full PoshQC toolchain loop (format, analyze, full test run with coverage) passes in one pass; evidence under `evidence/regression-testing/` and `evidence/qa-gates/`.

### PA-1 - Modified workflow `_poshqc.yml` has no green run on the final head

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: CI run 38912409726 for head `c1dab385e` is queued; run 38909263798 on `9f822f1cb` succeeded but is not a qualifying predecessor because merge commit `c1dab385e` changes paths outside the feature folder. The awaited workflow is `CI` (calls `_poshqc.yml`) on the final PR head.
- Action: after remediation commits are pushed, the S9 CI green gate records `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.

### PA-2 - CI-dependent acceptance criteria AC-08 to AC-12 are pending

- Severity: Blocking
- Remediability: awaiting_ci
- Remediability-Evidence: AC-08 to AC-12 in `spec.md` are evaluated from the final PR-head `poshqc-test-results` artifact and job timings; plan tasks P8-T19 and P8-T20 are owned by the orchestrator and run after CI completes on that head.
- Action at S9: execute P8-T19 and P8-T20. Reselect the AC-08 baseline at merge base `5d2d9a972` (policy audit PA-N1), because `main` commit `d9ce4757e` changed both `enforce-orchestration-preimplementation-gate-targets.ps1` copies after the earlier baseline run 38885440106. State in the AC-10 evidence that per-shard step timings replace the single `Test PowerShell` step (PA-N5).

## Related Findings Recommended for the Same Cycle (not counted)

These are Minor findings in files this item changes. Under the coordinator rule that related findings are fixed inside the item before merge, the orchestrator may include them in this cycle:

- CR-8: `Merge-PoshQCCoverageReport` leaves METHOD and CLASS counters at shard-1 values; recompute or remove them from the merged output (`PoshQC.CoverageMerge.psm1:89-121`, both copies; update CM02).
- CR-9: document the shard parameters of `Invoke-PoshQCTest` and the six new exports in the CHANGELOG `[Unreleased]` entry and both README copies.
- CR-11: replace the four literal shard-count sites in `_poshqc.yml` (lines 46, 62, 129, 133) with one source (`strategy.job-total` and manifest- or folder-derived loops).
- CR-12: add a test that drives the default `WriteShardFileList` seam with `Set-Content` mocked (`PoshQC.Testing.psm1:174` has `ci=0`).
- CR-13: fail fast or return early when a shard's selected slice is empty, with a test.

## Not Remediation-Required

- PA-N2 (assumption): Python coverage verdict recorded as PASS because the only changed Python file is a test module; if the orchestrator applies the absent-artifact rule literally, record `poetry run pytest --cov` figures under `evidence/qa-gates/`.
- PA-N3, PA-N4: pre-existing coverage population boundaries (bundle copies; `.devcontainer/` and `.github/codex/` outside kcov roots).
- PA-N6: in the single CI samples available, profiler mode did not shorten the unsharded step (930 s breakpoint baseline against 1141 s profiler PR head); report to the user.
- CR-10 (shard balance follow-up), CR-14 to CR-17 (Info).

## Constraints

- Do not edit `.github/workflows/ci.yml`, any workflow `on:` block, `.claude/rules/**`, or `.github/instructions/**`.
- Keep repository and bundle PoshQC copies byte-identical; the parity pytest must pass.
- No file over 500 lines (`PoshQC.Testing.psm1` is at 484); tests create no temporary files.
- Do not add a failing CI coverage threshold (D3).
