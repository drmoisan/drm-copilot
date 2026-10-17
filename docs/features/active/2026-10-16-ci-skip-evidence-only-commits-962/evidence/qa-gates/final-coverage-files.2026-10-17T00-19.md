# Final QA pass 2: per-file coverage (P6-T7, AC-27)

Timestamp: 2026-10-17T00-19
Command: sh SCRATCH/tools/run-cr.sh cr-cov-files -TargetList "scripts/ci/CiChangeScope.psm1,scripts/ci/Invoke-CiChangeScope.ps1" -NotBefore "2026-10-17T00:18:19.8704726Z"
EXIT_CODE: 0
Output Summary: Fresh report from the pass 2 coverage run. Line coverage scripts/ci/CiChangeScope.psm1 93.08% (121 covered, 9 missed) PASS; scripts/ci/Invoke-CiChangeScope.ps1 88.64% (78 covered, 10 missed) PASS; threshold 85. Total line coverage of the population for this scan set 1.54% (covered=293, missed=18697, 214 source files). COV-FILES-FAILING: 0; EXIT_CODE_COMPUTED: 0. No branch figure applies to PowerShell. CI job (the only job that measures PowerShell coverage): poshqc / PowerShell QC (windows-latest).

## Output

```
RUN-CR: cr-cov-files
COVERAGE-FILE-FRESH: True
SOURCEFILE-COUNT: 214
TOTAL-LINE-COVERAGE: covered=293 | missed=18697 | percent=1.54
COV-FILE: scripts/ci/CiChangeScope.psm1 | covered=121 | missed=9 | percent=93.08 | threshold=85 | PASS
COV-FILE: scripts/ci/Invoke-CiChangeScope.ps1 | covered=78 | missed=10 | percent=88.64 | threshold=85 | PASS
COV-FILES-FAILING: 0
EXIT_CODE_COMPUTED: 0
```
