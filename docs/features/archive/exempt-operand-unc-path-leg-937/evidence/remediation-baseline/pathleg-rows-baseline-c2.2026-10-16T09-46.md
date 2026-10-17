# Path-Leg Literal Classification Baseline, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T09-46
Task: P0-T5 (remediation-plan.2026-10-16T08-40.md)
Command: poetry run python -I SCRATCH/pathleg_rows_c2.py tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary: COUNT_OLD=38, COUNT_NEW=0, COUNT_NONE=15, COUNT_TOTAL=53. No existing path-leg literal is denied only by the cycle 2 URI-scheme alternative (OLD = cycle 1 pattern, NEW = cycle 2 pattern).

Printed lines (verbatim):

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
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:416	OLD	[ \\server\share\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:417	OLD	[ /synthetic-worktrees/other/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:418	OLD	[/synthetic-worktrees/other/a.ps1 ]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:419	OLD	[file:///C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:420	OLD	[file://server/share/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:421	OLD	[~/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:422	OLD	[~\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:423	OLD	[\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:440	NONE	[C:\]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:441	NONE	[C:/]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:455	NONE	[/synthetic-worktrees/other/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:455	OLD	[\\server\share\b.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:469	OLD	[\\server\share\..\x]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:484	OLD	[\\?\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:77	NONE	[/synthetic-worktrees/epic-child/scripts/powershell/Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:82	OLD	[\\server\share\wt\scripts\powershell\Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:88	OLD	[\\?\C:\wt\scripts\powershell\Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:94	OLD	[C:wt\scripts\powershell\Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:100	OLD	[file:///C:/wt/scripts/powershell/Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:106	OLD	[~/wt/scripts/powershell/Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:112	OLD	[\wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:69	NONE	[/synthetic-worktrees/epic-child/scripts/powershell/Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:72	OLD	[\\server\share\wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:78	OLD	[\\?\C:\wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:84	OLD	[C:wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:90	OLD	[file:///C:/wt/scripts/powershell/Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:96	OLD	[~/wt/scripts/powershell/Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:102	OLD	[\wt\scripts\powershell\Sample.ps1]
COUNT_OLD=38
COUNT_NEW=0
COUNT_NONE=15
COUNT_TOTAL=53
```
