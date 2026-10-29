# Stale Untracked Copy Disposition

Timestamp: 2026-10-29T10-29
Task: [P0-T2]

Classification method: `git hash-object <path>` compared to `git rev-parse origin/main:<path>`; when they differ, the file modification time is compared to `git log -1 --format=%ct origin/main -- <path>`. Script: `SCRATCH/issue-995-classify.sh`.

| Path | Classification | Action |
| --- | --- | --- |
| docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/issue.md | IDENTICAL | moved to SCRATCH/stale/ |
| docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/plan.2026-10-28T07-38.md | OLDER (mtime 1793187488 < main commit 1793195694) | moved to SCRATCH/stale/ |
| docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/research/research.2026-10-28T12-10.md | IDENTICAL | moved to SCRATCH/stale/ |
| docs/features/active/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist-989/spec.md | OLDER (mtime 1793188107 < main commit 1793198979) | moved to SCRATCH/stale/ |
| docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/issue.md | IDENTICAL | moved to SCRATCH/stale/ |
| docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/plan.2026-10-28T07-57.md | OLDER (mtime 1793188662 < main commit 1793226433) | moved to SCRATCH/stale/ |
| docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/research/research.2026-10-28T13-00.md | IDENTICAL | moved to SCRATCH/stale/ |
| docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/spec.md | OLDER (mtime 1793189156 < main commit 1793233858) | moved to SCRATCH/stale/ |
| docs/features/active/2026-10-28-tiered-file-size-policy-500-700-800-990/user-story.md | OLDER (mtime 1793189158 < main commit 1793233858) | moved to SCRATCH/stale/ |
| docs/features/potential/promoted/2026-10-28-pr-author-issue-link-target-derivation-and-view-allowlist.md | IDENTICAL | moved to SCRATCH/stale/ |
| docs/features/potential/promoted/2026-10-28-tiered-file-size-policy-500-700-800.md | IDENTICAL | moved to SCRATCH/stale/ |

No file classified `RETAIN`. The four [P5-T1] records and this issue's feature folder were not touched.

Command: git merge --no-edit origin/main
EXIT_CODE: 0
Output Summary: merge commit created on `bug/parallel-run-leaves-uncommitted-records-and-worktrees-995` ("Merge remote-tracking branch 'origin/main'"), bringing in #989 (PR #991) and #990 (PR #993) among others; no conflicts. Post-merge `git status --porcelain` lists only this issue's feature folder, `docs/features/parallel/pr-author-and-file-size/parallel-status.md`, and the three promoted records `2026-10-28-completion-gate-rejects-adopted-feature-folder.md`, `2026-10-29-parallel-run-leaves-uncommitted-records-and-worktrees.md`, `2026-10-29-standalone-orchestration-merge-on-green.md`; none of the four stale paths is listed.
