# Remediation Baseline — PSScriptAnalyzer

Timestamp: 2026-11-03T19-31
Command: sh SCRATCH/issue-1026-format-pssa.sh (PowerShell 7: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0

| File | Findings |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | 0 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | 0 |
| `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | 0 |
| `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` | 0 |

Output Summary: 0 findings in each of the 11 files.
