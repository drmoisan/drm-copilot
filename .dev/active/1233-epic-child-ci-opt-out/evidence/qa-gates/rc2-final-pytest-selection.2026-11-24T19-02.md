# RC2 final QC: pytest selection Set Y (P1-T11)

Timestamp: 2026-11-24T19-02
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_validate_orchestrator_state_completion.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -rf (through SCRATCH/issue-1233-rc2-sety.sh, SCRATCH/issue-1233-gate-py.sh, and SCRATCH/issue-1233-retry.sh)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-24T19-02 to 2026-11-24T19-02; first attempt, no queue timeout.
- pytest-xdist "24 workers [226 items]".
- pytest summary line: "226 passed in 5.49s"; passed=226, failed=0.
- P0-T4 recorded 224 passed; the increase is exactly the two new corpus rows, test_child_ci_corpus_matches_expected_errors[local-qc-gate-null-fields] and [local-qc-gate-null-heads].
