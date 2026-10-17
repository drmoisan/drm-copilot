# P5-T1 #901 Folder Locator Re-check (issue #927, AC-M25)

Timestamp: 2026-10-16T04-01
Command: test -d docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901
EXIT_CODE: 0
Output Summary: The #901 feature folder exists only at its active path, so Phase 5 proceeds and every #901 edit targets the active path.

SECOND_COMMAND: test -d docs/features/archive/2026-10-11-pr-author-hook-docs-only-exemption-901
SECOND_EXIT_CODE: 1

F901_LOCATOR: active
