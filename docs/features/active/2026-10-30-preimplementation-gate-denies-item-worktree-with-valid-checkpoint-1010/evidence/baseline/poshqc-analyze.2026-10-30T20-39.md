# Baseline PSScriptAnalyzer (Issue #1010, P0-T6)

Timestamp: 2026-10-30T20-39
Command: sh SCRATCH/issue-1010-run.sh issue-1010-analyze.ps1 -ListFile SCRATCH/issue-1010-qa-files.txt (Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary: 8 files analyzed; 0 findings in total.

| File | Findings |
|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 0 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 0 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1` | 0 |
| `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` | 0 |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | 0 |
