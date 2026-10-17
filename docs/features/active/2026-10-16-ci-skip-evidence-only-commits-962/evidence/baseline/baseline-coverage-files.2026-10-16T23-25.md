# Baseline per-file coverage (P0-T12)

Timestamp: 2026-10-16T23-25
Command: sh SCRATCH/tools/run-cr.sh cr-cov-files -TargetList "scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1" -NotBefore "2026-10-16T23:25:56.3940329Z"
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Baseline PowerShell line coverage of the config population for this scan set: 0.25% (covered=46, missed=18561, 208 source files). Both target files are MISSING because they do not exist yet. COVERAGE-FILE-FRESH: True; EXIT_CODE_COMPUTED: 1 as expected.

## Output

```
RUN-CR: cr-cov-files
COVERAGE-FILE-FRESH: True
SOURCEFILE-COUNT: 208
TOTAL-LINE-COVERAGE: covered=46 | missed=18561 | percent=0.25
COV-FILE: scripts/ci/CiChangeScope.psm1 | matches=0 | MISSING
COV-FILE: scripts/ci/Invoke-CiChangeScope.ps1 | matches=0 | MISSING
COV-FILES-FAILING: 2
EXIT_CODE_COMPUTED: 1
```
