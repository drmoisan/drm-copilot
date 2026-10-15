# Baseline Full-Population PoshQC Run (P0-T13)

Timestamp: 2026-10-11T23-52
Command: CR-POSHQC-FULL through the scratchpad route (Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1), then CR-JUNIT (scratchpad route)
EXIT_CODE: 0
Output Summary: full run exit 0; Tests Passed: 9867, Failed: 0, Skipped: 10; Covered 88.67% (25,950 analyzed Commands in 198 Files); JUNIT: tests=9877 | failures=0 | errors=0; EXIT_CODE_COMPUTED: 0.

PRE-EXISTING: NONE (no JUNIT-FAILED: line was printed)

## CR-POSHQC-FULL summary lines (verbatim, ANSI color codes removed)

```
Tests Passed: 9867, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 88.67% / 0%. 25,950 analyzed Commands in 198 Files.
PROCESS_EXIT: 0
```

## CR-JUNIT output

```
JUNIT: tests=9877 | failures=0 | errors=0
EXIT_CODE_COMPUTED: 0
PROCESS_EXIT: 0
```
