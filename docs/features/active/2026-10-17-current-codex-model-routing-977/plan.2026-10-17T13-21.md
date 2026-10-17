# Current Codex model routing — Atomic Plan

- Issue: #977
- Work Mode: full-feature
- Status: Approved — executor preflight all clear
- Authoritative plan: docs/features/active/2026-10-17-current-codex-model-routing-977/plan.2026-10-17T13-21.md

## Required References and Execution Contract

FEATURE means `docs/features/active/2026-10-17-current-codex-model-routing-977`.
Requirements: FEATURE/issue.md, FEATURE/spec.md, FEATURE/user-story.md. Research: FEATURE/research/2026-10-17T17-22-current-codex-model-routing-research.md.
Apply AGENTS.md and .agents/skills/{policy-compliance-order,atomic-plan-contract,execution-environment,evidence-and-timestamp-conventions,acceptance-criteria-tracking}/SKILL.md.
Tool routes, launchers, command restrictions, coverage invocation details, installed-extension behavior, and CI shape are owned by execution-environment; use that brief without substituting routes.
SCRATCH resolves to `<session scratchpad>/issue-977/`; execution helpers and machine-generated coverage reports use issue-prefixed names there. Persistent summaries live under FEATURE/evidence/<kind>/.
Every command step writes its own timestamped artifact with Timestamp:, Command:, EXIT_CODE:, and Output Summary:. Coverage steps include numeric total/per-file line and applicable branch values. Read UTC time when writing; consumers select the lexicographically greatest matching artifact.
Execute each language loop in formatting, linting, type checking, testing order, omitting PowerShell type checking. On failure or auto-fix, repair the concrete issue and restart that language at formatting until a clean pass completes. Unexecuted required gates cannot pass.
The parent owns delegation, actual launch receipts, installed-validator readiness, commits, PR delivery, and final-head CI. Preserve old launch receipts and hashes verbatim in historical evidence; never relabel a former launch or invent attestation. No historical-receipt compatibility/schema change is authorized. Installed validator mismatch is an operational blocker, not a source workaround.
This plan has 39 tasks. Task 35 is P2-T11: the parent must perform the required progress commit before P2-T12 and commit the final partial interval after P2-T15, recording covered intervals outside this plan.

## Approved Behavior

| Condition | Exact model | Effort |
| --- | --- | --- |
| C1 | `gpt-6-luna` | `low` |
| C2 | `gpt-6.1-sol` | `medium` |
| Standalone C3 with C3 ceiling | `gpt-6.1-sol` | `high` |
| C3 in either epic-child context or with C4 ceiling | `gpt-6-astra` | `high` |
| C4 | `gpt-6-astra` | `max` |
| Root epic-planner and epic-orchestrator | `gpt-6-astra` | `ultra` |

Change current model identities and corresponding role prose, plus the explicitly authorized minimal attestation I/O/command seams in FEATURE/attestation-coverage-addendum.md. Preserve default runtime behavior, topology/file-count budgets, suffixes, family inventory, aliases, overlay conditions/reasons, reasoning efforts, monotonic ceilings, receipt schema, and exact-profile/hash/start-attestation checks. Add no dependencies or public commands. Historical evidence and unrelated providers are excluded.

## Closed File Sets and Test Dispositions

Brace notation denotes only listed alternatives. Tasks may write only their named set and evidence. Report necessary repairs outside these sets to the parent instead of extending scope silently.

**POLICY:** config/orchestration-routing.json; extensions/drm-copilot/resources/config/orchestration-routing.json; extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json. No Codex-bundle policy copy.

