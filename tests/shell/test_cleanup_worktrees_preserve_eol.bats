#!/usr/bin/env bats
# Line-ending unit tests for the preserve-file consolidation function group, split out of
# tests/shell/test_cleanup_worktrees_preserve.bats to keep every file within the 500-line
# cap. The split is pre-authorized by the specification's placement decision. This file
# holds the tests for scripts/bash/cleanup_worktrees_preserve_eol_lib.sh: line-ending
# re-derivation, the index append terminator, the unterminated final line, the mixed
# ending refusal, and the advisory mismatch signal.
#
# There is no shared bats helper library in this tree, so the setup block below duplicates
# the one in tests/shell/test_cleanup_worktrees_preserve.bats rather than sharing it.
# Fixtures live under tests/fixtures/cleanup_worktrees/preserve/. No temporary files; no
# scratch git repositories; no real jq is ever invoked.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    ALIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_actions_lib.sh"
    EOLLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_preserve_eol_lib.sh"
    PLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_preserve_lib.sh"
    WRAP="${REPO_ROOT}/scripts/bash/cleanup-worktrees.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    JQSTUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq"
    PRES="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/preserve"
    # preserve_resolve_jq accepts CLEANUP_WT_JQ_BIN only when the value is executable, so
    # a non-executable stub would silently fall through to a real jq on the host.
    chmod +x "${STUB}" "${JQSTUB}" 2>/dev/null || true
    # Every manifest record names its worktree by a repo-relative path, so the working
    # directory has to be the repository root for the tests to be independent of where
    # bats was invoked from.
    cd "${REPO_ROOT}" || return 1
    # The five libraries are sourced here so the tests can call the production functions
    # directly instead of rebuilding a source chain in every test body. The source-guard
    # test deliberately does not rely on this: it sources the chain again in a fresh
    # subshell, which is the only place the no-work-at-source-time property is observable.
    source "${ELIB}"
    source "${LIB}"
    source "${ALIB}"
    source "${EOLLIB}"
    source "${PLIB}"
    return 0
}

# --- checked-in CRLF fixture integrity (AC-20) --------------------------------------
# This test fails if the `.gitattributes` `-text` exception for the eol-crlf directory is
# removed, misspelled, or ordered before the `* text=auto eol=lf` line, because git then
# normalizes the fixture to LF in the index and checks it out as LF.

@test "the crlf fixture still contains a carriage return in the working tree" {
    [ -f "${PRES}/eol-crlf/MEMORY.md" ]
    # Detection is done in bash rather than with `grep -c $'\r'` deliberately: grep on
    # some hosts opens the file in text mode and strips the carriage returns before
    # matching, so a grep-based assertion reports zero matches on a fixture that does
    # carry them. `cat` is byte-exact and command substitution preserves CR, stripping
    # only trailing newlines.
    local content
    content="$(cat "${PRES}/eol-crlf/MEMORY.md")"
    [[ "$content" == *$'\r'* ]]
}

@test "a stale advisory crlf value does not override an LF target" {
    # preserve_plan is the read-only phase (D6): it derives each index target's
    # line-ending convention and emits the advisory-mismatch record before anything is
    # written. Phase 1 is driven here rather than the whole pass because the whole pass
    # would append to the checked-in destination index, and the no-temporary-files rule
    # forbids the test from making a writable copy of that index first.
    run env CLEANUP_WT_GIT_BIN="${STUB}" \
        CLEANUP_WT_JQ_BIN="${JQSTUB}" \
        CLEANUP_WT_STUB_SCENARIO="${PRES}/eol-stale" \
        CLEANUP_WT_MANIFEST_PATH="${PRES}/eol-stale/manifest.json" \
        CLEANUP_WT_CONSOLIDATION_PATH="${PRES}/eol-stale/consolidation" \
        bash -c "cd '${REPO_ROOT}' && source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${EOLLIB}' && source '${PLIB}' && preserve_plan"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ACTION|preserve-eol|"*"ADVISORY-MISMATCH"* ]]
    [[ "$output" == *"agent-memory/atomic-executor/MEMORY.md"* ]]
    # The stale advisory value must not have reached the destination index.
    local index_content
    index_content="$(cat "${PRES}/eol-stale/consolidation/agent-memory/atomic-executor/MEMORY.md")"
    [[ "$index_content" != *$'\r'* ]]
}

# --- line-ending re-derivation (AC-15, AC-17, AC-18, AC-19) -------------------------
# Every assertion below is on BYTES rather than on parsed text. This repository is
# developed on Windows and several tools in the chain rewrite line endings, so an
# assertion that reads the rendered line as text would pass whatever terminator was
# actually written.

