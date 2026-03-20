Timestamp: 2026-03-14T23-38
Command: poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k test_main_falls_back_to_workspace_codex_when_template_root_template_is_missing
EXIT_CODE: 1
Output Summary:
- Expected red test reproduced.
- `test_main_falls_back_to_workspace_codex_when_template_root_template_is_missing` failed.
- Failure reason: `main()` exited through argparse because `--template-root` is an unrecognized argument.
