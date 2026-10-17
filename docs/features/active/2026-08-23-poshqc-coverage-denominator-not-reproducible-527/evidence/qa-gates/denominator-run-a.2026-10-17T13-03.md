# Denominator Run A (round 2, P2-T1)

Timestamp: 2026-10-17T13-03
Command: sh SCRATCH/issue-527-launch-run.sh run-a root repo tests/scripts/powershell/PoshQC 1 (current directory `<ROOT>`; the launcher runs PowerShell 7 over SCRATCH/issue-527-run-poshqc.ps1, which imports the branch module `scripts/powershell/PoshQC/PoshQC.psd1` and calls `Invoke-PoshQCTest -Root <ROOT> -ScanFolders tests/scripts/powershell/PoshQC -DisableKoverageCopy`); then sh SCRATCH/issue-527-launch-compare.sh run-a
EXIT_CODE: 0
Output Summary: the run exited 0 (PROCESS_EXIT=0). `SCRATCH/run-a/` holds `powershell-coverage.xml` and `pester-junit.xml`. Population source is `config`; 215 files; root LINE total 19095 (missed plus covered); 195 JUnit test cases, 0 failures.

```text
== LABEL run-a
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

Notes:
- Keys are `package|sourcefile` with the package attribute (an absolute directory in the report) normalized to a repository-relative path.
- The run log also contains `Code coverage population: source=settings; files=1` lines. Those are emitted by Pester tests that call `Invoke-PoshQCTest` with injected seams inside the suite; the first line of the log is the run's own population line, which is the value recorded here.
- Figures are not pinned; they are compared with the other runs below.
