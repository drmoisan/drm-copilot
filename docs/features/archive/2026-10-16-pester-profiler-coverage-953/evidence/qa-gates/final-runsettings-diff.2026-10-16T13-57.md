# Final QC: Runsettings Diff (P8-T16 / P6-T11, sharding path)

Timestamp: 2026-10-16T13-57
Command: git diff --numstat 5bc97774b8322e57abb94dfac3cd0a000a136c5b -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1; git status --porcelain -- scripts/powershell/PoshQC/settings extensions/drm-copilot/resources/powershell/PoshQC/settings
EXIT_CODE: 0

Output Summary:
- numstat rows: `3 0 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` and `3 0 scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (3 added, 0 deleted each; `Enabled`, `OutputFormat`, `OutputPath`, and `CoveragePercentTarget` unchanged from the base commit).
- Porcelain listing: empty.
- The latest final-poshqc-test-coverage evidence (2026-10-16T13-57) records RS01-RUNSETTINGS-PROFILER-MODE and RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE as PASS.
- Result: PASS (AC-01).
