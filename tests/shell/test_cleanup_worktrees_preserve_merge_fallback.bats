#!/usr/bin/env bats
# Fallback-path unit tests for the preserve staging decision defined by
# .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_merge_lib.sh:
# the git stub's merge key forms, each cause of an unavailable merge base, an untracked
# record whose target already exists, and a duplicate target_path within one pass. Split
# from tests/shell/test_cleanup_worktrees_preserve_merge.bats to keep each file below the
# 500-line guidance tier; the setup block duplicates that suite's.
#
# Every scenario is driven through the read-only planning phase against checked-in fixtures
# and the recording git stub. No temporary files; no real git or jq is invoked.
#
# Each two-record scenario holds notes/ok.md, whose main version is a line-subsequence of
# the source, and notes/bad.md, whose main version carries a line the source lacks and
# whose record has a non-null memory_index_line, so an index decision taken before the
# refusal would be visible as an ACTION|preserve-index record.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    SDIR="${REPO_ROOT}/.claude/skills/cleanup-merged-worktrees/scripts"
    ELIB="${SDIR}/cleanup_worktrees_enumerate_lib.sh"
    LIB="${SDIR}/cleanup_worktrees_lib.sh"
    ALIB="${SDIR}/cleanup_worktrees_actions_lib.sh"
    MLIB="${SDIR}/cleanup_worktrees_preserve_merge_lib.sh"
    EOLLIB="${SDIR}/cleanup_worktrees_preserve_eol_lib.sh"
    PLIB="${SDIR}/cleanup_worktrees_preserve_lib.sh"
    STUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/stub-bin/git"
    JQSTUB="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq"
    PRES="${REPO_ROOT}/tests/fixtures/cleanup_worktrees/preserve"
    chmod +x "${STUB}" "${JQSTUB}" 2>/dev/null || true
    cd "${REPO_ROOT}" || return 1
    source "${ELIB}"
    source "${LIB}"
    source "${ALIB}"
    source "${MLIB}"
    source "${EOLLIB}"
    source "${PLIB}"
    return 0
}

fallback_drive_plan() {
    export CLEANUP_WT_GIT_BIN="${STUB}"
    export CLEANUP_WT_JQ_BIN="${JQSTUB}"
    export CLEANUP_WT_STUB_SCENARIO="${PRES}/$1"
    export CLEANUP_WT_MANIFEST_PATH="${PRES}/$1/manifest.json"
    export CLEANUP_WT_CONSOLIDATION_PATH="${PRES}/$1/consolidation"
    preserve_plan
}

# Assert the two-record outcome: notes/ok.md is planned with column 9 `copy`, and
# notes/bad.md is refused by guard (b) with the full refusal contract. $2 is the source
# directory inside the worktree (`notes`, or `old` for the renamed scenario).
fallback_assert_ok_and_bad() {
    run fallback_drive_plan "$1"
    [ "$status" -eq 0 ]
    [[ "$output" == *"PRESERVE|tests/fixtures/cleanup_worktrees/preserve/$1/wt|$2/bad.md|STILL_RELEVANT"* ]]
    [[ "$output" == *"ACTION|preserve-stage|notes/bad.md|REFUSED-WOULD-REGRESS"* ]]
    [[ "$output" == *"cleanup-worktrees: refused notes/bad.md: guard-b"* ]]
    [[ "$output" != *"notes/ok.md|REFUSED-WOULD-REGRESS"* ]]
    [[ "$output" != *"ACTION|preserve-index|"* ]]
    fallback_drive_plan "$1" >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 1 ]
    [ "${#PRESERVE_PLAN_STREAM[@]}" -eq 1 ]
    preserve_split_tsv "${PRESERVE_PLAN_STREAM[0]}"
    [ "${PRESERVE_FIELDS[0]}" = "notes/ok.md" ]
    [ "${PRESERVE_FIELDS[8]-}" = "copy" ]
    [ -z "${PRESERVE_FIELDS[9]-}" ]
}

