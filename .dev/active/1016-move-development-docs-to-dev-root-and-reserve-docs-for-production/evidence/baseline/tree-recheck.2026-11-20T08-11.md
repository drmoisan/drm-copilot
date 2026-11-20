# Tree Re-check, stage B ([P0-T3])

Timestamp: 2026-11-20T08-11
Command: sh SCRATCH/issue-1016-p0t3-register.sh (Test-Path and ordinal Contains per register entry); sh SCRATCH/issue-1016-p0t3-matrix.sh and SCRATCH/issue-1016-p0t3-gen.sh (config/harness-parity-matrix.json generated entries; SHA-256 of each skill copy); git -C <worktree> ls-files (copy counts); grep of the copy lists in ProcessReductionLedger.Tests.ps1, planning-contract-wording.Tests.ps1, test_execution_environment_brief_contracts.py and test_single_pass_preflight_contracts.py; gh api --paginate repos/drmoisan/drm-copilot/pulls/1200/files; git -C <worktree> grep -n -E "docs.{1,8}(features|research|engineering|discovery)" over the A1 surfaces and the generator sources; sh SCRATCH/issue-1016-p0t3-dry.sh (rewrite candidates of dev-docs-migration-dry-run.2026-11-20T07-40.json); sh SCRATCH/issue-1016-p0t3-genchk.sh (Invoke-HarnessGeneration.ps1 -Surface all -Check; generate_codex_agent_variants --check); awk over the stored patches (region lines with a MAPPING_PREFIXES occurrence); git -C <worktree> merge-base <ref> HEAD then diff --name-status per ref; sh SCRATCH/issue-1016-p0t3-wc.sh
EXIT_CODE: 0
Output Summary: RESULT BLOCKED: re-plan-required. Every register entry is PRESENT. Every child 2 export is a MATCH. FT_BYTE_PAIRS is unchanged at four pairs. Neither ref has an upstream change, and both generator checks report no drift. Eleven premise mismatches are listed below: three changed copy counts (atomic-plan-contract, feature-review-workflow and the execution-environment brief are four copies each, not six); one generated hand-edit target ([P3-T11] brief outputs); a generator-closure gap around the epic-orchestrator FROZEN_SURFACES member and the harness RepoGate suite; a generator inventory that predates #1028; an A1 docs-estate occurrence; two A19 rows already satisfied by child 2; and ledger-pinned files absent from DECISIONS. No Phase 1 task was started.

HEAD: `origin/epic/shared-agent-harness-layer-integration` tip plus the five stage A commits (the INTEGRATION tip is an ancestor of HEAD).

## (a) Citation Register

