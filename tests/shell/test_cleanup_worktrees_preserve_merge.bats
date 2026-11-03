#!/usr/bin/env bats
# Merge-decision unit tests for
# .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh and
# its wiring into preserve_plan_one. The pure line helpers are driven directly with inline
# content; every scenario is driven through the read-only planning phase (preserve_plan)
# against checked-in fixtures under tests/fixtures/cleanup_worktrees/preserve/merge-*/ and
# the recording git stub, so no test writes a checked-in fixture. Where a test needs the
# writing phase, every plan entry's destination is first rewritten to the null device.
#
# No temporary files; no scratch git repositories; no real git or jq is invoked. CRLF and
# unterminated contents are built inline with $'...' strings, because the `eol=lf`
# attribute rule normalizes checked-in fixtures to LF.
#
# The base-unavailable, untracked, and duplicate-target scenarios live in
# tests/shell/test_cleanup_worktrees_preserve_merge_fallback.bats, which keeps each file
# below the 500-line guidance tier.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    SDIR="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts"
    ELIB="${SDIR}/cleanup_worktrees_enumerate_lib.sh"
    LIB="${SDIR}/cleanup_worktrees_lib.sh"
    ALIB="${SDIR}/cleanup_worktrees_actions_lib.sh"
    MLIB="${SDIR}/cleanup_worktrees_preserve_merge_lib.sh"
    EOLLIB="${SDIR}/cleanup_worktrees_preserve_eol_lib.sh"
    PLIB="${SDIR}/cleanup_worktrees_preserve_lib.sh"
    WRAP="${SDIR}/cleanup-worktrees.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    JQSTUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq"
    PRES="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/preserve"
    # preserve_resolve_jq accepts CLEANUP_WT_JQ_BIN only when the value is executable, so
    # a non-executable stub would silently fall through to a real jq on the host.
    chmod +x "${STUB}" "${JQSTUB}" 2>/dev/null || true
    # Manifest records name their worktree by a repo-relative path.
    cd "${REPO_ROOT}" || return 1
    # The six libraries are sourced in the wrapper's order so the tests call the production
    # functions directly. The source-guard test sources the chain again in a fresh subshell.
    source "${ELIB}"
    source "${LIB}"
    source "${ALIB}"
    source "${MLIB}"
    source "${EOLLIB}"
    source "${PLIB}"
    return 0
}

# Point every seam at the named scenario and run the read-only planning phase. $2 overrides
# the consolidation path, which defaults to the scenario's own consolidation directory.
merge_drive_plan() {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/$1"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/$1/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH="${2:-${PRES}/$1/consolidation}"
    preserve_plan
}

# Run the writing phase over the current plan stream with every destination rewritten to
# the null device, so the merged blob is written to /dev/null and nothing is created.
merge_commit_to_null() {
    local i
    for i in "${!PRESERVE_PLAN_STREAM[@]}"; do
        preserve_split_tsv "${PRESERVE_PLAN_STREAM[$i]}"
        PRESERVE_FIELDS[2]=/dev/null
        PRESERVE_PLAN_STREAM[i]="$(IFS=$'\t'; printf '%s' "${PRESERVE_FIELDS[*]}")"
    done
    preserve_commit_plan
}

# Assert the full refusal contract for a one-record scenario: the PRESERVE| record still
# precedes the decision, the refusal record and the reason token are written, the pass
# exit accumulator is 1, no plan entry is appended, and no index record is produced.
merge_assert_refused() {
    run merge_drive_plan "$1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PRESERVE|tests/fixtures/cleanup_worktrees/preserve/$1/wt|notes/n.md|STILL_RELEVANT"* ]]
    [[ "$output" == *"ACTION|preserve-stage|notes/n.md|REFUSED-WOULD-REGRESS"* ]]
    [[ "$output" == *"cleanup-worktrees: refused notes/n.md: $2"* ]]
    [[ "$output" != *"ACTION|preserve-index|"* ]]
    merge_drive_plan "$1" >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 1 ]
    [ "${#PRESERVE_PLAN_STREAM[@]}" -eq 0 ]
}

