#!/usr/bin/env bats
# Filesystem-scan unit tests for scripts/bash/cleanup_worktrees_scan_helper.sh, the
# bundled real implementation behind the CLEANUP_WT_SCAN_BIN seam. The helper is driven
# against the checked-in fixture tree under
# tests/fixtures/cleanup_worktrees/scan_roots/basic/, which carries one directory per
# observable shape: no pointer file, a pointer file whose gitdir target exists, and a
# pointer file whose gitdir target is missing.
#
# The fixture names its pointer files `dotgit` and the test sets
# CLEANUP_WT_SCAN_GITFILE_NAME accordingly, because git refuses to index any path
# component named `.git`, so a real `.git` pointer file cannot be checked in and the
# repository's test policy prohibits creating one at test time. No temporary files; no
# scratch git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    HELPER="${REPO_ROOT}/scripts/bash/cleanup_worktrees_scan_helper.sh"
    ROOTS="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scan_roots/basic"
    # Checked-in scripts may lose the executable bit on some platforms; make runnable.
    chmod +x "${HELPER}" 2>/dev/null || true
}

@test "scan-dirs emits has_gitfile/target_exists/size for each candidate directory" {
    run env CLEANUP_WT_SCAN_GITFILE_NAME=dotgit \
        bash "${HELPER}" scan-dirs "${ROOTS}"
    [ "$status" -eq 0 ]
    # A directory with no pointer file: has_gitfile 0 and target_exists NA. The size
    # field is asserted only as non-empty (spec: size is best-effort).
    [[ "$output" == *"/no_git|0|NA|"?* ]]
    # A pointer file whose gitdir target resolves: has_gitfile 1, target_exists 1.
    [[ "$output" == *"/good_wt|1|1|"?* ]]
    # A pointer file whose gitdir target is missing: has_gitfile 1, target_exists 0.
    [[ "$output" == *"/broken_wt|1|0|"?* ]]
}
