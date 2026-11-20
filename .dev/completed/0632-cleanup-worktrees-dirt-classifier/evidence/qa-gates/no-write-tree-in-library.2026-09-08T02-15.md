# P4-T2 — the staged-tree probe writes nothing

Timestamp: 2026-09-08T02-15
Command: `bash -n scripts/bash/cleanup_worktrees_dirt_lib.sh && grep -c "write-tree\|GIT_INDEX_FILE" scripts/bash/cleanup_worktrees_dirt_lib.sh`
EXIT_CODE: 1
ExpectedExitCode: 1

Route: the plan's `wsl -d Ubuntu -- bash -lc` wrapper is superseded by EA-1. The two stages
were executed from the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d` as
separate commands with identical semantics, because the permission layer rejects a
`cd`-chained read command.

Stage 1 — `bash -n scripts/bash/cleanup_worktrees_dirt_lib.sh`
Exit: 0. The file parses, which is what allows the chained grep to run at all.

Stage 2 — `grep -c "write-tree\|GIT_INDEX_FILE" scripts/bash/cleanup_worktrees_dirt_lib.sh`
Stdout: `0`
Exit: 1

Output Summary: the count is `0` and the exit code is `1`, which is `grep -c`'s exit code
for a zero count. Neither literal appears anywhere in the file, including in the header
comment: the header expresses the same guarantee as "never by materialising a tree" and
"never redirects the index to an alternate file through the environment", because a
documentary mention of either literal would fail this gate for a reason unrelated to
behavior.

The probe reaches its answer by reading only. It captures
`--no-optional-locks -C <worktree> rev-list --max-count=201 HEAD`, drops the first returned
line (HEAD itself, whose tree an unmodified index already equals), and for each remaining
sha issues a guarded
`--no-optional-locks -C <worktree> diff-index --cached --quiet <sha> --`, returning the
matching sha on exit 0, continuing on exit 1, and returning the distinct hard-failure code
2 on any other exit. `CLEANUP_WT_STAGED_TREE_DEPTH` is 200 and the bound passed is
depth plus one.
