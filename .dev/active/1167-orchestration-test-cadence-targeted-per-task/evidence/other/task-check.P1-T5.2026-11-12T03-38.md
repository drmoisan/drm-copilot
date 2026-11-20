# Task Check [P1-T5] (task-check evidence; not a gate, no coverage measured)

Timestamp: 2026-11-12T03-38
Command: bash SCRATCH/issue-1167-taskcheck.sh p1t5 (Pester and pytest selections), then bash SCRATCH/issue-1167-taskcheck.sh p1t5b (the same pytest selection with the two generator-check tests deselected)
EXIT_CODE: 0
Output Summary:
- Pester selection: 5 files, 328 passed, 0 failed (PESTER_EXIT=0).
- pytest selection, first run: 153 passed, 2 failed; both failures were test_generate_codex_agent_variants.py::test_checked_in_variants_match_generator_output_in_both_surfaces and ::test_generator_check_mode_reports_no_drift, which call the generator --check and report the expected stale atomic-executor variants and bundle. These two tests are the generator --check that the plan's ## Terms and Standing Rules excludes from this task's selection until [P1-T7].
- pytest selection, second run with those two node IDs deselected: 153 passed, 0 failed (PYTEST_EXIT=0).
- Scoped format/lint/type check: not applicable (Markdown and TOML text only; no formatter or linter applies).

Changed files:
- .claude/agents/atomic-executor.md (## Execution Protocol step 4; ## Toolchain Commands) and its bundle under claude-customizations/
- .codex/agents/atomic-executor.toml (same sections; bundle and variants regenerated in [P1-T7])
- .agents/skills/atomic-executor/SKILL.md (## Execution Rules) and its bundle under codex-and-agents-customizations/
- .github/agents/atomic_executor.agent.md, python-atomic-executor.agent.md, powershell-atomic-executor.agent.md, csharp-atomic-executor.agent.md (## 0. Highest Priority: Repository Policy Compliance (Non-Negotiable) toolchain bullet; ### 3.4 Verification (mandatory before check-off); ### 7.1 <Language> policy and toolchain gates label in the three language executors) and their bundles under customizations/
- .github/prompts/execute-hard-lock.prompt.md, .github/codex/execute-hard-lock.prompt.md, .github/codex/resume-hard-lock.prompt.md (EXECUTION LOOP step) and their bundles under customizations/; the PREFLIGHT VALIDATION GATE lists are unchanged.

Selection rule: test files that name a changed file, found by git grep -l over tests (fixture data excluded) for "agents/atomic-executor", "skills/atomic-executor", "atomic_executor.agent", "atomic-executor.agent", and "hard-lock".

Selection:
- Pester:
  - tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1
  - tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1
  - tests/scripts/claude-runtime/light-remediation-skill-contract.Tests.ps1
  - tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1
  - tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1
- pytest:
  - tests/scripts/dev_tools/codex_native_converter/test_rewrites.py
  - tests/scripts/dev_tools/test_execution_environment_brief_contracts.py
  - tests/scripts/dev_tools/test_generate_codex_agent_variants.py
  - tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
  - tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py
  - tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py
  - tests/scripts/dev_tools/test_resolve_hard_lock_prompt_output.py
  - tests/scripts/dev_tools/test_resolve_hard_lock_prompt_part2.py
  - tests/scripts/dev_tools/test_scratch_location_contracts.py
  - tests/scripts/dev_tools/test_single_pass_preflight_contracts.py
  - tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py
  - --deselect=tests/scripts/dev_tools/test_generate_codex_agent_variants.py::test_checked_in_variants_match_generator_output_in_both_surfaces
  - --deselect=tests/scripts/dev_tools/test_generate_codex_agent_variants.py::test_generator_check_mode_reports_no_drift

Excluded: test_push_down_codex_and_agents_resource_contracts.py, test_codex_agent_wrapper_contracts.py, test_codex_handoff_contract_parity.py, and the generator --check (and its two test wrappers above), first required in [P1-T7]; tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 (cannot pass before [P1-T10]).