| Entry | Result |
| --- | --- |
| `parallel_orchestrator_surface_expectations.py` `PINNED_FROZEN_SURFACE_HASHES`, `KICKOFF_IDENTITY_FRAGMENTS`, `SECTION_OBLIGATION_CASES` (case `kickoff-feature-folder-and-issue-number`); `test_parallel_orchestrator_surface_contracts.py` `test_frozen_epic_surface_matches_pinned_baseline_digest` | PRESENT |
| `FROZEN_SURFACES` files `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md` | PRESENT (the agent file is now a generated output; see M5) |
| `test_blast_radius_config_tolerance_keys.py` `PINNED_SELF_HOSTED_PATH_ROOTS`, `test_self_hosted_path_roots_match_pinned_directory_list`, `test_class_two_bundled_path_roots_are_empty`; `BlastRadius.KeyPartition.Tests.ps1` "declares an empty bundled path_roots list" | PRESENT |
| `test_orchestration_routing_config_parity.py` `test_canonical_and_bundled_routing_config_are_byte_identical`; the three `orchestration-routing.json` copies (`development_docs_root` key present) | PRESENT |
| `config/blast-radius.json` `path_roots` with `.codex` and `.devcontainer` | PRESENT |
| `test_single_pass_preflight_contracts.py` `test_plan_templates_carry_premortem_skeleton`, `test_contract_requires_final_phase_self_review`; `docs/features/templates/<kind>/plan.yyyy-MM-ddTHH-mm.md` and bundle copies (bug, feature, refactor); epic template and bundle copy | PRESENT |
| `cross-epic-skill-contract.Tests.ps1` `CES-TEMPLATES-BYTE-IDENTICAL` | PRESENT |
| `test_execution_environment_brief_contracts.py` `test_brief_copies_are_byte_identical`, `test_brief_ci_section_names_jobs_and_required_contexts`, `test_architecture_doc_lists_brief` | PRESENT (copy list changed; see M3) |
| `ProcessReductionChain.psm1` `Read-ProcessReductionChainInput`, `Invoke-ProcessReductionChain`, `Get-ProcessReductionMappedSource`, `Get-ProcessReductionDerivedSource`, `Get-ProcessReductionPatchHunk`, `Get-ProcessReductionLanding` | PRESENT |
| `ProcessReductionChain.Tests.ps1` `PRC-READ-COLLECTS-INPUT`; `ProcessReductionChain.Ledger.Tests.ps1` (five named ids) | PRESENT |
| `docs/engineering/process-reductions/README.md` `## Revert Order`; patches `0001`, `0006`, `0008`, `0009` | PRESENT |
| `ProcessReductionLedger.Tests.ps1` `PRL-RULE-STATED-IN-EVERY-COPY`; `.Replay` and `.Index` suites | PRESENT (copy list changed; see M2) |
| `planning-contract-wording.Tests.ps1` `PCW-STANDING-RULE-<Copy>` | PRESENT (copy list changed; see M1) |
| `parallel-gate-wording.Tests.ps1` (`AUDIT-TEMPLATE`, `AUDIT-AGENTS`, sweep root `'docs/features/templates'`); `less-evidence-contract.Tests.ps1` (`TEMPLATE`, `AUDIT-AGENTS`) | PRESENT |
| `build_discovery_runtime.py` `RESOURCE_ROOTS`, `ResourceAllowlist`; `discovery/init_models.py` `resolve_default_template_root`; `test_init_models.py` `test_resolve_default_template_root_returns_expected_path`; `test_build_discovery_runtime_io.py` | PRESENT |
| `OrchestratorStateFeatureFolderRecord.psm1` `FEATURE_FOLDER_PATH_PATTERN` and bundle copy; `_orchestrator_state_feature_folder_record.py`; `orchestrator-state-feature-folder-record.ts`; fixture `valid-large-waives-feature-folder-with-record.json` | PRESENT (already a two-root union; see M9) |
| `StageTiming.psm1` `Read-StageTimingEvidence`; `Get-StageTimingReport.ps1` `EvidenceRoot`; `Get-StageTimingReport.Tests.ps1`; `StageTiming.Tests.ps1` | PRESENT (`'../../docs/features'` literal absent; see M8) |
| `test_discovery_documentation_contracts.py` `DOC`, `test_handoff_reconciles_the_built_artifacts`, `test_handoff_carries_no_stale_installed_host_limit`; `claude-architecture-doc.Tests.ps1` | PRESENT |
| `test_blast_radius_write_intent.py` `FOLDER_GLOB`, `test_write_intent_fixture_reproduces_expected_radius`; `test_parallel_issue_adoption_skill_contracts.py` `test_rule_doc_states_origin_conditional_potential_record`; potential-bug-entry test `test_create_bug_entry_falls_back_to_workspace_when_no_template_root` | PRESENT |
| `.claude/hooks/hook-docs-estate-context.ps1`, `.claude/hooks/hook-docs-only-diff.ps1`, `.claude/lib/docs/`, `config/ci-docs-only-paths.json` | PRESENT (A1 occurrence; see M7) |
| `test_epic_kickoff_contract.py`; `docs/features/epics/shared-agent-harness-layer/epic.md` `feature_folder` | PRESENT |
| Consumed: child 2 exports, merged file list, Stay evidence; child 3 generators; child 10 docs tools; stage A tool and dry-run JSON | PRESENT |

