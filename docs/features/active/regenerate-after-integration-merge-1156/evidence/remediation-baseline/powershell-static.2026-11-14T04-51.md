# Remediation Baseline — PowerShell Static (cycle 1, [P0-T1])

Timestamp: 2026-11-14T04-51
Command: sh SCRATCH/issue-1156-static.sh (pwsh 7 from the worktree root: Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 compared ordinally with the file text, no write; Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; Get-Content line count) over .claude/lib/regeneration/Invoke-RegenerationPath.ps1 and tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1
EXIT_CODE: 0
Output Summary:
- .claude/lib/regeneration/Invoke-RegenerationPath.ps1: formatter differences 0, PSScriptAnalyzer findings 0, logical lines 711.
- tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1: formatter differences 0, PSScriptAnalyzer findings 0, logical lines 585.
- Both steps read files only; no file was rewritten.
- Test-suite Phase 0 baselines reused (not re-run): `evidence/baseline/pester-parallel.2026-11-10T04-00.md` (21311 tests, 0 failures, repo-wide line coverage 95.80%) and `evidence/baseline/pytest-parallel.2026-11-10T03-53.md` (16598 passed, 0 failed, line 97.11%, branch 94.37%).
