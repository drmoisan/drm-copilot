# Fail-before — Python renderer regression, expectation row line absent

Timestamp: 2026-08-20T09-53

Task: [P1-T6] [expect-fail]

Command: poetry run pytest tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py
EXIT_CODE: 1

## Expected outcome for this task

This task is tagged `[expect-fail]`. A FAILING run is the required outcome. The test module is a NEW
sibling of `tests/scripts/dev_tools/test_collect_pr_context_part4.py` (which is already over the
500-line limit and receives zero changed lines per SC5, AC20, AC25). It seeds its evidence artifact
through the in-memory `mem_fs_path` fixture and never uses `tmp_path`. The module is 73 lines, well
inside the 500-line limit.

## Missing expectation line, quoted from the run

```
        # Assert
        lines = body.splitlines()
>       assert "  - Expected EXIT_CODE: 1" in lines
E       AssertionError: assert '  - Expected EXIT_CODE: 1' in [
E         '- Feature: 2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485',
E         '  - Source: docs/features/...',
E         '  - Timestamp: 2026-08-20T09-53',
E         '  - Command: git grep -n forbidden-token',
E         '  - EXIT_CODE: 1',
E         '  - Normalized result: fail']

tests\scripts\dev_tools\test_collect_pr_context_expected_exit.py:68: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py::test_renderer_emits_expectation_line_for_non_zero_expectation
============================== 1 failed in 0.10s ==============================
```

The rendered body shows the pre-change six-line row with NO expectation line between
`  - EXIT_CODE: 1` and `  - Normalized result: ...`, and the result reads `fail` because the parser
still discards the declared expectation. Both halves of the defect are visible in one assertion
message: the missing renderer line and the mis-normalized result.

Output Summary: 1 failed, 0 passed; exit code 1, the expected outcome for this `[expect-fail]` task.
The rendered verification row contains no `  - Expected EXIT_CODE: 1` line, and the row's normalized
result reads `fail` for an artifact whose observed code equals its declared expectation. The
pass-after run is recorded at [P5-T7].
