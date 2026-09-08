#!/usr/bin/env bats
# Verdict tests for the dirt classifier in scripts/bash/cleanup_worktrees_dirt_lib.sh
# (issue #632).
#
# Every verdict is pinned in BOTH directions. For each of the six tokens there is a test
# asserting the verdict IS produced for a qualifying input and a test asserting it is
# NOT produced for a near-miss input, because a suite that pins only the "refuse to
# delete" direction does not show the classifier is useful and one that pins only the
# "safe to delete" direction does not show it is safe. The near-misses are:
#   DISPOSABLE_BUILD_ARTIFACT    <- dirt_build_artifact_mixed (a non-HintPath diff line)
#   DISPOSABLE_SESSION_ARTIFACT  <- dirt_quoted_path (a C-quoted path whose unquoted
#                                   prefix is a session-artifact path)
#   CONTENT_ON_MAIN              <- dirt_unique and dirt_content_in_history (the blob is
#                                   absent at main:<path>)
#   CONTENT_IN_HISTORY           <- dirt_unique (find-object returns nothing)
#   STAGED_TREE_IS_COMMIT        <- dirt_build_artifact (an unstaged X column)
#   UNIQUE                       <- every scenario whose entry classifies disposable
#
# Tests 1 through 18 drive classify_worktree_dirt directly through the
# CLEANUP_WT_GIT_BIN plus CLEANUP_WT_STUB_SCENARIO seam. Test 19 drives run_report
# through the same seam, because the record PLACEMENT it asserts is produced by the
# report-mode call site rather than by the classifier.
#
# No temporary files; no scratch git repositories. Every fixture is checked in.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    RLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_report_records_lib.sh"
    DLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_detached_lib.sh"
    DIRTLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_dirt_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCAN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/scan"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    WT="/repo-wt/dirt"
    chmod +x "${STUB}" 2>/dev/null || true
    chmod +x "${SCAN}" 2>/dev/null || true
}

dirt() { # dirt <scenario> -> classify_worktree_dirt with the stub argv log DISCARDED
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; classify_worktree_dirt '${WT}' 2>/dev/null"
}

dirt_log() { # dirt_log <scenario> -> the same run, KEEPING the stub argv log
    # No 2>/dev/null here: the stub writes its `stub-git: <argv>` log to stderr and bats
    # `run` merges stderr into $output, which is what the argv assertions read.
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/$1" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; classify_worktree_dirt '${WT}'"
}

argv_log() { # argv_log -> only the stub's argv lines from the merged $output
    # Filtering to the `stub-git: ` lines matters: the emitted DIRTFILE records also
    # carry file paths, so a search over the whole merged output would report a path as
    # "named by a git invocation" when it appeared only in a record.
    printf '%s\n' "$output" | grep '^stub-git: ' || true
}

@test "dirt_build_artifact: a HintPath-only csproj modification is DISPOSABLE_BUILD_ARTIFACT" {
    dirt dirt_build_artifact
    [ "$status" -eq 0 ]
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|DISPOSABLE_BUILD_ARTIFACT|| M|src/Legacy/Legacy.csproj'* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|'* ]]
    # Negative direction. The scenario supplies no diff-quiet..src_Legacy_Legacy.csproj
    # response, so a rung-3 miss would fall through to rung 4, read the stub default
    # exit 0, and label the entry CONTENT_ON_MAIN. The X column is a space, so rung 1
    # must not fire either.
    [[ "$output" != *"CONTENT_ON_MAIN"* ]]
    [[ "$output" != *"STAGED_TREE_IS_COMMIT"* ]]
    [[ "$output" != *"UNIQUE"* ]]
}

@test "dirt_build_artifact: no find-object history walk runs for the classified project file" {
    dirt_log dirt_build_artifact
    log="$(argv_log)"
    # Positive control: the ladder did run and reached rung 3's content read, so the
    # negative assertion below is not vacuous.
    [[ "$log" == *"diff"*"src/Legacy/Legacy.csproj"* ]]
    [[ "$log" != *"--find-object"* ]]
}

