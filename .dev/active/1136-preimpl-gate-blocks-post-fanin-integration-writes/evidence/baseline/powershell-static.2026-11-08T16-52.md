# PowerShell Static Baseline (Phase 0)

Timestamp: 2026-11-08T16-52
Command: sh SCRATCH/issue-1136-static-p0.sh (pwsh 7: Invoke-Formatter -ScriptDefinition <text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with file text, check-only; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; @(Get-Content -LiteralPath <file>).Count for physical line counts)
EXIT_CODE: 0
Output Summary:
- Formatter drift count: 0 (of 3 files).
- Analyzer findings: `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` 0; `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` 0; `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` 0.
- Physical line counts:
  - `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: 473
  - `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`: 493
  - `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1`: 481
  - `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: 387
  - `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: 447
