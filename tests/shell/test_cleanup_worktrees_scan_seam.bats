#!/usr/bin/env bats
# Seam unit tests for cleanup_wt_scan_bin in
# scripts/bash/cleanup_worktrees_report_records_lib.sh. The resolver mirrors the
# CLEANUP_WT_GIT_BIN seam's override shape but falls back to the bundled real
# implementation cleanup_worktrees_scan_helper.sh rather than a PATH lookup, so both
# branches are pinned here. No temporary files; no scratch git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    RLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_report_records_lib.sh"
    SCAN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/scan"
    # Checked-in stubs may lose the executable bit on some platforms; make runnable.
    chmod +x "${SCAN}" 2>/dev/null || true
}

@test "cleanup_wt_scan_bin honors an executable CLEANUP_WT_SCAN_BIN override" {
    run env CLEANUP_WT_SCAN_BIN="${SCAN}" \
        bash -c "source '${RLIB}' && cleanup_wt_scan_bin"
    [ "$status" -eq 0 ]
    [ "$output" = "${SCAN}" ]
}

@test "cleanup_wt_scan_bin falls back to the bundled scan helper when unset" {
    run env CLEANUP_WT_SCAN_BIN="" \
        bash -c "source '${RLIB}' && cleanup_wt_scan_bin"
    [ "$status" -eq 0 ]
    [[ "$output" == *"cleanup_worktrees_scan_helper.sh" ]]
}
