# Final QC: PowerShell Static (P3-T1)

Timestamp: 2026-11-19T10-37
Command: sh SCRATCH/issue-1050-static.sh pwsh scripts/ci extensions/drm-copilot/resources/ci-workflows (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat with a no-op -WriteFile seam and a capturing -Logger; Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary: Format drift 0 (zero `Formatted:` log lines) and analyzer findings 0 over 11 files in `scripts/ci` and `extensions/drm-copilot/resources/ci-workflows`.

| Step | Scope | Exit code | Findings |
| --- | --- | --- | --- |
| Format (`Invoke-PoshQCFormat`, non-writing seam) | `scripts/ci`, `extensions/drm-copilot/resources/ci-workflows` (11 files) | 0 | 0 `Formatted:` lines |
| Analyze (`Invoke-ScriptAnalyzer`, repository settings) | same 11 files | 0 | 0 findings |

Analyzer engine exception (not a finding): `Object reference not set to an instance of an object.` on `scripts/ci/CiChangeScope.psm1`, a file this plan does not edit; the same exception class occurs at baseline (on `scripts/ci/CiRequiredGate.psm1`) and moves between untouched files from run to run. Both files this plan adds under these folders (`scripts/ci/Set-CiRequiredChecks.ps1` and its bundle copy) were analyzed without exception and with zero findings.
