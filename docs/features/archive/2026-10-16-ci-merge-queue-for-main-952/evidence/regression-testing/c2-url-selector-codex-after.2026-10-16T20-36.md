# Remediation cycle 2 - Codex hook tests after the M1 URL rule (P3-T7)

Timestamp: 2026-10-16T20-36
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/codex-hooks]
EXIT_CODE: 0
Disposition: RETURNED
Output Summary: call returned (`ok: true`). P0-T8 baseline of `t-codex-hooks` is GREEN, so the returned call shows that every testcase of the folder passes, including N3 (`enforce-epic-merge-gate-docs-only.Tests.ps1`), N4 (`hook-docs-only-diff.Tests.ps1`), row (g) (`enforce-epic-merge-gate-merge-queue.Tests.ps1`), and the mirror byte-identity rows of `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`. N3 and N4 failed before the change (`c2-url-selector-codex-before.2026-10-16T20-18.md`).
