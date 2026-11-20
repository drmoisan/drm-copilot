# P2-T7 Python validator and parity tests before the fix (expect-fail)

Timestamp: 2026-09-30T10-40
Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason_parity.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Final line: `14 failed, 84 passed in 0.24s`.
- Failing nodes naming the new members (plain validation): `test_new_member_is_accepted_by_plain_validation[premise_falsified]`, `[external_dependency]`, `[policy_hold]`, `[awaiting_ci]`, `[human_decision_required]`.
- Failing nodes for the non-string guard: `test_non_string_value_yields_invalid_error_without_raising[list]` and `[dict]`, each raising `TypeError: unhashable type` at the membership check in `scripts/dev_tools/validate_orchestrator_state.py` (line 348).
- Failing parity nodes: `test_plain_errors_match_expected[accepts_awaiting_ci]`, `[accepts_external_dependency]`, `[accepts_human_decision_required_without_human_interaction]`, `[accepts_policy_hold]`, `[accepts_premise_falsified]`, `[completion_blocks_premise_falsified]`, and `test_completion_errors_match_expected[completion_blocks_premise_falsified]` (extra `Checkpoint has invalid blocked_reason: premise_falsified`).
- All 37 back-compat tests and every case for existing members, case variants, integers, null, and the absent key passed.
- Result: expected failure observed.