## (b) Child 2 exports against child 2 spec signatures

| Export | Result |
| --- | --- |
| `parseFeatureFolderName(name: string): FeatureFolderName` | MATCH |
| `formatFeatureFolderName(issueNumber: number, feature: string): string` | MATCH |
| `stripDateFirstPrefix(stem: string): string` | MATCH |
| `developmentDocsPath(root, area): string` | MATCH |
| `resolveDevelopmentDocsRoot(reader, workspaceRoot): DevelopmentDocsRoot` | MATCH |
| `KNOWN_DEVELOPMENT_DOCS_ROOTS` = `["docs/features", ".dev"]` | MATCH |

No commit between the INTEGRATION tip and HEAD touches `extensions/drm-copilot/src/lib/development-docs`, `.claude/lib/development-docs` or `scripts/dev_tools/json_config.py`.

## (c) Child 2 merged production file list and Stay evidence

- PR #1200: 502 files (paginated `gh api`; `gh pr view --json files` truncates at 100). Its production files under `PRODUCTION_ROOTS` include `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1`, `scripts/dev_tools/_orchestrator_state_feature_folder_record.py`, `extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts`, `scripts/dev-tools/Get-StageTimingReport.ps1`, the BlastRadius modules, `.claude/hooks/hook-docs-only-diff.ps1`, `.claude/hooks/validate-executor-output.ps1`, `.claude/hooks/feature-folder-resolution.ps1`, `.codex/hooks/feature-folder-resolution.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`, `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`, `.codex/hooks/authorize-root-epic-invocation.ps1`, `epic-kickoff-artifact.ts`, `parallel-kickoff-artifact.ts` and the resolver writers of the A19 table; full list kept at `SCRATCH/issue-1016-pr1200-files.txt` for [P1-T3].
- Child 2 recorded Stay allowlist: `docs/features/active/2026-10-30-dev-docs-root-resolver-and-feature-folder-name-parser-1035/evidence/other/residual-search.2026-11-17T10-10.md` (PRESENT).

## (d) Generator inventory (child 3, #1028, and older)

| Generator | Sources | Outputs | Check form | Result now |
| --- | --- | --- | --- | --- |
| `scripts/harness-generation/Invoke-HarnessGeneration.ps1` surface `skills` (`HarnessSkillMirror.psm1`) | `.agents/skills/<name>/` plus `scripts/harness-generation/sources/skills/<name>.substitutions.json` | `.claude/skills/<name>/` and the claude bundle copy, for 55 matrix entries `generated` (for example `execution-environment`, `documentation-workflow`, `pr-author`) | `-Surface skills -Check`; committed-tree suite `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` "reports no drift for any generated target in the working tree" | no drift |
| same, surface `agents` (`HarnessAgentGeneration.psm1`) | `scripts/harness-generation/sources/agents/<name>.json` and `.md` | `.claude/agents/<name>.md` (25), `.codex/agents/<name>.toml` (105 codex entries), bundle copies | `-Surface agents -Check`; RepoGate suite | no drift |
| same, surface `rules` (`HarnessRuleGeneration.psm1`) | `scripts/harness-generation/sources/rules/<name>.json` and `.md` | `.claude/rules/*.md` (20), `.github/instructions/*.md` (18), bundle copies | `-Surface rules -Check`; RepoGate suite | no drift |
| same, surfaces `mcp`, `instructions` | `scripts/harness-generation/sources/mcp-servers.json` | MCP configs (2); `instructions` is check-only | `-Check`; RepoGate suite | no drift |
| `scripts.dev_tools.generate_codex_agent_variants` | `.codex/agents/<name>.toml` base | `-c1` to `-c4` variants, bundle copies, Codex `core.json` | `--check` | exit 0 |
| `scripts.dev_tools.build_discovery_runtime` | `RESOURCE_ROOTS` canonical inputs | `packages/discovery-runtime/**` staged resources | `--check` | not run here ([P3-T7] reads it) |

