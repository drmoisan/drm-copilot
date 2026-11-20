# Isolation: Fresh Single-Process Run over tests/scripts (P6-T12)

Timestamp: 2026-11-04T04-30
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts (one fresh PowerShell 7 process, coverage and JUnit off, PassThru, no shuffle)
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=14153 Passed=14143 Failed=0 Skipped=10 NotRun=0 (P0-T3 baseline: 14144 tests, 85 failed)
- CONTAINERS Total=503 Failed=0
- Every FILE line reports failed=0, including all 17 in-scope suites. No other container has failures, so no container exceeds its P0-T3 baseline count (the P0-T3 baseline had failures only in 16 of the 17 in-scope suites).
- Probes after the run: POSHQC_SKIP_SCRIPT_EXECUTION=1 (set by `tests/scripts/dev-tools/link-feature-docs.Tests.ps1` and `tests/scripts/dev-tools/link-parent-child.Tests.ps1`, outside the change set; recorded as a new finding), GLOBAL_PROMPT_CHANGED=False, LEAKED_GLOBAL_FUNCTIONS=0 (P0-T3: 7), LASTEXITCODE=0.
- Wall time about 10 minutes (start 04-20, end 04-30 UTC).
