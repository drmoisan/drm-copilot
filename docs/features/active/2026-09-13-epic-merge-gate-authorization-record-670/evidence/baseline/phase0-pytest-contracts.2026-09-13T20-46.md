# Phase 0 Python Contract-Test Baseline — Issue #670

Timestamp: 2026-09-17T07-55
Task: [P0-T8]
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
EXIT_CODE: 0

Output Summary:
- `17 passed in 0.30s`
- Passed-test count: 17. Failed: 0.
- `.claude/state/` did not exist in this worktree when the task ran (`ls` reported "No such file or directory"), so the issue #510 branch does not apply; the baseline is clean.
- This is the reference count for [P6-T8], [P8-T3] and [P8-T5].
