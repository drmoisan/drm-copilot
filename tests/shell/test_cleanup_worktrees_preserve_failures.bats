#!/usr/bin/env bats
# Failure-path unit tests for the preserve-file consolidation function group defined by
# scripts/bash/cleanup_worktrees_preserve_lib.sh.
#
# Why a third suite file. tests/shell/test_cleanup_worktrees_preserve.bats stands at 471
# of the 500-line cap and tests/shell/test_cleanup_worktrees_preserve_eol.bats carries the
# line-ending and MEMORY.md index group, which is not what these tests exercise. The split
# follows the convention the pre-authorized library and suite splits used: the name extends
# the existing pair and the file is discovered by the same `bats tests/shell` invocation,
# because scripts/bash/shell_qc_lib.sh runs bats against the directory rather than against
# an enumerated file list.
#
# Scope. Every test here drives a refusal, a skip, or a write failure: the record-validation
# reasons that no happy-path fixture reaches, the upstream `tokens_present` short circuit,
# the manifest rejection as it surfaces through the two-phase driver, the five distinct
# failure branches of the writing phase, and the index-line half of the host-token scan.
#
# No temporary files. The destination for every writing scenario is the null device and the
# failing destinations are paths *under* the null device, which is a character device and
# not a directory, so `mkdir -p` and an append against them fail deterministically without
# anything being created anywhere.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    ALIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_actions_lib.sh"
    EOLLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_preserve_eol_lib.sh"
    PLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_preserve_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    JQSTUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq"
    PRES="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/preserve"
    CF="${PRES}/commit-failures"
    SRC="${CF}/wt/agent-memory/atomic-executor/commit-lesson.md"
    # preserve_resolve_jq accepts CLEANUP_WT_JQ_BIN only when the value is executable, so
    # a non-executable stub would silently fall through to a real jq on the host.
    chmod +x "${STUB}" "${JQSTUB}" 2>/dev/null || true
    cd "${REPO_ROOT}" || return 1
    source "${ELIB}"
    source "${LIB}"
    source "${ALIB}"
    source "${EOLLIB}"
    source "${PLIB}"
    return 0
}

# Build one 14-column record from positional column values, so a test states only the
# column it is varying and the reader can see which one that is.
preserve_make_record() {
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s' \
        "${1-}" "${2-}" "${3-}" "${4-}" "${5-}" "${6-}" "${7-}" \
        "${8-}" "${9-}" "${10-}" "${11-}" "${12-}" "${13-}" "${14-}"
}

# A record every field of which is valid, varied through the two arguments the tests below
# need: $1 replaces source_path and $2 replaces target_path.
preserve_valid_record() {
    preserve_make_record \
        "tests/fixtures/cleanup_worktrees/preserve/commit-failures/wt" \
        "${1:-agent-memory/atomic-executor/commit-lesson.md}" \
        untracked PRESERVE GENUINELY_NEW "${2:-null}" \
        true true "" absent object clean cleanup-wt-host-tokens-v1 \
        "preserve/commit-failures fixture record"
}

# --- record-validation reasons that no happy-path fixture reaches -------------------
# These three reasons are unreachable through a manifest fixture: jq emits `true` or
# `false` for the is-null column and always emits fourteen columns, and the `..` reason is
# only reachable for a value the field-matrix fixtures do not carry. Each is therefore
# asserted against preserve_validate_record directly, which is the function that owns it.

@test "a dot dot segment in source_path or target_path skips the record and reports" {
    # Half one: the source side. The reason names the field, so a chain that reported the
    # wrong field's violation would fail this assertion rather than pass it.
    run preserve_validate_record "$(preserve_valid_record '../outside/lesson.md')"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ACTION|preserve-stage|null|SKIPPED-INVALID"* ]]
    [[ "$output" == *"source_path contains a .. segment: ../outside/lesson.md"* ]]
    # Half two: the target side. A `..` in the middle of the value is asserted rather than
    # a leading one, because a leading-only check would pass a traversal that escapes the
    # consolidation worktree from a subdirectory.
    run preserve_validate_record "$(preserve_valid_record 'agent-memory/atomic-executor/commit-lesson.md' 'docs/../secret.md')"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ACTION|preserve-stage|docs/../secret.md|SKIPPED-INVALID"* ]]
    [[ "$output" == *"target_path contains a .. segment: docs/../secret.md"* ]]
}

@test "a record carrying fewer than fourteen columns is skipped and reports its count" {
    # The column count is checked before every field test, because a short record's later
    # columns are absent rather than invalid and would otherwise be reported as the wrong
    # violation. target_path is itself absent here, so the result record's target field is
    # legitimately empty.
    run preserve_validate_record "$(printf 'wt\tsrc/lesson.md\tuntracked')"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ACTION|preserve-stage||SKIPPED-INVALID"* ]]
    [[ "$output" == *"record carries 3 columns, expected 14"* ]]
}

