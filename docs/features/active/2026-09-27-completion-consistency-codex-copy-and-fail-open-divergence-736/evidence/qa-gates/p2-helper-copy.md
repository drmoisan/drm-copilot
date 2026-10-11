# Codex helper produced from the Claude helper ([P2-T2])

Timestamp: 2026-10-08T17-52
Command: pwsh -NoProfile -Command 'Copy-Item -LiteralPath .claude/hooks/enforce-completion-helpers.ps1 -Destination .codex/hooks/enforce-completion-helpers.ps1 -Force; "HELPERS_IDENTICAL=$((Get-FileHash -Algorithm SHA256 -LiteralPath .claude/hooks/enforce-completion-helpers.ps1).Hash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath .codex/hooks/enforce-completion-helpers.ps1).Hash)"'
EXIT_CODE: 0
Output Summary: printed `HELPERS_IDENTICAL=True`.
