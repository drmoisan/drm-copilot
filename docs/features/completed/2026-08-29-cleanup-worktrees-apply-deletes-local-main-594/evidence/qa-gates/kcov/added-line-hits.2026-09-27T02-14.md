# P6-T13 — Added-line execution (enumerate and actions libraries)

Timestamp: 2026-09-27T02-14
Task: [P6-T13]
RUN_ID: 36287146354 (cov.xml from the P6-T12 download, session scratchpad)
Effective BASE_SHA: `92d78897371cc5c4f301c8cc2238adeb3fff2fea` (DEV-1: replaces the plan literal `0658f6945aa833c6960dc5bf8a43635fc346991f`, which is no longer an ancestor of HEAD after the rebase recorded in P0-T1). The production edits were committed across `769afaa1`, `763b3865`, and `fd4d2656`; the diff anchored at `92d78897` covers all three.

Command: `git diff -U0 92d78897371cc5c4f301c8cc2238adeb3fff2fea HEAD -- scripts/bash/cleanup_worktrees_enumerate_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh`
EXIT_CODE: 0

Hunk headers:

```
+++ b/scripts/bash/cleanup_worktrees_actions_lib.sh
@@ -6,2 +6,2 @@
@@ -327,0 +328,5 @@ delete_candidate() {
@@ -337,0 +343,7 @@ delete_candidate() {
@@ -361,2 +373,4 @@ run_apply() {
+++ b/scripts/bash/cleanup_worktrees_enumerate_lib.sh
@@ -7,3 +7,3 @@
@@ -12,2 +12,2 @@
@@ -30,3 +30,3 @@
@@ -165,0 +166,5 @@ normalize_wt_path() {
@@ -177,0 +183,6 @@ compute_protected() {
@@ -198,0 +210,5 @@ compute_protected() {
```

Method: each added line number is derived from the new-side start and count of its hunk header. Blank and comment-only lines are dropped. Each remaining line is looked up in the `<line number="N" hits="H"/>` entries of the `<class>` element whose `filename` is the file's repository path.

## `scripts/bash/cleanup_worktrees_enumerate_lib.sh`

Added lines dropped as comment-only: 7, 8, 9, 12, 13, 30, 31, 32, 166, 167, 168, 183, 184, 185, 186, 187, 188, 210, 211. Dropped as blank: 170.

| Line | Text | hits |
|---|---|---|
| 169 | `CLEANUP_WT_BASE_BRANCH="main"` | 1 |
| 212 | `if [[ $current_branch != "$CLEANUP_WT_BASE_BRANCH" ]]; then` | 1 |
| 213 | `printf 'protected-branch\|%s\n' "$CLEANUP_WT_BASE_BRANCH"` | 1 |
| 214 | `fi` | absent (not instrumented by kcov) |

## `scripts/bash/cleanup_worktrees_actions_lib.sh`

Added lines dropped as comment-only: 6, 7, 328, 329, 330, 331, 332, 343, 344, 345, 373, 374, 375, 376.

| Line | Text | hits |
|---|---|---|
| 346 | `if [[ $name == "$CLEANUP_WT_BASE_BRANCH" ]]; then` | 1 |
| 347 | `printf 'ACTION\|delete\|%s\|BLOCKED-PROTECTED-BASE\n' "$name"` | 1 |
| 348 | `return 1` (inside the P3-T1 guard) | 1 |
| 349 | `fi` | absent (not instrumented by kcov) |

Output Summary:
- Required lines, each with hits >= 1: `CLEANUP_WT_BASE_BRANCH="main"` (enumerate:169, hits 1); `printf 'protected-branch|%s\n' "$CLEANUP_WT_BASE_BRANCH"` (enumerate:213, hits 1); `printf 'ACTION|delete|%s|BLOCKED-PROTECTED-BASE\n' "$name"` (actions:347, hits 1); `return 1` in the P3-T1 guard (actions:348, hits 1).
- Other added executable lines: enumerate:212 hits 1; actions:346 hits 1.
- Lines absent from the element (not instrumented): enumerate:214 `fi`, actions:349 `fi`.
- New-code coverage: 6 of 6 instrumented added lines executed (100%).
- Result: PASS.
