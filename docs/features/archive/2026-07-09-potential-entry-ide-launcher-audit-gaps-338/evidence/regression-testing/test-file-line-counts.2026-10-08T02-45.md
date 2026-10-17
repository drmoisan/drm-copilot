Timestamp: 2026-10-08T02-45
Command: poetry run python -c "import sys;[print(p,len(open(p,encoding='utf-8').read().splitlines())) for p in sys.argv[1:]]" tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts
EXIT_CODE: 0
Output Summary: Four lines printed, each count at or below 500:
tests/scripts/dev_tools/test_new_potential_bug_entry.py 415
tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py 142
extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts 392
extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts 290
