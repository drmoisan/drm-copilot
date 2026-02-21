# test-violations (Issue #35)

- Date captured: 2026-02-21
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/test-violations/ (Issue #35)

- Issue: #35
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/35
- Last Updated: 2026-02-21
## Summary

This repo has a clear unit-test policy that discourages filesystem-dependent tests, but a large set of tests currently use `tmp_path` for temporary file creation. The attached inventory shows broad, historical usage patterns across `tests/scripts/dev_tools/**`, with commit attribution showing these are pre-existing rather than newly introduced regressions. This issue captures the full evidence set for triage and follow-up remediation planning.

## Environment

- OS/version: Windows (from workspace context)
- Python version: Not captured in the source inventory document
- Command/flags used: Inventory review of Python test files under `tests/**/*.py`, focusing on `tmp_path` usage and checking for `tempfile`, `tmpdir`, and `tmp_path_factory`
- Data source or fixture: Repository test files in `tests/scripts/dev_tools/**`

## Steps to Reproduce

1. Review Python test files under `tests/**/*.py` for temporary-file fixture usage (`tmp_path`).
2. Build an inventory of each test/fixture using `tmp_path` and map each entry to its introducing commit.
3. Classify each entry deterministically against baseline commit `d7d8e3721b45fdc09c67ff603aa374e278a0d496` (`pre-existing` if present at baseline, otherwise `new problem`).

## Expected Behavior

Unit tests should align with the unit-test policy and avoid unnecessary filesystem-backed temporary file usage where in-memory alternatives are appropriate and sufficient.

## Actual Behavior

The test suite contains many tests using `tmp_path` across multiple files. The inventory confirms these are overwhelmingly historical and pre-existing relative to baseline commit `d7d8e3721b45fdc09c67ff603aa374e278a0d496`.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: See linked inventory at `docs/features/active/2026-02-19-minor-audit-small-change-28/v3/test-violations.md` and full findings embedded below.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Scope from source inventory:

Reviewed all Python test files under `tests/**/*.py` for temporary file usage. This inventory flags any test or fixture that uses `tmp_path` (pytest temporary path fixture). No uses of `tempfile` APIs, `tmpdir`, or `tmp_path_factory` were found.

Baseline commit used for deterministic classification:

`d7d8e3721b45fdc09c67ff603aa374e278a0d496` — tests present at this commit are classified as `pre-existing`. Tests absent from this commit are classified as `new problem`.

### [tests/scripts/dev_tools/test_validate_json.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [test_load_schema_from_cache](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_load_schema_unsupported_scheme](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_load_schema_missing_scheme](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_load_schema_relative_path](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_load_schema_fetch_and_cache](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_validate_relative_schema](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_collect_targets_with_file_paths](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_collect_targets_with_directory](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_collect_targets_defaults_to_governed](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_no_files](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_all_valid](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_validation_failure](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_verbose_mode](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_custom_cache_dir](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_validate_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/test_render_helpers.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [TestResolveFeatureDir.test_exact_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_strong_pattern_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_weak_substring_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_no_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_missing_base_dir](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_ignores_files_in_fuzzy_search](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestReadTextFile.test_reads_existing_file](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestReadTextFile.test_missing_file_returns_empty](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGatherFeatureExcerptsIntegration.test_full_integration_with_all_docs](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGatherFeatureExcerptsIntegration.test_multiple_features](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGatherFeatureExcerptsIntegration.test_missing_feature_directory_skipped](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render_helpers.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/test_render.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [TestResolveFeatureDir.test_resolve_feature_dir_direct_exact_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_base_does_not_exist](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_no_subdirectories](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_skips_files](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_strong_pattern_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_multiple_strong_matches_returns_first](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_weak_match_when_no_strong](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_multiple_weak_matches_returns_first](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_prefers_strong_over_weak](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_no_matches](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_pattern_with_underscore_delimiter](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_pattern_at_start](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_pattern_at_end](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_render.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [test_main_success](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py) | pre-existing | [4febd95](https://github.com/drmoisan/drm-copilot/commit/4febd95) |
| [test_main_template_not_found](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py) | pre-existing | [4febd95](https://github.com/drmoisan/drm-copilot/commit/4febd95) |
| [test_main_target_not_found](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py) | pre-existing | [4febd95](https://github.com/drmoisan/drm-copilot/commit/4febd95) |
| [test_main_clipboard_copy_fails](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py) | pre-existing | [4febd95](https://github.com/drmoisan/drm-copilot/commit/4febd95) |
| [test_main_default_workspace](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py) | pre-existing | [4febd95](https://github.com/drmoisan/drm-copilot/commit/4febd95) |
| [test_main_template_read_error](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py) | pre-existing | [4febd95](https://github.com/drmoisan/drm-copilot/commit/4febd95) |

### [tests/scripts/dev_tools/test_pr_context_integration.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_pr_context_integration.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [test_collect_and_write_end_to_end_scenarios](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_pr_context_integration.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/test_json_config.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [test_iter_governed_files_empty](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_iter_governed_files_excludes_vscode_json](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [4febd95](https://github.com/drmoisan/drm-copilot/commit/4febd95) |
| [test_iter_governed_files_excludes_nested_vscode_json](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [4febd95](https://github.com/drmoisan/drm-copilot/commit/4febd95) |
| [test_iter_governed_files_excludes_data_dir](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_iter_governed_files_excludes_artifacts_dir](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_iter_governed_files_excludes_parent_in_excluded](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_iter_governed_files_excludes_devcontainer_json](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [4febd95](https://github.com/drmoisan/drm-copilot/commit/4febd95) |
| [test_iter_governed_files_finds_scripts_json](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_iter_governed_files_finds_docs_json](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_iter_governed_files_finds_examples_json](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_iter_governed_files_accepts_str_path](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_iter_governed_files_mixed_included_excluded](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_iter_governed_files_handles_non_file_matches](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_json_config.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/test_github.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [TestGhClientAvailability.test_gh_not_installed](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientAvailability.test_gh_not_authenticated](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientAvailability.test_gh_available_success](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientAvailability.test_ensure_available_raises](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientAvailability.test_repo_name_caching](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientAvailability.test_repo_name_returns_none_on_invalid_json](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientClassifyEntity.test_classify_as_issue](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientClassifyEntity.test_classify_as_pull](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientClassifyEntity.test_classify_not_found](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientClosingIssues.test_closing_issues_returns_list](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientClosingIssues.test_closing_issues_empty](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientIssueDetails.test_issue_details_minimal](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientIssueDetails.test_issue_details_with_labels](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientPrDetails.test_pr_details_basic](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCurrentPr.test_current_pr_not_available](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCurrentPr.test_current_pr_no_pr](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientFetchRepoFile.test_fetch_repo_file_success](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientFetchRepoFile.test_fetch_repo_file_not_found](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCiStatus.test_ci_status_returns_status](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCiStatus.test_ci_status_empty_runs](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientIssueDetailsExtended.test_issue_details_with_comments](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientIssueDetailsExtended.test_issue_details_with_body](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientIssueDetailsExtended.test_issue_details_with_assignees](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientPrDetailsExtended.test_pr_details_with_all_fields](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCurrentPrExtended.test_current_pr_success](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCurrentPrExtended.test_current_pr_invalid_json](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCurrentPrExtended.test_current_pr_with_labels_and_assignees](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCurrentPrExtended.test_current_pr_with_closing_issues](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCurrentPrExtended.test_current_pr_with_author](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCurrentPrExtended.test_current_pr_malformed_data](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientUserStory.test_issue_details_with_user_story_link](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientUserStory.test_issue_details_user_story_remote_fetch](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientPrDetailsError.test_pr_details_raises_on_no_repo](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientPrDetailsError.test_pr_details_raises_on_bad_payload](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientFilesChanged.test_pr_details_extracts_files](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCommentEdgeCases.test_issue_details_comment_without_user](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientCommentEdgeCases.test_issue_details_comment_malformed_entries](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientLabelAssigneeEdgeCases.test_pr_details_malformed_labels](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientLabelAssigneeEdgeCases.test_pr_details_malformed_assignees](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientLabelAssigneeEdgeCases.test_pr_details_closing_issues_malformed](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientLabelAssigneeEdgeCases.test_pr_details_author_extraction](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientLabelAssigneeEdgeCases.test_issue_details_malformed_labels](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGhClientLabelAssigneeEdgeCases.test_issue_details_malformed_assignees](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_github.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/test_collect_commit_context.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [TestCollectCommitContext.test_creates_output_file](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_creates_parent_directories](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_output_contains_expected_sections](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_handles_no_upstream](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_handles_no_staged_changes](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_handles_no_unstaged_changes](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_handles_no_untracked_files](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_handles_no_changes_in_diff_stat](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_filters_python_files](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_handles_no_python_files_changed](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_handles_no_previous_commits](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_formats_last_commit_correctly](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestCollectCommitContext.test_prints_output_path](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMain.test_successful_execution_returns_zero](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMain.test_uses_default_output_path](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMain.test_accepts_custom_output_path](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMain.test_accepts_short_flag](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMain.test_returns_one_on_subprocess_error](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMain.test_returns_one_on_general_exception](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_commit_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/test_git.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_git.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [git_client (fixture)](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_git.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestSubprocessRunner.test_run_success](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_git.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGitClient.test_resolve_root_when_git_dir_exists](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_git.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGitClient.test_resolve_root_when_git_dir_missing](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_git.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/test_format_json.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_format_json.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [test_main_no_paths_uses_governed](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_format_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_with_file_path](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_format_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_with_directory_path](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_format_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_check_mode_exits_1_on_changes](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_format_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_failure_exits_1](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_format_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_verbose_mode_already_formatted](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_format_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_main_verbose_mode_reformatted](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_format_json.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/test_feature_docs.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [TestGatherFeatureExcerpts.test_gather_feature_excerpts_direct_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGatherFeatureExcerpts.test_gather_feature_excerpts_fuzzy_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGatherFeatureExcerpts.test_gather_feature_excerpts_not_found](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGatherFeatureExcerpts.test_gather_feature_excerpts_promoted](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGatherFeatureExcerpts.test_gather_feature_excerpts_extracts_issue_refs](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestGatherFeatureExcerpts.test_gather_feature_excerpts_multiple_features](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_direct_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_pattern_match_prefix](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_pattern_match_suffix](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_pattern_match_middle](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_weak_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_strong_over_weak](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_skips_files](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_sorted_order](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_no_match](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestResolveFeatureDir.test_resolve_feature_dir_empty_directory](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_feature_docs.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/test_collect_pr_context.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_pr_context.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [test_gather_feature_excerpts_reads_active_docs](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_pr_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_collect_and_write_uses_feature_refs_and_scoping](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_pr_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_write_output_creates_parent_and_appends](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_pr_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_collect_and_write_renders_non_material_scoping](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_pr_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_collect_and_write_handles_offline_gh](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_pr_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [test_collect_and_write_includes_intent_and_additional_context](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/test_collect_pr_context.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/atomic_executor/test_qc_runner.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [TestQCRunnerInit.test_init_stores_workspace](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerChangedFiles.test_changed_files_parses_git_status](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerChangedFiles.test_changed_files_handles_empty_output](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerChangedFiles.test_changed_files_handles_malformed_lines](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerGitHasChanges.test_git_has_changes_ignores_artifacts](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerGitHasChanges.test_git_has_changes_reports_non_artifact_changes](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerDiffSignature.test_diff_signature_ignores_excluded_artifacts](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerFullLoop.test_full_loop_completes_when_black_changes_nothing](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerFilterHelpers.test_filter_python_files_keeps_py_only](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerFilterHelpers.test_filter_python_files_returns_empty_for_no_py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerFilterHelpers.test_filter_test_files_keeps_tests_only](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerFilterHelpers.test_filter_test_files_requires_py_extension](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerRunScoped.test_run_scoped_runs_all_tools_on_changed_files](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerRunScoped.test_run_scoped_skips_when_no_python_files](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerRunScoped.test_run_scoped_skips_tests_when_no_test_files](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerRunScoped.test_run_scoped_raises_on_tool_failure](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerRunFull.test_run_full_runs_all_tools_on_entire_codebase](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerRunFull.test_run_full_raises_on_tool_failure](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerRunFull.test_phase_expected_fail_tolerates_pytest_failures](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerRunFull.test_phase_unexpected_fail_raises_on_pytest_failures](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerEdgeCases.test_run_helper_passes_cwd_to_subprocess](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerEdgeCases.test_run_helper_handles_capture_output_flag](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestQCRunnerEdgeCases.test_changed_files_with_spaces_in_paths](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_qc_runner.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/atomic_executor/test_plan_parser.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [TestPlanParserInit.test_init_with_valid_file](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserInit.test_init_with_nonexistent_file_raises](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserParse.test_parse_empty_file_returns_empty_model](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserParse.test_parse_single_unchecked_task](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserParse.test_parse_defaults_expect_fail_false_when_tag_missing](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserParse.test_parse_single_checked_task](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserParse.test_parse_multiple_tasks_multiple_phases](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserParse.test_parse_ignores_non_task_lines](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserNextUncheckedTask.test_next_unchecked_task_returns_first_unchecked](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserNextUncheckedTask.test_next_unchecked_task_returns_none_when_all_checked](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserNextUncheckedTask.test_next_unchecked_task_returns_none_for_empty_model](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserFindTaskById.test_find_task_by_id_returns_matching_task](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserFindTaskById.test_find_task_by_id_raises_for_missing_id](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserPhaseComplete.test_phase_complete_returns_true_when_all_checked](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserPhaseComplete.test_phase_complete_returns_false_when_any_unchecked](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserPhaseComplete.test_phase_complete_returns_false_for_nonexistent_phase](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserFlipCheckbox.test_flip_checkbox_checks_unchecked_task](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserFlipCheckbox.test_flip_checkbox_is_idempotent_for_checked_task](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserFlipCheckbox.test_flip_checkbox_preserves_other_lines](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserPreflightValidate.test_preflight_validate_passes_with_phase_0_and_qa](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserPreflightValidate.test_preflight_validate_raises_when_phase_0_missing](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserPreflightValidate.test_preflight_validate_raises_when_qa_phase_missing](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserPreflightValidate.test_preflight_validate_raises_when_both_missing](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserEdgeCases.test_parse_handles_mixed_checkbox_formats](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserEdgeCases.test_parse_handles_whitespace_variations](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPlanParserEdgeCases.test_flip_checkbox_is_idempotent](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_plan_parser.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [TestFeatureResolverInit.test_init_with_valid_paths](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverInit.test_init_raises_for_nonexistent_active_dir](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverListFolders.test_list_folders_returns_subdirectories](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverListFolders.test_list_folders_returns_empty_for_no_subdirs](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverResolve.test_resolve_with_direct_path_absolute](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverResolve.test_resolve_with_plan_md_path](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverResolve.test_resolve_with_explicit_feature_arg](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverResolve.test_resolve_raises_for_nonexistent_feature_arg](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverResolve.test_resolve_with_git_branch_inference](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverResolve.test_resolve_raises_when_no_matches_found](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverResolve.test_resolve_raises_for_multiple_matches](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverEdgeCases.test_resolve_with_issue_number_suffix](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverEdgeCases.test_resolve_handles_git_not_found](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverEdgeCases.test_resolve_handles_git_subprocess_error](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestFeatureResolverEdgeCases.test_list_folders_raises_for_no_folders](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_feature_resolver.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

### [tests/scripts/dev_tools/atomic_executor/test_cli.py](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py)

| Test | Status | Introduced In |
|------|--------|---------------|
| [TestResolveWorkspace.test_resolve_uses_explicit_workspace](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestEnsureCleanTree.test_ensure_clean_tree_passes_for_clean_tree](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestEnsureCleanTree.test_ensure_clean_tree_raises_for_dirty_tree](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRefuseProtectedBranch.test_refuse_raises_for_main_branch](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRefuseProtectedBranch.test_refuse_raises_for_master_branch](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRefuseProtectedBranch.test_refuse_raises_for_development_branch](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRefuseProtectedBranch.test_refuse_passes_for_feature_branch](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRefuseProtectedBranch.test_refuse_handles_git_error](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMainEdgeCases.test_main_exits_early_with_print_prompt](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMainEdgeCases.test_main_exits_early_with_copy_prompt](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMainEdgeCases.test_main_returns_error_for_missing_plan](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMainEdgeCases.test_main_returns_zero_when_plan_already_complete](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMainEdgeCases.test_main_returns_error_for_missing_template](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMainEdgeCases.test_main_with_copy_prompt_fallback_when_clipboard_fails](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMainEdgeCases.test_main_execute_with_start_flag](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMainEdgeCases.test_main_execute_when_all_tasks_complete](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestMainEdgeCases.test_main_successful_execution_with_scoped_qc](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPreflightQC.test_build_preflight_qc_fix_prompt_includes_workspace](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPreflightQC.test_run_preflight_qc_with_capture_returns_success](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestPreflightQC.test_run_preflight_qc_with_capture_returns_failure](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRunCopilot.test_run_copilot_raises_when_executable_not_found](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRunCopilot.test_run_copilot_rejects_vscode_shim](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRunCopilot.test_run_copilot_rejects_vscode_shim_remote_paths](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRunCopilot.test_run_copilot_creates_log_directory](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRunCopilot.test_run_copilot_prefers_cmd_wrapper_over_bare_executable_name](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [5c64f47](https://github.com/drmoisan/drm-copilot/commit/5c64f47) |
| [TestRunCopilot.test_run_copilot_invokes_with_correct_arguments](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRunCopilot.test_run_copilot_normalizes_gpt_5_2_codex_display_name](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [5c64f47](https://github.com/drmoisan/drm-copilot/commit/5c64f47) |
| [TestRunCopilot.test_run_copilot_permission_denied_fails_fast_with_actionable_error](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRunCopilot.test_run_copilot_reuses_session_when_requested](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRunCopilot.test_run_copilot_trusts_workspace_in_config](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |
| [TestRunCopilot.test_run_copilot_times_out_when_cli_is_idle](../../active/2026-02-19-minor-audit-small-change-28/v3/../../../../../tests/scripts/dev_tools/atomic_executor/test_cli.py) | pre-existing | [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) |

Additional notes from source inventory:

- No tests using `tempfile` APIs (`TemporaryDirectory`, `NamedTemporaryFile`, `mkstemp`, etc.) were found.
- `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` explicitly documents avoiding `tmp_path` and does not create temporary files.
- Commit legend:
	- [c730d85](https://github.com/drmoisan/drm-copilot/commit/c730d85) — `(feat(dev-tools)): import repo tooling, policies, and automation scaffolding`
	- [4febd95](https://github.com/drmoisan/drm-copilot/commit/4febd95) — `(feat(dev-tools)): add hard-lock prompt resolver and exclude JSONC from jq formatting`
	- [5c64f47](https://github.com/drmoisan/drm-copilot/commit/5c64f47) — `(fix(dev-tools)): relax Copilot CLI model validation and harden Windows launch`

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
- [x] Integration scenario to retest
- [x] Manual verification notes

- Unit coverage areas: prioritize test suites under `tests/scripts/dev_tools/**` where in-memory alternatives can replace filesystem temp paths.
- Integration scenario to retest: rerun scoped test groups affected by any fixture refactor and validate no behavior regressions.
- Manual verification notes: preserve deterministic commit-attribution approach when re-auditing to distinguish pre-existing vs newly introduced issues.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch