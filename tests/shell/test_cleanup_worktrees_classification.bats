#!/usr/bin/env bats
# Classification-ladder unit tests for scripts/bash/cleanup_worktrees_lib.sh.
# Drives classify_branch and run_report against the checked-in git stub and the
# scenario fixtures under tests/fixtures/cleanup_worktrees/scenarios/, covering the
# six AC8 scenarios plus the ancestry-error and content-neutral rungs. No temporary
# files; no scratch git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    chmod +x "${STUB}" 2>/dev/null || true
}

cb() { # cb <scenario> <branch>  -> run classify_branch under that scenario
    # The git stub logs its argv to stderr; discard it so $output is the function's
    # stdout report lines only (bats `run` otherwise merges stderr into $output).
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${LIB}' && classify_branch '$2' 2>/dev/null"
}

report() { # report <scenario> -> run the full report driver under that scenario
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${LIB}' && run_report 2>/dev/null"
}

@test "merged_no_worktree: MERGED_CLEAN and no worktree record for the branch" {
    cb merged_no_worktree feature-merged
    [ "$status" -eq 0 ]
    [ "$output" = "BRANCH|feature-merged|MERGED_CLEAN" ]
    report merged_no_worktree
    [ "$status" -eq 0 ]
    [[ "$output" == *"BRANCH|feature-merged|MERGED_CLEAN"* ]]
    # No WORKTREE stanza names the branch (it has no worktree).
    [[ "$output" != *"WORKTREE|/repo-wt"*"feature-merged"* ]]
}

@test "merged_with_worktree: MERGED_CLEAN plus its WORKTREE record" {
    report merged_with_worktree
    [ "$status" -eq 0 ]
    [[ "$output" == *"BRANCH|feature-wt|MERGED_CLEAN"* ]]
    [[ "$output" == *"WORKTREE|/repo-wt/feat|feature-wt|"* ]]
}

@test "unmerged: NOT_MERGED (excluded from destructive action)" {
    cb unmerged feature-unmerged
    [ "$status" -eq 0 ]
    [ "$output" = "BRANCH|feature-unmerged|NOT_MERGED" ]
}

@test "ancestry_error: run fails with ANCESTRY_ERROR, not classified as unmerged" {
    report ancestry_error
    [ "$status" -ne 0 ]
    [[ "$output" == *"BRANCH|feature-broken|ANCESTRY_ERROR"* ]]
    [[ "$output" != *"NOT_MERGED"* ]]
}

@test "content_neutral: MERGED_CONTENT_NEUTRAL via the diff --quiet short-circuit" {
    cb content_neutral feature-neutral
    [ "$status" -eq 0 ]
    [ "$output" = "BRANCH|feature-neutral|MERGED_CONTENT_NEUTRAL" ]
}

@test "residual_on_main: MERGED_EQUIVALENT with no cherry-pick candidates" {
    cb residual_on_main feature-equiv
    [ "$status" -eq 0 ]
    [ "$output" = "BRANCH|feature-equiv|MERGED_EQUIVALENT" ]
    # No COMMIT|...|UNIQUE record is emitted.
    [[ "$output" != *"|UNIQUE|"* ]]
}

@test "residual_unique_doc: HAS_UNIQUE_RESIDUALS with a UNIQUE COMMIT record" {
    cb residual_unique_doc feature-doc
    [ "$status" -eq 0 ]
    [[ "$output" == *"BRANCH|feature-doc|HAS_UNIQUE_RESIDUALS"* ]]
    # COMMIT record carries SHA, paths, author, and author-date.
    [[ "$output" == *"COMMIT|feature-doc|doc000002|UNIQUE|.claude/agent-memory/notes.md|Dan Moisan|2026-07-21T11:00:00-07:00"* ]]
}

@test "current_exclusion: PROTECTED_CURRENT and never delete-eligible" {
    cb current_exclusion current-branch
    [ "$status" -eq 0 ]
    [ "$output" = "BRANCH|current-branch|PROTECTED_CURRENT" ]
    # The main worktree branch is also protected, never MERGED_CLEAN.
    cb current_exclusion main
    [ "$status" -eq 0 ]
    [ "$output" = "BRANCH|main|PROTECTED_CURRENT" ]
}
