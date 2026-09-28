#!/usr/bin/env bats
# Content-location accounting gate for the dirt classifier in
# scripts/bash/cleanup_worktrees_dirt_lib.sh (issue #632).
#
# SUBJECT. The missing-comparison defect family: R1, N1 and N3. All three are the same
# defect in different places — a rung resolves a disposable verdict from a probe that
# does not answer the question the verdict claims to have answered. R1 read the index
# and concluded about the working tree; N1 read an exit code that meant "the pathspec
# selected nothing" and concluded "the content matches main"; N3 reads the working tree
# and concludes about an entry that also holds content in the index.
#
# WHY A SECOND GATE. The guard registry in
# tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats detects a DEAD GUARD: a
# marked line whose neutralization changes nothing observable. That is a different
# property, and it passes cleanly on a tree containing N3, because N3 is not a guard
# that fails to fire — it is a comparison that was never written. This suite states the
# property over the INPUTS TO A VERDICT instead.
#
# MECHANISM. The property is quantified over the classifier's own output rather than
# over a table of expected verdicts, so it cannot be satisfied by editing a table. For
# every DIRTFILE record every checked-in dirt_* scenario emits, the required content
# locations are derived from that record's OWN two-character status code, and a matching
# read for that record's OWN path is required in the stub's argv log. A future rung that
# resolves a disposable verdict for a status code nobody anticipated is therefore still
# in scope.
#
# THE TWO CHANNELS ARE SEPARATED, NOT MERGED. The classifier's stdout carries the record
# stream and the stub writes its argv log to stderr. They are read back through a 3>&1
# swap with the stderr side tagged, because a merged stream would let a file path that
# appears only in a record be read as a path named by an invocation.
#
# TWO VERDICTS ARE EXCLUDED, BY NAME AND WITH THE REASON STATED.
#
#   DISPOSABLE_SESSION_ARTIFACT is resolved at rung 2 by exact string comparison against
#   the hard-coded CLEANUP_WT_SESSION_ARTIFACT_PATHS array and issues NO read at all. It
#   is a path authorization, not a content inference, so there is no comparison for it
#   to be missing.
#
#   UNIQUE is excluded because it is the fail-closed direction. It asserts nothing about
#   recoverability, so there is no claim for a read to have to support.
#
# WHAT THE COVERAGE FLOOR IN THE SECOND TEST DOES. Once N3's fix lands, every two-blob
# entry resolves UNIQUE and leaves the first test's domain by construction. For those
# entries the first test is a REGRESSION DETECTOR: it holds zero tuples on a passing
# tree and fails the moment any change re-admits a two-blob entry to a disposable
# verdict. The floor's job is to keep those shapes present in the corpus so the detector
# has something to detect.
#
# No scratch directory and no file is created on disk. Every fixture is checked in.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    DIRTLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_dirt_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    SCEN="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/scenarios"
    WT="/repo-wt/dirt"
    chmod +x "${STUB}" 2>/dev/null || true
}

classify_channels() { # classify_channels <scenario> -> sets CH_REC and CH_ARGV
    # One child per call. Its stdout carries the record channel; its stderr carries the
    # stub argv log and is tagged with an ARGV prefix before both are read back, so the
    # two channels are separated rather than merged.
    local scen="$1" merged
    merged=$(
        {
            env CLEANUP_WT_GIT_BIN="$STUB" \
                CLEANUP_WT_STUB_SCENARIO="${SCEN}/${scen}" \
                bash -c '
                    source "$1"
                    source "$2"
                    source "$3"
                    classify_worktree_dirt "$4"
                ' _ "$ELIB" "$LIB" "$DIRTLIB" "$WT" 2>&1 1>&3 | sed 's/^/ARGV /'
        } 3>&1
    )
    CH_REC="$(printf '%s\n' "$merged" | grep -v '^ARGV ' || true)"
    CH_ARGV="$(printf '%s\n' "$merged" | sed -n 's/^ARGV //p' || true)"
}

has_index_probe() { # has_index_probe <path> -> 0 when an index-side read covers it
    # The `diff-index --cached --quiet <commit> --` form is path-independent by design:
    # it asserts that the WHOLE index equals an existing commit's tree, which accounts
    # for every path in it. That is why it is matched without a path suffix.
    local rel="$1" l
    [[ "$CH_ARGV" == *"diff-index --cached --quiet"* ]] && return 0
    while IFS= read -r l; do
        [[ "$l" == *"diff --no-color -U0 --cached -- $rel" ]] && return 0
        [[ "$l" == *"rev-parse :$rel" ]] && return 0
    done <<<"$CH_ARGV"
    return 1
}

has_worktree_probe() { # has_worktree_probe <path> -> 0 when a worktree read covers it
    local rel="$1" l
    while IFS= read -r l; do
        [[ "$l" == *"diff --quiet main -- $rel" ]] && return 0
        [[ "$l" == *"hash-object -- $rel" ]] && return 0
        [[ "$l" == *"diff --no-color -U0 -- $rel" ]] && return 0
    done <<<"$CH_ARGV"
    return 1
}

