# PowerShell Regression-Gate Baseline (Issue #479)

Timestamp: 2026-08-17T00-08

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root: c:\Users\DanMoisan\repos\drm-copilot` (no `scan_folders` argument, so the scan set resolves from `config/poshqc-scan.json` `test.scanFolders`)

EXIT_CODE: 0 (`{"ok": true, "tool": "run_poshqc_test", ...}`)

## Output Summary

Numeric values read from the run's emitted artifacts, since the MCP dispatcher returns a
status envelope rather than the console transcript.

### Pester counts (`artifacts/pester/pester-junit.xml`, root `<testsuites>`)

- tests: **2740**
- failures: **0**
- errors: **0**
- disabled (skipped): **9**
- wall time: 118.507 s

### Line coverage (`artifacts/pester/powershell-coverage.koverage.xml`, root JaCoCo counters)

- LINE: covered **4090**, missed **209** -> line coverage **95.14%**
- INSTRUCTION: covered 5593, missed 301
- METHOD: covered 341, missed 24
- CLASS: covered 52, missed 0

Line coverage of 95.14% is above the uniform 85% line threshold.

Branch coverage: `N/A — Pester does not measure branch coverage`.

## Role In This Feature

PowerShell is touched by no defect (spec.md "Explicitly excluded language"). This suite runs
as a regression gate only, at baseline here and at final QC in P7-T11. The Layer-1 cohort
barrier hook suite (`enforce-parallel-cohort-barrier`) is inside this run and is expected to
remain green and unmodified.
