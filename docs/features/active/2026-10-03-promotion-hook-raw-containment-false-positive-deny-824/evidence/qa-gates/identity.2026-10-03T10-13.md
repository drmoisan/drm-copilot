# P6-T8 Identity checks (AC-23, AC-24)

Timestamp: 2026-10-03T10-13
Command: foreach ($p in <six pairs listed in P6-T8>) { "$($p[0]) | $($p[1]) | EQUAL=$((Get-FileHash -LiteralPath $p[0]).Hash -eq (Get-FileHash -LiteralPath $p[1]).Hash)" }
EXIT_CODE: 0
Output Summary:
- .claude/hooks/hook-command-invocation.ps1 | .codex/hooks/hook-command-invocation.ps1 | EQUAL=True
- .claude/hooks/hook-command-raw-invocation.ps1 | .codex/hooks/hook-command-raw-invocation.ps1 | EQUAL=True
- .claude/hooks/hook-command-invocation.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-invocation.ps1 | EQUAL=True
- .claude/hooks/hook-command-raw-invocation.ps1 | extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-command-raw-invocation.ps1 | EQUAL=True
- .codex/hooks/hook-command-invocation.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-invocation.ps1 | EQUAL=True
- .codex/hooks/hook-command-raw-invocation.ps1 | extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-command-raw-invocation.ps1 | EQUAL=True
- First two lines: AC-23 (cross-surface identity). Last four: the MIRROR-PAIRS half of AC-24.
- Result: PASS
