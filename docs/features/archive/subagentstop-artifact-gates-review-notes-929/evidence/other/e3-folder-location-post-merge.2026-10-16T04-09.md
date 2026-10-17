# E3 Folder Location After Merge Check (P7-T3)

Timestamp: 2026-10-16T04-09

Command: sh SCRATCH/929/P7-T3-1.sh
Script: `$a = Test-Path -LiteralPath docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md; $b = Test-Path -LiteralPath docs/features/archive/subagentstop-envelope-artifact-gates-905/spec.md; 'ACTIVE=' + $a; 'ARCHIVE=' + $b; if ($a -and $b) { 'E3-LOCATION-AMBIGUOUS' }; $s = if ($a) { 'docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md' } elseif ($b) { 'docs/features/archive/subagentstop-envelope-artifact-gates-905/spec.md' } else { 'NONE' }; 'E3_SPEC: ' + $s; if ($s -ne 'NONE') { Select-String -Path $s -Pattern '^- \[x\] AC-11:','^- \[x\] AC-20:','^  Post-review clarification \(2026-10-15, issue #929\):' | ForEach-Object { 'LINE ' + $_.LineNumber + ' | ' + $_.Line.Substring(0, [Math]::Min(40, $_.Line.Length)) } }`
EXIT_CODE: 0
Output:
```
ACTIVE=True
ARCHIVE=False
E3_SPEC: docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md
LINE 377 | - [x] AC-11: Zero-false-positive gate or
LINE 378 |   Post-review clarification (2026-10-15,
LINE 387 | - [x] AC-20: No `CLAUDE_HOOK_INPUT` lite
LINE 388 |   Post-review clarification (2026-10-15,
```

Output Summary: `E3_SPEC: docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md` (current `E3_SPEC`). Four `LINE` entries are printed; each clarification line number is its AC line number plus 1 (377/378, 387/388). No remediation was needed (P7-T2 recorded `NO-MERGE-NEEDED`).
