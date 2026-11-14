# QA Gate: PSScriptAnalyzer (Issue #1010, P5-T2)

Timestamp: 2026-10-30T21-03
Command: sh SCRATCH/issue-1010-run.sh issue-1010-analyze.ps1 -ListFile SCRATCH/issue-1010-declared-ps.txt (Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary: 14 files analyzed; 0 findings in total (pass 2). Pass 1 reported 4 PSReviewUnusedParameter findings in the two new test suites, which were fixed before this pass.

| File | Findings |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 0 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 0 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1` | 0 |
| `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` | 0 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 0 |
