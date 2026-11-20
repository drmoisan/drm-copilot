# Apply commit ([P2-T3])

Timestamp: 2026-11-20T13-33
Command: git -C <worktree> add -u; git -C <worktree> add -- docs/README.md .dev/active/1016-move-development-docs-to-dev-root-and-reserve-docs-for-production/evidence; git -C <worktree> commit -q -F SCRATCH/issue-1016-msg-b-p2t3.txt; git -C <worktree> diff -M --name-status HEAD~1 HEAD; git -C <worktree> status --porcelain; git -C <worktree> rev-parse HEAD
EXIT_CODE: 0
Output Summary: Apply commit "feat(1016): move development records to .dev and reserve docs for production" (identifier from git rev-parse HEAD: 42e4581d8506403b434579a4a5bf5ab371c75f7f). git diff -M --name-status HEAD~1 HEAD: R100 35222, other R 53, A 5, M 475, D 0 (R100 above zero). The five A lines are docs/README.md and the four NEW_FEATURE evidence files written after the apply (the report pair dev-docs-migration-dry-run.2026-11-20T13-31.json and .md, task-check.P2-T1 and task-check.P2-T2). The 53 other R lines are moved files whose relative links were recomputed under links-only, plus the moved plan with its [P2-T2] and [P2-T3] check-offs. git status --porcelain lists no tracked change (0 lines, untracked included) after the commit.

| Status | Count |
| --- | --- |
| R100 | 35222 |
| R (other similarity) | 53 |
| A | 5 |
| M | 475 |
| D | 0 |
