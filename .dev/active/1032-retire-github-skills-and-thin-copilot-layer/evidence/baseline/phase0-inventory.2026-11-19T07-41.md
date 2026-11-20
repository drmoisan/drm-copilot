# Phase 0 Inventory and Anchor Re-Check ([P0-T1])

Timestamp: 2026-11-19T07-41
Plan: plan.2026-10-30T18-39.md
Command: sh SCRATCH/issue-1032-trees.sh; sh SCRATCH/issue-1032-brief.sh; sh SCRATCH/issue-1032-anchors.sh; sh SCRATCH/issue-1032-sets.sh (git ls-files, grep -cF over each named anchor)
EXIT_CODE: 0
Output Summary: every RETIRED-SKILL-TREES composition, counterpart and BRIEF-COUNT-STATEMENTS check holds; every Edit Set anchor is present except the CLAUDE.md OQ5 pointer anchors, which are inapplicable because child 3 already made CLAUDE.md import AGENTS.md (ClaudeMdPointer: agents-md); no premise falsified.

## Scope Derivation (AD-7)

`MB` is derived against `origin/epic/shared-agent-harness-layer-integration` (orchestrator decision AD-7; see `evidence/other/ad7-merge-base-deviation.*.md`). At this check `MB` equals `HEAD` (no branch commits yet), so the anchors were read at `HEAD`.

## Named Set Members

### RETIRED-SKILL-FOLDERS (43)

acceptance-criteria-tracking, adjudicate-unspecified-behavior, atomic-plan-contract, characterize-runtime-behavior, csharp-change-budget-router, csharp-orchestration-state-machine, discovery-behavior-reconciliation, discovery-coverage-ledger, discovery-parity-matrix, discovery-repo-inventory, discovery-runtime-characterization, discovery-validate-artifacts, discovery-workflow, docs-author-page, docs-init, docs-inventory-surface, docs-plan-ia, docs-reconcile-behavior, docs-review-coverage, docs-validate, documentation-workflow, evidence-and-timestamp-conventions, execution-environment, extract-feature-contract, feature-promotion-lifecycle, feature-review-workflow, generate-acceptance-scenarios, initialize-discovery-workspace, inventory-legacy-system, make-skill-template, owner-directives, policy-audit-template-usage, policy-compliance-order, powershell-change-budget-router, powershell-orchestration-state-machine, pr-base-branch-merge-base, pr-context-artifacts, reconcile-parity-matrix, remediation-handoff-atomic-planner, review-discovery-coverage, skill-canonical-location-audit, test-execution-policy, validate-discovery-artifacts

### RETIRED-SKILL-TREES

- `.github/skills/`: 52 tracked files = 43 `SKILL.md` + 8 `docs-author-page/templates/*.md` (api-reference, architecture-overview, cli-reference, config-reference, explanation, how-to, http-reference, tutorial) + `README.md`.
- `extensions/drm-copilot/resources/customizations/.github/skills/`: 52 tracked files, the same relative paths.

### DOCS-ROLE-LINK-SKILLS (7)

docs-author-page, docs-inventory-surface, docs-plan-ia, docs-reconcile-behavior, docs-review-coverage, docs-validate, documentation-workflow

### LEGACY-DISCOVERY-SKILLS (16, as pinned by `test_legacy_discovery_skills_contracts.py` `SKILL_NAMES`)

Workflows: inventory-legacy-system, extract-feature-contract, characterize-runtime-behavior, reconcile-parity-matrix, review-discovery-coverage, adjudicate-unspecified-behavior, generate-acceptance-scenarios, initialize-discovery-workspace, validate-discovery-artifacts. Aliases: discovery-workflow, discovery-repo-inventory, discovery-coverage-ledger, discovery-runtime-characterization, discovery-parity-matrix, discovery-behavior-reconciliation, discovery-validate-artifacts.

### COPILOT-AGENT-FILES (50 under `.github/agents/`, 50 bundle copies)

Listed with hashes in `github-native-inventory.*.md` (P0-T5).

### DOCS-AGENT-ROLES (4)

