Timestamp: 2026-03-14T23-38
Command: poetry run pytest tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py -k test_main_reports_checked_template_paths_when_template_lookup_fails
EXIT_CODE: 1
Output Summary:
- Expected red test reproduced.
- `test_main_reports_checked_template_paths_when_template_lookup_fails` failed.
- Failure reason: `main()` exited through argparse because `--template-root` is an unrecognized argument.
