# Final Line Counts (P9-T12)

Timestamp: 2026-10-16T05-15

Command: sh SCRATCH/929/P9-T12-1.sh
Script: the line-count body of P0-T17 verbatim (no P8-T10 or P8-T17 `ADDITIONAL:` path exists to append): `foreach ($f in @('.claude/hooks/validate-task-researcher-output.ps1','extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1','tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1')) { if (Test-Path -LiteralPath $f) { '{0} | LINES={1}' -f $f, (Get-Content -LiteralPath $f).Count } else { '{0} | ABSENT' -f $f } }`
EXIT_CODE: 0
Output:
```
.claude/hooks/validate-task-researcher-output.ps1 | LINES=289
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1 | LINES=289
tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | LINES=230
tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | LINES=193
tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | LINES=410
tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | LINES=350
tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | LINES=106
tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | LINES=132
tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | LINES=420
tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1 | LINES=67
tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1 | LINES=35
```

Output Summary: Every touched PowerShell file prints a `LINES=` value at or below 500 (maximum 420) and none prints `ABSENT` (AC-24).
