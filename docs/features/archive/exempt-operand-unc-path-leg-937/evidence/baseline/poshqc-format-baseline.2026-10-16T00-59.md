# PoshQC Format Baseline (issue #937)

Timestamp: 2026-10-16T00-59
Task: P0-T10
Command: git status --porcelain; mcp__drm-copilot__run_poshqc_format workspace_root=WORKTREE scan_folders=[".claude/hooks", ".codex/hooks", "extensions/drm-copilot/resources/claude-customizations/.claude/hooks", "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks", "tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]; git status --porcelain
EXIT_CODE: 0
Output Summary: ok=true. Summary (verbatim; the host worktree path is replaced by the token WORKTREE): "Ran bundled PoshQC format against 'WORKTREE' with 6 selected scan folder(s)." Porcelain before and after are identical; the formatter rewrote no file (no pre-existing drift).

## Porcelain before

```text
 M docs/features/active/exempt-operand-unc-path-leg-937/plan.2026-10-15T17-45.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/
```

## Porcelain after

```text
 M docs/features/active/exempt-operand-unc-path-leg-937/plan.2026-10-15T17-45.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/
```

Acceptance: identical. PASS.
