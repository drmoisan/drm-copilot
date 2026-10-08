# New scenario file list

Timestamp: 2026-10-07T22-03
Command: git status --porcelain -uall -- tests/fixtures/cleanup_worktrees/scenarios ; git diff origin/main --name-status -- tests/fixtures/cleanup_worktrees/scenarios
EXIT_CODE: 0
Output Summary:
- git status --porcelain -uall: exit 0, 28 lines, every line begins `?? ` (no M or D status): 19 under child_of_pairwise_probe_error (cherry.feature-child.out, cherry.feature-parent.out, diff-quiet.feature-child.rc, diff-quiet.feature-parent.rc, diff-tree.dead0001.out, diff-tree.dead0002.out, for-each-ref.out, merge-base.feature-child.feature-parent.rc, merge-base.feature-child.main.rc, merge-base.feature-parent.rc, merge-base.main.rc, rev-list.feature-parent.out, rev-parse.abbrev-ref-HEAD.out, rev-parse.feature-child_src_child.py.out, rev-parse.feature-parent_src_app.py.out, rev-parse.main_src_app.py.out, rev-parse.main_src_child.py.out, rev-parse.show-toplevel.out, worktree-list.out); 3 under report_scans_scan_failure (scan-dirs.out, scan-dirs.rc, worktree-list.out); 3 under report_scans_scan_failure_git_higher (for-each-ref.refs_remotes_.rc, scan-dirs.rc, worktree-list.out); 3 under report_scans_stale_ref_failure (for-each-ref.refs_remotes_.rc, scan-dirs.out, worktree-list.out).
- git diff origin/main --name-status: exit 0, no output (files are untracked, so the anchored diff sees none yet).
- Union of `?? ` paths and `A` paths is exactly the 28 planned paths; no M or D status; no path outside them.
