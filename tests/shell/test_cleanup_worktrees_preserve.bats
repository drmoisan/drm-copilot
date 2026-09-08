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

# --- preserve driver behavior (AC-08, AC-22) ----------------------------------------
# Every test below drives the production preserve functions through the manifest, jq,
# git, and consolidation seams against checked-in fixtures. The line-ending tests,
# including AC-16, live in tests/shell/test_cleanup_worktrees_preserve_eol.bats. The
# destination for the untracked and host-token scenarios is the null device
# (CLEANUP_WT_CONSOLIDATION_PATH=/dev with a target_path of `null`), so the byte copy
# writes to /dev/null and no file is created anywhere; /dev/null is a character device,
# not a temporary file.

@test "an untracked preserve record is staged and reported" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" \
        CLEANUP_WT_JQ_BIN="${JQSTUB}" \
        CLEANUP_WT_STUB_SCENARIO="${PRES}/untracked" \
        CLEANUP_WT_MANIFEST_PATH="${PRES}/untracked/manifest.json" \
        CLEANUP_WT_CONSOLIDATION_PATH=/dev \
        bash -c "cd '${REPO_ROOT}' && source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${EOLLIB}' && source '${PLIB}' && run_preserve"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PRESERVE|tests/fixtures/cleanup_worktrees/preserve/untracked/wt|agent-memory/atomic-executor/lesson.md|GENUINELY_NEW"* ]]
    [[ "$output" == *"ACTION|preserve-stage|null|OK"* ]]
    [[ "$output" == *"add -- null"* ]]
}

@test "a host token match aborts the pass before any staging" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" \
        CLEANUP_WT_JQ_BIN="${JQSTUB}" \
        CLEANUP_WT_STUB_SCENARIO="${PRES}/host-token" \
        CLEANUP_WT_MANIFEST_PATH="${PRES}/host-token/manifest.json" \
        CLEANUP_WT_CONSOLIDATION_PATH=/dev \
        bash -c "cd '${REPO_ROOT}' && source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${EOLLIB}' && source '${PLIB}' && run_preserve"
    [ "$status" -eq 3 ]
    # The record's own host_token_scan.result is `clean`, so a pass that trusted the
    # advisory value instead of scanning the source bytes would have staged it.
    [[ "$output" == *"|HOST-TOKEN-BLOCKED"* ]]
    # The absence assertion is the plan's prescribed operand-anchored expression, not the
    # bare word `add`: the stub logs its full argv including the leading `-C <worktree>`,
    # so an assertion against the literal `stub-git: add` could never match and so could
    # never fail. The same expression is used by the ignored-target test, so the two
    # refusal paths are asserted identically.
    local add_re='stub-git: .*[[:space:]]add[[:space:]]'
    [[ ! "$output" =~ $add_re ]]
}


# --- library contract, tool resolution, and record validation (AC-01, AC-05, AC-06,
# --- AC-26, AC-28) ------------------------------------------------------------------
# Each test below drives a function this phase creates, so none of them depends on a
# function a later phase adds.

@test "preserve library defines functions only and runs no work at source time" {
    # A fresh subshell is used rather than the already-sourced setup chain, because the
    # property under test is observable only at the moment of sourcing.
    #
    # Case one: the line-ending and index library, which the pre-authorized split created
    # and which is subject to the same source-time guard as every sibling.
    run bash -c "source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${EOLLIB}'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
    # Case two: the full chain including the preserve library itself.
    run bash -c "source '${ELIB}' && source '${LIB}' && source '${ALIB}' && source '${EOLLIB}' && source '${PLIB}'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "an unresolvable jq returns 127 and stages nothing" {
    # The test is independent of whether a real jq is installed on the host: the override
    # names a path that is not executable AND PATH is pointed at a checked-in fixture
    # directory that contains no jq. `command -v` is a bash builtin, so the function under
    # test needs nothing on PATH. /bin/bash is named by absolute path so env does not have
    # to resolve it through the stripped PATH.
    run env CLEANUP_WT_JQ_BIN="${PRES}/no-jq/jq" PATH="${PRES}/no-jq" \
        /bin/bash -c "source '${PLIB}' && preserve_resolve_jq"
    [ "$status" -eq 127 ]
    # Two assertions, not one. Bash returns 127 for `command not found`, so a failed
    # source, a misspelled function name, or a not-yet-existing function would all produce
    # 127 and pass a status-only assertion without the resolution logic having run. The
    # diagnostic token distinguishes the two sources of 127.
    [[ "$output" == *"no jq binary resolved"* ]]
    [[ "$output" != *"command not found"* ]]
    # Nothing was staged: no git invocation was made at all.
    [[ "$output" != *"stub-git:"* ]]
}

