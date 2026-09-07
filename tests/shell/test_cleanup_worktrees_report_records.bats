#!/usr/bin/env bats
# Report-record unit tests for scripts/bash/cleanup_worktrees_report_records_lib.sh.
# Each scan function is driven under the checked-in git stub and the checked-in
# filesystem-scan stub, against scenario fixtures in
# tests/fixtures/cleanup_worktrees/scenarios/, as a positive/negative pair. Every
# fixture supplies exactly one canned record per shape, so no assertion is tied to a
# historical count of orphan directories or stale refs. No temporary files; no scratch
# git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    RLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_report_records_lib.sh"
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