`.github/agents/docs-architect.agent.md`, `docs-author.agent.md`, `docs-coverage-reviewer.agent.md`, `docs-reconciler.agent.md`

### READ-FIRST-AGENTS (4 + 4 bundle copies)

`.github/agents/atomic_executor.agent.md`, `atomic_planning.agent.md`, `orchestrator.agent.md`, `task-researcher.agent.md` and their copies under `extensions/drm-copilot/resources/customizations/.github/agents/`.

### REMAINING-BRIEF-COPIES (4; number word `four`)

`.agents/skills/execution-environment/SKILL.md`, `.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` (all six current copies share one blob hash).

### REMAINING-CONTRACT-COPIES (4)

`.agents/skills/atomic-plan-contract/SKILL.md`, `.claude/skills/atomic-plan-contract/SKILL.md`, and their bundle copies under `claude-customizations/.claude/skills/` and `codex-and-agents-customizations/.agents/skills/`.

### Other sets

As defined in spec `## Named Sets` (fixed lists): BRIEF-PIN-TESTS, UPDATED-PYTEST-MODULES (12 + 4 conditional; `RootConstants` present, so all 16 apply), UNCHANGED-AGENT-PYTEST (6), UPDATED-PESTER-SUITES (14 files), UNCHANGED-AGENT-PESTER (5), LEDGER-CHAIN-TESTS (2), PUSH-DOWN-CONTRACT-TESTS (5), RUN-ONLY-FILES, LEDGER-RECORDS (8 entries + 4 patches), COLLISION-KEYS (4), KEPT-DEFAULT-KEYS (3), H3-SURFACES (H3 plan), STALE-REFERENCE-CLASSES, PARALLEL-GATES.

## Composition, Counterpart and Statement Checks

| Check | Result |
| --- | --- |
| Source tree composition (one SKILL.md per folder, templates, README) | holds |
| Bundle tree lists the same relative paths | holds |
| Every RETIRED-SKILL-FOLDERS member has `.agents/skills` counterpart | holds (43/43) |
| Every RETIRED-SKILL-FOLDERS member has `.claude/skills` counterpart | holds (43/43) |
| S1 `byte-identical in six locations` in each of 6 brief copies | holds |
| S2 `in all six byte-identical copies` in each of 6 brief copies | holds |
| S3 `in the six \`documentation-workflow\` copies` / `in the six copies of this brief` in each brief copy | holds |
| S4/S5 `in the six \`atomic-plan-contract\` copies` (2 per brief copy) | holds |
| S6 `in all six byte-identical copies` in each of 6 contract copies | holds |

## Anchor Re-Check

Every anchor below is `present` unless stated.

