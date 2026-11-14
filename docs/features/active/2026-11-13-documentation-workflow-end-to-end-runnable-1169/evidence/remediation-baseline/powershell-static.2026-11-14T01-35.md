# PowerShell Static Remediation Baseline (Cycle 1, P0-T1)

Timestamp: 2026-11-14T01-35
Command: sh SCRATCH/issue-1169-tc.sh R1-P0-T1 "<14 files>" "" (pwsh 7: per file, Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared in memory with the file text, so no file is rewritten; then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; PSScriptAnalyzer 1.25.0; no Pester run)
EXIT_CODE: 0
Output Summary:
- Mode: check-only (formatter output compared in memory; no file rewritten).
- Totals: FORMAT_FINDINGS=0 LINT_FINDINGS=0 FILES=14.
- Per file (drift count / finding count):
  - .claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1: 0 / 0
  - .codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1: 0 / 0
  - extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1: 0 / 0
  - extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-docs.ps1: 0 / 0
  - .claude/hooks/hook-docs-estate-context.ps1: 0 / 0
  - .codex/hooks/hook-docs-estate-context.ps1: 0 / 0
  - extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-estate-context.ps1: 0 / 0
  - extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-estate-context.ps1: 0 / 0
  - .claude/lib/docs/DocsCompleteGate.psm1: 0 / 0
  - extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsCompleteGate.psm1: 0 / 0
  - tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.DocsEstate.Tests.ps1: 0 / 0
  - tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-docs.Tests.ps1: 0 / 0
  - tests/scripts/claude-hooks/enforce-model-routing-receipt.DocsEstate.Tests.ps1: 0 / 0
  - tests/scripts/claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1: 0 / 0
- `git status --porcelain` before and after the run: identical (0 lines each).
- Mirror hashes at baseline: the four docs-leg copies share one SHA-256, the four hook-docs-estate-context copies share one SHA-256, and both DocsCompleteGate.psm1 copies share one SHA-256.
