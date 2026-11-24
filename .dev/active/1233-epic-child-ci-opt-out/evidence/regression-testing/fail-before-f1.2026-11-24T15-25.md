# Fail-before: F1 case-variant corpus fixtures (P1-T2)

Timestamp: 2026-11-24T15-25
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath tests/scripts/claude-lib/orchestrator-state/OrchestratorStateChildCi.Tests.ps1 (through SCRATCH/issue-1233-r1-fbf1.sh; four new fixtures added under tests/fixtures/orchestrator_state_child_ci/, OrchestratorStateCompletionChecks.psm1 unchanged)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Invoke-PoshQCParallelTest: workers=1; wall-clock=107.8s; exit code=1 (shard 1 exited 4; no merged artifact, read from the shard JUnit copied to SCRATCH/r1-fbf1-pester-parallel/shard-1/pester-junit.xml).
- Shard JUnit: tests=25, failures=4, errors=0. The four failing rows are exactly the rows of the new fixtures:
  - OCC-CORPUS-local-qc-gate-field-key-case-variant
  - OCC-CORPUS-remediation-loop-key-case-variant
  - OCC-CORPUS-review-outcome-head-key-case-variant
  - OCC-CORPUS-review-outcomes-key-case-variant
- Every other row passed (19 pre-existing corpus rows, OCC-CORPUS-FLOOR, OCC-ROUTE-OPT-OUT-PREPARATION).
- Attempts 1 to 3 exited 75 (queue timeout), recorded as queue timeouts, not failures.

Companion runs on the same tree (the Python and TypeScript validators already emit the expected errors):

Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py -k corpus
EXIT_CODE: 0
Output Summary: "24 passed in 3.25s" (23 corpus cases including the four new fixtures, plus the corpus floor row).

Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension "--testPathPatterns=test/lib/validate/orchestrator-state-child-ci[.]test[.]ts"
EXIT_CODE: 0
Output Summary: "Tests: 27 passed, 27 total" (23 before the fixtures plus the four new corpus rows).
