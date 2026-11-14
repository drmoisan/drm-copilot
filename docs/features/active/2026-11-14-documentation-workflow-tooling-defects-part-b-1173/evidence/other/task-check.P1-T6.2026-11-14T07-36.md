# Task Check P1-T6

Timestamp: 2026-11-14T07-36
Command: pwsh SCRATCH/issue-1173-p1t6-edit.ps1 and SCRATCH/issue-1173-p1t6-agents.ps1 (scripted edits); sh SCRATCH/issue-1173-codexgen.sh (generator write mode, then --check); sh SCRATCH/issue-1173-taskcheck.sh issue-1173-sel-p1t6.txt p1t6; sh SCRATCH/issue-1173-pysel.sh over the push-down resource contract and Codex wrapper and handoff parity tests
EXIT_CODE: 0
Output Summary:
- Changed files (B12): `docs-plan-ia/SKILL.md` in the six M-SKILL roots (new `## Steps` step 6: file names avoid the words `report`, `summary`, `findings` or `analysis`, or the page is assigned to a root step, because such a subagent write may be refused by the runtime); `docs-author-page/SKILL.md` in the six roots (new step 6: such a write "may be refused by the runtime. Report such a page as unwritten; the root writes it."); `docs-author` agent: .claude/agents/docs-author.md, .github/agents/docs-author.agent.md, .codex/agents/docs-author.toml (embedded developer_instructions) gain the same paragraph in `## Write Scope`, and the three bundle copies under extensions/drm-copilot/resources/ are byte-identical to their base (cmp).
- Codex generator: write mode exits 0 and changes no file (the docs-role agents and their bundles are not generator-managed, so the bundle copies were copied from the base files); `--check` exits 0.
- Selection rule: test files that name the changed skills or agent files (grep): enforce-docs-role-write-scope.Tests.ps1, DocumentationEstateOnboarding.Tests.ps1, docs-authoring-roles.Mirrors.Tests.ps1, .Registration.Tests.ps1, .Skills.Tests.ps1, .Templates.Tests.ps1; plus test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_codex_agent_wrapper_contracts.py, test_codex_handoff_contract_parity.py. All unchanged.
- Pester selection: exit 0, 397 passed, 0 failed. pytest selection: 35 passed, 0 failed.
- No format, lint or type check applies to these Markdown and TOML text edits. The B12 text rows are added to docs-authoring-roles.WorkflowText.Tests.ps1 in P1-T7, whose fail-before runs against the merge-base copy.
