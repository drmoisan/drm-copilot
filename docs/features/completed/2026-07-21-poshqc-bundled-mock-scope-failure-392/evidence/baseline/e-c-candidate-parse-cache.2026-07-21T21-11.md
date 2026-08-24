Timestamp: 2026-07-21T21-11

Command: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC'"
EXIT_CODE: 0

# Experiment E-C — Candidate A (parse-once process-lifetime cache in PoshQC.psm1)

## Edit applied (temporary, working tree)

`scripts/powershell/PoshQC/PoshQC.psm1` bootstrap loop (lines 82-106 region) restructured so the
parsed ScriptBlock for each sub-module is cached in a process-lifetime AppDomain data slot
(`[System.AppDomain]::CurrentDomain.GetData/SetData`, key `PoshQC.ParsedSubModuleScriptBlocks`),
keyed by absolute sub-module path. `[Parser]::ParseFile(...)` and `.GetScriptBlock()` now run at
most once per sub-module per PowerShell process; dot-sourcing (`. $cachedScriptBlock`) still runs on
every `Import-Module -Force`. The parse-error-throws-fast behavior is preserved on the first
(cache-miss) parse. A `$global:` variable was deliberately NOT used because `PSAvoidGlobalVars` is
enabled in `pssa.settings.psd1`; the AppDomain slot provides the required process-lifetime
persistence that `-Force` (which discards module script scope) does not.

## Output Summary

- Test results: Tests Passed: 107, Failed: 0, Skipped: 7. 0 test failures — function binding into
  each `-Force`-reimported module session state is intact (the cached ScriptBlock dot-sources and
  rebinds correctly; module-collision guards continue to pass).
- Per-file LINE coverage (parsed from artifacts/pester/powershell-coverage.xml):
  - PoshQC.Testing.psm1: covered=195, missed=0, total=195 => 100.00% (0 uncovered lines).
  - PoshQC.ScanConfig.psm1: covered=44, missed=2, total=46 => 95.65% (UNCHANGED vs. P0-T5 44/46 —
    no regression; issue #344 breakpoint-binding requirement preserved).
- Pester INSTRUCTION-basis summary: `Covered 9.65%` (narrowed denominator; rose from the P0-T6
  pre-fix 7.35%).

## Coverage restoration vs. P0-T5 / P0-T6 pre-fix baseline

Every line in the P0-T5/P0-T6 pre-fix uncovered set (64 lines, including the newly-regressed
75-128 module-bootstrap cluster) that is coverable in this narrowed PoshQC-folder run is now
covered. PoshQC.Testing.psm1 goes from 131/195 (67.18%, 64 uncovered) to 195/195 (100%, 0
uncovered) with the parse-once cache. This confirms the re-parse/re-compile churn was the cause of
the lost coverage credit, and caching the parsed ScriptBlock process-wide eliminates it.

CANDIDATE VERDICT: PASS

## Disposition

The edit is LEFT IN THE WORKING TREE (it seeds Phase 1). No revert performed.