@test "a manifest with a wrong tool or schema_version is rejected and stages nothing" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    local scen
    for scen in bad-tool bad-schema; do
        export CLEANUP_WT_STUB_SCENARIO="${PRES}/${scen}"
        run preserve_read_manifest "${PRES}/${scen}/manifest.json"
        [ "$status" -eq 1 ]
        [[ "$output" == *"ACTION|preserve-manifest|${PRES}/${scen}/manifest.json|REJECTED"* ]]
        [[ "$output" != *"stub-git:"* ]]
    done
}

@test "an absent or malformed host_token_scan refuses to stage the record" {
    local case_dir record count=0
    for case_dir in "${PRES}"/scan-malformed/*/; do
        record="$(cat "${case_dir}jq.out")"
        run preserve_validate_record "$record"
        [ "$status" -eq 1 ]
        [[ "$output" == *"|SKIPPED-INVALID"* ]]
        [[ "$output" == *"host_token_scan"* ]]
        count=$((count + 1))
    done
    # The count is asserted because a glob that matched no directory would leave every
    # assertion above unexecuted and the test would pass having checked nothing.
    [ "$count" -eq 5 ]
}

@test "each missing or out of vocabulary field skips the record and reports" {
    local case_dir record count=0
    for case_dir in "${PRES}"/field-matrix/*/; do
        record="$(cat "${case_dir}jq.out")"
        run preserve_validate_record "$record"
        [ "$status" -eq 1 ]
        [[ "$output" == *"|SKIPPED-INVALID"* ]]
        count=$((count + 1))
    done
    # One case per skip-bearing field of the D4 table: worktree_path, source_path,
    # change_class, disposition, verdict, target_path, memory_index_line, evidence.
    [ "$count" -eq 8 ]
}

# --- dispatch, preconditions, ordering, and per-record outcomes (AC-02, AC-03, AC-04,
# --- AC-07, AC-09, AC-10, AC-12, AC-29, AC-30, AC-31) --------------------------------
# The destination for every writing scenario below is the null device
# (CLEANUP_WT_CONSOLIDATION_PATH=/dev with a target_path of `null`), so the byte copy
# writes to /dev/null and no file is created anywhere. /dev/null is a character device,
# not a temporary file, so the no-temporary-files rule is satisfied in substance as well
# as in letter.

@test "preserve subcommand dispatches to the preserve driver" {
    run env CLEANUP_WT_GIT_BIN="${STUB}" \
        CLEANUP_WT_JQ_BIN="${JQSTUB}" \
        CLEANUP_WT_STUB_SCENARIO="${PRES}/modified" \
        CLEANUP_WT_MANIFEST_PATH="${PRES}/modified/manifest.json" \
        CLEANUP_WT_CONSOLIDATION_PATH=/dev \
        bash "${WRAP}" preserve
    [ "$status" -eq 0 ]
    # Reaching this record is only possible through the new dispatch arm: no other arm
    # calls run_preserve.
    [[ "$output" == *"ACTION|preserve-stage|null|OK"* ]]
}