**PY-SOURCE:** scripts/dev_tools/resolve_codex_deployment.py and scripts/dev_tools/generate_codex_agent_variants.py.
**TS-SOURCE:** extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts.
**PS-SOURCE:** .claude/lib/codex-routing/CodexDeployment.psm1; mirrors extensions/drm-copilot/resources/lib/codex-routing/CodexDeployment.psm1 and extensions/drm-copilot/resources/claude-customizations/.claude/lib/codex-routing/CodexDeployment.psm1. CodexRouting.Manifest.Tests.ps1 and test_push_down_claude_resource_contracts.py assert the third copy.
**HOOK:** .codex/hooks/record-subagent-routing-attestation.ps1 and its same-relative-path copy under extensions/drm-copilot/resources/codex-and-agents-customizations/.
**ATTESTATION AUXILIARY:** FEATURE/attestation-coverage-addendum.md authorizes tests/scripts/codex-hooks/{subagent-attestation-persistence,subagent-attestation-command}.Tests.ps1 and minimal behavior-preserving seams in HOOK. Only if the 500-line cap requires it, additionally authorize .codex/hooks/codex-subagent-attestation-command.ps1, its same-relative-path Codex bundle mirror, and the Codex bundle pack-manifests/core.json registration. These exact auxiliary files join the closed source/test/mirror sets; the addendum supplies their implementation and coverage obligations.
**EPICS:** .codex/agents/{epic-planner,epic-orchestrator}.toml and same-relative-path copies under that Codex bundle.
**SKILLS:** .agents/skills/{codex-model-routing,epic-plan,epic-orchestrate,orchestrate,orchestrator-workflow}/SKILL.md and same-relative-path copies under that Codex bundle. These current Codex routing policy/prose edits are expressly authorized.

**BASE-PROSE:** .codex/agents/orchestrator.toml developer_instructions; update its current C3 role prose before generation, which preserves instruction bodies.

**GENERATED:** twelve families orchestrator, atomic-planner, atomic-executor, feature-reviewer, task-researcher, prd-feature, pr-author, commit-steward, python-typed-engineer, powershell-typed-engineer, typescript-engineer, csharp-typed-engineer; for each, .codex/agents/<family>.toml and <family>-{c1,c2,c3,c3-elevated,c4}.toml, plus identical paths under extensions/drm-copilot/resources/codex-and-agents-customizations/; six generator-owned pack-manifests/{core,python,powershell,typescript,csharp-modern,csharp-legacy}.json under that bundle. One generator task owns these outputs.
**OVERRIDE:** extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml. This active bundle-only legacy C# default is not generator-owned and has no source mirror; replace only its model with gpt-6.1-sol, preserving reasoning effort, instruction body, and other settings.

**PY-UPDATE:** these exact files under tests/scripts/dev_tools/:

- test_resolve_codex_deployment.py
- test_generate_codex_agent_variants.py
- test_validate_orchestrator_state_codex_model_routing.py
- test_validate_orchestrator_state_codex_topology.py
- test_validate_epic_planner_state.py
- test_epic_planner_launch_evidence.py
- epic_planner_launch_evidence_test_support.py
- test_codex_full_migration_inventory.py

Also tests/fixtures/codex_routing/deployment.json, the current shared resolver corpus.
Update all current model/profile expectations in this set, preserving other assertions. Specifically update test_resolves_standalone_base_profiles, test_elevates_c3_for_epic_children, test_resolves_task_researcher_c3_selection_by_context_and_ceiling, test_resolves_commit_steward_standalone_c3_without_overlay, test_cli_emits_stable_deployment_receipt, test_render_variant_replaces_only_top_level_profile_fields, test_render_base_alias_pins_default_c3_profile_without_renaming, and test_codex_agent_contracts_follow_expected_wrapper_or_native_patterns. Rename test_forces_epic_personas_to_sol_ultra to describe Astra/ultra. Wrong-model/overlay test inputs must remain wrong; retain an explicit stale former-model rejection assertion in the existing receipt test module.

**TS-UPDATE:** these exact files under extensions/drm-copilot/test/lib/validate/:

- codex-deployment.test.ts
- orchestrator-state-codex-model-routing.test.ts
- orchestrator-state-codex-topology.test.ts
- epic-planner-state-launch-binding.test.ts
- epic-planner-state-feature-receipts.test.ts
- epic-planner-state-core.test.ts
- epic-planner-readiness-integrity.test.ts
- epic-planner-launch-evidence.test.ts
- epic-planner-launch-evidence-test-support.ts