@test "the git stub replays the merge key forms" {
    local scen="${PRES}/merge-repro"
    run env CLEANUP_WT_STUB_SCENARIO="$scen" "${STUB}" -C /x/consolidation merge-base wthead01 HEAD
    [ "$status" -eq 0 ]
    [[ "$output" == *"mbase001"* ]]
    run env CLEANUP_WT_STUB_SCENARIO="$scen" "${STUB}" -C /x/consolidation cat-file blob base0001
    [[ "$output" == *"- beta"* ]]
    # The hash-object -w key uses the final -C component, so absolute paths never enter it.
    run env CLEANUP_WT_STUB_SCENARIO="$scen" "${STUB}" -C /x/consolidation hash-object -w --path=notes/n.md -- notes/n.md
    [[ "$output" == *"main0001"* ]]
    run env CLEANUP_WT_STUB_SCENARIO="$scen" "${STUB}" -C /y/wt hash-object -w --path=notes/n.md -- notes/n.md
    [[ "$output" == *"wt000001"* ]]
    run env CLEANUP_WT_STUB_SCENARIO="$scen" "${STUB}" -C /x/consolidation merge-file --union --object-id main0001 base0001 wt000001
    [[ "$output" == *"merged01"* ]]
    # Non-default exit codes, which the stub's default of 0 could not produce.
    run env CLEANUP_WT_STUB_SCENARIO="${PRES}/merge-error" "${STUB}" merge-file --union --object-id main0001 base0001 wt000001
    [ "$status" -eq 129 ]
    run env CLEANUP_WT_STUB_SCENARIO="${PRES}/merge-nobase-mergebase" "${STUB}" merge-base wthead01 HEAD
    [ "$status" -eq 1 ]
    # The --is-ancestor form keeps its own key and default.
    run env CLEANUP_WT_STUB_SCENARIO="$scen" "${STUB}" merge-base --is-ancestor wthead01 HEAD
    [ "$status" -eq 0 ]
    [[ "$output" != *"mbase001"* ]]
}

@test "no worktree HEAD falls back to guard-b" {
    fallback_assert_ok_and_bad merge-nobase-head notes
    [[ "$output" == *"rev-parse --verify --quiet HEAD"* ]]
    [[ "$output" != *" merge-base "* ]]
}

@test "no merge base falls back to guard-b" {
    fallback_assert_ok_and_bad merge-nobase-mergebase notes
    [[ "$output" == *"merge-base wthead01 HEAD"* ]]
    [[ "$output" != *"mbase001:"* ]]
}

@test "a file absent at the merge base falls back to guard-b" {
    fallback_assert_ok_and_bad merge-nobase-absent notes
    [[ "$output" == *"rev-parse --verify --quiet mbase001:notes/bad.md"* ]]
    [[ "$output" != *"cat-file"* ]]
}

@test "a renamed target falls back to guard-b without resolving a base" {
    fallback_assert_ok_and_bad merge-nobase-renamed old
    [[ "$output" != *"merge-base"* ]]
    [[ "$output" != *"rev-parse"* ]]
}

@test "an untracked record with an existing target is guarded by guard-b" {
    fallback_assert_ok_and_bad merge-untracked notes
    [[ "$output" != *"merge-base"* ]]
    [[ "$output" != *"rev-parse"* ]]
}

@test "a duplicate target_path in one pass is refused after the first" {
    run fallback_drive_plan merge-duplicate
    [ "$status" -eq 0 ]
    [[ "$output" == *"PRESERVE|tests/fixtures/cleanup_worktrees/preserve/merge-duplicate/wt|notes/b.md|GENUINELY_NEW"* ]]
    [[ "$output" == *"ACTION|preserve-stage|notes/n.md|REFUSED-WOULD-REGRESS"* ]]
    [[ "$output" == *"cleanup-worktrees: refused notes/n.md: duplicate-target"* ]]
    [[ "$output" != *"ACTION|preserve-index|"* ]]
    fallback_drive_plan merge-duplicate >/dev/null 2>&1
    [ "$PRESERVE_EXIT" -eq 1 ]
    [ "${#PRESERVE_PLAN_STREAM[@]}" -eq 1 ]
    preserve_split_tsv "${PRESERVE_PLAN_STREAM[0]}"
    [[ "${PRESERVE_FIELDS[1]}" == *"/notes/a.md" ]]
    [ "${PRESERVE_FIELDS[8]-}" = "copy" ]
}
