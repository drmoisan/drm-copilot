# Baseline Python Toolchain (Issue #984)

Timestamp: 2026-10-20T13-28
Command: poetry run black --check tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py; poetry run ruff check <same file>; poetry run pyright <same file>; poetry run pytest <the ten baseline contract test files below> -v
EXIT_CODE: 0
Output Summary: Black "1 file would be left unchanged." (exit 0); Ruff "All checks passed!" (exit 0); Pyright "0 errors, 0 warnings, 0 informations" (exit 0); Pytest 154 passed, 0 failed, 0 skipped (exit 0).

| Step | Exit code | Result |
|---|---|---|
| Black check | 0 | `1 file would be left unchanged.` |
| Ruff check | 0 | `All checks passed!` |
| Pyright | 0 | `0 errors, 0 warnings, 0 informations` (Pyright error count 0) |
| Pytest | 0 | 154 passed, 0 failed, 0 skipped |

Pytest counts per file (all under `tests/scripts/dev_tools/`; `test_push_down_pack_manifest_dependency_closure.py` does not exist at baseline and is excluded):

| File | Passed | Failed | Skipped |
|---|---|---|---|
| `test_push_down_claude_resource_contracts.py` | 14 | 0 | 0 |
| `test_push_down_codex_and_agents_resource_contracts.py` | 9 | 0 | 0 |
| `test_push_down_claude_pack_manifest_completeness.py` | 2 | 0 | 0 |
| `test_push_down_codex_and_agents_pack_manifest_completeness.py` | 2 | 0 | 0 |
| `test_codex_core_manifest_closure.py` | 5 | 0 | 0 |
| `test_generate_codex_agent_variants.py` | 15 | 0 | 0 |
| `test_execution_environment_brief_contracts.py` | 18 | 0 | 0 |
| `test_single_pass_preflight_contracts.py` | 12 | 0 | 0 |
| `test_push_down_issue_824_follow_ups.py` | 62 | 0 | 0 |
| `test_typescript_toolchain_instruction_contracts.py` | 15 | 0 | 0 |
