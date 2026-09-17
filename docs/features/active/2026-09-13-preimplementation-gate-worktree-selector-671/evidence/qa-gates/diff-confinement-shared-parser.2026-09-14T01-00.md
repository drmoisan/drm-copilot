# Diff Confinement — Shared Parser and Epic-Merge Gate (issue #671)

Timestamp: 2026-09-17T08-17
Task: [P5-T3]
Command: git -C <worktree root> status --porcelain ; git -C <worktree root> diff --merge-base main -- .claude/hooks/hook-command-invocation.ps1 .codex/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 ; mcp__drm-copilot__run_poshqc_test (scan_folders = ["tests/scripts/claude-hooks"]) ; `artifacts/pester/pester-junit.xml` (LastWriteTime 2026-09-17T08:17:32) read by a scratchpad parser under pwsh 7.6.6
EXIT_CODE: 4
ExpectedExitCode: 4

Output Summary:
- The `git diff --merge-base main` output is empty (no bytes).
- The porcelain output (same capture as [P5-T1]) lists none of the five paths.
- MCP call disposition: non-zero (`ok: false`, "Command exited with code 4."). The four failures are the three new L3a/L3b/L8 rows in the Claude command-exemption suite and the baseline `enforce-pr-author-skill` failure; neither merge-gate suite is involved.
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`: testsuite matches=1; name=`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686/tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, tests=56, failures=0, errors=0, skipped=0, disabled=0.
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`: testsuite matches=1; name=`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a6dbf51ad3a3ac686/tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`, tests=12, failures=0, errors=0, skipped=0, disabled=0.

## Diff capture

```
(empty)
```
