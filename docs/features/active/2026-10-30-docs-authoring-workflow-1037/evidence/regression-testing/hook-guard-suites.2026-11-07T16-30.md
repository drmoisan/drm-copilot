# Hook Guard Suites (P2-T5, P2-T6)

Timestamp: 2026-11-07T16-30
Command: sh SCRATCH/issue-1037-pester-parallel.sh phase2 (`Invoke-PoshQCParallelTest -Root <worktree>`); counts and `It` names read from the merged `artifacts/pester/pester-junit.xml` by SCRATCH/issue-1037-junit-suites.ps1
EXIT_CODE: 0
Output Summary: `hook-dependency-failure.Claude.Tests.ps1`: 203 tests, 0 failed; the new hooks contribute B1 rows (4: `HookPayload.psm1` and `docs-role-contract.ps1` for the write-scope hook, `subagentstop-envelope.ps1` and `docs-role-contract.ps1` for the SubagentStop hook), B2 rows (2) and B3 rows (2), all passed; B4 passed. `subagentstop-uncaught-error.Tests.ps1`: 14 tests, 0 failed; the U1 row for `validate-docs-role-output.ps1` passed and U2 passed.

Owner directive 2026-11-07: parallel test gates only

Deviation recorded: registering `enforce-docs-role-write-scope.ps1` under `PreToolUse` in [P2-T4] also required one additive `$script:ExemptHook` row in `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` (issue #1026 inventory guard, test `lists every hook registered for the Bash, Write|Edit, and Agent matchers as composed or exempted`), which the plan does not name. Without the row that test fails once the hook is registered. The row was added with the reason "acts only for the four documentation roles; the workflow runs in the main session, which carries no agent_type"; no other line of that file changed. The suite passed in this run: 12 tests, 0 failed.
