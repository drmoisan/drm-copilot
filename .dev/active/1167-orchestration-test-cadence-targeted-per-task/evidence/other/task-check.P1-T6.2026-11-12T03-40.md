# Task Check [P1-T6] (task-check evidence; not a gate, no coverage measured)

Timestamp: 2026-11-12T03-40
Command: bash SCRATCH/issue-1167-taskcheck.sh p1t6 (Pester: New-PesterConfiguration with Run.Path = the selected files, Run.Exit = $true; pytest: env -u VIRTUAL_ENV poetry run pytest -n auto -q --no-cov <selected files> with the two generator-check node IDs deselected)
EXIT_CODE: 0
Output Summary:
- Pester selection: 12 files, 476 passed, 0 failed (PESTER_EXIT=0).
- pytest selection: 279 passed, 0 failed (PYTEST_EXIT=0), including test_evidence_timestamp_contracts.py::test_plan_templates_carry_premortem_skeleton and ::test_copilot_bundle_copies_match_canonical.
- Scoped format/lint/type check: not applicable (Markdown and TOML text only).

Changed files:
- .claude/agents/atomic-planner.md (## Plan Structure) and its bundle under claude-customizations/
- .codex/agents/atomic-planner.toml (## Requirements; bundle and variants regenerated in [P1-T7])
- .agents/skills/atomic-planner/SKILL.md (## Plan Requirements) and its bundle under codex-and-agents-customizations/
- .github/agents/atomic_planning.agent.md, python-atomic-planning.agent.md, powershell-atomic-planning.agent.md, csharp-atomic-planning.agent.md (final-QA rule and self-check list) and their bundles under customizations/
- docs/features/templates/bug/plan.yyyy-MM-ddTHH-mm.md (new [P3-T2] [phase-gate] task, last task of Phase 3 — Minimal Fix), docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md (new [P1-T3] [phase-gate] task, last task of Phase 1), docs/features/templates/refactor/plan.yyyy-MM-ddTHH-mm.md (new [phase-gate] checkbox, last of Phase 2: Execute Structural Changes), and their bundles under extensions/drm-copilot/resources/feature-templates/

Selection rule: test files that name a changed file, found by git grep -l over tests (fixture data excluded) for the planner paths, the template paths, "feature-templates", and "plan.yyyy-MM-ddTHH-mm", plus the Invoke-ParallelAdmission suites and test_evidence_timestamp_contracts.py named by the plan.

Selection:
- Pester:
  - tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1
  - tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
  - tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1
  - tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1
  - tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1
  - tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1
  - tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Manifest.Tests.ps1
  - tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1
  - tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1
  - tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1
  - tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1
  - tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1
- pytest:
  - tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py
  - tests/scripts/dev_tools/test_discovery_documentation_contracts.py
  - tests/scripts/dev_tools/test_execution_environment_brief_contracts.py
  - tests/scripts/dev_tools/test_new_active_feature_folder.py
  - tests/scripts/dev_tools/test_new_active_feature_folder_bug_template_preserved.py
  - tests/scripts/dev_tools/test_new_active_feature_folder_part2.py
  - tests/scripts/dev_tools/test_new_active_feature_folder_part3.py
  - tests/scripts/dev_tools/test_new_active_feature_folder_part4.py
  - tests/scripts/dev_tools/test_new_active_feature_folder_part5.py
  - tests/scripts/dev_tools/test_new_potential_bug_entry.py
  - tests/scripts/dev_tools/test_plan_gate_guideline_cutoff.py
  - tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
  - tests/scripts/dev_tools/test_scratch_location_contracts.py
  - tests/scripts/dev_tools/test_single_pass_preflight_contracts.py
  - tests/scripts/dev_tools/test_evidence_timestamp_contracts.py
  - tests/scripts/dev_tools/test_generate_codex_agent_variants.py
  - --deselect=tests/scripts/dev_tools/test_generate_codex_agent_variants.py::test_checked_in_variants_match_generator_output_in_both_surfaces
  - --deselect=tests/scripts/dev_tools/test_generate_codex_agent_variants.py::test_generator_check_mode_reports_no_drift

Excluded: test_push_down_codex_and_agents_resource_contracts.py, test_codex_agent_wrapper_contracts.py, test_codex_handoff_contract_parity.py, and the generator --check (with its two test wrappers), first required in [P1-T7]; tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 (cannot pass before [P1-T10]).
