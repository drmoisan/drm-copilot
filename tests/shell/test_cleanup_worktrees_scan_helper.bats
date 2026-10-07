#!/usr/bin/env bats
# Filesystem-scan unit tests for .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh, the
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
    HELPER="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh"
    ROOTS="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scan_roots/basic"
    # Checked-in scripts may lose the executable bit on some platforms; make runnable.
    chmod +x "${HELPER}" 2>/dev/null || true
}

run_helper_sourced() { # run_helper_sourced <body> [arg...] -> run <body> with HELPER sourced
    # The helper enables nounset at its top level, and under kcov the traced PS4 expands
    # ${BASH_SOURCE}, which is unset at the top level of a child shell. The helper is
    # therefore sourced inside source_helper, which clears nounset before it returns, so
    # no top-level command of the child shell runs with nounset enabled. <body> then runs
    # with the caller's arguments as its positional parameters.
    local body=$1
    shift
    local prelude='source_helper() { source "$1"; set +u; }
        source_helper "$1"
        shift
'
    run env CLEANUP_WT_SCAN_GITFILE_NAME=dotgit \
        bash -c "${prelude}${body}" _ "${HELPER}" "$@"
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

@test "scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory" {
    # Regression for issue #706. The fixture pointer names the drive-letter target
    # C:/fixture-repo/.git/worktrees/wt_drive. The helper is sourced in a child shell and
    # its single existence check, scan_helper_target_present, is redefined after sourcing
    # (a function-override test seam) to succeed only for that exact, unprefixed string.
    # A helper that prefixes the worktree directory never matches it and reports 0.
    local drive_root="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scan_roots/drive_letter"
    run_helper_sourced '
        scan_helper_target_present() { [[ $1 == "C:/fixture-repo/.git/worktrees/wt_drive" ]]; }
        scan_helper_scan_dirs "$1"
    ' "${drive_root}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"/wt_drive|1|1|"?* ]]
}

@test "scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist" {
    # Issue #706: a drive-letter target is resolved as given, with no worktree prefix.
    # No C:/fixture-repo path exists on the test host, so the real existence check
    # reports the target missing and a genuine registration loss is still reported.
    # The helper runs as a script, the same form as the first test in this file.
    local drive_root="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scan_roots/drive_letter"
    run env CLEANUP_WT_SCAN_GITFILE_NAME=dotgit \
        bash "${HELPER}" scan-dirs "${drive_root}"
    [ "$status" -eq 0 ]
    [[ "$output" == *"/wt_drive|1|0|"?* ]]
}
