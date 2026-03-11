# P1-T1 Push-Down Rewrite Red Evidence

Timestamp: 2026-03-10T20:38:00Z
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_copilot_customizations.py -k "test_rewrite_known_push_down_reference_to_real_command"
EXIT_CODE: 1
Output Summary: 1 failed, 7 deselected. AssertionError: assert 0 >= 1 (rewritten_reference_count). The push-down script reference is currently unmatched and not rewritten to the real command, which is the expected red state before the rewrite catalog entry is added.
