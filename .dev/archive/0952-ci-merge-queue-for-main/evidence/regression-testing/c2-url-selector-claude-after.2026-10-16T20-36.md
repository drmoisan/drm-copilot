# Remediation cycle 2 - Claude hook tests after the M1 URL rule (P3-T6)

Timestamp: 2026-10-16T20-36
Command: mcp__drm-copilot__run_poshqc_test workspace_root=WORKTREE_ROOT scan_folders=[tests/scripts/claude-hooks]
EXIT_CODE: 0
Disposition: RETURNED
Output Summary: call returned (`ok: true`). P0-T8 baseline of `t-claude-hooks` is GREEN, so the returned call shows that every testcase of the folder passes, including N1 (`hook-docs-only-diff.MergeExemption.Tests.ps1`), N2 (`enforce-epic-merge-gate.DocsOnly.Tests.ps1`) and the four-copy parity testcase `is byte-identical across all four copies (issue #927)` (`hook-docs-only-diff.Tests.ps1`). N1 and N2 failed before the change; the parity testcase passed before and after (`c2-url-selector-claude-before.2026-10-16T20-14.md`).
