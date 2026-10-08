#!/usr/bin/env bats
# Report-record unit tests for .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh.
# Each scan function is driven under the checked-in git stub and the checked-in
# filesystem-scan stub, against scenario fixtures in
# tests/fixtures/cleanup_worktrees/scenarios/, as a positive/negative pair. Every
# fixture supplies exactly one canned record per shape, so no assertion is tied to a
# historical count of orphan directories or stale refs. No temporary files; no scratch
# git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_lib.sh"
    RLIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh"
    DLIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh"
    DIRTLIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_dirt_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCAN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/scan"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    # Checked-in stubs may lose the executable bit on some platforms; make runnable.
    chmod +x "${STUB}" 2>/dev/null || true
    chmod +x "${SCAN}" 2>/dev/null || true
}

rr() { # rr <scenario> <function-invocation> -> run a report-record function
    # Both stubs log nothing to stdout beyond their canned data; stderr is discarded so
    # $output is the function's report lines only (bats `run` otherwise merges stderr).
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}' && source '${RLIB}' && $2 2>/dev/null"
}

report_raw() { # report_raw <scenario> -> run the full report driver, stderr RETAINED
    # Unlike rr() this helper carries NO 2>/dev/null redirection. The scan stub writes one
    # `stub-scan: <argv>` line to stderr per invocation and bats `run` merges stderr into
    # $output, and that retained stderr is what makes the number of filesystem-scan
    # invocations assertable. run_report also calls the classification driver and the
    # detached reporter, so LIB and DLIB must be sourced alongside ELIB and RLIB.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${DIRTLIB}' && source '${RLIB}' && source '${DLIB}' && run_report"
}

@test "scan_stale_refs emits STALE_REF for a remote-tracking ref with no configured remote" {
    # refs/remotes/upstream/* exists but `git remote` lists only origin, so the whole
    # upstream tracking namespace is a leftover. The remote is deliberately named
    # `upstream` rather than `child` to prove the detection is general.
    rr stale_ref_present "scan_stale_refs"
    [ "$status" -eq 0 ]
    [ "$output" = "STALE_REF|refs/remotes/upstream/feature-old" ]
}

@test "scan_stale_refs emits nothing when the remote exists" {
    # Identical to the positive fixture except that `git remote` also lists upstream.
    rr stale_ref_absent "scan_stale_refs"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "scan_orphan_dirs emits ORPHAN_DIR for an unregistered, .git-less directory" {
    # The scanned directory carries no .git pointer file (has_gitfile 0) and the
    # porcelain worktree listing does not name it, so it is worktree residue.
    rr orphan_dir_present "scan_orphan_dirs"
    [ "$status" -eq 0 ]
    [ "$output" = "ORPHAN_DIR|.claude/worktrees/agent-old|128K" ]
}

@test "scan_orphan_dirs emits nothing for a registered worktree directory" {
    # The scanned directory carries a resolving .git pointer file and IS named by the
    # porcelain worktree listing, so it is a live worktree, not an orphan.
    rr orphan_dir_absent "scan_orphan_dirs"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "scan_registration_loss emits WARN|registration-lost for a broken gitdir pointer" {
    # has_gitfile 1 with gitdir_target_exists 0: the directory still looks like a
    # worktree but the administrative entry it points at is gone.
    rr registration_lost_present "scan_registration_loss"
    [ "$status" -eq 0 ]
    [ "$output" = "WARN|registration-lost|/repo-wt/half-gone" ]
}

@test "scan_registration_loss emits nothing when the gitdir pointer resolves" {
    # has_gitfile 1 with gitdir_target_exists 1: an intact registration.
    rr registration_lost_absent "scan_registration_loss"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "cleanup_wt_scan_roots derives both roots from the main worktree path" {
    # The scenario's worktree-list.out names /repo/main as its first porcelain stanza, so
    # both roots are derived from that one path and neither is relative to the process's
    # current working directory.
    rr orphan_dir_present "cleanup_wt_scan_roots"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "/repo/main/.claude/worktrees" ]
    [ "${lines[1]}" = "/repo/main-wt" ]
}

@test "cleanup_wt_scan_roots honors the CLEANUP_WT_ORPHAN_ROOTS override" {
    # The colon-separated override replaces the derivation entirely, so neither root is
    # read from the worktree listing when it is set.
    rr orphan_dir_present "CLEANUP_WT_ORPHAN_ROOTS=/a/one:/b/two cleanup_wt_scan_roots"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "/a/one" ]
    [ "${lines[1]}" = "/b/two" ]
}

@test "cleanup_wt_scan_roots emits no root when the worktree listing hard-fails" {
    # worktree_list_error supplies worktree-list.rc, so parse_worktree_list hard-fails and
    # the main worktree path is unresolvable. Both roots derive from that path, so the
    # advisory records degrade to silence rather than to a misleading CWD-relative scan.
    rr worktree_list_error "cleanup_wt_scan_roots"
    [ "$output" = "" ]
}

@test "run_report performs exactly one filesystem scan" {
    # R-02 gate. Both scan-derived records below come from a single
    # cleanup_wt_scan_records invocation, which is what makes scan_registration_loss's
    # "one consistent view of the filesystem" docstring true. report_raw retains stderr,
    # so the scan stub's one-line-per-invocation argv log is countable in $output.
    report_raw report_single_scan
    [ "$status" -eq 0 ]
    [[ "$output" == *"ORPHAN_DIR|/repo/main/.claude/worktrees/agent-old|128K"* ]]
    [[ "$output" == *"WARN|registration-lost|/repo/main-wt/half-gone"* ]]
    # grep -c exits 1 on a zero count; neutralize it so the assertion reports the count.
    scan_calls=$(printf '%s\n' "$output" | grep -c 'stub-scan: scan-dirs' || true)
    [ "$scan_calls" -eq 1 ]
}

# rr() sources only ELIB and RLIB and therefore cannot run the classification driver,
# which calls classify_branch (LIB) and the dirt reads (DIRTLIB); this helper sources all four.
classify_all_rr() { # classify_all_rr <scenario> -> run classify_all_branches with stderr retained
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${DIRTLIB}' && source '${RLIB}' && classify_all_branches"
}

ladder_rr() { # ladder_rr <scenario> <branch> -> run classify_branch for one branch, stderr discarded
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${DIRTLIB}' && source '${DLIB}' && classify_branch '$2' 2>/dev/null"
}

# The redefinitions occur after sourcing, so run_report_scans calls the stand-ins. That
# reaches the rc-maximization statements, which the real scans cannot reach when given
# pre-scanned records.
rs_override() { # rs_override <scenario> <orphan-rc> <registration-rc> -> run run_report_scans with both record scans replaced
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}' && source '${RLIB}'; scan_orphan_dirs() { return $2; }; scan_registration_loss() { return $3; }; run_report_scans 2>/dev/null"
}

