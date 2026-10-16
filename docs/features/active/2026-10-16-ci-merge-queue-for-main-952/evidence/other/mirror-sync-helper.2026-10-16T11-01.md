# Mirror Sync: Helper Claude to Codex (P3-T8)

Timestamp: 2026-10-16T11-01
Command: git add .codex/hooks/enforce-epic-merge-gate-command.ps1; git hash-object .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1
EXIT_CODE: 0
Output Summary: PAIR_EQUAL=true helper-claude-codex

Mechanism: the Codex file was written with the Write tool from the exact text of the Claude helper (different relative path, so git checkout-index does not apply).

| Path | Hash |
|---|---|
| .claude/hooks/enforce-epic-merge-gate-command.ps1 | d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd |
| .codex/hooks/enforce-epic-merge-gate-command.ps1 | d7dfe732d6bd8f90cf779d7a4cf9574d4d6f12cd |
