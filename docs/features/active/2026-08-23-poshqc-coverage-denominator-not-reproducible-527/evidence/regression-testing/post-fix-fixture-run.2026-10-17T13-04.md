# Post-Fix Consumer Fixture Run (round 2, P3-T2)

Timestamp: 2026-10-17T13-04
Command: sh SCRATCH/issue-527-launch-run.sh fixture root fixture scripts,tests/scripts 0 (PowerShell 7 over SCRATCH/issue-527-run-poshqc.ps1: branch module, `Invoke-PoshQCTest -Root <ROOT>/tests/fixtures/poshqc-consumer -ScanFolders scripts,tests/scripts`, without `-DisableKoverageCopy`; current directory `<ROOT>`); then sh SCRATCH/issue-527-launch-compare.sh fixture
EXIT_CODE: 0
Output Summary: the run exited 0 (PROCESS_EXIT=0). Population line is `source=fallback; files=1`; JUnit reports 1 test case and 0 failures; the fixture's report has root LINE total 2 for its single file.

```text
== LABEL fixture
FILES=1
DUPLICATE_KEYS=0
ROOT_LINE_TOTAL=2
SUM_FILE_TOTALS=2
KEY_SHA256=52f803e942476206f7de1c6279f244d7fdee61f30908d7d8434a5a1fac2bb2c3
JUNIT_TESTS=1
JUNIT_FAILURES=0
POPULATION_LINE=Code coverage population: source=fallback; files=1
PROCESS_EXIT=0
```

The fixture contains no `config/poshqc-coverage.json`, so the population falls back to the effective test scan folders and contains only the fixture's production file.
