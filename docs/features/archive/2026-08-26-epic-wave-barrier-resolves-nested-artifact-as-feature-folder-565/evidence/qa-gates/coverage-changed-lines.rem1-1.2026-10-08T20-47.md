# Final QC (Remediation Cycle 1, Iteration 1): Changed-Line Coverage (R-PROD vs RemediationBase)

Timestamp: 2026-10-08T20-47
Command: $mb = 'da2dc7d59a4ba9c4a12d8a25534d3f88177ae60a'; [xml]$x = Get-Content -Raw -LiteralPath artifacts/pester/powershell-coverage.xml; foreach ($p in @(<the seven R-PROD paths>)) { $nr = @(git diff -U0 $mb -- $p | Select-String -Pattern '^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@' | ForEach-Object { ... added line numbers ... }); ... 'CHANGED ' + $p + ' Executable=' + $ln.Count + ' Covered=' + ($ln.Count - $un.Count) + ' Uncovered=' + ($un -join ',') }  (CLC template with $mb set to the RemediationBase; full body in <scratchpad>/c2-565-r1-P5-T12.ps1)
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P5-T12.ps1
EXIT_CODE: 0
Output Summary: For each of the seven paths Uncovered= is empty. 17 changed executable lines in total, all covered (RW01 3/3, RW02 3/3, RW03 4/4, RW04 4/4, RW05 1/1, RW06 1/1, RW07 1/1).

```
CHANGED .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Executable=3 Covered=3 Uncovered=
CHANGED .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 Executable=3 Covered=3 Uncovered=
CHANGED .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 Executable=4 Covered=4 Uncovered=
CHANGED .codex/hooks/enforce-orchestration-preimplementation-gate.ps1 Executable=4 Covered=4 Uncovered=
CHANGED .claude/hooks/enforce-epic-wave-barrier.ps1 Executable=1 Covered=1 Uncovered=
CHANGED .claude/hooks/enforce-parallel-cohort-barrier.ps1 Executable=1 Covered=1 Uncovered=
CHANGED .claude/hooks/enforce-parallel-drift-gate.ps1 Executable=1 Covered=1 Uncovered=
```
