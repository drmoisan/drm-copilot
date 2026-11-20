# Task Check [P1-T2] (task-check evidence; not a gate, no coverage measured)

Timestamp: 2026-11-12T03-33
Command: bash SCRATCH/issue-1167-taskcheck.sh p1t2 (Pester: New-PesterConfiguration with Run.Path = the selected files, Run.Exit = $true; pytest: env -u VIRTUAL_ENV poetry run pytest -n auto -q --no-cov <selected paths>)
EXIT_CODE: 0
Output Summary:
- Pester selection: 14 files, 406 passed, 0 failed (PESTER_EXIT=0).
- pytest selection: 10 paths, 287 passed, 0 failed (PYTEST_EXIT=0).
- Scoped format/lint/type check: not applicable (Markdown only).

Changed files:
- .claude/rules/general-code-change.md (## Mandatory Toolchain Loop) and its bundle extensions/drm-copilot/resources/claude-customizations/.claude/rules/general-code-change.md
- .agents/skills/general-code-change/SKILL.md (## Mandatory Toolchain Loop) and its bundle under codex-and-agents-customizations/.agents/skills/
- AGENTS.md (## Mandatory Toolchain Loop) and its bundle codex-and-agents-customizations/AGENTS.md
- .github/instructions/general-code-change.instructions.md (## Bugfix Workflow (all languages, defects only) step 3; ## 8. After Making Changes / ### 1. Run the full toolchain (no shortcuts)) and its bundle under customizations/.github/instructions/

Selection rule: test files that name a changed file, found by git grep -l "general-code-change" and "AGENTS\.md" over tests (fixture data excluded), plus the push-down resource contracts named by the plan.

Selection:
- Pester: tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1, ProcessReductionChain.Tests.ps1; tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1, parallel-gate-wording.Tests.ps1, less-evidence-contract.Tests.ps1; tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1, enforce-prd-feature-before-planner.FolderResolution.Tests.ps1, enforce-prd-feature-before-planner.TargetResolution.Tests.ps1, validate-planner-output.PreMortem.Tests.ps1, validate-prd-feature-output.Tests.ps1, validate-planner-output.Coverage.Tests.ps1, validate-planner-output.Reentry.Tests.ps1, validate-planner-output.Tests.ps1; tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1
- pytest: tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py, test_push_down_tier_rule_adoption_gate.py, test_claude_rules_frontmatter.py, test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, test_push_down_copilot_customizations_rewrites.py, test_blast_radius_config_parity.py, tests/scripts/dev_tools/codex_native_converter/, tests/discovery_runtime/test_path_collisions.py

Excluded: tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 (cannot pass before [P1-T10], per the plan).
