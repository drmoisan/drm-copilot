# PowerShell Static Baseline (remediation cycle 1, P0-T1)

Timestamp: 2026-11-11T05-47
Command: sh SCRATCH/issue-1164-ps-static.sh baseline (pwsh 7: git status --porcelain; Invoke-Formatter check-only comparison of formatter output with file text, settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; Invoke-ScriptAnalyzer with the same settings; git status --porcelain) over the five P0-T1 files
EXIT_CODE: 0
Output Summary:
- Format (check-only): 0 of 5 files differ. PSScriptAnalyzer: 0 findings in total.
- Per file (format differs, PSSA findings, logical lines):
  - .claude/lib/blast-radius/BlastRadiusAccess.psm1: 0, 0, 281
  - extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusAccess.psm1: 0, 0, 281
  - .claude/lib/parallel-admission/ParallelAdmissionPrecedenceGate.psm1: 0, 0, 160
  - tests/scripts/claude-lib/blast-radius/BlastRadiusAccess.Tests.ps1: 0, 0, 176
  - tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedenceGate.Tests.ps1: 0, 0, 117
- git status --porcelain before the format step: 8 lines, all untracked review-cycle and preflight files under the feature folder (code-review, feature-audit, policy-audit, remediation-inputs 2026-11-11T04-32; remediation-inputs and remediation-plan 2026-11-11T04-47; preflight-fixes 2026-11-11T05-22 and 2026-11-11T05-39). After the steps: the same 8 lines, identical, so the format step changed no file.
