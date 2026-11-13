# PowerShell Static Baseline (issue #1163)

Timestamp: 2026-11-10T03-19
Command: sh SCRATCH/issue-1163-static.sh baseline (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -GetFileList <18 production files> -WriteFile <recording seam, no write>; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary: Formatter visited 18 files, 0 would be rewritten (finding count 0, exit 0). Analyzer: 0 findings in each of the 18 production files (total 0, exit 0).

## Step 1 — Formatter (non-writing)

- Command: `Invoke-PoshQCFormat` with a `WriteFile` seam that records each file the formatter would rewrite and writes nothing; `GetFileList` returns the 18 production files below.
- EXIT_CODE: 0
- Files visited: 18
- Finding count (files that would be rewritten): 0

## Step 2 — Analyzer

- Command: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`
- EXIT_CODE: 0
- Total findings: 0

| Findings | File |
|---|---|
| 0 | `.claude/hooks/subagentstop-target-worktree.ps1` |
| 0 | `.claude/hooks/validate-task-researcher-output.ps1` |
| 0 | `.claude/hooks/validate-prd-feature-output.ps1` |
| 0 | `.claude/hooks/validate-required-artifact-output.ps1` |
| 0 | `.claude/hooks/validate-planner-output.ps1` |
| 0 | `.claude/hooks/validate-executor-output.ps1` |
| 0 | `.claude/hooks/validate-human-exception-runbook-output.ps1` |
| 0 | `.claude/hooks/enforce-completion-consistency.ps1` |
| 0 | `.codex/hooks/enforce-completion-consistency.ps1` |
| 0 | `.claude/hooks/enforce-file-size-limit.ps1` |
| 0 | `.codex/hooks/enforce-file-size-limit.ps1` |
| 0 | `.claude/hooks/validate-docs-role-output.ps1` |
| 0 | `.claude/hooks/enforce-docs-complete-gate.ps1` |
| 0 | `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` |
| 0 | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` |
| 0 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` |
| 0 | `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` |
| 0 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` |

Type checking does not apply to PowerShell.
