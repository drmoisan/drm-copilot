# Task Check [P1-T4] (task-check evidence; not a gate, no coverage measured)

Timestamp: 2026-11-12T03-36
Command: bash SCRATCH/issue-1167-taskcheck.sh p1t4 (Pester: New-PesterConfiguration with Run.Path = the selected files, Run.Exit = $true; pytest: env -u VIRTUAL_ENV poetry run pytest -n auto -q --no-cov <selected files>)
EXIT_CODE: 0
Output Summary:
- Pester selection: 19 files, 477 passed, 0 failed (PESTER_EXIT=0).
- pytest selection: 31 files, 554 passed, 0 failed (PYTEST_EXIT=0).
- Scoped format/lint/type check: not applicable (Markdown only).
- typescript.md keeps exactly one **Testing line (grep count 1); "planned batch" no longer occurs under .claude, .agents, or extensions (git grep count 0).

Changed files:
- .claude/rules/{python,powershell,typescript,csharp,shell}.md (## Toolchain) and their bundles under claude-customizations/.claude/rules/
- .agents/skills/{python,powershell,typescript,csharp}/SKILL.md (## Toolchain) and their bundles under codex-and-agents-customizations/.agents/skills/
- extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/rules/csharp.md (bundle-only variant)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp/SKILL.md (bundle-only variant)
- .claude/skills/{python,powershell,csharp}-qa-gate/SKILL.md and .agents/skills/{python,powershell,csharp}-qa-gate/SKILL.md (## When to Use This Skill) and their bundles
- extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md and extensions/drm-copilot/resources/codex-and-agents-customizations/.agents-variants/csharp-legacy/skills/csharp-qa-gate/SKILL.md (bundle-only variants)

Selection rule: test files that name a changed file, found by git grep -l over tests (fixture data excluded) for the rule paths, the language-skill paths, "qa-gate", and "csharp-legacy", plus test_claude_rules_frontmatter.py named by the plan.

Selection:
- Pester:
  - tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1
  - tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
  - tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1
  - tests/scripts/claude-hooks/validate-executor-output.Tests.ps1
  - tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1
  - tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1
  - tests/scripts/claude-hooks/validate-planner-output.PreMortem.Tests.ps1
  - tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1
  - tests/scripts/claude-hooks/validate-planner-output.Tests.ps1
  - tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1
  - tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1
  - tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1
  - tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1
  - tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1
  - tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1
  - tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1
  - tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1
  - tests/scripts/dev-tools/ProcessReductionLedger.Replay.Tests.ps1
  - tests/scripts/dev-tools/activate.Tests.ps1
- pytest:
  - tests/scripts/dev_tools/codex_native_converter/test_rewrites.py
  - tests/scripts/dev_tools/pr_context/test_verification_evidence.py
  - tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py
  - tests/scripts/dev_tools/test_blast_radius_extraction_rules.py
  - tests/scripts/dev_tools/test_blast_radius_mandate_reads.py
  - tests/scripts/dev_tools/test_claude_payload_scope_support.py
  - tests/scripts/dev_tools/test_collect_pr_context.py
  - tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py
  - tests/scripts/dev_tools/test_collect_pr_context_part4.py
  - tests/scripts/dev_tools/test_collect_pr_context_part5.py
  - tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py
  - tests/scripts/dev_tools/test_json_config.py
  - tests/scripts/dev_tools/test_push_down_claude_config_carriage.py
  - tests/scripts/dev_tools/test_push_down_claude_customizations.py
  - tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py
  - tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py
  - tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py
  - tests/scripts/dev_tools/test_push_down_claude_pack_selection.py
  - tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
  - tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py
  - tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
  - tests/scripts/dev_tools/test_push_down_codex_and_agents_variant_packs.py
  - tests/scripts/dev_tools/test_push_down_codex_pack_selection.py
  - tests/scripts/dev_tools/test_push_down_exclusion_manifest.py
  - tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py
  - tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py
  - tests/scripts/dev_tools/test_single_pass_preflight_contracts.py
  - tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py
  - tests/scripts/dev_tools/test_validate_orchestration_artifacts.py
  - tests/scripts/dev_tools/test_validate_policy_audit_artifact.py
  - tests/scripts/dev_tools/test_claude_rules_frontmatter.py

Excluded: tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 (cannot pass before [P1-T10], per the plan).
