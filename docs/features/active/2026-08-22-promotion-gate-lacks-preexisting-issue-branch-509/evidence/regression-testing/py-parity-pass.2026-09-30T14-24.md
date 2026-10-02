# Python Parity Corpus Reader Against the Python Authority

Timestamp: 2026-09-30T14-24
Task: P4-T31 (also confirms P4-T1 to P4-T29 fixture acceptance)
Working directory: worktree root

## Command 1

Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py
EXIT_CODE: 0
Output Summary:
- Summary line: `============================= 32 passed in 0.15s ==============================`
- 32 = 3 corpus-guard tests + 29 parametrized corpus cases. Zero failed; no fixture/module disagreement required resolution, so `_orchestrator_state_issue_adoption.py` was not changed and P3-T5 was not re-run.
- The loader (`load_fixture`) parses every file as JSON, requires the four keys `name`, `notes`, `checkpoint`, `expected_errors`, and requires `name` to equal the file stem; all 29 files loaded, which confirms the P4-T1 to P4-T29 structural acceptance. Each case's `expected_errors` matched `validate_routing_contract(checkpoint)` in order.

## Command 2

Command: ls tests/fixtures/orchestrator_state_issue_adoption
EXIT_CODE: 0
Output Summary: 29 files, matching P4-T1 to P4-T29:
absent-key-large-missing-receipt.json, adoption-error-precedes-local-execution-overrides.json, blank-evidence.json, blank-verified-at.json, bug-waives-feature-entry-tool.json, case-variant-tool-name.json, declared-list-omits-potential-to-issue.json, duplicate-waived-tool.json, empty-waived-tools.json, integer-issue-num.json, invalid-potential-record.json, issue-num-mismatch.json, issue-url-mismatch.json, leading-zero-issue-num.json, multiple-field-errors-in-rule-order.json, non-list-waived-tools.json, non-object-adoption-string.json, null-adoption.json, remediation-route-adoption.json, unknown-origin.json, unknown-verified-via.json, valid-bug-large-waives-bug-entry-tool-with-record.json, valid-large-waives-feature-entry-tool-with-record.json, valid-large-waives-potential-to-issue.json, valid-preparation-waives-potential-to-issue.json, waived-tools-omits-potential-to-issue.json, waives-new-active-feature-folder.json, waives-tool-with-successful-receipt.json, waives-validate-orchestration-artifacts.json

## Case-specific fixture checks

- P4-T5: `poetry run python -c "...; print('issue_adoption' in d['checkpoint'], sorted(d.keys()))"` on `absent-key-large-missing-receipt.json` printed `False ['checkpoint', 'expected_errors', 'name', 'notes']` (EXIT_CODE 0): the checkpoint carries no `issue_adoption` key (the only textual match of `issue_adoption` in that file is in its `notes` sentence).
- P4-T8: `grep -c -F -e "\"issue_num\": 509," tests/fixtures/orchestrator_state_issue_adoption/integer-issue-num.json` printed `1` (EXIT_CODE 0): `issue_num` is a JSON number.

## Generation method

The 29 files were written by a throwaway generator run from the session scratchpad (outside the repository; not committed), applying "Parity corpus construction rule" verbatim: key order `route_id`, `promotion-type`, `issue-num` `"509"`, the declared lists, receipts per resolved tool minus the case's lacking tools, `local_execution_overrides`, `delegation_bypasses`, then `issue_adoption`; two-space JSON indentation with a trailing LF newline, matching the #405 fixture layout.

Result: PASS