@test "dirt_build_artifact_mixed: a csproj diff carrying a non-HintPath line is UNIQUE" {
    dirt dirt_build_artifact_mixed
    [ "$status" -eq 0 ]
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE|| M|src/Legacy/Legacy.csproj'* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|'* ]]
    # This is the near-miss half of the build-artifact pin: the same path, the same
    # status code, and a diff that differs only by one changed line that is not a
    # HintPath rewrite. Labelling it disposable would destroy a hand edit to a project
    # file, which is the concrete data-loss case the content confinement exists to
    # prevent.
    [[ "$output" != *"DISPOSABLE_BUILD_ARTIFACT"* ]]
    [[ "$output" != *"ALL_DISPOSABLE"* ]]
}

@test "dirt_session_artifact: the session artifact is DISPOSABLE_SESSION_ARTIFACT" {
    dirt dirt_session_artifact
    [ "$status" -eq 0 ]
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|DISPOSABLE_SESSION_ARTIFACT||??|artifacts/pr_context.summary.txt'* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|'* ]]
    [[ "$output" != *"UNIQUE"* ]]
}

@test "dirt_session_artifact: no git invocation names the session artifact path" {
    dirt_log dirt_session_artifact
    log="$(argv_log)"
    # Rung 2 is a pure string comparison against the hard-coded array, evaluated before
    # rungs 3 through 5, so no read of any kind names this path.
    [[ "$log" != *"artifacts/pr_context.summary.txt"* ]]
    # Positive control: the classifier did run and issued its one status read, so the
    # assertion above is not passing merely because nothing happened.
    [[ "$log" == *"status --porcelain"* ]]
}

@test "dirt_content_on_main: an untracked blob equal to main's blob is CONTENT_ON_MAIN" {
    dirt dirt_content_on_main
    [ "$status" -eq 0 ]
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|docs/copy.md'* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|'* ]]
    [[ "$output" != *"CONTENT_IN_HISTORY"* ]]
    [[ "$output" != *"UNIQUE"* ]]
}

@test "dirt_content_on_main: no find-object history walk runs" {
    dirt_log dirt_content_on_main
    log="$(argv_log)"
    # Positive control: rung 4's two reads did run.
    [[ "$log" == *"hash-object"*"docs/copy.md"* ]]
    [[ "$log" == *"rev-parse main:docs/copy.md"* ]]
    [[ "$log" != *"--find-object"* ]]
}

@test "dirt_content_in_history: the detail field carries the find-object commit sha" {
    dirt dirt_content_in_history
    [ "$status" -eq 0 ]
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|CONTENT_IN_HISTORY|ffff8888|??|docs/old.md'* ]]
    # Negative direction: rev-parse main:docs/old.md exits 128, which is that probe's
    # defined negative answer (the path is absent from main) and must advance the ladder
    # rather than fail closed. Reading it as a hard failure would produce UNIQUE here.
    [[ "$output" != *"CONTENT_ON_MAIN"* ]]
    [[ "$output" != *"UNIQUE"* ]]
}

@test "dirt_staged_tree_is_commit: staged entries carry the matching commit sha" {
    dirt dirt_staged_tree_is_commit
    [ "$status" -eq 0 ]
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/a.cs'* ]]
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/b.cs'* ]]
    # dddd9999 is the HEAD sha the probe must drop. Reporting it as the match would mean
    # the first rev-list entry was probed and answered by the stub default.
    [[ "$output" != *"dddd9999"* ]]
    [[ "$output" != *"UNIQUE"* ]]
}

@test "dirt_staged_tree_is_commit: the aggregate detail field carries the same commit sha" {
    dirt dirt_staged_tree_is_commit
    [ "$status" -eq 0 ]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|eeee7777'* ]]
}

@test "dirt_staged_tree_is_commit: the first rev-list entry is never probed" {
    dirt_log dirt_staged_tree_is_commit
    log="$(argv_log)"
    # Positive control: the probe did run and did reach the second rev-list entry.
    [[ "$log" == *"diff-index --cached --quiet eeee7777"* ]]
    # The HEAD sha is the first line rev-list returns and is always identical to the
    # index it would be compared against, so probing it would match trivially and label
    # every staged entry disposable.
    [[ "$log" != *"diff-index --cached --quiet dddd9999"* ]]
}

