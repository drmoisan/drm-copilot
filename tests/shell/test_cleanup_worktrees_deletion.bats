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
    RLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_report_records_lib.sh"
    ALIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_actions_lib.sh"
    DLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_detached_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCAN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/scan"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    DEL="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/deletion"
    chmod +x "${STUB}" 2>/dev/null || true
    chmod +x "${SCAN}" 2>/dev/null || true
}

apply() { # apply <scenario-dir>
    # run_apply now calls the shared classification driver, so the sibling library must
    # be sourced here (bats subshells source the libraries directly and never run the CLI
    # wrapper) and the filesystem scan must route through the checked-in scan stub rather
    # than reading the real .claude/worktrees tree.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="$1" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${RLIB}'; source '${ALIB}'; source '${DLIB}'; run_apply"
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

@test "a zero-commit consolidation branch is never deleted" {
    # The branch was created at main and has no commit of its own, so its tip equals
    # main's tip. merge-base --is-ancestor answers 0 for that shape, which is why the
    # tip-equality pre-check has to win before the ancestry rung is consulted.
    apply "${DEL}/consolidated_zero_commit"
    [[ "$output" == *"ACTION|delete|documentationandmemories|BLOCKED-CONSOLIDATION-UNMERGED"* ]]
    [[ "$output" != *"branch -D documentationandmemories"* ]]
    [[ "$output" != *"worktree remove /repo-wt/dm"* ]]
}

@test "verify_consolidation_merged returns NOT_ANCESTOR on tip equality" {
    # Substring form, not equality: the stub writes one `stub-git: ` argv line to stderr
    # for each of the two rev-parse invocations the tip-equality pre-check makes, and
    # bats merges stderr into $output.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${DEL}/consolidated_zero_commit" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; verify_consolidation_merged"
    [ "$status" -eq 1 ]
    [[ "$output" == *"NOT_ANCESTOR"* ]]
    [[ "$output" != *"MERGED_CLEAN"* ]]
}

@test "verify_consolidation_merged fails closed on an empty rev-parse" {
    # merged_no_worktree supplies neither rev-parse.main.out nor
    # rev-parse.documentationandmemories.out, so both tip captures resolve to the empty
    # string under the stub. An unresolvable tip is a hard failure, not equality.
    # Substring form, not equality: retaining stderr is what makes the negative argv
    # assertion below meaningful, and the same retention puts `stub-git: ` lines into
    # $output.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_no_worktree" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; verify_consolidation_merged"
    [ "$status" -eq 2 ]
    [[ "$output" == *"ANCESTRY_ERROR"* ]]
    [[ "$output" != *"MERGED_CLEAN"* ]]
    [[ "$output" != *"branch -D documentationandmemories"* ]]
}

@test "apply mode allowlist is unaffected by a CHILD_OF short-circuit" {
    # Outcome preservation, property (b): a branch that reached NOT_MERGED through the
    # CHILD_OF short-circuit is gated by the same delete-eligible allowlist as one that
    # reached it through the full ladder. NOT_MERGED is not on that allowlist, so no
    # deletion ACTION of any result is emitted for it.
    apply "${SCEN}/child_of_not_merged"
    [[ "$output" == *"BRANCH|feature-child|NOT_MERGED"* ]]
    [[ "$output" == *"CHILD_OF|feature-child|feature-parent"* ]]
    [[ "$output" != *"ACTION|delete|feature-child|"* ]]
    [[ "$output" != *"branch -D feature-child"* ]]
}
