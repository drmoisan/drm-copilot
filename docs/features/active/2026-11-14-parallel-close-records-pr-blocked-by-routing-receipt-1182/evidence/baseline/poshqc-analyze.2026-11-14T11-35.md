# Phase 0 Baseline: PSScriptAnalyzer

Timestamp: 2026-11-14T11-35
Command: sh SCRATCH/issue-1182-static.sh base (pwsh -File SCRATCH/issue-1182-static.ps1: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 for each file of Get-PoshQCFileList, PSScriptAnalyzer 1.25.0, one retry per file)
EXIT_CODE: 1
Output Summary:
- Direct run, not an MCP summary. FILES_SCANNED=1701.
- ANALYZER_FINDINGS=0 (finding count 0).
- ANALYZER_ERRORS=1, ANALYZER_RETRIES=2: Invoke-ScriptAnalyzer threw on both attempts for extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 (an analyzer exception, not a rule finding). This file is not in the scope of issue #1182; the condition is recorded as the Phase 0 baseline and is compared with the final static loop.
- The launcher exits 1 because of the analyzer error, not because of a finding.
