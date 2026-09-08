# N4 discrimination probe — the parked row is now rejected

Timestamp: 2026-09-09T01-30
Task: [P3-T4] `[expect-fail]`
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

## Subject

The cycle-2 reaudit demonstrated that the guard registry's `EXEMPT` kind could be
satisfied by naming a scenario under which the ladder never reaches the guard. The variant
registry it built — the `staged-probe-skip-head` row rewritten as `EXEMPT` against
`dirt_unique` with a `RECORDS-AND-ARGV-IDENTICAL:` reason — passed all three tests of the
registry suite before this phase. The source of that variant is
`code-review.2026-09-08T23-30.md` Part 3 ("the systemic gate (AC-47), judged on its
merits"), at that file's `:119`.

This probe writes the same variant row into the tracked registry after Phase 3's edits and
records that the strengthened gate now rejects it, then restores the row by the inverse row
rewrite. Without this probe the strengthened gate would only be known to pass on a tree
that already satisfies it.

## Restore mechanism

The restore is an **inverse row rewrite**, not `git checkout --`. No task before this one
stages anything (`git add -A` first appears in P5-T7), so the index still holds the
pre-P2-T4 version of the registry and `git checkout --` would have discarded the three rows
P2-T4 appended. The same `sed -i` full-line substitution addressed by the row id performed
both the mutation and the restoration.

## Step 1 — write the parked row

Command:

```
sed -i 's|^staged-probe-skip-head\t.*$|staged-probe-skip-head\tEXEMPT\tdirt_unique\tHAS_UNIQUE\ts/((first == 1))/((0))/\tRECORDS-AND-ARGV-IDENTICAL: parked under a scenario that never reaches the guard|' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv
```

EXIT_CODE: 0

Row after step 1, shown through `cat -A` (`^I` is a tab, `$` is end of line):

```
staged-probe-skip-head^IEXEMPT^Idirt_unique^IHAS_UNIQUE^Is/((first == 1))/((0))/^IRECORDS-AND-ARGV-IDENTICAL: parked under a scenario that never reaches the guard$
```

## Step 2 — run the registry suite against the parked row

Command:

```
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats
```

EXIT_CODE: 1
ExpectedExitCode: 1

Verbatim combined output, including the stderr the suite printed:

```
1..3
not ok 1 every guard-shaped line in the dirt library is marked and every registry row names a marked id
# (in test file tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats, line 268)
#   `[ -z "$idless" ]' failed
# INVARIANT-2 markers with no registry row: staged-probe-skip-head
# INVARIANT-8 inadmissible kind: [staged-probe-skip-head::EXEMPT]
not ok 2 every registered guard is observable under its own neutralization
# (in test file tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats, line 377)
#   `[ -z "$OB5" ]' failed
# OBLIGATION-5 channel comparison failed: staged-probe-skip-head
not ok 3 every marker id is pinned by kind and the two dual-row lines are pinned by pair
# (in test file tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats, line 436)
#   `[ -z "$missing" ]' failed
# PINS NOT SATISFIED: SEPARATED:staged-probe-skip-head
```

All three required literals are present:

- `INVARIANT-8 inadmissible kind:` — Phase 3's new kind accumulator, P3-T2.
- `OBLIGATION-5 channel comparison failed:` — the deleted `EXEMPT` arm now falls to the
  `*)` default, P3-T1.
- `PINS NOT SATISFIED:` — the raised floor requires a `SEPARATED` row for this id, P3-T3.

A fourth accumulator, `INVARIANT-2 markers with no registry row:`, also fires because
edit 1b narrowed Invariant 2's kind list to `SEPARATED ARGV`. That is the observation the
plan's D4 item 1b predicted and is recorded rather than suppressed.

## Step 3 — restore by the inverse row rewrite

Command:

```
sed -i 's|^staged-probe-skip-head\t.*$|staged-probe-skip-head\tSEPARATED\tdirt_staged_tree_is_commit\tALL_DISPOSABLE\ts/((first == 1))/((1))/\t|' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv
```

EXIT_CODE: 0

Observations taken after step 3:

Command: `awk -F'\t' '$1=="staged-probe-skip-head"' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`

Output, one line, shown through `cat -A`:

```
staged-probe-skip-head^ISEPARATED^Idirt_staged_tree_is_commit^IALL_DISPOSABLE^Is/((first == 1))/((1))/^I$
```

That reproduces the plan's quoted restore target field for field, including the trailing
tab before the empty sixth field.

Command: `grep -vc '^#' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
Value: `42` — 39 data rows at cycle start plus the three P2-T4 appended.

Command: `grep -cF 'EXEMPT' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
Value: `0`

Command: `grep -c '^$' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
Value: `0`

Supplementary confirmation that the restore was byte-exact rather than merely
field-equivalent:

Command: `git status --porcelain tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
Output: empty. The file is identical to the version committed at `7b6e13c7`, which is the
version carrying P2-T4's three appended rows.

## Step 4 — confirm the restoration

Command:

```
npx --yes bats --formatter tap tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats
```

EXIT_CODE: 0

```
1..3
ok 1 every guard-shaped line in the dirt library is marked and every registry row names a marked id
ok 2 every registered guard is observable under its own neutralization
ok 3 every marker id is pinned by kind and the two dual-row lines are pinned by pair
```

`not ok` count: 0

## Output Summary

The variant registry that passed all three tests before this phase now fails all three.
Step 2 exited 1 and printed each of the three required literals; step 3 restored the row to
its exact six-field tab-separated form, leaving the registry at 42 data rows with zero
occurrences of the deleted kind and byte-identical to `HEAD`; step 4 exited 0 with zero
`not ok` lines. No temporary file was created.
