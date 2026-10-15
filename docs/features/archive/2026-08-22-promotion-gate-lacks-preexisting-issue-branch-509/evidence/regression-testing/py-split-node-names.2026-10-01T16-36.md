# Split Node-Name Preservation (Remediation Cycle 1)

Timestamp: 2026-10-01T16-36
Task: [P1-T8]
Location: worktree root

## 1. Post-split node-name listing

Command: `poetry run pytest --collect-only -q tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py | grep -o -e "::.*" | sort > docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/regression-testing/py-adoption-node-names-after.txt`
EXIT_CODE: 0
Output Summary: pipeline exit codes 0/0/0; listing written to `evidence/regression-testing/py-adoption-node-names-after.txt`.

## 2. Baseline versus post-split comparison

Command: `diff docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/remediation-baseline/py-adoption-node-names.txt docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/regression-testing/py-adoption-node-names-after.txt`
EXIT_CODE: 0
Output Summary: printed nothing. All 39 baseline node names (function name plus parameter id) are preserved.

## 3. Kept file collection

Command: `poetry run pytest --collect-only -q tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py`
EXIT_CODE: 0
Output Summary: ends with `31 tests collected in 0.05s`.

## 4. Waivers file collection

Command: `poetry run pytest --collect-only -q tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py`
EXIT_CODE: 0
Output Summary (verbatim):

```text
tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_waiving_new_active_feature_folder_is_rejected
tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_waiving_validate_orchestration_artifacts_is_rejected
tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_waiving_feature_entry_tool_on_bug_checkpoint_is_rejected
tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_waiving_on_remediation_route_is_rejected
tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_waiving_tool_with_successful_receipt_is_rejected
tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_duplicate_waived_tool_is_rejected
tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_absent_key_yields_no_errors_and_no_waivers
tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py::test_case_variant_tool_name_is_rejected

8 tests collected in 0.04s
```

The list names exactly the six AC-8 tests, `test_absent_key_yields_no_errors_and_no_waivers`, and `test_case_variant_tool_name_is_rejected`.
