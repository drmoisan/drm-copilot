# PoshQC format, hook folders, remediation cycle 1 (P2-T6)

Timestamp: 2026-10-16T07-09
Command: mcp__drm-copilot__run_poshqc_format with workspace_root WORKTREE and scan_folders [".claude/hooks", ".codex/hooks", "extensions/drm-copilot/resources/claude-customizations/.claude/hooks", "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks"]
EXIT_CODE: 0
Output Summary: ok=true. The four targets-copy hashes are identical before and after the formatter (e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2), so the formatter rewrote none of them. The porcelain output after the run lists only the four targets copies and FEATURE paths.

MCP summary (verbatim): "Ran bundled PoshQC format against 'WORKTREE' with 4 selected scan folder(s)."

## git hash-object of the four copies

| Copy | Before | After |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 | e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 | e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 | e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 | e92597ce1e4c2b0ed0bc9191f21f38e4afe282b2 |

## git status --porcelain after the run (verbatim)

```
 M .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
 M .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
 M docs/features/active/exempt-operand-unc-path-leg-937/remediation-plan.2026-10-16T03-39.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-diff-shape-c1.2026-10-16T07-06.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-mirror-identity-c1.2026-10-16T07-06.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-size-check-c1.2026-10-16T07-06.md
```

## Acceptance check

- Before and after hashes identical: met.
- Porcelain lists no path beyond the four copies and FEATURE paths: met.
