#!/usr/bin/env bats
# Detached-HEAD worktree unit tests for scripts/bash/cleanup_worktrees_detached_lib.sh.
# Drives run_report, run_apply, and the new detached functions through the checked-in
# git stub, asserting the five-field detached registration record, the per-HEAD
# classification verdicts, protection of the caller's own worktree, the locked and
# prunable short-circuits, the same-process re-verification gate, and the absence of any
# forced or pruning removal argv. Fixtures live under
# tests/fixtures/cleanup_worktrees/scenarios/. No temporary files; no scratch git
# repositories.
#
# Both helpers below deliberately RETAIN stderr: the stub echoes each invocation as a
# `stub-git: <argv>` line to stderr, bats merges stderr into $output, and that merge is
# what makes the negative argv assertions (no `worktree remove`, no `--force`, no
# `worktree prune`) meaningful. The same merge is why every verdict assertion is written
# in substring form rather than as an equality test against a bare token.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    ALIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_actions_lib.sh"
    DLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_detached_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    chmod +x "${STUB}" 2>/dev/null || true
}

report() { # report <scenario-dir> -> run the report driver under that scenario
    # Each source is joined to the next command by `&&`: an absent library must abort the
    # chain before the driver call rather than degrade to a partial run.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${DLIB}' && run_report"
}

runin() { # runin <scenario-dir> <invocation> -> run an arbitrary invocation under it
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${DLIB}' && $2"
}

@test "report emits one detached record with MERGED_CLEAN" {
    report "${SCEN}/detached_merged"
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|MERGED_CLEAN|detached"* ]]
    # The detached emission replaces the branch-backed record; it does not add a second
    # registration line for the same path.
    det_lines=$(printf '%s\n' "$output" | grep -c '^WORKTREE|/repo-wt/det' || true)
    [ "$det_lines" -eq 1 ]
    # The main worktree is never a detached candidate.
    [[ "$output" != *"WORKTREE|/repo/main|DETACHED|"* ]]
}

@test "report emits NOT_MERGED for an unmerged detached HEAD" {
    report "${SCEN}/detached_unmerged"
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|NOT_MERGED"* ]]
}

@test "is_detached_candidate flag matrix" {
    # A pure string predicate over the porcelain flag field; it makes no git call. The
    # scenario directory is immaterial here and is named only to keep the invocation
    # reproducible.
    runin "${SCEN}/detached_merged" "is_detached_candidate 'detached'"
    [ "$status" -eq 0 ]
    runin "${SCEN}/detached_merged" "is_detached_candidate 'detached,locked'"
    [ "$status" -eq 0 ]
    runin "${SCEN}/detached_merged" "is_detached_candidate 'detached,prunable'"
    [ "$status" -eq 0 ]
    runin "${SCEN}/detached_merged" "is_detached_candidate 'main'"
    [ "$status" -ne 0 ]
    runin "${SCEN}/detached_merged" "is_detached_candidate 'main,bare'"
    [ "$status" -ne 0 ]
    runin "${SCEN}/detached_merged" "is_detached_candidate 'main,detached'"
    [ "$status" -ne 0 ]
    runin "${SCEN}/detached_merged" "is_detached_candidate 'prunable'"
    [ "$status" -ne 0 ]
    runin "${SCEN}/detached_merged" "is_detached_candidate ''"
    [ "$status" -ne 0 ]
}

@test "branch-backed worktree records keep the four-field shape" {
    # The four-field regression guard for this suite: adding the detached path must not
    # change the shape of a branch-backed registration record.
    report "${SCEN}/merged_with_worktree"
    [[ "$output" == *"WORKTREE|/repo-wt/feat|feature-wt|"* ]]
}

@test "apply removes a merged detached worktree without force" {
    runin "${SCEN}/detached_merged" run_apply
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/det|OK"* ]]
    [[ "$output" == *"worktree remove /repo-wt/det"* ]]
    [[ "$output" != *"--force"* ]]
    [[ "$output" != *"worktree prune"* ]]
}

