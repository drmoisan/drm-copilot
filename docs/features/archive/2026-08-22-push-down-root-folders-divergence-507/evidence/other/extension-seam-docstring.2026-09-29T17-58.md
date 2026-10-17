# Extension Seam Docstring (P7-T4, AC15)

Timestamp: 2026-09-29T17-58
Command: git grep -n --untracked -E "#508|#621" -- scripts/dev_tools/push_down_claude_destination_writes.py
EXIT_CODE: 0

Output Summary:
- Exit code 0; two matching lines:
  - scripts/dev_tools/push_down_claude_destination_writes.py:24:#508 extends `MERGED_RELATIVE_PATHS` by registering `config/blast-radius.json`.
  - scripts/dev_tools/push_down_claude_destination_writes.py:25:#621 inserts its destination exclusion filter in `build_destination_write_stack()`
- The #621 sentence continues on line 26 (`as the outermost layer.`) because the full sentence is 107 characters and Ruff E501 enforces 88 columns on docstrings; the third sentence "Downstream children extend these seams; they do not replace, bypass, or duplicate them." is on line 27.
- `tests/scripts/dev_tools/test_push_down_claude_destination_writes.py::test_module_docstring_names_downstream_seams` asserts the tokens and all three sentences after whitespace normalization (passed).
- The spec's Extension seams section (spec.md) states the same contract.
