# Final QC: PowerShell Static (P3-T1, loop pass 2)

Timestamp: 2026-11-19T11-02
Command: sh SCRATCH/issue-1050-static.sh pwsh scripts/ci extensions/drm-copilot/resources/ci-workflows (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat with a no-op -WriteFile seam and a capturing -Logger; Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file)
EXIT_CODE: 0
Output Summary: Format drift 0 (zero `Formatted:` log lines) and analyzer findings 0 over 11 files in `scripts/ci` and `extensions/drm-copilot/resources/ci-workflows`, on the tree after final-loop remediation 1.

| Step | Scope | Exit code | Findings |
| --- | --- | --- | --- |
| Format (`Invoke-PoshQCFormat`, non-writing seam) | `scripts/ci`, `extensions/drm-copilot/resources/ci-workflows` (11 files) | 0 | 0 `Formatted:` lines |
| Analyze (`Invoke-ScriptAnalyzer`, repository settings) | same 11 files | 0 | 0 findings |

Analyzer engine exception (not a finding): `Object reference not set to an instance of an object.` on the untouched `scripts/ci/CiChangeScope.psm1`, the same pre-existing exception class recorded at baseline. `scripts/ci/Set-CiRequiredChecks.ps1` and its bundle copy were analyzed without exception and with zero findings; the edited test file `tests/scripts/ci/Set-CiRequiredChecks.Tests.ps1` was analyzed with zero findings in remediation 1.
