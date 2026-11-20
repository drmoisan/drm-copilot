# Runsettings Shape, Both Copies (P6-T24)

Timestamp: 2026-10-02T08-45
Command: git/static-equivalent + CI-evidence deviation DEV-P6-T24 (replaces `Import-PowerShellDataFile ... .CodeCoverage` key listing in a `pwsh` child). Read tool on `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (lines 17-27, the `CodeCoverage` block); `git -C <ROOT> hash-object` on both (P6-T2). Parse proof: CI run A https://github.com/drmoisan/drm-copilot/actions/runs/36983551836 (job https://github.com/drmoisan/drm-copilot/actions/runs/36983551836/job/110763341194) loads the repository copy as the default settings of `Invoke-PoshQCTest` and completed the Test step with coverage enabled (population line `source=config; files=174`, coverage XML produced); the bundled copy has the same git blob hash (b7abb1a7cd9594bf1edfaeb8f71ba08d676914e8), so it holds the same bytes and parses identically.
EXIT_CODE: 0
Output Summary: both copies: HAS_PATH=False KEYS=CoveragePercentTarget,Enabled,OutputFormat,OutputPath
- `CodeCoverage` keys read in each copy: `Enabled = $true` (line 18), `OutputFormat = 'CoverageGutters'` (line 21), `OutputPath = 'artifacts/pester/powershell-coverage.xml'` (line 22), `CoveragePercentTarget = 0` (line 26). No `Path` key. Lines 23-24 hold the two D5 comment lines.
- Acceptance (AC-08): both print `HAS_PATH=False` and `KEYS=CoveragePercentTarget,Enabled,OutputFormat,OutputPath`. Met by the static and CI routes recorded above.
