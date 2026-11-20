# Codex hook folder after the helper change (remediation cycle 1)

Timestamp: 2026-10-16T16-12
Task: [P3-T7]
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/codex-hooks]
EXIT_CODE: 0
Disposition: RETURNED
Baseline (P0-T8 t-codex-hooks): GREEN-AFTER-PIN (treated as GREEN after P2-T8)
Output Summary: call returned (ok=true); summary "Ran bundled PoshQC test against 'WORKTREE_ROOT' with 1 selected scan folder(s)." The folder includes the mirror byte-identity rows of tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1, the new suite tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 (including the CR-4 row that failed in P2-T10), and the pinned row of tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1.
