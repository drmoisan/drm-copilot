# Pass-after — R2: the ` -> ` split applies only to R and C entries

Timestamp: 2026-09-08T06-20

Task: [P3-T5] of `remediation-plan.2026-09-08T05-00.md`
Finding: R2

Command: `npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats`

EXIT_CODE: 0

TAP plan line: `1..21`
Lines beginning `ok`: 21
Lines beginning `not ok`: 0

## The two descriptions quoted in [P3-T2]

```
ok 20 dirt_rename_split: an untracked path containing the rename literal is reported in full and is UNIQUE
ok 21 dirt_rename_split: a genuine R entry is still split and the destination path is classified
```

## What changed

The line

```
[[ $rel == *" -> "* ]] && rel="${rel#* -> }"
```

in `classify_worktree_dirt` was replaced by a conditional gated on the porcelain X column:

```
if [[ ${xy:0:1} == R || ${xy:0:1} == C ]]; then
	rel="${rel#* -> }"
fi
```

The variable is `xy` and not the enclosing function's `x`, because `x` holds the last value
the `any_staged` pre-scan loop assigned rather than the current entry's X column. The comment
above the split now records that porcelain status uses the `OLD -> NEW` payload only for
those two codes and that a space does not trigger C-quoting, so an ordinary path may contain
the literal.

With the gate in place, `?? notes -> draft.md` is classified and reported under its full
path, resolves `UNIQUE` through rung 6, and makes the worktree `HAS_UNIQUE`, which refuses
the clear. The genuine `R  old.md -> new.md` entry is still split, and `new.md` — the path
that exists in the working tree — is the one classified.

Output Summary: The suite passes with exit code 0, 21 `ok` lines and 0 `not ok` lines. The
same suite exited 1 against the unfixed split, recorded at
`evidence/regression-testing/fail-before-rename-split.2026-09-08T06-00.md`. The 19
pre-existing tests in this suite are unaffected.
