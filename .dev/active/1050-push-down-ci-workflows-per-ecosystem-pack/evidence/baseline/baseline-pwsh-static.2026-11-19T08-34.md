# Baseline PowerShell Static (P0-T3)

Timestamp: 2026-11-19T08-34
Command: sh SCRATCH/issue-1050-static.sh pwsh scripts/ci (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -ScanFolders scripts/ci with a no-op -WriteFile seam and a capturing -Logger; Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 per file under scripts/ci)
EXIT_CODE: 0
Output Summary: Format drift 0 over 9 files; analyzer findings 0 over 9 files, with one pre-existing analyzer engine exception.

| Step | Scope | Exit code | Findings |
| --- | --- | --- | --- |
| Format (`Invoke-PoshQCFormat`, non-writing seam) | `scripts/ci` (9 files) | 0 | 0 `Formatted:` log lines |
| Analyze (`Invoke-ScriptAnalyzer`, repo settings) | `scripts/ci` (9 files) | 0 | 0 findings |

Pre-existing condition: `Invoke-ScriptAnalyzer` raises `Object reference not set to an instance of an object.` on `scripts/ci/CiRequiredGate.psm1` (an analyzer engine exception, not a rule finding). The first attempt, a single recursive `Invoke-ScriptAnalyzer -Path scripts/ci -Recurse` call, raised the same exception and its process did not exit; it was stopped (own PID) and replaced by the per-file loop recorded here. This file is not edited by this plan; the same per-file route is used at the final gate so the comparison is like for like.
