# Pass-After: UnknownEnumMemberError Member Selection (Issue #890)

Timestamp: 2026-10-12T20-20
Task: P1-T3
Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_errors.py tests/scripts/dev_tools/test_parallel_mutation_protocol.py tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py`
EXIT_CODE: 0
Output Summary: `86 passed in 0.29s` (no `failed` token).

Fix applied to `scripts/dev_tools/_parallel_mutation_errors.py` per plan Reference R2:

- Module constant `_ENUM_MEMBERS_BY_FIELD: dict[str, tuple[str, ...]]` mapping `state` to `VALID_ITEM_STATES`, `merge_status` to `VALID_MERGE_STATUS`, `disposition` to `VALID_DISPOSITIONS`, in that insertion order.
- The constructor looks the field up and raises `ValueError` (`UnknownEnumMemberError has no member list for field 'mode'; expected one of state, merge_status, disposition.`) when the lookup returns None; the message format is otherwise unchanged.
- Class docstring and `field_name` argument docstring rewritten to name all three fields and the `ValueError`.

Docstring check: Grep tool, pattern ``Either ``state`` or ``merge_status`` ``, `output_mode` count, on `scripts/dev_tools/_parallel_mutation_errors.py` reports 0 (was 1 at the merge base, line 182).
