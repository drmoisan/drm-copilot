# AC-1 sourcing set — library references per bats suite

Timestamp: 2026-09-08T07-18

Task: [P7-T8] of `remediation-plan.2026-09-08T05-00.md`

Command:

```
for f in test_cleanup_worktrees_*.bats; do
  a=$(grep -c -F 'cleanup_worktrees_lib.sh' "$f")
  b=$(grep -c -F 'cleanup_worktrees_dirt_lib.sh' "$f")
  printf '%-52s %3s %3s\n' "$f" "$a" "$b"
done
```

Run from `tests/shell/`.

EXIT_CODE: 0

## Table

| Suite | `cleanup_worktrees_lib.sh` | `cleanup_worktrees_dirt_lib.sh` |
|---|---:|---:|
| `test_cleanup_worktrees_classification.bats` | 2 | 1 |
| `test_cleanup_worktrees_cli.bats` | 0 | 1 |
| `test_cleanup_worktrees_consolidation.bats` | 1 | 1 |
| `test_cleanup_worktrees_deletion.bats` | 1 | 1 |
| `test_cleanup_worktrees_detached.bats` | 1 | 1 |
| `test_cleanup_worktrees_dirt_classify.bats` | 1 | 2 |
| `test_cleanup_worktrees_dirt_clear.bats` | 1 | 1 |
| `test_cleanup_worktrees_dirt_failclosed.bats` | 1 | 2 |
| `test_cleanup_worktrees_dirt_regression.bats` | 1 | 1 |
| `test_cleanup_worktrees_enumeration.bats` | 2 | 1 |
| `test_cleanup_worktrees_hard_failures.bats` | 1 | 1 |
| `test_cleanup_worktrees_report_records.bats` | 1 | 1 |
| `test_cleanup_worktrees_scan_helper.bats` | 0 | 0 |
| `test_cleanup_worktrees_scan_seam.bats` | 0 | 0 |

The two counts are independent because `cleanup_worktrees_dirt_lib.sh` does not contain
`cleanup_worktrees_lib.sh` as a substring — the `_dirt` segment separates them — so no row
is inflated by an overlapping match.

## The three acceptance conditions

**Every suite with a non-zero `cleanup_worktrees_lib.sh` column also has a non-zero
`cleanup_worktrees_dirt_lib.sh` column.** True for all eleven such rows. There is no suite
that sources the report library without also referencing the dirt library.

**The table has exactly 11 such suites.** They are `classification`, `consolidation`,
`deletion`, `detached`, `dirt_classify`, `dirt_clear`, `dirt_failclosed`, `dirt_regression`,
`enumeration`, `hard_failures`, and `report_records` — the ten measured at the audit commit
plus `test_cleanup_worktrees_dirt_failclosed.bats`, added by this remediation cycle.

**The three exclusions each show zero in the `cleanup_worktrees_lib.sh` column.**
`test_cleanup_worktrees_scan_helper.bats` (0), `test_cleanup_worktrees_scan_seam.bats` (0),
and `test_cleanup_worktrees_cli.bats` (0). That is what places all three outside the
narrowed AC-1 text written in [P1-T3]. The third is easy to miss because its
`cleanup_worktrees_dirt_lib.sh` column is non-zero: it references the dirt library without
sourcing the report library, so it is not a self-sourcing suite under AC-1's definition.

## The new suite is in the set

`tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` declares both library paths in
`setup()` at lines 33 and 34 and sources them in its `dirt` and `dirt_log` helpers:

```
33:    LIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_lib.sh"
34:    DIRTLIB="${REPO_ROOT}/scripts/bash/cleanup_worktrees_dirt_lib.sh"
43:        bash -c "source '${ELIB}'; source '${LIB}'; source '${DIRTLIB}'; classify_worktree_dirt '${WT}' 2>/dev/null"
```

This is the same pattern the pre-existing dirt suites use, so the new suite joins the
sourcing set by the same criterion as the other ten.

Output Summary: The table is complete for all 14 matching suites. Eleven are in the AC-1
sourcing set, all eleven reference both libraries, and the three exclusions named in AC-1's
narrowed text each show zero in the `cleanup_worktrees_lib.sh` column.
