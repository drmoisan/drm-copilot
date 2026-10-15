# Documentation Mirror, Bundle, and Variant Parity Tests — P7-T8

Timestamp: 2026-09-30T14-44
Task: P7-T8
Working directory: worktree root

## Issue #510 state step

Command: ls -a .claude/state
EXIT_CODE: 2
Output Summary: `ls: cannot access '.claude/state': No such file or directory` (empty listing).

Command: rm -f .claude/state/python-batch-budget.*.json .claude/state/powershell-batch-budget.*.json
EXIT_CODE: 0
Output Summary: no output; no file matched.

Command: ls -a .claude/state
EXIT_CODE: 2
Output Summary: `ls: cannot access '.claude/state': No such file or directory` (empty listing). No Write or Edit occurred between this step and the pytest command.

## Test run

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_codex_orchestration_contracts.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py -rA
EXIT_CODE: 0
Output Summary: `75 passed in 0.64s`; no FAILED or ERROR line. The `-rA` flag was added only to print per-test PASSED lines so the named tests can be quoted; it does not change test selection. Named passes:
```
PASSED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
PASSED tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts
PASSED tests/scripts/dev_tools/test_generate_codex_agent_variants.py::test_checked_in_variants_match_generator_output_in_both_surfaces
```
No Issue #510 condition arose.

Result: PASS
