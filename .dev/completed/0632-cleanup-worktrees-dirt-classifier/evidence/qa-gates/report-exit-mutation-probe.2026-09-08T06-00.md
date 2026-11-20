# Mutation probe — the report-mode exit pin can fail

Timestamp: 2026-09-08T07-14

Task: [P7-T7] of `remediation-plan.2026-09-08T05-00.md`
Finding: R6a (Decision A)

The report-mode exit-code propagation is retained rather than changed, so [P7-T4]'s test
pins existing behaviour. This probe demonstrates the pin can fail.

## The five commands, in order

```
sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_regression.bats
sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_regression.bats
sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh
```

## The three recorded digests

| Point | sha256 of `scripts/bash/cleanup_worktrees_dirt_lib.sh` |
|---|---|
| Before mutation | `9758f148e22731374496dcbcffce888acc59194f0ba1c40273aed62551270fcc` |
| After mutation | `16dafc754bac21836cfc0e3799cfcbf09e8922a30bf0a89afca6e61fcdf63749` |
| After revert | `9758f148e22731374496dcbcffce888acc59194f0ba1c40273aed62551270fcc` |

The first and third are equal and the second differs from them, so the mutation was applied
and then fully reverted.

## The mutated hunk

The `return "$srrc"` guarded by `if ((srrc != 0)); then` in `classify_worktree_dirt`:

```
 	if ((srrc != 0)); then
-		return "$srrc"
+		return 0
 	fi
```

This is the alternative the decision record rejected, expressed as code: suppressing the
propagation so a report over a worktree whose status read failed exits 0 while emitting no
records for it.

## Bats exit codes

MutatedRunExitCode: 1
RevertedRunExitCode: 0

## Mutated-run output

TAP plan line: `1..12`, 11 `ok`, 1 `not ok`:

```
not ok 12 report mode over dirty_worktree_status_error returns the status read exit code and emits no dirt record
# (in test file tests/shell/test_cleanup_worktrees_dirt_regression.bats, line 137)
#   `[ "$status" -eq 128 ]' failed
```

The failing description is the one [P7-T7] requires, and the failing assertion is the exit
code itself rather than one of the record assertions — which is the correct discrimination,
because under the mutation the records are still absent and only the exit status changes.

The other 11 tests in the suite pass under the mutation. That is informative: the
byte-identity pins compare stdout, and suppressing the exit code changes no byte of stdout,
so none of them can observe this behaviour. The new test is the only thing holding it.

Output Summary: The mutation made the report-mode exit pin fail and the revert made it pass
again, with the file digest returning to its pre-mutation value.