Hand-edit targets that are generated outputs: `.claude/skills/execution-environment/SKILL.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` ([P3-T11]). Every other hand-edit target of Phases 1 and 3 is `hand` in the matrix (routing configs, `config/blast-radius.json`, template bundle copies, the epic manifest, the A19 validators and evidence-root files, the ledger tests, `atomic-plan-contract` and `feature-review-workflow` copies).

## (e) A1 coexistence

| Check | Result |
| --- | --- |
| `docs/documentation-estate/` absent | PASS |
| `.claude/hooks/hook-docs-estate-context.ps1`, `.claude/hooks/hook-docs-only-diff.ps1` and their `.codex` twins hold no MAPPING_PREFIXES occurrence | PASS |
| `.claude/lib/docs/` holds no MAPPING_PREFIXES occurrence | FAIL: `.claude/lib/docs/DocsProfile.psm1` comment "so a starter profile never selects planning trees such as docs/features/." (see M7) |

## (f) Upstream changes to the overlap files

| Ref | Derivation | Commits on ref since merge base | Overlap files changed |
| --- | --- | --- | --- |
| `origin/main` | merge base of `origin/main` and `HEAD` | 0 | none |
| `INTEGRATION` | merge base of `origin/epic/shared-agent-harness-layer-integration` and `HEAD` | 0 | none |

## (g) Physical line counts of hand-edit targets

| File | Lines |
| --- | --- |
| `scripts/dev-tools/ProcessReductionChain.psm1` | 596 |
| `tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1` | 560 |
| `config/orchestration-routing.json` | 451 |
| `config/blast-radius.json` | 90 |
| `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` | 176 |
| `extensions/drm-copilot/resources/feature-templates/feature/plan.yyyy-MM-ddTHH-mm.md` | 64 |
| `docs/features/epics/shared-agent-harness-layer/epic.md` | 425 |
| `tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1` | 83 |
| `tests/scripts/dev_tools/test_discovery_documentation_contracts.py` | 462 |
| potential-bug-entry Python test (`tests/scripts/dev_tools/`) | 441 |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 513 |
| `scripts/dev_tools/build_discovery_runtime.py` | 471 |
| `scripts/dev_tools/discovery/init_models.py` | 32 |
| `tests/scripts/dev_tools/test_build_discovery_runtime_io.py` | 255 |
| `tests/scripts/dev_tools/discovery/test_init_models.py` | 114 |
| `.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1` | 169 |
| `scripts/dev_tools/_orchestrator_state_feature_folder_record.py` | 187 |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts` | 138 |
| `scripts/dev-tools/StageTiming.psm1` | 438 |
| `scripts/dev-tools/Get-StageTimingReport.ps1` | 41 |
| `tests/scripts/dev-tools/StageTiming.Tests.ps1` | 410 |
| `tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1` | 246 |
| `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` | 332 |
| `.claude/skills/atomic-plan-contract/SKILL.md` | 313 |
| `.agents/skills/atomic-plan-contract/SKILL.md` | 271 |
| `.agents/skills/execution-environment/SKILL.md` | 246 |
| patches `0001`, `0006`, `0008`, `0009` | 9832, 7783, 1809, 1212 |

No code file reaches 700 lines.

## Copy counts (current tree)

| Surface | Plan states | Observed copies | Byte groups |
| --- | --- | --- | --- |
| `atomic-plan-contract` SKILL.md | six | 4: `.claude/skills/...`, `.agents/skills/...`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/...`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/...` | two pairs (`.claude` with its bundle; `.agents` with its bundle); `.claude` differs from `.agents` |
| `feature-review-workflow` SKILL.md | six | 4 (same four locations) | two pairs |
| execution-environment brief | six (including `.github/skills/execution-environment/SKILL.md`) | 4 (same four locations; no `.github` copy) | one group, all four byte-identical |
| `PRL-RULE-STATED-IN-EVERY-COPY` rows | six | 4 | n/a |
| `PCW-STANDING-RULE-<Copy>` rows | six | 4 (`CLAUDE`, `AGENTS`, `CLAUDE-BUNDLE`, `AGENTS-BUNDLE`) | n/a |
| `test_brief_copies_are_byte_identical` `_BRIEF_COPIES` | six | 4 | n/a |
| `atomic-plan-contract` hunks in patch `0008` and in patch `0001` | six each | 4 each (no `.github` hunk remains) | n/a |
| `FT_BYTE_PAIRS` | 4 (epic + three plan templates) | 4 | unchanged |
| `### Single-Pass Preflight` preflight-fix-record sentence | two copies (`.claude` and its bundle) | `.claude` copy 1, `.agents` copy 0 | unchanged; the `.github` NOT_PRESENT rows have no file |

