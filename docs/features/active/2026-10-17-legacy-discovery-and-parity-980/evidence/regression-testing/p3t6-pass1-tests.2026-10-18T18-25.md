# p3t6-pass1-tests

Timestamp: 2026-10-18T18-25
Command: poetry run python SCRATCH\issue-980-p3t6-tests.py pass1
EXIT_CODE: 1
Output Summary: FAILED tests/discovery_runtime/test_references.py::test_transport_entries_resolve_their_declared_repository[source-snapshot-manifest-artifacts-source_repository-feature-contract]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; ======================= 1 failed, 301 passed in 30.39s ========================; {"pytest_exit": 1, "source_stable": true, "tests_stable": true, "elapsed_seconds": 30.66189000000304}

Working directory: .
Started: 2026-10-18T18:25:25.245384+00:00
Duration seconds: 31.679
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
{"label": "pass1", "pytest_arguments": ["-o", "addopts=-ra", "tests/discovery_runtime/test_snapshot_export.py", "tests/discovery_runtime/test_snapshot_import.py", "tests/discovery_runtime/test_path_policy.py", "tests/discovery_runtime/test_path_resolution.py", "tests/discovery_runtime/test_path_collisions.py", "tests/discovery_runtime/test_references.py", "tests/discovery_runtime/test_reference_uniqueness.py", "tests/discovery_runtime/test_mutation_plan.py", "tests/discovery_runtime/test_mutation_commit.py", "-v", "-x", "--durations=10", "--junitxml=EXTERNAL_PATH", "--cov=drm_copilot_discovery.path_policy", "--cov=drm_copilot_discovery.mutation_plan", "--cov=drm_copilot_discovery.mutation_io", "--cov=drm_copilot_discovery.references", "--cov=drm_copilot_discovery.transport_manifest", "--cov=drm_copilot_discovery.source_snapshots", "--cov-branch", "--cov-report=term-missing", "--cov-report=json:EXTERNAL_PATH"]}
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 430 items

