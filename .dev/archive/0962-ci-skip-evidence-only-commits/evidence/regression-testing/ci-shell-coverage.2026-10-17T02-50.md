# P7-T4 Shell-coverage results of the first full PR run (AC-37, AC-38)

Timestamp: 2026-10-17T02-50
Command: gh run view 38995143126 --repo drmoisan/drm-copilot --json jobs --jq .jobs[] | select(.name | test("Shell Coverage")) | [.databaseId, .conclusion] | @tsv ; gh run view 38995143126 --repo drmoisan/drm-copilot --log --job 117285990107 ; gh run view 38948304976 --repo drmoisan/drm-copilot --json jobs --jq .jobs[] | select(.name | test("Shell Coverage")) | [.databaseId, .conclusion] | @tsv ; gh run view 38948304976 --repo drmoisan/drm-copilot --log --job 117132949639 ; git grep -c -E -e ^[[:space:]]*@test  412c6ba20512ceb6c219431ba6c5f5d8472cf07b -- tests/shell ; git ls-tree -r --name-only 412c6ba20512ceb6c219431ba6c5f5d8472cf07b -- tests/shell
EXIT_CODE: 0
Output Summary: shell-coverage job 117285990107 success; TAP plan 1..733 equals 733 declared @test lines; no nested .bats; both --recursive tests and all six check_coverage_threshold tests ok; Bash coverage 95.2% meets the 85% minimum; shell_qc_lib.sh 91.3% (baseline 90.5%).

BATS-TESTS-DECLARED: 733
BATS-TESTS-RUN: 733 (TAP plan line `1..733`)
NESTED-BATS-AT-HEAD1: 0
NOT-OK-LINES: 0
KCOV-RECIPE (sh SCRATCH/tools/run-cr.sh cr-kcov-file -ReportDir SCRATCH/stage/kcov-38995143126 -FileSuffix shell_qc_lib.sh): KCOV-REPORT: present | KCOV-TOTAL: percent=95.2 | KCOV-FILE-MATCHES: 1 | KCOV-FILE: shell_qc_lib.sh | percent=91.3 | threshold=85 | PASS | EXIT_CODE_COMPUTED: 0
KCOV-RECIPE (sh SCRATCH/tools/run-cr.sh cr-kcov-file -ReportDir SCRATCH/stage/kcov-38948304976 -FileSuffix shell_qc_lib.sh): KCOV-REPORT: present | KCOV-TOTAL: percent=95.2 | KCOV-FILE-MATCHES: 1 | KCOV-FILE: shell_qc_lib.sh | percent=90.5 | threshold=85 | PASS | EXIT_CODE_COMPUTED: 0
BASH-COVERAGE: baseline=95.2 | post=95.2 | shell_qc_lib.sh=91.3 (baseline 90.5)
AC-37: PASS
AC-38: PASS

## `gh run view 38995143126 --repo drmoisan/drm-copilot --json jobs --jq .jobs[] | select(.name | test("Shell Coverage")) | [.databaseId, .conclusion] | @tsv`

exit: 0

```text
117285990107	success
```

## `gh run view 38995143126 --repo drmoisan/drm-copilot --log --job 117285990107`

exit: 0

```text
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:32:00.0490896Z 1..733
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:36:04.9595286Z ok 712 test passes --recursive to bats for each test directory
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:36:04.9595731Z ok 713 test --coverage passes --recursive to bats under kcov
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:36:04.9596212Z ok 714 check_coverage_threshold fails below the default 85 percent minimum
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:36:04.9596748Z ok 715 check_coverage_threshold passes when coverage equals the minimum
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:36:04.9597272Z ok 716 check_coverage_threshold passes when coverage is above the minimum
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:36:04.9597811Z ok 717 check_coverage_threshold rejects a minimum that is not an integer
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:36:04.9598346Z ok 718 check_coverage_threshold rejects a minimum above 100
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:36:04.9599057Z ok 719 check_coverage_threshold prints nothing and passes when cov.xml is missing
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:36:05.2632566Z Bash coverage (lines): 95.2%
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-17T02:36:05.2686408Z Bash coverage 95.2% meets the minimum line coverage of 85%.
```

## `gh run view 38948304976 --repo drmoisan/drm-copilot --json jobs --jq .jobs[] | select(.name | test("Shell Coverage")) | [.databaseId, .conclusion] | @tsv`

exit: 0

```text
117132949639	success
```

## `gh run view 38948304976 --repo drmoisan/drm-copilot --log --job 117132949639`

exit: 0

```text
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-16T18:37:27.6726341Z 1..725
shell-coverage / Shell Coverage (Bats + kcov)	UNKNOWN STEP	2026-10-16T18:42:42.9297954Z Bash coverage (lines): 95.2%
```

## `git grep -c -E -e ^[[:space:]]*@test  412c6ba20512ceb6c219431ba6c5f5d8472cf07b -- tests/shell`

exit: 0

