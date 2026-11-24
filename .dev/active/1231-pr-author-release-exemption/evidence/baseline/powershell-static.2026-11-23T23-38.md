# PowerShell Static Baseline (Phase 0, issue #1231)

Timestamp: 2026-11-23T23-38
Command: sh SCRATCH/issue-1231-p0-static.sh (runs pwsh -NoProfile -File SCRATCH/issue-1231-static.ps1: Invoke-Formatter check mode with scripts/powershell/PoshQC/settings/pssa.settings.psd1 and no write, Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, and @(Get-Content -LiteralPath <path>).Count; git status --porcelain captured before and after)
EXIT_CODE: 0
Output Summary:
- Formatter changed-file count: 0 (check mode, the comparison of Invoke-Formatter output with the file text; no file written).
- Analyzer findings: enforce-pr-author-skill.ps1 0; enforce-pr-author-skill.cleanup.ps1 0; enforce-model-routing-receipt.ps1 0; enforce-orchestration-preimplementation-gate.ps1 0.
- Sizes (@(Get-Content -LiteralPath <path>).Count):
  - .claude/hooks/enforce-pr-author-skill.ps1: 359
  - .claude/hooks/enforce-pr-author-skill.cleanup.ps1: 246
  - .claude/hooks/enforce-model-routing-receipt.ps1: 425
  - .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: 499
  - .claude/hooks/enforce-pr-author-skill-helpers.ps1: 499
  - .claude/hooks/hook-release-allowance-context.ps1: 495
- git status --porcelain before and after: unchanged (PORCELAIN_UNCHANGED=yes).

Note: the PoshQC MCP format tool writes files and returns no output, so the format check runs the same Invoke-Formatter call as Invoke-PoshQCFormat in check mode.
