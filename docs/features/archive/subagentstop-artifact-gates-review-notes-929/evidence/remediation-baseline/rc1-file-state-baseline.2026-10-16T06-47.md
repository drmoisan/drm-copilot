# Remediation Cycle 1 File-State Baseline (P0-T15)

Timestamp: 2026-10-16T06-47
Command: sh SCRATCH/929/RC1-P0-T15-1.sh
EXIT_CODE: 0

Script: SCRATCH/929/RC1-P0-T15-1.ps1 (file-state body from the plan's Fixed names), verbatim:

```powershell
$f = 'tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1'; $s = 'docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md'; 'LINES=' + (Get-Content -LiteralPath $f).Count; $h = @(Select-String -LiteralPath $f -SimpleMatch -Pattern 'SubagentStopEnvelope.Helpers.ps1'); 'HELPER=' + $h.Count + ' JOINPATH=' + @($h | Where-Object { $_.Line.Contains('Join-Path $PSScriptRoot') }).Count; 'HELPER_LINES=' + (($h | ForEach-Object { $_.LineNumber }) -join ','); 'CONVERT=' + @(Select-String -LiteralPath $f -SimpleMatch -Pattern "ConvertTo-SubagentStopEnvelopeJson -AgentType 'task-researcher'").Count; 'SESSION_ID_LITERAL=' + @(Select-String -LiteralPath $f -SimpleMatch -Pattern 'session_id').Count; 'SPEC_CHECKED=' + @(Select-String -LiteralPath $s -Pattern '^- \[x\] AC-').Count; 'SPEC_UNCHECKED=' + @(Select-String -LiteralPath $s -Pattern '^- \[ \] AC-').Count
```

Wrapper: SCRATCH/929/RC1-P0-T15-1.sh

```sh
cd "$(dirname "$0")/../.." || exit 97
pwsh -NoProfile -NonInteractive -File SCRATCH/929/RC1-P0-T15-1.ps1
```

Output (verbatim):

```
LINES=350
HELPER=1 JOINPATH=1
HELPER_LINES=24
CONVERT=10
SESSION_ID_LITERAL=1
SPEC_CHECKED=25
SPEC_UNCHECKED=2
```

Output Summary: every value matches the plan's expected baseline (LINES=350, HELPER=1 JOINPATH=1, HELPER_LINES=24, CONVERT=10, SESSION_ID_LITERAL=1, SPEC_CHECKED=25, SPEC_UNCHECKED=2). No later expected value requires adjustment.
