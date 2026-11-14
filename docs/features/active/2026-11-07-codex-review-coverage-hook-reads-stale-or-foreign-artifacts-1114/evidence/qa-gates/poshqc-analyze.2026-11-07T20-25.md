# PoshQC Analyze (direct PSScriptAnalyzer) - remediation cycle 1, issue #1114

Timestamp: 2026-11-07T20-25
Command: sh SCRATCH/issue-1114-static.sh cycle1a (PowerShell 7: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 over every .ps1 and .psm1 file under .codex/hooks, tests/scripts/codex-hooks, and extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks)
EXIT_CODE: 0
Output Summary:
- Files scanned: 201. Findings: 0.
- Zero findings in `.codex/hooks/feature-review-coverage-target.ps1` and `tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1`; no finding elsewhere in the scanned folders, so nothing is absent from the pre-cycle analyze artifact (evidence/qa-gates/poshqc-analyze.2026-11-07T19-40.md).
