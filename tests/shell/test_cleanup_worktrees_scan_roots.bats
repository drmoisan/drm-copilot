#!/usr/bin/env bats
# Scan-root unit tests for the cleanup-worktrees skill (issue #741). Scope:
# cleanup_wt_scan_roots, cleanup_wt_split_roots, and cleanup_wt_derive_scan_roots in
# .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh
# (registration-derived roots and the drive-safe CLEANUP_WT_ORPHAN_ROOTS separator
# contract), run_report's single filesystem scan over those roots, and the shared
# absolute-path predicate cleanup_wt_is_absolute_path together with its caller
# preserve_relative_path_reason in cleanup_worktrees_preserve_lib.sh.
#
# Every function is driven under the checked-in git stub and the checked-in
# filesystem-scan stub against scenario fixtures in
# tests/fixtures/cleanup_worktrees/scenarios/. No child shell here sources the scan
# helper, the only library that enables nounset, so every source runs at the top level
# of its child shell. No temporary files; no scratch git repositories.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_lib.sh"
    RLIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh"
    DLIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_detached_lib.sh"
    DIRTLIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_dirt_lib.sh"
    PLIB="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCAN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/scan"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    # Checked-in stubs may lose the executable bit on some platforms; make runnable.
    chmod +x "${STUB}" 2>/dev/null || true
    chmod +x "${SCAN}" 2>/dev/null || true
}

roots_run() { # roots_run <scenario> <override> -> cleanup_wt_scan_roots, stderr discarded
    # An empty <override> behaves as unset, because the library reads the variable with
    # the ${VAR:-} form. Stderr is discarded so $output is the emitted roots only.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" CLEANUP_WT_ORPHAN_ROOTS="$2" \
        bash -c "source '${ELIB}' && source '${RLIB}' && cleanup_wt_scan_roots 2>/dev/null"
}

roots_run_raw() { # roots_run_raw <scenario> <override> -> as roots_run, stderr RETAINED
    # bats `run` merges stderr into $output, so a diagnostic line is assertable. The git
    # stub's `stub-git:` argv log lines are also present in $output.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" CLEANUP_WT_ORPHAN_ROOTS="$2" \
        bash -c "source '${ELIB}' && source '${RLIB}' && cleanup_wt_scan_roots"
}

report_run() { # report_run <scenario> -> run the full report driver, stderr RETAINED
    # The scan stub writes one `stub-scan: <argv>` line to stderr per invocation, so the
    # number of filesystem scans and their argv are countable in $output. run_report also
    # calls the classification driver and the detached reporter, so LIB, DIRTLIB, and
    # DLIB are sourced alongside ELIB and RLIB.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}' && source '${LIB}' && source '${DIRTLIB}' && source '${RLIB}' && source '${DLIB}' && run_report"
}

@test "cleanup_wt_scan_roots appends registration-derived parents after the default pair" {
    # AC-1: with no override, the default pair comes first, then the kept parents of the
    # non-main registrations in LC_ALL=C order; /repo/main-wt (a default) and the
    # /Scratch/PlanHome case variant are emitted once.
    roots_run scan_roots_derived ""
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 4 ]
    [ "${lines[0]}" = "/repo/main/.claude/worktrees" ]
    [ "${lines[1]}" = "/repo/main-wt" ]
    [ "${lines[2]}" = "/repo/main-wt/a-wt" ]
    [ "${lines[3]}" = "/scratch/planhome" ]
}

@test "cleanup_wt_scan_roots excludes the main worktree, its ancestors, and paths equal to or inside a registered worktree" {
    # AC-2: the fixture registers worktrees whose parents are /repo (main's parent),
    # /repo/main (main itself), /repo/main/.claude (inside main), and /scratch/planhome/ph1
    # and /scratch/planhome/ph1/inner (equal to or inside a registered worktree).
    roots_run scan_roots_derived ""
    [ "${#lines[@]}" -eq 4 ]
    local line excluded
    for line in "${lines[@]}"; do
        for excluded in /repo /repo/main /repo/main/.claude /scratch/planhome/ph1 /scratch/planhome/ph1/inner; do
            if [ "$line" = "$excluded" ]; then
                echo "excluded root emitted: ${line}"
                return 1
            fi
        done
    done
}

@test "cleanup_wt_scan_roots appends derived roots after the override roots" {
    # AC-1 override rule: the override replaces only the default pair; derived parents
    # are still appended, and /repo/main-wt is now a derived root rather than a default.
    roots_run scan_roots_derived "/a/one:/b/two"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 5 ]
    [ "${lines[0]}" = "/a/one" ]
    [ "${lines[1]}" = "/b/two" ]
    [ "${lines[2]}" = "/repo/main-wt" ]
    [ "${lines[3]}" = "/repo/main-wt/a-wt" ]
    [ "${lines[4]}" = "/scratch/planhome" ]
}

@test "cleanup_wt_scan_roots emits exactly the override roots when the worktree listing hard-fails" {
    # AC-4: worktree_list_error supplies worktree-list.rc, so no root can be derived; the
    # override roots are still emitted, and nothing else.
    roots_run worktree_list_error "/a/one:/b/two"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "/a/one" ]
    [ "${lines[1]}" = "/b/two" ]
}

@test "CLEANUP_WT_ORPHAN_ROOTS keeps a drive-letter root whole" {
    # AC-5: the colon after a single drive letter that precedes / is part of the path.
    roots_run orphan_dir_present "C:/a/one"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = "C:/a/one" ]
}

