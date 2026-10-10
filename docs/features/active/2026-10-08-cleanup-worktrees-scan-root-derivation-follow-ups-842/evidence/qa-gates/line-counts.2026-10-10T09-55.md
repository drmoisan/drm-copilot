# P2-T6 final-QC line counts

Timestamp: 2026-10-10T09-55
Command: wc -l SCRIPTS/cleanup_worktrees_enumerate_lib.sh SCRIPTS/cleanup_worktrees_scan_helper.sh SCRIPTS/cleanup_worktrees_detached_lib.sh tests/shell/test_cleanup_worktrees_scan_roots.bats
EXIT_CODE: 0
Output Summary:
- enumerate_lib: 418 (BASE_LINES_ENUM 416 + 2: met); at most 500: met.
- scan_helper: 173 (BASE_LINES_HELPER 171 + 2: met); at most 500: met.
- detached_lib: 301 (BASE_LINES_DETACHED 301 + 0: met); at most 500: met.
- scan_roots bats: 314 (BASE_LINES_BATS 242; informational); at most 500: met.
- total 1206.
