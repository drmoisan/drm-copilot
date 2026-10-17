# P2-T7 PowerShell Format (routing suites)

Timestamp: 2026-10-01T19-20

Command: git status --porcelain (pre-pass)
EXIT_CODE: 0
Output Summary: 16 entries: ` M` plan file, ` M` the four routing suites, and 11 untracked evidence files under `<FEATURE>/evidence/`.

Command: sha256sum over the four routing suites (pre-pass)
EXIT_CODE: 0
Output Summary:
```
1436390db3e6d3ec8ba192cc4db316cde1a2f51b86e7f2877fddbb18b184a05e tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1
d7ce8a35df15c4fef0c3e6f32d8064884b0233a71bb0af68e664bf4ea9067d81 tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1
fae4e87f91351d77fba48695de7dde6c0085c65cd8ae906a65cef3567ec1af19 tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1
ef48ca9d4b87467f51dd882d8c8f7200a29575b059a3c7537117ecea167471b5 tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
```

Command: mcp__drm-copilot__run_poshqc_format (workspace_root = item worktree)
EXIT_CODE: 0
Output Summary: `ok: true`.

Command: sha256sum over the four routing suites (post-pass)
EXIT_CODE: 0
Output Summary: all four hashes identical to the pre-pass hashes.

Command: git status --porcelain (post-pass)
EXIT_CODE: 0
Output Summary: the same 16 entries as the pre-pass listing.

Acceptance: ok true; hashes and porcelain unchanged. Met.
