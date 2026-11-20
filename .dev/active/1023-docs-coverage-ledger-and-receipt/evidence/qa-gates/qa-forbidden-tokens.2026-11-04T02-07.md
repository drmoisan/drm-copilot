# Final QA: Forbidden-Token Scan ([P7-T11])

Timestamp: 2026-11-04T02-07
Command: sh SCRATCH/issue-1023-forbidden-token-scan.sh (collects every created or changed path from git diff --name-only MERGE_BASE HEAD and git status --porcelain --untracked-files=all with status columns stripped and deleted paths dropped, adds every file under the feature folder, de-duplicates, keeps the paths that exist, and runs grep -n -i -E 'r[g]f|fore[c]ast' over them from the worktree root)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: SCANNED_FILES=101 GREP_EXIT=1. grep printed no line and exited 1: no restricted token in any created or changed file (LIB, BUNDLE, core.json, TESTS) or in any file under the feature folder (plan, spec, user-story, issue, research, evidence). No match to remove; no loop restart.

MERGE_BASE: the merge base of `origin/epic/documentation-estate-tooling-integration` and `HEAD`, as recorded in `qa-scope`.

Note: a first invocation of the script piped the list through `xargs`, which reports 123 when grep exits 1 for every batch; the script was changed to call grep directly with the expanded file list so that the recorded exit code is grep's own. Both invocations printed no line.
