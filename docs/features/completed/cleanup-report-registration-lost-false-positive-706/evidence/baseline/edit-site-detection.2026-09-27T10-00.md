# Edit-Site Detection (P0-T5)

Timestamp: 2026-09-27T10-00
MERGE_BASE: 849aae609787172240c1ae7c33d10d6dd337d497

## Sibling-merge check

Command: git diff --stat 849aae609787172240c1ae7c33d10d6dd337d497 origin/main -- scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats tests/fixtures/cleanup_worktrees/scan_roots/
EXIT_CODE: 0
Output Summary: Empty output. No sibling change to these paths has merged to main since the merge base.

## Main-side counts

Command: git show origin/main:scripts/bash/cleanup_worktrees_scan_helper.sh | grep -c -F 'scan_helper_gitdir_target_exists() {'
EXIT_CODE: 0
Output Summary: 1

Command: git show origin/main:scripts/bash/cleanup_worktrees_scan_helper.sh | grep -c -F 'if [[ $target != /* ]]; then'
EXIT_CODE: 0
Output Summary: 1

Command: git show origin/main:scripts/bash/cleanup_worktrees_scan_helper.sh | grep -c -F 'target="$dir/$target"'
EXIT_CODE: 0
Output Summary: 1

Command: git show origin/main:scripts/bash/cleanup_worktrees_scan_helper.sh | grep -c -F 'if [[ -e $target ]]; then'
EXIT_CODE: 0
Output Summary: 1

Command: git show origin/main:scripts/bash/cleanup_worktrees_scan_helper.sh | grep -c -F '#                        else 0.'
EXIT_CODE: 0
Output Summary: 1

Command: git show origin/main:tests/shell/test_cleanup_worktrees_scan_helper.bats | grep -c -F '@test "scan-dirs emits has_gitfile/target_exists/size for each candidate directory"'
EXIT_CODE: 0
Output Summary: 1

## Branch-side counts

Command: grep -c -F 'scan_helper_gitdir_target_exists() {' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F 'if [[ $target != /* ]]; then' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F 'target="$dir/$target"' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F 'if [[ -e $target ]]; then' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F '#                        else 0.' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 1

Command: grep -c -F '@test "scan-dirs emits has_gitfile/target_exists/size for each candidate directory"' tests/shell/test_cleanup_worktrees_scan_helper.bats
EXIT_CODE: 0
Output Summary: 1

## Result

SIBLING-MERGED: none
MAIN-SIDE-ANCHOR-CHANGED: none
All six branch-side counts print 1; the plan proceeds.
