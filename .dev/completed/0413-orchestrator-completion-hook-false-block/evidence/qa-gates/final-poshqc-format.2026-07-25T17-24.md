# Final QA — PowerShell Format (issue #413, [P6-T1])

Timestamp: 2026-07-25T17-24

Command: `mcp__drm-copilot__run_poshqc_format` with `workspace_root = C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df`

EXIT_CODE: 0

Output Summary:

- MCP return payload: `{"ok":true,"tool":"run_poshqc_format","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a0fcdf306557436df","summary":"Ran bundled PoshQC format against '...'"}`.
- `ok: true` — format stage passed.

File-change confirmation via `git status --porcelain` (the MCP return payload does not report
file changes):

- Before the format run:

  ```text
   M .claude/hooks/validate-orchestrator-output.ps1
   M docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/plan.2026-07-25T15-37.md
   M extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1
   M tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1
  ?? docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/evidence/
  ```

- After the format run: **byte-for-byte the same list**, with no added or removed entries.

Second, stronger check: the SHA256 of `.claude/hooks/validate-orchestrator-output.ps1` after
this format run is `5E4BFA47C748C4E2E44262141E1F543B1ADE1A19ED43005855735AB422D3183B`, which
is identical to the hash recorded in `bundle-byte-parity.2026-07-25T17-16.md` before the
format run. The formatter did not rewrite the changed hook.

Verdict: **no files changed on this pass.** The loop does not restart at this stage; proceed
to [P6-T2] analyze.