@test "a memory_index_line that is neither a string nor null is skipped and reported" {
    # The key-presence column says the key is present; the is-null column carries a value
    # outside the two the contract defines. The record is refused rather than guessed at.
    local rec
    rec="$(preserve_make_record \
        wt src/lesson.md untracked PRESERVE GENUINELY_NEW docs/target.md \
        true unknown "" absent object clean cleanup-wt-host-tokens-v1 evidence)"
    run preserve_validate_record "$rec"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ACTION|preserve-stage|docs/target.md|SKIPPED-INVALID"* ]]
    [[ "$output" == *"memory_index_line is neither a string nor null"* ]]
}

# --- the upstream short circuit and the manifest rejection through the driver -------

@test "an upstream tokens_present result blocks the pass without a local scan" {
    # The fixture's own bytes carry no host token, so a pass that ignored the upstream
    # result and relied only on the local scan would stage this record and exit 0. The
    # assertion that the exit code is 3 and that no add argv was logged pins both halves.
    run env CLEANUP_WT_GIT_BIN="${STUB}" \
        CLEANUP_WT_JQ_BIN="${JQSTUB}" \
        CLEANUP_WT_STUB_SCENARIO="${PRES}/upstream-tokens" \
        CLEANUP_WT_MANIFEST_PATH="${PRES}/upstream-tokens/manifest.json" \
        CLEANUP_WT_CONSOLIDATION_PATH=/dev \
        bash -c "cd '${REPO_ROOT}' && source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${EOLLIB}' && source '${PLIB}' && run_preserve"
    [ "$status" -eq 3 ]
    [[ "$output" == *"ACTION|preserve-stage|null|HOST-TOKEN-BLOCKED"* ]]
    [[ "$output" == *"the manifest reports tokens_present for"* ]]
    # The operand-anchored expression, not the bare word `add`: the stub logs its full argv
    # including the leading `-C <worktree>`, so a literal `stub-git: add` could never match.
    local add_re='stub-git: .*[[:space:]]add[[:space:]]'
    [[ ! "$output" =~ $add_re ]]
    # The source file really is clean, so the refusal came from the upstream value.
    run grep -c -E -e '/home/[a-z]' "${PRES}/upstream-tokens/wt/agent-memory/atomic-executor/upstream-flagged-lesson.md"
    [ "$status" -eq 1 ]
}

@test "a rejected manifest is re-emitted by the driver and stops the pass" {
    # preserve_plan captures preserve_read_manifest's stdout into a variable, which
    # swallows the REJECTED record. The record has to be re-emitted or the operator sees a
    # non-zero exit with no machine-readable reason at all. Driving run_preserve rather
    # than preserve_read_manifest is what makes that re-emission observable.
    run env CLEANUP_WT_GIT_BIN="${STUB}" \
        CLEANUP_WT_JQ_BIN="${JQSTUB}" \
        CLEANUP_WT_STUB_SCENARIO="${PRES}/bad-schema" \
        CLEANUP_WT_MANIFEST_PATH="${PRES}/bad-schema/manifest.json" \
        CLEANUP_WT_CONSOLIDATION_PATH=/dev \
        bash -c "cd '${REPO_ROOT}' && source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${EOLLIB}' && source '${PLIB}' && run_preserve"
    [ "$status" -eq 1 ]
    [[ "$output" == *"ACTION|preserve-manifest|${PRES}/bad-schema/manifest.json|REJECTED"* ]]
    # Nothing was staged: the writing phase was never entered.
    local add_re='stub-git: .*[[:space:]]add[[:space:]]'
    [[ ! "$output" =~ $add_re ]]
}

# --- the five failure branches of the writing phase ---------------------------------
# Each test builds a one-entry plan stream directly rather than driving a manifest, because
# the branch under test is selected by the *result of a write*, which a manifest fixture
# cannot express. The eight columns are the ones preserve_plan_one emits: target_path,
# source file, destination file, index action, index path, index line, terminator token,
# and the leading-terminator flag.

preserve_commit_one() {
    PRESERVE_CWT=/dev
    PRESERVE_EXIT=0
    PRESERVE_PLAN_STREAM=()
    local entry
    printf -v entry '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s' \
        "${1-}" "${2-}" "${3-}" "${4-}" "${5-}" "${6-}" "${7-}" "${8-}"
    PRESERVE_PLAN_STREAM=("$entry")
    preserve_commit_plan
}

