# Baseline Collected Node Names (Remediation Cycle 1)

Timestamp: 2026-10-01T16-26
Task: [P0-T5]
Location: worktree root

## 1. Node-name listing of the issue-adoption unit test file

Command: `poetry run pytest --collect-only -q tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py | grep -o -e "::.*" | sort > docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/remediation-baseline/py-adoption-node-names.txt`
EXIT_CODE: 0
Output Summary: pipeline exit codes 0/0/0; listing written to `evidence/remediation-baseline/py-adoption-node-names.txt` (node names without the file component, sorted).

## 2. Listing line count

Command: `wc -l docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/remediation-baseline/py-adoption-node-names.txt`
EXIT_CODE: 0
Output Summary: `39` lines, matching the expected 39 collected node IDs.

## 3. Regression test file collection

Command: `poetry run pytest --collect-only -q tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py`
EXIT_CODE: 0
Output Summary (verbatim):

```text
tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py::test_large_checkpoint_with_valid_issue_adoption_completes_without_potential_to_issue_receipt
tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py::test_adoption_error_fails_closed_and_orders_errors_before_local_execution_overrides
tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py::test_declared_required_mcp_tools_equality_is_unchanged_under_adoption
tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py::test_absent_issue_adoption_keeps_routing_contract_output_unchanged

4 tests collected in 0.05s
```

Four node IDs; the first two are the `globals()`-registered names.
