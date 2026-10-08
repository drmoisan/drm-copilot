---
parallel: "bug-burndown-2026-10-08"
mode: "closed"
max_concurrency: 4
created_at: "2026-10-08T17:51:45Z"
items:
  - issue_num: 543
    feature_folder: "docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/hooks/enforce-python-batch-budget.ps1"
        - "docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/**"
        - "docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/evidence/baseline/phase0-instructions-read.md"
        - "docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/issue.md"
        - "docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/plan.2026-10-08T13-56.md"
        - "docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/research/research.2026-10-08T14-00.md"
        - "docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/spec.md"
        - "extensions/drm-copilot/package.json"
        - "extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts"
        - "extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts"
        - "extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts"
        - "extensions/drm-copilot/src/mcp-tool-definitions.ts"
        - "extensions/drm-copilot/src/mcp-tool-inputs.ts"
        - "extensions/drm-copilot/test/lib/json-config.test.ts"
        - "extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts"
        - "extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts"
        - "extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts"
        - "extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts"
        - "extensions/drm-copilot/test/mcp-repo-automation-tool-definitions.test.ts"
        - "extensions/drm-copilot/test/mcp-server-epic-validation.test.ts"
        - "extensions/drm-copilot/tsconfig.json"
        - "scripts/dev_tools/validate_epic_planner_state.py"
        - "scripts/dev_tools/validate_orchestration_artifacts.py"
        - "tests/scripts/dev_tools/test_epic_planner_readiness.py"
        - "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py"
        - "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py"
        - "tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py"
        - "tests/scripts/dev_tools/test_validate_epic_planner_state.py"
      modules: []
      shared_surfaces:
        - "scripts/dev_tools/validate_epic_planner_state.py"
        - "scripts/dev_tools/validate_orchestration_artifacts.py"
      contracts:
        - "epic-planner-state"
        - "topology_receipt"
      source: "declared"
      computed_at: "10/08/2026 18:46:33"
  - issue_num: 790
    feature_folder: "docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "./src/lib/push-down/claude-customizations.ts"
        - "./src/lib/push-down/claude-filesystem-adapter.ts"
        - ".claude/hooks/enforce-python-batch-budget.ps1"
        - "docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/**"
        - "docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/issue.md"
        - "docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md"
        - "docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/research/2026-10-08T18-00-python-push-down-divergence-research.md"
        - "docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/spec.md"
        - "docs/features/potential/promoted/2026-09-29-issue-507-python-push-down-divergence-follow-ups.md"
        - "extensions/drm-copilot/jest.config.cjs"
        - "extensions/drm-copilot/package-lock.json"
        - "extensions/drm-copilot/package.json"
        - "extensions/drm-copilot/src/lib/push-down/claude-customizations.ts"
        - "extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts"
        - "extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts"
        - "extensions/drm-copilot/test/lib/push-down/claude-filesystem-adapter.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/claude-gitignore-delivery.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts"
        - "scripts/dev_tools/push_down_claude_customizations.py"
        - "scripts/dev_tools/push_down_claude_exclusion_filter.py"
        - "scripts/dev_tools/push_down_claude_filesystem.py"
        - "scripts/dev_tools/push_down_claude_gitignore_merge.py"
        - "scripts/dev_tools/push_down_claude_pack_selection.py"
        - "scripts/dev_tools/push_down_codex_and_agents_customizations.py"
        - "scripts/dev_tools/push_down_codex_filesystem.py"
        - "scripts/dev_tools/push_down_copilot_customizations_filesystem.py"
        - "scripts/dev_tools/push_down_copilot_customizations.py"
        - "tests/fixtures/push_down_exclusions/plan-corpus.json"
        - "tests/fixtures/push_down/gitignore-merge-parity.json"
        - "tests/scripts/dev_tools/test_push_down_claude_customizations.py"
        - "tests/scripts/dev_tools/test_push_down_claude_exclusion_filter.py"
        - "tests/scripts/dev_tools/test_push_down_claude_gitignore_delivery.py"
        - "tests/scripts/dev_tools/test_push_down_claude_gitignore_merge.py"
        - "tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py"
        - "tests/scripts/dev_tools/test_push_down_claude_pack_selection.py"
        - "tests/scripts/dev_tools/test_push_down_claude_parity.py"
        - "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py"
      modules: []
      shared_surfaces:
        - "extensions/drm-copilot/package-lock.json"
      contracts:
        - ".gitignore"
      source: "declared"
      computed_at: "10/08/2026 19:05:11"
  - issue_num: 791
    feature_folder: "docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/agents/parallel-orchestrator.md"
        - ".claude/agents/parallel-planner.md"
        - ".claude/hooks/enforce-parallel-abandon-gate.ps1"
        - ".claude/hooks/hook-command-scanner.ps1"
        - ".claude/lib/bash/compute-cohorts.sh"
        - ".claude/lib/bash/parallel-mutation.sh"
        - ".claude/lib/bash/remove-parallel-item.sh"
        - ".claude/settings.json"
        - ".claude/skills/parallel-add/SKILL.md"
        - ".claude/skills/parallel-close/SKILL.md"
        - ".claude/skills/parallel-orchestrate/SKILL.md"
        - ".claude/skills/parallel-plan/SKILL.md"
        - ".claude/skills/parallel-remove/SKILL.md"
        - ".github/workflows/_shell-coverage.yml"
        - "docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/**"
        - "docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/follow-ups.md"
        - "docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/plan.2026-10-08T13-56.md"
        - "docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/spec.md"
        - "docs/features/potential/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups.md"
        - "docs/features/potential/promoted/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-mutation.sh"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/remove-parallel-item.sh"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/settings.json"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-remove/SKILL.md"
        - "extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json"
        - "extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts"
        - "scripts/dev_tools/_parallel_mutation_errors.py"
        - "scripts/dev_tools/parallel_cohort_computation.py"
        - "scripts/dev_tools/parallel_mutation_protocol.py"
        - "scripts/dev_tools/skill_bundle_contract.py"
        - "tests/fixtures/parallel_mutation_remove/decide-in-flight-abandon.json"
        - "tests/fixtures/parallel_mutation_remove/decide-in-flight-detach.json"
        - "tests/fixtures/parallel_mutation_remove/decide-in-flight-no-disposition.json"
        - "tests/fixtures/parallel_mutation_remove/decide-merged.json"
        - "tests/fixtures/parallel_mutation_remove/decide-scheduled.json"
        - "tests/fixtures/parallel_mutation_remove/decide-unknown-item.json"
        - "tests/fixtures/parallel_mutation_remove/entry-disposition-on-unstarted.json"
        - "tests/fixtures/parallel_mutation_remove/entry-in-flight-detach.json"
        - "tests/fixtures/parallel_mutation_remove/entry-negative-generation.json"
        - "tests/fixtures/parallel_mutation_remove/entry-unstarted-recompute.json"
        - "tests/fixtures/parallel_mutation_remove/recolor-empty-unstarted.json"
        - "tests/fixtures/parallel_mutation_remove/recolor-negative-current-cohort.json"
        - "tests/fixtures/parallel_mutation_remove/recolor-no-pinned-edge.json"
        - "tests/fixtures/parallel_mutation_remove/recolor-overlap.json"
        - "tests/fixtures/parallel_mutation_remove/recolor-pinned-edge-offset.json"
        - "tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1"
        - "tests/scripts/claude-runtime/claude-settings.Tests.ps1"
        - "tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1"
        - "tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py"
        - "tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py"
        - "tests/scripts/dev_tools/test_skill_bundle_contract_repo.py"
        - "tests/scripts/dev_tools/test_skill_bundle_contract.py"
        - "tests/shell/parallel_bash_manifest_membership.bats"
        - "tests/shell/parallel_mutation_remove_parity.bats"
        - "tests/shell/parallel_mutation_remove.bats"
        - "tests/shell/parallel_payload_only.bats"
      modules: []
      shared_surfaces:
        - ".claude/settings.json"
      contracts:
        - "parallel-remove"
      source: "declared"
      computed_at: "10/08/2026 21:38:36"
  - issue_num: 793
    feature_folder: "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "docs/features/active/2026-09-28-handoff-test-depends-on-archived-active-dir-765/evidence/baseline/baseline-pytest-coverage.2026-09-28T19-35.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/**"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-base-ref.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-line-counts.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-npm-ci.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-preconditions.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-python-black.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-python-pyright.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-python-pytest-coverage.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-python-ruff.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-python-wave-barrier-pytest.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-repro-completion-list.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-repro-enum-dict.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-repro-enum-list.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-ts-eslint.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-ts-jest-coverage.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-ts-prettier.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/p0-ts-typecheck.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/baseline/phase0-instructions-read.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/changed-lines-coverage.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/coverage-delta.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/final-python-black.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/final-python-pyright.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/final-python-pytest-coverage.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/final-python-ruff.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/final-python-wave-barrier-pytest.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/final-ts-eslint.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/final-ts-jest-coverage.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/final-ts-jest-new-file.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/final-ts-prettier.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/final-ts-typecheck.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/line-counts.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/qa-gates/scope-check.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/regression-testing/fail-before-python.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/regression-testing/guard-literal-count.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/regression-testing/pass-after-python.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/regression-testing/repro-after-completion-list.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/regression-testing/repro-after-enum-dict.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/regression-testing/repro-after-enum-list.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/evidence/regression-testing/ts-parity-new-file.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/issue.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/plan.2026-10-08T13-57.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/research/research.2026-10-08T14-00.md"
        - "docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/spec.md"
        - "docs/features/potential/promoted/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status.md"
        - "extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts"
        - "extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-merge-status.test.ts"
        - "extensions/drm-copilot/tsconfig.jest.json"
        - "scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py"
        - "scripts/dev_tools/validate_epic_orchestrator_state.py"
        - "scripts/dev_tools/validate_epic_orchestrator_state.py:2"
        - "src/lib/validate/epic-orchestrator-state-core.ts"
        - "tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py"
        - "tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py"
      modules: []
      shared_surfaces:
        - "scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py"
        - "scripts/dev_tools/validate_epic_orchestrator_state.py"
      contracts:
        - "merge_status"
      source: "declared"
      computed_at: "10/08/2026 18:23:48"
  - issue_num: 794
    feature_folder: "parallel-cohorts-split-words-drops-tokens-after-first-newline"
    kind: "bug"
    state: "admitted"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 796
    feature_folder: "duplicated-string-comparators-outside-pr-context"
    kind: "bug"
    state: "admitted"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 797
    feature_folder: "blast-radius-path-extractor-misses-real-plan-writes"
    kind: "bug"
    state: "admitted"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 798
    feature_folder: "orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails"
    kind: "bug"
    state: "admitted"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 824
    feature_folder: "issue-823-tier-rule-adoption-follow-ups"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 841
    feature_folder: "ci-gate-vacuous-on-empty-check-list"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 842
    feature_folder: "cleanup-worktrees-scan-root-derivation-follow-ups"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 843
    feature_folder: "parallel-model-routing-admitted-item-source-and-absent-band-test"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 844
    feature_folder: "handoff-failure-cause-fallback-and-name-gaps"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 845
    feature_folder: "npm-token-guard-comparison-false-positive-and-stale-docstring"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 846
    feature_folder: "bug-burndown-2026-09-29-review-nits"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 847
    feature_folder: "powershell-aggregate-line-coverage-below-floor"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 848
    feature_folder: "root-format-check-fails-on-test-fixtures"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
  - issue_num: 849
    feature_folder: "parallel-items-fail-completion-on-promotion-receipts"
    kind: "bug"
    state: "proposed"
    blast_radius:
      paths: []
      modules: []
      shared_surfaces: []
      contracts: []
      source: "derived"
      computed_at: "10/08/2026 17:51:45"
---

# Parallel Run: bug-burndown-2026-10-08

Run branch: `parallel/bug-burndown-2026-10-08-plan`. Each item opens its own pull request against `main`; this branch is not an integration branch.

| group | issue_num | state | band | branch | plan-path |
| --- | --- | --- | --- | --- | --- |
| P1 | 797 | admitted |  | bug/blast-radius-path-extractor-misses-real-plan-writes-797 |  |
| P2 | 794 | admitted |  | bug/parallel-cohorts-split-words-drops-tokens-after-first-newline-794 |  |
| P3 | 793 | prepared | C2 | bug/epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793 | docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/plan.2026-10-08T13-57.md |
| P4 | 798 | admitted |  | bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798 |  |
| P5 | 849 | proposed |  | bug/parallel-items-fail-completion-on-promotion-receipts-849 |  |
| P6 | 843 | proposed |  | bug/parallel-model-routing-admitted-item-source-and-absent-band-test-843 |  |
| P7 | 790 | prepared | C3 | bug/issue-507-python-push-down-divergence-follow-ups-790 | docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md |
| P8 | 791 | prepared | C3 | bug/issue-763-parallel-skill-cli-port-follow-ups-791 | docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/plan.2026-10-08T13-56.md |
| P9 | 796 | admitted |  | bug/duplicated-string-comparators-outside-pr-context-796 |  |
| P10 | 844 | proposed |  | bug/handoff-failure-cause-fallback-and-name-gaps-844 |  |
| P11 | 845 | proposed |  | bug/npm-token-guard-comparison-false-positive-and-stale-docstring-845 |  |
| P12 | 842 | proposed |  | bug/cleanup-worktrees-scan-root-derivation-follow-ups-842 |  |
| P13 | 848 | proposed |  | bug/root-format-check-fails-on-test-fixtures-848 |  |
| P14 | 847 | proposed |  | bug/powershell-aggregate-line-coverage-below-floor-847 |  |
| P15 | 841 | proposed |  | bug/ci-gate-vacuous-on-empty-check-list-841 |  |
| P16 | 824 | proposed |  | bug/issue-823-tier-rule-adoption-follow-ups-824 |  |
| P17 | 543 | prepared | C3 | bug/epic-planner-topology-receipt-gate-543 | docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/plan.2026-10-08T13-56.md |
| P18 | 846 | proposed |  | bug/bug-burndown-2026-09-29-review-nits-846 |  |
