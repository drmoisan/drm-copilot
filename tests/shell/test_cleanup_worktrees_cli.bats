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
    SCAN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/scan"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    chmod +x "${STUB}" 2>/dev/null || true
    chmod +x "${SCAN}" 2>/dev/null || true
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
    # The scan seam is supplied here for the same reason the git seam is: without it the
    # wrapper would read the real filesystem, making this test depend on the machine's
    # worktree layout.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_with_worktree" \
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
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_with_worktree" \
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
    # Source in a subshell so the wrapper's `set -euo pipefail` cannot abort the
    # outer shell before the marker is printed; then assert the observable contract:
    # sourcing prints no report or usage output (main did not run).
    run bash -c "( source '${WRAPPER}' ) 2>/dev/null; echo GUARD_OK"
    [ "$status" -eq 0 ]
    [[ "$output" == *"GUARD_OK"* ]]
    [[ "$output" != *"BRANCH|"* ]]
    [[ "$output" != *"WORKTREE|"* ]]
    [[ "$output" != *"Usage: cleanup-worktrees.sh"* ]]
}

@test "--help documents the detached worktree record" {
    # The usage text must document the detached worktree record and its state
    # vocabulary. ANCESTRY_ERROR is the asserted token because it is a bracket-free,
    # single-line literal and therefore survives reflow of the surrounding paragraph.
    run bash "${WRAPPER}" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"ANCESTRY_ERROR"* ]]
    # ac22-record-literal: AC22 names the five-field detached record itself, so the record literal is asserted in addition to its state vocabulary.
    [[ "$output" == *"WORKTREE|<path>|DETACHED|<state>|<flags>"* ]]
}

@test "--help documents the apply-mode exit-code change for blocked detached removals" {
    # A blocked detached removal makes apply mode exit non-zero where the same checkout
    # previously exited 0. BLOCKED-REVERIFY is the asserted token because it is the one
    # blocked result the usage text did not already name and it is bracket-free and
    # single-line, so it survives reflow of the surrounding paragraph.
    run bash "${WRAPPER}" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"BLOCKED-REVERIFY"* ]]
}

@test "--clear-disposable without a mode argument prints usage to stderr and exits 2" {
    # `2>&1 1>/dev/null` discards stdout and routes stderr to the captured stream, so
    # this asserts the usage text reached STDERR specifically rather than merely
    # appearing somewhere in the merged output. The flag is destructive and apply-mode
    # only, so supplying it alone is a usage error rather than a silently ignored no-op:
    # an operator who typed it expects clearing to happen.
    run bash -c "CLEANUP_WT_GIT_BIN='${STUB}' CLEANUP_WT_SCAN_BIN='${SCAN}' CLEANUP_WT_STUB_SCENARIO='${SCEN}/merged_with_worktree' bash '${WRAPPER}' --clear-disposable 2>&1 1>/dev/null"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage: cleanup-worktrees.sh"* ]]
    # The usage text printed on this rejection must document the flag the operator just
    # supplied. This also distinguishes a deliberate rejection by the flag pre-pass from
    # the wrapper's pre-existing unknown-argument arm, which produces the same exit code
    # and the same usage text for any unrecognised word.
    [[ "$output" == *"--clear-disposable"* ]]
}

@test "report --clear-disposable prints usage to stderr and exits 2" {
    # Report mode performs no mutation of any kind, so pairing it with the clearing flag
    # is the same usage error as supplying the flag with no mode at all.
    #
    # The stub seams are wired here for the same reason they are wired in the other
    # scenario-driven tests: without them a wrapper that dispatched to report mode would
    # read the machine's real repository, which is neither deterministic nor fast. With
    # them, a wrapper that failed to reject this argument pair emits the stub argv log
    # and no usage text, which is what makes the assertion below able to fail.
    run bash -c "CLEANUP_WT_GIT_BIN='${STUB}' CLEANUP_WT_SCAN_BIN='${SCAN}' CLEANUP_WT_STUB_SCENARIO='${SCEN}/merged_with_worktree' bash '${WRAPPER}' report --clear-disposable 2>&1 1>/dev/null"
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage: cleanup-worktrees.sh"* ]]
    [[ "$output" == *"--clear-disposable"* ]]
    [[ "$output" != *"stub-git:"* ]]
}

@test "--apply --clear-disposable and --clear-disposable --apply both dispatch to apply mode" {
    # Precondition: the flag's behavior depends on the dirt library the wrapper sources,
    # so its absence would make this test pass for the wrong reason.
    [ -f "${DIRTLIB}" ]
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_with_worktree" \
        bash "${WRAPPER}" --apply --clear-disposable
    [ "$status" -eq 0 ]
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/feat|OK"* ]]
    [[ "$output" != *"Usage: cleanup-worktrees.sh"* ]]
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/merged_with_worktree" \
        bash "${WRAPPER}" --clear-disposable --apply
    [ "$status" -eq 0 ]
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/feat|OK"* ]]
    [[ "$output" != *"Usage: cleanup-worktrees.sh"* ]]
}

@test "--help output documents the new flag and both new record prefixes" {
    run bash "${WRAPPER}" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"--clear-disposable"* ]]
    [[ "$output" == *"DIRTFILE|"* ]]
    [[ "$output" == *"DIRTSUM|"* ]]
}
