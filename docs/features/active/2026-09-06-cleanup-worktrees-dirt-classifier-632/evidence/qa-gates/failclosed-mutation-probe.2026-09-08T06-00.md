# Mutation probe — the fail-closed pins can fail

Timestamp: 2026-09-08T07-02

Task: [P6-T8] of `remediation-plan.2026-09-08T05-00.md`
Finding: R3

The scenarios added in Phase 6 pin behaviour that is already correct, so a demonstration
that the pins can fail is required. The mutation chosen is the one whose direction matters:
a fail-closed `UNIQUE` emission replaced by a disposable verdict.

## The five commands, in order

```
sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats
sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_clear.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats tests/shell/test_cleanup_worktrees_dirt_regression.bats
sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh
```

## The three recorded digests

| Point | sha256 of `scripts/bash/cleanup_worktrees_dirt_lib.sh` |
|---|---|
| Before mutation | `9758f148e22731374496dcbcffce888acc59194f0ba1c40273aed62551270fcc` |
| After mutation | `721d878c398b5b0bd66886abb0e499c777b1fb165f6573315bc2d7db687a6894` |
| After revert | `9758f148e22731374496dcbcffce888acc59194f0ba1c40273aed62551270fcc` |

The first and third are equal and the second differs from them, so the mutation was applied
and then fully reverted.

## The mutated hunk

The rung-3 hard-failure emission in `classify_dirt_entry`, guarded by `if ((brc > 1)); then`:

```
 		if ((brc > 1)); then
-			printf 'UNIQUE|\n'
+			printf 'CONTENT_ON_MAIN|\n'
 			return 0
 		fi
```

This is the exact defect the fail-closed rule exists to prevent: a project file whose diff
could not be read reported as content that already exists on `main`, and therefore
disposable.

## Bats exit codes

MutatedRunExitCode: 1
RevertedRunExitCode: 0

## Mutated-run output

TAP plan line: `1..55`, 54 `ok`, 1 `not ok`:

```
not ok 43 dirt_tracked_read_errors: a rung-3 diff read failure and a rung-4 probe failure both map to UNIQUE
```

The failing description is the one [P6-T8] requires. The remaining 54 tests still pass under
the mutation, which is the expected result: the mutated line is reached only when a rung-3
content read exits above 1, and `dirt_tracked_read_errors` is the only scenario that drives
that condition. That is precisely why the scenario was needed — before Phase 6 this line was
never executed by any test, so this mutation would have passed the entire suite silently.

Output Summary: The mutation made the new fail-closed pin fail and the revert made it pass
again, with the file digest returning to its pre-mutation value. The pin is demonstrably able
to fail in the direction that matters.
