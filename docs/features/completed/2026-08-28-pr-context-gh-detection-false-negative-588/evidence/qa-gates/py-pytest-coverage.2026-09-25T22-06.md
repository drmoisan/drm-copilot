# Python Test and Coverage Gate ([P8-T4])

Timestamp: 2026-09-26T22-22

Loop iteration: 2

Command: `poetry run pytest --cov=scripts.dev_tools.pr_context --cov-branch --cov-report=term-missing --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (repository root, full suite)

EXIT_CODE: 0

Output Summary:
- Result line: `5131 passed, 5 skipped, 1 deselected in 11.61s` (0 failed).
- Deselection reason: open issue #510. The deselected node enumerates the on-disk `.claude` tree, and the batch-budget hook's gitignored `.claude/state/python-batch-budget.<session_id>.json` makes it fail locally independent of this change; CI runs it on a fresh checkout.
- `TOTAL                                                      1610    112    642     80    90%`
- `scripts\dev_tools\pr_context\render_pr_helpers.py           132      5     66      3    96%   68, 93-95, 141, 278->277`
- `scripts\dev_tools\pr_context\collector.py                   168     11     50      8    91%   218, 229, 230->225, 272-273, 299-302, 315, 328, 360`
- For information: `scripts\dev_tools\pr_context\autoclose.py 45 0 16 0 100%` (`PY_BUILDER_FILE` is `render_pr_helpers.py`).
