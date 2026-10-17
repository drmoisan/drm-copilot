# Path-Leg Literal Classification After Test Edits, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T06-17
Task: P1-T13 (remediation-plan.2026-10-16T03-39.md)
Command: poetry run python -I SCRATCH/pathleg_rows.py tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1
EXIT_CODE: 0
Output Summary: COUNT_OLD=24, COUNT_NEW=14, COUNT_NONE=15, COUNT_TOTAL=53. OLD and NONE counts are unchanged from the baseline (wrapped cycle 0 rows extract to the same literals). The 14 NEW lines are exactly the 8 U27 spellings of the Row inventory (targets tests lines 416 to 423), the 3 Claude gate FilePath inputs (lines 100, 106, 112), and the 3 Codex marker paths (lines 90, 96, 102).

## Output

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
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:416	NEW	[ \\server\share\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:417	NEW	[ /synthetic-worktrees/other/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:418	NEW	[/synthetic-worktrees/other/a.ps1 ]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:419	NEW	[file:///C:/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:420	NEW	[file://server/share/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:421	NEW	[~/wt/a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:422	NEW	[~\wt\a.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1:423	NEW	[\wt\a.ps1]
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
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:100	NEW	[file:///C:/wt/scripts/powershell/Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:106	NEW	[~/wt/scripts/powershell/Sample.ps1]
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1:112	NEW	[\wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:69	NONE	[/synthetic-worktrees/epic-child/scripts/powershell/Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:72	OLD	[\\server\share\wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:78	OLD	[\\?\C:\wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:84	OLD	[C:wt\scripts\powershell\Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:90	NEW	[file:///C:/wt/scripts/powershell/Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:96	NEW	[~/wt/scripts/powershell/Sample.ps1]
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1:102	NEW	[\wt\scripts\powershell\Sample.ps1]
COUNT_OLD=24
COUNT_NEW=14
COUNT_NONE=15
COUNT_TOTAL=53
```

## Acceptance

| Condition | Result |
|---|---|
| `COUNT_OLD=24` | met |
| `COUNT_NONE=15` | met |
| `COUNT_NEW=14`, exactly the 8 U27 spellings, 3 Claude FilePath inputs, 3 Codex marker paths | met |
