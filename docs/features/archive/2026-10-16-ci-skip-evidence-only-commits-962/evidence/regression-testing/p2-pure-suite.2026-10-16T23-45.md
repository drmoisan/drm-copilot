# Pure module suite pass (P2-T3, P2-T4; AC-5, AC-10, AC-12, AC-13)

Timestamp: 2026-10-16T23-45
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/ci/CiChangeScope.Tests.ps1" -NamePatternList "*(AC-5)*,*(AC-10)*,*(AC-12)*,*(AC-13)*"
EXIT_CODE: 0
Output Summary: scripts/ci/CiChangeScope.psm1 written (345 lines, ends with a newline, F1 to F8 with the two PD-6 suppressions). SUITE Passed=54 Failed=0; NAMED totals AC-5 4, AC-10 1, AC-12 6, AC-13 13, all Failed=0; EXIT_CODE_COMPUTED: 0. Micro-action checks on the module: cr-format -Write FORMAT-CLEAN (no file written), cr-pssa PSSA-TOTAL: 0. CI job: poshqc / PowerShell QC (windows-latest).

## Output

```
RUN-CR: cr-pester-list
CONTAINER: tests/scripts/ci/CiChangeScope.Tests.ps1 | Result=Passed
SUITE: tests/scripts/ci/CiChangeScope.Tests.ps1 | Passed=54 | Failed=0 | Skipped=0 | NotRun=0
NAMED: *(AC-5)* | Passed=4 | Failed=0 | Total=4
NAMED: *(AC-10)* | Passed=1 | Failed=0 | Total=1
NAMED: *(AC-12)* | Passed=6 | Failed=0 | Total=6
NAMED: *(AC-13)* | Passed=13 | Failed=0 | Total=13
TOTAL: Passed=54 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```

## Module checks

- `wc -l scripts/ci/CiChangeScope.psm1` -> `345`
- last bytes: `)` then `\n` (the file ends with a newline)
- cr-format -Write: `FORMAT-CLEAN: scripts/ci/CiChangeScope.psm1`, `FORMAT-DRIFT-COUNT: 0`
- cr-pssa: `PSSA: scripts/ci/CiChangeScope.psm1 | findings=0`, `PSSA-TOTAL: 0`
