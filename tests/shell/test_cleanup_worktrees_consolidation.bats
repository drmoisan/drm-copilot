#!/usr/bin/env bats
# Consolidation unit tests for scripts/bash/cleanup_worktrees_actions_lib.sh. Sources
# both cleanup libraries and drives create_consolidation_worktree,
# cherry_pick_candidates (conflict/empty handling), and cleanup_consolidation_on_abort
# through the checked-in git stub. Fixtures live under
# tests/fixtures/cleanup_worktrees/consolidation/ and the classification scenarios.
# No temporary files; no scratch git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    ALIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_actions_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    CONS="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/consolidation"
    chmod +x "${STUB}" 2>/dev/null || true
}

@test "pre-existing documentationandmemories branch stops the run with a report" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/preexisting_consolidation_branch" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; create_consolidation_worktree"
    [ "$status" -ne 0 ]
    [[ "$output" == *"refs/heads/documentationandmemories already exists"* ]]
    # No worktree add is attempted when the branch already exists.
    [[ "$output" != *"worktree add"* ]]
}

@test "fresh run creates the consolidation worktree off main via worktree add" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${CONS}/ok" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; create_consolidation_worktree"
    [ "$status" -eq 0 ]
    [[ "$output" == *"worktree add /repo/main-wt/documentationandmemories -b documentationandmemories main"* ]]
    [[ "$output" == *"ACTION|worktree-add|/repo/main-wt/documentationandmemories|OK"* ]]
}

@test "candidates are cherry-picked in fed order with -x on every commit" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${CONS}/ok" \
        bash -c "printf 'COMMIT|branch-a|sha-a1|UNIQUE|d|A|d\nCOMMIT|branch-a|sha-a2|UNIQUE|d|A|d\nCOMMIT|branch-b|sha-b1|UNIQUE|d|A|d\n' | { source '${ELIB}'; source '${LIB}'; source '${ALIB}'; cherry_pick_candidates /repo-wt/dm; }"
    [ "$status" -eq 0 ]
    # -x present on every cherry-pick argv, in oldest-first / LC_ALL=C-fed order.
    [[ "$output" == *"cherry-pick -x sha-a1"* ]]
    [[ "$output" == *"cherry-pick -x sha-a2"* ]]
    [[ "$output" == *"cherry-pick -x sha-b1"* ]]
    a1_pos=$(printf '%s\n' "$output" | grep -n 'cherry-pick -x sha-a1' | head -n1 | cut -d: -f1)
    b1_pos=$(printf '%s\n' "$output" | grep -n 'cherry-pick -x sha-b1' | head -n1 | cut -d: -f1)
    [ "$a1_pos" -lt "$b1_pos" ]
}

@test "a conflicting pick aborts, records CONFLICT, and skips the rest of its branch" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${CONS}/conflict" \
        bash -c "printf 'COMMIT|branch-a|sha-a1|UNIQUE|d|A|d\nCOMMIT|branch-a|sha-a2|UNIQUE|d|A|d\nCOMMIT|branch-b|sha-b1|UNIQUE|d|A|d\n' | { source '${ELIB}'; source '${LIB}'; source '${ALIB}'; cherry_pick_candidates /repo-wt/dm; }"
    [ "$status" -ne 0 ]
    [[ "$output" == *"cherry-pick --abort"* ]]
    [[ "$output" == *"COMMIT|branch-a|sha-a1|CONFLICT|"* ]]
    [[ "$output" == *"ACTION|cherry-pick|sha-a2|SKIPPED-BRANCH"* ]]
    # The next branch still proceeds.
    [[ "$output" == *"ACTION|cherry-pick|sha-b1|OK"* ]]
}

@test "an empty pick is skipped and the commit is reclassified as content-on-main" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${CONS}/empty" \
        bash -c "printf 'COMMIT|branch-c|sha-c1|UNIQUE|d|A|d\n' | { source '${ELIB}'; source '${LIB}'; source '${ALIB}'; cherry_pick_candidates /repo-wt/dm; }"
    [ "$status" -eq 0 ]
    [[ "$output" == *"cherry-pick --skip"* ]]
    [[ "$output" == *"COMMIT|branch-c|sha-c1|CONTENT_ON_MAIN|reclassified-empty"* ]]
    [[ "$output" == *"ACTION|cherry-pick-skip|sha-c1|OK"* ]]
}

@test "abort cleanup removes the consolidation worktree and branch" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${CONS}/ok" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; cleanup_consolidation_on_abort"
    [ "$status" -eq 0 ]
    [[ "$output" == *"worktree remove /repo/main-wt/documentationandmemories"* ]]
    [[ "$output" == *"branch -D documentationandmemories"* ]]
    [[ "$output" == *"ACTION|worktree-remove|/repo/main-wt/documentationandmemories|OK"* ]]
    [[ "$output" == *"ACTION|branch-delete|documentationandmemories|OK"* ]]
}
