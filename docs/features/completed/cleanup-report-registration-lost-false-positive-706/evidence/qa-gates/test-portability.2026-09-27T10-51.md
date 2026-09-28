# Test Portability (P4-T16)

Timestamp: 2026-09-27T10-51
ExpectedExitCode: 1
Command: git diff -U0 849aae609787172240c1ae7c33d10d6dd337d497 HEAD -- tests/shell/test_cleanup_worktrees_scan_helper.bats tests/fixtures/cleanup_worktrees/scan_roots/drive_letter/ | grep -E '^[+][^+]' | grep -n -E 'mktemp|BATS_TMPDIR|BATS_TEST_TMPDIR|BATS_FILE_TMPDIR|origin/|artifacts/|git init|/mnt/'
EXIT_CODE: 1
Output Summary: No output; exit 1. The added test lines and fixture contain no temporary file, remote ref, gitignored state, scratch repository, or host path.
