#!/usr/bin/env bats
# Enumeration/parsing/seam unit tests for scripts/bash/cleanup_worktrees_lib.sh.
# Sources the library and exercises enumerate_branches, parse_worktree_list,
# cleanup_wt_git (the CLEANUP_WT_GIT_BIN seam), compute_protected, and
# check_main_freshness against the checked-in git stub and scenario fixtures under
# tests/fixtures/cleanup_worktrees/. No temporary files; no real git repositories
# (the fallback test only invokes `git --version`).

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    SHAPES="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/worktree_shapes"
    MISSING="/nonexistent/definitely-not-a-git"
    # Checked-in stubs may lose the executable bit on some platforms; make runnable.
    chmod +x "${STUB}" 2>/dev/null || true
}

@test "enumerate_branches emits name/sha pairs in LC_ALL=C order" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_with_worktree" \
        bash -c "source '${LIB}' && enumerate_branches"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "feature-wt bbbb2222" ]
    [ "${lines[1]}" = "main aaaa0000" ]
}

@test "parse_worktree_list parses a branch stanza and marks the first as main" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SHAPES}" \
        bash -c "source '${LIB}' && parse_worktree_list"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "/repo/main|aaaa0000|main|main" ]
    [ "${lines[1]}" = "/repo-wt/onbranch|bbbb1111|some-branch|" ]
}

@test "parse_worktree_list parses a detached and locked stanza" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SHAPES}" \
        bash -c "source '${LIB}' && parse_worktree_list"
    [ "$status" -eq 0 ]
    [ "${lines[2]}" = "/repo-wt/detachedlocked|cccc2222|DETACHED|detached,locked" ]
}

@test "parse_worktree_list parses a prunable stanza" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SHAPES}" \
        bash -c "source '${LIB}' && parse_worktree_list"
    [ "$status" -eq 0 ]
    [ "${lines[3]}" = "/repo-wt/pruned|dddd3333|gonebranch|prunable" ]
}

@test "cleanup_wt_git honors an executable CLEANUP_WT_GIT_BIN override" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_no_worktree" \
        bash -c "source '${LIB}' && cleanup_wt_git for-each-ref --format='%(refname:short) %(objectname)' refs/heads/"
    [ "$status" -eq 0 ]
    [[ "$output" == *"feature-merged bbbb1111"* ]]
    [[ "$output" == *"main aaaa0000"* ]]
}

@test "cleanup_wt_git falls back to PATH git when the override is empty" {
    run env CLEANUP_WT_GIT_BIN="" \
        bash -c "source '${LIB}' && cleanup_wt_git --version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"git version"* ]]
}

@test "cleanup_wt_git falls back to PATH git when the override does not exist" {
    run env CLEANUP_WT_GIT_BIN="${MISSING}" \
        bash -c "source '${LIB}' && cleanup_wt_git --version"
    [ "$status" -eq 0 ]
    [[ "$output" == *"git version"* ]]
}

@test "compute_protected protects the current branch (dual-check: branch match)" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/current_exclusion" \
        bash -c "source '${LIB}' && compute_protected"
    [ "$status" -eq 0 ]
    [[ "$output" == *"protected-branch|current-branch"* ]]
}

@test "compute_protected protects the current worktree path and always the main worktree" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/current_exclusion" \
        bash -c "source '${LIB}' && compute_protected"
    [ "$status" -eq 0 ]
    # Main worktree (first stanza) is always protected.
    [[ "$output" == *"protected-path|/repo/main"* ]]
    # Current worktree path is protected via --show-toplevel path match.
    [[ "$output" == *"protected-path|/repo-wt/current"* ]]
}

@test "check_main_freshness emits WARN on main/origin divergence and returns 0" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/main_divergence" \
        bash -c "source '${LIB}' && check_main_freshness"
    [ "$status" -eq 0 ]
    [ "$output" = "WARN|main-divergence|localsha111|originsha222" ]
}

@test "check_main_freshness emits nothing when main matches origin/main" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_with_worktree" \
        bash -c "source '${LIB}' && check_main_freshness"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}
