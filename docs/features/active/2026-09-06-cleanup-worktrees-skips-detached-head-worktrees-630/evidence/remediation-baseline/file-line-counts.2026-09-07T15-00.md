# Baseline File Line Counts

Timestamp: 2026-09-07T15-00
Task: [P0-T8]

Command: `git grep -c "^" -- "scripts/bash/*.sh" "tests/shell/*.bats"`
EXIT_CODE: 0

`git grep -c` prefixes every count with the matching file path, which is the per-file listing this
task needs. The `-h` suppression form is not used here.

## Output (verbatim)

```
scripts/bash/cleanup-worktrees.sh:103
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
tests/shell/test_cleanup_worktrees_cli.bats:72
tests/shell/test_cleanup_worktrees_consolidation.bats:78
tests/shell/test_cleanup_worktrees_deletion.bats:120
tests/shell/test_cleanup_worktrees_detached.bats:167
tests/shell/test_cleanup_worktrees_enumeration.bats:112
tests/shell/test_cleanup_worktrees_hard_failures.bats:173
tests/shell/test_codex_web_setup_apt_helpers.bats:113
tests/shell/test_codex_web_setup_pypi_connectivity.bats:70
tests/shell/test_codex_web_setup_source_safety.bats:36
tests/shell/test_coverage_demo.bats:26
tests/shell/test_shell_qc_commands.bats:168
tests/shell/test_shell_qc_discovery.bats:92
```

## Named baseline counts

| File | Lines | Headroom to the 500-line cap |
|---|---|---|
| `scripts/bash/cleanup_worktrees_detached_lib.sh` | 301 | 199 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 483 | 17 |
| `scripts/bash/cleanup-worktrees.sh` | 103 | 397 |
| `tests/shell/test_cleanup_worktrees_detached.bats` | 167 | 333 |

Output Summary: no listed count exceeds 500. The largest listed count is 483
(`scripts/bash/cleanup_worktrees_lib.sh`), followed by 458
(`tests/shell/parallel_lane_assertion.bats`) and 406
(`scripts/bash/cleanup_worktrees_actions_lib.sh`). This cycle modifies neither
`cleanup_worktrees_lib.sh` nor `cleanup_worktrees_detached_lib.sh`, so their counts are expected to
be unchanged at Phase 6.
