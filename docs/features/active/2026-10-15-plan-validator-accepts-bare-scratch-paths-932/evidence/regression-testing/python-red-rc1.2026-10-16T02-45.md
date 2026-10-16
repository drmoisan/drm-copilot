# Python Red Run (Remediation Cycle 1)

Timestamp: 2026-10-16T02-45
Task: [P1-T6] [expect-fail]
Command: poetry run pytest -v --continue-on-collection-errors tests/scripts/dev_tools/test_plan_gate_commands.py tests/scripts/dev_tools/test_plan_gate_scratch.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:

Final line: `4 failed, 40 passed, 1 error in 0.97s`. Every failure and error matches an expected signature in [P1-T6].

Erroring node (collection):

- `tests/scripts/dev_tools/test_plan_gate_commands.py`: `E   ImportError: cannot import name 'split_plan_lines' from 'scripts.dev_tools.plan_gate_commands'`.

Failing nodes:

- `test_plan_gate_scratch.py::test_bare_scratch_definitions_splits_only_on_cr_lf_terminators[form-feed]`: `At index 0 diff: (2, 'SCRATCH is the session scratchpad.') != (1, 'intro SCRATCH is the session scratchpad.')`.
- `test_plan_gate_scratch.py::test_bare_scratch_definitions_splits_only_on_cr_lf_terminators[line-separator]`: `At index 0 diff: (2, 'SCRATCH is the session scratchpad.') != (1, 'intro SCRATCH is the session scratchpad.')`.
- `test_plan_gate_scratch_docs.py::test_rule_file_scope_and_enforcement_state_the_shipped_set`: `AssertionError: rule file lacks ['G1 through G9 judge the shell commands the plan states', 'G1 through G9 are fed by the command extractor', 'evaluates G1 through G9, calls']`.
- `test_plan_gate_scratch_docs.py::test_rule_file_documents_g10_line_rules_and_issue_token_class`: `AssertionError: rule file lacks ['an indented heading or task line is absorbed', 'do not end a physical line', 'One parity residual remains', '**Any issue token after the definition.**']`.

Expected-pass nodes (as printed by `-v`):

- `test_plan_gate_scratch.py::test_indented_heading_and_task_line_continue_logical_line[indented-heading] PASSED`
- `test_plan_gate_scratch.py::test_indented_heading_and_task_line_continue_logical_line[indented-task-line] PASSED`
- `test_plan_gate_scratch.py::test_logical_line_stops_at_heading_fence_and_task_line[indented-fence] PASSED`
- `test_plan_gate_scratch.py::test_logical_line_stops_at_heading_fence_and_task_line[column-0-heading] PASSED`
- `test_plan_gate_scratch.py::test_logical_line_stops_at_heading_fence_and_task_line[column-0-task-line] PASSED`

## Grep counts from [P1-T1], [P1-T2], [P1-T3]

[P1-T1] `tests/scripts/dev_tools/test_plan_gate_commands.py`:

- Pattern `^def (test_split_plan_lines_splits_only_on_cr_lf_terminators|test_extract_plan_commands_line_numbers_ignore_form_feed_and_line_separator)\(`: 2 (0 before the task).
- Pattern `^` (line count): 358 at task completion; 360 after the E501 wrap noted below. Both at most 500.
- Pattern `[\x{2028}\x0c]`: 0.

[P1-T2] `tests/scripts/dev_tools/test_plan_gate_scratch.py`:

- Pattern `^def (test_indented_heading_and_task_line_continue_logical_line|test_bare_scratch_definitions_splits_only_on_cr_lf_terminators)\(`: 2.
- Pattern `id="column-0-heading"`: 1. Pattern `id="column-0-task-line"`: 1. Pattern `id="heading"`: 0.
- Pattern `^` (line count): 452 (at most 500).
- Pattern `[\x{2028}\x0c]`: 0.

[P1-T3] `tests/scripts/dev_tools/test_plan_gate_scratch_docs.py`:

- Pattern `^def (test_rule_file_scope_and_enforcement_state_the_shipped_set|test_rule_file_documents_g10_line_rules_and_issue_token_class)\(`: 2.

## Execution notes

- Line-length deviation (ruff `E` selection, line length 88): the [P1-T2] docstring `Continuation stops at an indented fence and at any line not beginning with whitespace.` would occupy 95 columns on one line, so it is written as a two-line docstring with identical words. The two [P1-T1] extractor fixtures are written as implicit concatenations of two string literals with identical content. Neither change alters a test's behaviour or an asserted value.
- The tool layer decodes a ` ` escape passed through a tool parameter into the raw character. Each affected file was repaired with a character-code replacement so that every file carries the six-character escape and no raw form-feed or U+2028 character (verified by the `[\x{2028}\x0c]` counts above).
