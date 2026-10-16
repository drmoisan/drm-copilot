# Final Runsettings Diff (issue #953, P6-T11, post-split restart pass)

Timestamp: 2026-10-16T09-59
Command: git diff --numstat 5bc97774b8322e57abb94dfac3cd0a000a136c5b -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1; git status --porcelain -- scripts/powershell/PoshQC/settings extensions/drm-copilot/resources/powershell/PoshQC/settings
EXIT_CODE: 0
Output Summary: Numstat rows (BASE_SHA against the working tree): `3	0	extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` and `3	0	scripts/powershell/PoshQC/settings/pester.runsettings.psd1`. Each file has 3 lines added and 0 deleted, so `Enabled`, `OutputFormat`, `OutputPath`, and `CoveragePercentTarget` are unchanged from the base commit. Porcelain output is empty. P6-T3 (final-poshqc-test-coverage.2026-10-16T09-55.md) recorded RS01-RUNSETTINGS-PROFILER-MODE and RS04-BUNDLED-RUNSETTINGS-PROFILER-MODE as PASS (AC-01).