# Assert that the one-record scenario planned exactly one merge-mode entry for merged01.
merge_assert_merge_entry() {
    merge_drive_plan "$1" >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 0 ]
    [ "${#PRESERVE_PLAN_STREAM[@]}" -eq 1 ]
    preserve_split_tsv "${PRESERVE_PLAN_STREAM[0]}"
    echo "plan entry columns: ${#PRESERVE_FIELDS[@]}, mode: '${PRESERVE_FIELDS[8]-}'"
    [ "${PRESERVE_FIELDS[8]-}" = "merge" ]
    [ "${PRESERVE_FIELDS[9]-}" = "merged01" ]
}

# --- library contract and pure helpers ----------------------------------------------

@test "merge library defines functions only and runs no work at source time" {
    run bash -c "source '${MLIB}'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    run bash -c "source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${MLIB}' && source '${EOLLIB}' && source '${PLIB}'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    # The functions the preserve library calls are defined by sourcing alone.
    run bash -c "source '${MLIB}' && declare -F preserve_merge_decide preserve_merge_check_duplicate"
    [ "$status" -eq 0 ]
    [[ "$output" == *"preserve_merge_decide"* ]]
}

@test "is_subsequence accepts an ordered subset and rejects a missing or reordered line" {
    run preserve_merge_is_subsequence $'a\nc\n' $'a\nb\nc\n'
    [ "$status" -eq 0 ]
    run preserve_merge_is_subsequence $'a\nd\n' $'a\nb\nc\n'
    [ "$status" -eq 1 ]
    run preserve_merge_is_subsequence $'c\na\n' $'a\nb\nc\n'
    [ "$status" -eq 1 ]
    # A repeated needle line needs two haystack occurrences.
    run preserve_merge_is_subsequence $'a\na\n' $'a\nb\n'
    [ "$status" -eq 1 ]
}

@test "is_subsequence handles empty inputs" {
    run preserve_merge_is_subsequence "" $'a\n'
    [ "$status" -eq 0 ]
    run preserve_merge_is_subsequence "" ""
    [ "$status" -eq 0 ]
    run preserve_merge_is_subsequence $'a\n' ""
    [ "$status" -eq 1 ]
}

@test "is_subsequence strips one trailing carriage return per line" {
    run preserve_merge_is_subsequence $'a\r\nb\r\n' $'a\nx\nb\n'
    [ "$status" -eq 0 ]
    run preserve_merge_is_subsequence $'a\nb\n' $'a\r\nb\r\n'
    [ "$status" -eq 0 ]
    # Only one carriage return is stripped, so a doubled one still differs.
    run preserve_merge_is_subsequence $'a\r\r\n' $'a\n'
    [ "$status" -eq 1 ]
}

@test "is_subsequence counts an unterminated final line" {
    run preserve_merge_is_subsequence $'a\nb' $'a\nb'
    [ "$status" -eq 0 ]
    # The unterminated `b` is a line, so a haystack without it is not a superset.
    run preserve_merge_is_subsequence $'a\nb' $'a\n'
    [ "$status" -eq 1 ]
    run preserve_merge_is_subsequence $'a\nb\n' $'a\r\nb'
    [ "$status" -eq 0 ]
}

@test "extra_within accepts worktree additions and an empty difference" {
    # merged, main, worktree, base
    run preserve_merge_extra_within $'m\nx\nw\n' $'m\nx\n' $'m\nw\n' $'m\n'
    [ "$status" -eq 0 ]
    run preserve_merge_extra_within $'m\nx\n' $'m\nx\n' $'m\nw\n' $'m\n'
    [ "$status" -eq 0 ]
    # Blank lines are ordinary lines and are counted like any other.
    run preserve_merge_extra_within $'m\n\nw\n' $'m\n' $'m\n\nw\n' $'m\n'
    [ "$status" -eq 0 ]
}