@test "an unterminated final line receives a terminator before the append" {
    local index="${PRES}/eol-unterminated/consolidation/agent-memory/atomic-executor/MEMORY.md"
    # The fixture's final byte is not a line feed, so a terminator is owed.
    run preserve_index_needs_terminator "$index"
    [ "$status" -eq 0 ]
    # The negative control: a fixture whose final byte IS a line feed owes nothing. Without
    # it this test would pass against an implementation that always answered yes.
    run preserve_index_needs_terminator "${PRES}/index-append/consolidation/agent-memory/atomic-executor/MEMORY.md"
    [ "$status" -eq 1 ]
    # The rendered bytes therefore begin with the terminator, so the new entry cannot be
    # concatenated onto the existing final entry. The count is taken on the RAW stream
    # rather than on `$output`: command substitution strips trailing line feeds, and on a
    # Windows host it strips a trailing CRLF pair whole, so a comparison against a captured
    # string is not a byte observation on every platform. Counting line feeds through a
    # pipe is.
    local line="- [Unterminated lesson](unterminated-lesson.md) - appended after a terminator"
    run bash -c "source '${EOLLIB}' && preserve_render_index_append /dev/stdout '${line}' lf yes | tr -dc '\n' | wc -c"
    [ "$status" -eq 0 ]
    [ "$output" -eq 2 ]
    # The control: with nothing owed, exactly one line feed is written.
    run bash -c "source '${EOLLIB}' && preserve_render_index_append /dev/stdout '${line}' lf no | tr -dc '\n' | wc -c"
    [ "$status" -eq 0 ]
    [ "$output" -eq 1 ]
}

@test "an advisory line ending mismatch emits ADVISORY-MISMATCH" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    # The index target is LF terminated; the advisory value passed here says crlf.
    run preserve_plan_index "agent-memory/atomic-executor/appended-lesson.md" \
        "- [Appended lesson](appended-lesson.md)" crlf "${PRES}/index-append/consolidation"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ACTION|preserve-eol|"*"MEMORY.md|ADVISORY-MISMATCH"* ]]
    # The re-derived value governs the write, not the advisory one.
    preserve_plan_index "agent-memory/atomic-executor/appended-lesson.md" \
        "- [Appended lesson](appended-lesson.md)" crlf "${PRES}/index-append/consolidation" >/dev/null 2>&1
    [ "$PRESERVE_INDEX_TERM" = "lf" ]
    # The negative control: an advisory value that agrees emits no mismatch record.
    run preserve_plan_index "agent-memory/atomic-executor/appended-lesson.md" \
        "- [Appended lesson](appended-lesson.md)" lf "${PRES}/index-append/consolidation"
    [[ "$output" != *"ADVISORY-MISMATCH"* ]]
}

@test "a crlf target receives a crlf terminated index line" {
    run preserve_derive_line_ending "${PRES}/eol-crlf/MEMORY.md"
    [ "$status" -eq 0 ]
    [ "$output" = "crlf" ]
    # The terminator is asserted in BYTES, counted on the raw stream. `$output` is not used
    # for this: command substitution strips trailing line feeds, and on a Windows host it
    # strips a trailing CRLF pair whole, so both terminators would capture as the empty
    # string and the assertion could not fail. Counting bytes through a pipe discriminates
    # on every platform.
    run bash -c "source '${EOLLIB}' && preserve_line_terminator crlf | wc -c"
    [ "$status" -eq 0 ]
    [ "$output" -eq 2 ]
    run bash -c "source '${EOLLIB}' && preserve_line_terminator lf | wc -c"
    [ "$status" -eq 0 ]
    [ "$output" -eq 1 ]
    # The writer selects from that same function, so a CRLF index receives a CRLF
    # terminated line end to end. One carriage return is written for the crlf token and
    # none at all for the lf token.
    local line="- [Crlf lesson](crlf-lesson.md) - appended to a carriage return index"
    run bash -c "source '${EOLLIB}' && preserve_render_index_append /dev/stdout '${line}' crlf no | tr -dc '\r' | wc -c"
    [ "$status" -eq 0 ]
    [ "$output" -eq 1 ]
    run bash -c "source '${EOLLIB}' && preserve_render_index_append /dev/stdout '${line}' lf no | tr -dc '\r' | wc -c"
    [ "$status" -eq 0 ]
    [ "$output" -eq 0 ]
}

@test "a mixed line ending target is refused and reported as EOL-MIXED" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/eol-mixed"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/eol-mixed/manifest.json"
    # The index target lives under preserve/eol-crlf/mixed-index/, which the existing
    # .gitattributes `-text` exception covers, so its carriage returns survive checkout.
    export CLEANUP_WT_CONSOLIDATION_PATH="${PRES}/eol-crlf/mixed-index"
    run preserve_derive_line_ending "${PRES}/eol-crlf/mixed-index/agent-memory/atomic-executor/MEMORY.md"
    [ "$output" = "mixed" ]
    run preserve_plan
    [ "$status" -eq 0 ]
    [[ "$output" == *"|EOL-MIXED"* ]]
    # The record is skipped entirely: no copy, no stage, no append is planned for it.
    [[ "$output" != *"ACTION|preserve-index|"*"|OK"* ]]
    preserve_plan >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 1 ]
    [ "${#PRESERVE_PLAN_STREAM[@]}" -eq 0 ]
}