Also extensions/drm-copilot/test/lib/push-down/codex-bundle-publish.integration.test.ts.
Its existing test `publishes the corrected csharp-legacy role file` asserts the OVERRIDE publishes gpt-6.1-sol; update the current-model expectation while preserving its publishing/role assertions. The failed targeted proof identifies the stale override and must pass after the exact model correction.
Update all current receipt/model/profile expectations and shared support data in this set. Preserve wrong-model, missing-receipt, ceiling, topology, readiness, launch-binding, and mismatch assertions. Keep a stale former-model receipt explicitly invalid under current resolution.

**PS-UPDATE:** tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1; tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1; these exact files under tests/scripts/codex-hooks/:

- model-profile-attestation.Tests.ps1
- legacy-codex-hook-contracts.Tests.ps1
- epic-wave-launch-binding.Tests.ps1
- epic-provenance.Tests.ps1
- epic-child-worktree-launcher.Tests.ps1
- epic-child-launch-hardening.Tests.ps1
- epic-child-launch-attestation.Tests.ps1
- codex-worktree-binding-hook.Tests.ps1
- codex-pretooluse-transport.Tests.ps1
- codex-pretooluse-integration.Tests.ps1
- codex-bundle-hook-probe.Tests.ps1
- codex-epic-runtime-contracts.Tests.ps1

Update all current model/profile expectations in this set. Preserve wrong model/effort/path/hash, absent profile, failed attestation, and unauthorized epic provenance rejection. Keep deliberately invalid former-model literals where they prove rejection.
In codex-epic-runtime-contracts.Tests.ps1, update the escaped former-model regex and epic-persona test description to assert Astra/ultra; retain registration, packaging, provenance, and all other assertions.

**UNCHANGED CONTRACTS:** under tests/scripts/dev_tools/, test_codex_routing_cli_corpus.py, test_codex_model_routing_skill.py, test_codex_agent_wrapper_contracts.py, test_codex_handoff_contract_parity.py, test_codex_core_manifest_closure.py, test_push_down_codex_and_agents_virtual_paths.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_codex_and_agents_pack_manifest_completeness.py, test_push_down_claude_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, parallel_orchestrator_surface_expectations.py; under tests/scripts/claude-lib/codex-routing/, {CodexTopology.Parity,CodexDeployment.GeneratedFamilies.Parity,CodexRouting.Manifest}.Tests.ps1.
These derive current results or pin unchanged topology, wrappers, inventory, mirrors, and frozen provider surfaces; run them without weakening assertions. Other existing receipt validators remain unchanged because they call migrated resolvers. Preserve historical tests/fixtures/orchestration-handoff/taskmaster-469/codex-to-claude/source-checkpoint.json.

## Supplemental Bundled PowerShell Coverage

Configured PoshQC coverage does not instrument bundled resources. Keep its complete configured population and add supplemental baseline/final Pester coverage for all three changed bundled files: both PS-SOURCE mirrors and the HOOK mirror. Reuse CodexDeployment.Parity.Tests.ps1 for each resolver mirror and model-profile-attestation.Tests.ps1, epic-provenance.Tests.ps1, and the remaining PS-UPDATE attestation/launch suites as needed for the hook mirror. Supplemental in-memory Pester containers bind only existing suite import/dot-source targets to the actual bundled files; preserve test assertions and restore bindings between runs. Instrument each actual bundled path explicitly, and record its own measured covered/total lines and percent. Use issue-prefixed execution helpers under SCRATCH, not temporary test files or a production framework. Source coverage or mirror equality cannot substitute for these numeric measurements. Missing measurements or thresholds require remediation.

## Implementation Plan

### Phase 0 — Policy and Baseline Capture

