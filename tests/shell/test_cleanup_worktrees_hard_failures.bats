#!/usr/bin/env bats
# Hard-failure (fail-open sweep) unit tests for the cleanup-worktrees libraries
# (scripts/bash/cleanup_worktrees_{enumerate,,actions}_lib.sh). Each test drives one
# git-backed function under the checked-in recording stub and a scenario fixture in
# which a git command returns a hard-failure exit code, and asserts that the function
# fails closed (a non-zero return and/or a hard-error report token) rather than
# fabricating a delete-eligible verdict. Tests 1-13 assert post-fix behavior and are
# deterministically red before the Phase 3 fixes; tests 14-17 are pass-before
# regression guards that pin behavior-preserving semantics across the fixes.
# No temporary files; no scratch git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    ALIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_actions_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    chmod +x "${STUB}" 2>/dev/null || true
}

runin() { # runin <scenario> <function-invocation>
    # Source the three libraries in dependency order and run the given invocation under
    # the named scenario. The stub logs argv to stderr; discard it so $output is the
    # function's stdout report lines only (bats `run` otherwise merges stderr).
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; $2 2>/dev/null"
}

# --- Fail-before-red set (assert post-fix behavior; red before Phase 3 fixes) ---

@test "1 diff_tree_error: classify_branch reports ANCESTRY_ERROR, never a MERGED_* verdict on a diff-tree hard failure" {
    # NEW-1 site 1: a non-zero git diff-tree exit during the empty-residual check must
    # yield DIFF_TREE_ERROR -> ANCESTRY_ERROR, not a fail-open MERGED_EQUIVALENT.
    runin diff_tree_error "classify_branch feature-dtfail"
    [ "$status" -eq 2 ]
    [ "$output" = "BRANCH|feature-dtfail|ANCESTRY_ERROR" ]
    [[ "$output" != *"MERGED_EQUIVALENT"* ]]
    [[ "$output" != *"MERGED_CLEAN"* ]]
    [[ "$output" != *"MERGED_CONTENT_NEUTRAL"* ]]
}

@test "2 residual_namestatus_error: classify_residual_commit reports RESIDUAL_ERROR, never CONTENT_ON_MAIN" {
    # NEW-1 site 2: a non-zero name-status diff-tree exit must yield RESIDUAL_ERROR
    # before any path processing, never a fail-open CONTENT_ON_MAIN.
    runin residual_namestatus_error "classify_residual_commit feature-ns ns000001"
    [ "$output" = "RESIDUAL_ERROR" ]
    [[ "$output" != *"CONTENT_ON_MAIN"* ]]
}

@test "3 ls_tree_error: classify_branch reports ANCESTRY_ERROR on a D-rung ls-tree hard failure" {
    # D-rung: a non-zero git ls-tree probe (path presence on main) is a hard failure
    # -> RESIDUAL_ERROR -> ANCESTRY_ERROR, not a fail-open droppable MERGED_EQUIVALENT.
    runin ls_tree_error "classify_branch feature-dfail"
    [ "$status" -eq 2 ]
    [ "$output" = "BRANCH|feature-dfail|ANCESTRY_ERROR" ]
    [[ "$output" != *"MERGED_EQUIVALENT"* ]]
}

@test "4 rev_parse_error_protection: compute_protected returns non-zero on a rev-parse hard failure" {
    # NEW-2: a non-zero git rev-parse (--abbrev-ref HEAD / --show-toplevel) is fatal, not
    # a silently weakened (empty) protection set.
    runin rev_parse_error_protection "compute_protected"
    [ "$status" -ne 0 ]
}

@test "5 rev_parse_error_protection: classify_branch reports ANCESTRY_ERROR for the current branch, never MERGED_CLEAN" {
    # NEW-2 propagation: a compute_protected hard failure must map to ANCESTRY_ERROR, so
    # the current branch cannot be degraded into a delete-eligible MERGED_CLEAN.
    runin rev_parse_error_protection "classify_branch curbranch"
    [ "$status" -eq 2 ]
    [ "$output" = "BRANCH|curbranch|ANCESTRY_ERROR" ]
    [[ "$output" != *"MERGED_CLEAN"* ]]
}

@test "6 enumerate_error: enumerate_branches returns non-zero with empty stdout on a for-each-ref hard failure" {
    # NEW-3 / enumerate pipeline: a for-each-ref failure must surface as a non-zero
    # return even without caller pipefail, never a silent empty (success) branch list.
    runin enumerate_error "enumerate_branches"
    [ "$status" -ne 0 ]
    [ -z "$output" ]
}

