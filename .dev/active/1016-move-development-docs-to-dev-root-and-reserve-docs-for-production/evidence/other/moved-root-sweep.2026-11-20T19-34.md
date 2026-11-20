# Moved-Root Sweep, Static Half [P1-T7] — remediation cycle 1 (F3 class)

Timestamp: 2026-11-20T19-34
Command: sh SCRATCH/issue-1016-sweep.sh (git -C <worktree> ls-files -- tests extensions/drm-copilot/test filtered case-insensitively by the integration-lane suffixes of config/test-execution-policy.json; git -C <worktree> ls-files of tests/shell/*.bats; grep -nE 'docs/(features|research|engineering|discovery)' over each file)
EXIT_CODE: 0
Output Summary: 65 files in scope (10 integration-lane files, 55 bats files). 13 hits, all in one file, `tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1`; every hit is a non-read (mocked resolver result, mocked git response key, in-memory item fixture, CLI argument string or asserted literal). No real-checkout read was found, so the task changes no tracked file.
SearchScope: tracked files under `tests/` and `extensions/drm-copilot/test/` whose names end (case-insensitively) with `.integration.test.ts`, `.integration.test.js`, `_integration.py`, `.integration.tests.ps1`, `-integration.test.ts` or `integration.tests.ps1`; tracked `*.bats` files under `tests/shell/`.
SearchPatterns: `docs/features`, `docs/research`, `docs/engineering`, `docs/discovery`.
SearchResult: 13 hits in tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 (listed below); none in the other 64 files.

## Files in scope

Integration lane: extensions/drm-copilot/test/extension.collect-commit-context.integration.test.ts; extensions/drm-copilot/test/extension.integration.test.ts; extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts; extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts; tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1; tests/scripts/claude-lib/docs/DocsReferenceIntegration.Tests.ps1; tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1; tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1; tests/scripts/dev_tools/atomic_executor/test_unicode_integration.py; tests/scripts/dev_tools/test_pr_context_integration.py.

Bats (tests/shell/): compute_concurrency_batches_cli, parallel_abandon, parallel_abandon_parity, parallel_bash_manifest_membership, parallel_cohorts, parallel_cohorts_parity, parallel_common, parallel_items_validate, parallel_lane_assertion, parallel_lane_assertion_parity, parallel_manifest_parity, parallel_manifest_validate, parallel_mutation_remove, parallel_mutation_remove_parity, parallel_mutation_run, parallel_mutation_run_parity, parallel_payload_only, parallel_yaml_subset, report_lane_assertion_dispatch, test_cleanup_worktrees_classification, test_cleanup_worktrees_cli, test_cleanup_worktrees_consolidation, test_cleanup_worktrees_deletion, test_cleanup_worktrees_detached, test_cleanup_worktrees_dirt_classify, test_cleanup_worktrees_dirt_clear, test_cleanup_worktrees_dirt_content_locations, test_cleanup_worktrees_dirt_failclosed, test_cleanup_worktrees_dirt_guard_registry, test_cleanup_worktrees_dirt_regression, test_cleanup_worktrees_enumeration, test_cleanup_worktrees_hard_failures, test_cleanup_worktrees_preserve, test_cleanup_worktrees_preserve_eol, test_cleanup_worktrees_preserve_failures, test_cleanup_worktrees_preserve_merge, test_cleanup_worktrees_preserve_merge_fallback, test_cleanup_worktrees_report_records, test_cleanup_worktrees_scan_helper, test_cleanup_worktrees_scan_roots, test_cleanup_worktrees_scan_seam, test_codex_web_setup_apt_helpers, test_codex_web_setup_codex_copy, test_codex_web_setup_codex_dotnet, test_codex_web_setup_codex_installers, test_codex_web_setup_codex_verify, test_codex_web_setup_pypi_connectivity, test_codex_web_setup_source_safety, test_container_versions, test_coverage_demo, test_devcontainer_verification, test_devcontainer_workspace, test_run_test_suite, test_shell_qc_commands, test_shell_qc_discovery (each `.bats`).

## Hits (file: tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1)

| Site | Class | Disposition |
| --- | --- | --- |
| BeforeAll, `Mock Resolve-DevelopmentDocsRoot` returning Root `docs/features` | non-read: mocked path | unchanged; the root is a mocked resolver value and no disk read follows from it |
| `Get-BranchGitResponse`, two `show origin/main:docs/features/templates/...` keys | non-read: mocked git response key | unchanged; served by the mocked `Invoke-ParallelAdmissionGit` |
| `builds the committed scheduling record`, `-RunFolder 'docs/features/parallel/admission-seed'` | non-read: CLI argument string | unchanged; the case asserts zero git calls and compares stdout with a committed fixture |
| Three `show origin/parallel/admission-seed-plan:docs/features/parallel/...` keys (reuse cases) | non-read: mocked git response key | unchanged |
| `Add a half-prepared item` BeforeEach, `feature_folder`, `research_path`, `plan_path` | non-read: in-memory fixture | unchanged; served through mocked git |
| `reports stage spec and resumes preparation at plan`, `-FeatureFolder` argument and two `Should -Be` literals | non-read: argument string and asserted literals | unchanged |

Task check: no tracked file changed, so no task-check run is required; the dynamic half of the sweep runs in the [P1-T8] phase gate.
