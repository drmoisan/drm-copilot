# Remediation Inputs (Issue #1190), feature review 2026-11-15T17-45

Review-Verdict: REMEDIATION_REQUIRED
Remediation-Path: full
Remediation-Mode: proportionate

**Entry timestamp:** 2026-11-15T17-45
**Feature folder:** `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190`
**Base branch:** `main` (merge base `11c6ecde2e3080722c90bc63289bc160bf9596ea`)
**Head reviewed:** `497bf51abae3ecbdf8845b4d799fd72a5930f8f2` on `feature/ci-shard-powershell-and-python`
**Work mode:** `full-feature`; AC sources are `spec.md` and `user-story.md` (15 of 17 met; 2 PARTIAL)
**Finding count:** 1 (autonomous: 1)
**Audit artifacts:**
- `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/policy-audit.2026-11-15T17-45.md`
- `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/code-review.2026-11-15T17-45.md`
- `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/feature-audit.2026-11-15T17-45.md`

## Findings

### F1 (CR-1; criteria S12 and U5) - PowerShell shard durations miss the issue target

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The remedy is a data-only regeneration of the shard weights file on this branch followed by a repeat workflow_dispatch CI run on the same branch; no external system, owner decision, or policy exception is needed.
Finding-Scope: contained

File: `config/poshqc-shard-weights.json` (the tuning mechanism for the `poshqc-shard` matrix); evidence under `docs/features/active/2026-11-14-ci-shard-powershell-and-python-coverage-1190/evidence/other/`.

Current state: run 43736520255 measured the six PowerShell shards at 7.4, 13.6, 10.9, 12.5, 9.1 and 9.9 minutes. The issue target is about 11 minutes per leg. Shards 2 and 4 exceed it; the longest is 13.6 minutes (baseline longest 16.9). The spread is 84 percent of the shortest shard, above the 20 percent trigger in `spec.md` `## Implementation Strategy`. The Python 3.13 leg meets the target (critical path 11.3 minutes) and needs no change.

Determination: acceptance gap (not a code defect, not a policy hold). The shard count of six is an owner-specified input and stays as it is.

Fix:
1. Download the per-file Pester timing data of run 43736520255 (the `poshqc-test-results` artifact and the shard JUnit files) with `gh run download` into a scratch folder; do not commit it.
2. Regenerate `config/poshqc-shard-weights.json` with the repository's existing weights export (the `Export-PoshQCShardWeight` function of `PoshQC.Parallel.psm1`, as used for the file in issue #1048) so that the longest-processing-time assignment over six shards balances measured milliseconds. Change no other file under `scripts/`, `.github/workflows/`, or the helper.
3. Run the weights tests (`tests/scripts/powershell/PoshQC/PoshQC.ShardWeights.Tests.ps1`) through the launcher pester suite in one parallel run, then push and rerun `ci.yml` through workflow_dispatch on the branch head.
4. Record the new per-job durations, run URL, and queue trade-off in a new `evidence/other/ci-measurement.<timestamp>.md`; keep the earlier record unchanged.
5. Check off `spec.md` S12 and `user-story.md` U5 only when every PowerShell shard and the Python leg meet the target. If the longest shard still exceeds the target after one regeneration, record the measured figures and the residual spread in the evidence and report the result without altering the criterion text.

Verification:
- `config/poshqc-shard-weights.json` diff is data-only and the weights tests pass.
- The new CI run is green on every job including `CI Required Gate`, and the six PowerShell shard durations are recorded.

## Do not do

- Do not change the shard count, the matrix, the helper, or any workflow file to address F1.
- Do not lower or alter any threshold, and do not edit the criterion text of S12 or U5.
- Do not add a coverage exclusion, a new Python file, or a serial test run.
- Write evidence only under `<FEATURE>/evidence/<kind>/`, append-only; use repository-relative paths in every artifact.
