# P1-T7 PowerShell Format (drift-gate suite)

Timestamp: 2026-10-01T19-13

Command: git status --porcelain (pre-pass)
EXIT_CODE: 0
Output Summary: ` M` plan file, ` M tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, and 11 untracked evidence files under `<FEATURE>/evidence/`.

Command: sha256sum tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 (pre-pass)
EXIT_CODE: 0
Output Summary: 1a3c71c0dec33468fc9f609dc180a1656b40a2fc3548e31acb2baa76eca5bcd5

Command: mcp__drm-copilot__run_poshqc_format (workspace_root = item worktree)
EXIT_CODE: 0
Output Summary: `ok: true`.

Command: sha256sum tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 (post-pass)
EXIT_CODE: 0
Output Summary: 1a3c71c0dec33468fc9f609dc180a1656b40a2fc3548e31acb2baa76eca5bcd5 (unchanged)

Command: git status --porcelain (post-pass)
EXIT_CODE: 0
Output Summary: identical to the pre-pass listing.

Acceptance: ok true; hash and porcelain unchanged. Met.
