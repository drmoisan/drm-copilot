# Isolation: Fresh Single-Process Run over tests/scripts (P6-T12, second restart pass after resume)

Timestamp: 2026-11-04T15-06
Command: sh SCRATCH/issue-1067-runpaths.sh testsscripts tests/scripts (one fresh PowerShell 7 process running SCRATCH/issue-1067-run-pester.ps1; coverage and JUnit off, PassThru, no shuffle)
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=14153 Passed=14143 Failed=0 Skipped=10 NotRun=0 (P0-T3 baseline `evidence/baseline/linux-tests-scripts-baseline.2026-11-04T03-54.md`: 14144 tests, 85 failed)
- CONTAINERS Total=503 Failed=0
- Every FILE line reports failed=0, including all 17 in-scope suites (AC8). No other container has failures, so none exceeds its P0-T3 baseline count.
- Probes after the run: POSHQC_SKIP_SCRIPT_EXECUTION=1 (left by `tests/scripts/dev-tools/link-feature-docs.Tests.ps1` and `tests/scripts/dev-tools/link-parent-child.Tests.ps1`, outside the change set; recorded finding, not changed), GLOBAL_PROMPT_CHANGED=False, LEAKED_GLOBAL_FUNCTIONS=0 of 7 (P0-T3: 7), LASTEXITCODE=0.
- Wall time about 17 minutes (2026-11-04T14-49 to 15-06 UTC).