## Mismatches (each with the plan task ids it affects)

- M1, changed copy count, `atomic-plan-contract`. There are four copies in two byte pairs, not six. Affects: [P3-T10] (the six copies, "the `.agents` and `.github` copies and their bundle copies carry no such sentence", acceptance "`PCW-STANDING-RULE-<Copy>` for all six copies"); `## Ledger Decision (A15, A17)` regeneration rows `0008` and `0001` ("the six `atomic-plan-contract` hunks"; four hunks per patch remain); `## Existing Tests Asserting Changed Behavior` row `PCW-STANDING-RULE-<Copy>`; Pre-Mortem `Mirror parity` ("the six `atomic-plan-contract` copies ([P3-T10])"). The `Final-phase self-review` bullet (`docs/features/templates/policy_audit/`) and the `## Process-Reduction Ledger` applicability bullet (`docs/engineering/process-reductions/`) are present in all four copies; each of the four `0001` and `0008` hunks of these copies holds exactly one region line with a MAPPING_PREFIXES occurrence.
- M2, changed copy count, `feature-review-workflow`. There are four copies in two byte pairs, not six. Affects: [P3-T10] ("Confirm the six `feature-review-workflow` copies name `.dev/engineering/process-reductions/`"); `## Ledger Decision (A15, A17)` ledger-test row for `ProcessReductionLedger.Tests.ps1` ("the six `feature-review-workflow` copies"); `PRL-RULE-STATED-IN-EVERY-COPY` enumerates four copies.
- M3, changed copy count, execution-environment brief. There are four byte-identical copies and no `.github/skills/execution-environment/SKILL.md` (retired by #1032). `test_brief_copies_are_byte_identical` asserts four. Affects: [P3-T11] (names `.github/skills/execution-environment/SKILL.md` and "the six copies"); `REWRITE_EXCLUSIONS` member 6 ("the six execution-environment brief copies"); Pre-Mortem `Mirror parity` ("all six byte-identical copies by [P3-T11]"); `## Existing Tests Asserting Changed Behavior` row `test_brief_copies_are_byte_identical` ("[P3-T11] edits six copies identically"). The brief's own `## Purpose and Maintenance` paragraph still says six locations including `.github`; that paragraph names no MAPPING_PREFIXES path, so [P3-T11] as written does not reach it.
- M4, generated hand-edit target ([P3-T11]). `.claude/skills/execution-environment/SKILL.md` and its claude bundle copy are outputs of `harness-generation/skills`: matrix entry `claude:skill:execution-environment`, generated from `.agents/skills/execution-environment/SKILL.md`, with no substitutions file. A hand edit to the outputs drifts from the generator. Required source edit: `.agents/skills/execution-environment/SKILL.md` and its `codex-and-agents-customizations` bundle copy. Then regenerate with `Invoke-HarnessGeneration.ps1 -Surface skills` and confirm `-Check` prints `harness-generation: no drift`. Affects [P3-T11] and [P3-T12] (generator check list).
- M5, generator closure of a `FROZEN_SURFACES` member. `.claude/agents/epic-orchestrator.md` and its bundle copy are outputs of `harness-generation/agents` (matrix `claude:agent:epic-orchestrator`, from `scripts/harness-generation/sources/agents/epic-orchestrator.json` and `.md`). The same sources generate `.codex/agents/epic-orchestrator.toml` and its bundle copy. DECISIONS excludes `**/.claude/agents/epic-orchestrator.md` and `scripts/harness-generation/sources/agents/epic-orchestrator.md`, but it does not exclude `.codex/agents/epic-orchestrator.toml` or `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml`. Both TOML copies are stage A dry-run rewrite candidates with two occurrences each. DECISIONS also does not exclude `scripts/harness-generation/sources/agents/epic-orchestrator.json` (one occurrence; not a dry-run candidate). If the apply rewrites the TOML outputs while their `.md` source stays byte-identical, `HarnessGeneration.RepoGate.Tests.ps1` reports drift at [P2-T4], and that failure is not in `UPDATE_SET`. Affects: `FROZEN_SURFACES` and `REWRITE_EXCLUSIONS` member 8 closure; [P1-T4]; `CONTRACT_TESTS`, which names neither `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` nor the `Invoke-HarnessGeneration.ps1 -Check` form, so the closure rule ("that a `CONTRACT_TESTS` suite compares with it") does not reach generator outputs; [P2-T4]; [P3-T12].
- M6, generator inventory predates #1028. The plan names only the Codex variant generator and the discovery runtime build. It does not name `scripts/harness-generation/Invoke-HarnessGeneration.ps1` (surfaces skills, rules, agents, mcp, instructions; 241 generated target paths) or its committed-tree suite. The stage A dry run (run without DECISIONS) lists 164 generator-related rewrite candidates, among them sources and outputs of non-excluded generated surfaces. Those include the substitution files `epic-plan.substitutions.json` (9 occurrences), `evidence-and-timestamp-conventions.substitutions.json` (1), `feature-promotion-lifecycle.substitutions.json` (1) and `research-issue.substitutions.json` (3). If the prefix rule rewrites sources and outputs identically, the generator stays at no drift after the apply, but no task proves this before [P2-T4]. Affects [P1-T4], [P2-T4] (a drift failure is outside `UPDATE_SET`), [P3-T12] ("every generator check of the [P0-T3] inventory") and `CONTRACT_TESTS`.
- M7, A1 docs-estate occurrence. `.claude/lib/docs/DocsProfile.psm1` holds a `docs/features/` occurrence in a comment. The file is a STAY row and is excluded in DECISIONS (`**/.claude/lib/docs/DocsProfile.psm1`), so no rewrite or behavior risk follows, but the plan's A1 premise ("`.claude/lib/docs/` ... with no `MAPPING_PREFIXES` occurrence") is false and [P0-T3] stops on it. Affects: [P0-T3] acceptance; `## Existing Tests Asserting Changed Behavior` last row ("A1: ... `.claude/lib/docs/` hold no `MAPPING_PREFIXES` occurrence at planning"); the A19 table `DocsProfile.psm1` row (add the comment occurrence); [P4-T4].
- M8, A19 evidence-root row already routed by child 2. `scripts/dev-tools/Get-StageTimingReport.ps1` no longer holds `'../../docs/features'`. Child 2 (#1200) routes the default through `Resolve-DevelopmentDocsRoot` in `.claude/lib/development-docs/DevelopmentDocsRoot.psm1`, which resolves the configured root: `docs/features` before [P3-T2] and `.dev` after it. [P3-T9]'s no-edit branch is worded "already resolves both roots", which does not match "resolves the configured root". Affects: the A19 table row; `HAND_EDIT_SET`; [P3-T9] (branch condition and the two new `STM-EVIDENCE-ROOT-*` cases); [P5-T5] hand-edited file list (`StageTiming.psm1`, `Get-StageTimingReport.ps1`); `## Existing Tests Asserting Changed Behavior` row `Get-StageTimingReport.Tests.ps1`.
- M9, A19 validator row already satisfied by child 2 (recorded so the plan stays consistent; this alone does not stop the run). All three runtimes already accept `docs/features/active/` and `.dev/active/`. The PowerShell module imports `DevelopmentDocsRoot.psm1`, the Python module joins `KNOWN_DEVELOPMENT_DOCS_ROOTS`, and the TypeScript pattern is `^(?:docs\/features|\.dev)\/active\/...`. Each error string is unchanged. [P3-T8] therefore takes `SATISFIED_BY_CHILD_2` in all three runtimes, and only its fixtures and its unit and parity cases remain. Affects: [P3-T8]; [P5-T5] (lists `OrchestratorStateFeatureFolderRecord.psm1`, `_orchestrator_state_feature_folder_record.py` and `orchestrator-state-feature-folder-record.ts` as hand-edited); `HAND_EDIT_SET`.
- M10, ledger-pinned files absent from DECISIONS (a pre-derivation for [P1-T2] and [P1-T4], so that the superseding decision file can be written in one round). Region lines of the stored patches carry MAPPING_PREFIXES occurrences in these files, which meet the plan's `LEDGER_PINNED` definition (injected strings, consistent with `## Ledger Decision`). DECISIONS has no glob for any of them:
  - `0001`: `extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts`, `tests/scripts/dev_tools/test_validate_policy_audit_artifact.py`
  - `0008`: `extensions/drm-copilot/test/lib/validate/plan-gate-guideline-cutoff.test.ts`, `tests/scripts/dev_tools/test_plan_gate_guideline_cutoff.py`
  - `0010`: `tests/scripts/claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1`, `tests/scripts/claude-hooks/enforce-epic-wave-barrier.EarlyStart.Tests.ps1`, `tests/scripts/codex-hooks/enforce-epic-wave-barrier.EarlyStart.Tests.ps1`, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (context line naming `Edit(docs/features/epics/**)`; the file also carries `KICKOFF_IDENTITY_FRAGMENTS`, so [P3-T6]'s `manual` row applies)
  Already covered: `tests/fixtures/epic_wave_barrier/early-start-edge-cases.json` (member 1), `.claude/rules/plan-acceptance-gates.md` and its bundle copy (member 5), `parallel-gate-wording.Tests.ps1` and `less-evidence-contract.Tests.ps1`, and the four `atomic-plan-contract` copies (member 8 globs).
  Affects [P1-T2], [P1-T4] and the DECISIONS `rewrite_exclusions` list.
- M11, the plan references the retired `.github` skill tree. It cites `.github/skills/execution-environment/SKILL.md` ([P3-T11]) and `.github` copies of `atomic-plan-contract` ([P3-T10]). Neither exists after #1032 (matrix `copilot:skill:*` entries are `dropped`). The same tasks as M1 and M3 are affected.

## Notes (no mismatch)

- `.claude/hooks/validate-executor-output.ps1` accepts a preflight-fix-record under any known development-docs root (`Get-DevelopmentDocsKnownRoot`), so the [P3-T10] premise for the preflight-fix-record sentence holds.
- The skill substitution JSON files are rewrite candidates together with their `.agents` sources, so a find string and its source text change together under the prefix rule (consistency is plausible but unproven; see M6).
- Stage A dry run (no DECISIONS): 771 files outside moved trees are rewrite candidates; 11375 files and 145520 occurrences in total.