@test "an unknown subcommand still prints usage to stderr and returns 2" {
    run bash "${WRAP}" bogus
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage: cleanup-worktrees.sh"* ]]
}

@test "the manifest path is taken from CLEANUP_WT_MANIFEST_PATH" {
    # Half one: an override naming a path that does not exist is reported verbatim, which
    # is only possible if the override was read.
    run env CLEANUP_WT_GIT_BIN="${STUB}" \
        CLEANUP_WT_JQ_BIN="${JQSTUB}" \
        CLEANUP_WT_MANIFEST_PATH="${PRES}/no-worktree/absent-manifest.json" \
        CLEANUP_WT_CONSOLIDATION_PATH=/dev \
        bash "${WRAP}" preserve
    [ "$status" -eq 1 ]
    [[ "$output" == *"ACTION|preserve-manifest|${PRES}/no-worktree/absent-manifest.json|MISSING"* ]]
    # Half two: an override naming a manifest that does exist is the one actually read.
    run env CLEANUP_WT_GIT_BIN="${STUB}" \
        CLEANUP_WT_JQ_BIN="${JQSTUB}" \
        CLEANUP_WT_STUB_SCENARIO="${PRES}/modified" \
        CLEANUP_WT_MANIFEST_PATH="${PRES}/modified/manifest.json" \
        CLEANUP_WT_CONSOLIDATION_PATH=/dev \
        bash "${WRAP}" preserve
    [ "$status" -eq 0 ]
    [[ "$output" == *"agent-memory/atomic-executor/modified-lesson.md"* ]]
}

@test "a missing consolidation worktree reports MISSING-WORKTREE and stages nothing" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/no-worktree"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/no-worktree/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH="${PRES}/no-worktree/absent-consolidation-worktree"
    run run_preserve
    [ "$status" -eq 1 ]
    [[ "$output" == *"ACTION|preserve-stage||MISSING-WORKTREE"* ]]
    # The precondition fails before any record is read, so no stub was invoked at all and
    # the arm did not create the worktree.
    [[ "$output" != *"stub-git:"* ]]
    [ ! -e "${PRES}/no-worktree/absent-consolidation-worktree" ]
}

@test "a modified preserve record is staged and reported" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/modified"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/modified/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH=/dev
    run run_preserve
    [ "$status" -eq 0 ]
    [[ "$output" == *"|agent-memory/atomic-executor/modified-lesson.md|STILL_RELEVANT"* ]]
    [[ "$output" == *"ACTION|preserve-stage|null|OK"* ]]
    # change_class `modified` takes the identical staging path as `untracked`.
    [[ "$output" == *"add -- null"* ]]
}

@test "records are emitted in LC_ALL=C order regardless of manifest order" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/order"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/order/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH=/dev
    # The read-only phase is driven so the ordering is observed without any write.
    run preserve_plan
    [ "$status" -eq 0 ]
    local names
    names="$(printf '%s\n' "$output" | grep '^PRESERVE|' | cut -d'|' -f3 | tr '\n' ' ')"
    # The manifest lists zzz first; LC_ALL=C order puts aaa first. An implementation that
    # iterated the array as written would produce the reverse of this string.
    [ "$names" = "agent-memory/atomic-executor/aaa-lesson.md agent-memory/atomic-executor/zzz-lesson.md " ]
}

@test "a null memory_index_line stages the file and touches no index" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/untracked"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/untracked/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH=/dev
    run run_preserve
    [ "$status" -eq 0 ]
    [[ "$output" == *"ACTION|preserve-stage|null|OK"* ]]
    # No index record of any kind is emitted, and no index file is read or created.
    [[ "$output" != *"ACTION|preserve-index|"* ]]
    [ ! -e /dev/MEMORY.md ]
}

