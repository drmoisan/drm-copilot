# Divergent-literal and production-root derivation ([P1-T3])

Timestamp: 2026-11-20T11-15
Command: git -C <worktree> grep -l -E 'docs/(features|research|engineering|discovery)/' -- tests extensions/drm-copilot/test ':!tests/fixtures' (444 files); git -C <worktree> grep -l -E <segment-join, -ChildPath 'docs', *-980 and NNNN-* glob patterns> -- tests extensions/drm-copilot/test ':!tests/fixtures' (28 files); node SCRATCH/issue-1016-p1t3.cjs (classification against FRESH_DRY_RUN dev-docs-migration-dry-run.2026-11-20T11-03.json rewrite list and DECISIONS folder-rename-decisions.2026-11-20T09-48.json globs); PRODUCTION_SEARCH: git -C <worktree> grep -n -E 'docs.{1,8}(features|research|engineering|discovery)' and -E "[\"']docs[\"']" over .claude/hooks .claude/lib .codex/hooks .codex/scripts scripts extensions/drm-copilot/src (320 and 15 lines); node SCRATCH/issue-1016-p1t3prod.cjs; sh SCRATCH/issue-1016-p1t3-seg.sh (segment-join review)
EXIT_CODE: 0
Output Summary: 452 test candidates classified: 260 R tool-rewritten, 2 D tool-rewritten (planning-contract-wording.Tests.ps1, test_single_pass_preflight_contracts.py), 2 D excluded (parallel-gate-wording.Tests.ps1, less-evidence-contract.Tests.ps1; FIX-NAMED [P3-T9]), 2 R manual [P3-T6] (claude-architecture-doc.Tests.ps1, test_discovery_documentation_contracts.py), 1 I+R excluded plus manual [P3-T6] (parallel_orchestrator_surface_expectations.py), 3 R FIX-NAMED [P3-T7] (initialization_test_support.py among the readers; test_init_models.py, test_domain_neutrality.py), 4 I+R exclude rows decided by the rehearsal (test_new_active_feature_folder_part3.py, _part5.py, test_render_helpers.py, test_resolve_execute_plan_prompt_part2.py), 128 I exclude (111 by a DECISIONS glob, 17 not rewritten at all), 48 X exclude, 3 A exclude. 332 production matches: 245 STAY_ENTRIES, 73 tool-rewritten (all comments, docstrings or help text), 2 HAND_EDIT_SET, 12 child 2 set via the harness agent generator family (tool-protected Write( globs and both-root matcher unions whose generated .claude/agents outputs are in child 2's merged list). 0 H rows, 0 X rows whose compared production result resolves the configured root, write-intent root pin PRESENT, 0 unclassified production matches. No stop.

## Named rows

| Row | Result |
| --- | --- |
| test_blast_radius_write_intent.py | class A, excluded (member 4). Root pin PRESENT: FOLDER_GLOB = "docs/features/active/demo-feature-1/**" and derive_blast_radius falls back to the constant DEFAULT_DEVELOPMENT_DOCS_ROOT = "docs/features" in scripts/dev_tools/json_config.py (no resolver call, child 2 OD-P4), so the flip does not move it |
| test_parallel_issue_adoption_skill_contracts.py | class X, excluded (group 5); compares .claude/rules/orchestrator-state.md (A6) |
| test_new_potential_bug_entry.py | class I, excluded (member 4); injected root |
| tests/discovery_runtime/test_package_contract.py | class X against the excluded package; holds only "artifacts: {root: docs/discovery}" (no MAPPING_PREFIXES literal with a trailing separator), so it is not a literal candidate |
| BlastRadius.Tests.ps1, BlastRadius.Parity.Tests.ps1, test_compute_blast_radius.py, test_blast_radius_parity.py | class A, excluded; no-root default docs/features |
| five ledger suites | ProcessReductionChain.Tests.ps1 excluded (member 8); ProcessReductionChain.Ledger.Tests.ps1, ProcessReductionLedger.Tests.ps1, .Replay, .Index tool-rewritten (class R) |
| eight M10 LEDGER_PINNED test files | class I (injected strings naming no tracked path), excluded; parallel_orchestrator_surface_expectations.py additionally manual [P3-T6] |
| parallel-gate-wording.Tests.ps1, less-evidence-contract.Tests.ps1, planning-contract-wording.Tests.ps1, test_contract_requires_final_phase_self_review | class D, FIX-NAMED [P3-T9] |

## Excluded literals compared with production results

The 73 tool-rewritten production occurrences are all comments, docstrings or CLI help text (enforce-epic-wave-barrier.ps1, enforce-evidence-locations.ps1 twins, hook-command-invocation/scanner twins, subagentstop-envelope.ps1, report-lane-assertion.sh, Invoke-EpicCrossReadiness.ps1, OrchestratorStateCheckpointValue.psm1, ParallelAdmissionPrecedence.psm1, plan-gate-discrimination and plan-gate-observability in TypeScript and Python, parallel_lane_assertion.py, parallel_manifest_contract.py, schema_loading.py, and generator sources). No excluded fixture or excluded test literal is compared with a production result that a rewrite changes; the potential_record STAY row of the A19 table stays excluded (member 4) with its suites. The [P1-T6] rehearsal is the mechanical check of this row.

## Test candidates

| Test file | Class | Disposition | Exclusion glob (group) | Rewrite (refs/links) | Segment-joined |
| --- | --- | --- | --- | --- | --- |
| extensions/drm-copilot/test/extension-command-helpers.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/extension.integration.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/extension.new-active-feature-folder-inprocess.test.ts | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  |  |
| extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts |  |  |
| extensions/drm-copilot/test/extension.potential-to-issue.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/extension.potential-to-issue.test.ts |  |  |
| extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/extension.resolve-atomic-plan-prompt.test.ts |  |  |
| extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/extension.resolve-hard-lock-prompt.test.ts |  |  |
| extensions/drm-copilot/test/fixtures/collect_commit_context.no_staged.fixture.txt | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/fixtures/collect_commit_context.staged.fixture.txt | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/lib/development-docs-migration/folder-rename-plan.test.ts | X | exclude | g1-stageA: extensions/drm-copilot/test/lib/development-docs-migration/** |  |  |
| extensions/drm-copilot/test/lib/development-docs-migration/layout-map.test.ts | X | exclude | g1-stageA: extensions/drm-copilot/test/lib/development-docs-migration/** |  |  |
| extensions/drm-copilot/test/lib/development-docs-migration/migrate-development-docs-service-call.test.ts | X | exclude | g1-stageA: extensions/drm-copilot/test/lib/development-docs-migration/** |  |  |
| extensions/drm-copilot/test/lib/development-docs-migration/migration-apply.test.ts | X | exclude | g1-stageA: extensions/drm-copilot/test/lib/development-docs-migration/** |  |  |
| extensions/drm-copilot/test/lib/development-docs-migration/migration-decisions.test.ts | X | exclude | g1-stageA: extensions/drm-copilot/test/lib/development-docs-migration/** |  |  |
| extensions/drm-copilot/test/lib/development-docs-migration/migration-git.test.ts | X | exclude | g1-stageA: extensions/drm-copilot/test/lib/development-docs-migration/** |  |  |
| extensions/drm-copilot/test/lib/development-docs-migration/migration-plan.test.ts | X | exclude | g1-stageA: extensions/drm-copilot/test/lib/development-docs-migration/** |  |  |
| extensions/drm-copilot/test/lib/development-docs-migration/migration-report.test.ts | X | exclude | g1-stageA: extensions/drm-copilot/test/lib/development-docs-migration/** |  |  |
| extensions/drm-copilot/test/lib/development-docs-migration/reference-rewrite.test.ts | X | exclude | g1-stageA: extensions/drm-copilot/test/lib/development-docs-migration/** |  |  |
| extensions/drm-copilot/test/lib/development-docs/root.test.ts | I | exclude | base: extensions/drm-copilot/test/lib/development-docs/** |  |  |
| extensions/drm-copilot/test/lib/development-docs/write-scopes.contract.test.ts | I | exclude | base: extensions/drm-copilot/test/lib/development-docs/** |  |  |
| extensions/drm-copilot/test/lib/development-docs/write-scopes.test.ts | I | exclude | base: extensions/drm-copilot/test/lib/development-docs/** |  |  |
| extensions/drm-copilot/test/lib/json-config.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/json-config.test.ts |  |  |
| extensions/drm-copilot/test/lib/new-active-feature-folder/flow.promoted-disposition.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/lib/new-active-feature-folder/flow.promoted-disposition.test.ts |  |  |
| extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/new-active-feature-folder/flow.test.ts |  |  |
| extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts |  |  |
| extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/new-active-feature-folder/new-active-feature-folder-service-call.test.ts |  |  |
| extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/new-potential-bug-entry.test.ts |  |  |
| extensions/drm-copilot/test/lib/potential-to-issue/content.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/potential-to-issue/content.test.ts |  |  |
| extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call-test-support.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts |  |  |
| extensions/drm-copilot/test/lib/potential-to-issue/promotion.matrix.test.ts | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  |  |
| extensions/drm-copilot/test/lib/potential-to-issue/promotion.missing-label.test.ts | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  |  |
| extensions/drm-copilot/test/lib/potential-to-issue/promotion.move-verification.test.ts | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  |  |
| extensions/drm-copilot/test/lib/potential-to-issue/promotion.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/potential-to-issue/promotion.test.ts |  |  |
| extensions/drm-copilot/test/lib/pr-context/collector-core-autoclose.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/lib/pr-context/collector-core-autoclose.test.ts |  |  |
| extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts |  |  |
| extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/pr-context/collector-output-ordering.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts | R | tool-rewritten |  | 19r/0l |  |
| extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts |  |  |
| extensions/drm-copilot/test/lib/pr-context/gh-client-details.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/lib/pr-context/gh-client-details.test.ts |  |  |
| extensions/drm-copilot/test/lib/pr-context/models.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/lib/pr-context/models.test.ts |  |  |
| extensions/drm-copilot/test/lib/pr-context/pr-context-service-call-target.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts | R | tool-rewritten |  | 4r/0l |  |
| extensions/drm-copilot/test/lib/pr-context/render-feature-excerpts.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/pr-context/render-feature-excerpts.test.ts |  |  |
| extensions/drm-copilot/test/lib/pr-context/render.test.ts | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  |  |
| extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts |  |  |
| extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts |  |  |
| extensions/drm-copilot/test/lib/promotion-lifecycle-sequence.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/lib/promotion-lifecycle-sequence.test.ts |  |  |
| extensions/drm-copilot/test/lib/resolve/file-prompt-core.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/resolve/file-prompt-variables.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/resolve/file-prompt-variables.test.ts |  |  |
| extensions/drm-copilot/test/lib/resolve/hard-lock-prompt.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/resolve/resolve-prompts-service-call.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/validate/development-docs-matchers.test.ts | I | exclude | base: extensions/drm-copilot/test/lib/validate/development-docs-matchers.test.ts |  |  |
| extensions/drm-copilot/test/lib/validate/epic-kickoff-artifact.test.ts | R | tool-rewritten |  | 10r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-merge-status.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-git-integrity-feature-indices.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-git-integrity.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence-test-support.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-launch-evidence.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-readiness-edges.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/lib/validate/epic-planner-readiness-edges.test.ts |  |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts |  |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-readiness-relative-paths.test.ts | R | tool-rewritten |  | 7r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts | R | tool-rewritten |  | 6r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-indices.test.ts | R | tool-rewritten |  | 4r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/lib/validate/epic-planner-state-shape-errors.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/evidence-locations.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/validate/evidence-locations.test.ts |  |  |
| extensions/drm-copilot/test/lib/validate/orchestration-artifacts-parallel-dispatch.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts | R | tool-rewritten |  | 13r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts |  |  |
| extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-production.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts | R | tool-rewritten |  | 4r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-model-routing.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-codex-topology.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-core.completion.test.ts | R | tool-rewritten |  | 4r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-core.model-routing.test.ts | R | tool-rewritten |  | 5r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-core.test.ts | R | tool-rewritten |  | 6r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-feature-folder.test.ts |  |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts | X | exclude | g4-stay: extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-origin.test.ts |  |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts | X | exclude | g4-stay: extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts |  |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-light-cycle.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-preparation-route.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-accounting.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact-tables.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/validate/parallel-kickoff-artifact.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/parallel-kickoff-fixtures.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/parallel-kickoff-template-seam.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-cohort-barrier.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/lib/validate/parallel-planner-state-core.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/parallel-state-test-support.ts | R | tool-rewritten |  | 5r/0l |  |
| extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/lib/validate/plan-gate-guideline-cutoff.test.ts | I | exclude | base: extensions/drm-copilot/test/lib/validate/plan-gate-guideline-cutoff.test.ts |  |  |
| extensions/drm-copilot/test/lib/validate/plan-gate-observability-boundaries.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts | I | exclude | base: extensions/drm-copilot/test/lib/validate/policy-audit-artifact.test.ts |  |  |
| extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/mcp-handlers/orchestration-handoff-handlers.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/mcp-parallel-validation-definitions.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/mcp-server-parallel-validation.test.ts | R | tool-rewritten |  | 2r/0l |  |
| extensions/drm-copilot/test/mcp-server.test.ts | R | tool-rewritten |  | 5r/0l |  |
| extensions/drm-copilot/test/mcp-tool-inputs-parallel-validation.test.ts | R | tool-rewritten |  | 1r/0l |  |
| extensions/drm-copilot/test/mcp-tools.potential-to-issue-target-repository.test.ts | R | tool-rewritten |  | 3r/0l |  |
| extensions/drm-copilot/test/repo-automation-hard-lock-prompt.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/repo-automation-hard-lock-prompt.test.ts |  |  |
| extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts | X | exclude | g5-proto: extensions/drm-copilot/test/repo-automation-orchestration-validation.test.ts |  |  |
| extensions/drm-copilot/test/repo-automation-service.development-docs.test.ts | X | exclude | g1-stageA: extensions/drm-copilot/test/repo-automation-service.development-docs.test.ts |  |  |
| extensions/drm-copilot/test/repo-automation-service.new-potential-entry-root.test.ts | I | exclude | g3-child2test: extensions/drm-copilot/test/repo-automation-service.new-potential-entry-root.test.ts |  |  |
| extensions/drm-copilot/test/repo-automation-service.resolve-atomic-plan-prompt.test.ts | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/ci/CiChangeScope.Tests.ps1 | I | exclude | base: tests/scripts/ci/CiChangeScope.Tests.ps1 |  |  |
| tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 | I | exclude | base: tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1 |  |  |
| tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 | I | exclude | base: tests/scripts/ci/Invoke-CiChangeScope.Tests.ps1 |  |  |
| tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1 | I | exclude | base: tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/EpicMergeGateReview.Cases.Helpers.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1 | I | exclude | base: tests/scripts/claude-hooks/EpicWaveEarlyStart.Cases.Helpers.ps1 |  |  |
| tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1 | X | exclude | g5-proto: tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-completion-consistency.TargetWorktree.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-completion-consistency.TargetWorktree.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Regeneration.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-epic-wave-barrier.EarlyStart.Tests.ps1 | I | exclude | base: tests/scripts/claude-hooks/enforce-epic-wave-barrier.EarlyStart.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | R | tool-rewritten |  | 10r/0l |  |
| tests/scripts/claude-hooks/enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-bookkeeping.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-bookkeeping.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | R | tool-rewritten |  | 38r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | R | tool-rewritten |  | 31r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 | R | tool-rewritten |  | 42r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Classification.Cases.ps1 | R | tool-rewritten |  | 5r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1 | X | exclude | g5-proto: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Cleanup.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | R | tool-rewritten |  | 106r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.DevRoot.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.DevRoot.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1 | R | tool-rewritten |  | 8r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.MergedFollowUp.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.MergedFollowUp.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1 | R | tool-rewritten |  | 12r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | R | tool-rewritten |  | 8r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 | R | tool-rewritten |  | 8r/0l |  |
| tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | R | tool-rewritten |  | 70r/0l |  |
| tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 | R | tool-rewritten |  | 5r/0l |  |
| tests/scripts/claude-hooks/enforce-parallel-drift-gate.DevelopmentDocsRoot.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-parallel-drift-gate.DevelopmentDocsRoot.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1 | X | exclude | g5-proto: tests/scripts/claude-hooks/enforce-pr-author-skill.Cleanup.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | X | exclude | g5-proto: tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | R | tool-rewritten |  | 28r/0l |  |
| tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/hook-cleanup-context.Tests.ps1 | X | exclude | g5-proto: tests/scripts/claude-hooks/hook-cleanup-context.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | R | tool-rewritten |  | 17r/0l |  |
| tests/scripts/claude-hooks/parallel-records-workflow.EndToEnd.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/review-verdict-status.HookAllowance.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-hooks/subagentstop-target-worktree.Tests.ps1 | X | exclude | g5-proto: tests/scripts/claude-hooks/subagentstop-target-worktree.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/validate-executor-output.Envelope.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/validate-executor-output.LightRemediation.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/validate-executor-output.Preflight.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/validate-executor-output.Preflight.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/validate-executor-output.Reentry.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/validate-executor-output.TargetWorktree.Tests.ps1 | R | tool-rewritten |  | 8r/0l |  |
| tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | R | tool-rewritten |  | 29r/0l |  |
| tests/scripts/claude-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/validate-feature-review-coverage.E4.Helpers.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-hooks/validate-feature-review-coverage.Issue824.Tests.ps1 | R | tool-rewritten |  | 28r/0l |  |
| tests/scripts/claude-hooks/validate-feature-review-coverage.TargetWorktree.Tests.ps1 | X | exclude | g5-proto: tests/scripts/claude-hooks/validate-feature-review-coverage.TargetWorktree.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/validate-human-exception-runbook-output.TargetWorktree.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/validate-human-exception-runbook-output.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/validate-orchestrator-output.FeatureFolder.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/validate-planner-output.Coverage.Tests.ps1 | R | tool-rewritten |  | 7r/0l |  |
| tests/scripts/claude-hooks/validate-planner-output.PreMortem.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-hooks/validate-planner-output.Reentry.Tests.ps1 | R | tool-rewritten |  | 8r/0l |  |
| tests/scripts/claude-hooks/validate-planner-output.TargetWorktree.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | R | tool-rewritten |  | 36r/0l |  |
| tests/scripts/claude-hooks/validate-prd-feature-output.TargetWorktree.Tests.ps1 | R | tool-rewritten |  | 6r/0l |  |
| tests/scripts/claude-hooks/validate-required-artifact-output.Envelope.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-hooks/validate-required-artifact-output.Reentry.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-hooks/validate-required-artifact-output.TargetWorktree.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1 | R | tool-rewritten |  | 23r/0l |  |
| tests/scripts/claude-hooks/validate-task-researcher-output.PreMortem.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/validate-task-researcher-output.PreMortem.Tests.ps1 |  |  |
| tests/scripts/claude-hooks/validate-task-researcher-output.TargetWorktree.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 |  |  |
| tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 | A | exclude; no-root default docs/features (child 2 OD-P4) | g3-child2test: tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 |  |  |
| tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.OverlappingPairs.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.PathOverlap.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | X | exclude | g5-proto: tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 |  |  |
| tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 | X | exclude | g5-proto: tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 |  |  |
| tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 |  |  |
| tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/blast-radius/BlastRadiusWriteIntent.Tests.ps1 |  |  |
| tests/scripts/claude-lib/development-docs/DevelopmentDocsRoot.Tests.ps1 | I | exclude | base: tests/scripts/claude-lib/development-docs/** |  |  |
| tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.Tests.ps1 | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  | yes |
| tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1 | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  | yes |
| tests/scripts/claude-lib/docs/DocsPageImportIsolation.Tests.ps1 | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  | yes |
| tests/scripts/claude-lib/docs/DocsProfile.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-lib/docs/DocsScannerContract.Tests.ps1 | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  | yes |
| tests/scripts/claude-lib/docs/DocumentationEstateEpicTemplate.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-lib/docs/DocumentationEstateOnboarding.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Adapters.Tests.ps1 |  |  |
| tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/epic-wave/EpicCrossDependency.Tests.ps1 |  |  |
| tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateConcurrentReview.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.Tests.ps1 |  |  |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 |  |  |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateLightCycle.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Integration.Tests.ps1 |  |  |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.PrecedenceGate.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/parallel-admission/Invoke-ParallelAdmission.Tests.ps1 |  |  |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmission.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-lib/parallel-admission/ParallelAdmissionPrecedence.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-lib/regeneration/RegenerationDelta.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-lib/review-verdict/Invoke-ReviewVerdictStatus.Tests.ps1 | R | tool-rewritten |  | 6r/0l |  |
| tests/scripts/claude-lib/review-verdict/ReviewVerdictEligibility.PullRequest.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/review-verdict/ReviewVerdictEligibility.PullRequest.Tests.ps1 |  |  |
| tests/scripts/claude-lib/review-verdict/ReviewVerdictEligibility.Review.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/review-verdict/ReviewVerdictEligibility.Review.Tests.ps1 |  |  |
| tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 |  |  |
| tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 | X | exclude | g5-proto: tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 |  |  |
| tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 |  |  |
| tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  |  |
| tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | R | manual [P3-T6] (segment-joined docs, engineering) |  | 2r/0l | yes |
| tests/scripts/claude-runtime/copilot-layer-retirement.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/claude-runtime/cross-epic-skill-contract.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1 | D | exclude (LEDGER_PINNED); FIX-NAMED [P3-T9] | base: tests/scripts/claude-runtime/less-evidence-contract.Tests.ps1 |  |  |
| tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 | D | exclude (LEDGER_PINNED); FIX-NAMED [P3-T9] | base: tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 |  |  |
| tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 | D | tool-rewritten; FIX-NAMED [P3-T9] (PCW-STANDING-RULE rows) |  | 3r/0l |  |
| tests/scripts/claude-runtime/policy-toolchain-naming.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-runtime/test-cadence-wording.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.CriticalPath.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.CrossEpic.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Gather.Tests.ps1 | R | tool-rewritten |  | 8r/0l |  |
| tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.ItemMode.Tests.ps1 | R | tool-rewritten |  | 7r/0l |  |
| tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Schedule.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.State.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/claude-skills/epic-progress-report/Get-EpicProgressReport.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/codex-hooks/authorize-root-epic-invocation.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/authorize-root-epic-invocation.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/codex-hooks/enforce-completion-consistency-target-worktree.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/enforce-completion-helpers.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/enforce-epic-merge-gate-regeneration.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-review.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/enforce-epic-merge-gate-review.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/enforce-epic-wave-barrier.Coverage.Tests.ps1 | R | tool-rewritten |  | 9r/0l |  |
| tests/scripts/codex-hooks/enforce-epic-wave-barrier.EarlyStart.Tests.ps1 | I | exclude | base: tests/scripts/codex-hooks/enforce-epic-wave-barrier.EarlyStart.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1 | X | exclude | g5-proto: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-cleanup.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1 | R | tool-rewritten |  | 53r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | R | tool-rewritten |  | 53r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-dev-root.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-dev-root.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-fan-in.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-merged-follow-up.Tests.ps1 | R | tool-rewritten |  | 11r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 | R | tool-rewritten |  | 38r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | R | tool-rewritten |  | 9r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | R | tool-rewritten |  | 7r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | R | tool-rewritten |  | 6r/0l |  |
| tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/codex-hooks/epic-child-launch-contract.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/epic-child-launch-contract.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/epic-child-launch-runtime.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/epic-child-launch-runtime.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | R | tool-rewritten |  | 9r/0l |  |
| tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | R | tool-rewritten |  | 8r/0l |  |
| tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/feature-review-coverage-target.Tests.ps1 |  |  |
| tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1 | R | tool-rewritten |  | 7r/0l |  |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | R | tool-rewritten |  | 6r/0l |  |
| tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/codex-hooks/validate-feature-review-coverage.Coverage.Tests.ps1 |  |  |
| tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1 | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1 | I | exclude | base: tests/scripts/dev-tools/ProcessReductionChain.Tests.ps1 |  |  |
| tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1 | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev-tools/ProcessReductionLedger.Replay.Tests.ps1 | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1 | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/dev-tools/link-feature-docs.Tests.ps1 |  |  |
| tests/scripts/dev-tools/new-potential-entry.EntryGuards.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/dev-tools/new-potential-entry.EntryGuards.Tests.ps1 |  |  |
| tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | I | exclude | g3-child2test: tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 |  |  |
| tests/scripts/dev_tools/atomic_executor/test_cli_part2.py | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  | yes |
| tests/scripts/dev_tools/atomic_executor/test_cli_part2_part2.py | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  | yes |
| tests/scripts/dev_tools/atomic_executor/test_cli_part3.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/atomic_executor/test_plan_discovery.py | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  |  |
| tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  |  |
| tests/scripts/dev_tools/discovery/test_domain_neutrality.py | R | FIX-NAMED [P3-T7] |  |  |  |
| tests/scripts/dev_tools/discovery/test_init_models.py | R | FIX-NAMED [P3-T7] |  |  | yes |
| tests/scripts/dev_tools/epic_planner_launch_evidence_test_support.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/orchestrator_state_issue_adoption_test_support.py | X | exclude | g4-stay: tests/scripts/dev_tools/orchestrator_state_issue_adoption_test_support.py |  |  |
| tests/scripts/dev_tools/parallel_orchestrator_permission_seam_support.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py | I+R | exclude (LEDGER_PINNED) plus manual [P3-T6] KICKOFF_IDENTITY_FRAGMENTS | base: tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py |  |  |
| tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/parallel_planner_state_builders.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/pr_context/test_autoclose_collector.py | X | exclude | g5-proto: tests/scripts/dev_tools/pr_context/test_autoclose_collector.py |  | yes |
| tests/scripts/dev_tools/pr_context/test_verification_evidence.py | I | exclude | g3-child2test: tests/scripts/dev_tools/pr_context/test_verification_evidence.py |  |  |
| tests/scripts/dev_tools/test_blast_radius_conflicts.py | X | exclude | g5-proto: tests/scripts/dev_tools/test_blast_radius_conflicts.py |  |  |
| tests/scripts/dev_tools/test_blast_radius_extraction.py | X | exclude | g5-proto: tests/scripts/dev_tools/test_blast_radius_extraction.py |  |  |
| tests/scripts/dev_tools/test_blast_radius_extraction_rules.py | X | exclude | g5-proto: tests/scripts/dev_tools/test_blast_radius_extraction_rules.py |  |  |
| tests/scripts/dev_tools/test_blast_radius_generic_contracts.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_blast_radius_normalization.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_blast_radius_token_shapes.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_blast_radius_token_shapes.py |  |  |
| tests/scripts/dev_tools/test_blast_radius_write_intent.py | A | exclude (member 4); pins docs/features explicitly (see root-pin row) | g3-child2test: tests/scripts/dev_tools/test_blast_radius_write_intent.py |  |  |
| tests/scripts/dev_tools/test_build_discovery_runtime.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_collect_pr_context.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_collect_pr_context.py |  | yes |
| tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_collect_pr_context_part2.py | R | tool-rewritten |  | 8r/0l |  |
| tests/scripts/dev_tools/test_collect_pr_context_part3.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_collect_pr_context_part4.py | X | exclude | g5-proto: tests/scripts/dev_tools/test_collect_pr_context_part4.py |  |  |
| tests/scripts/dev_tools/test_collect_pr_context_part5.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py |  |  |
| tests/scripts/dev_tools/test_compute_blast_radius.py | A | exclude; no-root default | g3-child2test: tests/scripts/dev_tools/test_compute_blast_radius.py |  |  |
| tests/scripts/dev_tools/test_copy_research_to_issue.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_copy_research_to_issue.py |  |  |
| tests/scripts/dev_tools/test_discovery_documentation_contracts.py | R | manual [P3-T6] (DOC segment join; *-980 glob) |  | 4r/0l | yes |
| tests/scripts/dev_tools/test_epic_kickoff_contract.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_epic_kickoff_contract.py |  |  |
| tests/scripts/dev_tools/test_epic_planner_git_integrity.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_epic_planner_git_integrity_feature_indices.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_epic_planner_launch_evidence.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_epic_planner_readiness.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_epic_planner_readiness.py |  |  |
| tests/scripts/dev_tools/test_epic_planner_readiness_edges.py | X | exclude | g5-proto: tests/scripts/dev_tools/test_epic_planner_readiness_edges.py |  |  |
| tests/scripts/dev_tools/test_epic_planner_readiness_relative_paths.py | R | tool-rewritten |  | 7r/0l |  |
| tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py | X | exclude | g5-proto: tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py |  |  |
| tests/scripts/dev_tools/test_execution_environment_brief_contracts.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_feature_docs.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_feature_docs.py |  | yes |
| tests/scripts/dev_tools/test_github_part2.py | X | exclude | g5-proto: tests/scripts/dev_tools/test_github_part2.py |  | yes |
| tests/scripts/dev_tools/test_json_config.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_json_config.py |  | yes |
| tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_new_active_feature_folder.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_new_active_feature_folder.py |  | yes |
| tests/scripts/dev_tools/test_new_active_feature_folder_bug_template_preserved.py | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  | yes |
| tests/scripts/dev_tools/test_new_active_feature_folder_part2.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_new_active_feature_folder_part2.py |  | yes |
| tests/scripts/dev_tools/test_new_active_feature_folder_part3.py | I+R | exclude row: segment joins inside a fake workspace plus tool-rewritten literals; a glob is needed only when the [P1-T6] rehearsal fails it (member 9); no manual edit |  | 1r/0l | yes |
| tests/scripts/dev_tools/test_new_active_feature_folder_part4.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_new_active_feature_folder_part4.py |  | yes |
| tests/scripts/dev_tools/test_new_active_feature_folder_part5.py | I+R | exclude row: segment joins inside a fake workspace plus tool-rewritten literals; a glob is needed only when the [P1-T6] rehearsal fails it (member 9); no manual edit |  | 2r/0l | yes |
| tests/scripts/dev_tools/test_new_potential_bug_entry.py | I | exclude (member 4); injected root | g3-child2test: tests/scripts/dev_tools/test_new_potential_bug_entry.py |  | yes |
| tests/scripts/dev_tools/test_orchestration_handoff_paths.py | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/dev_tools/test_orchestration_handoff_schema.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_orchestration_handoff_versions.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py |  |  |
| tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py |  |  |
| tests/scripts/dev_tools/test_orchestrator_state_light_cycle.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_orchestrator_state_remediation_accounting.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py |  |  |
| tests/scripts/dev_tools/test_parallel_drift_detection.py | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py | X | exclude (group 5, A29); compares .claude/rules/orchestrator-state.md (A6) | g5-proto: tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py |  |  |
| tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_parallel_kickoff_contract.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_parallel_kickoff_contract.py |  |  |
| tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_parallel_manifest_contract_m8.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py | R | tool-rewritten |  | 5r/0l |  |
| tests/scripts/dev_tools/test_plan_gate_guideline_cutoff.py | I | exclude | base: tests/scripts/dev_tools/test_plan_gate_guideline_cutoff.py |  |  |
| tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_plan_progress_report.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_plan_progress_report.py |  |  |
| tests/scripts/dev_tools/test_potential_to_issue.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_potential_to_issue.py |  |  |
| tests/scripts/dev_tools/test_potential_to_issue_branches.py | R | tool-rewritten |  | 6r/0l |  |
| tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py | R | tool-rewritten |  | 7r/0l |  |
| tests/scripts/dev_tools/test_potential_to_issue_content.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_potential_to_issue_content.py |  |  |
| tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py | X | exclude | g5-proto: tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py |  |  |
| tests/scripts/dev_tools/test_potential_to_issue_move_verification.py | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  | yes |
| tests/scripts/dev_tools/test_potential_to_issue_work_modes.py | R | tool-rewritten |  | 6r/0l |  |
| tests/scripts/dev_tools/test_pr_context_freshness.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_pr_context_integration.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_render_helpers.py | I+R | exclude row: segment joins inside a fake workspace plus tool-rewritten literals; a glob is needed only when the [P1-T6] rehearsal fails it (member 9); no manual edit |  | 10r/0l | yes |
| tests/scripts/dev_tools/test_resolve_execute_plan_prompt.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_resolve_execute_plan_prompt.py |  | yes |
| tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part2.py | I+R | exclude row: segment joins inside a fake workspace plus tool-rewritten literals; a glob is needed only when the [P1-T6] rehearsal fails it (member 9); no manual edit |  | 4r/0l | yes |
| tests/scripts/dev_tools/test_resolve_execute_plan_prompt_part3.py | I | exclude (workspace-rooted, in-memory or library-folder form the prefix rule does not rewrite; no glob needed) |  |  | yes |
| tests/scripts/dev_tools/test_resolve_file_prompt.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_resolve_file_prompt.py |  | yes |
| tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py | X | exclude | g5-proto: tests/scripts/dev_tools/test_resolve_hard_lock_prompt.py |  | yes |
| tests/scripts/dev_tools/test_scratch_location_contracts.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_single_pass_preflight_contracts.py | D | tool-rewritten; FIX-NAMED [P3-T9] test_contract_requires_final_phase_self_review, [P3-T4] test_plan_templates_carry_premortem_skeleton |  | 5r/0l |  |
| tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_validate_epic_planner_state.py | R | tool-rewritten |  | 7r/0l |  |
| tests/scripts/dev_tools/test_validate_epic_planner_state_feature_indices.py | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_validate_epic_planner_state_shape_errors.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_validate_evidence_locations.py | I | exclude | g3-child2test: tests/scripts/dev_tools/test_validate_evidence_locations.py |  |  |
| tests/scripts/dev_tools/test_validate_orchestration_artifacts.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_codex_model_routing.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_codex_topology.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_delegation_receipts.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_human_interaction.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_model_routing_gate.py | R | tool-rewritten |  | 1r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_pr_creation_readiness.py | R | tool-rewritten |  | 4r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_preparation_route.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py | R | tool-rewritten |  | 5r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_validate_orchestrator_state_step_status_extras.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py | R | tool-rewritten |  | 3r/0l |  |
| tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py | R | tool-rewritten |  | 2r/0l |  |
| tests/scripts/dev_tools/test_validate_policy_audit_artifact.py | I | exclude | base: tests/scripts/dev_tools/test_validate_policy_audit_artifact.py |  |  |
| tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py | R | tool-rewritten |  | 16r/0l |  |
| tests/scripts/dev_tools/validate_orchestrator_state_test_support.py | R | tool-rewritten |  | 9r/0l |  |
| tests/shell/report_lane_assertion_dispatch.bats | R | tool-rewritten |  | 1r/0l |  |

## Production matches (PRODUCTION_SEARCH)

| File | Line | Class | Text |
| --- | --- | --- | --- |
| .claude/hooks/enforce-epic-merge-gate-review.ps1 | 39 | STAY_ENTRIES (**/hooks/enforce-epic-merge-gate-review.ps1) | 9. feature-folder is not a clean path below docs/features/: REVIEW_GATE_HEAD_UNRESOLVED. |
| .claude/hooks/enforce-epic-merge-gate-review.ps1 | 296 | STAY_ENTRIES (**/hooks/enforce-epic-merge-gate-review.ps1) | return [ordered]@{ State = 'Unresolved'; Detail = 'the checkpoint feature-folder value is not a clean path below docs/features/.' } |
| .claude/hooks/enforce-epic-wave-barrier.ps1 | 14 | tool-rewritten | (feature-folder-resolution.ps1, issue #565): every docs/features/active/<token> |
| .claude/hooks/enforce-epic-wave-barrier.ps1 | 120 | tool-rewritten | docs/features/active/<token> path, in either separator style, is truncated to its |
| .claude/hooks/enforce-evidence-locations.ps1 | 27 | tool-rewritten | is written to the tracked roots docs/features/<feature>/research/ |
| .claude/hooks/enforce-evidence-locations.ps1 | 28 | tool-rewritten | (feature-associated) or docs/research/ (one-off). |
| .claude/hooks/enforce-feature-folder-order.ps1 | 10 | STAY_ENTRIES (**/hooks/enforce-feature-folder-order.ps1) | docs/features/(active/archive)/<folder>/: a literal plan.md or a timestamped |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 18 | STAY_ENTRIES (**/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md. |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 59 | STAY_ENTRIES (**/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md. |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 65 | STAY_ENTRIES (**/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # `docs/features/active/X` under `-C <root>/tests/fixtures/resolve_execute_plan_prompt` |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 66 | STAY_ENTRIES (**/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # stages `tests/fixtures/resolve_execute_plan_prompt/docs/features/active/X`. Measured |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 267 | STAY_ENTRIES (**/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | rule in docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md). |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 367 | STAY_ENTRIES (**/hooks/enforce-orchestration-preimplementation-gate-modes.ps1) | epic_manifest_path under docs/features/epics/; non-empty |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 19 | STAY_ENTRIES (**/hooks/enforce-parallel-cohort-barrier.ps1) | (feature-folder-resolution.ps1, issue #565): every docs/features/active/<token> |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 138 | STAY_ENTRIES (**/hooks/enforce-parallel-cohort-barrier.ps1) | docs/features/active/<folder> path and one that records a bare basename both match |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 171 | STAY_ENTRIES (**/hooks/enforce-parallel-cohort-barrier.ps1) | docs/features/active/<token> path, in either separator style, is truncated to its |
| .claude/hooks/enforce-parallel-drift-gate.ps1 | 12 | STAY_ENTRIES (**/hooks/enforce-parallel-drift-gate.ps1) | (feature-folder-resolution.ps1, issue #565), which truncates every docs/features/active/ |
| .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 290 | STAY_ENTRIES (**/hooks/enforce-prd-feature-before-planner-helpers.ps1) | Scans a prompt string for docs/features/active/<...> path tokens, |
| .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 296 | STAY_ENTRIES (**/hooks/enforce-prd-feature-before-planner-helpers.ps1) | Truncation to four segments -- docs, features, active, and the |
| .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 297 | STAY_ENTRIES (**/hooks/enforce-prd-feature-before-planner-helpers.ps1) | feature-folder name -- is two segments past the docs/features/active/ |
| .claude/hooks/enforce-prd-feature-before-planner.ps1 | 27 | STAY_ENTRIES (**/.claude/hooks/enforce-prd-feature-before-planner.ps1) | docs/features/active/<token>, accepting both forward-slash and |
| .claude/hooks/enforce-prd-feature-before-planner.ps1 | 29 | STAY_ENTRIES (**/.claude/hooks/enforce-prd-feature-before-planner.ps1) | docs/features/active/ prefix -- that is, to exactly four path segments: |
| .claude/hooks/enforce-prd-feature-before-planner.ps1 | 30 | STAY_ENTRIES (**/.claude/hooks/enforce-prd-feature-before-planner.ps1) | docs, features, active, and the feature-folder name. Truncation is |
| .claude/hooks/enforce-prd-feature-before-planner.ps1 | 63 | STAY_ENTRIES (**/.claude/hooks/enforce-prd-feature-before-planner.ps1) | under docs/features/active/ today, and issue.md sits at the feature root in |
| .claude/hooks/feature-folder-resolution.ps1 | 9 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | a known development-docs root (docs/features/active/ or .dev/active/, issue #1035), and |
| .claude/hooks/feature-folder-resolution.ps1 | 41 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | after the first 'active' segment (the fourth segment under docs/features), with |
| .claude/hooks/feature-folder-resolution.ps1 | 49 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | known-root alternation, so both docs/features and .dev tokens are read. |
| .claude/hooks/feature-folder-resolution.ps1 | 60 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | [string] $RootPattern = '(?:docs[\\/]features/\.dev)' |
| .claude/hooks/feature-folder-resolution.ps1 | 96 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | known-root alternation, so docs/features/<lifecycle>/ and .dev/<lifecycle>/ prefixes |
| .claude/hooks/feature-folder-resolution.ps1 | 108 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | [string] $RootPattern = '(?:docs[\\/]features/\.dev)' |
| .claude/hooks/hook-command-invocation.ps1 | 6 | tool-rewritten | docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md, |
| .claude/hooks/hook-command-scanner.ps1 | 6 | tool-rewritten | docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md. |
| .claude/hooks/hook-epic-fan-in.ps1 | 10 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | docs/features/epics/<slug>/epic-status.md and pr-author writes the integration pull |
| .claude/hooks/hook-epic-fan-in.ps1 | 123 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | Derives docs/features/epics/<epic_feature_folder>/epic-status.md; a declared .dev/epics form of the |
| .claude/hooks/hook-epic-fan-in.ps1 | 137 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $derived = "docs/features/epics/$slug/epic-status.md" |
| .claude/hooks/hook-epic-fan-in.ps1 | 389 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | after one optional docs/features/active/ or docs/features/completed/ prefix, a |
| .claude/hooks/hook-epic-fan-in.ps1 | 391 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | 0: docs/features/active/<basename>/ and docs/features/completed/<basename>/. The status |
| .claude/hooks/hook-epic-fan-in.ps1 | 415 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $roots.Add("docs/features/active/$basename/") |
| .claude/hooks/hook-epic-fan-in.ps1 | 416 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $roots.Add("docs/features/completed/$basename/") |
| .claude/hooks/hook-epic-fan-in.ps1 | 431 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | path is also judged in its docs/features/<area>/... form (issue #1035). |
| .claude/hooks/subagentstop-envelope.ps1 | 12 | tool-rewritten | docs/features/archive/subagentstop-envelope-core-897/spec.md (issue #897; at |
| .claude/hooks/subagentstop-envelope.ps1 | 13 | tool-rewritten | docs/features/active/subagentstop-envelope-core-897/ until the archive move). Where this file |
| .claude/hooks/validate-executor-output.ps1 | 146 | STAY_ENTRIES (**/hooks/validate-executor-output.ps1) | the docs/features/ rule reads the repository-relative value and Test-PreflightFixRecord |
| .claude/hooks/validate-executor-output.ps1 | 188 | STAY_ENTRIES (**/hooks/validate-executor-output.ps1) | return @{ Ok = $false; Repairable = $true; Message = 'atomic-executor hook: a `PREFLIGHT-FIX:` line requires a `preflight-fix-record: <path> |
| .claude/hooks/validate-required-artifact-output.ps1 | 15 | STAY_ENTRIES (**/hooks/validate-required-artifact-output.ps1) | spec-path/^docs/features/active/.+/spec\.md$/spec artifact |
| .claude/hooks/validate-task-researcher-output.ps1 | 9 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | (docs/features/<feature>/research/ for feature-associated research, or |
| .claude/hooks/validate-task-researcher-output.ps1 | 10 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | docs/research/ for one-off research), matches the documented filename |
| .claude/hooks/validate-task-researcher-output.ps1 | 12 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | docs/features/ must also carry a complete `## Pre-Mortem` section |
| .claude/hooks/validate-task-researcher-output.ps1 | 14 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | research under docs/research/ is exempt. |
| .claude/hooks/validate-task-researcher-output.ps1 | 89 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | Feature research lives under docs/features/ or .dev/ (issue #1035); the one-off research |
| .claude/hooks/validate-task-researcher-output.ps1 | 90 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | areas docs/research/ and .dev/research/ are excluded, so .dev/research/ is exempt from |
| .claude/hooks/validate-task-researcher-output.ps1 | 91 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | the Pre-Mortem as docs/research/ is. |
| .claude/hooks/validate-task-researcher-output.ps1 | 123 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | #   - one-off research: the research area (docs/research/ or .dev/research/). |
| .claude/hooks/validate-task-researcher-output.ps1 | 306 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | return @{ Ok = $false; Message = 'task-researcher hook: agent output does not advertise a research-path. Researcher must report `research-pa |
| .claude/hooks/validate-task-researcher-output.ps1 | 323 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | return @{ Ok = $false; Message = "task-researcher hook: research-path '$researchPath' is not under a tracked research root. All research art |
| .claude/hooks/validate-task-researcher-output.ps1 | 327 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | return @{ Ok = $false; Message = "task-researcher hook: research-path '$researchPath' does not match the required filename convention `<time |
| .claude/hooks/validate-task-researcher-output.ps1 | 345 | STAY_ENTRIES (**/hooks/validate-task-researcher-output.ps1) | # Issue #964: feature research carries a Pre-Mortem; one-off research under docs/research/ |
| .claude/lib/bash/report-lane-assertion.sh | 48 | tool-rewritten | --manifest  Path to docs/features/parallel/<slug>/parallel.md (required). |
| .claude/lib/blast-radius/BlastRadius.psm1 | 157 | STAY_ENTRIES (**/.claude/lib/blast-radius/BlastRadius.psm1) | placed. Defaults to the first known root (docs/features); a value outside |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 25 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | $script:DefaultDevelopmentDocsRoot = 'docs/features' |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 26 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | $script:KnownDevelopmentDocsRoots = @('docs/features', '.dev') |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 29 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | 'backlog'             = @{ 'docs/features' = 'docs/features/backlog.md'; '.dev' = '.dev/backlog.md' } |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 30 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | 'research'            = @{ 'docs/features' = 'docs/research'; '.dev' = '.dev/research' } |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 31 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | 'discovery-templates' = @{ 'docs/features' = 'docs/discovery/templates'; '.dev' = '.dev/discovery/templates' } |
| .claude/lib/development-docs/DevelopmentDocsRoot.psm1 | 32 | STAY_ENTRIES (**/.claude/lib/development-docs/**) | 'engineering'         = @{ 'docs/features' = 'docs/engineering'; '.dev' = '.dev/engineering' } |
| .claude/lib/docs/DocsProfile.psm1 | 187 | STAY_ENTRIES (**/.claude/lib/docs/DocsProfile.psm1) | 'guide', so a starter profile never selects planning trees such as docs/features/. |
| .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 | 24 | tool-rewritten | pwsh -NoProfile -File .claude/lib/epic-wave/Invoke-EpicCrossReadiness.ps1 -Mode feature -ManifestPath docs/features/epics/<slug>/epic.md -Is |
| .claude/lib/orchestrator-state/OrchestratorStateCheckpointValue.psm1 | 392 | tool-rewritten | docs/features/potential/2026-08-07-python-repr-quote-selection-divergence.md: |
| .claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1 | 37 | STAY_ENTRIES (**/.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1) | # the error text keeps naming docs/features/active (D-P11). |
| .claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1 | 42 | STAY_ENTRIES (**/.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1) | $script:ERROR_PATH_FORMAT = 'Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without  |
| .claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1 | 55 | STAY_ENTRIES (**/.claude/lib/orchestrator-state/OrchestratorStateFeatureFolderRecord.psm1) | under docs/features/active/ whose every segment starts with a letter or |
| .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | 317 | STAY_ENTRIES (**/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1) | $errors.Add("Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving $tool.") |
| .claude/lib/parallel-admission/Invoke-ParallelAdmission.ps1 | 241 | STAY_ENTRIES (**/lib/parallel-admission/Invoke-ParallelAdmission.ps1) | return "-RunFolder must be docs/features/parallel/<slug>; got '$($Option['RunFolder'])'." |
| .claude/lib/parallel-admission/ParallelAdmissionPrecedence.psm1 | 420 | tool-rewritten | Build the durable scheduling record docs/features/parallel/<slug>/parallel-scheduling.json. |
| .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 | 246 | STAY_ENTRIES (**/lib/review-verdict/ReviewVerdictEligibility.psm1) | return ConvertTo-ReviewVerdictDecision -Eligible $false -Code 'REVIEW_VERDICT_FEATURE_FOLDER_INVALID' -Detail "feature-folder '$folder' is n |
| .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 | 481 | STAY_ENTRIES (**/lib/review-verdict/ReviewVerdictEligibility.psm1) | Every name-status entry lies under docs/features/potential/ (not template.md) or is an |
| .claude/lib/review-verdict/ReviewVerdictEligibility.psm1 | 482 | STAY_ENTRIES (**/lib/review-verdict/ReviewVerdictEligibility.psm1) | added file under exactly one folder docs/features/active/<name>-<branch number>/ that does |
| .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | 132 | STAY_ENTRIES (**/lib/worktree-resolution/EpicScopeReadiness.psm1) | epic_manifest_path (empty, or not under docs/features/epics/ after backslash |
| .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1 | 52 | STAY_ENTRIES (**/lib/worktree-resolution/WorktreeTargetResolution.psm1) | # active area of either known development-docs root (docs/features/active or |
| .codex/hooks/enforce-epic-merge-gate-review.ps1 | 39 | STAY_ENTRIES (**/hooks/enforce-epic-merge-gate-review.ps1) | 9. feature-folder is not a clean path below docs/features/: REVIEW_GATE_HEAD_UNRESOLVED. |
| .codex/hooks/enforce-epic-merge-gate-review.ps1 | 296 | STAY_ENTRIES (**/hooks/enforce-epic-merge-gate-review.ps1) | return [ordered]@{ State = 'Unresolved'; Detail = 'the checkpoint feature-folder value is not a clean path below docs/features/.' } |
| .codex/hooks/enforce-evidence-locations.ps1 | 28 | tool-rewritten | is written to the tracked roots docs/features/<feature>/research/ |
| .codex/hooks/enforce-evidence-locations.ps1 | 29 | tool-rewritten | (feature-associated) or docs/research/ (one-off). |
| .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 353 | STAY_ENTRIES (**/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1) | epic_manifest_path (empty, or not under docs/features/epics/ after backslash |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 18 | STAY_ENTRIES (**/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | docs/features/active/2026-08-24-preimplementation-gate-blocks-planner-integration-commits-539/spec.md. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 59 | STAY_ENTRIES (**/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md. |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 65 | STAY_ENTRIES (**/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # `docs/features/active/X` under `-C <root>/tests/fixtures/resolve_execute_plan_prompt` |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 66 | STAY_ENTRIES (**/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | # stages `tests/fixtures/resolve_execute_plan_prompt/docs/features/active/X`. Measured |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 267 | STAY_ENTRIES (**/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1) | rule in docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md). |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 364 | STAY_ENTRIES (**/hooks/enforce-orchestration-preimplementation-gate-modes.ps1) | epic_manifest_path under docs/features/epics/; non-empty |
| .codex/hooks/feature-folder-resolution.ps1 | 9 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | a known development-docs root (docs/features/active/ or .dev/active/, issue #1035), and |
| .codex/hooks/feature-folder-resolution.ps1 | 41 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | after the first 'active' segment (the fourth segment under docs/features), with |
| .codex/hooks/feature-folder-resolution.ps1 | 49 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | known-root alternation, so both docs/features and .dev tokens are read. |
| .codex/hooks/feature-folder-resolution.ps1 | 60 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | [string] $RootPattern = '(?:docs[\\/]features/\.dev)' |
| .codex/hooks/feature-folder-resolution.ps1 | 96 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | known-root alternation, so docs/features/<lifecycle>/ and .dev/<lifecycle>/ prefixes |
| .codex/hooks/feature-folder-resolution.ps1 | 108 | STAY_ENTRIES (**/hooks/feature-folder-resolution.ps1) | [string] $RootPattern = '(?:docs[\\/]features/\.dev)' |
| .codex/hooks/feature-review-coverage-target.ps1 | 97 | STAY_ENTRIES (**/hooks/feature-review-coverage-target.ps1) | Accepts docs/features/active/<folder>/[<version>/]policy-audit.<timestamp>.md and |
| .codex/hooks/feature-review-coverage-target.ps1 | 98 | STAY_ENTRIES (**/hooks/feature-review-coverage-target.ps1) | docs/features/active/<folder>/audit/<timestamp>/policy-audit.md, relative or absolute, with / |
| .codex/hooks/feature-review-coverage-target.ps1 | 103 | STAY_ENTRIES (**/hooks/feature-review-coverage-target.ps1) | double-quote span that holds docs/features/active/ (spaces kept); (3) each whitespace-delimited |
| .codex/hooks/feature-review-coverage-target.ps1 | 105 | STAY_ENTRIES (**/hooks/feature-review-coverage-target.ps1) | holds docs/features/active/ exactly once, so a source that spans two audit paths is skipped and |
| .codex/hooks/feature-review-coverage-target.ps1 | 190 | STAY_ENTRIES (**/hooks/feature-review-coverage-target.ps1) | return [pscustomobject]@{ RelativePath = $null; ReasonCode = 'AUDIT_NOT_NAMED'; Reason = 'the reviewer''s final message names no policy audi |
| .codex/hooks/hook-command-invocation.ps1 | 6 | tool-rewritten | docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md, |
| .codex/hooks/hook-command-scanner.ps1 | 6 | tool-rewritten | docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md. |
| .codex/hooks/hook-epic-fan-in.ps1 | 10 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | docs/features/epics/<slug>/epic-status.md and pr-author writes the integration pull |
| .codex/hooks/hook-epic-fan-in.ps1 | 123 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | Derives docs/features/epics/<epic_feature_folder>/epic-status.md; a declared .dev/epics form of the |
| .codex/hooks/hook-epic-fan-in.ps1 | 137 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $derived = "docs/features/epics/$slug/epic-status.md" |
| .codex/hooks/hook-epic-fan-in.ps1 | 389 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | after one optional docs/features/active/ or docs/features/completed/ prefix, a |
| .codex/hooks/hook-epic-fan-in.ps1 | 391 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | 0: docs/features/active/<basename>/ and docs/features/completed/<basename>/. The status |
| .codex/hooks/hook-epic-fan-in.ps1 | 415 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $roots.Add("docs/features/active/$basename/") |
| .codex/hooks/hook-epic-fan-in.ps1 | 416 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | $roots.Add("docs/features/completed/$basename/") |
| .codex/hooks/hook-epic-fan-in.ps1 | 431 | STAY_ENTRIES (**/hooks/hook-epic-fan-in.ps1) | path is also judged in its docs/features/<area>/... form (issue #1035). |
| .codex/scripts/epic-child-launch-contract.ps1 | 416 | STAY_ENTRIES (**/.codex/scripts/epic-child-launch-contract.ps1) | $errors.Add("launch '$($entry.launch_id)' requires a final docs/features/active feature_folder without placeholders.") |
| extensions/drm-copilot/src/extension-command-helpers.ts | 90 | STAY_ENTRIES (extensions/drm-copilot/src/extension-command-helpers.ts) | return "This command requires an active or selected plan markdown file under docs/features/active/**/plan*.md."; |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 5 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | * longest prefix first. `docs/discovery/` holds only `templates/`, so its row |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 34 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | export const DISCOVERY_TEMPLATES_SOURCE = "docs/discovery/templates/"; |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 41 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | from: "docs/features/", |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 46 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/potential/", ".dev/potential/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 47 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/active/", ".dev/active/", true), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 48 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/completed/", ".dev/completed/", true), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 49 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/archive/", ".dev/archive/", true), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 50 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/epics/", ".dev/epics/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 51 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/parallel/", ".dev/parallel/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 52 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/templates/", ".dev/templates/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 53 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/features/research/", ".dev/research/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 55 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | from: "docs/features/backlog.md", |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 61 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/research/", ".dev/research/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 62 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | directory("docs/engineering/", ".dev/engineering/"), |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 123 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | * @returns `mapped` with the target; `unmapped` under `docs/features/` with no |
| extensions/drm-copilot/src/lib/development-docs-migration/layout-map.ts | 149 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | if (path.startsWith("docs/features/")) { |
| extensions/drm-copilot/src/lib/development-docs-migration/migrate-development-docs-service-call.ts | 37 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | "docs/features", |
| extensions/drm-copilot/src/lib/development-docs-migration/migrate-development-docs-service-call.ts | 38 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | "docs/research", |
| extensions/drm-copilot/src/lib/development-docs-migration/migrate-development-docs-service-call.ts | 39 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | "docs/engineering", |
| extensions/drm-copilot/src/lib/development-docs-migration/migrate-development-docs-service-call.ts | 40 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | "docs/discovery", |
| extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts | 251 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | for (const root of [`docs/features/${area}/`, `.dev/${area}/`]) { |
| extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts | 396 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | if (tracked.some((path) => path.startsWith("docs/discovery/"))) { |
| extensions/drm-copilot/src/lib/development-docs-migration/migration-plan.ts | 422 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | refusals.push(`unmapped entry under docs/features/: ${entry}`); |
| extensions/drm-copilot/src/lib/development-docs-migration/migration-report.ts | 33 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | ["unmapped_entries", "Unmapped entries under docs/features/"], |
| extensions/drm-copilot/src/lib/development-docs-migration/reference-rewrite.ts | 64 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | * generic `docs/features/` row, longest prefix first. |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 11 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | *     R-1 file absent or unreadable -> `docs/features`. |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 12 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | *     R-2 key absent -> `docs/features` (no `.dev` probe). |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 15 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | *     R-5 value `docs/features` -> `docs/features`. |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 17 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | *     R-7 value `.dev`, `.dev` absent, `docs/features` exists -> `docs/features`. |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 33 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | export type DevelopmentDocsRoot = "docs/features" / ".dev"; |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 37 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | "docs/features"; |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 41 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | ["docs/features", ".dev"]; |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 98 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | /** Areas whose `docs/features` form sits outside `docs/features`. */ |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 103 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | "docs/features": "docs/features/backlog.md", |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 106 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | research: { "docs/features": "docs/research", ".dev": ".dev/research" }, |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 108 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | "docs/features": "docs/discovery/templates", |
| extensions/drm-copilot/src/lib/development-docs/root.ts | 112 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | "docs/features": "docs/engineering", |
| extensions/drm-copilot/src/lib/development-docs/write-scopes.ts | 9 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | *     fallback release both the `docs/features` form and the `.dev` form are |
| extensions/drm-copilot/src/lib/development-docs/write-scopes.ts | 161 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | * `docs/features` and `.dev` for `.dev` (the parent of the engineering area). |
| extensions/drm-copilot/src/lib/development-docs/write-scopes.ts | 205 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | * @returns For example `["Write(/docs/features/active/**)", "Write(/.dev/active/**)"]`. |
| extensions/drm-copilot/src/lib/development-docs/write-scopes.ts | 249 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs/**) | * @returns For example `^(?:docs/features/\.dev)/active/.+/spec\.md$`. |
| extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts | 103 | STAY_ENTRIES (extensions/drm-copilot/src/lib/new-active-feature-folder/io.ts) | * @param root Resolved development-docs root; defaults to `docs/features`. |
| extensions/drm-copilot/src/lib/potential-to-issue/content.ts | 29 | STAY_ENTRIES (extensions/drm-copilot/src/lib/potential-to-issue/content.ts) | export const DEFAULT_ACTIVE_AREA = "docs/features/active"; |
| extensions/drm-copilot/src/lib/potential-to-issue/content.ts | 476 | STAY_ENTRIES (extensions/drm-copilot/src/lib/potential-to-issue/content.ts) | *   `docs/features/active`. |
| extensions/drm-copilot/src/lib/validate/epic-kickoff-artifact.ts | 7 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/epic-kickoff-artifact.ts) | /(?:docs\/features/\.dev)\/epics\/[a-z0-9][a-z0-9-]*\/epic\.md/; |
| extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts | 124 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts) | `${prefix}.feature_folder must be under docs/features/active or completed.`, |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts | 35 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts) | * A repository-relative folder under `docs/features/active/`. Applied without |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts | 39 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts) | // root; the error text keeps naming docs/features/active (D-P11). |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts | 41 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts) | /^(?:docs\/features/\.dev)\/active\/[A-Za-z0-9][A-Za-z0-9._-]*(\/[A-Za-z0-9][A-Za-z0-9._-]*)*$/; |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts | 52 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/orchestrator-state-feature-folder-record.ts) | "Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without dot segments or a trailing s |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts | 276 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts) | `Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving ${tool}.`, |
| extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts | 10 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts) | * Ownership is recorded in `docs/features/epics/parallel-orchestration/epic.md`, |
| extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts | 26 | STAY_ENTRIES (extensions/drm-copilot/src/lib/validate/parallel-kickoff-artifact.ts) | /(?:docs\/features/\.dev)\/parallel\/[a-z0-9][a-z0-9-]*\/parallel\.md/; |
| extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts | 88 | tool-rewritten | * `docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gates/g5-corpus-measurement.2026-08 |
| extensions/drm-copilot/src/lib/validate/plan-gate-observability.ts | 48 | tool-rewritten | * `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/corpus-measurement. |
| scripts/dev-tools/Get-StageTimingReport.ps1 | 15 | STAY_ENTRIES (scripts/dev-tools/Get-StageTimingReport.ps1) | (docs/features unless configured otherwise, issue #1035); a failed resolution throws its Reason. |
| scripts/dev-tools/ProcessReductionChain.psm1 | 184 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionChain.psm1) | return 'docs/features/templates/' + $Matches['rest'] |
| scripts/dev-tools/ProcessReductionChain.psm1 | 482 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionChain.psm1) | [string]$LedgerPath = 'docs/engineering/process-reductions', |
| scripts/dev-tools/ProcessReductionChain.psm1 | 555 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionChain.psm1) | [string]$LedgerPath = 'docs/engineering/process-reductions' |
| scripts/dev-tools/ProcessReductionLedger.psm1 | 6 | STAY_ENTRIES (scripts/dev-tools/ProcessReductionLedger.psm1) | The ledger under docs/engineering/process-reductions/ records every reduction of |
| scripts/dev-tools/link-feature-docs.ps1 | 7 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [ValidateSet('docs/features', '.dev')] |
| scripts/dev-tools/link-feature-docs.ps1 | 8 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [string] $DevelopmentDocsRoot = 'docs/features' |
| scripts/dev-tools/link-feature-docs.ps1 | 44 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [ValidateSet('docs/features', '.dev')] |
| scripts/dev-tools/link-feature-docs.ps1 | 45 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [string] $DevelopmentDocsRoot = 'docs/features' |
| scripts/dev-tools/link-feature-docs.ps1 | 89 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [ValidateSet('docs/features', '.dev')] |
| scripts/dev-tools/link-feature-docs.ps1 | 90 | STAY_ENTRIES (scripts/dev-tools/link-feature-docs.ps1) | [string] $DevelopmentDocsRootParam = 'docs/features' |
| scripts/dev-tools/new-potential-entry.ps1 | 6 | STAY_ENTRIES (**/new-potential-entry.ps1) | [ValidateSet('docs/features', '.dev')] |
| scripts/dev-tools/new-potential-entry.ps1 | 7 | STAY_ENTRIES (**/new-potential-entry.ps1) | [string] $DevelopmentDocsRoot = 'docs/features' |
| scripts/dev_tools/_orchestrator_state_feature_folder_record.py | 57 | STAY_ENTRIES (scripts/dev_tools/_orchestrator_state_feature_folder_record.py) | # A repository-relative folder under docs/features/active/: every segment |
| scripts/dev_tools/_orchestrator_state_feature_folder_record.py | 62 | STAY_ENTRIES (scripts/dev_tools/_orchestrator_state_feature_folder_record.py) | # naming docs/features/active (D-P11). |
| scripts/dev_tools/_orchestrator_state_feature_folder_record.py | 76 | STAY_ENTRIES (scripts/dev_tools/_orchestrator_state_feature_folder_record.py) | "docs/features/active/ without dot segments or a trailing slash." |
| scripts/dev_tools/_orchestrator_state_issue_adoption.py | 289 | STAY_ENTRIES (scripts/dev_tools/_orchestrator_state_issue_adoption.py) | f"file under docs/features/potential/ when waiving {tool}." |
| scripts/dev_tools/build_discovery_runtime.py | 49 | HAND_EDIT_SET | RESOURCE_ROOTS = ("schemas/discovery", "docs/discovery/templates") |
| scripts/dev_tools/copy_research_to_issue.py | 7 | STAY_ENTRIES (scripts/dev_tools/copy_research_to_issue.py) | `docs/features/active/<issue>/...`). |
| scripts/dev_tools/copy_research_to_issue.py | 49 | STAY_ENTRIES (scripts/dev_tools/copy_research_to_issue.py) | development-docs root rather than a fixed ``docs/features`` path. |
| scripts/dev_tools/copy_research_to_issue.py | 58 | STAY_ENTRIES (scripts/dev_tools/copy_research_to_issue.py) | ``docs/features/active`` or ``.dev/active``. |
| scripts/dev_tools/discovery/init_models.py | 32 | HAND_EDIT_SET | return Path(__file__).resolve().parents[3] / "docs" / "discovery" / "templates" |
| scripts/dev_tools/epic_planner_readiness.py | 166 | STAY_ENTRIES (scripts/dev_tools/epic_planner_readiness.py) | The epics area, for example ``docs/features/epics`` or ``.dev/epics``. |
| scripts/dev_tools/epic_planner_readiness.py | 206 | STAY_ENTRIES (scripts/dev_tools/epic_planner_readiness.py) | f"{prefix}.feature_folder must be under docs/features/active or completed." |
| scripts/dev_tools/json_config.py | 46 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | "docs/features/**", |
| scripts/dev_tools/json_config.py | 85 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | DEFAULT_DEVELOPMENT_DOCS_ROOT = "docs/features" |
| scripts/dev_tools/json_config.py | 86 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | KNOWN_DEVELOPMENT_DOCS_ROOTS: tuple[str, ...] = ("docs/features", ".dev") |
| scripts/dev_tools/json_config.py | 101 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | "backlog": {"docs/features": "docs/features/backlog.md", ".dev": ".dev/backlog.md"}, |
| scripts/dev_tools/json_config.py | 102 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | "research": {"docs/features": "docs/research", ".dev": ".dev/research"}, |
| scripts/dev_tools/json_config.py | 104 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | "docs/features": "docs/discovery/templates", |
| scripts/dev_tools/json_config.py | 107 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | "engineering": {"docs/features": "docs/engineering", ".dev": ".dev/engineering"}, |
| scripts/dev_tools/json_config.py | 167 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | ``"docs/features"`` or ``".dev"``. |
| scripts/dev_tools/json_config.py | 205 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | # existing .dev, falls back to an existing docs/features for one release, |
| scripts/dev_tools/json_config.py | 224 | STAY_ENTRIES (scripts/dev_tools/json_config.py) | The area path, for example ``.dev/active`` or ``docs/research``. |
| scripts/dev_tools/new_active_feature_folder_flow.py | 59 | STAY_ENTRIES (scripts/dev_tools/new_active_feature_folder_flow.py) | The resolved root, ``docs/features`` or ``.dev``. |
| scripts/dev_tools/new_active_feature_folder_flow.py | 393 | STAY_ENTRIES (scripts/dev_tools/new_active_feature_folder_flow.py) | description="Create docs/features/active/<name>/ from the selected template." |
| scripts/dev_tools/new_active_feature_folder_flow.py | 406 | STAY_ENTRIES (scripts/dev_tools/new_active_feature_folder_flow.py) | "Must be under docs/features/potential/promoted and end with .md" |
| scripts/dev_tools/new_active_feature_folder_io.py | 52 | STAY_ENTRIES (scripts/dev_tools/new_active_feature_folder_io.py) | root: Resolved development-docs root; defaults to ``docs/features``. |
| scripts/dev_tools/parallel_kickoff_contract.py | 11 | STAY_ENTRIES (scripts/dev_tools/parallel_kickoff_contract.py) | ``docs/features/epics/parallel-orchestration/epic.md`` section "Planner |
| scripts/dev_tools/parallel_lane_assertion.py | 450 | tool-rewritten | help="Path to docs/features/parallel/<slug>/parallel.md", |
| scripts/dev_tools/parallel_manifest_contract.py | 5 | tool-rewritten | ``docs/features/parallel/<slug>/parallel.md`` -- spec invariants M1 through |
| scripts/dev_tools/plan_gate_discrimination.py | 61 | tool-rewritten | # in docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in- |
| scripts/dev_tools/plan_gate_observability.py | 60 | tool-rewritten | # counts recorded in docs/features/active/2026-08-23-plan-acceptance-gates-miss- |
| scripts/dev_tools/plan_progress_report.py | 1 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | """Generate a markdown report of incomplete plan checkboxes under docs/features/active. |
| scripts/dev_tools/plan_progress_report.py | 72 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | active_root: Root directory (typically docs/features/active). |
| scripts/dev_tools/plan_progress_report.py | 140 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | active_root: Root directory (docs/features/active). |
| scripts/dev_tools/plan_progress_report.py | 198 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | active_root: Root directory (docs/features/active). |
| scripts/dev_tools/plan_progress_report.py | 249 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | A markdown link string, e.g. `[plan](../docs/features/active/.../plan.md)`. |
| scripts/dev_tools/plan_progress_report.py | 320 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | active_root: Root directory (docs/features/active). |
| scripts/dev_tools/plan_progress_report.py | 346 | STAY_ENTRIES (scripts/dev_tools/plan_progress_report.py) | "Scan docs/features/active for plan.md / plan.*.md and report " |
| scripts/dev_tools/potential_to_issue.py | 173 | STAY_ENTRIES (scripts/dev_tools/potential_to_issue.py) | The resolved root, ``docs/features`` or ``.dev``. |
| scripts/dev_tools/potential_to_issue_content.py | 18 | STAY_ENTRIES (scripts/dev_tools/potential_to_issue_content.py) | DEFAULT_ACTIVE_AREA = "docs/features/active" |
| scripts/dev_tools/potential_to_issue_content.py | 243 | STAY_ENTRIES (scripts/dev_tools/potential_to_issue_content.py) | ``docs/features/active``. |
| scripts/dev_tools/pr_context/render.py,cover | 210 | STAY_ENTRIES (scripts/dev_tools/pr_context/render.py,cover) | >     """Extract feature names from docs/features/active/** paths.""" |
| scripts/dev_tools/pr_context/render.py,cover | 309 | STAY_ENTRIES (scripts/dev_tools/pr_context/render.py,cover) | !     base_dir = root / "docs" / "features" / "active" |
| scripts/dev_tools/pr_context/render.py,cover | 310 | STAY_ENTRIES (scripts/dev_tools/pr_context/render.py,cover) | !     promoted_dir = root / "docs" / "features" / "potential" / "promoted" |
| scripts/dev_tools/pr_context/render_feature_excerpts.py | 105 | STAY_ENTRIES (scripts/dev_tools/pr_context/render_feature_excerpts.py) | path under ``docs/features/active/`` or ``.dev/active/`` yields its |
| scripts/dev_tools/pr_context/render_feature_excerpts.py | 131 | STAY_ENTRIES (scripts/dev_tools/pr_context/render_feature_excerpts.py) | The set of feature folder names under ``docs/features/active/`` or |
| scripts/dev_tools/schema_loading.py | 7 | tool-rewritten | requirement (``docs/features/epics/legacy-discovery-and-parity/epic.md``). |
| scripts/dev_tools/validate_evidence_locations.py | 61 | STAY_ENTRIES (scripts/dev_tools/validate_evidence_locations.py) | research = development_docs_relative_path(docs_root, "research") |
| scripts/harness-generation/sources/agents/epic-orchestrator.json | 19 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.json) | "value": "\n  - \"Agent(orchestrator)\"\n  - \"Agent(pr-author)\"\n  - Read\n  - Grep\n  - Glob\n  - \"Write(docs/features/epics/**)\"\n  -  |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 36 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | (`docs/features/epics/<epic-slug>/epic.md`). |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 58 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | `docs/features/epics/<epic-slug>/epic-kickoff.md` from that ref — for example |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 59 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | `git show origin/epic/<epic-slug>-integration:docs/features/epics/<epic-slug>/epic-kickoff.md`, or |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 61 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | `git cat-file -e epic/<epic-slug>-integration:docs/features/epics/<epic-slug>/epic-kickoff.md` — |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 159 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | Maintain `docs/features/epics/<epic-slug>/epic-status.md` as a human-readable projection of the |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 176 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | 3. `docs/features/epics/<epic-slug>/epic-status.md` reflects the completed state. |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 221 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | For `epic-run`, require `docs/features/epics/<slug>/epic-kickoff.md`. Validate its invocation |
| scripts/harness-generation/sources/agents/epic-orchestrator.md | 277 | STAY_ENTRIES (scripts/harness-generation/sources/agents/epic-orchestrator.md) | `docs/features/epics/<slug>/epic-status.md` from that checkpoint at kickoff, every feature status |
| scripts/harness-generation/sources/agents/epic-planner.json | 19 | child 2 set via generator family: tool-protected Write( glob or (docs/features or .dev) matcher union; generated output in child 2 list | "value": "\n  - \"Agent(orchestrator)\"\n  - Read\n  - Grep\n  - Glob\n  - \"Write(docs/features/epics/**)\"\n  - \"Write(.dev/epics/**)\"\n |
| scripts/harness-generation/sources/agents/epic-planner.md | 83 | tool-rewritten | `docs/features/epics/<epic-slug>/epic-kickoff.md` (the `artifacts/` tree is gitignored). The |
| scripts/harness-generation/sources/agents/epic-planner.md | 111 | tool-rewritten | 1. The epic manifest at `docs/features/epics/<epic-slug>/epic.md` parses against the |
| scripts/harness-generation/sources/agents/epic-review.json | 19 | child 2 set via generator family: tool-protected Write( glob or (docs/features or .dev) matcher union; generated output in child 2 list | "value": "\n  - Read\n  - Grep\n  - Glob\n  - \"Write(/docs/features/**)\"\n  - \"Write(/.dev/**)\"" |
| scripts/harness-generation/sources/agents/epic-review.json | 31 | child 2 set via generator family: tool-protected Write( glob or (docs/features or .dev) matcher union; generated output in child 2 list | "value": "\n  SubagentStop:\n    - matcher: \"epic-review\"\n      hooks:\n        - type: command\n          command: pwsh -NoProfile -File |
| scripts/harness-generation/sources/agents/epic-review.md | 10 | tool-rewritten | - `docs/features/epics/<epic>/epic-audit.<timestamp>.md` |
| scripts/harness-generation/sources/agents/epic-review.md | 17 | tool-rewritten | - `epic-audit-path: docs/features/epics/<epic>/epic-audit.<timestamp>.md` |
| scripts/harness-generation/sources/agents/epic-review.md | 55 | child 2 set via generator family: tool-protected Write( glob, both roots listed; generated output in child 2 list | - "Write(/docs/features/**)" |
| scripts/harness-generation/sources/agents/feature-review.json | 15 | tool-rewritten | "value": " Feature branch review specialist that produces policy-audit, code-review, and feature-audit artifacts restricted to docs/features |
| scripts/harness-generation/sources/agents/feature-review.json | 19 | child 2 set via generator family: tool-protected Write( glob, both roots listed; generated output in child 2 list | "value": "\n  - Read\n  - Grep\n  - Glob\n  - \"Bash(git diff *)\"\n  - \"Bash(git log *)\"\n  - \"Write(/docs/features/active/**)\"\n  - \" |
| scripts/harness-generation/sources/agents/feature-review.md | 10 | tool-rewritten | When the active review scope is a selected version folder such as `docs/features/active/<feature>/v2/`, write review artifacts into that sel |
| scripts/harness-generation/sources/agents/feature-review.md | 12 | tool-rewritten | 1. `docs/features/active/<feature-or-selected-version>/policy-audit.<timestamp>.md` — policy compliance audit with PASS/PARTIAL/FAIL verdict |
| scripts/harness-generation/sources/agents/feature-review.md | 13 | tool-rewritten | 2. `docs/features/active/<feature-or-selected-version>/code-review.<timestamp>.md` — code quality review covering best practices |
| scripts/harness-generation/sources/agents/feature-review.md | 14 | tool-rewritten | 3. `docs/features/active/<feature-or-selected-version>/feature-audit.<timestamp>.md` — acceptance criteria verification relative to baseline |
| scripts/harness-generation/sources/agents/feature-review.md | 15 | tool-rewritten | 4. For every review with at least one blocking finding, including halt (`HALT_NON_REMEDIABLE`) and wait (`AWAITING_CI`) verdicts: `docs/feat |
| scripts/harness-generation/sources/agents/feature-review.md | 32 | tool-rewritten | - `policy-audit-path: docs/features/active/<feature-or-selected-version>/policy-audit.<timestamp>.md` |
| scripts/harness-generation/sources/agents/feature-review.md | 33 | tool-rewritten | - `code-review-path: docs/features/active/<feature-or-selected-version>/code-review.<timestamp>.md` |
| scripts/harness-generation/sources/agents/feature-review.md | 34 | tool-rewritten | - `feature-audit-path: docs/features/active/<feature-or-selected-version>/feature-audit.<timestamp>.md` |
| scripts/harness-generation/sources/agents/feature-review.md | 35 | tool-rewritten | - When remediation inputs are produced: `remediation-inputs-path: docs/features/active/<feature-or-selected-version>/remediation-inputs.<tim |
| scripts/harness-generation/sources/agents/feature-review.md | 192 | tool-rewritten | description: Feature branch review specialist that produces policy-audit, code-review, and feature-audit artifacts restricted to docs/featur |
| scripts/harness-generation/sources/agents/feature-review.md | 199 | child 2 set via generator family: tool-protected Write( glob, both roots listed; generated output in child 2 list | - "Write(/docs/features/active/**)" |
| scripts/harness-generation/sources/agents/feature-review.md | 218 | tool-rewritten | When the active review scope is a selected version folder such as `docs/features/active/<feature>/v2/`, write review artifacts into that sel |
| scripts/harness-generation/sources/agents/feature-review.md | 220 | tool-rewritten | 1. `docs/features/active/<feature-or-selected-version>/policy-audit.<timestamp>.md` — policy compliance audit with PASS/PARTIAL/FAIL verdict |
| scripts/harness-generation/sources/agents/feature-review.md | 221 | tool-rewritten | 2. `docs/features/active/<feature-or-selected-version>/code-review.<timestamp>.md` — code quality review covering best practices |
| scripts/harness-generation/sources/agents/feature-review.md | 222 | tool-rewritten | 3. `docs/features/active/<feature-or-selected-version>/feature-audit.<timestamp>.md` — acceptance criteria verification relative to baseline |
| scripts/harness-generation/sources/agents/feature-review.md | 223 | tool-rewritten | 4. If remediation is needed: `docs/features/active/<feature-or-selected-version>/remediation-inputs.<timestamp>.md` with explicit remediatio |
| scripts/harness-generation/sources/agents/orchestrator.md | 39 | tool-rewritten | - **Epic outcome**: the objective names or references an epic manifest (`docs/features/epics/<epic-slug>/epic.md`) or explicitly requests mu |
| scripts/harness-generation/sources/agents/orchestrator.md | 50 | tool-rewritten | - `task-researcher` — performs deep research and writes findings to the research path the orchestrator resolves before delegating: `docs/fea |
| scripts/harness-generation/sources/agents/orchestrator.md | 309 | tool-rewritten | - For issue #306, the canonical existing plan path is `docs/features/active/2026-07-04-codex-agent-role-config-306/plan.2026-07-04T13-47.md` |
| scripts/harness-generation/sources/agents/prd-feature.json | 19 | child 2 set via generator family: tool-protected Write( glob or (docs/features or .dev) matcher union; generated output in child 2 list | "value": "\n  - Read\n  - Grep\n  - Glob\n  - \"Write(/docs/features/active/**)\"\n  - \"Write(/.dev/active/**)\"" |
| scripts/harness-generation/sources/agents/prd-feature.json | 31 | child 2 set via generator family: tool-protected Write( glob or (docs/features or .dev) matcher union; generated output in child 2 list | "value": "\n  SubagentStop:\n    - matcher: \"prd-feature\"\n      hooks:\n        - type: command\n          command: pwsh -NoProfile -File |
| scripts/harness-generation/sources/agents/prd-feature.md | 10 | tool-rewritten | - `docs/features/active/<feature>/spec.md` |
| scripts/harness-generation/sources/agents/prd-feature.md | 11 | tool-rewritten | - `docs/features/active/<feature>/user-story.md` |
| scripts/harness-generation/sources/agents/prd-feature.md | 20 | tool-rewritten | - `spec-path: docs/features/active/<feature>/spec.md` |
| scripts/harness-generation/sources/agents/prd-feature.md | 21 | tool-rewritten | - `user-story-path: docs/features/active/<feature>/user-story.md` |
| scripts/harness-generation/sources/agents/prd-feature.md | 22 | tool-rewritten | - `research-path: docs/features/active/<feature>/research/<timestamp>-<short-name>-research.md` when numeric acceptance criteria are present |
| scripts/harness-generation/sources/agents/prd-feature.md | 62 | child 2 set via generator family: tool-protected Write( glob, both roots listed; generated output in child 2 list | - "Write(/docs/features/active/**)" |
| scripts/harness-generation/sources/agents/prd-feature.md | 76 | tool-rewritten | - `docs/features/active/<feature>/spec.md` |
| scripts/harness-generation/sources/agents/prd-feature.md | 77 | tool-rewritten | - `docs/features/active/<feature>/user-story.md` |
| scripts/harness-generation/sources/agents/status-updater.json | 19 | child 2 set via generator family: tool-protected Write( glob or (docs/features or .dev) matcher union; generated output in child 2 list | "value": "\n  - Read\n  - Grep\n  - Glob\n  - \"Write(/artifacts/**)\"\n  - \"Write(/docs/features/**)\"\n  - \"Write(/.dev/**)\"" |
| scripts/harness-generation/sources/agents/status-updater.md | 56 | child 2 set via generator family: tool-protected Write( glob or (docs/features or .dev) matcher union; generated output in child 2 list | - "Write(/docs/features/**)" |
| scripts/harness-generation/sources/agents/task-researcher.json | 11 | tool-rewritten | "value": " Research specialist that performs deep investigation and writes structured findings to the orchestrator-supplied research path un |
| scripts/harness-generation/sources/agents/task-researcher.json | 19 | child 2 set via generator family: tool-protected Write( glob, both roots listed; generated output in child 2 list | "value": "\n  - Read\n  - Grep\n  - Glob\n  - WebFetch\n  - \"Write(/docs/features/**/research/**)\"\n  - \"Write(/.dev/**/research/**)\"\n  |
| scripts/harness-generation/sources/agents/task-researcher.md | 12 | tool-rewritten | - Feature-associated research: `docs/features/<feature>/research/<timestamp>-<short-name>-research.md` (for example `docs/features/active/<f |
| scripts/harness-generation/sources/agents/task-researcher.md | 13 | tool-rewritten | - One-off research not tied to a feature: `docs/research/<timestamp>-<short-name>-research.md`. |
| scripts/harness-generation/sources/agents/task-researcher.md | 60 | tool-rewritten | - Feature-associated research (a research path under `docs/features/`) MUST carry a `## Pre-Mortem` section with one bullet beginning with e |
| scripts/harness-generation/sources/agents/task-researcher.md | 61 | tool-rewritten | - One-off research under `docs/research/` is exempt. |
| scripts/harness-generation/sources/agents/task-researcher.md | 67 | tool-rewritten | - Write only to the orchestrator-supplied research path under `docs/features/<feature>/research/` (feature-associated) or `docs/research/` ( |
| scripts/harness-generation/sources/rules/orchestrator-state.md | 319 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | / `potential_record` / When waiving a promotion-entry tool: required when `origin` is `epic_decomposition`, optional when `origin` is `trans |
| scripts/harness-generation/sources/rules/orchestrator-state.md | 320 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | / `feature_folder_record` / Required when `waived_tools` includes `new_active_feature_folder`, and validated whenever it is an object: `{ pa |
| scripts/harness-generation/sources/rules/orchestrator-state.md | 335 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | - 11a. `path` must be a string that fully matches `^docs/features/active/[A-Za-z0-9][A-Za-z0-9._-]*(/[A-Za-z0-9][A-Za-z0-9._-]*)*$`, so dot  |
| scripts/harness-generation/sources/rules/orchestrator-state.md | 343 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | A lifecycle record moved to `docs/features/potential/promoted/` satisfies the `potential_record` path rule, because the rule checks only the |
| scripts/harness-generation/sources/rules/parallel-orchestration.json | 8 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | "value": "\n  - \"artifacts/orchestration/parallel-*\"\n  - \"docs/features/parallel/**\"\n  - \"scripts/dev_tools/*parallel*\"\n  - \"exten |
| scripts/harness-generation/sources/rules/parallel-orchestration.md | 5 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | This rule governs the three artifacts of the `parallel` orchestration surface: the parallel-run manifest at `docs/features/parallel/<slug>/p |
| scripts/harness-generation/sources/rules/parallel-orchestration.md | 267 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | **Durable scheduling record.** `docs/features/parallel/<slug>/parallel-scheduling.json`, committed on `parallel/<slug>-plan`, carries `schem |
| scripts/harness-generation/sources/rules/parallel-orchestration.md | 321 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | token whose final component names a directory rather than a file, a `docs/features/` glob whose |
| scripts/harness-generation/sources/rules/parallel-orchestration.md | 701 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | that starts with `docs/features/`, ends with `/**`, and carries no other wildcard (the feature-folder |
| scripts/harness-generation/sources/rules/parallel-orchestration.md | 848 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | - The TypeScript parity port at `extensions/drm-copilot/src/lib/validate/parallel-state-shared.ts`, `parallel-state-structures.ts`, `paralle |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.json | 8 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | "value": "\n  - \"scripts/dev_tools/plan_gate_*\"\n  - \"scripts/dev_tools/validate_orchestration_artifacts.py\"\n  - \"extensions/drm-copil |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 65 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | The measurement is recorded in `docs/features/completed/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/evidence/qa-gat |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 87 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | The four severities below were fixed by one corpus measurement recorded in `docs/features/completed/2026-08-23-plan-acceptance-gates-miss-un |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 91 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | The measurement scanned 194 plan files under `docs/features`, covering the `active`, `completed`, and `archive` trees. Unlike the G5 measure |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 110 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | Counts, and every one of the 22 false positives named by plan path, task identifier, and offending span: `docs/features/completed/2026-08-23 |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 120 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | Counts, and every one of the 7 false positives named by plan path, task identifier, and offending span: `docs/features/completed/2026-08-23- |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 128 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | Counts, the zero false-positive record, and the three sub-classes with their plan paths and offending spans: `docs/features/completed/2026-0 |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 136 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | Counts, and every one of the 4 false positives named by plan path, task identifier, offending span, and the reason its acceptance condition  |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 155 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | The measurement is recorded in `docs/features/archive/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/evidence/qa-gates/g10-corpus- |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 189 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | G13 reports a plan above 20 canonical task lines or 250 physical lines that carries no `## Size Justification` section with content. The fir |
| scripts/harness-generation/sources/rules/plan-acceptance-gates.md | 205 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | The corpus measurement informed the false-positive class list and did not decide the channel. It is recorded in `docs/features/archive/2026- |
| scripts/harness-generation/sources/skills/epic-plan.substitutions.json | 26 | tool-rewritten | "find": "1. Define `docs/features/epics/<epic-slug>/` and author `epic.md` using the manifest schema in\n   `epic-orchestrate`.\n2. Record g |
| scripts/harness-generation/sources/skills/epic-plan.substitutions.json | 27 | tool-rewritten | "replace": "1. Define the epic slug and epic home `docs/features/epics/<epic-slug>/`.\n2. Author `docs/features/epics/<epic-slug>/epic.md` u |
| scripts/harness-generation/sources/skills/epic-plan.substitutions.json | 31 | tool-rewritten | "find": "## Integration Branch\n\nCreate or reuse `epic/<epic-slug>-integration` from `origin/main`, push it, and commit the epic\nhome befo |
| scripts/harness-generation/sources/skills/epic-plan.substitutions.json | 32 | tool-rewritten | "replace": "## Integration Branch Lifecycle\n\n1. Before any preparation delegation, create the integration branch off the tip of `main` if  |
| scripts/harness-generation/sources/skills/epic-plan.substitutions.json | 41 | tool-rewritten | "find": "Do not emit a kickoff until the manifest is valid, the checkpoint has a forced `epic-planner`\ntopology receipt, and every child ha |
| scripts/harness-generation/sources/skills/epic-plan.substitutions.json | 42 | tool-rewritten | "replace": "Do not emit a kickoff until the manifest is valid and every child has a promoted issue, active\nfolder, `issue.md`, research, `s |
| scripts/harness-generation/sources/skills/epic-plan.substitutions.json | 51 | tool-rewritten | "find": "docs/features/epics/<epic-slug>/epic.md. Reuse epic/<epic-slug>-integration. Every child resumes\nat atomic execution from its comm |
| scripts/harness-generation/sources/skills/epic-plan.substitutions.json | 52 | tool-rewritten | "replace": "docs/features/epics/<epic-slug>/epic.md. The integration branch\nepic/<epic-slug>-integration already contains every prepared fe |
| scripts/harness-generation/sources/skills/epic-plan.substitutions.json | 57 | tool-rewritten | "replace": "The `## Invocation Prompt` section is the exact text the user replays (from the main session,\nnever from an `orchestrator` agen |
| scripts/harness-generation/sources/skills/evidence-and-timestamp-conventions.substitutions.json | 6 | tool-rewritten | "find": "Research output is not an `artifacts/` sub-path. Use `docs/features/<feature>/research/` for feature-associated research or `docs/r |
| scripts/harness-generation/sources/skills/feature-promotion-lifecycle.substitutions.json | 27 | tool-rewritten | "replace": "- the promoted record under `docs/features/potential/promoted/` is still present (see 4b)\n- if any check fails, stop and remedi |
| scripts/harness-generation/sources/skills/research-issue.substitutions.json | 7 | tool-rewritten | "replace": "description: Investigate the best implementation approach for a feature or bug by analyzing the codebase and external references |
| scripts/harness-generation/sources/skills/research-issue.substitutions.json | 11 | tool-rewritten | "find": "Create or update a single research file in the applicable tracked research root:\n\n- Feature-associated path: `docs/features/<feat |
| scripts/harness-generation/sources/skills/research-issue.substitutions.json | 12 | tool-rewritten | "replace": "Create or update a single research file at one of the two tracked research roots:\n\n- Feature-associated research: `docs/featur |
| .claude/lib/docs/DocsFinding.psm1 | 252 | STAY_ENTRIES (**/.claude/lib/docs/DocsFinding.psm1) | 'docs'. |
| .claude/lib/docs/DocsFinding.psm1 | 270 | STAY_ENTRIES (**/.claude/lib/docs/DocsFinding.psm1) | $name = if ([string]::IsNullOrEmpty($CommandResult.Command)) { 'docs' } else { [string] $CommandResult.Command } |
| .claude/lib/file-size-policy/FileSizePolicy.psm1 | 67 | STAY_ENTRIES (**/.claude/lib/file-size-policy/FileSizePolicy.psm1) | return [string[]]@('.git', 'node_modules', 'artifacts', 'coverage', 'dist', 'out', 'virtual', 'docs', |
| .codex/hooks/file-size-policy.ps1 | 58 | STAY_ENTRIES (**/.codex/hooks/file-size-policy.ps1) | return [string[]]@('.git', 'node_modules', 'artifacts', 'coverage', 'dist', 'out', 'virtual', 'docs', |
| extensions/drm-copilot/src/lib/development-docs-migration/migration-apply.ts | 96 | STAY_ENTRIES (extensions/drm-copilot/src/lib/development-docs-migration/**) | deps.fileSystem.ensureDir(joinRoot(deps.workspaceRoot, "docs")); |
| extensions/drm-copilot/src/lib/pr-context/models.ts | 41 | STAY_ENTRIES (extensions/drm-copilot/src/lib/pr-context/models.ts) | "docs", |
| extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts | 94 | STAY_ENTRIES (extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts) | "docs", |
| extensions/drm-copilot/src/repo-automation-service.ts | 148 | STAY_ENTRIES (extensions/drm-copilot/src/repo-automation-service.ts) | private readonly docsOptions: RepoAutomationServiceOptions["docs"]; |
| scripts/dev_tools/pr_context/models.py | 18 | STAY_ENTRIES (scripts/dev_tools/pr_context/models.py) | "docs", |
| scripts/dev_tools/pr_context/render.py,cover | 216 | STAY_ENTRIES (scripts/dev_tools/pr_context/render.py,cover) | !             and parts[0] == "docs" |
| scripts/dev_tools/push_down_claude_blast_radius_derive_manifests.py | 118 | STAY_ENTRIES (scripts/dev_tools/push_down_claude_blast_radius_derive_manifests.py) | "docs", |
| scripts/harness-generation/sources/rules/mermaid.json | 43 | STAY_ENTRIES (scripts/harness-generation/sources/rules/**) | "docs" |
