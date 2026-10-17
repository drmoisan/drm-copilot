# Test and Helper Rename Record (Remediation Cycle 1)

Timestamp: 2026-10-01T16-38
Task: [P2-T7]
Location: worktree root

## Table 1: regression-test renames (R2)

File: `tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py`

| Old collected name (registered through the module namespace) | New `def` name | `def` line | Observed `def` line length |
| --- | --- | --- | --- |
| `test_large_checkpoint_with_valid_issue_adoption_completes_without_potential_to_issue_receipt` | `test_valid_adoption_completes_without_potential_to_issue_receipt` | 150 | 79 |
| `test_adoption_error_fails_closed_and_orders_errors_before_local_execution_overrides` | `test_adoption_error_fails_closed_before_local_execution_overrides` | 170 | 80 |

Rationale (from the remediation plan "Test split design"): the old names were set by the executed plan's P2-T2 and exceed 88 columns on a `def` line. The new names keep the behavior terms that AC-5 and AC-9 cite (valid adoption, completion without the `potential_to_issue` receipt, fail-closed ordering before `local_execution_overrides`), and their `def` lines fit in 88 columns without a suppression. This follows the #512 precedent (PR #799), which resolved the same E501 conflict by shortening the name. Docstrings, bodies, and assertions are unchanged.

## Table 2: node IDs moved to the waivers file (R1)

Function names are unchanged; only the file component of the node ID changes.

| Function name | Old file | New file |
| --- | --- | --- |
| `test_waiving_new_active_feature_folder_is_rejected` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` |
| `test_waiving_validate_orchestration_artifacts_is_rejected` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` |
| `test_waiving_feature_entry_tool_on_bug_checkpoint_is_rejected` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` |
| `test_waiving_on_remediation_route_is_rejected` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` |
| `test_waiving_tool_with_successful_receipt_is_rejected` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` |
| `test_duplicate_waived_tool_is_rejected` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` |
| `test_absent_key_yields_no_errors_and_no_waivers` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` |
| `test_case_variant_tool_name_is_rejected` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` | `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` |

## Table 3: helper renames (support module `tests/scripts/dev_tools/orchestrator_state_issue_adoption_test_support.py`)

| Old name | New name |
| --- | --- |
| `e8dup` | `duplicate_tool_error` |
| `e8cannot` | `non_waivable_tool_error` |
| `e8notreq` | `tool_not_required_error` |
| `e8receipt` | `tool_has_receipt_error` |
| `e9` | `invalid_potential_record_error` |
| `_adoption` | `build_adoption` |
| `_state` | `build_state` |
| `_resolve` | `run_resolver` |

## Historical artifacts

The following historical artifacts keep the old names by design and are not edited: `evidence/regression-testing/py-regression-expect-fail.2026-09-30T14-17.md`, `evidence/regression-testing/py-regression-pass-after.2026-09-30T14-19.md`, `evidence/qa-gates/py-ruff.2026-09-30T14-48.md`, `evidence/other/handoff-notes.2026-09-30T15-15.md`.

## Verification (P2-T7)

Command: `grep -c -F -e "test_valid_adoption_completes_without_potential_to_issue_receipt" -e "test_adoption_error_fails_closed_before_local_execution_overrides" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/other/test-renames.2026-10-01T16-38.md`
EXIT_CODE: 0
Output Summary: count `2` (at least 2 required).

## Verification (P2-T8)

Executed-plan edit: in `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md` P2-T2 sub-bullets (lines 353-354), the two old names were replaced with the new names and the sentence "Renamed in remediation cycle 1; see the rename record." followed by this file's repository-relative path was appended to each. No other text of that plan was edited.

Command: `grep -c -F -e "test_valid_adoption_completes_without_potential_to_issue_receipt" -e "test_adoption_error_fails_closed_before_local_execution_overrides" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/plan.2026-09-29T15-26.md`
EXIT_CODE: 0
Output Summary: count `2`.
