# Fixture Hook Names (P6-T9)

Timestamp: 2026-10-16T03-10
Command: Glob `{.claude,.codex}/hooks/{enforce-x,gate,x,Helper,Fixture.Helpers,Other.Helpers}.ps1` (worktree root)
EXIT_CODE: 0

Output Summary: the Glob returned no file. PASS.

Hook-like fixture names used in `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` (listed with `grep -o -E "[A-Za-z0-9._-]+\.ps1"` in SCRATCH/935/issue-935/p5t12.sh): `enforce-x.ps1`, `gate.ps1`, `x.ps1`, `Helper.ps1`, `Fixture.Helpers.ps1`, `Other.Helpers.ps1`. Each was checked under both `.claude/hooks/` and `.codex/hooks/`; none exists. The other `.ps1` names in the file are the three `EpicStateIsolation.*.Helpers.ps1` test helpers dot-sourced from `$PSScriptRoot`.
