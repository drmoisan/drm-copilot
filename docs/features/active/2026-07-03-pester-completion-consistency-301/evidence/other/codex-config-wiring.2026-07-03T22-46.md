# `.codex/config.toml` Hook Wiring Confirmation

Timestamp: 2026-07-04T09-56

Command: search of `.codex/config.toml` for the `enforce-completion-consistency.ps1` `PreToolUse` entry.

## Matching Excerpt (lines 77-79 of `.codex/config.toml`)

```
[[hooks.PreToolUse]]
matcher = "Write|Edit"
command = "pwsh -NoProfile -File .codex/hooks/enforce-completion-consistency.ps1"
```

## Output Summary

Confirmed `.codex/config.toml` wires `pwsh -NoProfile -File .codex/hooks/enforce-completion-consistency.ps1` as the `PreToolUse` hook command for the `Write|Edit` matcher.
