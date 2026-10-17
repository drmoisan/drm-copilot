# Documentation, Contract, Push-Down, and Frontmatter Suites — Issue #932

Timestamp: 2026-10-16T01-25
Task: [P5-T9]
Command: poetry run pytest tests/scripts/dev_tools/test_plan_gate_scratch_docs.py tests/scripts/dev_tools/test_scratch_location_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py
EXIT_CODE: 0

Output Summary: `53 passed`; 0 failed. Case applied: 0 failed. The #510 node `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passed locally on this run.

Supporting checks run in [P5-T5] through [P5-T8]:
- `test_plan_gate_scratch_docs.py::test_rule_file_documents_g10` — 1 passed.
- `test_plan_gate_scratch_docs.py::test_rule_file_bundle_copy_is_byte_identical` — 1 passed after `cp` to the bundle (exit 0).
- `test_scratch_location_contracts.py::test_normative_surfaces_name_no_bare_fixed_scratch_path` — 1 passed after the skill edit.
- `test_plan_gate_scratch_docs.py::test_atomic_plan_contract_states_shipped_set_through_g10` — 1 passed after `cp` to the bundle (exit 0).
- The production G10 detector reports 0 findings for `.claude/rules/plan-acceptance-gates.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, this feature's `spec.md`, and this plan (scratch helper `SCRATCH/g10/scan_file.py`).
