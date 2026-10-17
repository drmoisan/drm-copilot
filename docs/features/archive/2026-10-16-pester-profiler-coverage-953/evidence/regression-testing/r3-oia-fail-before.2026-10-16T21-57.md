# r3 OIA_SUITE Alone, Fail-Before (P2-T11, expect-fail)

Timestamp: 2026-10-16T21-57
Command: TARGETED_RUN(oia-before, OIA_SUITE) through the Tool route (SCRATCH/issue-953-r3-p2-t11.sh): the TARGETED_RUN text with ISSUE953_PATHS = 'tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1', JUnit SCRATCH/issue-953-r3-oia-before-junit.xml, log SCRATCH/issue-953-r3-oia-before.log, followed by the validity check, JRP totals, the JRP failure check for OIA_DIRECT_TOKEN, the JRP token check for OIA_WIRING_TOKEN, and the first failure message.
EXIT_CODE: 45
ExpectedExitCode: 45
Output Summary:
- EXIT_CODE=45 START_UTC=2026-10-16T21:57:11.0393958Z; VALID=True
- JRP tests=49 failures=45 errors=0 (matches the orchestrator sweep line `RESULT 49 45 0 0`)
- FAILURE_CHECK OIA_DIRECT_TOKEN (Issue adoption accepts valid records (AC-6).) hits=10 failed=10 PASS
- TOKEN_CHECK OIA_WIRING_TOKEN (Routing contract wiring for issue adoption.) hits=4 PASS
- Result: expected failure reproduced.

OIA_FIRST_FAILURE_MESSAGE: CommandNotFoundException: The term 'Get-OrchestratorStateIssueAdoptionResult' is not recognized as a name of a cmdlet, function, script file, or executable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
