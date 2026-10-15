# Pester Pass-After (P3-T4)

Timestamp: 2026-10-09T03-45
Command: mcp__drm-copilot__run_poshqc_test scan_folders ["tests/scripts/claude-lib/blast-radius"]; then poetry run python (ElementTree) over the run's JUnit output artifacts/pester/pester-junit.xml, selecting the testsuites BlastRadiusTokenShape.Tests.ps1 and BlastRadiusExtraction.Path.Tests.ps1
EXIT_CODE: 0
Output Summary: substitute evidence. Within the two P1-T10 files: Passed=118 Failed=0 (TokenShape 57 tests, Path 61 tests); no failed name is printed for these files. The nine P1-T10 failures now pass, together with the fifteen FL-3 predicate cases, the two Python-source parity pins (known names, extension pattern), the re-export case, and the fifteen `still rejects the non-file token` guards. The MCP result for the whole folder was ok:false (exit code 1) because of one failure outside these two files: BlastRadius.HistoricalRuns.Tests.ps1 `reproduces the pinned AFTER edges and tolerated overlaps for backlog-2026-09-26` observed edge 588-622 cost 160 against the pinned 152. That pin is re-derived and updated in Phase 4 (P4-T2 through P4-T4). The parity case for derivation-file-shaped-tokens passes in this run.

## Deviation (PowerShell route denied)

The plan re-runs the P1-T10 `Invoke-Pester` command, which needs the PowerShell tool or inline `pwsh`; inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in evidence/baseline/requirements-source.2026-10-09T02-51.md). The counts above are read from the JUnit file written by the PoshQC MCP test run.

## Deviation (P3-T3 module-scope read)

The plan's P3-T3 text reads the module-scoped values through `& (Get-Command -Name Test-FileShapedComponent).Module { ... }`. The first run failed both parity cases with `The variable '$script:KnownFileName' cannot be retrieved because it has not been set.` (and the same for `$script:FileExtensionPatternText`), because the command resolves through the re-exporting extraction module. The test now reads `(Get-Command -Name Test-FileShapedComponent).ScriptBlock.Module`, which is the defining BlastRadiusTokenShape module instance the function executes in. The comparison logic (ordinal sort, `Should -BeExactly`, count 18) is unchanged.

## Folder-wide failure (outside the two files; expected, handled in Phase 4)

```text
BlastRadius.HistoricalRuns.Tests.ps1 Blast-radius historical runs.reproduces the pinned AFTER edges and tolerated overlaps for backlog-2026-09-26 Expected @('528-588|path_overlap|False|8|2', '588-622|path_overlap|False|152|4'), because backlog-2026-09-26, but got @('528-588|path_overlap|False|8|2', '588-622|path_overlap|False|160|4').
```
