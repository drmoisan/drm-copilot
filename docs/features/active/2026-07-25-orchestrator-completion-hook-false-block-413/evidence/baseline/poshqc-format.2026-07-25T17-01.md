# PowerShell Format Baseline — PoshQC (issue #413)

Timestamp: 2026-07-25T17-01

Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root = C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`

EXIT_CODE: 0

Output Summary:

- MCP return payload: `{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df","summary":"Ran bundled PoshQC format against '...'"}`.
- `ok: true` — the format stage succeeded with no error.
- File-change confirmation via `git status --porcelain` (the MCP payload does not report file changes):
  - Before the format run:
    ```text
     M docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/plan.2026-07-25T15-37.md
    ```
  - After the format run:
    ```text
     M docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/plan.2026-07-25T15-37.md
    ?? docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/
    ```
  - The only delta between the two is the new untracked `<FEATURE>/evidence/` directory, which
    this executor created between the two samples (Phase 0 evidence artifacts). No PowerShell
    file was reformatted; no tracked source file changed.
- Baseline verdict: clean. Formatting is at a fixed point before any production edit.
