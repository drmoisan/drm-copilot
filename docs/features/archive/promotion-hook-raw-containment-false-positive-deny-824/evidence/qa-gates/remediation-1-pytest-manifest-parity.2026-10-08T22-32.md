# Remediation 1 Pytest Manifest and Parity Gate (pass 1)

Timestamp: 2026-10-08T22-32

## poetry install

Command: poetry install --no-interaction
EXIT_CODE: 0
Output Summary: "No dependencies to install or update"; "Installing the current project: drm-copilot (0.1.1)".

## Six node IDs

Command: poetry run pytest -v tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_documented_exceptions_remain_absent_from_every_manifest tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py::test_bundled_codex_files_are_listed_in_some_pack_manifest tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py::test_no_bundled_codex_file_is_absent_from_disk_and_exception_list tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts
EXIT_CODE: 0
Output Summary: final summary line `6 passed in 0.21s`; no failed or error count; the #510 exception was not needed (no KNOWN-510-LOCAL-ONLY line).

```text
rootdir: <WORKSPACE_ROOT>
configfile: pyproject.toml
collecting ... collected 6 items

tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest PASSED [ 16%]
tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py::test_documented_exceptions_remain_absent_from_every_manifest PASSED [ 33%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py::test_bundled_codex_files_are_listed_in_some_pack_manifest PASSED [ 50%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py::test_no_bundled_codex_file_is_absent_from_disk_and_exception_list PASSED [ 66%]
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts PASSED [ 83%]
tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts PASSED [100%]

============================== 6 passed in 0.21s ==============================
```