@test "CLEANUP_WT_ORPHAN_ROOTS splits colon-separated drive-letter roots" {
    # AC-5: a colon that does not follow a lone drive letter separates entries, and a
    # drive letter followed by a backslash is kept whole.
    roots_run orphan_dir_present 'C:/a/one:D:\b\two'
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "C:/a/one" ]
    [ "${lines[1]}" = 'D:\b\two' ]
}

@test "CLEANUP_WT_ORPHAN_ROOTS splits on semicolons" {
    # AC-5: a semicolon separates entries.
    roots_run orphan_dir_present "C:/a/one;D:/b/two"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "C:/a/one" ]
    [ "${lines[1]}" = "D:/b/two" ]
}

@test "CLEANUP_WT_ORPHAN_ROOTS splits on newlines" {
    # AC-5: a newline separates entries.
    roots_run orphan_dir_present $'C:/a\n/b'
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "C:/a" ]
    [ "${lines[1]}" = "/b" ]
}

@test "CLEANUP_WT_ORPHAN_ROOTS drops empty segments" {
    # AC-5: doubled and trailing separators produce empty segments, which are dropped.
    roots_run orphan_dir_present "/a/one::/b/two;;"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "/a/one" ]
    [ "${lines[1]}" = "/b/two" ]
}

@test "CLEANUP_WT_ORPHAN_ROOTS keeps a glob character literally" {
    # AC-5: the split performs no pathname expansion, so /* is emitted as written.
    roots_run orphan_dir_present '/*'
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = '/*' ]
}

@test "CLEANUP_WT_ORPHAN_ROOTS drops a relative segment with a stderr diagnostic" {
    # AC-5: a relative entry is dropped and named on stderr; the absolute entry is kept.
    roots_run_raw orphan_dir_present "rel:/b/two"
    [ "$status" -eq 0 ]
    # grep -c exits 1 on a zero count; neutralize it so each assertion reports the count.
    diag_count=$(printf '%s\n' "${lines[@]}" | grep -cxF "cleanup-worktrees: CLEANUP_WT_ORPHAN_ROOTS entry is not absolute, dropped: rel" || true)
    [ "$diag_count" -ge 1 ]
    kept_count=$(printf '%s\n' "${lines[@]}" | grep -cxF "/b/two" || true)
    [ "$kept_count" -ge 1 ]
    relative_count=$(printf '%s\n' "${lines[@]}" | grep -cxF "rel" || true)
    [ "$relative_count" -eq 0 ]
}

@test "run_report passes a registration-derived root to its single filesystem scan" {
    # AC-6: run_report still performs exactly one scan, and its argv carries the default
    # pair followed by the registration-derived roots.
    report_run scan_roots_derived
    # grep -c exits 1 on a zero count; neutralize it so each assertion reports the count.
    scan_calls=$(printf '%s\n' "$output" | grep -c 'stub-scan: scan-dirs' || true)
    [ "$scan_calls" -eq 1 ]
    argv_lines=$(printf '%s\n' "$output" | grep -cxF "stub-scan: scan-dirs /repo/main/.claude/worktrees /repo/main-wt /repo/main-wt/a-wt /scratch/planhome" || true)
    [ "$argv_lines" -eq 1 ]
}

@test "cleanup_wt_is_absolute_path returns 0 for slash-leading and drive-letter paths" {
    # AC-7 (issue #706 cases): slash-leading paths and drive letters followed by / or \
    # are absolute. Each candidate classified relative is printed, so a failure names it.
    # The enumeration library does not enable nounset, so it is sourced at top level.
    run bash -c '
        source "$1"
        shift
        for candidate in "$@"; do
            cleanup_wt_is_absolute_path "$candidate" || printf "classified relative: [%s]\n" "$candidate"
        done
    ' _ "${ELIB}" "/abs" "C:/x" "c:/x" 'C:\x'
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "cleanup_wt_is_absolute_path returns non-zero for relative, drive-relative, and empty paths" {
    # AC-7 (issue #706 cases): relative paths, a drive letter with no separator, and the
    # empty string are not absolute. Each candidate classified absolute is printed.
    run bash -c '
        source "$1"
        shift
        for candidate in "$@"; do
            if cleanup_wt_is_absolute_path "$candidate"; then
                printf "classified absolute: [%s]\n" "$candidate"
            fi
        done
    ' _ "${ELIB}" "../rel" "rel" "C:rel" ""
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "preserve_relative_path_reason honors an override of the shared absolute-path predicate" {
    # AC-7: the shared predicate is redefined after sourcing (a function-override test
    # seam) to classify every path as relative. The reason is empty only when the
    # preserve library calls the shared function rather than an inline test.
    run bash -c '
        source "$1"
        source "$2"
        cleanup_wt_is_absolute_path() { return 1; }
        preserve_relative_path_reason source_path /abs/x
    ' _ "${ELIB}" "${PLIB}"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "preserve_relative_path_reason rejects a drive-letter source_path as absolute" {
    # AC-7: a drive-letter source_path is reported as absolute.
    run bash -c '
        source "$1"
        source "$2"
        preserve_relative_path_reason source_path C:/x/lesson.md
    ' _ "${ELIB}" "${PLIB}"
    [ "$status" -eq 0 ]
    [ "$output" = "source_path is absolute: C:/x/lesson.md" ]
}
