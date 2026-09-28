Timestamp: 2026-08-25T21-41
Command: PowerShell comparison of the P0-T2 manifest in `evidence/remediation-baseline/poshqc-settings-parity-before.2026-08-25T17-34.md` against current `Get-FileHash -Algorithm SHA256` and byte lengths for `tests/`, `.agents/skills/`, `.codex/state/`, and `plan.2026-08-25T14-58.md`; protected-settings `Get-FileHash`; `git status --porcelain=v1 --untracked-files=all`; and `.codex/state` authority-store enumeration.
EXIT_CODE: 1
Output Summary: REMEDIATION_REQUIRED. The protected settings match the P0-T2 baseline: source Pester SHA-256 `7A43CE095D86E1944CDE00435F1957A211B9667C1728B00AC2A0D4B8B4EE10FD`; both root and mirror PSSA settings SHA-256 `EDB5605C525A12741D6943FB776C74AA1EDB345F219DD4D240B9FAE0E9B5148E`. The baseline manifest has 914 entries; the current manifest has 913 entries after the two authorized P0-T6 removals. However, an additional prohibited-path file is present: `tests/scripts/dev_tools/__pycache__/test_poshqc_bundled_parity.cpython-313-pytest-9.0.2.pyc`, SHA-256 `6E9EF900125750B31D1E9E83584CE465DF2912629E50925EC5070A308B032CC5`, byte length 4400. The normalized current worktree-status snapshot equals the baseline normalized snapshot (`?? docs/features/active/2026-08-25-codex-subagent-routing-attestation-launch-binding-552/remediation-inputs.2026-08-25T17-20.md`). No authority-store file exists and `.codex/state` is absent. Final QA must not proceed.

## Comparison Results

- P0-T2 protected settings: unchanged.
- P0-T2 prohibited-path manifest: changed only by the two authorized P0-T6 counter removals and the unexpected Python bytecode file above.
- Normalized worktree status: unchanged from baseline.
- Authority-store search result: none.
