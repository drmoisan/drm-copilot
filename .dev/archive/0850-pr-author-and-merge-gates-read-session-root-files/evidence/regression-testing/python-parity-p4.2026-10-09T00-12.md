# P4-T12 Python parity (CMD-PY-PARITY)

Timestamp: 2026-10-09T00-12
Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py
EXIT_CODE: 0
Output Summary:
  ============================= 17 passed in 0.24s ==============================
  PASSED node lines: 18; FAILED node lines: 0
  KL-510: PASSED

## Full output (worktree root shown as `.`; interpreter host path redacted)

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- (virtualenv python)
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 17 items

tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_required_runtime_files PASSED [  5%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED [ 11%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_planner_review_resources_exist_and_are_byte_identical PASSED [ 17%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_handoff_runtime_has_bundle_pack_and_effective_install_parity PASSED [ 23%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_pack_manifests_are_outside_the_parity_scope PASSED [ 29%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_excludes_settings_local_json PASSED [ 35%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_excludes_variant_subtree_from_parity PASSED [ 41%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_variant_subtree_is_bundle_only_and_non_colliding PASSED [ 47%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_agent_memory_scopes_are_well_formed PASSED [ 52%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_legacy_variant_files_contain_corrected_gate_commands PASSED [ 58%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_legacy_variant_files_exclude_stale_gate_commands PASSED [ 64%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_modern_csharp_profile_retains_modern_gate_commands PASSED [ 70%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_consumer_uses_published_typescript_handoff_authority PASSED [ 76%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_claude_orchestrate_requires_independent_expected_context PASSED [ 82%]
tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest PASSED [ 88%]
tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_documented_exceptions_remain_absent_from_every_manifest PASSED [ 94%]
tests/scripts/dev_tools/test_poshqc_bundled_parity.py::test_poshqc_bundled_module_files_match_repo_root_sources PASSED [100%]

============================= 17 passed in 0.24s ==============================
```
