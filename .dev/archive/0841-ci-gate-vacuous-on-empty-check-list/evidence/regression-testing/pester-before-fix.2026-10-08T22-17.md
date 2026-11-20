# Pester Before-Fix Run (#841, P1-T4) [expect-fail]

Timestamp: 2026-10-10T09-18
Command: mcp__drm-copilot__run_poshqc_test workspace_root=<worktree> scan_folders=["tests/scripts/claude-lib/ci-gate"]; then Read artifacts/pester/pester-junit.xml
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
- MCP call disposition: raised `{"ok":false,"tool":"run_poshqc_test",...,"summary":"Command exited with code 18."}`. The exit code equals the failed-test count; this is the expected test-failure outcome, not an unrelated error, so no retry was made.
- Per-file (Invoke-CiGateParser.Tests.ps1 testsuite): TotalCount=33 PassedCount=15 FailedCount=18
- Folder totals (testsuites element): tests=35 failures=18 errors=0 (includes CiGate.Manifest.Tests.ps1: tests=2 failures=0)
- All 18 FAILED lines contain the text "RequireWorkflow". The 15 pre-existing tests (including the renamed empty-array test) pass.
- Result matches the plan expectation exactly; no design-review stop.

ROUTE_SUBSTITUTION: scratch scripts A1-A8 prohibited by operator constraint; substitutes below. The plan command `sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` was replaced by the A2 substitute: the MCP test call over the folder `tests/scripts/claude-lib/ci-gate`, then per-file counts read from the testsuite element named `Invoke-CiGateParser.Tests.ps1`. EXIT_CODE records the substitute route's task-level result (the counts were obtained), matching the plan's A2 convention that test failures appear in output rather than the exit code; the raw MCP disposition is recorded above.

## Freshness

`artifacts/pester/pester-junit.xml` modified 2026-10-10 09:17:42 -0400, after this MCP call was issued (prior file 09:13:00).

## JUnit attributes

- `<testsuites ... tests="35" errors="0" failures="18" disabled="0" time="1.056">`
- testsuite `...CiGate.Manifest.Tests.ps1`: tests="2" errors="0" failures="0" skipped="0"
- testsuite `...Invoke-CiGateParser.Tests.ps1`: tests="33" errors="0" failures="18" skipped="0"

## FAILED lines (testcase elements with a failure child)

1. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow parameter surface.declares -RequireWorkflow as a string defaulting to '' on the script, Invoke-CiGateParser, and Get-CiGateConclusion -- Expected 1, because each surface declares -RequireWorkflow exactly once, but got 0.
2. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow parameter surface.documents .PARAMETER RequireWorkflow in the help of the script, Invoke-CiGateParser, and Get-CiGateConclusion -- Expected 'RequireWorkflow' to be found in collection @('CHECKSJSON', 'HEADSHA', 'PRPIPELINERUNID', 'PRPIPELINERUNURL', 'NOWPROVIDER', 'ASJSON'), but it was not
3. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns pending for an empty check array with -RequireWorkflow CI -- ParameterBindingException: A parameter cannot be found that matches parameter name 'RequireWorkflow'.
4. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns pending for a null check set with -RequireWorkflow CI -- ParameterBindingException (same)
5. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns pending when only non-CI checks pass -- ParameterBindingException (same)
6. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns success when a CI check passes -- ParameterBindingException (same)
7. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns success when a CI check and a non-CI check both pass -- ParameterBindingException (same)
8. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns failure when a CI check failed -- ParameterBindingException (same)
9. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns failure when a CI check was cancelled -- ParameterBindingException (same)
10. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns failure when a CI check passes and a non-CI check failed -- ParameterBindingException (same)
11. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns pending when a CI check is pending -- ParameterBindingException (same)
12. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns pending when a CI check passes and a non-CI check is pending -- ParameterBindingException (same)
13. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns failure when a CI check is pending and another check failed -- ParameterBindingException (same)
14. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).returns pending when the only CI checks are skipping -- ParameterBindingException (same)
15. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).does not match a lowercase ci workflow name (case-sensitive) -- ParameterBindingException (same)
16. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).treats an element without a workflow property as non-matching without throwing -- ParameterBindingException (same)
17. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).throws an error naming -RequireWorkflow for a whitespace-only value -- Expected an exception with message like '*-RequireWorkflow*whitespace-only*' to be thrown, but the message was 'A parameter cannot be found that matches paramet...'
18. FAILED: Invoke-CiGateParser.ps1.-RequireWorkflow (epic-child guard).forwards -RequireWorkflow from the script entry point -- ParameterBindingException (same)

## Passing pre-existing tests (15)

All seven "conclusion derivation across bucket combinations" tests (including `returns success for an empty required-check array without -RequireWorkflow (vacuous satisfaction)`), three "fail-fast error handling" tests, one "deterministic verified_at" test, two "field passthrough" tests, one "JSON emission" test, and one "Get-CiGateConclusion pure helper" test: no failure child.

## Related task verification (P1-T2 line count, substitute route)

`git grep -c "" -- tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1` -> `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1:410` (LineCount=410, <= 500). P1-T3: `git grep --untracked -c "" -- tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` -> 312 (<= 500).

TotalCount=33
PassedCount=15
FailedCount=18
