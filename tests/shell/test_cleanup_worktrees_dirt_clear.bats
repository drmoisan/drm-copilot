#!/usr/bin/env bats
# Clearing-path and non-mutation tests for the dirt classifier (issue #632).
#
# This suite pins the safety properties of the one destructive path this feature adds:
# that the clear never forces, never touches ignored files, refuses on any UNIQUE
# verdict including the fail-closed one, re-verifies after clearing and before retrying
# the removal, and that report mode issues no mutating command at all.
#
# DRIVER, stated because the ordinal assertions in tests 1, 5, and 8 depend on it.
# Tests 1 through 8 invoke delete_candidate DIRECTLY under CLEANUP_WT_CLEAR_DISPOSABLE,
# in the form used at tests/shell/test_cleanup_worktrees_deletion.bats:47, and not
# run_apply. Driving run_apply would add a further classify_branch pass ahead of all of
# these and make an ordinal assertion written for the direct-driver case read the wrong
# line. The third argument is the RECORDED state, which reverify_delete_eligible takes
# as advisory and never compares against the fresh verdict, so passing MERGED_CLEAN is
# correct for dirt_clear_reverify_order even though that scenario's fresh verdict is
# MERGED_EQUIVALENT.
#
# OBSERVABILITY. Not every git call the ladder issues reaches the argv log.
# classify_ancestry redirects both streams of its `merge-base --is-ancestor` probe, so
# that call is issued but never logged and no assertion here is written over it. The
# cherry rung is the first ladder rung whose call is observable: classify_cherry_equiv-
# alent captures stdout only and leaves stderr attached. Every ordinal assertion below
# is therefore written over `cherry main feature-dirt` or over `worktree remove`.
#
# THE SECOND OCCURRENCE IS THE SUBJECT. remove_worktree_safe issues `git worktree
# remove` BEFORE it reads status, so the first occurrence in the log precedes the
# clearing sequence entirely. A first-match idiom such as the `grep -n ... | head -n1`
# at tests/shell/test_cleanup_worktrees_deletion.bats:47 would compare against a line
# that precedes `reset --hard` and fail regardless of whether the implementation is
# correct.
#
# The retry's own outcome is deliberately not asserted: the stub is stateless and
# replays worktree-remove.rc of 1 on both calls, so the retry reports BLOCKED-DIRTY
# again. The subject of these tests is the ordering and the absence of force and
# ignored-file flags, not the retry's result.
#
# No temporary files; no scratch git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    RLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_report_records_lib.sh"
    ALIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_actions_lib.sh"
    DLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_detached_lib.sh"
    DIRTLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_dirt_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCAN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/scan"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    chmod +x "${STUB}" 2>/dev/null || true
    chmod +x "${SCAN}" 2>/dev/null || true
}

clear_candidate() { # clear_candidate <scenario>
    # delete_candidate with the opt-in clearing flag set, keeping the stub argv log.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        CLEANUP_WT_CLEAR_DISPOSABLE=1 \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; source '${DIRTLIB}'; delete_candidate feature-dirt /repo-wt/dirt MERGED_CLEAN"
}

report_run() { # report_run <scenario>
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${RLIB}'; source '${DLIB}'; source '${DIRTLIB}'; run_report"
}

argv_log() { # argv_log -> the stub's argv and environment log lines only
    # Ordinal assertions are computed over THIS filtered list, not over the merged
    # $output. Every line here is written to stderr by a sequentially executed stub
    # process, so their relative order is the order the calls were issued; interleaving
    # them with the driver's buffered stdout would not be a reliable ordering.
    printf '%s\n' "$output" | grep '^stub-git' || true
}

nth_line_of() { # nth_line_of <n> <pattern>
    # Line number, within the filtered argv log, of the <n>th occurrence of <pattern>.
    printf '%s\n' "$(argv_log)" | grep -n -- "$2" | sed -n "$1p" | cut -d: -f1
}

