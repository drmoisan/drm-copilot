# Runsettings Coverage-Path Check ([P0-T20])

Timestamp: 2026-10-09T22-25
Command: Import-PowerShellDataFile -LiteralPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1; Import-PowerShellDataFile -LiteralPath extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1; Get-Content -Raw -LiteralPath config/poshqc-coverage.json (fresh process, <SCRATCHPAD>/p0t20.ps1)
EXIT_CODE: 0
Output Summary: neither runsettings copy carries a CodeCoverage.Path key (CODECOVERAGE_PATH: absent); the coverage roots are .claude/hooks, .claude/lib, .codex/hooks, .codex/scripts, scripts.

CODECOVERAGE_PATH: absent
Coverage roots: .claude/hooks, .claude/lib, .codex/hooks, .codex/scripts, scripts

Output:

```text
COPY: scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | CodeCoverage keys: CoveragePercentTarget, Enabled, OutputFormat, OutputPath | Path: absent
COPY: extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 | CodeCoverage keys: CoveragePercentTarget, Enabled, OutputFormat, OutputPath | Path: absent
CODECOVERAGE_PATH: absent
## config/poshqc-coverage.json
{
  "version": 1,
  "roots": [
    ".claude/hooks",
    ".claude/lib",
    ".codex/hooks",
    ".codex/scripts",
    "scripts"
  ]
}
```
