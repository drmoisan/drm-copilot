# Preflight Fixes - Issue #1050 (confirming preflight after the OD-2 revision)

Timestamp: 2026-11-15T18-44
Plan: docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/plan.2026-11-14T09-31.md
Signal: PREFLIGHT: ALL CLEAR (all fixes below are trivial and were made in task text and the plan preamble only; no task was added, removed, or reordered)

## Prior-round defects

- (a) actionlint 1.7.12 and `job.workflow_*`: resolved. A SCRATCH prototype (`issue-1050-harness-powershell.yml` with `workflow_call` inputs `poshqc`, `harness_repository`, `harness_ref`, the empty-input failure step, the guarded side checkout, and a caller passing the inputs in reference and copy form) gave actionlint 1.7.12 exit 0 with zero findings. A control file using `job.workflow_repository` and `job.workflow_sha` gave exit 1 with two `property ... is not defined` findings.
- (b) [P2-T2] copy-mode manifest case: resolved. The case asserts layer `shared`, pack `core` or the language pack name, `sha256` equal to `hashPayloadText` of the written bytes, and manifest `schema_version` `1.0.0`.

## Fixes

1. `## Planning Decisions` D5 | validator-blind defect (success-case output not observable) | `scripts/dev-tools/run-actionlint.ps1` assigns the actionlint output to `$null` in `Invoke-ActionlintCommand`, so a run through the wrapper prints neither the `-version` output nor finding text (observed: `-version` through the wrapper printed only `Running actionlint...`). D5 now states that the version and any finding text are read from a direct run of the binary the wrapper resolves, that the wrapper's exit code is the gate result, and that exit 0 means zero findings. The assertions of P0-T3, P1-T4, and P3-T1 (version `1.7.12`, exit 0, zero findings) are unchanged.
2. [P0-T3], [P3-T1] | stale tool route (no check mode) | `Invoke-PoshQCFormat` has no check switch. Both tasks now name the non-writing `-WriteFile` seam and read drift as the count of `Formatted:` log lines (zero at P3-T1). The meaning (format check, zero drift at the final gate) is unchanged.
3. [P1-T3] | stale tool route | The task check named a Pester run with `Run.Exit` true; task checks run the launcher `pester` suite with `-TestPath` per `## Test Cadence (Mandatory)`. The assertion (zero failures) is unchanged.
4. [P2-T4] `harness workflows are destination-generic` | missing test row for behavior the same case already owns (spec `## Template Contract` PowerShell and .NET rows) | Added the assertions for the empty-input failure step guarded by `inputs.poshqc`, the Pester step guarded by `!inputs.poshqc` with no side-folder path, and `ubuntu-latest` for `modern`. Classified trivial on the #1016 precedent (a missing row for behavior the same task and spec section already own); the orchestrator may reclassify.
5. [P2-T5] | ambiguous asserted token | The contract case said "token present" without naming it; it now names `.github/drm-copilot/ci-required-checks.json`, the path the bullet introduces. The bullet text "the bullets above describe this source repository" now reads "the other bullets of this section describe this source repository", because bullets after the insertion point also describe this repository.
6. [P3-T5] | literal correction | The scratch dispatch set only the `uses:` ref to the pushed head; the PowerShell job's `harness_ref` input is now set to the same head, because the `v<payload_version>` tag does not carry the harness workflows. The asserted outcome (per-pack `success` with the pack check and `CI Required Gate`) is unchanged.

## Validation

- Installed MCP `validate_orchestration_artifacts` (plan) and the branch Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan` are run after the fixes; results are reported in the preflight return.