@test "dirt_staged_tree_is_commit: no lower-rung read runs for the staged paths" {
    dirt_log dirt_staged_tree_is_commit
    log="$(argv_log)"
    # Positive control, asserted over the merged $output because the records are on
    # stdout while the argv log is on stderr. Both staged paths must reach a rung-1
    # verdict. Without this the four absence assertions below hold in any tree where no
    # classification runs at all, including one with the classifier deleted outright, so
    # the test could not fail in the direction that matters.
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/a.cs'* ]]
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/b.cs'* ]]
    # Rung 1 precedes rungs 2 through 5, so none of the lower rungs' reads is issued for
    # either staged path.
    [[ "$log" != *"hash-object"* ]]
    [[ "$log" != *"--find-object"* ]]
    [[ "$log" != *"diff --quiet main -- src/a.cs"* ]]
    [[ "$log" != *"diff --quiet main -- src/b.cs"* ]]
}

@test "dirt_unique: an unmatched untracked file is UNIQUE and the worktree is HAS_UNIQUE" {
    dirt dirt_unique
    [ "$status" -eq 0 ]
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes.md'* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|'* ]]
    # This entry is the near miss for both content rungs: hash-object resolves, but the
    # path is absent from main's tree and its blob is absent from main's history.
    [[ "$output" != *"CONTENT_ON_MAIN"* ]]
    [[ "$output" != *"CONTENT_IN_HISTORY"* ]]
    [[ "$output" != *"ALL_DISPOSABLE"* ]]
}

@test "dirt_classifier_read_error: a non-zero classifier read yields UNIQUE and HAS_UNIQUE" {
    dirt dirt_classifier_read_error
    [ "$status" -eq 0 ]
    # hash-object exits 128 with no canned stdout. That exit carries no verdict, so it
    # is a hard read failure and the entry must fail closed. This is the one rule whose
    # violation converts a transient git failure into data loss.
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes.md'* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|'* ]]
    [[ "$output" != *"ALL_DISPOSABLE"* ]]
}

@test "every verdict emitted across the checked-in dirt scenarios is one of the six defined tokens" {
    local s out line v offenders="" seen=0 iterated=0 on_disk
    # The list names every scenario directory under scenarios/ whose name begins `dirt_`.
    # It is written out rather than globbed so that the file records which scenarios the
    # membership check covers; the on-disk count assertion below is what stops the list
    # silently falling behind the directory.
    for s in dirt_build_artifact dirt_build_artifact_added_file dirt_build_artifact_mixed \
        dirt_build_artifact_plus_content dirt_classifier_read_error \
        dirt_clear_all_disposable dirt_clear_clean_failed dirt_clear_reset_failed \
        dirt_clear_reverify_order dirt_content_in_history dirt_content_on_main \
        dirt_history_depth_fallback dirt_history_read_error dirt_mixed_unique_blocks \
        dirt_pipe_path dirt_quoted_path dirt_rename_split dirt_session_artifact \
        dirt_staged_probe_diffindex_error dirt_staged_probe_revlist_error \
        dirt_staged_tree_is_commit dirt_staged_tree_no_match \
        dirt_staged_tree_worktree_delta dirt_tracked_read_errors dirt_unique; do
        iterated=$((iterated + 1))
        out="$(env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_STUB_SCENARIO="${SCEN}/${s}" \
            bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; classify_worktree_dirt '${WT}' 2>/dev/null")" || true
        while IFS= read -r line; do
            [[ "$line" == DIRTFILE\|* ]] || continue
            v="$(printf '%s\n' "$line" | cut -d'|' -f3)"
            seen=$((seen + 1))
            case "$v" in
            DISPOSABLE_BUILD_ARTIFACT | DISPOSABLE_SESSION_ARTIFACT | CONTENT_ON_MAIN | CONTENT_IN_HISTORY | STAGED_TREE_IS_COMMIT | UNIQUE) ;;
            *) offenders="${offenders}${s}:${v} " ;;
            esac
        done <<<"$out"
    done
    # Companion assertion: the loop must have covered every dirt_* directory that exists.
    # Without it a future scenario could be added to the tree and omitted from the list
    # above, and its verdicts would never be checked for membership.
    on_disk="$(find "${SCEN}" -maxdepth 1 -type d -name 'dirt_*' | wc -l)"
    [ "$iterated" -eq "$on_disk" ]
    # The union must be exactly the thirty records these scenarios produce: twenty-five
    # scenarios, of which five carry two status entries each. Without this count the
    # membership check would pass vacuously over an empty union.
    [ "$seen" -eq 30 ]
    [ -z "$offenders" ]
}

