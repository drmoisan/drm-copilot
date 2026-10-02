# QC Step 1: PowerShell Format (P3-T1, pass 1)

Timestamp: 2026-10-01T19-23
P4-T11 files in scope: none (first pass).

Command: git status --porcelain (pre-pass)
EXIT_CODE: 0
Output Summary: ` M` plan file; `??` evidence/other/commit-push-p2.2026-10-01T19-22.md.

Command: sha256sum over the five P0-T8 files (pre-pass)
EXIT_CODE: 0
Output Summary:
```
1a3c71c0dec33468fc9f609dc180a1656b40a2fc3548e31acb2baa76eca5bcd5 tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
1436390db3e6d3ec8ba192cc4db316cde1a2f51b86e7f2877fddbb18b184a05e tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
d7ce8a35df15c4fef0c3e6f32d8064884b0233a71bb0af68e664bf4ea9067d81 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1
fae4e87f91351d77fba48695de7dde6c0085c65cd8ae906a65cef3567ec1af19 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ef48ca9d4b87467f51dd882d8c8f7200a29575b059a3c7537117ecea167471b5 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
```

Command: mcp__drm-copilot__run_poshqc_format (workspace_root = item worktree)
EXIT_CODE: 0
Output Summary: `ok: true`. No `Formatted:` count is asserted.

Command: git status --porcelain (post-pass)
EXIT_CODE: 0
Output Summary: identical to the pre-pass listing.

Command: sha256sum over the five P0-T8 files (post-pass)
EXIT_CODE: 0
Output Summary: all five hashes identical to the pre-pass hashes.

Acceptance: ok true; porcelain and hashes unchanged. Met.
