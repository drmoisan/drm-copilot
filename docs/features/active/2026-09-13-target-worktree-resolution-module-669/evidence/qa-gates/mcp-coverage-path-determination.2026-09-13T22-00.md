# MCP Runner CodeCoverage.Path Determination

Timestamp: 2026-09-17T08:40:30-04:00
Command: [xml] parse of evidence/other/final-powershell-coverage.mcp.2026-09-13T22-00.xml using the [P0-T8] names: report/package where @name ends with 'worktree-resolution', then sourcefile where @name equals the bare module file name
EXIT_CODE: 0
Output Summary: INSTALLED-EXTENSION-SETTINGS — row count for WorktreeResolution.psm1 = 0; row count for WorktreeTargetResolution.psm1 = 0; packages whose name ends with worktree-resolution = 0.

## Observations

- Packages in the MCP coverage file: 14, the same count as the self-hosted baseline; none ends with `worktree-resolution`.
- The report-level LINE counter is identical to the [P0-T6] baseline (`covered=8914 missed=422`), and the file
  size is identical (784030 bytes), although the run executed the 106 new tests (tests 4547 -> 4653). The
  coverage denominator therefore did not include the two newly registered modules.
- `[P3-T1]`, `[P3-T3]`, and `[P3-T8]` establish that both in-repo runsettings copies carry the two entries.
  The missing rows are consistent with the MCP runner reading run settings from the installed VS Code
  extension payload rather than from either in-repo copy. This is recorded as a tooling-path symptom, not a
  registration defect, and closes unverified item 1 (`research:1155`).
- Per-file coverage for the two modules is measured by the self-hosted invocation in [P4-T7].
