# Predicate Restored (P3-T4)

Timestamp: 2026-09-27T10-29

## Pre-mutation hash

Command: sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: fee0479ead8204a294eb3c453ba31e0a653c7976a92e13bd88bbb7d25070274f (pre-mutation hash; taken before any edit).

## Post-restore: R1 line count (plan command, as written)

Command: grep -c -F '[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 1
Output Summary: 0. DEVIATION: the plan expects `1`. The local grep is GNU grep 3.0 (Git for Windows), whose `-F` mode collapses the two-character sequence `\\` in the pattern to a single backslash, so the pattern searches for `[/\]` and cannot match the file's `[/\\]` whatever the file contains. Diagnostic pairs below establish this; the byte-identity hash pair below proves the property this check was intended to prove.

## Post-restore: shfmt diff

Command: shfmt -d scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: No output.

## Diagnostics for the grep deviation

Command: printf '%s\n' 'a[/\]b' | grep -c -F '[/\\]'
EXIT_CODE: 0
Output Summary: 1 (a single-backslash input matches the double-backslash -F pattern, showing the collapse).

Command: grep -c -F '[[ $path == /* || $path == [A-Za-z]:[/\\\\]* ]]' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 1 (the same token with each backslash doubled for this grep matches the restored R1 line exactly once).

Command: grep -c -F '[[ $path == /* ]]' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 1
Output Summary: 0 (the mutated line is gone).

Command: git diff --exit-code --stat HEAD -- scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: No output; the helper equals the committed Phase 2 version (3efc3ddf).

## Post-restore hash (written last)

Command: sha256sum scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: fee0479ead8204a294eb3c453ba31e0a653c7976a92e13bd88bbb7d25070274f -- equal to the pre-mutation hash. The file is byte-identical to its pre-mutation state and the mutated line is gone.
