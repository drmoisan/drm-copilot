# Remediation Baseline — Formatting

Timestamp: 2026-11-03T19-31
Command: sh SCRATCH/issue-1026-format-pssa.sh (PowerShell 7: Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, compared ordinally with the file text; no write)
EXIT_CODE: 0

| File | Result |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | unchanged |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | unchanged |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | unchanged |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` | unchanged |
| `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` | unchanged |
| `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` | unchanged |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1` | unchanged |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1` | unchanged |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1` | unchanged |
| `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` | unchanged |
| `tests/scripts/claude-hooks/cleanup-merged-worktrees.SkillText.Tests.ps1` | unchanged |

Output Summary: 11 of 11 files unchanged under the PoshQC formatter settings.
