Timestamp: 2026-08-31T11-33
Command: `mcp__drm_copilot__run_poshqc_test({"workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-31T07-29","scan_folders":["tests/scripts/codex-hooks"]})`
EXIT_CODE: 32
Output Summary:
- Baseline result: 627 tests, 32 failures, 0 errors; the failures are process-launch environment errors caused by a concatenated PowerShell executable path.
- Repository PowerShell line coverage: 18.8011% (1471/7824 executable lines).
- Changed-script baseline for `.codex/hooks/enforce-epic-planning-only.ps1`: 93.3333% line coverage (126/135 executable lines).
- Pester does not measure branch coverage; branch coverage is explicitly exempt under repository policy.
- The run used `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, including its configured `CodeCoverage.Path` denominator.
