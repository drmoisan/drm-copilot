# Final QA pass 1: coverage comparison (P6-T8)

Timestamp: 2026-10-17T00-06
Command: sh SCRATCH/tools/run-cr.sh cr-cov-delta
EXIT_CODE: 0
Output Summary: Baseline total line coverage 0.25% (covered=46, missed=18561; scan folders tests/scripts/workflows and tests/scripts/claude-lib/ci-gate). Post-change total 1.3% (covered=245, missed=18580; scan folders also include tests/scripts/ci). New-code (per-file) coverage: scripts/ci/CiChangeScope.psm1 93.08% PASS, scripts/ci/Invoke-CiChangeScope.ps1 88.64% PASS (both files are new, so changed-line coverage equals per-file coverage). DELTA-NEW-CODE-FILES-FAILING: 0; EXIT_CODE_COMPUTED: 0.

## Output

```
RUN-CR: cr-cov-delta
DELTA-BASELINE-ARTIFACT: baseline-coverage-files.2026-10-16T23-25.md
DELTA-FINAL-ARTIFACT: final-coverage-files.2026-10-17T00-06.md
BASELINE TOTAL-LINE-COVERAGE: covered=46 | missed=18561 | percent=0.25
BASELINE COV-FILE: scripts/ci/CiChangeScope.psm1 | matches=0 | MISSING
BASELINE COV-FILE: scripts/ci/Invoke-CiChangeScope.ps1 | matches=0 | MISSING
FINAL TOTAL-LINE-COVERAGE: covered=245 | missed=18580 | percent=1.3
FINAL COV-FILE: scripts/ci/CiChangeScope.psm1 | covered=121 | missed=9 | percent=93.08 | threshold=85 | PASS
FINAL COV-FILE: scripts/ci/Invoke-CiChangeScope.ps1 | covered=78 | missed=10 | percent=88.64 | threshold=85 | PASS
DELTA-NEW-CODE-FILES-FAILING: 0
EXIT_CODE_COMPUTED: 0
```
