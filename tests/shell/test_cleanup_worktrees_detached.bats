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

report() { # report <scenario-dir> -> run the report driver under that scenario
    # Each source is joined to the next command by `&&`: an absent library must abort the
    # chain before the driver call rather than degrade to a partial run. run_report calls
    # the report-record functions and the shared classification driver, so the sibling
    # library must be sourced here (bats subshells source the libraries directly and never
    # run the CLI wrapper) and the filesystem scan must route through the checked-in scan
    # stub rather than reading the real .claude/worktrees tree.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${DIRTLIB}' && source '${RLIB}' && source '${ALIB}' && source '${DLIB}' && run_report"
}

runin() { # runin <scenario-dir> <invocation> -> run an arbitrary invocation under it
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${DIRTLIB}' && source '${RLIB}' && source '${ALIB}' && source '${DLIB}' && $2"
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
    # locked-exit-code-propagation: the locked path is the primary source of the documented apply-mode exit-code change, so the non-zero status is asserted here.
    [ "$status" -ne 0 ]
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

@test "report emits MERGED_CONTENT_NEUTRAL for a content-neutral detached HEAD" {
    # Ladder rung 2: the HEAD is not an ancestor of main (merge-base rc 1) but adds no net
    # content versus main (diff --quiet rc 0). This is the first case in the suite to
    # produce the MERGED_CONTENT_NEUTRAL verdict, which is on the delete-eligible allowlist.
    report "${SCEN}/detached_content_neutral"
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|MERGED_CONTENT_NEUTRAL|detached"* ]]
    [[ "$output" != *"MERGED_CLEAN"* ]]
}

@test "apply removes a content-neutral detached worktree without force" {
    # The first test in this repository to drive the destructive path from a
    # MERGED_CONTENT_NEUTRAL verdict. The scenario carries no worktree-remove.rc, so the
    # stub's removal exits 0 and remove_worktree_safe reports OK.
    runin "${SCEN}/detached_content_neutral" run_apply
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/det|OK"* ]]
    [[ "$output" == *"worktree remove /repo-wt/det"* ]]
    [[ "$output" != *"--force"* ]]
    [[ "$output" != *"worktree prune"* ]]
}

@test "report emits MERGED_EQUIVALENT for a cherry-equivalent detached HEAD" {
    # Ladder rung 3: a single patch-id-equivalent `- <sha>` cherry line leaves the residual
    # list empty, so classify_cherry_equivalent returns the single MERGED_EQUIVALENT line.
    report "${SCEN}/detached_equivalent"
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|MERGED_EQUIVALENT|detached"* ]]
    [[ "$output" != *"MERGED_CLEAN"* ]]
}

@test "apply removes a cherry-equivalent detached worktree without force" {
    # The first test in this repository to drive the destructive path from a
    # MERGED_EQUIVALENT verdict, the third and last entry on the delete-eligible allowlist.
    runin "${SCEN}/detached_equivalent" run_apply
    [[ "$output" == *"ACTION|worktree-remove|/repo-wt/det|OK"* ]]
    [[ "$output" == *"worktree remove /repo-wt/det"* ]]
    [[ "$output" != *"--force"* ]]
    [[ "$output" != *"worktree prune"* ]]
}

@test "report emits HAS_UNIQUE_RESIDUALS for a partially incorporated detached HEAD" {
    # Ladder rung 5: one residual `+` commit whose touched path holds a different blob on
    # main is UNIQUE, and the `- <sha>` cherry line supplies the MINUS_PRESENT partial-merge
    # signal that separates HAS_UNIQUE_RESIDUALS from NOT_MERGED.
    report "${SCEN}/detached_unique_residuals"
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|HAS_UNIQUE_RESIDUALS|detached"* ]]
    # HAS_UNIQUE_RESIDUALS is not on the delete-eligible allowlist. The apply-mode run is
    # what proves the non-eligible terminal blocks the destructive path, rather than the
    # report line merely naming a state.
    runin "${SCEN}/detached_unique_residuals" run_apply
    [[ "$output" != *"ACTION|worktree-remove"* ]]
    [[ "$output" != *"worktree remove"* ]]
}

@test "classify_detached_head returns MERGED_EQUIVALENT when every residual is content-on-main" {
    # Ladder rung 4, the second MERGED_EQUIVALENT producer: the cherry rung leaves one
    # residual `+` commit, and that commit's single touched path resolves to the same blob
    # OID on the HEAD and on main, so the residual is CONTENT_ON_MAIN and the unique count
    # stays at zero. Substring form, not equality, because the helper retains stderr and the
    # stub writes one `stub-git: ` argv line per invocation.
    runin "${SCEN}/detached_equivalent_residual" "classify_detached_head det00011 /repo-wt/det"
    [ "$status" -eq 0 ]
    [[ "$output" == *"MERGED_EQUIVALENT"* ]]
    [[ "$output" != *"HAS_UNIQUE_RESIDUALS"* ]]
}

@test "a protection-set hard failure fails closed as ANCESTRY_ERROR" {
    # compute_protected hard-fails (rev-parse --abbrev-ref HEAD exits 128). The guard must
    # fire before the ancestry rung, so a weakened (empty) protected set can never let a
    # candidate reach a delete-eligible verdict. The scenario deliberately carries no
    # merge-base key for this HEAD, so reaching the ancestry rung at all would be visible.
    runin "${SCEN}/detached_protection_error" "classify_detached_head det00012 /repo-wt/det"
    [ "$status" -eq 2 ]
    [[ "$output" == *"ANCESTRY_ERROR"* ]]
    [[ "$output" != *"MERGED_"* ]]
    report "${SCEN}/detached_protection_error"
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|ANCESTRY_ERROR|detached"* ]]
    runin "${SCEN}/detached_protection_error" run_apply
    [[ "$output" != *"worktree remove"* ]]
    [ "$status" -ne 0 ]
}

@test "a content-neutral probe hard failure fails closed as ANCESTRY_ERROR" {
    # `git diff --quiet main...<head>` exits 128, which classify_content_neutral reports as
    # CONTENT_NEUTRAL_ERROR and classify_detached_head maps to ANCESTRY_ERROR, never to
    # MERGED_CONTENT_NEUTRAL.
    runin "${SCEN}/detached_content_neutral_error" "classify_detached_head det00013 /repo-wt/det"
    [ "$status" -eq 2 ]
    [[ "$output" == *"ANCESTRY_ERROR"* ]]
    [[ "$output" != *"MERGED_"* ]]
    report "${SCEN}/detached_content_neutral_error"
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|ANCESTRY_ERROR|detached"* ]]
    runin "${SCEN}/detached_content_neutral_error" run_apply
    [[ "$output" != *"worktree remove"* ]]
    [ "$status" -ne 0 ]
}

@test "a cherry hard failure fails closed as ANCESTRY_ERROR" {
    # `git cherry main <head>` exits 128, which classify_cherry_equivalent reports as
    # CHERRY_ERROR and classify_detached_head maps to ANCESTRY_ERROR, never to
    # MERGED_EQUIVALENT. A failed cherry read must not be mistaken for "all residuals
    # equivalent".
    runin "${SCEN}/detached_cherry_error" "classify_detached_head det00014 /repo-wt/det"
    [ "$status" -eq 2 ]
    [[ "$output" == *"ANCESTRY_ERROR"* ]]
    [[ "$output" != *"MERGED_"* ]]
    report "${SCEN}/detached_cherry_error"
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|ANCESTRY_ERROR|detached"* ]]
    runin "${SCEN}/detached_cherry_error" run_apply
    [[ "$output" != *"worktree remove"* ]]
    [ "$status" -ne 0 ]
}

@test "a diff-tree hard failure fails closed as ANCESTRY_ERROR" {
    # Direct invocation only. The stub answers `cherry` from one key per sha, so a single
    # scenario cannot make both `cherry` and `diff-tree` fail for the same sha; det00015 is
    # a second key set hosted inside the same directory and is deliberately absent from that
    # scenario's worktree-list.out, which leaves /repo-wt/det2 merely unprotected.
    # classify_cherry_equivalent reports the failed diff-tree probe as DIFF_TREE_ERROR, and
    # classify_detached_head maps it to ANCESTRY_ERROR rather than to a droppable empty diff.
    runin "${SCEN}/detached_cherry_error" "classify_detached_head det00015 /repo-wt/det2"
    [ "$status" -eq 2 ]
    [[ "$output" == *"ANCESTRY_ERROR"* ]]
    [[ "$output" != *"MERGED_"* ]]
}

@test "a residual ls-tree hard failure fails closed as ANCESTRY_ERROR" {
    # The D-rung `git ls-tree main -- <path>` probe exits 128, which classify_residual_commit
    # reports as RESIDUAL_ERROR and classify_detached_head maps to ANCESTRY_ERROR. A hard
    # ls-tree failure must stay distinct from a path legitimately absent on main.
    runin "${SCEN}/detached_residual_error" "classify_detached_head det00016 /repo-wt/det"
    [ "$status" -eq 2 ]
    [[ "$output" == *"ANCESTRY_ERROR"* ]]
    [[ "$output" != *"MERGED_"* ]]
    report "${SCEN}/detached_residual_error"
    [[ "$output" == *"WORKTREE|/repo-wt/det|DETACHED|ANCESTRY_ERROR|detached"* ]]
    runin "${SCEN}/detached_residual_error" run_apply
    [[ "$output" != *"worktree remove"* ]]
    [ "$status" -ne 0 ]
}

@test "reverify_detached_delete_eligible blocks on a classification hard failure" {
    # The hard-failure branch of the re-verification gate, which is distinct from the
    # allowlist-miss branch covered by "reverify_detached_delete_eligible blocks on a
    # flipped verdict": here classify_detached_head returns non-zero rather than returning 0
    # with a non-eligible state token.
    runin "${SCEN}/detached_content_neutral_error" "reverify_detached_delete_eligible det00013 /repo-wt/det"
    [ "$status" -eq 1 ]
    [[ "$output" == *"BLOCKED-REVERIFY"* ]]
    [[ "$output" != *"worktree remove"* ]]
}
