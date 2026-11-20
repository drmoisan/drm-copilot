# PA-3 Relocation: Content-Preservation Check

Timestamp: 2026-10-08T20-35
Command: $o = @(git show 'HEAD:docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/evidence/qa-gates/analyze-selfhosted.1.2026-10-08T19-50.md'); $n = @(Get-Content -LiteralPath 'docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/evidence/remediation-baseline/superseded/analyze-selfhosted.1.2026-10-08T19-50.md' | Where-Object { $_ -notlike 'Superseded: *' }); if (($o -join "`n") -ceq ($n -join "`n")) { 'CONTENT-PRESERVED' } else { 'CONTENT-CHANGED'; exit 1 }
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P4-T3.ps1
EXIT_CODE: 0
Output Summary: CONTENT-PRESERVED. The relocated file under evidence/remediation-baseline/superseded/ equals the original committed qa-gates file except for the one added Superseded: line. P4-T2 (git rm) removed the original; `ls` on the original path reports "No such file or directory". P4-T4 updated the single forward citation in qa-gates/qc-loop.2026-10-08T19-15.md line 10.

```
CONTENT-PRESERVED
```
