#!/usr/bin/env bats
# Byte-identity regression pins for the dirt classifier (issue #632).
#
# This suite is a PIN, not an expect-fail suite: it must pass both before the
# classifier lands and after. It asserts that adding per-file dirt verdicts to report
# mode changes no existing record for a worktree that carries no dirt, and changes no
# apply-mode record at all when --clear-disposable is absent.
#
# The reference files under tests/fixtures/cleanup_worktrees/expected/ were captured
# from the unmodified libraries before the classifier existed, which is what makes the
# comparison able to fail.
#
# Every driver here discards stderr inside the subshell. The reference files are
# stdout-only captures, whereas the git stub writes its `stub-git:` argv log to stderr
# and bats `run` merges stderr into $output; a comparison that did not discard stderr
# would compare the reference bytes against stdout plus the log and could never report
# identity.
#
# The filesystem-scan seam is wired to the checked-in scan stub for the same reason the
# git seam is: run_report_scans otherwise reads the machine's real .claude/worktrees
# tree, which would make these comparisons depend on the machine. No temporary files;
# no scratch git repositories.

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
    EXP="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/expected"
    chmod +x "${STUB}" 2>/dev/null || true
    chmod +x "${SCAN}" 2>/dev/null || true
}

report_identical() { # report_identical <scenario>
    # Run run_report under <scenario> and assert its stdout matches the checked-in
    # reference byte for byte, and that it carries neither new record type.
    local s="$1"
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/${s}" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${RLIB}'; source '${DLIB}'; run_report 2>/dev/null"
    [ "$output" = "$(cat "${EXP}/report.${s}.out")" ]
    [[ "$output" != *"DIRTFILE|"* ]]
    [[ "$output" != *"DIRTSUM|"* ]]
}

apply_identical() { # apply_identical <scenario>
    # Run run_apply under <scenario> WITHOUT CLEANUP_WT_CLEAR_DISPOSABLE and assert the
    # stdout matches the checked-in reference. The variable is deliberately not set:
    # default apply-mode behavior is exactly what this comparison pins.
    local s="$1"
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/${s}" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${RLIB}'; source '${ALIB}'; source '${DLIB}'; run_apply 2>/dev/null"
    [ "$output" = "$(cat "${EXP}/apply.${s}.out")" ]
    [[ "$output" != *"DIRTFILE|"* ]]
    [[ "$output" != *"DIRTSUM|"* ]]
}

@test "report mode output for merged_with_worktree is byte-identical to the checked-in expected output" {
    report_identical merged_with_worktree
}

@test "report mode output for merged_no_worktree is byte-identical to the checked-in expected output" {
    report_identical merged_no_worktree
}

@test "report mode output for unmerged is byte-identical to the checked-in expected output" {
    report_identical unmerged
}

@test "report mode output for content_neutral is byte-identical to the checked-in expected output" {
    report_identical content_neutral
}

@test "report mode output for residual_on_main is byte-identical to the checked-in expected output" {
    report_identical residual_on_main
}

@test "report mode output for residual_unique_doc is byte-identical to the checked-in expected output" {
    report_identical residual_unique_doc
}

@test "report mode output for current_exclusion is byte-identical to the checked-in expected output" {
    report_identical current_exclusion
}

@test "report mode output for main_divergence is byte-identical to the checked-in expected output" {
    report_identical main_divergence
}

@test "apply mode without --clear-disposable over dirty_worktree is byte-identical" {
    apply_identical dirty_worktree
    # The two records the acceptance criterion names explicitly: the three-field DIRTY|
    # shape and the blocked removal are both retained unchanged.
    [[ "$output" == *"DIRTY|/repo-wt/dirty|?? untracked-artifact.txt"* ]]
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/dirty|BLOCKED-DIRTY"* ]]
}

@test "apply mode without --clear-disposable over dirty_worktree_status_error is byte-identical" {
    apply_identical dirty_worktree_status_error
}

@test "report mode over a worktree with zero status entries emits no DIRTFILE or DIRTSUM record" {
    # Asserted over the LIVE run_report stdout, not over the checked-in reference file.
    # An assertion over the reference would be reading bytes captured before the
    # classifier existed and could therefore never fail. merged_with_worktree registers
    # the non-main worktree /repo-wt/feat and supplies no status fixture for it, so the
    # classifier's status read returns empty; this test fails if the implementation
    # emits an aggregate for a worktree whose status read returned nothing. It carries
    # the DIRTSUM| half of the zero-entry rule.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_with_worktree" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${RLIB}'; source '${DLIB}'; run_report 2>/dev/null"
    [ "$status" -eq 0 ]
    # Positive control: the candidate registration whose status read returned nothing is
    # present in the output, so the two negative assertions below are not vacuous.
    [[ "$output" == *"WORKTREE|/repo-wt/feat|feature-wt|"* ]]
    [[ "$output" != *"DIRTFILE|"* ]]
    [[ "$output" != *"DIRTSUM|"* ]]
}

@test "report mode over dirty_worktree_status_error returns the status read exit code and emits no dirt record" {
    # Decision A. classify_worktree_dirt returns the status read's exit code on a hard
    # failure and run_report propagates it, so report mode exits non-zero here where the
    # pre-classifier tree exited 0. That is deliberate: the worktree produces no dirt
    # records at all, so a report that also exited 0 could not be told apart from a report
    # about a clean worktree, and an operator would decide a deletion on incomplete data.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/dirty_worktree_status_error" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; source '${RLIB}'; source '${DLIB}'; run_report 2>/dev/null"
    [ "$status" -eq 128 ]
    # Positive control: the registration whose status read failed is present in the report,
    # so the two absence assertions below are not passing merely because nothing ran.
    [[ "$output" == *"WORKTREE|/repo-wt/dirty|feature-dirty|"* ]]
    [[ "$output" != *"DIRTFILE|"* ]]
    [[ "$output" != *"DIRTSUM|"* ]]
}
