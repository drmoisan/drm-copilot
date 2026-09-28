# CI Remediation Inputs — Issue #552

- Created: 2026-08-25T17-20
- Trigger: `quality-checks7 / Code Quality & Tests (3.12)`, job `97971527109`
- PR: #553
- Branch: `bug/codex-subagent-routing-attestation-launch-binding-552`

## Blocking Finding

`test_poshqc_bundled_module_files_match_repo_root_sources` failed because the canonical PoshQC source settings file and its checked-in extension mirror differ.

- Source of truth: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- Required mirror: `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
- Required end state: the mirror is byte-for-byte equal to the source, including the Issue #552 coverage-target entries.

## Confirmed Local-Gate Environment Finding

The remediation baseline Pester gate ran twice and each result reported 3,594 tests, 1 failure, 0 errors, 9 skipped, and 96.14% line coverage. The repeated failure was `leaves no Codex batch-budget state behind` (expected `$false`, got `$true`) in `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`. The test asserts that the entire worktree `.codex/state` directory is absent after benign hook payloads.

The verified worktree state directory resolves to `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-25T14-48\.codex\state` and contains exactly these ignored per-session counters, with no authority-store file:

- `powershell-batch-budget.01a03a40-eb5b-7e63-9c04-94ca4f0590d0.json` — SHA-256 `C936BE...AE50C9`; only the root Pester settings source and `model-profile-attestation.Tests.ps1`.
- `python-batch-budget.01a03a40-eb5b-7e63-9c04-94ca4f0590d0.json` — SHA-256 `915C1D...CD7B`; only the two completed routing test files.

This is an authorized batch transition, not a cap override. After re-verifying the exact resolved paths, content, and hashes, the remediation may delete only these two named counter files and remove `.codex/state` only if it is then empty, immediately before the final full Pester gate. It must record transition evidence and must not delete, alter, or bypass any other runtime state or routing-authority data.

## Required Scope and Verification

1. Synchronize only the required bundled mirror from the canonical source using the repository-authorized source-to-bundle mechanism or an equivalent exact-text synchronization that preserves encoding.
2. Verify exact text parity with `tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources`.
3. Update the remediation plan in place to include the constrained counter-reset transition after the recorded repeated baseline failure and immediately before the full Pester gate; retain both failed baseline artifacts.
4. Run the applicable PowerShell toolchain in order: PoshQC format, PoshQC analyze, and PoshQC test. If a command changes files or fails, restart the loop from formatting.
5. Record command evidence under this feature folder's canonical `evidence/` hierarchy and retain the CI job identifier and failure diagnosis.
6. Commit and push only the bounded remediation and its required evidence; then monitor replacement CI for the pushed head.

## Do Not Do

- Do not change the canonical source settings file, unrelated PoshQC module files, routing-authority data, or Issue #552 implementation files.
- Do not delete, edit, or bypass any `.codex/state/**` data except the two named verified per-session counter files and the then-empty `.codex/state` directory under the authorized transition above.
- Do not weaken, skip, or modify the parity test.
- Do not add a new publisher or broaden the original plan.
- Do not use manual validation steps or accept a skipped command as passing.
