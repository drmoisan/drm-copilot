# Workflow suite, rule 17 RI-4 re-run of P4-T11

Timestamp: 2026-10-17T00-12
Command: sh SCRATCH/tools/run-cr.sh cr-pester-list -PathList "tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1" -NamePatternList "*(AC-18)*,*(AC-19)*,*(AC-20)*,*(AC-21)*,*(AC-36)*"
EXIT_CODE: 0
Output Summary: On the re-integrated head (merge 32350256b plus the A2 edit), SUITE Passed=39 Failed=0; NAMED totals AC-18 5, AC-19 9, AC-20 21, AC-21 3, AC-36 1, all Failed=0; EXIT_CODE_COMPUTED: 0. The merge_group trigger in the on: block does not affect any W row. AC-18 to AC-21 and AC-23 stay checked. CI job: poshqc / PowerShell QC (windows-latest).

## Output

```
RUN-CR: cr-pester-list
CONTAINER: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Result=Passed
SUITE: tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1 | Passed=39 | Failed=0 | Skipped=0 | NotRun=0
NAMED: *(AC-18)* | Passed=5 | Failed=0 | Total=5
NAMED: *(AC-19)* | Passed=9 | Failed=0 | Total=9
NAMED: *(AC-20)* | Passed=21 | Failed=0 | Total=21
NAMED: *(AC-21)* | Passed=3 | Failed=0 | Total=3
NAMED: *(AC-36)* | Passed=1 | Failed=0 | Total=1
TOTAL: Passed=39 | Failed=0 | Skipped=0 | NotRun=0 | FailedBlocks=0 | FailedContainers=0
EXIT_CODE_COMPUTED: 0
```
