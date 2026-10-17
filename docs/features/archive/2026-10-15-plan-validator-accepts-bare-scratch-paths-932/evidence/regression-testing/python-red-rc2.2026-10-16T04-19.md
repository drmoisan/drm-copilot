# Python Red Run (Remediation Cycle 2)

Timestamp: 2026-10-16T04-19
Task: [P1-T6] [expect-fail]
Command: poetry run pytest -v tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `9 failed, 24 passed in 0.61s`. The failing nodes are exactly the nine expected nodes with the stated signatures.

Failing nodes (first error line):

- `test_whitespace_class_matches_typescript`: `KeyError: 'PLAN_WHITESPACE_CLASS'`.
- `test_continuation_uses_plan_whitespace_class[nel-led]`: `AssertionError: unexpected findings [(1, '- SCRATCH means the session scratchpad. continued text')]` (Python continues the line).
- `test_continuation_uses_plan_whitespace_class[unit-separator-led]`: `AssertionError: unexpected findings [(1, '- SCRATCH means the session scratchpad. continued text')]` (Python continues the line).
- `test_continuation_uses_plan_whitespace_class[space-then-nel]`: `AssertionError: unexpected findings [(1, '- SCRATCH means the session scratchpad.')]` (Python treats the line as blank).
- `test_normalization_uses_plan_whitespace_class[nel-inline]`: `AssertionError: unexpected findings [(1, 'intro SCRATCH is the session scratchpad.')]` (NEL normalized to a space).
- `test_normalization_uses_plan_whitespace_class[unit-separator-inline]`: `AssertionError: unexpected findings [(1, 'intro SCRATCH is the session scratchpad.')]` (U+001F normalized to a space).
- `test_g6_window_split_ignores_form_feed_and_line_separator[form-feed]`: `AssertionError: assert ['[P2-T1] sea...-line token.'] == ['[P2-T1] sea...that exists.']` (G6 cross-line warning instead of the G5 finding).
- `test_g6_window_split_ignores_form_feed_and_line_separator[line-separator]`: same signature as `[form-feed]`.
- `test_rule_file_states_g10_whitespace_alignment`: `AssertionError: rule file lacks ['share one explicit whitespace class', '`PLAN_WHITESPACE_CLASS`', "keeps the command extractor's fence pattern"]`.

Expected-pass nodes (all PASSED):

- `test_continuation_uses_plan_whitespace_class[bom-led]`, `[nbsp-led]`
- `test_normalization_uses_plan_whitespace_class[bom-inline]`, `[nbsp-inline]`
- `test_plan_gate_discrimination_literals.py`: all 13 pre-existing tests PASSED.
- `test_plan_gate_scratch_docs.py`: all 7 pre-existing tests PASSED, including `test_rule_file_documents_g10_line_rules_and_issue_token_class`.

Grep counts recorded for [P1-T1], [P1-T2], [P1-T3]:

| Task | File | Pattern | Count |
| --- | --- | --- | --- |
| P1-T1 | `tests/scripts/dev_tools/test_plan_gate_scratch_whitespace.py` | three `^def test_...\(` names | 3 |
| P1-T1 | same | nine `id="..."` fixture ids | 9 |
| P1-T1 | same | `^` (line count) | 150 |
| P1-T1 | same | raw-character zero-count pattern | 0 |
| P1-T2 | `tests/scripts/dev_tools/test_plan_gate_discrimination_literals.py` | `^def test_g6_window_split_ignores_form_feed_and_line_separator\(` | 1 |
| P1-T2 | same | `^` (line count) | 387 |
| P1-T2 | same | raw-character zero-count pattern | 0 |
| P1-T3 | `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py` | `^def test_rule_file_states_g10_whitespace_alignment\(` | 1 |
| P1-T3 | same | `One parity residual remains` | 1 |
| P1-T3 | same | `^` (line count; 169 before) | 191 |
