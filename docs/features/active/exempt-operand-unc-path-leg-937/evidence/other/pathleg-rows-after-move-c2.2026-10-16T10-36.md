# Path-Leg Literal Classification After the Move, Remediation Cycle 2 (issue #937 RI-8)

Timestamp: 2026-10-16T10-36
Task: P1-T5 (remediation-plan.2026-10-16T08-40.md)
Command: poetry run python -I SCRATCH/pathleg_rows_c2.py tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1; poetry run python -I SCRATCH/pathleg_rows_c2.py tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1; poetry run python -I SCRATCH/pathleg_rows_c2.py tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1 (run via sh SCRATCH/c2_p1t5.sh from WORKTREE)
EXIT_CODE: 0
Output Summary: Six-file run: COUNT_OLD=38 COUNT_NEW=0 COUNT_NONE=15 COUNT_TOTAL=53. Source-suite run: COUNT_OLD=0 COUNT_NEW=0 COUNT_NONE=10 COUNT_TOTAL=10. New-suite run: COUNT_OLD=26 COUNT_NEW=0 COUNT_NONE=3 COUNT_TOTAL=29. Exit codes 0, 0, 0.

## Six-file run (exit 0)

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
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:24	OLD	[\\server\share\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:25	OLD	[//server/share/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:26	OLD	[\/server/share/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:27	OLD	[/\server\share\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:28	OLD	[\\]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:29	OLD	[//]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:30	OLD	[\\?\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:31	OLD	[//?/C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:32	OLD	[\\?\UNC\server\share\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:33	OLD	[\\.\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:34	OLD	[//./C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:35	OLD	[\??\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:36	OLD	[/??/C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:37	OLD	[C:wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:38	OLD	[C:]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:39	OLD	[ \\server\share\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:40	OLD	[ /synthetic-worktrees/other/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:41	OLD	[/synthetic-worktrees/other/a.ps1 ]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:42	OLD	[file:///C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:43	OLD	[file://server/share/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:44	OLD	[~/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:45	OLD	[~\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:46	OLD	[\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:63	NONE	[C:\]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:64	NONE	[C:/]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:78	NONE	[/synthetic-worktrees/other/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:78	OLD	[\\server\share\b.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:92	OLD	[\\server\share\..\x]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:107	OLD	[\\?\C:\wt\a.ps1]
COUNT_OLD=38
COUNT_NEW=0
COUNT_NONE=15
COUNT_TOTAL=53
```

## Source-suite run (exit 0)

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
COUNT_OLD=0
COUNT_NEW=0
COUNT_NONE=10
COUNT_TOTAL=10
```

## New-suite run (exit 0)

```text
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:24	OLD	[\\server\share\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:25	OLD	[//server/share/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:26	OLD	[\/server/share/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:27	OLD	[/\server\share\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:28	OLD	[\\]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:29	OLD	[//]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:30	OLD	[\\?\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:31	OLD	[//?/C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:32	OLD	[\\?\UNC\server\share\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:33	OLD	[\\.\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:34	OLD	[//./C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:35	OLD	[\??\C:\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:36	OLD	[/??/C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:37	OLD	[C:wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:38	OLD	[C:]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:39	OLD	[ \\server\share\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:40	OLD	[ /synthetic-worktrees/other/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:41	OLD	[/synthetic-worktrees/other/a.ps1 ]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:42	OLD	[file:///C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:43	OLD	[file://server/share/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:44	OLD	[~/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:45	OLD	[~\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:46	OLD	[\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:63	NONE	[C:\]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:64	NONE	[C:/]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:78	NONE	[/synthetic-worktrees/other/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:78	OLD	[\\server\share\b.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:92	OLD	[\\server\share\..\x]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1:107	OLD	[\\?\C:\wt\a.ps1]
COUNT_OLD=26
COUNT_NEW=0
COUNT_NONE=3
COUNT_TOTAL=29
```