@test "dirt_mixed_unique_blocks: two entries emit two per-file records in porcelain order then one aggregate" {
    dirt dirt_mixed_unique_blocks
    [ "$status" -eq 0 ]
    [ "$(printf '%s\n' "$output" | sed -n '1p')" = 'DIRTFILE|/repo-wt/dirt|DISPOSABLE_SESSION_ARTIFACT||??|artifacts/pr_context.summary.txt' ]
    [ "$(printf '%s\n' "$output" | sed -n '2p')" = 'DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes.md' ]
    [ "$(printf '%s\n' "$output" | sed -n '3p')" = 'DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|' ]
    # Exactly one aggregate, emitted last, whatever the entry count.
    [ "$(printf '%s\n' "$output" | grep -c '^DIRTSUM|')" -eq 1 ]
    [ "$(printf '%s\n' "$output" | grep -c '^DIRTFILE|')" -eq 2 ]
}

@test "dirt_pipe_path: the file path is the last field and the detail field is empty" {
    dirt dirt_pipe_path
    [ "$status" -eq 0 ]
    # The path carries the record delimiter. Because the file path is the LAST field, a
    # consumer splitting on the first five delimiters still recovers it intact; any
    # other field order would truncate it here.
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|docs/a|b.md'* ]]
    # The detail field is empty for every verdict other than the two sha-carrying ones.
    [ "$(printf '%s\n' "$output" | grep '^DIRTFILE|' | cut -d'|' -f4)" = "" ]
}

@test "dirt_quoted_path: a C-quoted path is UNIQUE and no unquoting is attempted" {
    quoted='"artifacts/pr_context.summary.txt\342\200\223"'
    dirt dirt_quoted_path
    [ "$status" -eq 0 ]
    [[ "$output" == *"DIRTFILE|/repo-wt/dirt|UNIQUE||??|${quoted}"* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|'* ]]
    # The near-miss half of the session-artifact pin. This path's unquoted prefix is
    # exactly a session-artifact path, so a classifier that unquoted the payload, or
    # that matched the array by prefix rather than exactly, would label it disposable
    # and make it clearable. Rung 2's comparison is exact and no unquoting is attempted,
    # so it must fail closed instead.
    [[ "$output" != *"DISPOSABLE_SESSION_ARTIFACT"* ]]
    [[ "$output" != *"ALL_DISPOSABLE"* ]]
    dirt_log dirt_quoted_path
    log="$(argv_log)"
    # No read of any kind names the quoted payload, in either its quoted or an unquoted
    # form.
    [[ "$log" != *"artifacts/pr_context.summary.txt"* ]]
}

@test "dirt_mixed_unique_blocks: report mode emits the two per-file records and the aggregate immediately after that worktree's WORKTREE record" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" CLEANUP_WT_SCAN_BIN="${SCAN}" \
        CLEANUP_WT_STUB_SCENARIO="${SCEN}/dirt_mixed_unique_blocks" \
        bash -c "source '${ELIB}'; source '${LIB}'; source '${RLIB}'; source '${DLIB}'; source '${DIRTLIB}'; run_report 2>/dev/null"
    [ "$status" -eq 0 ]
    # Matched on the leading literal rather than in full so the assertion does not
    # depend on the record's trailing flags field.
    wt_line="$(printf '%s\n' "$output" | grep -n '^WORKTREE|/repo-wt/dirt|' | head -n1 | cut -d: -f1)"
    [ -n "$wt_line" ]
    # Asserted by POSITION, not by membership: the placement clause is what this test
    # pins, and a membership check would pass wherever the records were emitted.
    [ "$(printf '%s\n' "$output" | sed -n "$((wt_line + 1))p")" = 'DIRTFILE|/repo-wt/dirt|DISPOSABLE_SESSION_ARTIFACT||??|artifacts/pr_context.summary.txt' ]
    [ "$(printf '%s\n' "$output" | sed -n "$((wt_line + 2))p")" = 'DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes.md' ]
    [ "$(printf '%s\n' "$output" | sed -n "$((wt_line + 3))p")" = 'DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|' ]
    # The main worktree registration is never classified, so no record precedes it.
    [[ "$output" == *"WORKTREE|/repo/main|main|main"* ]]
    [ "$(printf '%s\n' "$output" | grep -c '^DIRTSUM|')" -eq 1 ]
}

@test "dirt_rename_split: an untracked path containing the rename literal is reported in full and is UNIQUE" {
    dirt dirt_rename_split
    [ "$status" -eq 0 ]
    # Porcelain status uses the `OLD -> NEW` payload only for R and C entries. A space
    # does not trigger C-quoting, so an ordinary untracked path may contain the literal.
    # Splitting unconditionally truncated this path to `draft.md`, issued every probe
    # against the wrong file, and emitted a record naming a file the operator does not
    # have. The two fixture blobs differ, so the truncated read resolves CONTENT_ON_MAIN
    # and the full read resolves UNIQUE.
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes -> draft.md'* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|'* ]]
    [[ "$output" != *'DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|draft.md'* ]]
}

