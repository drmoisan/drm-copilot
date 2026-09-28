# Baseline — PoshQC Format (issue #671)

Timestamp: 2026-09-17T07-54
Task: [P0-T6]
Command: mcp__drm-copilot__run_poshqc_format (workspace_root = worktree root), bracketed by `git -C <worktree root> status --porcelain` immediately before and immediately after
EXIT_CODE: 0

Output Summary:
- MCP call disposition: returned `ok: true`, summary "Ran bundled PoshQC format against '<worktree root>'." (the summary is a fixed template and carries no per-file result).
- The two porcelain captures are byte-identical.
- The formatter rewrote no tracked file.

## Porcelain before

```
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/
```

## Porcelain after

```
 M docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md
?? docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/evidence/
```

## Formatter-rewritten paths:

none

No gate file, modes file, or `hook-command-invocation.ps1` copy was rewritten.