@test "a missing source file is reported as MISSING-SOURCE" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/missing-source"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/missing-source/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH=/dev
    run run_preserve
    # Skip and report, contributing to exit 1; never a hard stop.
    [ "$status" -eq 1 ]
    [[ "$output" == *"ACTION|preserve-stage|null|MISSING-SOURCE"* ]]
    [[ "$output" != *"ACTION|preserve-stage|null|OK"* ]]
}

@test "an ignored target path is refused without a force flag" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/ignored-target"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/ignored-target/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH=/dev
    run run_preserve
    [ "$status" -eq 1 ]
    [[ "$output" == *"ACTION|preserve-stage|null|IGNORED-TARGET"* ]]
    # The observable consequence of the refusal is that no staging call is made at all.
    # The stub logs its whole argv and the production call always passes `-C <worktree>`
    # first, so the literal `stub-git: add` would match nothing whether or not the add
    # ran; the operand-anchored expression below can fail.
    local add_re='stub-git: .*[[:space:]]add[[:space:]]'
    [[ ! "$output" =~ $add_re ]]
}

@test "the preserve exit codes distinguish clean, skipped, and blocked runs" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_CONSOLIDATION_PATH=/dev
    local variant expected
    for variant in clean:0 skipped:1 blocked:3; do
        expected=${variant##*:}
        variant=${variant%%:*}
        export CLEANUP_WT_STUB_SCENARIO="${PRES}/exit-codes/${variant}"
        export CLEANUP_WT_MANIFEST_PATH="${PRES}/exit-codes/${variant}/manifest.json"
        run run_preserve
        [ "$status" -eq "$expected" ]
    done
    # The blocked run stages nothing at all, which is what distinguishes exit 3 from the
    # partial-progress meaning of exit 1.
    [[ "$output" != *"ACTION|preserve-stage|null|OK"* ]]
}

# --- carrying the MEMORY.md index line (AC-11, AC-13, AC-14) ------------------------
# Every test below drives the read-only phase, or the renderer with the null-device
# stand-in `/dev/stdout`, so no checked-in index file is ever modified and the suite stays
# idempotent. Writing to a character device is not a temporary file.

@test "the memory index line is appended verbatim to the destination index" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/index-append"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/index-append/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH="${PRES}/index-append/consolidation"
    # Half one: the read-only phase resolves the index as the MEMORY.md sibling of
    # target_path and plans an append against it.
    run preserve_plan
    [ "$status" -eq 0 ]
    [[ "$output" == *"ACTION|preserve-index|${PRES}/index-append/consolidation/agent-memory/atomic-executor/MEMORY.md|OK"* ]]
    # Half two: the rendered bytes are the line's own bytes plus one terminator and
    # nothing else. The em dash separator and the parenthesised link survive unchanged;
    # an implementation that normalized the separator would fail this comparison.
    local line="- [Appended lesson](appended-lesson.md) — carried across verbatim, separator included"
    run preserve_render_index_append /dev/stdout "$line" lf no
    [ "$status" -eq 0 ]
    [ "$output" = "$line" ]
    # The checked-in index is unchanged: the read-only phase wrote nothing to it.
    run grep -c -F -- "appended-lesson.md" "${PRES}/index-append/consolidation/agent-memory/atomic-executor/MEMORY.md"
    [ "$status" -eq 1 ]
}

@test "an absent destination index is created and reported as CREATED" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/index-absent"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/index-absent/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH=/dev
    run preserve_plan
    [ "$status" -eq 0 ]
    [[ "$output" == *"ACTION|preserve-index|/dev/MEMORY.md|CREATED"* ]]
    # The read-only phase decided; it did not write.
    [ ! -e /dev/MEMORY.md ]
    # Creating an index contributes to exit 1: it is deliberately not a clean success.
    # preserve_plan is re-run outside `run` so the accumulator is visible in this shell;
    # the phase performs no writes, so re-running it has no side effect.
    preserve_plan >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 1 ]
}

