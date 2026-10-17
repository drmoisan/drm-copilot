# Path-Leg Literal Classification Baseline, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T05-30
Task: P0-T6 (remediation-plan.2026-10-16T03-39.md)
Command: poetry run python -I SCRATCH/pathleg_rows.py tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary: COUNT_OLD=24, COUNT_NEW=0, COUNT_NONE=15, COUNT_TOTAL=39. No existing path-leg literal is denied only by the new alternatives. Matches the expected counts (24 / 0 / 15).

Printed lines (verbatim; TAB-separated):

```text
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:31	NONE	[/synthetic-worktrees/other/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:40	NONE	[scripts/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:48	NONE	[/synthetic-worktrees/other/../a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:58	NONE	[C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:66	NONE	[/synthetic-worktrees/other/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:66	NONE	[scripts/b.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:276	NONE	[a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:276	NONE	[b.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:276	NONE	[c.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:276	NONE	[d.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:401	OLD	[\\server\share\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:402	OLD	[//server/share/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:403	OLD	[\/server/share/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:404	OLD	[/\server\share\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:405	OLD	[\\]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:406	OLD	[//]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:407	OLD	[\\?\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:408	OLD	[//?/C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:409	OLD	[\\?\UNC\server\share\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:410	OLD	[\\.\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:411	OLD	[//./C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:412	OLD	[\??\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:413	OLD	[/??/C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:414	OLD	[C:wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:415	OLD	[C:]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:430	NONE	[C:\]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:431	NONE	[C:/]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:445	NONE	[/synthetic-worktrees/other/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:445	OLD	[\\server\share\b.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:458	OLD	[\\server\share\..\x]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:470	OLD	[\\?\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:77	NONE	[/synthetic-worktrees/epic-child/scripts/powershell/Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:79	OLD	[\\server\share\wt\scripts\powershell\Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:80	OLD	[\\?\C:\wt\scripts\powershell\Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:81	OLD	[C:wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:69	NONE	[/synthetic-worktrees/epic-child/scripts/powershell/Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:70	OLD	[\\server\share\wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:71	OLD	[\\?\C:\wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:72	OLD	[C:wt\scripts\powershell\Sample.ps1]
COUNT_OLD=24
COUNT_NEW=0
COUNT_NONE=15
COUNT_TOTAL=39
```