- `test_execution_environment_brief_contracts.py`: `_BRIEF_COPIES`, `test_brief_copies_are_byte_identical`, `test_brief_preflight_classes_include_brief_maintenance`, `test_brief_is_referenced_by_copilot_base_agents`, `test_architecture_doc_lists_brief` — present.
- `test_discovery_documentation_contracts.py`: `test_execution_environment_fact_is_unchanged_across_copies`, `rglob` — present.
- `test_single_pass_preflight_contracts.py`: `_CONTRACTS`, `_REMEDIATION_SURFACES`, `_COPILOT_BASE_EDITED`, `_ROUTER_AND_PROMPT_SURFACES`, `test_contract_premortem_mirror_parity_requires_brief_update_task` — present; the S6 token is present as the implicit concatenation the plan describes (`... in all six ` + `byte-identical copies`).
- `test_plan_gate_document_docs.py`: `_ALL_CONTRACT_COPIES` — present.
- `test_completion_gate_documentation_contracts.py`: `AC_TRACKING_SKILLS`, `EVIDENCE_SKILLS`, `github-ac-tracking`, `github-evidence`, `_GITHUB_BUNDLE` — present.
- `test_evidence_timestamp_contracts.py`: `EVIDENCE_SKILLS`, `PLAN_CONTRACT_SKILLS`, `github` pair, `_GITHUB_BUNDLE` — present.
- `test_minor_audit_acceptance_criteria_contracts.py`: `ROOT_MIRROR_PAIRS`, `required_paths` — present.
- `test_csharp_orchestration_contracts.py`: `_assert_state_machine_contract`, `test_csharp_change_budget_router_requires_orchestrated_small_path_wording`, `_assert_bundle_mirror_contract` — present.
- `test_push_down_issue_824_follow_ups.py`: `STEP_EIGHT_COPIES`, `FEATURE_REVIEW_TEXT_COPIES`, `SOLUTION_SCAN_ROOTS` — present.
- `test_discovery_publication_contracts.py`: `COPILOT_ROOTS`, `test_skill_is_represented_on_every_host`, `test_copilot_bundle_mirrors_every_scoped_github_file` — present.
- `test_legacy_discovery_skills_contracts.py`: `canonical_path`, `test_generated_copies_are_the_deterministic_role_link_rewrite` — present.
- `test_discovery_workflow_contracts.py`: `skill` — present.
- Pester: `$script:WorkflowCopyRows`, `$script:BriefCopyRows` (CommitStage); `CONTRACT-GITHUB`, `WORKFLOW-GITHUB` (less-evidence); Copilot rows (light-remediation); `$script:SkillCopy` (owner-directives); `$script:BriefFiles` (NestingDepth); `PLAN-GITHUB`, `REVIEW-GITHUB`, sweep root (parallel-gate); `$script:ContractCopy`, `$briefCopy`, `HANDOFF-GITHUB` (planning-contract); `GITHUB` rows and sweep root (test-cadence); `Get-DocsAuthoringSkillRoot`, `Get-DocsAuthoringAgentPath` (helper); `covers 48 template files` (Templates); `PRL-RULE-STATED-IN-EVERY-COPY`, `PRL-RULE-BUNDLE-PARITY` (ProcessReductionLedger) — present.
- `copilot-customizations-engine.ts`: `COPILOT_ROOT_FOLDERS` holding `.github/skills` — present; Jest tests `exposes the inlined copilot root-folder enumeration order`, `classifies created vs overwritten and enumerates in root then path order`, `accumulates rewrite counters and first-seen unmatched references` — present.
- `agentic_sync.py`: `ROOT_FOLDERS`, `Path(".github/skills")` — present; `test_root_folders_include_published_github_hooks_in_scoped_order`, `test_force_left_to_right_overrides_newer_right`, `_seed_scoped_source_files`, `test_push_down_copies_scoped_github_trees_to_empty_destination`, `test_push_down_overwrites_existing_destination_file`, `test_push_down_reports_unmatched_script_references_without_rewrite` — present.
- `docs/engineering/claude-code-architecture.md`: `### Canonical \`.github/skills\` migration map`, `## 1. Copilot-to-Claude Equivalence Table`, `### Authoritative source by asset category`, `## 3. Sync Strategy`, `### Manual sync procedure` — present.
- `.github/copilot-instructions.md` and bundle: `strictly professional` — present.
- `CLAUDE.md`: `## Policy Compliance Reading Order` present; `## Tone Policy` and `copilot-instructions.md` absent — `not-applicable`: CLAUDE.md already imports `AGENTS.md` (child 3), so the OQ5 condition of P1-T13 does not arise and P1-T13 makes no CLAUDE.md edit. This is the state the spec expects after child 3 (`## Upstream Dependencies`, child 3 row), not a premise mismatch.
- `.agents/README.md` and bundle: `historical source` — present. `README.md`: `## Policy and skills references` with the retired README link — present. `maintainer-guide.md`, `workflow.md`, `consumer-onboarding.md`: retired path — present.
- `test_vscode_workspace_settings.py`: `test_workspace_settings_pin_vscode_to_powershell_7`, `test_workspace_settings_contain_no_host_specific_paths` — present. `.vscode/settings.json` — present.
- `config/harness-parity-matrix.json`: `copilot:skill:` (43), `copilot:skill-frontmatter-field:` (2) — present.
- RUN-ONLY-FILES: both `core.json` manifests, `generate_codex_agent_variants.py`, the five PUSH-DOWN-CONTRACT-TESTS modules — present.

## Result

No `moved` anchor and no `differs` check. No `blocked: premise_falsified`.
