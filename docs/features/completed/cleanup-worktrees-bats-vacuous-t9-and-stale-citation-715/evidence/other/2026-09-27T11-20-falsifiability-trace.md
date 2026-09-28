# D6 Falsifiability Trace — T9 new assertion (`rev-parse --abbrev-ref HEAD`)

Timestamp: 2026-09-27T11-20

This artifact documents a static call-path trace. It does not modify, describe as
committed, or reference a mutated copy of any production file; the guard-ordering mutation
named below is described, not applied, in the tree.

## Call-path anchors (function name + literal call-site text)

(a) `delete_candidate()` in `scripts/bash/cleanup_worktrees_actions_lib.sh` — the
    base-branch guard:
    `if [[ $name == "$CLEANUP_WT_BASE_BRANCH" ]]; then`
    and the re-verification call:
    `reverify_delete_eligible "$name" "$state" || return 1`

(b) `reverify_delete_eligible()` in `scripts/bash/cleanup_worktrees_actions_lib.sh` — the
    guarded parent-shell capture of `classify_branch`:
    `out=$(classify_branch "$name") || crc=$?`

(c) `classify_branch()` in `scripts/bash/cleanup_worktrees_lib.sh` — the guarded
    parent-shell capture of `compute_protected`:
    `cpout=$(compute_protected) || cprc=$?`
    and the subsequent protected-check that precedes the ancestry call:
    `if [[ -n ${prot_branch[$name]:-} ]] || { [[ -n $wt_norm && -n ${prot_path[$wt_norm]:-} ]]; }; then`
    which, when it does not short-circuit, is followed by:
    `v=$(classify_ancestry "$name")`

(d) `compute_protected()` in `scripts/bash/cleanup_worktrees_enumerate_lib.sh` — the
    unredirected current-branch capture:
    `current_branch=$(cleanup_wt_git rev-parse --abbrev-ref HEAD) || cbrc=$?`

(e) The stub's unconditional argv log line, in
    `tests/fixtures/cleanup_worktrees/stub-bin/git`:
    `printf 'stub-git: %s\n' "$*" >&2`

## (i) Current code: no `rev-parse --abbrev-ref HEAD` call reaches `$output`

T9 ("delete_candidate refuses the base branch before re-verification") drives
`delete_candidate main '' MERGED_CLEAN` directly under the `base_not_checked_out` fixture,
with `name="main"` equal to `$CLEANUP_WT_BASE_BRANCH`. Under the current guard ordering in
`delete_candidate` (anchor a), the base-branch guard
`if [[ $name == "$CLEANUP_WT_BASE_BRANCH" ]]; then` is the first conditional evaluated and
it is true for this fixture, so `delete_candidate` prints
`ACTION|delete|main|BLOCKED-PROTECTED-BASE` and returns before reaching the
`reverify_delete_eligible "$name" "$state" || return 1` line. `reverify_delete_eligible`
(anchor b) is therefore never called, so `classify_branch` (anchor c) is never called, so
`compute_protected` (anchor d) is never called, so the unredirected
`current_branch=$(cleanup_wt_git rev-parse --abbrev-ref HEAD) || cbrc=$?` call is never
issued. With no such call issued, the stub's argv log line (anchor e) is never emitted for
this call, and no `rev-parse --abbrev-ref HEAD` text reaches `$output` under `bats run`.
The new T9 assertion `[[ "$output" != *"rev-parse --abbrev-ref HEAD"* ]]` is therefore true
today, for this reason and not vacuously: the call it forbids provably does not occur on
this path.

## (ii) Named mutation: the call would reach `$output`, unredirected

Consider the named mutation: moving the base-branch guard in `delete_candidate` (anchor a)
to after the `reverify_delete_eligible "$name" "$state" || return 1` line (anchor a), so
that `reverify_delete_eligible` runs first for every candidate, including `main` under the
`base_not_checked_out` fixture. Under that mutation, `reverify_delete_eligible` (anchor b)
executes `out=$(classify_branch "$name") || crc=$?`, invoking `classify_branch` (anchor c),
which executes `cpout=$(compute_protected) || cprc=$?`, invoking `compute_protected`
(anchor d). `compute_protected` issues
`current_branch=$(cleanup_wt_git rev-parse --abbrev-ref HEAD) || cbrc=$?` via plain command
substitution: stdout is captured by the substitution, but stderr is not redirected away, so
it remains attached to the test process's stderr. The stub's argv log line (anchor e),
`printf 'stub-git: %s\n' "$*" >&2`, writes to that same unredirected stderr, producing a
line containing the literal text `rev-parse --abbrev-ref HEAD`. Because T9's `run` command
retains stderr (per the comment at the top of the T9 test body, "stderr is retained so the
stub argv log is observable in $output"), that line is merged into `$output` under `bats
run`. The new T9 assertion `[[ "$output" != *"rev-parse --abbrev-ref HEAD"* ]]` would
therefore be false, and the test would fail, under this named guard-ordering mutation. This
is the assertion's falsifiability: it distinguishes the current guard ordering from the
named regression.
