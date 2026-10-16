# Policy Follow-up Record Check (P7-T6, coordinator R4)

Timestamp: 2026-10-16T11-36
Command: git grep -n -F -e "The gate consults the array only for a" -- .claude/rules/orchestrator-state.md; git grep -n -F -e "pull-request state, merge time, and merge commit" -- .claude/rules/parallel-orchestration.md; git grep -n -F -e "authorizes a per-item" -e "gh pr merge --merge" -- .claude/rules/parallel-orchestration.md; git add docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md; git grep -c -F -e "Current text (verbatim):" -- docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md; git status --porcelain -- .claude/rules
EXIT_CODE: 0
Output Summary: rule lines found at 238, 154 and 689 (equal to the plan citations; no line-number difference); Current text (verbatim) count = 3; porcelain for .claude/rules is empty (no rule file modified)

Results:
1. `.claude/rules/orchestrator-state.md`: exactly one line, numbered 238. It begins "Each entry records one authorized standalone merge with the shape" and contains "The gate consults the array only for a `gh pr merge --merge` command that names an explicit pull request number, and only after its per-feature, epic, and parallel allow conditions have all declined."
2. `.claude/rules/parallel-orchestration.md`: exactly one line, numbered 154: "- `gh pr view --json state,mergedAt,headRefOid` — pull-request state, merge time, and merge commit (`items[].pr_number`, `pr_url`, `merge_status`, `merged_at`, `merge_commit_sha`)."
3. `.claude/rules/parallel-orchestration.md`: the output includes line 689, whose text contains both `authorizes a per-item` and `gh pr merge --merge`. Line 690 (the worktree-removal gate) also matched `authorizes a per-item`. It is not part of the record.
4. `policy-followups.md` quotes the full current text of lines 238, 154 and 689 verbatim, copied from the outputs above.
5. `git grep -c -F -e "Current text (verbatim):"` printed `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-followups.md:3`.
6. `git status --porcelain -- .claude/rules` printed nothing (exit 0).
