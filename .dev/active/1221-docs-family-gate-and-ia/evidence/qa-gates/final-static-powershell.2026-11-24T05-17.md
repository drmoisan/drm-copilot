# Final QC - PowerShell Static (P3-T1)

Timestamp: 2026-11-24T05-17
Command: sh SCRATCH/issue-1221-static-ps.sh check .claude/lib/docs tests/scripts/claude-lib/docs extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1; sh SCRATCH/issue-1221-pssa-batch.sh <same scope>
EXIT_CODE: 0
Output Summary: Head 684e3feca (after the merge of the integration tip with #1219). Format: 303 files scanned, 0 needing format; the formatter ran in check mode and changed no file. Analyzer: 303 files, 0 findings, 0 analyzer errors. Type check: not applicable to PowerShell.

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format | `Invoke-PoshQCFormat` in check mode (writer records, never writes) over the scope (SCRATCH/issue-1221-static-ps.ps1) | 0 | 0 files needing format (FILES_SCANNED=303) |
| Lint | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file in one pwsh importing only PSScriptAnalyzer (SCRATCH/issue-1221-pssa-batch.ps1) | 0 | 0 findings, 0 analyzer errors |
| Type check | not applicable (PowerShell) | N/A | N/A |

Scope: the plan's `.claude/lib/docs/` and `tests/scripts/claude-lib/docs/`, plus the bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` and the edited `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1`. The analyzer route is recorded in `decisions.2026-11-24T05-07.md` (decision 3).
