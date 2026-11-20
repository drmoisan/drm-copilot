# PowerShell Static Final QC, loop restart (issue #1163, P8-T1)

Timestamp: 2026-11-11T06-17
Command: sh SCRATCH/issue-1163-static-final.sh pass5 (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <item worktree> -GetFileList <55 changed .ps1/.psm1 files from git diff --name-only against the merge base, bundle mirrors excluded>; git status --porcelain before and after; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary: Loop restarted from step 1 after the first P8-T2 gate run failed (8 failures) and fixes were committed. Final pass (pass 5): formatter exit 0, 0 files rewritten (git status --porcelain empty before and after); analyzer 0 findings across all 55 files (the 54 of the earlier pass plus tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1). Type checking does not apply to PowerShell. This artifact supersedes powershell-static-final.2026-11-11T05-33.md for the final loop pass.

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format | Invoke-PoshQCFormat (writing) over the 55 files | 0 | 0 files rewritten |
| Porcelain observation | git status --porcelain before and after the formatter | 0 | 0 entries before, 0 after |
| Lint | Invoke-ScriptAnalyzer with pssa.settings.psd1, per file | 0 | 0 |
| Type check | not applicable to PowerShell | n/a | n/a |

## Analyzer findings per file

| Findings | File |
|---|---|
| 0 | `.claude/hooks/enforce-completion-consistency.ps1` |
| 0 | `.claude/hooks/enforce-docs-complete-gate.ps1` |
| 0 | `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` |
| 0 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` |
| 0 | `.claude/hooks/enforce-file-size-limit.ps1` |
| 0 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` |
| 0 | `.claude/hooks/subagentstop-target-worktree.ps1` |
| 0 | `.claude/hooks/validate-docs-role-output.ps1` |
| 0 | `.claude/hooks/validate-executor-output.ps1` |
| 0 | `.claude/hooks/validate-human-exception-runbook-output.ps1` |
| 0 | `.claude/hooks/validate-planner-output.ps1` |
| 0 | `.claude/hooks/validate-prd-feature-output.ps1` |
| 0 | `.claude/hooks/validate-required-artifact-output.ps1` |
| 0 | `.claude/hooks/validate-task-researcher-output.ps1` |
| 0 | `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` |
| 0 | `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` |
| 0 | `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` |
| 0 | `.codex/hooks/agent-target-worktree.ps1` |
| 0 | `.codex/hooks/enforce-completion-consistency.ps1` |
| 0 | `.codex/hooks/enforce-file-size-limit.ps1` |
| 0 | `tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/enforce-completion-consistency.EditTarget.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/enforce-completion-consistency.FailClosed.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/enforce-completion-consistency.TargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/enforce-file-size-limit.TargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/enforce-file-size-limit.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/subagentstop-target-worktree.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/validate-docs-role-output.TargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/validate-docs-role-output.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/validate-executor-output.TargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/validate-human-exception-runbook-output.TargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/validate-orchestrator-output-target.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/validate-planner-output.TargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/validate-prd-feature-output.TargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/validate-required-artifact-output.TargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-hooks/validate-task-researcher-output.TargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1` |
| 0 | `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Tests.ps1` |
| 0 | `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` |
| 0 | `tests/scripts/claude-lib/worktree-resolution/WorktreeRunRecordPath.Tests.ps1` |
| 0 | `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1` |
| 0 | `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.RelativeRecord.Tests.ps1` |
| 0 | `tests/scripts/codex-hooks/agent-target-worktree.Tests.ps1` |
| 0 | `tests/scripts/codex-hooks/enforce-completion-consistency-default-reader.Tests.ps1` |
| 0 | `tests/scripts/codex-hooks/enforce-completion-consistency-edit-semantics.Tests.ps1` |
| 0 | `tests/scripts/codex-hooks/enforce-completion-consistency-edit-target.Tests.ps1` |
| 0 | `tests/scripts/codex-hooks/enforce-completion-consistency-fail-closed.Tests.ps1` |
| 0 | `tests/scripts/codex-hooks/enforce-completion-consistency-target-worktree.Tests.ps1` |
| 0 | `tests/scripts/codex-hooks/enforce-file-size-limit-target-worktree.Tests.ps1` |
| 0 | `tests/scripts/codex-hooks/enforce-file-size-limit.Tests.ps1` |
