# Phase 0 static baseline: PowerShell (P0-T2)

Timestamp: 2026-11-08T13-54
Command: sh SCRATCH/issue-1130-static.sh (pwsh 7: Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared with the file text, no write; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary:
- Files whose formatter output differs: none (0 of 14).
- Analyzer findings per file (all 0):
  - .claude/hooks/enforce-epic-merge-gate.ps1: 0 (497 lines)
  - .codex/hooks/enforce-epic-merge-gate.ps1: 0 (417 lines)
  - tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1: 0
  - tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1: 0
  - tests/scripts/claude-hooks/enforce-epic-merge-gate.EpicModeStrict.Tests.ps1: 0
  - tests/scripts/claude-hooks/enforce-epic-merge-gate.GreenCiRegression.Tests.ps1: 0
  - tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1: 0
  - tests/scripts/claude-hooks/EpicMergeGateReview.Cases.Helpers.ps1: 0
  - tests/scripts/claude-hooks/enforce-epic-merge-gate.ReviewGuard.Tests.ps1: 0
  - tests/scripts/claude-hooks/enforce-epic-merge-gate.ReviewPaths.Tests.ps1: 0
  - tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1: 0
  - tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1: 0
  - tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1: 0
  - tests/scripts/codex-hooks/enforce-epic-merge-gate-review.Tests.ps1: 0
- Totals: FORMATTER_DIFF_FILES=0 PSSA_TOTAL=0.
