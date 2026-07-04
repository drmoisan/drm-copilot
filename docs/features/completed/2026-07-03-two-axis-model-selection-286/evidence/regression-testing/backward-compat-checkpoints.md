# Backward-Compatibility — Checkpoints Lacking the New Arrays

Timestamp: 2026-07-03T16-43

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py::test_no_complexity_assessments_is_backward_compatible tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing.py::test_no_model_routing_receipts_is_backward_compatible -v`
EXIT_CODE: 0

Output Summary: 2 passed. A valid step-based checkpoint that omits `complexity_assessments` and `model_routing_receipts` validates through the public `validate_orchestrator_state_text` with zero errors and no error text mentioning either new key. This confirms the two new keys are additive and optional, not added to `REQUIRED_STATE_KEYS`, and gated by `if <KEY> in state_map:`.

## Evidence Detail

- `test_no_complexity_assessments_is_backward_compatible` — builds `build_valid_orchestrator_state()`, asserts the key is absent, validates, asserts `errors == []` and no `complexity_assessments` error text.
- `test_no_model_routing_receipts_is_backward_compatible` — same pattern for `model_routing_receipts`.
- End-to-end wiring confirmed by `test_present_well_formed_complexity_wired_through_public_validator`, `test_present_malformed_complexity_caught_by_public_validator`, `test_present_well_formed_receipts_wired_through_public_validator`, and `test_present_malformed_receipts_caught_by_public_validator`: a present well-formed array produces no error, while a present malformed array is caught by the wired key-gated block.
- The existing checkpoint fixtures (`build_valid_orchestrator_state`) pass unchanged; the full pre-change suite remains green (verified in P8-T4 full run).

## Scope-change note (recorded, in-service of P3-T5 gate)

Wiring the two validators pushed `scripts/dev_tools/validate_orchestrator_state.py` from 485 to 512 lines, exceeding the 500-line file-size policy. To pass that gate, the four additive, key-gated optional validators (`remediation_loop`, `human_interaction`, `complexity_assessments`, `model_routing_receipts`), which all share the identical `(value) -> list[str]` gated shape, were consolidated into one local data-driven loop inside `validate_orchestrator_state_text`. Semantics are identical (each validator still runs only when its key is present). Final file size: 495 lines. See SCOPE-CHANGE item [P3-T5] in the executor report.
