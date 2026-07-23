#!/usr/bin/env bats
# Deletion-mechanics unit tests for scripts/bash/cleanup_worktrees_actions_lib.sh.
# Drives run_apply and delete_candidate through the checked-in git stub, asserting the
# dirty-worktree block, the same-process re-verification gate, the fixed
# worktree-remove-before-branch-delete order, the no-worktree branch-only path, the
# non-eligible-state no-op, and the consolidation-merge gate. Fixtures live under
# tests/fixtures/cleanup_worktrees/{scenarios,deletion}/. No temporary files; no
# scratch git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    ALIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_actions_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    DEL="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/deletion"
    chmod +x "${STUB}" 2>/dev/null || true
}

apply() { # apply <scenario-dir>
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="$1" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; run_apply"
}

@test "a dirty worktree blocks removal, reports DIRTY lines, and never forces" {
    apply "${SCEN}/dirty_worktree"
    [[ "$output" == *"DIRTY|/repo-wt/dirty|?? untracked-artifact.txt"* ]]
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY"* ]]
    # No forced-removal token appears anywhere in the argv log.
    [[ "$output" != *"--force"* ]]
    # The branch is not deleted because its worktree removal was blocked.
    [[ "$output" != *"branch -D feature-dirty"* ]]
}

@test "a candidate whose re-verification flips is blocked before any branch delete" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/unmerged" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; delete_candidate feature-unmerged /repo-wt/x MERGED_CLEAN"
    [ "$status" -ne 0 ]
    [[ "$output" == *"ACTION|delete|feature-unmerged|BLOCKED-REVERIFY"* ]]
    [[ "$output" != *"branch -D feature-unmerged"* ]]
    [[ "$output" != *"worktree remove"* ]]
}

@test "worktree removal is invoked strictly before branch deletion" {
    apply "${SCEN}/merged_with_worktree"
    remove_pos=$(printf '%s\n' "$output" | grep -n 'worktree remove /repo-wt/feat' | head -n1 | cut -d: -f1)
    delete_pos=$(printf '%s\n' "$output" | grep -n 'branch -D feature-wt' | head -n1 | cut -d: -f1)
    [ -n "$remove_pos" ]
    [ -n "$delete_pos" ]
    [ "$remove_pos" -lt "$delete_pos" ]
}

@test "a merged branch with no worktree gets only a branch delete" {
    apply "${SCEN}/merged_no_worktree"
    [[ "$output" == *"branch -D feature-merged"* ]]
    [[ "$output" == *"ACTION|branch-delete|feature-merged|OK"* ]]
    # No worktree removal is attempted for a branch that has no worktree.
    [[ "$output" != *"worktree remove"*"feature-merged"* ]]
}

@test "non-eligible states produce no destructive argv" {
    apply "${SCEN}/unmerged"
    [[ "$output" != *"worktree remove"* ]]
    [[ "$output" != *"branch -D"* ]]
    apply "${SCEN}/residual_unique_doc"
    [[ "$output" != *"worktree remove"* ]]
    [[ "$output" != *"branch -D"* ]]
    apply "${SCEN}/current_exclusion"
    [[ "$output" != *"worktree remove"* ]]
    [[ "$output" != *"branch -D"* ]]
}

@test "consolidated-content branch deletion is gated on the merge check" {
    # Unmerged: merge-base --is-ancestor documentationandmemories main returns 1.
    apply "${DEL}/consolidated_unmerged"
    [[ "$output" == *"ACTION|delete|documentationandmemories|BLOCKED-CONSOLIDATION-UNMERGED"* ]]
    [[ "$output" != *"branch -D documentationandmemories"* ]]
    # Merged: returns 0, so the consolidation branch is cleaned up.
    apply "${DEL}/consolidated_merged"
    [[ "$output" == *"branch -D documentationandmemories"* ]]
    [[ "$output" == *"ACTION|branch-delete|documentationandmemories|OK"* ]]
}
