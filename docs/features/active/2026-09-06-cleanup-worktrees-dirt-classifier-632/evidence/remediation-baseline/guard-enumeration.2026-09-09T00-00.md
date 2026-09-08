# Baseline — guard inventory in the classifier library and its registry

Timestamp: 2026-09-09T00-00

Task: [P0-T6]

The three commands below are the ones the task states. They were run with absolute paths to
the same two files rather than repository-relative paths, because this session's Bash
permission layer refuses a `cd`-chained file-reading command; the pattern, the flags and the
target files are unchanged.

Command: `grep -cE '\(\([A-Za-z_][A-Za-z0-9_]* (==|!=|>=|<=|>|<) [0-9]+\)\)' scripts/bash/cleanup_worktrees_dirt_lib.sh`
EXIT_CODE: 0
Result: **31**

Command: `grep -cE '# guard:[a-z0-9-]+$' scripts/bash/cleanup_worktrees_dirt_lib.sh`
EXIT_CODE: 0
Result: **37**

Command: `grep -vc '^#' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv`
EXIT_CODE: 0
Result: **39**

Supporting derivation, not required by the acceptance but recorded so the id arithmetic below
is checkable:

Command: `awk -F'\t' '!/^#/ && NF {print $1}' tests/fixtures/cleanup_worktrees/dirt-guard-registry.tsv | sort -u | wc -l`
EXIT_CODE: 0
Result: **37** distinct registry ids.

## Cycle-start position

| Quantity | Value |
|---|---:|
| Arithmetic guard-shaped lines in `cleanup_worktrees_dirt_lib.sh` | 31 |
| Marker lines (`# guard:` at end of line) in the same file | 37 |
| Registry data rows in `dirt-guard-registry.tsv` | 39 |
| Distinct registry ids | 37 |

## Derived end-state targets, with the arithmetic that produces each

**33 arithmetic lines.** 31 at cycle start plus the two `((bothloc == 0))` lines that D1
adds, one nested at rung 4's positive emission and one nested at rung 5's positive emission.
31 + 2 = 33.

**40 marker lines.** 37 at cycle start plus the three markers D1's new guard-shaped lines
carry: `# guard:index-and-worktree-both-hold-content` on the `[[ $x == [MARCTU] && $y ==
[MARCTU] ]]` line, `# guard:rung4-index-blob-unaccounted`, and
`# guard:rung5-index-blob-unaccounted`. 37 + 3 = 40. Equivalently, 33 arithmetic marked lines
plus 7 lines that are marked but carry no arithmetic comparison.

**42 registry rows.** 39 at cycle start plus the three rows D3 adds, one per new marker id,
all three of kind `SEPARATED` and all three keyed to the new scenario
`dirt_index_and_worktree_delta`. 39 + 3 = 42. Equivalently, 33 rows backing the arithmetic
lines plus 9 rows backing named non-arithmetic literals.

**40 distinct ids.** 42 rows less the two ids that back two rows each. Those two ids are
`hash-object-hard-fail` and `rung4-untracked-main-present`; each of their marked lines carries
an arithmetic comparison and a named non-arithmetic test together, so each holds one
arithmetic row and one literal row. 42 - 2 = 40. This is consistent with the marker count:
every marker id has at least one row and every row names a marked id, so distinct ids equals
marker lines, 40 = 40.

**9 named non-arithmetic literals (`LIT_IDS`).** 8 at cycle start plus
`index-and-worktree-both-hold-content`, which is the one non-arithmetic guard this cycle adds
and which the registry's `GUARD_RE` predicate does not compel. 8 + 1 = 9.

Output Summary: cycle-start inventory measured as 31 arithmetic guard-shaped lines, 37 marker
lines and 39 registry data rows over 37 distinct ids, which matches the position the cycle-3
plan asserts. The derived end-state targets are 33 arithmetic lines, 40 marker lines, 42
registry rows and 40 distinct ids, each with its arithmetic stated above.
