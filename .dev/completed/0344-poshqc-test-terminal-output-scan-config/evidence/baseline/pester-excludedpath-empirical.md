# Baseline — `New-PesterConfiguration -Hashtable` and `CodeCoverage.ExcludedPath` (AC7)

- Timestamp: 2026-07-10T17-53
- Command: `pwsh -NoLogo -NoProfile -Command "& { $h = Import-PowerShellDataFile extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1; New-PesterConfiguration -Hashtable $h }"` (with property introspection)
- EXIT_CODE: 0

## Verbatim Outcome

```
CONSTRUCT_OK
ExcludedPath present in hashtable: True
CodeCoverage props: CoveragePercentTarget, Enabled, ExcludeTests, OutputEncoding, OutputFormat, OutputPath, Path, RecursePaths, SingleHitBreakpoints, UseBreakpoints
Has ExcludedPath property: False
```

## Determination (unambiguous)

`New-PesterConfiguration -Hashtable` **does not error** on the bundled `CodeCoverage.ExcludedPath` key. The unknown key is **silently ignored**: construction succeeds, and the resulting `CodeCoverage` configuration section exposes no `ExcludedPath` property (the documented Pester `CodeCoverage` option set does not include `ExcludedPath`).

Consequence: the undocumented `ExcludedPath` block in the bundled `pester.runsettings.psd1` has no runtime effect on Pester configuration; it is dead configuration. Removing it during the Phase 3 resync (FR2.2) is behavior-neutral for test discovery and coverage construction, consistent with the identical discovered-set result recorded in `junit-diff-task-vs-command.md`.
