# Final Pester Gate (P4-T2)

Timestamp: 2026-11-24T09-35
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run with coverage, through SCRATCH/issue-1234-pester-full.sh, which re-runs only after a queue timeout)
EXIT_CODE: 0
Output Summary:
- Attempt history: the first final gate (2026-11-24T08-42 to 08-58) exited 1 with 5 failures in 3 shards; the causes and fixes are recorded in evidence/other/final-qa-remediation.2026-11-24T09-16.md, and the loop restarted from format (evidence/qa-gates/powershell-static.2026-11-24T09-20.md).
- This run: started 2026-11-24T09-20, one queue timeout (exit 75, recorded as a queue timeout, not a failure), then exit 0; workers=8; wall-clock 763.03 s; all 8 shards exited 0.
- Counts from artifacts/pester/pester-junit.xml (written 2026-11-24T09-35): tests 29483, failures 0, errors 0, disabled 22. Failing tests: none.
- Compared with the Phase 0 baseline (evidence/baseline/pester.2026-11-24T05-02.md: 29292 tests, 0 failures, 22 disabled): no new failing test; 191 tests added.
- Repo-wide line coverage from artifacts/pester/powershell-coverage.xml (written 2026-11-24T09-35): 96.87% (47655 of 49197).
- Copies of both files are kept under SCRATCH/final-pester/ for the P4-T3 comparison.
