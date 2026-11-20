# Phase 0 Citations and Skill Sets (X2)

Timestamp: 2026-11-16T00-38
Command: sh SCRATCH/issue-1025-ps.sh SCRATCH/issue-1025-x2.ps1 (citation re-derivation against HEAD: path tracked per `git ls-files`, then a fixed-string match of the symbol, heading or test name in that path; `file presence` entries by tracking alone; then enumeration of folders holding `SKILL.md` directly under `.claude/skills`, `.agents/skills` and `.github/skills`), followed by sh SCRATCH/issue-1025-ps.sh SCRATCH/issue-1025-sets.ps1 (set comparison)
EXIT_CODE: 1
Output Summary: all 59 citation rows PRESENT (0 MOVED). Skill sets differ from the expected sets of the plan `## Definitions`: observed 77 / 90 / 43 skill folders, 102 distinct names and 65 shared names against the expected 76 / 89 / 42, 101 and 64. One name was added on `main` after the planning refresh (`test-execution-policy`, added by #1158 in all three trees), and it matches no batch assignment rule. Citations: FAIL.

HEAD: branch `feature/harness-survey-gold-standard-contracts-parity-matrix-1025`; MB derivation: `git merge-base origin/main HEAD` after `git fetch origin main` (origin/main 0 commits beyond HEAD).

## Citation Rows

| Path | Symbol, heading, test name or check | Result |
| --- | --- | --- |
| `config/poshqc-scan.json` | `scanFolders` | PRESENT |
| `config/poshqc-coverage.json` | `roots` | PRESENT |
| `.claude/skills/human-exception-runbook/SKILL.md` | `## Required Sections` | PRESENT |
| `.claude/rules/orchestrator-state.md` | `## Invariants (human_interaction block)` | PRESENT |
| `.claude/rules/orchestrator-state.md` | `## Blocked-Reason Vocabulary` | PRESENT |
| `scripts/powershell/PoshQC/PoshQC.Parallel.psm1` | `Invoke-PoshQCParallelTest` | PRESENT |
| `scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1` | `Invoke-PoshQCLeakScan` | PRESENT |
| `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` | `Invoke-PoshQCFormat` | PRESENT |
| `scripts/powershell/PoshQC/PoshQC.Analyzer.psm1` | `Invoke-PoshQCAnalyze` | PRESENT |
| `tests/scripts/ci/FileSizePolicy.RepoGate.Tests.ps1` | `reports zero ratchet violations against config/file-size-baseline.json` | PRESENT |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` | PRESENT |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` | `test_bundled_codex_files_are_listed_in_some_pack_manifest` | PRESENT |
| `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py` | `test_pushed_roots_carry_no_hard_coded_solution_file` | PRESENT |
| `tests/scripts/dev_tools/test_codex_full_migration_inventory.py` | `test_all_repo_agent_skills_are_bundled_and_identical` | PRESENT |
| `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` | `test_committed_quality_tiers_yml_matches_live_tree` | PRESENT |
| `tests/scripts/dev_tools/test_quality_tiers_contract_classification.py` | `test_committed_quality_tiers_yml_assigns_spec_tiers` | PRESENT |
| `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` | `PGW-SWEEP-SURFACES finds no removed-class token in any surface` | PRESENT |
| `tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1` | `TCW-SWEEP-SURFACES finds no per-task full-suite prescription in any surface` | PRESENT |
| `tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1` | `holds no forbidden toolchain or example phrase` | PRESENT |
| `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` | `reports zero folded adapter-ID collisions` | PRESENT |
| `scripts/dev_tools/generate_codex_agent_variants.py` | `--check` | PRESENT |
| `quality-tiers.yml` | `scripts/ci` | PRESENT |
| `scripts/dev_tools/quality_tiers_contract.py` | `QT008` | PRESENT |
| `scripts/dev_tools/quality_tiers_contract.py` | `discover_projects` | PRESENT |
| `scripts/dev_tools/check_quality_tiers.py` | `quality-tiers: OK` | PRESENT |
| `.github/workflows/_quality-checks.yml` | `tier-classification` | PRESENT |
| `.claude/settings.json` | `invoke-pretooluse-dispatch` | PRESENT |
| `.claude/settings.json` | `validate-planner-output` | PRESENT |
| `.claude/settings.json` | `validate-feature-review-coverage` | PRESENT |
| `.claude/settings.json` | `$schema` | PRESENT |
| `.claude/settings.json` | `SubagentStart` | PRESENT |
| `.claude/hooks/pretooluse-dispatch.json` | `PreToolUse` | PRESENT |
| `.codex/hooks/pretooluse-dispatch.json` | `enforce-evidence-locations` | PRESENT |
| `.codex/config.toml` | `[[hooks.PreToolUse]]` | PRESENT |
| `.codex/config.toml` | `[[hooks.UserPromptSubmit]]` | PRESENT |
| `.github/hooks/discovery.json` | `powershell` | PRESENT |
| `.claude/agents/atomic-planner.md` | `validate-planner-output` | PRESENT |
| `.claude/agents/feature-review.md` | `validate-feature-review-coverage` | PRESENT |
| `.github/skills/feature-promotion-lifecycle/SKILL.md` | `## MCP-First Execution Rule` | PRESENT |
| `.codex/agents/orchestrator.toml` | file presence | PRESENT |
| `.codex/agents/orchestrator-c1.toml` | file presence | PRESENT |
| `.codex/agents/orchestrator-c3-elevated.toml` | file presence | PRESENT |
| `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` | file presence | PRESENT |
| `docs/features/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md` | file presence | PRESENT |
| `docs/features/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` | file presence | PRESENT |
| `.agents/README.md` | file presence | PRESENT |
| `.agents/skills/README.md` | file presence | PRESENT |
| `.github/skills/README.md` | file presence | PRESENT |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | file presence | PRESENT |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` | file presence | PRESENT |
| `config/file-size-baseline.json` | file presence | PRESENT |
| `scripts/powershell/PoshQC/settings/pssa.settings.psd1` | file presence | PRESENT |
| `extensions/drm-copilot/jest.config.cjs` | file presence | PRESENT |
| `.claude/skills/execution-environment/SKILL.md` | file presence | PRESENT |
| `.agents/skills/execution-environment/SKILL.md` | file presence | PRESENT |
| `.github/skills/execution-environment/SKILL.md` | file presence | PRESENT |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | file presence | PRESENT |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | file presence | PRESENT |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | file presence | PRESENT |

Note: the sixth brief copy lives under `extensions/drm-copilot/resources/customizations/.github/skills/`; the first script run probed a misspelled bundle folder name and was corrected before this record (the plan names the copies only as "the six execution-environment brief copies").

## Skill Sets

| Set | Expected (plan `## Definitions`, spec `### Inventory context`) | Observed at HEAD |
| --- | --- | --- |
| `.claude/skills` | 76 | 77 |
| `.agents/skills` | 89 | 90 |
| `.github/skills` | 42 | 43 |
| Union | 101 | 102 |
| Shared (`.claude/skills` and `.agents/skills`) | 64 | 65 |
| Single-ecosystem | 37 | 37 |

Added: `test-execution-policy` (present in all three trees; `.agents/skills/test-execution-policy/SKILL.md` was added by the commit titled `docs(skills): add the test-execution-policy skill (#1158)`, which reached `main` after the 2026-11-14 planning refresh)
Removed: (none)
Unassigned: `test-execution-policy` (a shared name not listed in research `### 1.4 Recommended execution of the full survey`, not starting `discovery-` or `docs-`, and not `documentation-workflow` or `owner-directives`)

Batch sizes after applying the assignment rules to the observed shared set: A 16, B 8, C 5, D 11, E 7, F 17, unassigned 1.

Citations: FAIL
