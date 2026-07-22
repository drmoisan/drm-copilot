#!/usr/bin/env bats
# End-to-end CLI tests for scripts/bash/cleanup-worktrees.sh. Runs the wrapper through
# the checked-in git stub, asserting the usage/exit-code contract, the no-mutation
# guarantee of the default report mode, destructive actions only in apply mode for
# delete-eligible states, and the source-guard. No temporary files; no scratch git
# repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    WRAPPER="${REPO_ROOT}/scripts/bash/cleanup-worktrees.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    chmod +x "${STUB}" 2>/dev/null || true
}

@test "--help prints usage and exits 0" {
    run bash "${WRAPPER}" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: cleanup-worktrees.sh"* ]]
}

@test "an unknown argument prints usage to stderr and exits 2" {
    run bash "${WRAPPER}" bogus
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage: cleanup-worktrees.sh"* ]]
}

@test "default report mode emits classification lines and performs no mutation" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_with_worktree" \
        bash "${WRAPPER}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"BRANCH|feature-wt|MERGED_CLEAN"* ]]
    [[ "$output" == *"WORKTREE|/repo-wt/feat|feature-wt|"* ]]
    # No mutating git command is invoked in report mode.
    [[ "$output" != *"worktree remove"* ]]
    [[ "$output" != *"branch -D"* ]]
    [[ "$output" != *"cherry-pick"* ]]
    [[ "$output" != *"worktree add"* ]]
}

@test "apply mode emits ACTION lines and destructive argv only for eligible states" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_with_worktree" \
        bash "${WRAPPER}" --apply
    [ "$status" -eq 0 ]
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/feat|OK"* ]]
    [[ "$output" == *"ACTION|branch-delete|feature-wt|OK"* ]]
    [[ "$output" == *"worktree remove /repo-wt/feat"* ]]
    [[ "$output" == *"branch -D feature-wt"* ]]
    # The protected main worktree branch is never a destructive target.
    [[ "$output" != *"branch -D main"* ]]
}

@test "sourcing the wrapper does not execute main (source-guard)" {
    run bash -c "source '${WRAPPER}'; echo SOURCED_OK"
    [ "$status" -eq 0 ]
    [ "$output" = "SOURCED_OK" ]
}
