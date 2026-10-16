# Python Push-Down Contract Tests After Fix, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T11-41
Task: P3-T9 (remediation-plan.2026-10-16T08-40.md)
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py (run as `poetry -C WORKTREE run pytest` with the two paths under WORKTREE)
EXIT_CODE: 0
Output Summary: ============================= 23 passed in 0.52s ==============================

## Acceptance

- `EXIT_CODE: 0`: met.
- The summary line reports no failed test: met (23 passed).
