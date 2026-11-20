Timestamp: 2026-03-14T23-38
Command: poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k test_main_prefers_template_root_before_workspace_codex
EXIT_CODE: 1
Output Summary:
- Expected red test reproduced.
- `test_main_prefers_template_root_before_workspace_codex` failed.
- Failure reason: `main()` exited through argparse because `--template-root` is an unrecognized argument.