count_of() { # count_of <pattern>
    printf '%s\n' "$(argv_log)" | grep -c -- "$1" || true
}

@test "dirt_clear_all_disposable: the clearing sequence is reset then clean then worktree remove" {
    clear_candidate dirt_clear_all_disposable
    reset_pos="$(nth_line_of 1 'reset --hard')"
    clean_pos="$(nth_line_of 1 'clean -fd')"
    # The SECOND worktree remove is the retry. The first is the attempt that failed and
    # is what made the clearing hook reachable at all.
    retry_pos="$(nth_line_of 2 'worktree remove')"
    [ -n "$reset_pos" ]
    [ -n "$clean_pos" ]
    [ -n "$retry_pos" ]
    [ "$reset_pos" -lt "$clean_pos" ]
    [ "$clean_pos" -lt "$retry_pos" ]
}

@test "dirt_clear_all_disposable: the clear result record reports OK" {
    clear_candidate dirt_clear_all_disposable
    [[ "$output" == *'ACTION|dirt-clear|/repo-wt/dirt|OK'* ]]
    [[ "$output" != *'ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE'* ]]
    [[ "$output" != *'ACTION|dirt-clear|/repo-wt/dirt|FAILED'* ]]
}

@test "dirt_clear_all_disposable: no force flag and no ignored-file flag reaches git" {
    clear_candidate dirt_clear_all_disposable
    log="$(argv_log)"
    # Positive control: the clearing sequence did run, so the negative assertion below
    # is not passing merely because nothing was invoked.
    [[ "$log" == *"clean -fd"* ]]
    # Matched as whole tokens rather than as substrings: -fd must not be read as -ff,
    # and -U0 must not be read as carrying -x.
    ! printf '%s\n' "$log" | grep -qE '(^| )(--force|-x|-X|-ff|-fdx|-fdX)( |$)'
}

@test "dirt_mixed_unique_blocks: a UNIQUE verdict refuses the clear" {
    clear_candidate dirt_mixed_unique_blocks
    [ "$status" -ne 0 ]
    [[ "$output" == *'ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE'* ]]
    [[ "$output" != *'ACTION|dirt-clear|/repo-wt/dirt|OK'* ]]
    # A refused clear stops the candidate: the branch is not deleted.
    [[ "$output" != *"branch -D feature-dirt"* ]]
}

@test "dirt_mixed_unique_blocks: a refused clear runs no reset, no clean, and no second worktree remove" {
    clear_candidate dirt_mixed_unique_blocks
    log="$(argv_log)"
    ! printf '%s\n' "$log" | grep -qE '(^| )reset( |$)'
    ! printf '%s\n' "$log" | grep -qE '(^| )clean( |$)'
    # Exactly one removal: the attempt that failed. No retry is issued.
    [ "$(count_of 'worktree remove')" -eq 1 ]
}

@test "dirt_classifier_read_error: a fail-closed UNIQUE refuses the clear" {
    clear_candidate dirt_classifier_read_error
    [ "$status" -ne 0 ]
    # The entry's only classifier read exits 128. That non-zero carries no verdict, so
    # it maps to UNIQUE, the aggregate is HAS_UNIQUE, and the clear is refused. A
    # transient git failure must never widen into a clear.
    [[ "$output" == *'ACTION|dirt-clear|/repo-wt/dirt|REFUSED-UNIQUE'* ]]
    log="$(argv_log)"
    ! printf '%s\n' "$log" | grep -qE '(^| )reset( |$)'
    ! printf '%s\n' "$log" | grep -qE '(^| )clean( |$)'
}

@test "dirt_clear_clean_failed: a non-zero clean reports FAILED and retries no removal" {
    clear_candidate dirt_clear_clean_failed
    [ "$status" -ne 0 ]
    [[ "$output" == *'ACTION|dirt-clear|/repo-wt/dirt|FAILED'* ]]
    [[ "$output" != *'ACTION|dirt-clear|/repo-wt/dirt|OK'* ]]
    log="$(argv_log)"
    # Positive control: the clean was attempted, which is what failed.
    [[ "$log" == *"clean -fd"* ]]
    # Only the original removal attempt; the retry is not reached.
    [ "$(count_of 'worktree remove')" -eq 1 ]
}

