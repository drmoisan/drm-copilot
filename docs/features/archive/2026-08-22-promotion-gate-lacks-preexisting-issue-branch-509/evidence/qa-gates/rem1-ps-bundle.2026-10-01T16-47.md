# Final QA: Bundle Identity and Bundle/Resource-Contract Tests (Remediation Cycle 1)

Timestamp: 2026-10-01T16-47
Task: [P4-T10]
Location: worktree root

## 1. PowerShell bundle hashes

Command: `sha256sum .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1`
EXIT_CODE: 0
Output Summary (verbatim):

```text
993acecd1afaad381a63477e7ddd61508b84e9b9c8d1adfff9b6e198de77f322 *.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
993acecd1afaad381a63477e7ddd61508b84e9b9c8d1adfff9b6e198de77f322 *extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1
```

The two hashes are equal.

## 2. Issue #510 state step

Command: `rm -f .claude/state/python-batch-budget.*.json .claude/state/powershell-batch-budget.*.json`
EXIT_CODE: 0
Output Summary: no output.

Command: `find .claude -maxdepth 2 -name "*-batch-budget.*.json"`
EXIT_CODE: 0
Output Summary: printed nothing. No Write or Edit occurred before the pytest command.

## 3. Bundle, resource-contract, and manifest tests

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_codex_orchestration_contracts.py tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py -rA`
EXIT_CODE: 0
Output Summary:

- Summary line: `============================= 75 passed in 0.65s ==============================` (0 failed; no #510 condition).
- `-rA` short summary lines (verbatim):

```text
PASSED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
PASSED tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py::test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts
PASSED tests/scripts/dev_tools/test_generate_codex_agent_variants.py::test_checked_in_variants_match_generator_output_in_both_surfaces
```

Result: PASS (also the supplementary-input merge verification for the bundle-parity and resource-contract tests).
