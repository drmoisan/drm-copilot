# Mutation probe — the three new staged-rung pins can fail

Timestamp: 2026-09-08T06-50

Task: [P5-T6] of `remediation-plan.2026-09-08T05-00.md`
Finding: R4

The reviewer drove the no-match and hard-read-failure paths directly and reported they behave
correctly today, so [P5-T4]'s three tests pin correct behaviour rather than fix a defect.
A pin of correct behaviour needs a demonstration that it can fail, which is what this probe
supplies.

## The five commands, in order

```
sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats
sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_failclosed.bats
sha256sum scripts/bash/cleanup_worktrees_dirt_lib.sh
```

The first digest was taken before the mutation, the second after it, and the third after the
revert. The two bats runs bracket the mutation.

## The three recorded digests

| Point | sha256 of `scripts/bash/cleanup_worktrees_dirt_lib.sh` |
|---|---|
| Before mutation | `9758f148e22731374496dcbcffce888acc59194f0ba1c40273aed62551270fcc` |
| After mutation | `f4ef29fe943964336d1513e0f8f9476e721fa4b250dea688d667de92c9dbb2db` |
| After revert | `9758f148e22731374496dcbcffce888acc59194f0ba1c40273aed62551270fcc` |

The first and third are equal and the second differs from them, so the mutation was applied
and then fully reverted. The digest triple is the failable revert check: a diff against the
base branch is non-empty here because this cycle's own fixes are in the tree, so it could not
distinguish a reverted mutation from an unreverted one.

## The mutated hunk

One mutation was applied to `dirt_staged_tree_commit`, making its no-match return and both of
its hard-failure returns indistinguishable from a match. Each of `return 1` and the two
`return 2` statements in that function's body was replaced by a path that prints a candidate
sha and returns 0:

```
 	if ((rc != 0)); then
-		return 2
+		printf 'eeee7777\n'
+		return 0
 	fi
 ...
 		if ((drc > 1)); then
-			return 2
+			printf 'eeee7777\n'
+			return 0
 		fi
 	done <<<"$out"
-	return 1
+	printf 'eeee7777\n'
+	return 0
 }
```

## Bats exit codes

MutatedRunExitCode: 1
RevertedRunExitCode: 0

## Mutated-run output

TAP plan line: `1..5`, 2 `ok`, 3 `not ok`:

```
not ok 3 dirt_staged_tree_no_match: a staged index matching no ancestor tree is UNIQUE not STAGED_TREE_IS_COMMIT
not ok 4 dirt_staged_probe_revlist_error: a rev-list hard failure maps the staged entry to UNIQUE
not ok 5 dirt_staged_probe_diffindex_error: a diff-index exit above one maps the staged entry to UNIQUE
```

Every one of the three descriptions quoted in [P5-T4] carries a `not ok` line under the
mutation.

The two `dirt_staged_tree_worktree_delta` tests still pass under the mutation, which is
correct and is itself informative: their fixture's probe already matched, so the mutation
does not change their input. The Y-column gate is what decides those two, and it is a
different mechanism from the probe's return contract.

Output Summary: The mutation made all three new pins fail and the revert made them pass
again, with the file digest returning to its pre-mutation value. The three pins are
demonstrably able to fail in the direction that matters — a probe that reported a match where
it had no answer would label a staged entry disposable and make it clearable.