@test "every disposable verdict is backed by a git read of every location holding that entry's content" {
    local scen_dir scen line verdict xy rel x y idx wtb
    local offenders="" examined=0

    # Arrange: every checked-in dirt scenario, discovered from disk rather than from a
    # written list, so a scenario added without touching this file is still in scope.
    while IFS= read -r scen_dir; do
        scen="$(basename "$scen_dir")"

        # Act: one classification per scenario, both channels captured separately.
        classify_channels "$scen"

        # Assert, accumulating rather than failing at the first offender so that one run
        # names every one of them.
        while IFS= read -r line; do
            [[ "$line" == DIRTFILE\|* ]] || continue
            verdict="$(printf '%s\n' "$line" | cut -d'|' -f3)"
            case "$verdict" in
            UNIQUE | DISPOSABLE_SESSION_ARTIFACT) continue ;;
            esac
            # Field 5 is the status code and field 6 onward is the path, so a path
            # containing the record delimiter is recovered intact.
            xy="$(printf '%s\n' "$line" | cut -d'|' -f5)"
            rel="$(printf '%s\n' "$line" | cut -d'|' -f6-)"
            x="${xy:0:1}"
            y="${xy:1:1}"
            examined=$((examined + 1))

            # An index blob exists when the X column carries a content-bearing letter; a
            # working-tree blob exists when the Y column does, or when the entry is
            # untracked. M A R C T U are content-bearing: a space means the two sides
            # agree, ? and ! mean the path is not in the index, and D means the blob on
            # that side does not exist.
            idx=0
            wtb=0
            case "$x" in [MARCTU]) idx=1 ;; esac
            case "$y" in [MARCTU]) wtb=1 ;; esac
            [ "$xy" = "??" ] && wtb=1

            if [ "$idx" -eq 1 ] && [ "$wtb" -eq 1 ]; then
                # Two distinct blobs. Both must be accounted for.
                has_index_probe "$rel" ||
                    offenders="${offenders}${scen}:${rel}:${verdict}:index "
                has_worktree_probe "$rel" ||
                    offenders="${offenders}${scen}:${rel}:${verdict}:worktree "
            elif [ "$idx" -eq 1 ] && [ "$y" = " " ]; then
                # One blob reachable from both sides: either probe accounts for it.
                has_index_probe "$rel" || has_worktree_probe "$rel" ||
                    offenders="${offenders}${scen}:${rel}:${verdict}:same-blob "
            elif [ "$idx" -eq 1 ]; then
                has_index_probe "$rel" ||
                    offenders="${offenders}${scen}:${rel}:${verdict}:index "
            elif [ "$wtb" -eq 1 ]; then
                has_worktree_probe "$rel" ||
                    offenders="${offenders}${scen}:${rel}:${verdict}:worktree "
            fi
        done <<<"$CH_REC"
    done < <(find "${SCEN}" -maxdepth 1 -type d -name 'dirt_*')

    echo "in-domain records examined: ${examined}" >&2
    if [ -n "$offenders" ]; then
        echo "UNACCOUNTED CONTENT LOCATIONS (scenario:path:verdict:location):" >&2
        printf '%s\n' "$offenders" >&2
    fi
    [ -z "$offenders" ]
}

@test "every classifier-relevant status-code class is covered by a checked-in dirt scenario" {
    local scen_dir line codes="" want missing=""

    # Arrange and act: the union of two-character status codes across every checked-in
    # dirt scenario's status fixture. Each code is bracketed so that a two-character
    # code ending in a space cannot match inside a longer one.
    while IFS= read -r scen_dir; do
        [ -f "${scen_dir}/status._repo-wt_dirt.out" ] || continue
        while IFS= read -r line || [ -n "$line" ]; do
            [ -z "$line" ] && continue
            codes="${codes}[${line:0:2}]"
        done <"${scen_dir}/status._repo-wt_dirt.out"
    done < <(find "${SCEN}" -maxdepth 1 -type d -name 'dirt_*')

    # Assert: the eight classes the classifier's own branching distinguishes.
    #   ??   untracked; the only shape that sets untracked=1
    #   'M ' staged, worktree clean; reaches rung 1
    #   'A ' staged addition; the path may be absent from main
    #   'R ' staged rename; triggers the ` -> ` payload split
    #   ' M' unstaged only; the index equals HEAD
    #   AD   staged content with the working-tree copy deleted; N1's shape
    #   MM   both columns content-bearing, ordinary; N3's shape
    #   UU   both columns content-bearing, unmerged; N3's shape at an index stage
    # This is not an enumeration of every pair porcelain can emit, and it makes no claim
    # about !! (the status read never carries --ignored) or about within-class variants
    # such as MD beside AD.
    for want in '??' 'M ' 'A ' 'R ' ' M' 'AD' 'MM' 'UU'; do
        [[ "$codes" == *"[${want}]"* ]] || missing="${missing}[${want}] "
    done

    if [ -n "$missing" ]; then
        echo "STATUS-CODE CLASSES WITH NO CHECKED-IN SCENARIO:" >&2
        printf '%s\n' "$missing" >&2
    fi
    [ -z "$missing" ]
}
