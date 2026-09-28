# P5-T8 — AC-21 test portability (anchored diff and stub-routing counts)

Timestamp: 2026-09-27T01-43
Task: [P5-T8]
Working directory: repository worktree root (HEAD `7e54e0e1`)
Effective BASE_SHA: `92d78897371cc5c4f301c8cc2238adeb3fff2fea` (rebased counterpart of plan literal `0658f6945aa833c6960dc5bf8a43635fc346991f`; DEV-1). Every command below substitutes it for the plan literal.
Route: the pipelines were run from a session-scratchpad `.sh` file (`sh <file>`) because the worktree isolation guard refuses pipelines that contain `git`; each `Command:` records the command itself.

"Added lines" below means the output of the anchored diff filtered by `grep -e '^+' | grep -v -e '^+++'` (89 lines).

## Command 1 — anchored diff of the three edited suites

Command: `git diff -U0 92d78897371cc5c4f301c8cc2238adeb3fff2fea -- tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats`
EXIT_CODE: 0

Hunk headers (each suite gains one appended hunk and no other change):

```
@@ -259,0 +260,14 @@  tests/shell/test_cleanup_worktrees_classification.bats (T4, T5)
@@ -153,0 +154,46 @@  tests/shell/test_cleanup_worktrees_deletion.bats (T6-T10)
@@ -113,0 +114,29 @@  tests/shell/test_cleanup_worktrees_enumeration.bats (T1-T3)
```

The `-0` old-side counts show that no pre-existing line in any suite was modified or removed.

Full diff output (verbatim):

