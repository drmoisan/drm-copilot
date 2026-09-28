# Python Fail-First ([P2-T6])

Timestamp: 2026-09-26T21-37

Command: `poetry run pytest tests/scripts/dev_tools/test_pr_context_integration.py -v` (repository root, pre-fix production code)

EXIT_CODE: 1

ExpectedExitCode: 1

Mode: FAIL-FIRST

Output Summary:
- State: `PY_BUILDER_STATE: PARAM-ONLY`, `PY_CALLSITE: PRESENT` (not both PRESENT), so the FAIL-FIRST branch applies.
- Result line: `1 failed, 4 passed in 0.12s`
- `FAILED tests/scripts/dev_tools/test_pr_context_integration.py::test_collect_and_write_end_to_end_scenarios[OfflineGh-verified1-referenced1-feature_docs1-None-False]` — `AssertionError: assert 'None (GitHub CLI unavailable; closing issues not verified)' in '...'`; the rendered section body was `None (no verified closing issues and readiness not PASS)` (the unavailable body is absent pre-fix).
- `PASSED tests/scripts/dev_tools/test_pr_context_integration.py::test_collect_and_write_end_to_end_scenarios[OnlineGh-verified0-referenced0-feature_docs0-#42-True]`
- `PASSED tests/scripts/dev_tools/test_pr_context_integration.py::test_collect_and_write_end_to_end_scenarios[OnlineGh-verified2-referenced2-feature_docs2-None-False]`
- `PASSED tests/scripts/dev_tools/test_pr_context_integration.py::test_generate_pr_prompt_alignment`
- `PASSED tests/scripts/dev_tools/test_pr_context_integration.py::test_prompt_contract_allows_evidence_backed_verification_only_when_enumerated`
- Exactly one FAILED node, beginning `...::test_collect_and_write_end_to_end_scenarios[OfflineGh-`. Acceptance met.