@test "dirt_clear_reverify_order: the post-clear re-verification cherry probe follows the reset and precedes the removal retry" {
    clear_candidate dirt_clear_reverify_order
    reset_pos="$(nth_line_of 1 'reset --hard')"
    # The SECOND cherry is the post-clear re-verification; the first is the pre-removal
    # one that ran before the clearing hook was reached. The cherry rung is the probe
    # under test because the ancestry rung's call is redirected and never logged, so a
    # search for it would return nothing whatever the implementation does.
    cherry_pos="$(nth_line_of 2 'cherry main feature-dirt')"
    retry_pos="$(nth_line_of 2 'worktree remove')"
    [ -n "$reset_pos" ]
    [ -n "$cherry_pos" ]
    [ -n "$retry_pos" ]
    [ "$reset_pos" -lt "$cherry_pos" ]
    [ "$cherry_pos" -lt "$retry_pos" ]
    # Exactly two re-verifications reach the cherry rung under this fixture: one before
    # the removal attempt and one after the clear.
    [ "$(count_of 'cherry main feature-dirt')" -eq 2 ]
}

@test "reverify_delete_eligible refuses a non-eligible branch under the unmerged fixture" {
    # Driven directly rather than through the clearing path, because the stateless stub
    # cannot flip a canned response between two calls of the same key and so cannot make
    # one re-verification pass and the next fail within one run.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/unmerged" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${ALIB}'; source '${DIRTLIB}'; reverify_delete_eligible feature-unmerged MERGED_CLEAN"
    [ "$status" -ne 0 ]
    [[ "$output" == *'ACTION|delete|feature-unmerged|BLOCKED-REVERIFY'* ]]
}

@test "dirt_staged_tree_is_commit: report mode issues no mutating git command and redirects no index" {
    report_run dirt_staged_tree_is_commit
    log="$(argv_log)"
    # Positive control: the classifier's staged-tree probe did run, so the eight
    # negative assertions below are not vacuous.
    [[ "$log" == *"diff-index --cached --quiet"* ]]
    [[ "$log" != *"write-tree"* ]]
    # The environment sentinel. GIT_INDEX_FILE travels in the environment rather than
    # the argument vector, so redirecting the index would be invisible in the argv log
    # alone; the stub logs it separately and only when it is set.
    [[ "$log" != *"stub-git-env"* ]]
    [[ "$log" != *"/index"* ]]
    ! printf '%s\n' "$log" | grep -qE '(^| )reset( |$)'
    ! printf '%s\n' "$log" | grep -qE '(^| )clean( |$)'
    [[ "$log" != *"worktree remove"* ]]
    [[ "$log" != *"branch -D"* ]]
    [[ "$log" != *"hash-object -w"* ]]
}

@test "dirt_staged_tree_is_commit: the cached diff-index probe runs and every status read suppresses optional locks" {
    report_run dirt_staged_tree_is_commit
    log="$(argv_log)"
    [[ "$log" == *"diff-index --cached --quiet"* ]]
    # Every logged status read carries --no-optional-locks on the same line. Under the
    # run_report driver the only status --porcelain invocation is the new library's;
    # remove_worktree_safe's unqualified read is on the deletion path, which this driver
    # never reaches, and that call site is textually unmodified by this change.
    status_reads="$(printf '%s\n' "$log" | grep 'status --porcelain' || true)"
    [ -n "$status_reads" ]
    [ "$(printf '%s\n' "$status_reads" | grep -c -- '--no-optional-locks')" -eq "$(printf '%s\n' "$status_reads" | grep -c 'status --porcelain')" ]
}