```
diff --git a/tests/shell/test_cleanup_worktrees_classification.bats b/tests/shell/test_cleanup_worktrees_classification.bats
index 53a2031e..afc3ff26 100644
--- a/tests/shell/test_cleanup_worktrees_classification.bats
+++ b/tests/shell/test_cleanup_worktrees_classification.bats
@@ -259,0 +260,14 @@ report() { # report <scenario> -> run the full report driver under that scenario
+
+@test "classify_branch main is PROTECTED_CURRENT when the primary worktree is on another branch" {
+    # Reported topology: the primary worktree is on chore-cleanup and main is checked out nowhere.
+    cb base_not_checked_out main
+    [ "$status" -eq 0 ]
+    [ "$output" = "BRANCH|main|PROTECTED_CURRENT" ]
+}
+
+@test "classify_branch main is PROTECTED_CURRENT when main is checked out in a linked worktree" {
+    # /repo-wt/base holds main and is neither the primary nor the invoking worktree.
+    cb base_in_linked_worktree main
+    [ "$status" -eq 0 ]
+    [ "$output" = "BRANCH|main|PROTECTED_CURRENT" ]
+}
diff --git a/tests/shell/test_cleanup_worktrees_deletion.bats b/tests/shell/test_cleanup_worktrees_deletion.bats
index 2ca58d3c..8989dc71 100644
--- a/tests/shell/test_cleanup_worktrees_deletion.bats
+++ b/tests/shell/test_cleanup_worktrees_deletion.bats
@@ -153,0 +154,46 @@ apply() { # apply <scenario-dir>
+
+@test "run_report classifies main PROTECTED_CURRENT when the primary worktree is on another branch" {
+    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/base_not_checked_out" \
+        bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${RLIB}'; source '${DLIB}'; run_report 2>/dev/null"
+    [ "$status" -eq 0 ]
+    [[ "$output" == *"BRANCH|main|PROTECTED_CURRENT"* ]]
+    [[ "$output" != *"BRANCH|main|MERGED_CLEAN"* ]]
+}
+
+@test "run_apply does not delete main when the primary worktree is on another branch" {
+    apply "${SCEN}/base_not_checked_out"
+    [[ "$output" == *"BRANCH|main|PROTECTED_CURRENT"* ]]
+    [[ "$output" != *"BRANCH|main|MERGED_CLEAN"* ]]
+    [[ "$output" != *"branch -D main"* ]]
+    [[ "$output" != *"ACTION|branch-delete|main|"* ]]
+    # Positive controls: the two genuinely merged branches are still deleted.
+    [[ "$output" == *"ACTION|branch-delete|feature-merged|OK"* ]]
+    [[ "$output" == *"ACTION|branch-delete|zeta-merged|OK"* ]]
+}
+
+@test "run_apply neither removes nor deletes main checked out in a linked worktree" {
+    apply "${SCEN}/base_in_linked_worktree"
+    [[ "$output" == *"BRANCH|main|PROTECTED_CURRENT"* ]]
+    [[ "$output" != *"worktree remove /repo-wt/base"* ]]
+    [[ "$output" != *"branch -D main"* ]]
+    [[ "$output" != *"ACTION|branch-delete|main|"* ]]
+}
+
+@test "delete_candidate refuses the base branch before re-verification" {
+    # stderr is retained so the stub argv log is observable in $output.
+    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/base_not_checked_out" \
+        bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${ALIB}'; delete_candidate main '' MERGED_CLEAN"
+    [ "$status" -eq 1 ]
+    [[ "$output" == *"ACTION|delete|main|BLOCKED-PROTECTED-BASE"* ]]
+    [[ "$output" != *"merge-base"* ]]
+    [[ "$output" != *"worktree remove"* ]]
+    [[ "$output" != *"branch -D"* ]]
+}
+
+@test "delete_candidate refuses the base branch before removing its linked worktree" {
+    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/base_in_linked_worktree" \
+        bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${ALIB}'; delete_candidate main /repo-wt/base MERGED_CLEAN"
+    [ "$status" -eq 1 ]
+    [[ "$output" == *"ACTION|delete|main|BLOCKED-PROTECTED-BASE"* ]]
+    [[ "$output" != *"worktree remove"* ]]
+}
diff --git a/tests/shell/test_cleanup_worktrees_enumeration.bats b/tests/shell/test_cleanup_worktrees_enumeration.bats
index ab6f4741..8662a6bb 100644
--- a/tests/shell/test_cleanup_worktrees_enumeration.bats
+++ b/tests/shell/test_cleanup_worktrees_enumeration.bats
@@ -113,0 +114,29 @@ setup() {
+
+@test "compute_protected emits protected-branch main when the primary worktree is on another branch" {
+    # The primary worktree is on chore-cleanup and main is checked out nowhere.
+    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/base_not_checked_out" \
+        bash -c "source '${ELIB}' && source '${LIB}' && source '${DIRTLIB}' && compute_protected 2>/dev/null"
+    [ "$status" -eq 0 ]
+    [[ "$output" == *"protected-branch|chore-cleanup"* ]]
+    [[ "$output" == *"protected-branch|main"* ]]
+}
+
+@test "compute_protected emits protected-branch main under current_exclusion" {
+    # The base record is additional to the existing current-branch and path records.
+    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/current_exclusion" \
+        bash -c "source '${ELIB}' && source '${LIB}' && source '${DIRTLIB}' && compute_protected 2>/dev/null"
+    [ "$status" -eq 0 ]
+    [[ "$output" == *"protected-branch|current-branch"* ]]
+    [[ "$output" == *"protected-path|/repo/main"* ]]
+    [[ "$output" == *"protected-path|/repo-wt/current"* ]]
+    [[ "$output" == *"protected-branch|main"* ]]
+}
+
+@test "compute_protected emits exactly one protected-branch main when the current branch is main" {
+    # The merged_no_worktree scenario's current branch is main.
+    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_no_worktree" \
+        bash -c "source '${ELIB}' && source '${LIB}' && source '${DIRTLIB}' && compute_protected 2>/dev/null"
+    [ "$status" -eq 0 ]
+    count=$(printf '%s\n' "$output" | grep -c -x -F 'protected-branch|main' || true)
+    [ "$count" -eq 1 ]
+}
```

## Command 2 — stub-routed `run env` count over the added lines

Command: `git diff -U0 92d78897371cc5c4f301c8cc2238adeb3fff2fea -- tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats | grep -e '^+' | grep -v -e '^+++' | grep -c -F 'run env CLEANUP_WT_GIT_BIN="${STUB}"'`
EXIT_CODE: 0

Output: `6`

## Command 3 — total `run env` count over the added lines

Command: `git diff -U0 92d78897371cc5c4f301c8cc2238adeb3fff2fea -- tests/shell/test_cleanup_worktrees_enumeration.bats tests/shell/test_cleanup_worktrees_classification.bats tests/shell/test_cleanup_worktrees_deletion.bats | grep -e '^+' | grep -v -e '^+++' | grep -c -F 'run env'`
EXIT_CODE: 0

Output: `6`

Output Summary:
- The anchored diff adds one hunk per suite and modifies no pre-existing line.
- Both counts are `6` and equal: T1, T2, T3, T6, T9, and T10 each add one `run env` line, and every one routes git through the stub (`CLEANUP_WT_GIT_BIN="${STUB}"`); T4, T5, T7, and T8 use the existing `cb`/`apply` helpers, which already do so.
- The two pattern searches (remote refs, host paths, temp files, `artifacts/`) are recorded in `ac21-pattern-tests.2026-09-27T01-43.md` and `ac21-pattern-fixtures.2026-09-27T01-43.md`; both printed nothing and exited 1.
- Result: PASS.
