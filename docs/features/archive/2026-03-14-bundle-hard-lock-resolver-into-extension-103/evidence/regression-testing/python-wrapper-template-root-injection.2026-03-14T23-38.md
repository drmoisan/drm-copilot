Timestamp: 2026-03-14T23-38
Command: poetry run pytest tests/extensions/drm_copilot/resources/templates/test_resolve_hard_lock_prompt.py -k test_main_injects_bundled_template_root_when_flag_is_absent
EXIT_CODE: 1
Output Summary:
- Expected red test reproduced.
- `test_main_injects_bundled_template_root_when_flag_is_absent` failed.
- Failure reason: bundled wrapper file `extensions/drm-copilot/resources/templates/resolve_hard_lock_prompt.py` does not exist yet.
