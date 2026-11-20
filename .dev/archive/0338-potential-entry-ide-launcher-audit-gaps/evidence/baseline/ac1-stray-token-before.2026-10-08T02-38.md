Timestamp: 2026-10-08T02-38
Command: git grep -n -F -e "as_posix() for file_path in files" -- scripts/dev_tools/new_potential_bug_entry.py scripts/dev_tools/new_active_feature_folder_io.py
EXIT_CODE: 0
Output Summary: exactly two matches (the two path arguments were double-quoted when run, per the hook constraint):
- scripts/dev_tools/new_potential_bug_entry.py:243
- scripts/dev_tools/new_active_feature_folder_io.py:270
