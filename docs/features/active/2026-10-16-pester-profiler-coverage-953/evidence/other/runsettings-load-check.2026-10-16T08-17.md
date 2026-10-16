# Runsettings Load Check (issue #953, P2-T3)

Timestamp: 2026-10-16T08-17
Command: pwsh -NoProfile -Command "foreach (`$p in 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1','extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1') { `$c = (Import-PowerShellDataFile -Path `$p).CodeCoverage; '{0} UseBreakpoints={1} Enabled={2} OutputFormat={3} OutputPath={4} CoveragePercentTarget={5}' -f `$p, `$c.UseBreakpoints, `$c.Enabled, `$c.OutputFormat, `$c.OutputPath, `$c.CoveragePercentTarget }" (Tool route: SCRATCH/issue-953-p2-t3.sh, run with sh)
EXIT_CODE: 0
Output Summary: Both files load and report profiler mode with the coverage keys unchanged:
scripts/powershell/PoshQC/settings/pester.runsettings.psd1 UseBreakpoints=False Enabled=True OutputFormat=CoverageGutters OutputPath=artifacts/pester/powershell-coverage.xml CoveragePercentTarget=0
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1 UseBreakpoints=False Enabled=True OutputFormat=CoverageGutters OutputPath=artifacts/pester/powershell-coverage.xml CoveragePercentTarget=0