@test "a duplicate index entry is skipped and does not change the exit code" {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/index-duplicate"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/index-duplicate/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH="${PRES}/index-duplicate/consolidation"
    run preserve_plan
    [ "$status" -eq 0 ]
    [[ "$output" == *"|SKIPPED-DUPLICATE"* ]]
    # The file is still copied and staged: the duplicate suppresses only the append.
    [[ "$output" == *"PRESERVE|"*"agent-memory/atomic-executor/duplicate-lesson.md|"* ]]
    preserve_plan >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 0 ]
}

# --- the host-token refusal (AC-23, AC-24, AC-25, AC-27) ----------------------------
# Every test drives the read-only phase, which is where the pre-pass runs, so no test
# writes anything. The refusal is pinned in both directions: a token is refused, and a
# legitimate payload is still accepted, so the refusal is not a blanket reject.

preserve_drive_plan() {
    # Shared driver for the scenarios below: point every seam at the named scenario and
    # run the read-only phase.
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/$1"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/$1/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH="${2:-/dev}"
    preserve_plan
}

@test "each host token pattern is detected" {
    run preserve_drive_plan ht-patterns
    [ "$status" -eq 3 ]
    local id
    # One checked-in source fixture per identifier, each matching exactly one pattern.
    for id in HT1 HT2 HT3 HT4 HT5 HT6; do
        [[ "$output" == *"host token matched (${id})"* ]]
    done
    [ "$(printf '%s\n' "$output" | grep -c -F -- "|HOST-TOKEN-BLOCKED")" -eq 6 ]
    # Nothing reached the writing phase, for any record and not only the matching ones.
    preserve_drive_plan ht-patterns >/dev/null 2>&1 || true
    [ "${#PRESERVE_PLAN_STREAM[@]}" -eq 0 ]
}

@test "HEAD~1 and other revision syntax do not match the short-name pattern" {
    run preserve_drive_plan ht-revision
    # The legitimate payload is still accepted, so the refusal is not a blanket reject.
    [ "$status" -eq 0 ]
    [[ "$output" != *"HOST-TOKEN-BLOCKED"* ]]
    [[ "$output" != *"host token matched"* ]]
    [[ "$output" == *"PRESERVE|"*"revision-syntax-lesson.md|"* ]]
}

@test "the host token scan reads only the named source file" {
    # The manifest's evidence field and the destination index both carry a host path; the
    # named source file does not. A pass that scanned either would refuse this record.
    run preserve_drive_plan scan-scope "${PRES}/scan-scope/consolidation"
    [ "$status" -eq 0 ]
    [[ "$output" != *"HOST-TOKEN-BLOCKED"* ]]
    # The tokens really are present in the two places that are out of scope, so the test
    # is not passing because the fixture forgot to carry them.
    run grep -c -F -- "exampleaccount" "${PRES}/scan-scope/manifest.json"
    [ "$output" -eq 1 ]
    run grep -c -F -- "exampleaccount" "${PRES}/scan-scope/consolidation/agent-memory/atomic-executor/MEMORY.md"
    [ "$output" -eq 1 ]
    run grep -c -F -- "exampleaccount" "${PRES}/scan-scope/wt/agent-memory/atomic-executor/scope-lesson.md"
    [ "$status" -eq 1 ]
}

@test "a pattern set id mismatch is reported and the local scan governs" {
    # An identifier this library does not own is advisory: it is reported and changes
    # nothing else, including the exit code.
    run preserve_drive_plan pattern-set-id/advisory-only
    [ "$status" -eq 0 ]
    [[ "$output" == *"|PATTERN-SET-MISMATCH"* ]]
    [[ "$output" != *"HOST-TOKEN-BLOCKED"* ]]
    # The local scan governs regardless of what the identifier says.
    run preserve_drive_plan pattern-set-id/local-scan-governs
    [ "$status" -eq 3 ]
    [[ "$output" == *"|PATTERN-SET-MISMATCH"* ]]
    [[ "$output" == *"|HOST-TOKEN-BLOCKED"* ]]
}
