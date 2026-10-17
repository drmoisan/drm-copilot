# Phase 4 Fixture Names and Row Counts (P4-T1)

Timestamp: 2026-10-16T01-59
Command: Glob `{.claude,.codex}/hooks/{enforce-x,gate,x,a,b,Helper,Fixture.Helpers,Other.Helpers,Probe.Helpers}.ps1` (worktree root); sh SCRATCH/935/issue-935/p4t1.sh (`grep -c -F -e <row token>` and `awk 'END { print NR }'` on tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1, plus `grep -o -E` listing of every `.ps1` name in the file)
EXIT_CODE: 0

Output Summary: PASS. The Glob returned no file, so no fixture hook name used in the suite exists under `.claude/hooks/` or `.codex/hooks/`. Each row token count is 1; the file is 238 lines.

Fixture names used in the suite (checked by the Glob, which was run before the file was written): `enforce-x.ps1`, `gate.ps1`, `x.ps1`, `Helper.ps1`, `Fixture.Helpers.ps1`, `Other.Helpers.ps1`. The remaining `.ps1` names in the file are the three `EpicStateIsolation.*.Helpers.ps1` helpers the suite dot-sources from `$PSScriptRoot` (test helpers, not hooks).

| Token | Count |
| --- | --- |
| `It 'R1 identifies ` | 1 |
| `It 'R1 does not identify ` | 1 |
| `R2 (a) helper-only block yields no dot-source finding` | 1 |
| `R2 (b) seam mock before the last helper dot-source yields the ordering finding` | 1 |
| `R2 (c) helper-only block without the seam mock yields the presence finding` | 1 |
| `R2 (d) helper plus unidentified non-helper dot-source yields no dot-source loads the hook` | 1 |
| line count | 238 (at most 500) |
