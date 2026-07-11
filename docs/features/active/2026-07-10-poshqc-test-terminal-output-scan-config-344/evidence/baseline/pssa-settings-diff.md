# Baseline — Workspace vs Bundled `pssa.settings.psd1` Diff (research open item 2)

- Timestamp: 2026-07-10T17-54
- Command: `git diff --no-index --stat scripts/powershell/PoshQC/settings/pssa.settings.psd1 extensions/drm-copilot/resources/powershell/PoshQC/settings/pssa.settings.psd1` and `cmp` byte comparison
- EXIT_CODE: 0 (git diff reported no difference; cmp confirms byte-identical)

## Output Summary

The workspace and bundled `pssa.settings.psd1` copies are **byte-identical**. No resync is required for this file (P3-T3 reduces to a confirmation step).

For context, the two other bundled settings/manifest files that Phase 3 resyncs DO differ at baseline:
- `settings/pester.runsettings.psd1`: 18 insertions, 29 deletions (workspace has the maintained coverage `Path` list; bundled has the undocumented `CodeCoverage.ExcludedPath` block and a shorter coverage list).
- `PoshQC.psd1`: 4 insertions (bundled carries the `RequiredModules` block that the workspace copy omits per the bootstrap contract asserted in `PoshQC.EntryPoints.Tests.ps1`).
