# Post-Fix Consumer Fixture Coverage Check (round 2, P3-T3)

Timestamp: 2026-10-17T13-04
Command: sh SCRATCH/issue-527-launch-fixture-check.sh (PowerShell 7 over SCRATCH/issue-527-fixture-check.ps1, reading `SCRATCH/fixture/powershell-coverage.xml`, the copy of the fixture run's coverage report, with the fixture root `<ROOT>/tests/fixtures/poshqc-consumer`)
EXIT_CODE: 0
Output Summary: SOURCEFILE_COUNT is 1; SOURCEFILE_NAMES is `Sample.psm1`; SAMPLE_LINE_COVERED is 2 (greater than 0); PACKAGE_RELATIVE is `scripts`; STANDIN_PRESENT is 0 (no sourcefile named `validate-bash.ps1`); OUTSIDE_PACKAGE_COUNT is 0. This is the inverse of the pre-fix result recorded in `fail-first-fixture-check.2026-10-02T07-55.md` (SAMPLE_PRESENT=0, STANDIN_PRESENT=1).

```text
SOURCEFILE_COUNT=1
SOURCEFILE_NAMES=Sample.psm1
SAMPLE_LINE_COVERED=2
PACKAGE_RELATIVE=scripts
STANDIN_PRESENT=0
OUTSIDE_PACKAGE_COUNT=0
PROCESS_EXIT=0
```