@test "dirt_rename_split: a genuine R entry is still split and the destination path is classified" {
    dirt_log dirt_rename_split
    [ "$status" -eq 0 ]
    # The other half of the pin. Restricting the split must not disable it: for a real
    # rename the destination is the path that exists in the working tree and is therefore
    # the one to classify.
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||R |new.md'* ]]
    log="$(argv_log)"
    # The source path of a rename exists nowhere in the working tree, so no probe may name
    # it. A split that kept the source instead of the destination would show up here.
    [[ "$log" != *"old.md"* ]]
}

@test "dirt_build_artifact_plus_content: an added content line beginning with plus-plus-plus is counted and the entry is UNIQUE" {
    dirt dirt_build_artifact_plus_content
    [ "$status" -eq 0 ]
    # The header skip was written as an unanchored prefix test, so it also dropped an
    # added line whose CONTENT begins with the marker. Such a line was neither counted
    # toward `changed` nor tested for HintPath, so a project file carrying a real hand
    # edit resolved DISPOSABLE_BUILD_ARTIFACT and became clearable. The skip is now
    # anchored to the four header forms the diff actually emits.
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE|| M|src/Legacy/Legacy.csproj'* ]]
    [[ "$output" != *"DISPOSABLE_BUILD_ARTIFACT"* ]]
}

@test "dirt_build_artifact_added_file: a dev-null header is still skipped and the entry is DISPOSABLE_BUILD_ARTIFACT" {
    dirt dirt_build_artifact_added_file
    [ "$status" -eq 0 ]
    # The other half of the pin. Anchoring must not stop the skip working: a newly added
    # file's cached diff carries `--- /dev/null` and `+++ b/<path>`, and both are headers
    # rather than content. An anchoring that missed either form would count them as
    # changed lines, fail the HintPath test, and resolve the entry UNIQUE.
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|DISPOSABLE_BUILD_ARTIFACT||A |src/Legacy/Legacy.csproj'* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|ALL_DISPOSABLE|'* ]]
}

@test "no status read the classifier issues carries --ignored" {
    dirt_log dirt_session_artifact
    log="$(argv_log)"
    # Positive control: the classifier issued its one status read, so the absence
    # assertion below is not passing merely because nothing ran.
    [[ "$log" == *"status --porcelain"* ]]
    # Decision B. Adding --ignored would make DISPOSABLE_SESSION_ARTIFACT reachable in a
    # checkout that gitignores artifacts/, and would at the same time pull every ignored
    # build output into the classified set and, for any entry matching a disposable rung,
    # into the cleared set. The verdict stays repository-agnostic and inert here rather
    # than being made reachable that way, and this assertion is what holds that decision.
    [[ "$log" != *"--ignored"* ]]
}
