# Line Counts Baseline (P0-T17)

Timestamp: 2026-10-16T00-24

Command: sh SCRATCH/issue-929/P0-T17-1.sh
Script: `foreach ($f in @('.claude/hooks/validate-task-researcher-output.ps1','extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1','tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1','tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1','tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1','tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1','tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1')) { if (Test-Path -LiteralPath $f) { '{0} | LINES={1}' -f $f, (Get-Content -LiteralPath $f).Count } else { '{0} | ABSENT' -f $f } }`
EXIT_CODE: 0
Output:
```
.claude/hooks/validate-task-researcher-output.ps1 | LINES=290
extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1 | LINES=290
tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | LINES=223
tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | LINES=201
tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | LINES=418
tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | LINES=320
tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | LINES=114
tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | LINES=140
tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | LINES=358
tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1 | ABSENT
tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1 | ABSENT
```

Output Summary: all eleven values match the expected 290, 290, 223, 201, 418, 320, 114, 140, 358, ABSENT, ABSENT. No later expected count needs adjustment.
