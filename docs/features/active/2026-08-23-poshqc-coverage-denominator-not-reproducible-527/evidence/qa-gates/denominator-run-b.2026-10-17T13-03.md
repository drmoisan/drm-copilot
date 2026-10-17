# Denominator Run B (round 2, P2-T2)

Timestamp: 2026-10-17T13-03
Command: sh SCRATCH/issue-527-launch-run.sh run-b tests-scripts repo tests/scripts/powershell/PoshQC 1 (current directory `<ROOT>/tests/scripts`; same `Invoke-PoshQCTest` call and absolute `-Root` as run A); then sh SCRATCH/issue-527-launch-compare.sh run-b
EXIT_CODE: 0
Output Summary: the run exited 0 (PROCESS_EXIT=0). `SCRATCH/run-b/` holds both XML copies. Population source is `config`; 215 files; root LINE total 19095; 195 JUnit test cases, 0 failures.

```text
== LABEL run-b
FILES=215
DUPLICATE_KEYS=0
ROOT_LINE_TOTAL=19095
SUM_FILE_TOTALS=19095
KEY_SHA256=08ab3a8d86d003c06f1baa8276fccd32c7d0acc0c11254f90f6c218b118449a5
JUNIT_TESTS=195
JUNIT_FAILURES=0
POPULATION_LINE=Code coverage population: source=config; files=215
PROCESS_EXIT=0
```
