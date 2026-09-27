# Fixture Check (P1-T2)

Timestamp: 2026-09-27T10-14

Command: wc -c tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit
EXIT_CODE: 0
Output Summary: 48 (no CR, no BOM).

Command: grep -c -x -F 'gitdir: C:/fixture-repo/.git/worktrees/wt_drive' tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit
EXIT_CODE: 0
Output Summary: 1

Command: git check-attr text eol -- tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit
EXIT_CODE: 0
Output Summary: `text: auto` and `eol: lf`.

Command: find tests/fixtures/cleanup_worktrees/scan_roots/drive_letter -type f
EXIT_CODE: 0
Output Summary: Exactly one path: tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/wt_drive/dotgit
