Timestamp: 2026-08-25T21-46
Command: PowerShell comparison of the P0-T2 manifest in `evidence/remediation-baseline/poshqc-settings-parity-before.2026-08-25T17-34.md` against current SHA-256 and byte lengths for `tests/`, `.agents/skills/`, `.codex/state/`, and `plan.2026-08-25T14-58.md`; protected-settings SHA-256; `git status --porcelain=v1 --untracked-files=all`; and `.codex/state` authority-store enumeration.
EXIT_CODE: 0
Output Summary: PASS. The P0-T2 baseline contains 914 prohibited-path entries and the current comparison contains 913: exactly the two P0-T6-authorized batch-counter removals are absent, and the exact allowed ignored parity-test bytecode artifact is present. The Pester source SHA-256 remains `7A43CE095D86E1944CDE00435F1957A211B9667C1728B00AC2A0D4B8B4EE10FD`; both protected PSSA files remain `EDB5605C525A12741D6943FB776C74AA1EDB345F219DD4D240B9FAE0E9B5148E`. No other manifest differences or authority-store files exist. The normalized worktree snapshot contains only the baseline remediation-inputs file.

## Protected Settings

| Path | SHA-256 | Byte length | Baseline comparison |
| --- | --- | ---: | --- |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `7A43CE095D86E1944CDE00435F1957A211B9667C1728B00AC2A0D4B8B4EE10FD` | 15349 | unchanged |
| `scripts/powershell/PoshQC/settings/pssa.settings.psd1` | `EDB5605C525A12741D6943FB776C74AA1EDB345F219DD4D240B9FAE0E9B5148E` | 2324 | unchanged |
| `extensions/drm-copilot/resources/powershell/PoshQC/settings/pssa.settings.psd1` | `EDB5605C525A12741D6943FB776C74AA1EDB345F219DD4D240B9FAE0E9B5148E` | 2324 | unchanged |

## Manifest and Status Comparison

- Baseline prohibited-path manifest entries: 914.
- Current prohibited-path manifest entries: 913.
- Authorized absent entries: `.codex/state/powershell-batch-budget.01a03a40-eb5b-7e63-9c04-94ca4f0590d0.json`; `.codex/state/python-batch-budget.01a03a40-eb5b-7e63-9c04-94ca4f0590d0.json`.
- Generated-test exception: `tests/scripts/dev_tools/__pycache__/test_poshqc_bundled_parity.cpython-313-pytest-9.0.2.pyc`; SHA-256 `6E9EF900125750B31D1E9E83584CE465DF2912629E50925EC5070A308B032CC5`; byte length 4400; ignored by Git; provenance: the P0-T3 and P1-T2 parity-test commands.
- Other changed, missing, or additional manifest entries: none.
- `.codex/state` authority-store, attestation, and routing-authority search result: none; the directory is absent after the authorized counter transition.
- Normalized worktree-status snapshot: `?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/remediation-inputs.2026-08-25T17-20.md`.
