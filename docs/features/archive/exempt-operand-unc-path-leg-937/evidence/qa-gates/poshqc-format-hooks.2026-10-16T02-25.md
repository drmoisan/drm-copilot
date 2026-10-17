# PoshQC format, hook folders (P2-T7)

Timestamp: 2026-10-16T02-25
Command: mcp__drm-copilot__run_poshqc_format workspace_root=WORKTREE scan_folders=[".claude/hooks", ".codex/hooks", "extensions/drm-copilot/resources/claude-customizations/.claude/hooks", "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks"]
EXIT_CODE: 0
Output Summary: ok=true. Summary (verbatim; host path replaced by WORKTREE): "Ran bundled PoshQC format against 'WORKTREE' with 4 selected scan folder(s)." The four targets-copy hashes are identical before and after (ef89c7f2e603ec3667d0c09589628be8af187559), so the formatter rewrote none of them. The porcelain output lists only the four copies and FEATURE paths. Acceptance met.

## Hashes (git hash-object)

| Copy | Before | After |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `ef89c7f2e603ec3667d0c09589628be8af187559` | `ef89c7f2e603ec3667d0c09589628be8af187559` |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `ef89c7f2e603ec3667d0c09589628be8af187559` | `ef89c7f2e603ec3667d0c09589628be8af187559` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `ef89c7f2e603ec3667d0c09589628be8af187559` | `ef89c7f2e603ec3667d0c09589628be8af187559` |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1` | `ef89c7f2e603ec3667d0c09589628be8af187559` | `ef89c7f2e603ec3667d0c09589628be8af187559` |

## git status --porcelain (after)

```
 M .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
 M .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
 M docs/features/active/exempt-operand-unc-path-leg-937/plan.2026-10-15T17-45.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
 M extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-additions-only.2026-10-16T02-24.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-mirror-identity.2026-10-16T02-24.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/other/targets-size-check.2026-10-16T02-24.md
```
