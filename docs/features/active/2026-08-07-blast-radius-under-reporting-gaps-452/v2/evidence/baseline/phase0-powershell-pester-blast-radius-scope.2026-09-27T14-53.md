# Phase 0 Baseline — Pester Scoped to the Blast-Radius Suites (P0-T28)

Timestamp: 2026-09-27T14-53

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/poshqc-test.ps1 -ScanFolder tests/scripts/claude-lib/blast-radius
EXIT_CODE: 0
Output (tail):

```
Tests completed in 26.99s
Tests Passed: 438, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/junit-report.ps1
EXIT_CODE: 0
Output:

```
ALL total=438 pass=438 fail=0 skip=0
```

Output Summary: Folder-scoped baseline ALL total=438, fail=0 (pass 438, skip 0). No failures, so the baseline failed set for this scope is empty.
