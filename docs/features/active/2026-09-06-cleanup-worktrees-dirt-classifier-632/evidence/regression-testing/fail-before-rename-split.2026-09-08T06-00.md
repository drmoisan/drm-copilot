# Fail-before — R2: the ` -> ` split is unconditional

Timestamp: 2026-09-08T06-16

Task: [P3-T3] of `remediation-plan.2026-09-08T05-00.md` — tagged `[expect-fail]`
Finding: R2 (code review F2; feature audit AC-15)

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats`

EXIT_CODE: 1
ExpectedExitCode: 1

Run against the **unfixed** split in `scripts/bash/cleanup_worktrees_dirt_lib.sh`, before
[P3-T4] restricts it to `R` and `C` entries.

TAP plan line: `1..21`
Lines beginning `ok`: 20
Lines beginning `not ok`: 1

## Failing line, verbatim

```
not ok 20 dirt_rename_split: an untracked path containing the rename literal is reported in full and is UNIQUE
# (in test file tests/shell/test_cleanup_worktrees_dirt_classify.bats, line 311)
#   `[[ "$output" == *'DIRTFILE|/repo-wt/dirt|UNIQUE||??|notes -> draft.md'* ]]' failed
ok 21 dirt_rename_split: a genuine R entry is still split and the destination path is classified
```

## Both halves

The failing half is present: the untracked entry `?? notes -> draft.md` is truncated to
`draft.md` by the unconditional split, every probe is issued against `draft.md`, and the
emitted record is `DIRTFILE|/repo-wt/dirt|CONTENT_ON_MAIN||??|draft.md` — a disposable
verdict about a file the operator does not have, naming a path that is not the one on disk.

The passing half is present: `ok 21` shows the genuine `R  old.md -> new.md` entry is still
split and its destination `new.md` is the path classified. That proves the fixture is not
simply broken and that the second half of the pin is satisfiable in this fixture.

The two `hash-object` responses in the fixture carry **different** blobs — `5555dddd` for the
truncated `draft.md` and `6666eeee` for the full `notes -> draft.md` — and only the truncated
one has a matching `rev-parse main:` response. That is what makes the pin able to fail in
both directions: the truncated read resolves `CONTENT_ON_MAIN` and the full read resolves
`UNIQUE`, so a classifier reading the wrong path cannot accidentally produce the right
verdict.

The remaining 19 `ok` lines are the pre-existing tests in this suite, all of which still pass
at this commit.

Output Summary: The suite exits 1 with exactly the predicted split of results. The defect is
reproduced at the level of the emitted record: a non-rename path containing the literal
` -> ` is truncated, misclassified as disposable, and misreported under a path that does not
exist.
