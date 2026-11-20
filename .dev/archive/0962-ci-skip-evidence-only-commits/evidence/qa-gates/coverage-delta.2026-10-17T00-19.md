# Final QA pass 2: coverage comparison (P6-T8)

Timestamp: 2026-10-17T00-19
Command: sh SCRATCH/tools/run-cr.sh cr-cov-delta
EXIT_CODE: 0
Output Summary: Baseline total line coverage 0.25% (covered=46, missed=18561, 208 files). Post-change total 1.54% (covered=293, missed=18697, 214 files; the population grew by the two scripts/ci files and the PowerShell sources merged with #952, and the scan set adds tests/scripts/ci). New-code (per-file) coverage: scripts/ci/CiChangeScope.psm1 93.08% PASS, scripts/ci/Invoke-CiChangeScope.ps1 88.64% PASS; both files are new, so changed-line coverage equals per-file coverage. DELTA-NEW-CODE-FILES-FAILING: 0; EXIT_CODE_COMPUTED: 0.

## Output

```
RUN-CR: cr-cov-delta
DELTA-BASELINE-ARTIFACT: baseline-coverage-files.2026-10-16T23-25.md
DELTA-FINAL-ARTIFACT: final-coverage-files.2026-10-17T00-19.md
BASELINE TOTAL-LINE-COVERAGE: covered=46 | missed=18561 | percent=0.25
BASELINE COV-FILE: scripts/ci/CiChangeScope.psm1 | matches=0 | MISSING
BASELINE COV-FILE: scripts/ci/Invoke-CiChangeScope.ps1 | matches=0 | MISSING
FINAL TOTAL-LINE-COVERAGE: covered=293 | missed=18697 | percent=1.54
FINAL COV-FILE: scripts/ci/CiChangeScope.psm1 | covered=121 | missed=9 | percent=93.08 | threshold=85 | PASS
FINAL COV-FILE: scripts/ci/Invoke-CiChangeScope.ps1 | covered=78 | missed=10 | percent=88.64 | threshold=85 | PASS
DELTA-NEW-CODE-FILES-FAILING: 0
EXIT_CODE_COMPUTED: 0
```