@test "extra_within rejects a resurrected base line and counts duplicates" {
    # Main deleted `o`; the merge re-emitted it; the worktree added only `w`.
    run preserve_merge_extra_within $'a\no\nw\nz\n' $'a\nz\n' $'a\no\nw\nz\n' $'a\no\nz\n'
    [ "$status" -eq 1 ]
    # `w` appears twice beyond main but the worktree added it once.
    run preserve_merge_extra_within $'m\nw\nw\n' $'m\n' $'m\nw\n' $'m\n'
    [ "$status" -eq 1 ]
    run preserve_merge_extra_within $'m\nw\nw\n' $'m\n' $'m\nw\nw\n' $'m\n'
    [ "$status" -eq 0 ]
}

# --- the issue repro ------------------------------------------------------------------

@test "an older modified snapshot never overwrites newer main lines" {
    # The worktree holds an older snapshot plus one note; main has since gained two notes.
    # A whole-file copy would drop both; the plan entry must instead stage the merged blob.
    run merge_drive_plan merge-repro
    [ "$status" -eq 0 ]
    [[ "$output" != *"REFUSED-WOULD-REGRESS"* ]]
    merge_assert_merge_entry merge-repro
}

# --- base-available scenarios: merge outcomes ---------------------------------------

@test "a clean merge plans the merged blob in merge mode" {
    run merge_drive_plan merge-clean
    [ "$status" -eq 0 ]
    [[ "$output" == *"cleanup-worktrees: merged notes/n.md"* ]]
    # The decision's git calls, in the shapes the library documents; none forces.
    [[ "$output" == *"hash-object -w --path=notes/n.md -- notes/n.md"* ]]
    [[ "$output" == *"merge-file --union --object-id main0001 base0001 wt000001"* ]]
    [[ "$output" == *"cat-file blob merged01"* ]]
    [[ "$output" != *" --force"* ]]
    merge_assert_merge_entry merge-clean
}

@test "both sides appending at end of file is merged with OK" {
    merge_assert_merge_entry merge-eof-union
    run merge_commit_to_null
    [ "$status" -eq 0 ]
    # The writing phase reads the merged blob and never copies the source file.
    [[ "$output" == *"cat-file blob merged01"* ]]
    [[ "$output" == *"ACTION|preserve-stage|notes/n.md|OK"* ]]
}

@test "an addition already on main merges to main content" {
    merge_assert_merge_entry merge-already-on-main
    # The stubbed merged blob is byte-identical to main's version.
    cmp "${PRES}/merge-already-on-main/cat-file.merged01.out" \
        "${PRES}/merge-already-on-main/consolidation/notes/n.md"
    run merge_commit_to_null
    [[ "$output" == *"ACTION|preserve-stage|notes/n.md|OK"* ]]
}

# --- base-available scenarios: refusals ---------------------------------------------

@test "a worktree that deleted a base line is refused by G1" {
    merge_assert_refused merge-g1 G1
    # G1 runs before any object is written or merged.
    [[ "$output" != *"merge-file"* ]]
    [[ "$output" != *"hash-object"* ]]
}

@test "a merge-file error is refused and names the git exit code" {
    merge_assert_refused merge-error "merge-file rc=129"
}

@test "a merged result missing a main line is refused by G2" {
    merge_assert_refused merge-g2 G2
}

@test "a resurrected base line is refused by G3" {
    merge_assert_refused merge-g3 G3
}

# --- absent targets and the help text -----------------------------------------------

@test "an absent target is copied with no decision git call" {
    local scen
    for scen in modified untracked; do
        run merge_drive_plan "$scen" /dev
        [ "$status" -eq 0 ]
        [[ "$output" != *"merge-file"* ]]
        [[ "$output" != *"hash-object"* ]]
        [[ "$output" != *"merge-base"* ]]
        [[ "$output" != *"rev-parse"* ]]
        merge_drive_plan "$scen" /dev >/dev/null 2>&1
        [ "${#PRESERVE_PLAN_STREAM[@]}" -eq 1 ]
        preserve_split_tsv "${PRESERVE_PLAN_STREAM[0]}"
        [ "${PRESERVE_FIELDS[8]-}" = "copy" ]
        [ -z "${PRESERVE_FIELDS[9]-}" ]
    done
}

@test "--help documents REFUSED-WOULD-REGRESS" {
    run bash "${WRAP}" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"REFUSED-WOULD-REGRESS"* ]]
}
