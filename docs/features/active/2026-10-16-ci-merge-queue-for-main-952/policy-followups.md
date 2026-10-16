# Policy Follow-ups for Issue #952 (Merge Queue on `main`)

Status: no rule file is edited by issue #952; each change below requires policy-edit approval and is recorded here for a separately approved change.

Each record quotes the full current line, read from the tree at the time this file was written (P7-T6), states why the line becomes stale after issue #952, and proposes replacement wording.

## Record 1

File: .claude/rules/orchestrator-state.md

Line: 238

Current text (verbatim):

> Each entry records one authorized standalone merge with the shape `{ pr_number, pr_url, issue_num, branch_name, authorized_by, authorized_at, session_id, basis, run_slug? }`. The gate consults the array only for a `gh pr merge --merge` command that names an explicit pull request number, and only after its per-feature, epic, and parallel allow conditions have all declined. For a command that names an explicit pull request number, the gate reads the per-feature checkpoint `artifacts/orchestration/orchestrator-state.json` beneath the one live worktree whose checkpoint records that number in `pr_gate.pr_number` or in a `standalone_merge_authorizations` entry, and it reads no per-feature checkpoint when no live worktree or more than one records it; a bare command reads the checkpoint beneath the session worktree.

Why it becomes stale after issue #952: the gate's scope predicate (`Test-EpicMergeGateCommandInScope` in `.claude/hooks/enforce-epic-merge-gate-command.ps1`) now covers every `gh pr merge` spelling except a pure `--disable-auto` and every `gh api` merge or enqueue mutation, and the standalone authorization branch is reached for all of them. "only for a `gh pr merge --merge` command" therefore understates the scope.

Proposed replacement wording (for the second sentence): "The gate consults the array only for a gated merge or merge-queue enqueue command (any `gh pr merge` spelling except a pure `--disable-auto`, or a `gh api` merge or enqueue mutation; issue #952) that names an explicit pull request number, and only after its per-feature, epic, and parallel allow conditions have all declined."

## Record 2

File: .claude/rules/parallel-orchestration.md

Line: 154

Current text (verbatim):

> - `gh pr view --json state,mergedAt,headRefOid` — pull-request state, merge time, and merge commit (`items[].pr_number`, `pr_url`, `merge_status`, `merged_at`, `merge_commit_sha`).

Why it becomes stale after issue #952: none of the three requested fields is the merge commit. After issue #952 a merge is recorded only after polling reports `MERGED` with a merge commit oid and `git merge-base --is-ancestor` confirms it, so the line names an incomplete source for `merge_commit_sha`.

Proposed replacement wording: "- `gh pr view --json state,mergedAt,mergeCommit,headRefOid` — pull-request state, merge time, merge commit (`mergeCommit.oid`), and head (`items[].pr_number`, `pr_url`, `merge_status`, `merged_at`, `merge_commit_sha`); under a merge queue `merge_commit_sha` is recorded only after the merge is confirmed by polling and ancestry check (issue #952)."

## Record 3

File: .claude/rules/parallel-orchestration.md

Line: 689

Current text (verbatim):

> - The `PreToolUse` merge gate `.claude/hooks/enforce-epic-merge-gate.ps1` carries a parallel allow-branch that authorizes a per-item `gh pr merge --merge` from the parallel-orchestrator checkpoint when `route_id == "parallel"`, the target item's `merge_status == "ci_green"`, and the command's PR number matches that item's `pr_number`; any other case fails closed with `EPIC_MERGE_GATE_BLOCKED`.

Why it becomes stale after issue #952: the gate is now method-agnostic, so the parallel allow-branch authorizes any gated merge or enqueue command for the item, not only `gh pr merge --merge`.

Proposed replacement wording (for "authorizes a per-item `gh pr merge --merge`"): "authorizes a per-item merge or merge-queue enqueue (any `gh pr merge` spelling except a pure `--disable-auto`, or a `gh api` merge or enqueue mutation; issue #952)".