- [x] [P0-T1] Read AGENTS.md, .agents/skills/general-code-change/SKILL.md, .agents/skills/general-unit-test/SKILL.md, then .agents/skills/{python,python-suppressions,powershell,typescript,typescript-suppressions}/SKILL.md in policy order; review required references and FEATURE requirement documents. Write FEATURE/evidence/baseline/policy-read.<timestamp>.md. Acceptance: evidence identifies the authorized SKILLS exception, closed sets, requirements, and unchanged receipt schema before code edits.
- [x] [P0-T2] Capture repository Python formatting baseline over the configured Python population using Python policy/execution-environment. Write FEATURE/evidence/baseline/python-format.<timestamp>.md. Acceptance: actual results and findings are recorded.
- [x] [P0-T3] Capture repository Python lint baseline over the configured Python population. Write FEATURE/evidence/baseline/python-lint.<timestamp>.md. Acceptance: actual Ruff results are recorded after formatting.
- [x] [P0-T4] Capture repository Python type-check baseline over the configured Pyright population. Write FEATURE/evidence/baseline/python-typecheck.<timestamp>.md. Acceptance: actual diagnostics are recorded after linting.
- [x] [P0-T5] Capture complete Python tests/coverage baseline, explicitly measuring both PY-SOURCE dotted modules plus repository coverage; include PY-UPDATE, current corpus, generator freshness, and UNCHANGED CONTRACTS. Write FEATURE/evidence/baseline/python-test.<timestamp>.md. Acceptance: numeric total/changed-module line and branch coverage, counts, and existing failures are recorded.
- [x] [P0-T6] Capture extension TypeScript formatting baseline over the configured Prettier population in extensions/drm-copilot/. Write FEATURE/evidence/baseline/typescript-format.<timestamp>.md. Acceptance: actual results are recorded.
- [x] [P0-T7] Capture extension TypeScript lint baseline over configured src/test populations. Write FEATURE/evidence/baseline/typescript-lint.<timestamp>.md. Acceptance: actual ESLint findings are recorded after formatting.
- [x] [P0-T8] Capture extension TypeScript production/test type-check baseline. Write FEATURE/evidence/baseline/typescript-typecheck.<timestamp>.md. Acceptance: both configured compiler populations have actual results after linting.
- [x] [P0-T9] Capture complete extension Jest coverage baseline, including TS-UPDATE and routing consumers. Write FEATURE/evidence/baseline/typescript-test.<timestamp>.md. Acceptance: numeric total/TS-SOURCE file line and branch coverage, counts, and existing failures are recorded.
- [x] [P0-T10] Capture PowerShell formatting baseline over the configured repository population, including PS-SOURCE, HOOK, and PS-UPDATE. Write FEATURE/evidence/baseline/powershell-format.<timestamp>.md. Acceptance: actual formatter results are recorded.
- [x] [P0-T11] Capture PowerShell analysis baseline with repository settings over the configured population. Write FEATURE/evidence/baseline/powershell-lint.<timestamp>.md. Acceptance: actual analyzer findings are recorded after formatting.
- [x] [P0-T12] Capture complete configured Pester coverage baseline, including PS-UPDATE and unchanged routing contracts. Write FEATURE/evidence/baseline/powershell-test.<timestamp>.md. Acceptance: actual JUnit/coverage outputs establish numeric total/source resolver/hook line coverage and counts. Also run the supplemental bundled coverage design above, recording separate numeric per-file baseline values for both PS-SOURCE mirrors and the HOOK mirror in FEATURE/evidence/baseline/powershell-bundle-coverage.<timestamp>.md. Invocation acknowledgement or mirror parity cannot replace measurement.

### Phase 1 — Current Model Tables, Profiles, and Asserting Tests

