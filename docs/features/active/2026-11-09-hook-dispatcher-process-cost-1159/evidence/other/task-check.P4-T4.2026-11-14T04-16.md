# Task check [P4-T4]

Timestamp: 2026-11-14T04-16
Command: sh SCRATCH/issue-1159-pycheck.sh (poetry run black --check; ruff check; pyright; pytest -q --no-cov over the three changed files)
EXIT_CODE: 1
Output Summary: Black 3 files unchanged (after one Black reformat through SCRATCH/issue-1159-pyfmt.sh); Ruff all checks passed (one E501 in a docstring fixed); Pyright 0 errors; pytest 52 passed, 4 failed, all four caused by bundle files that [P6-T1] creates or refreshes.

## Changed files
- tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py (test_claude_command_text_closure and test_codex_command_text_closure add the registry _command_gaps calls)
- tests/scripts/dev_tools/test_codex_core_manifest_closure.py (new registry_hook_paths; find_missing_manifest_paths takes an optional registry_text; the core closure test adds the bundle registry hooks to the roots; new test_guard_reports_registry_hook_absent_from_manifest, which passes)
- tests/scripts/dev_tools/test_discovery_publication_contracts.py (test_roles_carry_stop_and_tool_controls_on_every_host reads hook names from the registry as well)

## Selection and rule
The three changed test files.

## Expected failures (acceptance is evaluated in [P7-T5])
- test_claude_command_text_closure, test_codex_command_text_closure, test_core_manifest_contains_registered_hook_closure_and_resolver_paths: FileNotFoundError for the bundle pretooluse-dispatch.json copies created in [P6-T1].
- test_native_hooks_and_helpers_are_published_and_listed: bundle DiscoveryCapability.psm1 differs from the [P3-T4] source until [P6-T1] copies it.
