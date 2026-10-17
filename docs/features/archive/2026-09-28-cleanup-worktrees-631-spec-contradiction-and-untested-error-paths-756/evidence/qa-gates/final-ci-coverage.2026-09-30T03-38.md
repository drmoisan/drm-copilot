# Final CI coverage (P2-T13)

Timestamp: 2026-10-08T02:16:00Z
Command: gh run download 37716284664 --name shell-coverage --dir artifacts/pester/kcov-final-756; then grep -m1 -o 'line-rate="[0-9.]*"' artifacts/pester/kcov-final-756/cov.xml and grep -F 'cleanup_worktrees_report_records_lib.sh' artifacts/pester/kcov-final-756/cov.xml (Grep tool equivalents)
EXIT_CODE: 0
Output Summary: Overall line-rate="0.942" (94.2%). Library class cleanup_worktrees_report_records_lib_sh__33 line-rate="0.952" (95.2%). Download exit code 0.
