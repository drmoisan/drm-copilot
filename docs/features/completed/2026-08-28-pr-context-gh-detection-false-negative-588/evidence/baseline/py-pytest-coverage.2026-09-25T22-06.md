# Python Baseline Tests with Coverage ([P0-T18])

Timestamp: 2026-09-26T21-21

Command: `poetry run pytest --cov=scripts.dev_tools.pr_context --cov-branch --cov-report=term-missing --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (repository root, full suite)

EXIT_CODE: 0

Output Summary:
- Result line: `5126 passed, 5 skipped, 1 deselected in 15.50s` (0 failed).
- Deselection reason: open issue #510. The deselected node enumerates the on-disk `.claude` tree, and the Python batch-budget hook writes gitignored `.claude/state/python-batch-budget.<session_id>.json`, which makes the node fail locally independent of this change; CI runs it on a fresh checkout.
- `TOTAL                                                      1608    112    640     80    90%`
- `scripts\dev_tools\pr_context\render_pr_helpers.py           130      5     64      3    96%   68, 93-95, 141, 275->274`
- `scripts\dev_tools\pr_context\collector.py                   168     11     50      8    91%   218, 229, 230->225, 272-273, 299-302, 315, 328, 360`
- `PY_BUILDER_FILE` is `render_pr_helpers.py` (not `autoclose.py`); for information, `scripts\dev_tools\pr_context\autoclose.py 45 0 16 0 100%`.
