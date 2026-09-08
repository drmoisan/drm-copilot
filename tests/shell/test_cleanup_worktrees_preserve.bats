#!/usr/bin/env bats
# Preserve-file consolidation unit tests for
# scripts/bash/cleanup_worktrees_preserve_lib.sh. Sources the enumerate, classification,
# actions, and preserve libraries and drives the preserve functions through the
# checked-in git and jq stubs. Fixtures live under
# tests/fixtures/cleanup_worktrees/preserve/. No temporary files; no scratch git
# repositories; no real jq is ever invoked.
#
# There is no shared bats helper library in this tree, so the setup block duplicates the
# idiom used by tests/shell/test_cleanup_worktrees_consolidation.bats and adds the paths
# this suite needs.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ELIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_enumerate_lib.sh"
    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
    ALIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_actions_lib.sh"
    PLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_preserve_lib.sh"
    WRAP="${REPO_ROOT}/scripts/bash/cleanup-worktrees.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    JQSTUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq"
    PRES="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/preserve"
    # preserve_resolve_jq accepts CLEANUP_WT_JQ_BIN only when the value is executable, so
    # a non-executable stub would silently fall through to a real jq on the host.
    chmod +x "${STUB}" "${JQSTUB}" 2>/dev/null || true
}

# --- git stub case coverage (AC-32) -----------------------------------------------
# Both tests drive the stub directly rather than through the library, because the
# behavior under test belongs to the stub itself. Each asserts a NON-default exit code:
# the stub's default arm and its `respond` default both exit 0, so an assertion of 0
# would pass even if the new case arm were absent.

@test "the git stub replays a scenario response for add" {
    run env CLEANUP_WT_STUB_SCENARIO="${PRES}/stub-keys/add-fails" \
        "${STUB}" -C /repo-wt/dm add -- docs/target.md
    [ "$status" -eq 1 ]
    [[ "$output" == *"stub-git: -C /repo-wt/dm add -- docs/target.md"* ]]
    [[ "$output" == *"stub-add-failed"* ]]
}

@test "the git stub replays a scenario response for check-ignore" {
    run env CLEANUP_WT_STUB_SCENARIO="${PRES}/stub-keys/not-ignored" \
        "${STUB}" -C /repo-wt/dm check-ignore -q -- docs/target.md
    [ "$status" -eq 1 ]
    [[ "$output" == *"stub-git: -C /repo-wt/dm check-ignore -q -- docs/target.md"* ]]
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

# --- preserve driver behavior (AC-08, AC-16, AC-22) ---------------------------------
# Every test below drives the production preserve functions through the manifest, jq,
# git, and consolidation seams against checked-in fixtures. The destination for the
# untracked and host-token scenarios is the null device
# (CLEANUP_WT_CONSOLIDATION_PATH=/dev with a target_path of `null`), so the byte copy
# writes to /dev/null and no file is created anywhere; /dev/null is a character device,
# not a temporary file.

@test "an untracked preserve record is staged and reported" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" \
        CLEANUP_WT_JQ_BIN="${JQSTUB}" \
        CLEANUP_WT_STUB_SCENARIO="${PRES}/untracked" \
        CLEANUP_WT_MANIFEST_PATH="${PRES}/untracked/manifest.json" \
        CLEANUP_WT_CONSOLIDATION_PATH=/dev \
        bash -c "cd '${REPO_ROOT}' && source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${PLIB}' && run_preserve"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PRESERVE|tests/fixtures/cleanup_worktrees/preserve/untracked/wt|agent-memory/atomic-executor/lesson.md|GENUINELY_NEW"* ]]
    [[ "$output" == *"ACTION|preserve-stage|null|OK"* ]]
    [[ "$output" == *"add -- null"* ]]
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
        bash -c "cd '${REPO_ROOT}' && source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${PLIB}' && preserve_plan"
    [ "$status" -eq 0 ]
    [[ "$output" == *"ACTION|preserve-eol|"*"ADVISORY-MISMATCH"* ]]
    [[ "$output" == *"agent-memory/atomic-executor/MEMORY.md"* ]]
    # The stale advisory value must not have reached the destination index.
    local index_content
    index_content="$(cat "${PRES}/eol-stale/consolidation/agent-memory/atomic-executor/MEMORY.md")"
    [[ "$index_content" != *$'\r'* ]]
}

@test "a host token match aborts the pass before any staging" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" \
        CLEANUP_WT_JQ_BIN="${JQSTUB}" \
        CLEANUP_WT_STUB_SCENARIO="${PRES}/host-token" \
        CLEANUP_WT_MANIFEST_PATH="${PRES}/host-token/manifest.json" \
        CLEANUP_WT_CONSOLIDATION_PATH=/dev \
        bash -c "cd '${REPO_ROOT}' && source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${PLIB}' && run_preserve"
    [ "$status" -eq 3 ]
    # The record's own host_token_scan.result is `clean`, so a pass that trusted the
    # advisory value instead of scanning the source bytes would have staged it. The
    # absence assertion names the operand the staging call would carry, not the bare
    # word `add`: the stub logs its full argv including the leading `-C <worktree>`, so
    # an assertion against the literal `stub-git: add` could never match and so could
    # never fail.
    [[ "$output" != *"add -- null"* ]]
}

