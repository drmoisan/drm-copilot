#!/usr/bin/env bats
# Classification-ladder unit tests for scripts/bash/cleanup_worktrees_lib.sh.
# Drives classify_branch and run_report against the checked-in git stub and the
# scenario fixtures under tests/fixtures/cleanup_worktrees/scenarios/, covering the
# six AC8 scenarios plus the ancestry-error and content-neutral rungs. No temporary
# files; no scratch git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    RLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_report_records_lib.sh"
    DLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_detached_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCAN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/scan"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    chmod +x "${STUB}" 2>/dev/null || true
    chmod +x "${SCAN}" 2>/dev/null || true
}

cb() { # cb <scenario> <branch>  -> run classify_branch under that scenario
    # The git stub logs its argv to stderr; discard it so $output is the function's
    # stdout report lines only (bats `run` otherwise merges stderr into $output).
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${DLIB}' && classify_branch '$2' 2>/dev/null"
}

classify_all() { # classify_all <scenario> -> run the shared classification driver
    # Drives classify_all_branches directly, independent of run_report's wiring, so the
    # shared driver's own output can be asserted without run_report's other records.
    #
    # Unlike cb() and report() this helper deliberately carries NO 2>/dev/null
    # redirection: the git stub's `stub-git:` argv log goes to stderr, bats `run` merges
    # stderr into $output, and the tests read that merged log as positive proof that each
    # subject's own ladder ran.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${RLIB}' && classify_all_branches"
}

