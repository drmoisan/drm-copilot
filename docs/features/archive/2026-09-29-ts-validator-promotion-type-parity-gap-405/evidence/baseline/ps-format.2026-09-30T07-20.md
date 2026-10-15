# PowerShell formatter baseline (P0-T16)

Timestamp: 2026-09-30T07-20
Command: git status --porcelain; mcp__drm-copilot__run_poshqc_format with workspace_root = worktree root (no scan_folders); git status --porcelain
EXIT_CODE: 0
MCP-Status: success (the tool result carried `"ok":true`, summary "Ran bundled PoshQC format against" the worktree root)
Output Summary:
- Porcelain before:
```
?? docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/
```
- Porcelain after:
```
?? docs/features/active/2026-09-29-ts-validator-promotion-type-parity-gap-405/evidence/baseline/
```
- Listings identical: the run rewrote no files. No revert needed.
