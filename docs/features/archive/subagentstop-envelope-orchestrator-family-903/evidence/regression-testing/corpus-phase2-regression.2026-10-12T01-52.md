# Corpus Regression Gate, Phase 2 ([P2-T16])

Timestamp: 2026-10-12T01-52
Command: sh <SCRATCHPAD>/run-ps.sh <SCRATCHPAD>/pester-run.ps1 -TestPath <the [P2-T8] set, S-DEP-SUITES-2 first> plus tests/scripts/claude-hooks/validate-executor-output.Tests.ps1,tests/scripts/claude-hooks/validate-planner-output.Tests.ps1,tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1
EXIT_CODE: 0
Output Summary: TotalCount=1242, PassedCount=1242, FailedCount=0, FailedContainersCount=0. Passed lines for both RULE-CHANGE rows: CORPUS-EXE-1 (RULE-CHANGE 1) and CORPUS-PLN-1 (RULE-CHANGE 2). FailedCount=0 confirms that the existing executor rows at tests/scripts/claude-hooks/validate-executor-output.Tests.ps1:178 and 183 and the existing planner rows at tests/scripts/claude-hooks/validate-planner-output.Tests.ps1:227, 241, 252, and 263 still pass.

RULE-CHANGE rows:
  RULE-CHANGE 1 -> [+] CORPUS-EXE-1 accepts a plan line array that contains an empty line
  RULE-CHANGE 2 -> [+] CORPUS-PLN-1 ignores a non-task checkbox line under a level-2 heading after the final phase

TEST_ORDER_NOTE: S-DEP-SUITES-2 ordered before FailClosed (see TEST_ORDER_NOTE in evidence/regression-testing/phase2-pass-after.2026-10-12T01-20.md).

TotalCount=1242
PassedCount=1242
FailedCount=0
FailedContainersCount=0
