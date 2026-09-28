# Post-Change File Line Counts

Timestamp: 2026-09-07T16-30
Task: [P6-T7]

Command: `git grep -c "^" -- "scripts/bash/*.sh" "tests/shell/*.bats"`
EXIT_CODE: 0

`git grep -c` prefixes every count with the matching file path, which is the per-file listing this
task requires. `git grep` performs its own pathspec matching, so the quoted glob operands are
expanded identically on every platform.

## Full printed list (34 rows)

```
scripts/bash/cleanup-worktrees.sh:108
scripts/bash/cleanup_worktrees_actions_lib.sh:406
scripts/bash/cleanup_worktrees_detached_lib.sh:301
scripts/bash/cleanup_worktrees_enumerate_lib.sh:236
scripts/bash/cleanup_worktrees_lib.sh:483
scripts/bash/coverage_demo.sh:8
scripts/bash/coverage_lib.sh:7
scripts/bash/shell-qc.sh:103
scripts/bash/shell_qc_lib.sh:379
tests/shell/parallel_bash_manifest_membership.bats:89
tests/shell/parallel_cohorts.bats:222
tests/shell/parallel_cohorts_parity.bats:101
tests/shell/parallel_common.bats:167
tests/shell/parallel_items_validate.bats:187
tests/shell/parallel_lane_assertion.bats:458
tests/shell/parallel_lane_assertion_parity.bats:243
tests/shell/parallel_manifest_parity.bats:114
tests/shell/parallel_manifest_validate.bats:195
tests/shell/parallel_payload_only.bats:120
tests/shell/parallel_yaml_subset.bats:181
tests/shell/report_lane_assertion_dispatch.bats:160
tests/shell/test_cleanup_worktrees_classification.bats:130
tests/shell/test_cleanup_worktrees_cli.bats:84
tests/shell/test_cleanup_worktrees_consolidation.bats:78
tests/shell/test_cleanup_worktrees_deletion.bats:120
tests/shell/test_cleanup_worktrees_detached.bats:319
tests/shell/test_cleanup_worktrees_enumeration.bats:112
tests/shell/test_cleanup_worktrees_hard_failures.bats:173
tests/shell/test_codex_web_setup_apt_helpers.bats:113
tests/shell/test_codex_web_setup_pypi_connectivity.bats:70
tests/shell/test_codex_web_setup_source_safety.bats:36
tests/shell/test_coverage_demo.bats:26
tests/shell/test_shell_qc_commands.bats:168
tests/shell/test_shell_qc_discovery.bats:92
```

## 500-line limit

The largest count anywhere in the listing is 483 (`scripts/bash/cleanup_worktrees_lib.sh`), followed
by 458 (`tests/shell/parallel_lane_assertion.bats`) and 406
(`scripts/bash/cleanup_worktrees_actions_lib.sh`). No listed count exceeds 500, so the file-size
limit in `.claude/rules/general-code-change.md` holds for every file in the span.

## Unmodified-library confirmation against [P0-T8]

| File | [P0-T8] baseline | Post-change | Change |
|---|---|---|---|
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 301 | 301 | 0 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 483 | 483 | 0 |

Both counts are unchanged from the [P0-T8] baseline recorded in
`evidence/remediation-baseline/file-line-counts.2026-09-07T15-00.md`, because this cycle modifies
neither file. The plan's Do-Not-Do list item 1 forbids production-code change to either library, and
the identical counts are consistent with that constraint.

## Post-change counts for the files this cycle modified

| File | [P0-T8] baseline | Post-change | Change | Task |
|---|---|---|---|---|
| `scripts/bash/cleanup-worktrees.sh` | 103 | **108** | +5 | [P5-T5], `usage()` heredoc text only |
| `tests/shell/test_cleanup_worktrees_detached.bats` | 167 | **319** | +152 | [P2-T1]–[P2-T6], [P4-T1]–[P4-T6], [P5-T1] |
| `tests/shell/test_cleanup_worktrees_cli.bats` | 72 | **84** | +12 | [P5-T2], [P5-T6] |

The +5 lines in `scripts/bash/cleanup-worktrees.sh` are heredoc body lines inside `usage()`, which
are data rather than statements. They add no executable statement and therefore do not alter the
kcov denominator.

Output Summary: no listed count exceeds 500; the largest is 483.
`scripts/bash/cleanup_worktrees_detached_lib.sh` (301) and `scripts/bash/cleanup_worktrees_lib.sh`
(483) both carry the same counts recorded in [P0-T8], because this cycle does not modify either
file. The post-change counts for the modified files are `scripts/bash/cleanup-worktrees.sh` 108,
`tests/shell/test_cleanup_worktrees_detached.bats` 319, and
`tests/shell/test_cleanup_worktrees_cli.bats` 84.
