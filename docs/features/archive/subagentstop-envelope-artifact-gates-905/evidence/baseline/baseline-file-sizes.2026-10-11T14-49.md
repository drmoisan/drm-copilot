# Baseline file sizes ([P0-T28], issue #905)

Timestamp: 2026-10-11T14-49
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-size.ps1 WBASE (R-SIZE: (Get-Content -LiteralPath <path>).Count per W-BASE file)
EXIT_CODE: 0
Output Summary: 10 LINES lines. Hooks 264, 142, 97, 294; suites 211, 127, 54, 135, 46, 423. All at most 500.

```text
LINES: .claude/hooks/validate-discovery-artifact-gate.ps1 | 264
LINES: .claude/hooks/validate-pr-author-output.ps1 | 142
LINES: .claude/hooks/validate-prd-feature-output.ps1 | 97
LINES: .claude/hooks/validate-task-researcher-output.ps1 | 294
LINES: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | 211
LINES: tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | 127
LINES: tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1 | 54
LINES: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | 135
LINES: tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1 | 46
LINES: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | 423
```
