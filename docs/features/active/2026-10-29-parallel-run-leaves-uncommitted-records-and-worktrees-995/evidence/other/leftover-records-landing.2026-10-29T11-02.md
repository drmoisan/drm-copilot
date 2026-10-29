# Leftover Run Records Landing

Timestamp: 2026-10-29T11-02
Task: [P5-T1]
Command: git add -- docs/features/parallel/pr-author-and-file-size/parallel-status.md docs/features/potential/promoted/2026-10-28-completion-gate-rejects-adopted-feature-folder.md docs/features/potential/promoted/2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees.md docs/features/potential/promoted/2026-10-29-standalone-orchestration-merge-on-green.md; git commit -F SCRATCH/issue-995-commit-msg-records.txt -- <the same four paths>
EXIT_CODE: 0
Output Summary: both commands exited 0; commit "docs(parallel): land pr-author-and-file-size run records" created with 4 files changed, 256 insertions. Afterwards `git status --porcelain -- docs/features/parallel docs/features/potential` lists nothing, and `git diff --name-only $(git merge-base origin/main HEAD) HEAD` lists all four paths (plus the already-committed parallel.md and parallel-kickoff.md).

Deviation note: the commit message was supplied with `-F <file>` rather than `-m "<message>"`, so the message body and attribution trailers could be passed without shell-quoting newlines. The pathspec is the same four literal paths after `--`; no `-A`, `--all`, or `.` was used, and no other file was staged.