@test "7 enumerate_error: run_report returns non-zero and emits no BRANCH or WORKTREE lines" {
    # NEW-3 site 1: an enumeration hard failure must abort the report before any line, so
    # a git failure never yields a partial or misleadingly clean report.
    runin enumerate_error "run_report"
    [ "$status" -ne 0 ]
    [[ "$output" != *"BRANCH|"* ]]
    [[ "$output" != *"WORKTREE|"* ]]
}

@test "8 enumerate_error: run_apply returns non-zero and emits no ACTION lines" {
    # NEW-3 site 2: an enumeration hard failure in apply mode must abort before any
    # mutation, so no ACTION line is emitted.
    runin enumerate_error "run_apply"
    [ "$status" -ne 0 ]
    [[ "$output" != *"ACTION|"* ]]
}

@test "9 worktree_list_error: run_apply returns non-zero and emits no ACTION or WORKTREE lines" {
    # A worktree-list hard failure must abort apply mode before any WORKTREE line or
    # mutation.
    runin worktree_list_error "run_apply"
    [ "$status" -ne 0 ]
    [[ "$output" != *"ACTION|"* ]]
    [[ "$output" != *"WORKTREE|"* ]]
}

@test "10 consolidation_path_error: consolidation_worktree_path returns non-zero with empty stdout on a worktree-list hard failure" {
    # NEW-4: a parse_worktree_list hard failure must not derive a malformed
    # -wt/documentationandmemories path; it must fail with empty stdout.
    runin consolidation_path_error "consolidation_worktree_path"
    [ "$status" -ne 0 ]
    [ -z "$output" ]
}

@test "11 consolidation_path_empty: consolidation_worktree_path returns non-zero with empty stdout on an empty main worktree path" {
    # NEW-4: an empty main-worktree path must fail rather than derive a malformed path.
    runin consolidation_path_empty "consolidation_worktree_path"
    [ "$status" -ne 0 ]
    [ -z "$output" ]
}

@test "12 consolidation_path_error: create_consolidation_worktree returns non-zero and emits no worktree-add action" {
    # NEW-4 consumer: a consolidation-path failure must return before any git mutation.
    runin consolidation_path_error "create_consolidation_worktree"
    [ "$status" -ne 0 ]
    [[ "$output" != *"ACTION|worktree-add"* ]]
}

@test "13 consolidation_path_error: cleanup_consolidation_on_abort reports worktree-remove FAILED (path unknown) and still deletes the branch" {
    # NEW-4 consumer: best-effort abort cleanup must report the skipped removal and still
    # attempt the branch deletion.
    runin consolidation_path_error "cleanup_consolidation_on_abort"
    [[ "$output" == *"ACTION|worktree-remove||FAILED"* ]]
    [[ "$output" == *"ACTION|branch-delete|documentationandmemories|"* ]]
}

# --- Pass-before regression guards (green in both the fail-before and pass-after runs) ---

@test "14 deleted_path_on_main: classify_branch is NOT_MERGED because the deletion is unique work" {
    # D-rung behavior preservation: a path still present on main means the branch's
    # deletion is unique work; the branch is not delete-eligible.
    runin deleted_path_on_main "classify_branch feature-dunique"
    [[ "$output" == *"BRANCH|feature-dunique|NOT_MERGED"* ]]
    [[ "$output" != *"MERGED_EQUIVALENT"* ]]
}

@test "15 deleted_path_absent: classify_branch is MERGED_EQUIVALENT for a legitimately droppable deletion" {
    # D-rung behavior preservation: a path absent on main is a droppable deletion; the
    # branch remains content-equivalent-merged.
    runin deleted_path_absent "classify_branch feature-ddrop"
    [ "$status" -eq 0 ]
    [ "$output" = "BRANCH|feature-ddrop|MERGED_EQUIVALENT" ]
}

@test "16 worktree_list_error: reverify_delete_eligible blocks (BLOCKED-REVERIFY) when classification hard-fails" {
    # Fail-closed conversion: a classify_branch hard failure must block the destructive
    # re-verification, never allow it.
    runin worktree_list_error "reverify_delete_eligible feature-x MERGED_CLEAN"
    [ "$status" -eq 1 ]
    [[ "$output" == *"BLOCKED-REVERIFY"* ]]
}

@test "17 dirty_worktree_status_error: remove_worktree_safe blocks (BLOCKED-DIRTY) when the status read hard-fails" {
    # Fail-closed conversion: a failed worktree removal still reports BLOCKED-DIRTY and
    # returns non-zero even when the follow-up status read itself hard-fails.
    runin dirty_worktree_status_error "remove_worktree_safe /repo-wt/dirty"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY"* ]]
}
