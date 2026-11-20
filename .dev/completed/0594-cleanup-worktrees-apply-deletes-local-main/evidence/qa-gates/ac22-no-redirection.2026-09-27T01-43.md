# P5-T9 — AC-22 no file redirection in the added tests

Timestamp: 2026-09-27T01-43
Task: [P5-T9]
Working directory: repository worktree root (HEAD `7e54e0e1`)
Effective BASE_SHA: `92d78897371cc5c4f301c8cc2238adeb3fff2fea` (DEV-1 substitute for `0658f6945aa833c6960dc5bf8a43635fc346991f`).
ExpectedExitCode: 1

Command: `git diff -U0 92d78897371cc5c4f301c8cc2238adeb3fff2fea -- tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats | grep -e '^+' | grep -v -e '^+++' | grep -n '>' | grep -v -F '2>/dev/null'`
EXIT_CODE: 1

Output Summary:
- No output; the final grep exited 1. Every added line containing `>` is a `2>/dev/null` device redirection (four lines: the T6 `run_report` line and the T1, T2, T3 `compute_protected` lines), which writes no file.
- Result: PASS (observed exit 1 equals the expected exit 1).
