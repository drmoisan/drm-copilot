# Duplicate Test Review (Remediation Cycle 1, P1-T2)

Timestamp: 2026-11-07T16-30
Command: sh SCRATCH/issue-1096-debug-py.sh tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py tests/scripts/dev_tools/atomic_executor/test_plan_discovery.py (Black check, Ruff, focused pytest; debugging only, not a gate)
EXIT_CODE: 0
Output Summary: 16 branch cases of `TestPreflightBranches` and 6 of `TestPromptBuilderContext` removed as duplicates; 1 case kept. Both edited files: Black unchanged, Ruff clean, 11 passed in the focused debugging run. No class named `TestPreflightBranches` remains under `tests/scripts/dev_tools/atomic_executor/`.

Rule: a branch case is a duplicate when a main case asserts the same symbol path and the same outcome. Main cases: `TestPreflightQCBranches` in `tests/scripts/dev_tools/atomic_executor/test_cli_part3.py` and `TestPromptBuilderOptionalSections` in `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py`. Each counterpart was checked against the branches of `run_preflight_qc_with_capture`, `resolve_preflight_toolchains`, `_resolve_executable`, `build_preflight_qc_fix_prompt`, `PromptBuilder.build`, `_extract_phase0_read_tasks`, `_extract_task_block`, and `RealPromptBuilderFileSystem`.

## test_cli_part2_part2.py, class TestPreflightBranches

| Branch case | Disposition | Main counterpart |
|---|---|---|
| `test_toolchains_default_to_python_without_a_detector` (3 rows) | REMOVED | `test_resolve_preflight_toolchains_defaults_and_orders` rows: not callable, non-set result, empty set |
| `test_detected_toolchains_order_python_first` | REMOVED | `test_resolve_preflight_toolchains_defaults_and_orders` row: TypeScript and Python set sorted Python first |
| `test_resolve_executable_rejects_empty_argv` | REMOVED | `test_resolve_executable_rejects_empty_argv` |
| `test_capture_rejects_unsupported_toolchain` | REMOVED | `test_unsupported_toolchain_raises` (QC run half) |
| `test_pytest_collect_missing_executable_fails_collect_step` | REMOVED | `test_collect_step_missing_executable_fails` |
| `test_pytest_collect_failure_stops_before_pytest` | REMOVED | `test_collect_step_nonzero_exit_fails` (failed step `pytest-collect` is returned before the pytest step) |
| `test_pytest_collection_error_fails_step` | REMOVED | `test_pytest_failures_outside_expectations_fail` row: collection/import errors |
| `test_pytest_unmatched_failure_fails_without_override_note` | REMOVED | `test_pytest_failures_outside_expectations_fail` row: unlisted nodeid, no override note |
| `test_jest_runtime_error_fails_step` | REMOVED | `test_jest_failures_are_gated_by_expectations` row: runtime error |
| `test_jest_unparsed_failure_fails_step` | REMOVED | `test_jest_failures_are_gated_by_expectations` row: could not be parsed |
| `test_jest_expected_pass_test_name_fails_step` | REMOVED | `test_jest_failures_are_gated_by_expectations` row: test names alpha, beta, gamma with override |
| `test_jest_unmatched_test_name_fails_step` | REMOVED | `test_jest_failures_are_gated_by_expectations` row: test names alpha, beta, gamma (gamma reaches the unmatched-name branch); the no-override branch is reached by the row for file `c.ts` |
| `test_jest_expected_fail_file_is_allowed` | REMOVED | `test_jest_failures_are_gated_by_expectations` row: file `b.ts` allowed |
| `test_jest_expected_pass_file_fails_step` | REMOVED | `test_jest_failures_are_gated_by_expectations` row: files a, b, c with override |
| `test_jest_unmatched_file_fails_step` | REMOVED | `test_jest_failures_are_gated_by_expectations` row: file `c.ts` unexpected |
| `test_fix_prompt_rejects_unsupported_toolchain` | REMOVED | `test_unsupported_toolchain_raises` (fix prompt half) |

The now-unused helpers `_preflight_expectations`, `_install_preflight_stubs`, and `_run_jest_preflight`, and the `TYPE_CHECKING` imports of `PreflightQCResult` and `ResolvedTestExpectations`, were removed with the class. The file returns to its merge-base content.

## test_plan_discovery.py, class TestPromptBuilderContext

| Branch case | Disposition | Main counterpart |
|---|---|---|
| `test_real_file_system_is_dir_delegates_to_path` | REMOVED | `test_real_filesystem_reports_missing_directory` |
| `test_real_file_system_glob_sorts_matches` | KEPT | No main case asserts the sorted order of `RealPromptBuilderFileSystem.glob`; main asserts only an empty result for a missing directory. Moved unchanged into class `TestRealPromptBuilderFileSystem`. |
| `test_build_includes_retry_context` | REMOVED | `test_build_renders_optional_sections_and_task_block` (retry section) |
| `test_build_uses_folder_name_outside_active_root` | REMOVED | `test_build_renders_optional_sections_and_task_block` (feature folder outside the active root) |
| `test_build_warns_when_prompt_exceeds_threshold` | REMOVED | `test_build_renders_optional_sections_and_task_block` (size warning) |
| `test_build_prepends_only_unchecked_phase0_read_tasks` | REMOVED | `test_build_renders_optional_sections_and_task_block` (checked, non-read, and later-phase tasks excluded; check-instruction text) |
| `test_build_task_block_keeps_continuation_and_stops_at_next_task` | REMOVED | `test_build_renders_optional_sections_and_task_block` (indented continuation, inner blank, stop at next task) |

The helpers `_make_builder`, `_task`, `_section`, and the module constants, and the imports `logging`, `PlanTask`, `PromptBuilder`, `InMemoryPromptBuilderFileSystem`, and `make_default_plan_resolver`, were removed. The imports `Mock` and `RealPromptBuilderFileSystem` stay for the kept case.

## Unchanged

The P4-T3 repair of `test_preflight_expected_fail_allows_known_jest_failures` in `test_cli_part3.py` stays. No production file changes in this task.
