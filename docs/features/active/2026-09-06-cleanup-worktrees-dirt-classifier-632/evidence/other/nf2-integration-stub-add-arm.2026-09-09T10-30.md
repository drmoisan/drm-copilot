# NF-2 — the merged stub now defines an index-writing arm the header rule denies (follow-up)

Timestamp: 2026-09-09T10-30
Raised by: `atomic-executor`, while resolving the integration merge
Disposition: NON-BLOCKING. Recorded because it was found during a merge rather than during a
review, so it belongs to neither feature's audit trail unless written down deliberately.

## What happened

Merging `origin/epic/cleanup-merged-worktrees-hardening-integration` brought in sibling child
issue #637 (preserve-file consolidation). That change added an `add)` arm to
`tests/fixtures/cleanup_worktrees/stub-bin/git`. The arm sits outside the three conflict regions,
so it auto-merged silently and was never presented for resolution.

This feature's block in the same file's header states:

```
# No arm is defined for any subcommand that writes to the index or the object database.
# The dirt classifier must reach its staged-tree answer by reading only, so defining
# such an arm would make the report-mode non-mutation assertion unable to fail.
```

`git add` writes to the index. That sentence is now false in the merged file. It was true when
written and no one edited it; the tree moved underneath it.

## Why it is not blocking

The product side is safe, verified rather than assumed. The only callers of the new arm are
`scripts/bash/cleanup_worktrees_preserve_lib.sh:400` and `:402`, both inside the preserve staging
path, which report mode never reaches. No dirt-classifier path can issue `git add`.

The full merged suite is green at 460 tests with zero failures, including
`dirt_staged_tree_is_commit: report mode issues no mutating git command and redirects no index`.

## The residual, stated precisely

The exposure is in the test, not the product. `tests/shell/test_cleanup_worktrees_dirt_clear.bats:205`
asserts non-mutation by enumerating a fixed token list — `write-tree`, `stub-git-env`, `/index`,
`reset`, `clean`, `worktree remove`, `branch -D`, `hash-object -w` — and that list has no `add`
entry. A future regression that made report mode issue `git add` would therefore pass that
assertion.

The assertion is not vacuous: it still discriminates for every token it does list, and it carries a
live positive control. It is narrowly blind to exactly one newly available arm.

## Recommended follow-up

Either add `add` to the assertion's negative token list, or amend the header rule to name `add` as
the one permitted index-writing arm with its preserve-mode-only justification. The first is
stronger; the second is honest if the arm is expected to stay.

Doing it here would have required editing either a test file or the header block that the merge
instruction said to keep verbatim, which is why it was reported rather than fixed in the merge.

## The general lesson, which is the reason this file exists

An assertion that enumerates a denylist is only as complete as the world it was written against. A
sibling feature can widen that world without touching the assertion, and the merge will be clean
and the suite will be green. Nothing in this repository's gates detects that class — it surfaced
only because the merge resolver read the header prose it was asked to preserve and noticed the
prose no longer matched the file.
