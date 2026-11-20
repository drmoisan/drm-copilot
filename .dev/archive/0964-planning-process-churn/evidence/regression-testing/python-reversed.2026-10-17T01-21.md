# Isolation Run — Python Tests in Reverse Collection Order

Timestamp: 2026-10-17T00-54
Task: [P6-T9]
Command: poetry run python SCRATCH/issue-964-pytest-reverse.py tests/scripts/dev_tools/test_plan_gate_document.py tests/scripts/dev_tools/test_plan_gate_document_parity.py tests/scripts/dev_tools/test_plan_gate_document_docs.py tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_single_pass_preflight_contracts.py tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/codex_native_converter/test_rewrites.py
EXIT_CODE: 0
Output Summary:
- One process; the runner passes an in-process plugin whose `pytest_collection_modifyitems` reverses the collected items.
- COLLECTED=88; original first `test_plan_gate_document.py::test_g11_reports_prose_path_and_anchor_forms`; reversed first `codex_native_converter/test_rewrites.py::test_detect_unresolved_runtime_reference_ignores_non_runtime_github_paths`.
- 88 passed, 0 failed. Scope: the five new Python test modules plus the four modified ones.