@test "apply never touches an unmerged detached worktree" {
    runin "${SCEN}/detached_unmerged" run_apply
    # The record assertion is what allows this case to fail: both negative assertions
    # below already hold before the implementation lands, because the helper's `&&` chain
    # aborts at the absent detached library before run_apply is ever reached.
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|NOT_MERGED|detached"* ]]
    [[ "$output" != *"worktree remove"* ]]
    [[ "$output" != *"ACTION|worktree-remove"* ]]
}

@test "dirty detached worktree blocks with DIRTY lines" {
    runin "${SCEN}/detached_merged_dirty" run_apply
    [[ "$output" == *"DIRTY|/repo-wt/det|?? untracked-artifact.txt"* ]]
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/det|BLOCKED-DIRTY"* ]]
    [[ "$output" != *"--force"* ]]
    [ "$status" -ne 0 ]
}

@test "locked detached worktree yields BLOCKED-LOCKED and invokes no removal" {
    runin "${SCEN}/detached_locked" run_apply
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/det|BLOCKED-LOCKED"* ]]
    [[ "$output" != *"worktree remove"* ]]
    [[ "$output" != *"worktree prune"* ]]
}

@test "prunable detached worktree is report-only" {
    report "${SCEN}/detached_prunable"
    printf '%s\n' "$output" | grep -q '^WORKTREE|/repo-wt/det|DETACHED|'
    runin "${SCEN}/detached_prunable" run_apply
    [[ "$output" != *"ACTION|worktree-remove"* ]]
    [[ "$output" != *"worktree remove"* ]]
    [[ "$output" != *"worktree prune"* ]]
}

@test "the caller's own detached worktree is PROTECTED_CURRENT" {
    report "${SCEN}/detached_current"
    [[ "$output" == *"WORKTREE|/repo-wt/current|DETACHED|PROTECTED_CURRENT"* ]]
    # Protection short-circuits before the ancestry rung, so no ancestry probe for this
    # HEAD appears in the stub argv log.
    [[ "$output" != *"merge-base --is-ancestor det00005"* ]]
    runin "${SCEN}/detached_current" run_apply
    [[ "$output" != *"ACTION|worktree-remove"* ]]
}

@test "a hard git failure maps to ANCESTRY_ERROR with no removal" {
    runin "${SCEN}/detached_ancestry_error" run_apply
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|ANCESTRY_ERROR"* ]]
    [[ "$output" != *"worktree remove"* ]]
    [ "$status" -ne 0 ]
}

@test "classify_detached_head returns MERGED_CLEAN for an ancestor HEAD" {
    # Substring form, not equality: the helper retains stderr and the stub writes one
    # `stub-git: ` argv line per invocation, so $output always carries those lines in
    # addition to the echoed verdict token.
    runin "${SCEN}/detached_merged" "classify_detached_head det00001 /repo-wt/det"
    [ "$status" -eq 0 ]
    [[ "$output" == *"MERGED_CLEAN"* ]]
    [[ "$output" != *"NOT_MERGED"* ]]
}

@test "classify_detached_head returns 2 on a hard failure" {
    # Substring form, not equality, for the same stderr-retention reason.
    runin "${SCEN}/detached_ancestry_error" "classify_detached_head det00006 /repo-wt/det"
    [ "$status" -eq 2 ]
    [[ "$output" == *"ANCESTRY_ERROR"* ]]
    [[ "$output" != *"MERGED_CLEAN"* ]]
}

@test "reverify_detached_delete_eligible blocks on a flipped verdict" {
    runin "${SCEN}/detached_unmerged" "reverify_detached_delete_eligible det00002 /repo-wt/det"
    [[ "$output" == *"BLOCKED-REVERIFY"* ]]
    [ "$status" -eq 1 ]
    [[ "$output" != *"worktree remove"* ]]
}
