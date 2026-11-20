# Post-merge PoshQC analyzer baseline — issue #598

Timestamp: 2026-08-29T23-10
Task: [P0-T15]

Command:
1. `mcp__drm-copilot__run_poshqc_analyze` against the workspace root
   `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7`
2. `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path"`

Every recorded literal and exit code below comes from command 2. Command 1 returned
`{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7","summary":"Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7'."}`
and carries no finding line and no exit code (`extensions/drm-copilot/src/mcp-tools.ts:90-113`), so
it is not the observation source.

EXIT_CODE: 0

Output Summary:

Command 2 produced exactly one output line, quoted verbatim:

```
PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aee68cdb110fb5da7
```

That line begins `PSScriptAnalyzer passed: no findings under`, which
`scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:185` prints only when the analyzer found nothing.
No `PSScriptAnalyzer reported` throw message was emitted and no finding table was printed, so there
are no verbatim findings to record.

PostMergeAnalyzerClean: true

## Acceptance evaluation

- The artifact records the boolean field `PostMergeAnalyzerClean:` with the value `true`.
- Because that value is `true`, the verbatim-findings requirement does not apply.

Acceptance holds. The merge introduced no analyzer findings, so the report-to-caller branch does not
fire and every remaining batch gate can meet its clean-line requirement.