report() { # report <scenario> -> run the full report driver under that scenario
    # run_report now calls the report-record functions and the shared classification
    # driver, so the sibling library must be sourced here (bats subshells source the
    # libraries directly and never run the CLI wrapper that sources them in production)
    # and the filesystem scan must route through the checked-in scan stub rather than
    # reading the real .claude/worktrees tree.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${RLIB}' && source '${DLIB}' && run_report 2>/dev/null"
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

@test "worktree_list_error: classify_branch reports ANCESTRY_ERROR, never a delete-eligible verdict" {
    # A `git worktree list --porcelain` hard failure weakens the protected set under the
    # fail-open bug, letting feature-x reach MERGED_EQUIVALENT (delete-eligible). The fix
    # must map the hard failure to ANCESTRY_ERROR and return 2, never a MERGED verdict.
    cb worktree_list_error feature-x
    [ "$status" -eq 2 ]
    [ "$output" = "BRANCH|feature-x|ANCESTRY_ERROR" ]
    [[ "$output" != *"MERGED_EQUIVALENT"* ]]
    [[ "$output" != *"MERGED_CLEAN"* ]]
    [[ "$output" != *"MERGED_CONTENT_NEUTRAL"* ]]
}

@test "worktree_list_error: run_report returns non-zero and emits no MERGED or WORKTREE lines" {
    report worktree_list_error
    [ "$status" -ne 0 ]
    [[ "$output" != *"MERGED"* ]]
    [[ "$output" != *"WORKTREE|"* ]]
}

@test "cherry_error: classify_branch reports ANCESTRY_ERROR on a git cherry hard failure" {
    # `git cherry` exits 128 with empty output. The fail-open bug treats an empty cherry
    # result as "all residuals equivalent" -> MERGED_EQUIVALENT. The fix emits the internal
    # CHERRY_ERROR verdict, which classify_branch maps to ANCESTRY_ERROR and return 2.
    cb cherry_error feature-cherryfail
    [ "$status" -eq 2 ]
    [ "$output" = "BRANCH|feature-cherryfail|ANCESTRY_ERROR" ]
    [[ "$output" != *"MERGED_EQUIVALENT"* ]]
}

@test "rev_list_error: classify_branch returns non-zero with no fabricated COMMIT record" {
    # `git rev-list` exits 128 during cherry-pick candidate selection. The fail-open bug
    # loses the rc and returns 0 with the branch left at HAS_UNIQUE_RESIDUALS but no COMMIT
    # record. The fix propagates the hard failure as a non-zero classify_branch return.
    cb rev_list_error feature-revfail
    [ "$status" -ne 0 ]
    [[ "$output" == *"BRANCH|feature-revfail|HAS_UNIQUE_RESIDUALS"* ]]
    [[ "$output" != *"COMMIT|"* ]]
}

@test "child_of_not_merged: CHILD_OF is emitted alongside the branch's own full-ladder verdict" {
    # feature-child is a git ancestor of feature-parent, and both resolve exactly
    # NOT_MERGED through their own unchanged ladders. The driver runs the full ladder for
    # every branch and never substitutes a verdict of its own; the CHILD_OF record names
    # the ancestry relationship between the two branches, not a verdict one of them took
    # from the other. classify_all() does not suppress stderr, so $output carries the
    # stub's `stub-git:` argv log and the subject's own ladder run is provable by its
    # presence in that log.
    classify_all child_of_not_merged
    [ "$status" -eq 0 ]
    [[ "$output" == *"BRANCH|feature-child|NOT_MERGED"* ]]
    [[ "$output" == *"BRANCH|feature-parent|NOT_MERGED"* ]]
    [[ "$output" == *"CHILD_OF|feature-child|feature-parent"* ]]
    # The cherry rung ran for feature-child: its verdict came from its own ladder.
    [[ "$output" == *"cherry main feature-child"* ]]
}

@test "child_of_merged_equivalent: no CHILD_OF is emitted when the ancestor is not NOT_MERGED" {
    # The driver classifies every branch first, then probes only ordered pairs drawn from
    # the set of branches that resolved exactly NOT_MERGED. In this fixture feature-parent
    # resolves MERGED_EQUIVALENT and main resolves PROTECTED_CURRENT, so that set has the
    # single member feature-child; a single-member set yields no ordered pair, and no
    # CHILD_OF record is emitted.
    classify_all child_of_merged_equivalent
    [ "$status" -eq 0 ]
    [[ "$output" == *"BRANCH|feature-parent|MERGED_EQUIVALENT"* ]]
    [[ "$output" == *"BRANCH|feature-child|NOT_MERGED"* ]]
    # feature-child reports the verdict its own ladder produced; the cherry rung ran.
    [[ "$output" == *"cherry main feature-child"* ]]
    # No pair exists, so no branch in this scenario carries a CHILD_OF record.
    [[ "$output" != *"CHILD_OF|"* ]]
}

@test "child_of_ancestry_probe_error: a hard pairwise ancestry failure maps to ANCESTRY_ERROR" {
    # The scenario's merge-base.feature-child.rc value of 128 is consumed by
    # classify_ancestry's own rung-2 probe inside classify_branch, because that probe also
    # falls back to the bare merge-base.feature-child key when no target-aware key exists.
    # A hard git failure must fail closed to ANCESTRY_ERROR and a non-zero driver return,
    # never degrade silently to "not an ancestor". That mapping is unchanged.
    classify_all child_of_ancestry_probe_error
    [ "$status" -ne 0 ]
    [[ "$output" == *"BRANCH|feature-child|ANCESTRY_ERROR"* ]]
}

@test "child_of_not_merged: the driver's BRANCH line equals the ladder's own for the same branch" {
    # Outcome preservation, property (a): for one branch under one fixture, the BRANCH|
    # line the shared driver emits is byte-identical to the line classify_branch produces
    # for that same branch. Comparing the same branch in the same scenario is what makes
    # this assertion able to fail; a comparison against a different branch in a different
    # fixture would hold whatever the driver did.
    classify_all child_of_not_merged
    [ "$status" -eq 0 ]
    driver_line=$(printf '%s\n' "$output" | grep '^BRANCH|feature-child|' || true)
    cb child_of_not_merged feature-child
    [ "$status" -eq 0 ]
    ladder_line=$(printf '%s\n' "$output" | grep '^BRANCH|feature-child|' || true)
    [ "$driver_line" = "$ladder_line" ]
    [ "$driver_line" = "BRANCH|feature-child|NOT_MERGED" ]
}

@test "child_of_subject_merged_clean: the subject's own MERGED_CLEAN verdict is reported" {
    # feature-child is a git ancestor of feature-parent, which resolves exactly
    # NOT_MERGED, but feature-child's own rung-2 ancestry probe resolves it MERGED_CLEAN.
    # This test is the regression guard against reintroducing verdict inheritance at
    # rung 2: a driver that applied feature-parent's NOT_MERGED to feature-child would
    # report a delete-eligible branch as unmerged, and it would never be cleaned up.
    classify_all child_of_subject_merged_clean
    [ "$status" -eq 0 ]
    [[ "$output" == *"BRANCH|feature-child|MERGED_CLEAN"* ]]
    [[ "$output" != *"BRANCH|feature-child|NOT_MERGED"* ]]
    [[ "$output" != *"CHILD_OF|feature-child|"* ]]
    # Driver and ladder agree for the same branch under the same fixture.
    cb child_of_subject_merged_clean feature-child
    [ "$output" = "BRANCH|feature-child|MERGED_CLEAN" ]
}

@test "child_of_subject_content_neutral: the subject's own MERGED_CONTENT_NEUTRAL verdict is reported" {
    # The rung-3 counterexample. feature-child is a git ancestor of the NOT_MERGED
    # feature-parent, but its net diff against main is empty, so its own ladder resolves
    # it MERGED_CONTENT_NEUTRAL at the diff --quiet rung. Being an ancestor of an
    # unmerged branch determines nothing about the subject's own merged-ness.
    classify_all child_of_subject_content_neutral
    [ "$status" -eq 0 ]
    [[ "$output" == *"BRANCH|feature-child|MERGED_CONTENT_NEUTRAL"* ]]
    [[ "$output" != *"BRANCH|feature-child|NOT_MERGED"* ]]
    [[ "$output" != *"CHILD_OF|feature-child|"* ]]
    # Driver and ladder agree for the same branch under the same fixture.
    cb child_of_subject_content_neutral feature-child
    [ "$output" = "BRANCH|feature-child|MERGED_CONTENT_NEUTRAL" ]
}

@test "child_of_subject_merged_equivalent: the subject's own MERGED_EQUIVALENT verdict is reported" {
    # The rung-5 counterexample, and the reason the cut point is "no rungs skipped". The
    # subject's merged-ness is only discoverable at rung 5, which compares the BRANCH
    # TIP's blob against main's. Two branches in an ancestor relationship have different
    # tips, so that comparison cannot be derived from any ancestor's result at any rung:
    # a design that ran rungs 1 through 4 and then inherited would still be wrong here.
    classify_all child_of_subject_merged_equivalent
    [ "$status" -eq 0 ]
    [[ "$output" == *"BRANCH|feature-child|MERGED_EQUIVALENT"* ]]
    [[ "$output" != *"BRANCH|feature-child|NOT_MERGED"* ]]
    [[ "$output" != *"CHILD_OF|feature-child|"* ]]
    # Driver and ladder agree for the same branch under the same fixture.
    cb child_of_subject_merged_equivalent feature-child
    [ "$output" = "BRANCH|feature-child|MERGED_EQUIVALENT" ]
}
