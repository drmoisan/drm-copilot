# Denominator Run C (round 2, P2-T3)

Timestamp: 2026-10-17T13-03
Command: sh SCRATCH/issue-527-launch-run.sh run-c scratch repo tests/scripts/powershell/PoshQC 1 (current directory `SCRATCH/run-c-cwd`, a directory outside the repository tree; same `Invoke-PoshQCTest` call and absolute `-Root <ROOT>` as run A); then sh SCRATCH/issue-527-launch-compare.sh run-c
EXIT_CODE: 0
Output Summary: the run exited 0 (PROCESS_EXIT=0). `SCRATCH/run-c/` holds both XML copies. Population source is `config`; 215 files; root LINE total 19095; 195 JUnit test cases, 0 failures. This is the different-current-directory leg of AC-01 (local only).

```text
== LABEL run-c
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