- [x] [P1-T1] Update only canonical config/orchestration-routing.json model values under codex_model_policy.complexity_to_profile, c3_elevated_profile, and forced_personas. Acceptance: structural comparison shows only approved model values changed; schema, budgets, suffixes, efforts, families, aliases, and overlay/ceiling rules remain unchanged. Migrated asserting tests are updated at P1-T10 through P1-T12 and run in Phase 2.
- [x] [P1-T2] Update BASE_PROFILES, C3_ELEVATED_PROFILE, FORCED_PERSONA_PROFILES and resolve_codex_deployment docstring in scripts/dev_tools/resolve_codex_deployment.py, plus current C3 role wording in generate_codex_agent_variants.py render_base_alias/_synchronize. Acceptance: structural comparison shows the approved exact model values and current Sol/Astra role prose, with unchanged profile names, schema, and algorithm; diagnostic changes are limited to current C3 role wording. Asserting tests are updated at P1-T10 and executed in Phase 2.
- [x] [P1-T3] Update embedded profile tables in TS-SOURCE. Acceptance: structural comparison shows only the approved model values in the existing tables; algorithms and schema are unchanged. TS-UPDATE assertions are updated at P1-T11 and executed in Phase 2.
- [x] [P1-T4] Update embedded profile tables and current C3/epic role prose in .DESCRIPTION of source .claude/lib/codex-routing/CodexDeployment.psm1. Acceptance: structural comparison shows approved exact model values and Sol/Astra descriptions with unchanged output fields and rejection algorithms. PS-UPDATE assertions are updated at P1-T12 and executed in Phase 2.
- [x] [P1-T5] Update the forced epic model expectation in source .codex/hooks/record-subagent-routing-attestation.ps1 and perform the approved minimal I/O/command seam work from FEATURE/attestation-coverage-addendum.md. Acceptance: Astra is the forced model; auxiliary seams preserve default runtime behavior and identity/effort/path/hash/start-attestation checks. Auxiliary source/helper coverage and size obligations apply; PS-UPDATE assertions are updated at P1-T12 and executed in Phase 2.
- [x] [P1-T6] Update source EPICS model settings and current elevated/root role prose. Acceptance: structural comparison shows Astra/ultra and accurate child Astra/high or Astra/max prose, with unchanged persona names and launch constraints. Inventory/wrapper/provenance tests are reconciled at P1-T10/P1-T12 and run in Phase 2.
- [x] [P1-T7] Update source SKILLS model tables, examples, and current Terra/Sol role prose. Acceptance: current guidance describes Sol/high base C3, Astra/high elevated C3, Astra/max C4, and Astra/ultra roots, with structurally unchanged route/failure rules; skill/handoff contracts execute in Phase 2.
- [x] [P1-T8] Update BASE-PROSE current C3 roles to base Sol/high and elevated Astra/high, then regenerate the entire GENERATED set through PY-SOURCE generator. Acceptance: instruction-body comparison confirms current orchestrator role prose in source/bundle variants; twelve aliases and sixty variants use approved model settings and six manifests retain their family inventory. Generated outputs are not edited individually. Full freshness/wrapper/manifest contracts execute in Phase 2 after test updates.
- [x] [P1-T9] Synchronize POLICY, PS-SOURCE, HOOK, EPICS, and SKILLS mirrors to their sources, and replace only the active bundle-only OVERRIDE model with gpt-6.1-sol. Acceptance: direct source/mirror comparison shows equal content at every mirrored path, including both PS-SOURCE mirrors; OVERRIDE retains its existing effort/body/settings and is corrected independently of the generator without creating a source mirror. No Codex-bundle policy copy or unrelated-provider change appears. The existing legacy C# publishing test in TS-UPDATE and complete push-down/manifest contracts execute after test updates and in Phase 2.
- [x] [P1-T10] Update PY-UPDATE and current deployment corpus according to their dispositions. Acceptance: all-band/context/ceiling, alias, epic, availability, mismatch, generator, inventory, and launch/readiness assertions pass with current identities; stale former-model receipts remain invalid and historical handoff evidence is unchanged.
- [x] [P1-T11] Update TS-UPDATE current deployment/receipt/launch and bundle expectations according to their dispositions. Acceptance: valid current deployments pass, stale/wrong receipt and launch bindings remain rejected, and publication tests name synchronized profiles without weakening assertions.
- [x] [P1-T12] Update PS-UPDATE current resolver/receipt/profile/epic/bundle expectations according to their dispositions and complete the approved no-file tests from FEATURE/attestation-coverage-addendum.md. Acceptance: current corpus parity/valid launches pass and negative model/effort/hash/path/provenance/attestation cases retain rejection semantics; auxiliary tests cover unchanged persistence/CLI behavior and join full and shuffled/single-process Pester runs. Add no temporary-file tests.

### Phase 2 — Ordered QA and Review

