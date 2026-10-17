# Line Counts: Gate Production Files (P3-T20)

Timestamp: 2026-10-16T11-13
Command: git grep -c -e "^" -- .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-command.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate-command.ps1
EXIT_CODE: 0
Output Summary: four counts, each at or below 500; .claude/hooks/enforce-epic-merge-gate.ps1 = 441 (below the P0-T7 value 472); .codex/hooks/enforce-epic-merge-gate.ps1 = 364 (below the P0-T7 value 385)

Output (verbatim):
```
.claude/hooks/enforce-epic-merge-gate-command.ps1:184
.claude/hooks/enforce-epic-merge-gate.ps1:441
.codex/hooks/enforce-epic-merge-gate-command.ps1:184
.codex/hooks/enforce-epic-merge-gate.ps1:364
```