tests/discovery_runtime/test_path_collisions.py::test_collection_grant_only_matches_its_exact_configured_file PASSED [  0%]
tests/discovery_runtime/test_path_collisions.py::test_configuration_classifies_missing_inputs_and_rejects_wrong_existing_kind PASSED [  0%]
tests/discovery_runtime/test_path_collisions.py::test_conflicting_input_file_and_directory_declarations_fail[documentation_roots-value1] PASSED [  0%]
tests/discovery_runtime/test_path_collisions.py::test_conflicting_input_file_and_directory_declarations_fail[project_entry_points-value0] PASSED [  0%]
tests/discovery_runtime/test_path_collisions.py::test_custom_unicode_layout_and_separate_output_roots_are_supported PASSED [  1%]
tests/discovery_runtime/test_path_collisions.py::test_exact_grant_is_required_even_inside_a_permitted_output_root[acceptance-view-acceptance-acceptance.alpha.feature] PASSED [  1%]
tests/discovery_runtime/test_path_collisions.py::test_exact_grant_is_required_even_inside_a_permitted_output_root[completion-report-reports-completion-report.md] PASSED [  1%]
tests/discovery_runtime/test_path_collisions.py::test_exact_grant_is_required_even_inside_a_permitted_output_root[evidence-reference-evidence-evidence.alpha.json] PASSED [  1%]
tests/discovery_runtime/test_path_collisions.py::test_exact_grant_is_required_even_inside_a_permitted_output_root[feature-contract-feature_contracts-feature.alpha.json] PASSED [  2%]
tests/discovery_runtime/test_path_collisions.py::test_exact_grant_is_required_even_inside_a_permitted_output_root[implementation-record-implementation_records-implementation.alpha.json] PASSED [  2%]
tests/discovery_runtime/test_path_collisions.py::test_exact_grant_is_required_even_inside_a_permitted_output_root[inventory-snapshot-inventory-inventory.alpha.json] PASSED [  2%]
tests/discovery_runtime/test_path_collisions.py::test_exact_grant_is_required_even_inside_a_permitted_output_root[runtime-characterization-scenario-characterization-scenario.alpha.yaml] PASSED [  2%]
tests/discovery_runtime/test_path_collisions.py::test_exact_grant_is_required_even_inside_a_permitted_output_root[source-snapshot-manifest-source_snapshots-snapshot.alpha.json] PASSED [  3%]
tests/discovery_runtime/test_path_collisions.py::test_existing_namespace_aliases_fail_on_every_host[names0-file.cs] PASSED [  3%]
tests/discovery_runtime/test_path_collisions.py::test_existing_namespace_aliases_fail_on_every_host[names1-\xe9.cs] PASSED [  3%]
tests/discovery_runtime/test_path_collisions.py::test_existing_namespace_aliases_fail_on_every_host[names2-file.cs] PASSED [  3%]
tests/discovery_runtime/test_path_collisions.py::test_existing_namespace_aliases_fail_on_every_host[names3-file.cs] PASSED [  3%]
tests/discovery_runtime/test_path_collisions.py::test_extension_schema_cannot_be_placed_in_writable_artifact_scope PASSED [  4%]
tests/discovery_runtime/test_path_collisions.py::test_nested_output_policy_names_remain_protected[.codex/hooks.json] PASSED [  4%]
tests/discovery_runtime/test_path_collisions.py::test_nested_output_policy_names_remain_protected[.git/config] PASSED [  4%]
tests/discovery_runtime/test_path_collisions.py::test_nested_output_policy_names_remain_protected[AGENTS.md] PASSED [  4%]
tests/discovery_runtime/test_path_collisions.py::test_nested_output_policy_names_remain_protected[CLAUDE.md] PASSED [  5%]
tests/discovery_runtime/test_path_collisions.py::test_nested_output_policy_names_remain_protected[SKILL.md] PASSED [  5%]
tests/discovery_runtime/test_path_collisions.py::test_nested_output_policy_names_remain_protected[rule.schema.json] PASSED [  5%]
tests/discovery_runtime/test_path_collisions.py::test_output_peers_cannot_collide_or_nest[feature_contracts-docs/migration/discovery/Evidence] PASSED [  5%]
tests/discovery_runtime/test_path_collisions.py::test_output_peers_cannot_collide_or_nest[feature_contracts-docs/migration/discovery/coverage-ledger.json/child] PASSED [  6%]
tests/discovery_runtime/test_path_collisions.py::test_output_peers_cannot_collide_or_nest[feature_contracts-docs/migration/discovery/evidence/contracts] PASSED [  6%]
tests/discovery_runtime/test_path_collisions.py::test_output_peers_cannot_collide_or_nest[feature_contracts-docs/migration/discovery/evidence] PASSED [  6%]
tests/discovery_runtime/test_path_collisions.py::test_output_peers_cannot_collide_or_nest[root-docs/migration/discovery/evidence/nested] PASSED [  6%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[.agents/discovery] PASSED [  6%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[.claude/discovery] PASSED [  7%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[.codex/discovery] PASSED [  7%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[.git/discovery] PASSED [  7%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[.github/discovery] PASSED [  7%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[.vscode/discovery] PASSED [  8%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[config/discovery] PASSED [  8%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[docs/.codex/discovery] PASSED [  8%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[extensions/discovery] PASSED [  8%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[packages/discovery] PASSED [  9%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[schemas/discovery] PASSED [  9%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[scripts/discovery] PASSED [  9%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[src/discovery] PASSED [  9%]
tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[tests/discovery] PASSED [ 10%]
tests/discovery_runtime/test_path_collisions.py::test_profile_input_aliases_fail_before_any_metadata_read[roots0] PASSED [ 10%]
tests/discovery_runtime/test_path_collisions.py::test_profile_input_aliases_fail_before_any_metadata_read[roots1] PASSED [ 10%]
tests/discovery_runtime/test_path_collisions.py::test_profile_input_aliases_fail_before_any_metadata_read[roots2] PASSED [ 10%]
tests/discovery_runtime/test_path_collisions.py::test_protection_is_bidirectional_and_host_additions_cannot_be_overridden PASSED [ 10%]
tests/discovery_runtime/test_path_collisions.py::test_structurally_valid_grants_do_not_authorize_configuration_or_authority[activation] PASSED [ 11%]
tests/discovery_runtime/test_path_collisions.py::test_structurally_valid_grants_do_not_authorize_configuration_or_authority[domain-profile] PASSED [ 11%]
tests/discovery_runtime/test_path_collisions.py::test_structurally_valid_grants_do_not_authorize_configuration_or_authority[tool-authorization] PASSED [ 11%]
tests/discovery_runtime/test_path_collisions.py::test_structurally_valid_grants_do_not_authorize_configuration_or_authority[unknown] PASSED [ 11%]
tests/discovery_runtime/test_path_collisions.py::test_structurally_valid_grants_do_not_authorize_configuration_or_authority[validation-receipt] PASSED [ 12%]
tests/discovery_runtime/test_path_policy.py::test_collision_order_is_deterministic_and_identical_ancestors_are_allowed PASSED [ 12%]
tests/discovery_runtime/test_path_policy.py::test_component_containment_properties[Notes-notes/\xc9vidence/a.json] PASSED [ 12%]
tests/discovery_runtime/test_path_policy.py::test_component_containment_properties[a/b-a/b/c/d] PASSED [ 12%]
tests/discovery_runtime/test_path_policy.py::test_component_containment_properties[src-src/file.cs] PASSED [ 13%]
tests/discovery_runtime/test_path_policy.py::test_contradictory_metadata_is_rejected_at_construction[directory-x-/root/x-child] PASSED [ 13%]
tests/discovery_runtime/test_path_policy.py::test_contradictory_metadata_is_rejected_at_construction[directory-x-/root/x-children7] PASSED [ 13%]
tests/discovery_runtime/test_path_policy.py::test_contradictory_metadata_is_rejected_at_construction[file-None-/root/x-children1] PASSED [ 13%]
tests/discovery_runtime/test_path_policy.py::test_contradictory_metadata_is_rejected_at_construction[file-x-/root/x-children5] PASSED [ 13%]
tests/discovery_runtime/test_path_policy.py::test_contradictory_metadata_is_rejected_at_construction[file-x-None-children2] PASSED [ 14%]
tests/discovery_runtime/test_path_policy.py::test_contradictory_metadata_is_rejected_at_construction[missing-None-/root/x-children4] PASSED [ 14%]
tests/discovery_runtime/test_path_policy.py::test_contradictory_metadata_is_rejected_at_construction[missing-x-None-children3] PASSED [ 14%]
tests/discovery_runtime/test_path_policy.py::test_contradictory_metadata_is_rejected_at_construction[unknown-x-/root/x-children0] PASSED [ 14%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-AUX] PASSED [ 15%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-CLOCK$] PASSED [ 15%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-COM1] PASSED [ 15%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-COM9] PASSED [ 15%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-COM\xb2] PASSED [ 16%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-COM\xb3] PASSED [ 16%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-COM\xb9] PASSED [ 16%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-CONIN$] PASSED [ 16%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-CONOUT$] PASSED [ 16%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-CON] PASSED [ 17%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-LPT1] PASSED [ 17%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-LPT9] PASSED [ 17%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-LPT\xb2] PASSED [ 17%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-LPT\xb3] PASSED [ 18%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-LPT\xb9] PASSED [ 18%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-NUL] PASSED [ 18%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[ .json-PRN] PASSED [ 18%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-AUX] PASSED [ 19%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-CLOCK$] PASSED [ 19%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-COM1] PASSED [ 19%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-COM9] PASSED [ 19%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-COM\xb2] PASSED [ 20%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-COM\xb3] PASSED [ 20%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-COM\xb9] PASSED [ 20%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-CONIN$] PASSED [ 20%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-CONOUT$] PASSED [ 20%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-CON] PASSED [ 21%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-LPT1] PASSED [ 21%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-LPT9] PASSED [ 21%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-LPT\xb2] PASSED [ 21%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-LPT\xb3] PASSED [ 22%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-LPT\xb9] PASSED [ 22%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-NUL] PASSED [ 22%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[-PRN] PASSED [ 22%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-AUX] PASSED [ 23%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-CLOCK$] PASSED [ 23%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-COM1] PASSED [ 23%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-COM9] PASSED [ 23%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-COM\xb2] PASSED [ 23%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-COM\xb3] PASSED [ 24%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-COM\xb9] PASSED [ 24%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-CONIN$] PASSED [ 24%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-CONOUT$] PASSED [ 24%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-CON] PASSED [ 25%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-LPT1] PASSED [ 25%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-LPT9] PASSED [ 25%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-LPT\xb2] PASSED [ 25%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-LPT\xb3] PASSED [ 26%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-LPT\xb9] PASSED [ 26%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-NUL] PASSED [ 26%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.tar.gz-PRN] PASSED [ 26%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-AUX] PASSED [ 26%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-CLOCK$] PASSED [ 27%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-COM1] PASSED [ 27%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-COM9] PASSED [ 27%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-COM\xb2] PASSED [ 27%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-COM\xb3] PASSED [ 28%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-COM\xb9] PASSED [ 28%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-CONIN$] PASSED [ 28%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-CONOUT$] PASSED [ 28%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-CON] PASSED [ 29%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-LPT1] PASSED [ 29%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-LPT9] PASSED [ 29%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-LPT\xb2] PASSED [ 29%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-LPT\xb3] PASSED [ 30%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-LPT\xb9] PASSED [ 30%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-NUL] PASSED [ 30%]
tests/discovery_runtime/test_path_policy.py::test_device_stems_remain_reserved_in_any_directory[.txt-PRN] PASSED [ 30%]
tests/discovery_runtime/test_path_policy.py::test_duplicate_and_ancestor_aliases_fail_in_either_order[paths0] PASSED [ 30%]
tests/discovery_runtime/test_path_policy.py::test_duplicate_and_ancestor_aliases_fail_in_either_order[paths1] PASSED [ 31%]
tests/discovery_runtime/test_path_policy.py::test_duplicate_and_ancestor_aliases_fail_in_either_order[paths2] PASSED [ 31%]
tests/discovery_runtime/test_path_policy.py::test_duplicate_and_ancestor_aliases_fail_in_either_order[paths3] PASSED [ 31%]
tests/discovery_runtime/test_path_policy.py::test_duplicate_and_ancestor_aliases_fail_in_either_order[paths4] PASSED [ 31%]
tests/discovery_runtime/test_path_policy.py::test_grant_requires_literal_kind_and_stable_id[Feature-feature.alpha] PASSED [ 32%]
tests/discovery_runtime/test_path_policy.py::test_grant_requires_literal_kind_and_stable_id[feature-contract-A] PASSED [ 32%]
tests/discovery_runtime/test_path_policy.py::test_grant_requires_literal_kind_and_stable_id[feature-contract-] PASSED [ 32%]
tests/discovery_runtime/test_path_policy.py::test_grant_requires_literal_kind_and_stable_id[feature-contract-a\n] PASSED [ 32%]
tests/discovery_runtime/test_path_policy.py::test_metadata_and_resolution_detach_sequences_and_reject_assignment PASSED [ 33%]
tests/discovery_runtime/test_path_policy.py::test_policy_and_reader_contracts_fail_closed PASSED [ 33%]
tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case[Sample.sln/child] PASSED [ 33%]
tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case[Src/file.cs] PASSED [ 33%]
tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case[config/other.json] PASSED [ 33%]
tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case[neighbor/file.cs] PASSED [ 34%]
tests/discovery_runtime/test_path_policy.py::test_read_scope_cannot_expand_by_prefix_or_case[src-other/file.cs] PASSED [ 34%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[../root] PASSED [ 34%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[/a/../root] PASSED [ 34%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[/a/./root] PASSED [ 35%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[C:relative] PASSED [ 35%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[\\\\.\\pipe\\root] PASSED [ 35%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[\\\\?\\EXTERNAL_PATH PASSED [ 35%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[\\root] PASSED [ 36%]
tests/discovery_runtime/test_path_policy.py::test_trusted_workspace_still_requires_canonical_absolute_shape[relative] PASSED [ 36%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[..] PASSED [ 36%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[.] PASSED [ 36%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[//./pipe/name] PASSED [ 36%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[//?/EXTERNAL_PATH PASSED [ 37%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[//server/share/file] PASSED [ 37%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[/root/file] PASSED [ 37%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[EXTERNAL_PATH PASSED [ 37%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[EXTERNAL_PATH PASSED [ 38%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[C:relative] PASSED [ 38%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[\\\\.\\COM1] PASSED [ 38%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[\\\\?\\EXTERNAL_PATH PASSED [ 38%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[\\\\server\\share\\file] PASSED [ 39%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[\\root\\file] PASSED [ 39%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[] PASSED [ 39%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a.txt:stream] PASSED [ 39%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/   ] PASSED [ 40%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/*] PASSED [ 40%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/...] PASSED [ 40%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/../b] PASSED [ 40%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/./b] PASSED [ 40%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a//b] PASSED [ 41%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/<] PASSED [ 41%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/>] PASSED [ 41%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/?] PASSED [ 41%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/\n] PASSED [ 42%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/\u2028] PASSED [ 42%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/\u2029] PASSED [ 42%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/\ud800] PASSED [ 42%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/\x00] PASSED [ 43%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/\x01] PASSED [ 43%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/\x1f] PASSED [ 43%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/\x7f] PASSED [ 43%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/] PASSED [ 43%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/dot.] PASSED [ 44%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/quo"te] PASSED [ 44%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/space ] PASSED [ 44%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a/|] PASSED [ 44%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a:b] PASSED [ 45%]
tests/discovery_runtime/test_path_policy.py::test_unsafe_portable_spellings_are_rejected_without_normalization[a\\b] PASSED [ 45%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[.migration/Record.json] PASSED [ 45%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[\u8cc7\u6599/\u884c\u70ba.json] PASSED [ 45%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[docs/%2e%2e/name.json] PASSED [ 46%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[docs/COM10.txt] PASSED [ 46%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[docs/Feature Contract.yaml] PASSED [ 46%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[docs/LPT0.txt] PASSED [ 46%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[docs/\xe9vidence.json] PASSED [ 46%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[docs/a..b] PASSED [ 47%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[docs/a~1.json] PASSED [ 47%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[docs/e\u0301vidence.json] PASSED [ 47%]
tests/discovery_runtime/test_path_policy.py::test_valid_relative_spelling_is_preserved_and_idempotent[docs/null.json] PASSED [ 47%]
tests/discovery_runtime/test_path_resolution.py::test_every_link_or_reparse_entry_is_rejected[ancestor-reparse] PASSED [ 48%]
tests/discovery_runtime/test_path_resolution.py::test_every_link_or_reparse_entry_is_rejected[ancestor-symlink] PASSED [ 48%]
tests/discovery_runtime/test_path_resolution.py::test_every_link_or_reparse_entry_is_rejected[leaf-reparse] PASSED [ 48%]
tests/discovery_runtime/test_path_resolution.py::test_every_link_or_reparse_entry_is_rejected[leaf-symlink] PASSED [ 48%]
tests/discovery_runtime/test_path_resolution.py::test_every_link_or_reparse_entry_is_rejected[root-reparse] PASSED [ 49%]
tests/discovery_runtime/test_path_resolution.py::test_every_link_or_reparse_entry_is_rejected[root-symlink] PASSED [ 49%]
tests/discovery_runtime/test_path_resolution.py::test_exact_resolved_spelling_blocks_aliases[/workspace/src/File.cs] PASSED [ 49%]
tests/discovery_runtime/test_path_resolution.py::test_exact_resolved_spelling_blocks_aliases[/workspace/src/other.cs] PASSED [ 49%]
tests/discovery_runtime/test_path_resolution.py::test_file_ancestor_and_special_leaf_fail PASSED [ 50%]
tests/discovery_runtime/test_path_resolution.py::test_inconsistent_directory_metadata_fails[False] PASSED [ 50%]
tests/discovery_runtime/test_path_resolution.py::test_inconsistent_directory_metadata_fails[True] PASSED [ 50%]
tests/discovery_runtime/test_path_resolution.py::test_missing_read_is_explicit_and_missing_write_parents_are_projected PASSED [ 50%]
tests/discovery_runtime/test_path_resolution.py::test_non_directory_workspace_fails[file] PASSED [ 50%]
tests/discovery_runtime/test_path_resolution.py::test_non_directory_workspace_fails[missing] PASSED [ 51%]
tests/discovery_runtime/test_path_resolution.py::test_non_directory_workspace_fails[other] PASSED [ 51%]
tests/discovery_runtime/test_path_resolution.py::test_parent_or_target_change_invalidates_precommit_result[alias-child] PASSED [ 51%]
tests/discovery_runtime/test_path_resolution.py::test_parent_or_target_change_invalidates_precommit_result[deleted-leaf] PASSED [ 51%]
tests/discovery_runtime/test_path_resolution.py::test_parent_or_target_change_invalidates_precommit_result[leaf-identity] PASSED [ 52%]
tests/discovery_runtime/test_path_resolution.py::test_parent_or_target_change_invalidates_precommit_result[link-parent] PASSED [ 52%]
tests/discovery_runtime/test_path_resolution.py::test_parent_or_target_change_invalidates_precommit_result[new-parent] PASSED [ 52%]
tests/discovery_runtime/test_path_resolution.py::test_parent_or_target_change_invalidates_precommit_result[parent-identity] PASSED [ 52%]
tests/discovery_runtime/test_path_resolution.py::test_parent_or_target_change_invalidates_precommit_result[root-identity] PASSED [ 53%]
tests/discovery_runtime/test_path_resolution.py::test_repeated_directory_identity_is_a_cycle PASSED [ 53%]
tests/discovery_runtime/test_path_resolution.py::test_resolve_inputs_and_outputs_independently_of_host[/workspace] PASSED [ 53%]
tests/discovery_runtime/test_path_resolution.py::test_resolve_inputs_and_outputs_independently_of_host[EXTERNAL_PATH PASSED [ 53%]
tests/discovery_runtime/test_path_resolution.py::test_resolve_inputs_and_outputs_independently_of_host[EXTERNAL_PATH PASSED [ 53%]
tests/discovery_runtime/test_path_resolution.py::test_resolve_inputs_and_outputs_independently_of_host[\\\\server\\share\\Workspace] PASSED [ 54%]
tests/discovery_runtime/test_path_resolution.py::test_resolved_escape_and_sibling_prefix_traps_fail[/neighbor/src/file.cs] PASSED [ 54%]
tests/discovery_runtime/test_path_resolution.py::test_resolved_escape_and_sibling_prefix_traps_fail[/workspace-other/src/file.cs] PASSED [ 54%]
tests/discovery_runtime/test_path_resolution.py::test_resolved_escape_and_sibling_prefix_traps_fail[EXTERNAL_PATH PASSED [ 54%]
tests/discovery_runtime/test_path_resolution.py::test_short_name_alias_cannot_authorize_existing_file PASSED [ 55%]
tests/discovery_runtime/test_path_resolution.py::test_unreadable_metadata_never_becomes_missing[.] PASSED [ 55%]
tests/discovery_runtime/test_path_resolution.py::test_unreadable_metadata_never_becomes_missing[src/file.cs] PASSED [ 55%]
tests/discovery_runtime/test_path_resolution.py::test_unreadable_metadata_never_becomes_missing[src] PASSED [ 55%]
tests/discovery_runtime/test_path_resolution.py::test_unrelated_sibling_change_does_not_invalidate_identity PASSED [ 56%]
tests/discovery_runtime/test_reference_uniqueness.py::test_bare_foreign_id_is_ambiguous_but_explicit_repository_selects_one PASSED [ 56%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_member_links_and_invalid_member_headers_use_full_pointers PASSED [ 56%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_members_share_standalone_namespaces_and_keep_container_paths[product-decision-decision_id] PASSED [ 56%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_members_share_standalone_namespaces_and_keep_container_paths[unspecified-behavior-behavior_id] PASSED [ 56%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[acceptance_criteria-id-feature-contract] PASSED [ 57%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[alternatives-id-product-decision] PASSED [ 57%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[competing_interpretations-id-unspecified-behavior] PASSED [ 57%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[components-component_id-inventory-snapshot] PASSED [ 57%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[diagnostics-id-inventory-snapshot] PASSED [ 58%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[entries-id-parity-matrix] PASSED [ 58%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[findings-finding_id-inventory-snapshot] PASSED [ 58%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[observation_plan-id-runtime-characterization-scenario] PASSED [ 58%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[relationships-relationship_id-inventory-snapshot] PASSED [ 59%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[resulting_acceptance_criteria-id-product-decision] PASSED [ 59%]
tests/discovery_runtime/test_reference_uniqueness.py::test_collection_record_ids_reject_duplicates_with_different_content[runs-id-runtime-characterization-scenario] PASSED [ 59%]
tests/discovery_runtime/test_reference_uniqueness.py::test_diagnostic_order_and_targets_are_invariant_under_artifact_permutations PASSED [ 59%]
tests/discovery_runtime/test_reference_uniqueness.py::test_domain_identity_aliases_are_unique_within_repository_and_kind[acceptance-specification-scenario_id] PASSED [ 60%]
tests/discovery_runtime/test_reference_uniqueness.py::test_domain_identity_aliases_are_unique_within_repository_and_kind[evidence-reference-evidence_id] PASSED [ 60%]
tests/discovery_runtime/test_reference_uniqueness.py::test_domain_identity_aliases_are_unique_within_repository_and_kind[feature-contract-feature_id] PASSED [ 60%]
tests/discovery_runtime/test_reference_uniqueness.py::test_domain_identity_aliases_are_unique_within_repository_and_kind[product-decision-decision_id] PASSED [ 60%]
tests/discovery_runtime/test_reference_uniqueness.py::test_domain_identity_aliases_are_unique_within_repository_and_kind[runtime-characterization-scenario-scenario_id] PASSED [ 60%]
tests/discovery_runtime/test_reference_uniqueness.py::test_domain_identity_aliases_are_unique_within_repository_and_kind[unspecified-behavior-behavior_id] PASSED [ 61%]
tests/discovery_runtime/test_reference_uniqueness.py::test_duplicate_artifact_ids_block_resolution_even_with_a_path PASSED [ 61%]
tests/discovery_runtime/test_reference_uniqueness.py::test_foreign_storage_path_cannot_replace_the_source_origin PASSED [ 61%]
tests/discovery_runtime/test_reference_uniqueness.py::test_index_snapshots_do_not_share_mutable_documents_or_findings PASSED [ 61%]
tests/discovery_runtime/test_reference_uniqueness.py::test_invalid_header_cannot_index_under_its_self_selected_kind PASSED [ 62%]
tests/discovery_runtime/test_reference_uniqueness.py::test_inventory_scalar_links_require_existing_local_records[files-value3-/files/0/diagnostic_ids/0] PASSED [ 62%]
tests/discovery_runtime/test_reference_uniqueness.py::test_inventory_scalar_links_require_existing_local_records[findings-value0-/findings/0/component_id] PASSED [ 62%]
tests/discovery_runtime/test_reference_uniqueness.py::test_inventory_scalar_links_require_existing_local_records[relationships-value1-/relationships/0/from_component_id] PASSED [ 62%]
tests/discovery_runtime/test_reference_uniqueness.py::test_inventory_scalar_links_require_existing_local_records[relationships-value2-/relationships/0/to_component_id] PASSED [ 63%]
tests/discovery_runtime/test_reference_uniqueness.py::test_nested_record_ids_are_local_to_their_parent_artifact PASSED [ 63%]
tests/discovery_runtime/test_reference_uniqueness.py::test_same_id_in_distinct_kind_and_repository_namespaces_is_valid PASSED [ 63%]
tests/discovery_runtime/test_reference_uniqueness.py::test_selectors_cannot_use_unlinked_global_artifacts[coverage-ledger-fields1-/components/0/component_id] PASSED [ 63%]
tests/discovery_runtime/test_reference_uniqueness.py::test_selectors_cannot_use_unlinked_global_artifacts[parity-matrix-fields2-/entries/0/feature_id] PASSED [ 63%]
tests/discovery_runtime/test_reference_uniqueness.py::test_selectors_cannot_use_unlinked_global_artifacts[scope-fields0-/included_components/0] PASSED [ 64%]
tests/discovery_runtime/test_reference_uniqueness.py::test_unknown_extensions_and_action_payloads_cannot_create_graph_authority PASSED [ 64%]
tests/discovery_runtime/test_reference_uniqueness.py::test_unparseable_and_identityless_reports_retain_loading_failures PASSED [ 64%]
tests/discovery_runtime/test_references.py::test_acceptance_links_bind_feature_and_criterion_without_claiming_readiness[decision] PASSED [ 64%]
tests/discovery_runtime/test_references.py::test_acceptance_links_bind_feature_and_criterion_without_claiming_readiness[source] PASSED [ 65%]
tests/discovery_runtime/test_references.py::test_feature_reference_fields_resolve_exact_typed_identity[product_decision_refs-product-decision] PASSED [ 65%]
tests/discovery_runtime/test_references.py::test_feature_reference_fields_resolve_exact_typed_identity[runtime_evidence_refs-evidence-reference] PASSED [ 65%]
tests/discovery_runtime/test_references.py::test_feature_reference_fields_resolve_exact_typed_identity[source_evidence_refs-evidence-reference] PASSED [ 65%]
tests/discovery_runtime/test_references.py::test_feature_reference_fields_resolve_exact_typed_identity[unresolved_behavior_refs-unspecified-behavior] PASSED [ 66%]
tests/discovery_runtime/test_references.py::test_imported_reference_uses_origin_and_feature_alias_without_hash_rules PASSED [ 66%]
tests/discovery_runtime/test_references.py::test_inventory_and_coverage_component_linkage_is_contextual PASSED [ 66%]
tests/discovery_runtime/test_references.py::test_nested_core_references_follow_catalog_shapes[feature-contract-fields0-/trigger/evidence_refs/0] PASSED [ 66%]
tests/discovery_runtime/test_references.py::test_nested_core_references_follow_catalog_shapes[feature-contract-fields1-/state_transitions/entries/0/before/evidence_refs/0] PASSED [ 66%]
tests/discovery_runtime/test_references.py::test_nested_core_references_follow_catalog_shapes[feature-contract-fields2-/acceptance_criteria/0/evidence_refs/0] PASSED [ 67%]
tests/discovery_runtime/test_references.py::test_nested_core_references_follow_catalog_shapes[implementation-record-fields6-/test_references/0/evidence_refs/0] PASSED [ 67%]
tests/discovery_runtime/test_references.py::test_nested_core_references_follow_catalog_shapes[product-decision-fields4-/approval/evidence_refs/0] PASSED [ 67%]
tests/discovery_runtime/test_references.py::test_nested_core_references_follow_catalog_shapes[runtime-characterization-scenario-fields3-/runs/0/post_state_capture/evidence_refs/0] PASSED [ 67%]
tests/discovery_runtime/test_references.py::test_nested_core_references_follow_catalog_shapes[scope-fields7-/confirmed_by/evidence_refs/0] PASSED [ 68%]
tests/discovery_runtime/test_references.py::test_nested_core_references_follow_catalog_shapes[unspecified-behavior-fields5-/competing_interpretations/0/evidence_refs/0] PASSED [ 68%]
tests/discovery_runtime/test_references.py::test_resolver_blocks_mismatched_identity_fields[fields0-REFERENCE_MISSING] PASSED [ 68%]
tests/discovery_runtime/test_references.py::test_resolver_blocks_mismatched_identity_fields[fields1-REFERENCE_KIND] PASSED [ 68%]
tests/discovery_runtime/test_references.py::test_resolver_blocks_mismatched_identity_fields[fields2-REFERENCE_PATH] PASSED [ 69%]
tests/discovery_runtime/test_references.py::test_resolver_blocks_mismatched_identity_fields[fields3-REFERENCE_MISSING] PASSED [ 69%]
tests/discovery_runtime/test_references.py::test_resolver_blocks_mismatched_identity_fields[fields4-REFERENCE_INVALID] PASSED [ 69%]
tests/discovery_runtime/test_references.py::test_resolver_blocks_mismatched_identity_fields[fields5-REFERENCE_INVALID] PASSED [ 69%]
tests/discovery_runtime/test_references.py::test_transport_entries_resolve_their_declared_repository[extension-result-manifest-result_files-repository-inventory-snapshot] PASSED [ 70%]
tests/discovery_runtime/test_references.py::test_transport_entries_resolve_their_declared_repository[source-snapshot-manifest-artifacts-source_repository-feature-contract] FAILED [ 70%]

================================== FAILURES ===================================
_ test_transport_entries_resolve_their_declared_repository[source-snapshot-manifest-artifacts-source_repository-feature-contract] _

snapshot_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...rocessing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
manifest_kind = 'source-snapshot-manifest', field = 'artifacts'
owner_field = 'source_repository', target_kind = 'feature-contract'

    @pytest.mark.parametrize(
        "manifest_kind,field,owner_field,target_kind",
        [
            (
                "source-snapshot-manifest",
                "artifacts",
                "source_repository",
                "feature-contract",
            ),
            (
                "extension-result-manifest",
                "result_files",
                "repository",
                "inventory-snapshot",
            ),
        ],
    )
    def test_transport_entries_resolve_their_declared_repository(
        snapshot_profile: ProfileV2,
        snapshot_catalog: SchemaCatalog,
        manifest_kind: str,
        field: str,
        owner_field: str,
        target_kind: str,
    ) -> None:
        """Manifest rows bind captured files without treating the rows as new artifacts."""
        target = artifact(
            target_kind, "target", repository="foreign", origin="artifact.json"
        )
        source = artifact(
            manifest_kind,
            "manifest",
            fields={
                owner_field: {"id": "foreign"},
                field: [reference(target_kind, "target", path="artifact.json")],
            },
        )
        index = index_references(graph(snapshot_profile, snapshot_catalog, source, target))
>       assert index.findings == ()
E       AssertionError: assert (Finding(code...ed_paths=()),) == ()
E
E         Left contains one more item: Finding(code='REFERENCE_KIND', message='Reference feature-contract/target requires one matching artifact in repository...act_path='docs/local/source-snapshot-manifest/manifest.json', pointer='/artifacts/0', related_ids=(), related_paths=())
E
E         Full diff:
E         - ()
E         + (
E         +     Finding(...
E
E         ...Full output truncated (12 lines hidden), use '-vv' to show

tests\discovery_runtime\test_references.py:360: AssertionError
- generated xml file: SCRATCH\issue-980-p3t6-pass1-tests.xml -
============================ slowest 10 durations =============================
1.71s call     tests/discovery_runtime/test_path_collisions.py::test_extension_schema_cannot_be_placed_in_writable_artifact_scope
1.61s setup    tests/discovery_runtime/test_path_policy.py::test_policy_and_reader_contracts_fail_closed
1.47s call     tests/discovery_runtime/test_path_collisions.py::test_custom_unicode_layout_and_separate_output_roots_are_supported
1.46s setup    tests/discovery_runtime/test_path_resolution.py::test_every_link_or_reparse_entry_is_rejected[ancestor-reparse]
1.43s setup    tests/discovery_runtime/test_reference_uniqueness.py::test_bare_foreign_id_is_ambiguous_but_explicit_repository_selects_one
1.42s setup    tests/discovery_runtime/test_references.py::test_acceptance_links_bind_feature_and_criterion_without_claiming_readiness[decision]
1.35s setup    tests/discovery_runtime/test_path_collisions.py::test_collection_grant_only_matches_its_exact_configured_file
0.98s call     tests/discovery_runtime/test_path_collisions.py::test_output_peers_cannot_collide_or_nest[feature_contracts-docs/migration/discovery/evidence/contracts]
0.92s call     tests/discovery_runtime/test_path_collisions.py::test_protection_is_bidirectional_and_host_additions_cannot_be_overridden
0.80s call     tests/discovery_runtime/test_path_collisions.py::test_output_roots_cannot_overlap_implementation_or_native_configuration[.codex/discovery]
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_references.py::test_transport_entries_resolve_their_declared_repository[source-snapshot-manifest-artifacts-source_repository-feature-contract]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
======================= 1 failed, 301 passed in 30.39s ========================
{"pytest_exit": 1, "source_stable": true, "tests_stable": true, "elapsed_seconds": 30.66189000000304}
```