- [x] [P2-T1] Run complete repository Python formatting over its configured population. Write FEATURE/evidence/qa-gates/python-format.<timestamp>.md. Acceptance: clean result with no outstanding edits; otherwise restart this language loop.
- [x] [P2-T2] Run complete repository Python lint. Write FEATURE/evidence/qa-gates/python-lint.<timestamp>.md. Acceptance: no new findings or unresolved blocking diagnostics; restart at P2-T1 after failure/repair.
- [x] [P2-T3] Run complete configured Python type checking. Write FEATURE/evidence/qa-gates/python-typecheck.<timestamp>.md. Acceptance: no new findings or unresolved blocking diagnostics; restart at P2-T1 after failure/repair.
- [x] [P2-T4] Run complete Python tests with repository and PY-SOURCE line/branch coverage, including PY-UPDATE, UNCHANGED CONTRACTS, shared corpus, generator freshness, and frozen-surface contracts. Write FEATURE/evidence/qa-gates/python-test.<timestamp>.md. Acceptance: tests/contracts pass and numeric coverage is captured; restart at P2-T1 after failure/repair.
- [x] [P2-T5] Run complete configured extension TypeScript formatting. Write FEATURE/evidence/qa-gates/typescript-format.<timestamp>.md. Acceptance: clean result with no outstanding edits; otherwise restart this language loop.
- [x] [P2-T6] Run complete configured extension TypeScript lint. Write FEATURE/evidence/qa-gates/typescript-lint.<timestamp>.md. Acceptance: no new findings or unresolved blocking diagnostics; restart at P2-T5 after failure/repair.
- [x] [P2-T7] Run complete extension production/test TypeScript type checking. Write FEATURE/evidence/qa-gates/typescript-typecheck.<timestamp>.md. Acceptance: both populations pass; restart at P2-T5 after failure/repair.
- [x] [P2-T8] Run complete extension Jest suite with coverage, including TS-UPDATE and all routing consumers. Write FEATURE/evidence/qa-gates/typescript-test.<timestamp>.md. Acceptance: tests pass with numeric total/TS-SOURCE line and branch coverage; restart at P2-T5 after failure/repair.
- [x] [P2-T9] Run complete configured PowerShell formatting. Write FEATURE/evidence/qa-gates/powershell-format.<timestamp>.md. Acceptance: clean result with no outstanding edits; otherwise restart this language loop.
- [x] [P2-T10] Run complete configured PowerShell analysis and inspect actual findings. Write FEATURE/evidence/qa-gates/powershell-lint.<timestamp>.md. Acceptance: no new findings or unresolved blocking diagnostics; restart at P2-T9 after failure/repair.
- [x] [P2-T11] Run complete configured Pester coverage tests, including PS-UPDATE and unchanged deployment/topology/manifest contracts, inspecting actual JUnit/coverage outputs. Write FEATURE/evidence/qa-gates/powershell-test.<timestamp>.md. Acceptance: tests pass with numeric total/source resolver/hook line coverage. Repeat the supplemental bundled coverage design above and record separately measured numeric coverage for both PS-SOURCE mirrors and the HOOK mirror in FEATURE/evidence/qa-gates/powershell-bundle-coverage.<timestamp>.md; every actual bundled target must be instrumented. Restart at P2-T9 after failure/repair. This is task 35; parent records the progress commit before P2-T12.
- [x] [P2-T12] Compare baseline/final coverage and physical file sizes for every changed production/test/reusable-script path including mirrors. Write FEATURE/evidence/qa-gates/coverage-and-size.<timestamp>.md. Acceptance: repository line coverage >=80%; changed Python/TypeScript production files >=85% line and >=75% branch; changed PowerShell production files, explicitly including both bundled PS-SOURCE mirrors and the bundled HOOK, each have their own measured >=85% line coverage; source percentages and byte parity cannot stand in for mirror measurements; any new methods/modules >=90%; no changed-line regression; all applicable files <=500 physical lines. Missing numeric values require remediation, never PASS.
- [x] [P2-T13] Run isolation checks: seeded shuffled extension Jest with recorded seed; reverse-order changed Python modules in one process; shuffled PS-UPDATE file order in one process with >=3 recorded seeds/orders; fresh single-process Pester over tests/scripts. Write an artifact per check under FEATURE/evidence/regression-testing/isolation-<language>-<run>.<timestamp>.md. The same fresh full configured single-process Pester run from P2-T11 may satisfy the fresh tests/scripts isolation outcome when the evidence establishes identical test populations, the same process identity, and unchanged source since that run; reference its actual-run evidence instead of repeating the full run solely for this checkbox. Acceptance: all checks pass; all three targeted Pester seeds, randomized Jest, reversed Python, and other isolation checks remain required. Fix both leaking/dependent suites, repeat affected seeds, and rerun the corresponding full QA loop after repairs.
- [x] [P2-T14] Self-review the branch diff from the merge base of origin/main and HEAD against every item in the policy-audit/code-review/feature-audit templates under docs/features/templates/policy_audit/. Write FEATURE/evidence/qa-gates/self-review.<timestamp>.md with PASS, FAIL, or justified N/A per item. Acceptance: no FAIL; verify closed scope, test dispositions, current prose, mirrors, generator freshness, unchanged schema/attestation, historical preservation, and unrelated-provider exclusion. Fix findings and rerun affected QA loops before rewriting review.
- [x] [P2-T15] Reconcile locally proven checkboxes in FEATURE/{issue,spec,user-story}.md through acceptance-criteria-tracking; write FEATURE/evidence/qa-gates/acceptance-reconciliation.<timestamp>.md. Acceptance: local criteria cite passing evidence; CI-dependent SPEC-08/STORY-05 and final completion remain unchecked pending parent verification of matching installed validator, truthful current receipts, and required checks at final PR head. Any CI check-off push requires verification again at its resulting head.