@test "a destination directory that cannot be created is reported as FAILED" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    # /dev/null is a character device, so /dev/null/nested is not creatable and no
    # directory is created anywhere by this test.
    run preserve_commit_one null "${SRC}" /dev/null/nested/lesson.md none "" "" lf no
    [[ "$output" == *"ACTION|preserve-stage|null|FAILED"* ]]
    [[ "$output" == *"cannot create the destination directory: null"* ]]
    # The copy was not attempted and nothing was staged: the branch is first in the chain.
    local add_re='stub-git: .*[[:space:]]add[[:space:]]'
    [[ ! "$output" =~ $add_re ]]
    # The failure contributes to exit 1 rather than aborting the remaining records.
    # preserve_commit_plan is re-run outside `run` so the accumulator is visible here.
    preserve_commit_one null "${SRC}" /dev/null/nested/lesson.md none "" "" lf no >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 1 ]
}

@test "a failed verbatim byte copy is reported as FAILED" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    # The destination directory is /dev, which exists, so mkdir succeeds and the copy is
    # the operation that fails: the named source does not exist.
    local absent="${CF}/wt/agent-memory/atomic-executor/absent-lesson.md"
    [ ! -e "$absent" ]
    run preserve_commit_one null "$absent" /dev/null none "" "" lf no
    [[ "$output" == *"ACTION|preserve-stage|null|FAILED"* ]]
    [[ "$output" == *"the verbatim byte copy failed: null"* ]]
    local add_re='stub-git: .*[[:space:]]add[[:space:]]'
    [[ ! "$output" =~ $add_re ]]
    preserve_commit_one null "$absent" /dev/null none "" "" lf no >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 1 ]
}

@test "a failed index append is reported as FAILED" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    # mkdir and the copy both succeed; the append is the operation that fails, because its
    # destination is a path under the null device rather than a directory entry.
    run preserve_commit_one null "${SRC}" /dev/null append /dev/null/MEMORY.md "- [Commit lesson](commit-lesson.md)" lf no
    [[ "$output" == *"ACTION|preserve-stage|null|FAILED"* ]]
    [[ "$output" == *"the index append failed: null"* ]]
    # The staging call is not reached: an index that could not be written must not be
    # followed by a commit that looks as though it carried the entry.
    local add_re='stub-git: .*[[:space:]]add[[:space:]]'
    [[ ! "$output" =~ $add_re ]]
    preserve_commit_one null "${SRC}" /dev/null append /dev/null/MEMORY.md "- [Commit lesson](commit-lesson.md)" lf no >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 1 ]
}

@test "a failed staging call is reported as FAILED" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    # The scenario supplies add.null.rc = 1, so the staging call is the first operation in
    # the chain that fails; every earlier one is exercised and succeeds.
    export CLEANUP_WT_STUB_SCENARIO="${CF}/stage-fails"
    run preserve_commit_one null "${SRC}" /dev/null none "" "" lf no
    [[ "$output" == *"stub-git: -C /dev add -- null"* ]]
    [[ "$output" == *"ACTION|preserve-stage|null|FAILED"* ]]
    [[ "$output" == *"the staging call failed: null"* ]]
    [[ "$output" != *"|OK"* ]]
    preserve_commit_one null "${SRC}" /dev/null none "" "" lf no >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 1 ]
}

@test "a failed index staging call is reported as FAILED" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    # The scenario answers the target's own add with the default success and the index
    # path's add with 1, so the last branch of the chain is the one that fires. Both argv
    # lines are asserted, which is what distinguishes this branch from the previous test.
    export CLEANUP_WT_STUB_SCENARIO="${CF}/index-stage-fails"
    run preserve_commit_one null "${SRC}" /dev/null append /dev/null "- [Commit lesson](commit-lesson.md)" lf no
    [[ "$output" == *"stub-git: -C /dev add -- null"* ]]
    [[ "$output" == *"stub-git: -C /dev add -- /dev/null"* ]]
    [[ "$output" == *"ACTION|preserve-stage|null|FAILED"* ]]
    [[ "$output" == *"staging the index failed: null"* ]]
    preserve_commit_one null "${SRC}" /dev/null append /dev/null "- [Commit lesson](commit-lesson.md)" lf no >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 1 ]
}

# --- the index-line half of the host-token scan -------------------------------------

@test "a host token carried by the index line refuses the record" {
    # The scan reads two things: the source file's bytes and the index line's bytes. Every
    # existing test drives the first. This one drives the second, with a source file that
    # is clean, so a scan that read only the file would report no match at all.
    local iline
    iline="$(cat "${CF}/index-line-with-token.txt")"
    run preserve_scan_host_tokens "${SRC}" "$iline"
    [ "$status" -eq 1 ]
    [[ "$output" == *"host token matched (HT3) in the index line"* ]]
    [[ "$output" != *"in ${SRC}"* ]]
    # The same source file with no index line is clean, so the refusal above is caused by
    # the index line and not by the file.
    run preserve_scan_host_tokens "${SRC}" ""
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
