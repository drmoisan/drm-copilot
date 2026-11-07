# Stage D PowerShell Format and Lint (loop restart)

Timestamp: 2026-11-07T10-09
Command: sh SCRATCH/issue-1097-d-qc.sh, which runs `Invoke-PoshQCFormat` check-only (a no-op `-WriteFile`) over the folders of every `.ps1`, `.psm1`, and `.psd1` file changed since the merge base of `origin/main` and `HEAD`, a warm-up `Invoke-ScriptAnalyzer` call on `scripts/powershell/PoshQC/PoshQC.psd1`, then `Invoke-ScriptAnalyzer` per file with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`
EXIT_CODE: 0
Output Summary: the loop restarted from [P3-T1] after a pytest failure on the branch was fixed (see stage-d-python-test). 16 changed PowerShell files, including the four guard copies; each has an `Already formatted: ` line and none has a `Formatted: ` line (targets-not-formatted=0; 651 `Already formatted: ` lines and 0 `Formatted: ` lines over the scanned folders). Analyzer findings: 0. Type checking does not apply to PowerShell.
