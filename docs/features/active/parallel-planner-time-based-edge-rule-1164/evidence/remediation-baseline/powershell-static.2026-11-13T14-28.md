# PowerShell Static Baseline (remediation cycle 2, P0-T1)

Timestamp: 2026-11-13T14-28
Command: sh SCRATCH/issue-1164-ps-static.sh (pwsh 7: git status --porcelain; per file, Invoke-Formatter check-only comparison of formatter output with the file text and Invoke-ScriptAnalyzer, both with settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; git status --porcelain) over the three P0-T1 files
EXIT_CODE: 0
Output Summary:
- Run on head 06355416f. Format (check-only): 0 of 3 files differ. PSScriptAnalyzer: 0 findings in total.
- Per file (format differs, PSSA findings, logical lines):
  - .claude/lib/blast-radius/BlastRadiusAccess.psm1: 0, 0, 320
  - extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusAccess.psm1: 0, 0, 320
  - tests/scripts/claude-lib/blast-radius/BlastRadiusAccess.Tests.ps1: 0, 0, 192
- git status --porcelain before the format step: empty. After the steps: empty. The format step changed no file.
