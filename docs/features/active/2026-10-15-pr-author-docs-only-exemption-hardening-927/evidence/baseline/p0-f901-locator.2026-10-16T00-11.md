# P0-T5 #901 Folder Locator (issue #927, AC-M25, decision D11)

Timestamp: 2026-10-16T00-11
Command: test -d docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901
EXIT_CODE: 0
Output Summary: Only the active #901 folder exists; the archive path is absent. Locator result is active; Phase 5 edits may proceed at the active path.

## Commands and results

- `test -d docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901` -> exit 0
- `test -d docs/features/archive/2026-10-11-pr-author-hook-docs-only-exemption-901` -> exit 1

F901_ACTIVE: 0
F901_ARCHIVE: 1
F901_LOCATOR: active