```text
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/compute_concurrency_batches_cli.bats:5
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_abandon.bats:14
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_abandon_parity.bats:3
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_bash_manifest_membership.bats:6
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_cohorts.bats:46
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_cohorts_parity.bats:3
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_common.bats:24
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_items_validate.bats:22
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_lane_assertion.bats:22
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_lane_assertion_parity.bats:8
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_manifest_parity.bats:3
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_manifest_validate.bats:26
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_mutation_remove.bats:44
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_mutation_remove_parity.bats:3
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_mutation_run.bats:51
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_mutation_run_parity.bats:3
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_payload_only.bats:19
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/parallel_yaml_subset.bats:23
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/report_lane_assertion_dispatch.bats:14
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_classification.bats:21
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_cli.bats:11
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_consolidation.bats:6
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_deletion.bats:16
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_detached.bats:26
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_dirt_classify.bats:26
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_dirt_clear.bats:15
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_dirt_content_locations.bats:2
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_dirt_failclosed.bats:15
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats:3
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_dirt_regression.bats:12
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_enumeration.bats:15
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_hard_failures.bats:17
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_preserve.bats:26
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_preserve_eol.bats:6
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_preserve_failures.bats:11
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_report_records.bats:18
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_scan_helper.bats:3
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_scan_roots.bats:21
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_cleanup_worktrees_scan_seam.bats:2
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_codex_web_setup_apt_helpers.bats:5
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_codex_web_setup_codex_copy.bats:18
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_codex_web_setup_codex_dotnet.bats:14
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_codex_web_setup_codex_installers.bats:18
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_codex_web_setup_codex_verify.bats:14
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_codex_web_setup_pypi_connectivity.bats:4
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_codex_web_setup_source_safety.bats:2
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_coverage_demo.bats:3
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_shell_qc_commands.bats:30
412c6ba20512ceb6c219431ba6c5f5d8472cf07b:tests/shell/test_shell_qc_discovery.bats:14
```

## `git ls-tree -r --name-only 412c6ba20512ceb6c219431ba6c5f5d8472cf07b -- tests/shell`

exit: 0

```text
tests/shell/compute_concurrency_batches_cli.bats
tests/shell/helpers/codex_web_setup_common.bash
tests/shell/parallel_abandon.bats
tests/shell/parallel_abandon_parity.bats
tests/shell/parallel_bash_manifest_membership.bats
tests/shell/parallel_cohorts.bats
tests/shell/parallel_cohorts_parity.bats
tests/shell/parallel_common.bats
tests/shell/parallel_items_validate.bats
tests/shell/parallel_lane_assertion.bats
tests/shell/parallel_lane_assertion_parity.bats
tests/shell/parallel_manifest_parity.bats
tests/shell/parallel_manifest_validate.bats
tests/shell/parallel_mutation_remove.bats
tests/shell/parallel_mutation_remove_parity.bats
tests/shell/parallel_mutation_run.bats
tests/shell/parallel_mutation_run_parity.bats
tests/shell/parallel_payload_only.bats
tests/shell/parallel_yaml_subset.bats
tests/shell/report_lane_assertion_dispatch.bats
tests/shell/test_cleanup_worktrees_classification.bats
tests/shell/test_cleanup_worktrees_cli.bats
tests/shell/test_cleanup_worktrees_consolidation.bats
tests/shell/test_cleanup_worktrees_deletion.bats
tests/shell/test_cleanup_worktrees_detached.bats
tests/shell/test_cleanup_worktrees_dirt_classify.bats
tests/shell/test_cleanup_worktrees_dirt_clear.bats
tests/shell/test_cleanup_worktrees_dirt_content_locations.bats
tests/shell/test_cleanup_worktrees_dirt_failclosed.bats
tests/shell/test_cleanup_worktrees_dirt_guard_registry.bats
tests/shell/test_cleanup_worktrees_dirt_regression.bats
tests/shell/test_cleanup_worktrees_enumeration.bats
tests/shell/test_cleanup_worktrees_hard_failures.bats
tests/shell/test_cleanup_worktrees_preserve.bats
tests/shell/test_cleanup_worktrees_preserve_eol.bats
tests/shell/test_cleanup_worktrees_preserve_failures.bats
tests/shell/test_cleanup_worktrees_report_records.bats
tests/shell/test_cleanup_worktrees_scan_helper.bats
tests/shell/test_cleanup_worktrees_scan_roots.bats
tests/shell/test_cleanup_worktrees_scan_seam.bats
tests/shell/test_codex_web_setup_apt_helpers.bats
tests/shell/test_codex_web_setup_codex_copy.bats
tests/shell/test_codex_web_setup_codex_dotnet.bats
tests/shell/test_codex_web_setup_codex_installers.bats
tests/shell/test_codex_web_setup_codex_verify.bats
tests/shell/test_codex_web_setup_pypi_connectivity.bats
tests/shell/test_codex_web_setup_source_safety.bats
tests/shell/test_coverage_demo.bats
tests/shell/test_shell_qc_commands.bats
tests/shell/test_shell_qc_discovery.bats
```
