# RC2 final QC: Pester selection Set P (P1-T10)

Timestamp: 2026-11-24T19-01
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <Set P, 21 files listed in SCRATCH/issue-1233-rc2-setp.txt> (through SCRATCH/issue-1233-r1-pester.sh and SCRATCH/issue-1233-retry.sh; merged JUnit copied to SCRATCH/issue-1233-rc2-final-pester.junit.xml)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-24T18-58 to 2026-11-24T19-01; first attempt, no queue timeout.
- Invoke-PoshQCParallelTest: workers=8; wall-clock=166.32s; exit code=0.
- Merged JUnit (artifacts/pester/pester-junit.xml, removed before the run and rewritten by it): testcases=917, failures=0, errors=0, skipped=0, passed=917.
- P0-T3 recorded 913 passed; the increase is exactly four: OCC-CORPUS-local-qc-gate-null-fields, OCC-CORPUS-local-qc-gate-null-heads, CCO X-LIMIT [claude], and CCO X-LIMIT [claude-bundle], all Passed.
- Set L (five ProcessReduction suites) is included and passes on the committed ledger (the ledger is unchanged since commit 61702e988).
- Selection-scoped run under O1; not repo-wide gate evidence.
