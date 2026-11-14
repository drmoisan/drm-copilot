# Task check — [P5-T1]

Timestamp: 2026-11-14T02-22
Command: sh SCRATCH/issue-1156-p5t1-copy.sh; sh SCRATCH/issue-1156-p5t1-manifest.sh; sh SCRATCH/issue-1156-tc-p5t1.sh; sh SCRATCH/issue-1156-tc-pester.sh (Run.Path = Pester selection below)
EXIT_CODE: 0
Output Summary: 18 bundle copies byte-identical to their post-merge sources (cmp after copy); 6 Claude and 2 Codex core.json entries added, both manifests round-trip equal to JSON indent-2 plus one trailing LF with no duplicate path; pytest selection 186 passed; Pester selection 977 passed, 0 failed. Not a gate; no coverage measured.

## Changed files

- extensions/drm-copilot/resources/claude-customizations/.claude/lib/regeneration/{Invoke-RegenerationPath.ps1, RegenerationClassifier.psm1, RegenerationConfig.psm1, RegenerationDelta.psm1} (new)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/{enforce-epic-merge-gate-regeneration.ps1, hook-epic-regeneration.ps1} (new), {enforce-epic-merge-gate.ps1, enforce-orchestration-preimplementation-gate-epic-scope.ps1} (updated)
- extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/{enforce-epic-merge-gate-regeneration.ps1, hook-epic-regeneration.ps1} (new), {enforce-epic-merge-gate.ps1, enforce-orchestration-preimplementation-gate-epic-scope.ps1} (updated)
- extensions/drm-copilot/resources/claude-customizations/.claude/skills/{orchestrate, epic-orchestrate, parallel-orchestrate}/SKILL.md, .claude/agents/{orchestrator.md, epic-orchestrator.md}, .claude/rules/orchestrator-state.md (updated)
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json (+6 entries)
- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json (+2 entries)

Each updated bundle copy was a byte mirror of its source at the merge base of origin/main and HEAD (git rev-parse blob equality), so a byte copy is the correct update.

## Selection and rule

Rule: contract tests that read the bundle tree or the two core.json files (the [P5-T1] named tests and the readers it lists, found by searching tests/ for pack-manifests).

- pytest (-n auto): test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py, test_skill_bundle_contract_repo.py, test_epic_skill_script_citations_shipped.py, test_codex_core_manifest_closure.py, test_push_down_claude_pack_selection.py, test_push_down_codex_pack_selection.py, test_push_down_claude_pack_end_to_end.py, test_generate_codex_agent_variants.py, test_push_down_codex_and_agents_customizations.py, test_discovery_publication_contracts.py, test_blast_radius_config_tolerance_keys.py
- Pester: the 16 tests/scripts/claude-lib manifest suites, legacy-codex-hook-contracts.Tests.ps1, codex-epic-runtime-contracts.Tests.ps1, epic-child-launch-hardening.Tests.ps1, docs-authoring-roles.Mirrors.Tests.ps1, EpicProgressReport.SkillContract.Tests.ps1, hook-dependency-guard-completeness.Tests.ps1
- parallel_bash_manifest_membership.bats runs in CI (shell-coverage); it checks only its own files.

## Commands and exit codes

| Step | Command | Exit | Result |
|---|---|---|---|
| copy | cp + cmp per file (18 files) | 0 | 18 copied, all cmp-equal |
| manifest | sed insert after anchors; node JSON round-trip | 0 | roundtrip-equal true, dupes 0 (both files) |
| test | poetry run pytest -n auto (15 files) | 0 | 186 passed |
| test | Invoke-Pester (22 files, exit = FailedCount) | 0 | 977 passed, 0 failed |
