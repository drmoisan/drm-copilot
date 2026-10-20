# QA Gate: Mirror and Contract Tests (Issue #984)

Timestamp: 2026-10-20T14-42
Command: poetry run pytest <the eleven tests/scripts/dev_tools files below> -v; poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check; sh SCRATCH/issue-984-run-files.sh issue-984-archdoc issue-984-archdoc.txt (Pester tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1, JUnit)
EXIT_CODE: 0
Output Summary: Pytest 170 passed, 0 failed across eleven files (exit 0); Codex generator --check exit 0; Pester claude-architecture-doc 6 passed, 0 failed.

| File (`tests/scripts/dev_tools/`) | Passed | Failed |
|---|---|---|
| `test_push_down_claude_resource_contracts.py` | 14 | 0 |
| `test_push_down_codex_and_agents_resource_contracts.py` | 9 | 0 |
| `test_push_down_claude_pack_manifest_completeness.py` | 2 | 0 |
| `test_push_down_codex_and_agents_pack_manifest_completeness.py` | 2 | 0 |
| `test_push_down_pack_manifest_dependency_closure.py` | 16 | 0 |
| `test_codex_core_manifest_closure.py` | 5 | 0 |
| `test_generate_codex_agent_variants.py` | 15 | 0 |
| `test_execution_environment_brief_contracts.py` | 18 | 0 |
| `test_single_pass_preflight_contracts.py` | 12 | 0 |
| `test_push_down_issue_824_follow_ups.py` | 62 | 0 |
| `test_typescript_toolchain_instruction_contracts.py` | 15 | 0 |

| Other gate | Result |
|---|---|
| `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check` | exit code 0 |
| Pester `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | 6 passed, failed count 0 (JUnit) |

Mirror parity: the resource-contract tests compare every distributable `.claude`, `.agents`, and `.codex` file with its bundle copy (both pass), and the guard suites ran over repository and mirror roots in [P4-T9] and [P6-T12].
