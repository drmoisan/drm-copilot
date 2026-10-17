# Run-Settings Pair Equality (P0-T9)

Timestamp: 2026-10-01T21-07
Task: P0-T9
Route: sh-wrapped pwsh -NoProfile -Command (pwsh 7.6.6)

Command: (Get-FileHash -LiteralPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1).Hash -eq (Get-FileHash -LiteralPath extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1).Hash
EXIT_CODE: 0
Output: `True`

RunsettingsPairEqual: True

## Output Summary:

- The repository and bundle run-settings files are byte-identical.
- RunsettingsPairEqual: True selects the corresponding P5-T9 branch.