@test "classify_all_branches: a hard pairwise probe failure returns rc 2 and emits no CHILD_OF record" {
    # child_of_pairwise_probe_error is child_of_not_merged plus
    # merge-base.feature-child.feature-parent.rc = 128. Only the pairwise probe reads that
    # pair key, and both branches resolve NOT_MERGED, so rc 2 can only come from the probe.
    classify_all_rr child_of_pairwise_probe_error
    [ "$status" -eq 2 ]
    [[ "$output" == *"BRANCH|feature-child|NOT_MERGED"* ]]
    [[ "$output" == *"BRANCH|feature-parent|NOT_MERGED"* ]]
    [[ "$output" != *"CHILD_OF|"* ]]
    [[ "$output" != *"ANCESTRY_ERROR"* ]]
}

@test "classify_all_branches: a hard pairwise probe failure leaves each BRANCH record identical to the classify_branch record" {
    # Comparing the same branch under the same scenario is what lets the assertion fail.
    classify_all_rr child_of_pairwise_probe_error
    [ "$status" -eq 2 ]
    driver_child=$(printf '%s\n' "$output" | grep '^BRANCH|feature-child|' || true)
    driver_parent=$(printf '%s\n' "$output" | grep '^BRANCH|feature-parent|' || true)
    ladder_rr child_of_pairwise_probe_error feature-child
    [ "$status" -eq 0 ]
    ladder_child=$(printf '%s\n' "$output" | grep '^BRANCH|feature-child|' || true)
    ladder_rr child_of_pairwise_probe_error feature-parent
    [ "$status" -eq 0 ]
    ladder_parent=$(printf '%s\n' "$output" | grep '^BRANCH|feature-parent|' || true)
    [ "$driver_child" = "$ladder_child" ]
    [ "$driver_parent" = "$ladder_parent" ]
    [ "$driver_child" = "BRANCH|feature-child|NOT_MERGED" ]
    [ "$driver_parent" = "BRANCH|feature-parent|NOT_MERGED" ]
}

@test "run_report_scans: a failed filesystem scan returns the scan rc and emits no scan-derived record" {
    # The scan stub replays one orphan-shaped record and exits 3, so the partial output
    # must be discarded and the scan exit code returned.
    rr report_scans_scan_failure "run_report_scans"
    [ "$status" -eq 3 ]
    [ "$output" = "" ]
}

@test "run_report_scans: a stale-ref failure with a higher rc than a failed scan returns the stale-ref rc" {
    # The scan exits 3 and the stale-ref read exits 5, so the larger code is returned.
    rr report_scans_scan_failure_git_higher "run_report_scans"
    [ "$status" -eq 5 ]
    [ "$output" = "" ]
}

@test "run_report_scans: a stale-ref failure after a successful scan returns its rc and keeps the scan records" {
    # The scan succeeds and the stale-ref read exits 4, so the success path returns 4 and
    # still emits the orphan record.
    rr report_scans_stale_ref_failure "run_report_scans"
    [ "$status" -eq 4 ]
    [ "$output" = "ORPHAN_DIR|.claude/worktrees/agent-old|128K" ]
}

@test "run_report_scans: the orphan-directory scan rc is returned when it is the maximum" {
    # The orphan scan returns 7 and the registration scan returns 0.
    rs_override report_single_scan 7 0
    [ "$status" -eq 7 ]
}

@test "run_report_scans: the registration-loss scan rc is returned when it is the maximum" {
    # The orphan scan returns 7 and the registration scan returns 9.
    rs_override report_single_scan 7 9
    [ "$status" -eq 9 ]
}

@test "run_report_scans: an earlier larger scan rc is kept when a later scan returns a smaller one" {
    # The orphan scan returns 9 and the registration scan returns 7, so the later smaller
    # code must not replace the earlier larger one.
    rs_override report_single_scan 9 7
    [ "$status" -eq 9 ]
}
