# Python Regression Test — Expected Failure Before the Fix

Timestamp: 2026-09-30T14-17
Task: P2-T3 [expect-fail]
Working directory: worktree root
Code under test: split-only code at SPLIT_COMMIT_SHA 5a3278df71bd14237a2a7bdeb1857728f5077de3 (no adoption resolver yet)

Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Summary line: `3 failed, 1 passed in 0.12s`
- Failed (assertion failures, not import errors):
  1. `test_large_checkpoint_with_valid_issue_adoption_completes_without_potential_to_issue_receipt` — observed errors `['Checkpoint missing successful MCP receipt: potential_to_issue.']`, i.e. `[R(potential_to_issue)]`; expected `[]`. This is the defect reproduction for AC-5.
  2. `test_adoption_error_fails_closed_and_orders_errors_before_local_execution_overrides` — observed `['Checkpoint missing successful MCP receipt: potential_to_issue.', 'Checkpoint local_execution_overrides must be empty at completion.']`; expected `[R(potential_to_issue), E4, LEO]` (the adoption error E4 is absent because no resolver exists).
  3. `test_declared_required_mcp_tools_equality_is_unchanged_under_adoption` — observed `['Checkpoint required_mcp_tools must match routing matrix for route large.', 'Checkpoint missing successful MCP receipt: potential_to_issue.']`; expected `[EQ(large)]` only.
- Passed: `test_absent_issue_adoption_keeps_routing_contract_output_unchanged` (observed `[R(potential_to_issue)]`, as expected).
- The outcome matches the task's expected repro exactly.

Result: EXPECTED FAILURE CONFIRMED
