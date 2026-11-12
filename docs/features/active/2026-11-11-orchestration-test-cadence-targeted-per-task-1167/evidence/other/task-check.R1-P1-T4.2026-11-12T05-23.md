# Task Check [R1 P1-T4] (task-check evidence; not a gate, no coverage measured)

Timestamp: 2026-11-12T05-23
Command: sh SCRATCH/issue-1167-p1t4.sh (one-match sed replacement and cp to bundles with cmp); sh SCRATCH/issue-1167-pester-tc.sh <4 Pester files>; sh SCRATCH/issue-1167-pester-tc.sh tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1; sh SCRATCH/issue-1167-pytest-tc.sh <7 pytest files>, pytest -n auto --no-cov
EXIT_CODE: 0
Output Summary:
- Format, lint, type check: not applicable (Markdown only).
- Bundles: both edited files byte-identical to their bundle copies (cmp exit 0).
- Pester selection: 203 passed, 0 failed (PESTER_EXIT=0).
- test-cadence-wording.Tests.ps1: 133 passed, 2 failed (raw PESTER_EXIT=1); the 2 failures are the excluded red-window rows TCW-TEMPLATE-BUG and TCW-TEMPLATE-BUG-BUNDLE (updated in [P1-T5]); all TCW-POLICY rows pass.
- pytest selection: 150 passed, 0 failed (PYTEST_EXIT=0).

Changed files:
- .claude/rules/general-code-change.md (`## Mandatory Toolchain Loop`: the `all seven stages` sentence now reads "Do not stop the loop until every stage it runs completes without errors in a single pass; at phase gates and in the final QA loop, stage 7 runs in CI.")
- .agents/skills/general-code-change/SKILL.md (same sentence)
- extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md (byte copy)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/general-code-change/SKILL.md (byte copy)

Selection rule: tests found by searching `tests/` for `general-code-change`, limited to those that read the rule or skill text: test-cadence-wording.Tests.ps1, parallel-gate-wording.Tests.ps1, planning-contract-wording.Tests.ps1, sync-agents-from-instructions.Tests.ps1, validate-planner-output.PreMortem.Tests.ps1; test_typescript_toolchain_instruction_contracts.py, test_push_down_tier_rule_adoption_gate.py, test_claude_rules_frontmatter.py, test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, test_blast_radius_config_parity.py.