## Pre-Mortem

- Review checklists: P2-T14 covers every template item against the merge-base diff; explicit test dispositions prevent hidden current model assertions from remaining stale.
- Coverage: P0-T5/P0-T9/P0-T12 capture numeric baselines; P2-T4/P2-T8/P2-T11 capture final values; P2-T12 enforces coverage/no regression without exclusions or tool acknowledgement as evidence. P0-T12/P2-T11 additionally instrument both bundled resolver copies and the bundled hook via existing assertions in in-memory Pester containers, recording each actual file numerically.
- Mirror parity: P1-T8 regenerates agents/manifests; P1-T9 synchronizes remaining mirrors; P2-T4 runs both resource/manifest contract families. No execution-environment fact changes: CI jobs, routes, budgets, and thresholds stay fixed, so its six copies need no edit.
- File size: P2-T12 counts physical lines across changed production/test/reusable-script paths; the attestation addendum permits only its named command helper if necessary to keep every file within 500 lines.
- Test isolation: P2-T13 runs seeded shuffled Jest with seed recorded, reversed changed Python modules, shuffled touched Pester suites with at least three recorded seeds/orders, and fresh single-process tests/scripts Pester; tests use existing in-memory seams. The P2-T11 full Pester run may supply the last outcome only with recorded population/process identity and unchanged source; all targeted seeds and other isolation checks remain required.
- CI-only behavior: full configured gates and frozen/parity contracts protect path case, joins, LF normalization, and generated freshness; parent-owned required CI must pass at final PR head, including check-off pushes.
- Evidence: every gate has its own actual-result artifact and required numeric coverage; historical launches/hashes remain verbatim. Installed-validator mismatch and actual launch provenance are parent-owned constraints, not source compatibility exceptions.

## Acceptance Coverage

- SPEC-01/STORY-01: P1-T1 through P1-T4, P1-T8, P1-T10 through P1-T12.
- SPEC-02/STORY-02: P1-T1 through P1-T6, unchanged topology contracts, complete language tests.
- SPEC-03/SPEC-06/STORY-03: P1-T2 through P1-T5 and stale/invalid assertions in P1-T10 through P1-T12; no compatibility schema.
- SPEC-04/SPEC-05/STORY-04: P1-T6 through P1-T11, generator/parity/frozen contracts, P2-T14.
- SPEC-07: Phase 0 and P2-T1 through P2-T14.
- SPEC-08/STORY-05: P2-T15 prepares evidence handoff; final-head CI and authoritative completion remain parent-owned.
