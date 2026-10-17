# Documentation Drift Tests, Expected Failure Before Document Edits (P6-T3)

Timestamp: 2026-10-01T22-20
Task: P6-T3 [expect-fail]
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py
EXIT_CODE: 1
ExpectedExitCode: 1

Output (failing node IDs and final line):

```
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_feature_review_skill_lists_every_literal
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_orchestrator_agent_lists_every_literal
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_rules_review_outcome_section_lists_every_literal
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_rules_introduction_drops_three_invariants_wording[.claude/rules/orchestrator-state.md]
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_rules_introduction_drops_three_invariants_wording[.agents/skills/orchestrator-state/SKILL.md]
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_remediation_input_prefixes_avoid_blocking_tokens[.claude/agents/feature-review.md]
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_remediation_input_prefixes_avoid_blocking_tokens[.agents/skills/feature-review/SKILL.md]
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_feature_review_agent_states_evidence_text_constraint[.claude/agents/feature-review.md]
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_feature_review_agent_states_evidence_text_constraint[.agents/skills/feature-review/SKILL.md]
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_loop_documents_state_completed_attempts
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_orchestrate_skills_state_halt_and_wait_rules[.claude/skills/orchestrate/SKILL.md]
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_orchestrate_skills_state_halt_and_wait_rules[.agents/skills/orchestrate/SKILL.md]
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_documents_classify_mcp_contract_lag[.agents/skills/feature-review/SKILL.md]
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_documents_classify_mcp_contract_lag[.claude/skills/feature-review-workflow/SKILL.md]
FAILED tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py::test_docs_contract_documents_share_review_outcome_section
============================= 15 failed in 0.34s ==============================
```

Output Summary: 15 failed, 0 passed, no collection error (all ten test functions collected; five are parametrized over two documents). The failed set includes `test_docs_rules_introduction_drops_three_invariants_wording` (both documents) and `test_docs_remediation_input_prefixes_avoid_blocking_tokens` (both documents), as the acceptance condition requires. Pre-step toolchain on the new file: `poetry run black` reported `1 file left unchanged.` on the final run, `poetry run ruff check` reported `All checks passed!`, and `poetry run pyright` reported `0 errors, 0 warnings, 0 informations`.
