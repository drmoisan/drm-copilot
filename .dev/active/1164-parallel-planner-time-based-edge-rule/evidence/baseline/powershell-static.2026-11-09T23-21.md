# PowerShell Static Baseline (Phase 0, P0-T1)

Timestamp: 2026-11-09T23-21
Command: sh SCRATCH/issue-1164-ps-static-p0.sh (pwsh -File SCRATCH/issue-1164-ps-static.ps1: Invoke-Formatter check-only comparison and Invoke-ScriptAnalyzer, both with scripts/powershell/PoshQC/settings/pssa.settings.psd1)
EXIT_CODE: 0
Output Summary:
- Policy files read in policy-compliance-order before capture: CLAUDE.md, .claude/rules/general-code-change.md, .claude/rules/general-unit-test.md, .claude/rules/powershell.md, .claude/rules/python.md, .claude/rules/typescript.md.
- Format step (check-only; no file written): 0 findings in total.
- PSScriptAnalyzer step: 0 findings in total.
- .claude/lib/blast-radius/BlastRadiusScheduling.psm1: format 0, PSSA 0
- .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1: format 0, PSSA 0
- .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1: format 0, PSSA 0
- .claude/lib/parallel-drift/ParallelDrift.psm1: format 0, PSSA 0
