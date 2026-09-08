#!/usr/bin/env bats
# Staged-tree rung and fail-closed branch tests for the dirt classifier in
# scripts/bash/cleanup_worktrees_dirt_lib.sh (issue #632).
#
# SUBJECT. Two things that the verdict suite in
# tests/shell/test_cleanup_worktrees_dirt_classify.bats does not cover.
#
# First, the staged-tree rung in all five of its material directions, counting the
# probe's two hard-failure sites separately: the probe matches an ancestor tree; the
# probe matches nothing; the probe's rev-list read hard-fails; the probe's diff-index
# read exits above 1; and a staged entry whose porcelain Y column is not a space. The
# fourth and fifth are the dangerous ones. A rung that answered STAGED_TREE_IS_COMMIT
# from an index-only probe would label an MM entry disposable, and --clear-disposable
# would then run reset --hard over an unstaged delta that exists in no commit and not in
# the index.
#
# Second, the classifier's fail-closed branches: the ladder's UNIQUE emissions that are
# reached only when a classifier read failed, and the clear's FAILED record. Every one of
# them is the branch that decides what happens when the tool could not read what it
# needed. Fail-closed is the property that stops the tool from reporting "safe to delete"
# about content that exists only in that worktree, so a branch of this kind that is never
# executed is a branch whose direction nothing holds.
#
# Every negative assertion here is paired with a positive control, because an assertion
# that only names what must be absent also passes in a build where no classification ran
# at all.
#
# No temporary files; no scratch git repositories. Every fixture is checked in.

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

@test "dirt_staged_tree_worktree_delta: the MM entry is not STAGED_TREE_IS_COMMIT and the worktree is not ALL_DISPOSABLE" {
    dirt dirt_staged_tree_worktree_delta
    [ "$status" -eq 0 ]
    # The X column is M, so the index differs from HEAD and the probe matches eeee7777.
    # But the Y column is also M, so the WORKING TREE differs from the index as well, and
    # the probe answered a question about the index only. Labelling this entry disposable
    # would let --clear-disposable run reset --hard over an unstaged modification that
    # exists in no commit and not in the index.
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||MM|src/a.cs'* ]]
    [[ "$output" == *'DIRTSUM|/repo-wt/dirt|HAS_UNIQUE|'* ]]
    [[ "$output" != *'DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|MM|src/a.cs'* ]]
    [[ "$output" != *"ALL_DISPOSABLE"* ]]
}

@test "dirt_staged_tree_worktree_delta: the M-space entry in the same fixture is still STAGED_TREE_IS_COMMIT" {
    dirt dirt_staged_tree_worktree_delta
    [ "$status" -eq 0 ]
    # The other half of the pin, and the reason the two entries live in ONE fixture: they
    # differ only in the Y column, so the same once-per-worktree probe result serves both
    # directions. A fix that simply disabled rung 1 would fail here.
    [[ "$output" == *'DIRTFILE|/repo-wt/dirt|STAGED_TREE_IS_COMMIT|eeee7777|M |src/b.cs'* ]]
}
