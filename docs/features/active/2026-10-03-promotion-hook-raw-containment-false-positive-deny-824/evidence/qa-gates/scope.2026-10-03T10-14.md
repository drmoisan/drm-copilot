# P6-T10 Scope check

Timestamp: 2026-10-03T10-14
Command: git diff --numstat 9e8fe7eb576a904ac22cab96faf8c5c12311833e -- <eight in-scope paths>; git status --porcelain --untracked-files=all -- <eight in-scope paths>; git status --porcelain --untracked-files=no | Where-Object { $_ -notmatch '<feature folder>/' -and $_ -notmatch '\.claude/agent-memory/' }
EXIT_CODE: 0
Output Summary:
- numstat lists exactly 21 tracked files:
  - 20/12 .claude/hooks/hook-command-invocation.ps1
  - 20/12 .codex/hooks/hook-command-invocation.ps1
  - 20/12 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1
  - 20/12 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1
  - 1/0 for each core.json (Claude and Codex)
  - 1/1 LEGACY; S1-S14 as in P4-T6 (S3 and S4 18/1, all others with 0 deletions)
- Scoped porcelain status: 27 lines, the same 21 files as ' M' plus exactly six untracked files: .claude/hooks/hook-command-raw-invocation.ps1, .codex/hooks/hook-command-raw-invocation.ps1, extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-raw-invocation.ps1, extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-raw-invocation.ps1, tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1, tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1
- Filtered tracked status: exactly the same 21 paths and nothing else (no tracked file outside the plan's scope changed)
- Result: PASS
