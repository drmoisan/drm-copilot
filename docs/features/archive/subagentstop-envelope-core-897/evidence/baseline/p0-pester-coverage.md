# Phase 0 Baseline Full Pester Run with Coverage (issue #897, epic child E1)

Timestamp: 2026-10-11T12-45
Task: [P0-T9]
Command: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (R-FULL, fresh PowerShell 7 process started 12:33:21 and ended 12:44:41; then R-COV and R-JUNIT in the executor session)
EXIT_CODE: 0
Output Summary: baseline total coverage 89.16% (`Covered 89.16% / 0%. 25,877 analyzed Commands in 197 Files.`); `.claude/hooks` package line coverage 96.19% (covered=5226, missed=207); 9784 passed, 0 failed, 10 skipped; the helper source file is not yet present (`SOURCEFILE_MATCHES: 0`); JUnit root `tests=9794 failures=0 errors=0`; no failing test case.

## Verbatim Pester lines

```text
Tests Passed: 9784, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 89.16% / 0%. 25,877 analyzed Commands in 197 Files.
Tests completed in 558.09s
```

Process exit code (equals Pester's failed count under `Run.Exit = $true`): 0

## R-COV output (`artifacts/pester/powershell-coverage.xml`, LastWriteTime 2026-10-11T12-43-09)

```text
PACKAGE_NODE_MATCHES: 1
PACKAGE: .claude/hooks | covered=5226 | missed=207
COVERAGE: .claude/hooks/subagentstop-envelope.ps1 | n/a | covered=0 | missed=0 | SOURCEFILE_MATCHES: 0
```

Package percentage: 100 * 5226 / (5226 + 207) = 96.19

## R-JUNIT output (`artifacts/pester/pester-junit.xml`)

```text
JUNIT_ROOT: tests=9794 failures=0 errors=0
FAILING_TESTCASES: none
```

BASELINE_TOTAL_PCT: 89.16
BASELINE_HOOKS_PACKAGE_PCT: 96.19
