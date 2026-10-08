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
    feature_folder: "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/lib/bash/compute-cohorts.sh"
        - ".claude/lib/bash/compute-concurrency-batches.sh"
        - ".claude/lib/bash/parallel-cohorts.sh"
        - ".claude/lib/bash/parallel-common.sh"
        - ".claude/lib/bash/parallel-items-validate.sh"
        - ".claude/lib/bash/parallel-lane-assertion.sh"
        - ".github/workflows/_shell-coverage.yml"
        - ".github/workflows/ci.yml"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/**"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/baseline/baseline-ci-run.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/baseline/baseline-shell-check-ci.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/baseline/baseline-shell-check-local.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/baseline/baseline-shell-coverage-ci.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/baseline/baseline-shell-test-ci.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/baseline/baseline-shell-test-local.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/baseline/baseline-size-and-mirror.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/baseline/phase0-instructions-read.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/baseline/preconditions.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/baseline/tool-availability.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/other/ac-gaps.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/other/ac-status-summary.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/other/spec-gap-note.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/ci-covers-final-files.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/ci-final-run.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/coverage-comparison.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-commit.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-push.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-shell-check-ci.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-shell-check-local.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-shell-coverage-ci.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-shell-format-local.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-shell-syntax.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-shell-test-ci.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/final-shell-test-local.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/size-and-hygiene.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/unchanged-files-check.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/qa-gates/write-set-check.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/bats-rows-added.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/bats-suites-after-local.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/bats-unit-after-local.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/bats-unit-before-local.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/ci-fail-first-lines.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/ci-fail-first-run.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/fail-before-exception.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/fail-first-commit.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/fail-first-push.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/fix-build-adjacency.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/mirror-updated.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/repro-after-combined.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/repro-after-edges.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/repro-after-keys.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/repro-after-malformed.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/repro-before-combined.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/repro-before-edges.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/repro-before-keys.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/repro-companion-needed-a.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/repro-companion-needed-b.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/evidence/regression-testing/repro-control.2026-10-08T21-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/plan.2026-10-08T17-25.md"
        - "docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/spec.md"
        - "docs/features/potential/promoted/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-cohorts.sh"
        - "extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json"
        - "scripts/bash/shell_qc_lib.sh"
        - "tests/shell/parallel_cohorts.bats"
      modules: []
      shared_surfaces: []
      contracts: []
      source: "declared"
      computed_at: "10/08/2026 22:10:51"
  - issue_num: 796
    feature_folder: "docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "./src/lib/string-ordering.ts"
        - "docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/**"
        - "docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/evidence/baseline/phase0-instructions-read.md"
        - "docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/issue.md"
        - "docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/research/research.2026-10-08T21-30.md"
        - "docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/spec.md"
        - "docs/features/potential/promoted/2026-09-30-duplicated-string-comparators-outside-pr-context.md"
        - "extensions/drm-copilot/jest.config.cjs"
        - "extensions/drm-copilot/package-lock.json"
        - "extensions/drm-copilot/src/lib/codex-native-converter/engine-pipeline.ts"
        - "extensions/drm-copilot/src/lib/codex-native-converter/intermediate-state.ts"
        - "extensions/drm-copilot/src/lib/codex-native-converter/inventory.ts"
        - "extensions/drm-copilot/src/lib/codex-native-converter/models.ts"
        - "extensions/drm-copilot/src/lib/codex-native-converter/pipeline-traces.ts"
        - "extensions/drm-copilot/src/lib/codex-native-converter/pipeline.ts"
        - "extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts"
        - "extensions/drm-copilot/src/lib/codex-native-converter/reporting.ts"
        - "extensions/drm-copilot/src/lib/codex-native-converter/validation.ts"
        - "extensions/drm-copilot/src/lib/pr-context/autoclose.ts"
        - "extensions/drm-copilot/src/lib/pr-context/collector-core.ts"
        - "extensions/drm-copilot/src/lib/pr-context/collector-output.ts"
        - "extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts"
        - "extensions/drm-copilot/src/lib/pr-context/feature-docs.ts"
        - "extensions/drm-copilot/src/lib/pr-context/models.ts"
        - "extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts"
        - "extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts"
        - "extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts"
        - "extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts"
        - "extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-manifests.ts"
        - "extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts"
        - "extensions/drm-copilot/src/lib/push-down/claude-blast-radius-overlay.ts"
        - "extensions/drm-copilot/src/lib/push-down/copilot-customizations-engine.ts"
        - "extensions/drm-copilot/src/lib/push-down/filesystem-adapter.ts"
        - "extensions/drm-copilot/src/lib/string-ordering.ts"
        - "extensions/drm-copilot/src/lib/subagent-tree/quick-pick-labels.ts"
        - "extensions/drm-copilot/src/lib/subagent-tree/tree-assembler.ts"
        - "extensions/drm-copilot/src/lib/validate/orchestration-handoff-contract.ts"
        - "extensions/drm-copilot/test/lib/codex-native-converter/inventory.test.ts"
        - "extensions/drm-copilot/test/lib/pr-context/collector-output-ordering.test.ts"
        - "extensions/drm-copilot/test/lib/pr-context/models.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/blast-radius-derive-manifests.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/claude-blast-radius-overlay-parity.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/copilot-customizations-engine.test.ts"
        - "extensions/drm-copilot/test/lib/push-down/filesystem-adapter.test.ts"
        - "extensions/drm-copilot/test/lib/string-ordering.test.ts"
        - "extensions/drm-copilot/test/lib/subagent-tree/module-boundary.test.ts"
        - "extensions/drm-copilot/test/lib/subagent-tree/quick-pick-labels.test.ts"
        - "extensions/drm-copilot/test/lib/subagent-tree/tree-assembler.test.ts"
        - "extensions/drm-copilot/tsconfig.jest.json"
        - "extensions/drm-copilot/tsconfig.json"
        - "src/lib/pr-context/models.ts"
        - "src/lib/string-ordering.ts"
        - "src/lib/subagent-tree/quick-pick-labels.ts"
        - "src/lib/validate/orchestration-handoff-contract.ts"
        - "tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py"
      modules: []
      shared_surfaces:
        - "extensions/drm-copilot/package-lock.json"
      contracts:
        - "compareOrdinal"
      source: "declared"
      computed_at: "10/08/2026 22:29:45"
  - issue_num: 797
    feature_folder: "docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/lib/blast-radius/BlastRadiusExtraction.psm1"
        - ".claude/lib/blast-radius/BlastRadiusTokenShape.psm1"
        - ".claude/rules/parallel-orchestration.md"
        - "docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/**"
        - "docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/plan.2026-10-08T17-24.md"
        - "docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md"
        - "docs/features/potential/promoted/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md"
        - "scripts/dev_tools/_blast_radius_extraction.py"
        - "scripts/dev_tools/_blast_radius_token_shapes.py"
        - "tests/fixtures/blast_radius/derivation-directory-shaped-rejected.json"
        - "tests/fixtures/blast_radius/derivation-file-shaped-tokens.json"
        - "tests/fixtures/blast_radius/historical-runs/backlog-2026-09-26.json"
        - "tests/fixtures/blast_radius/historical-runs/epic-655-followups.json"
        - "tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json"
        - "tests/fixtures/blast_radius/verification-integrity/verification-integrity-485-486-487.json"
        - "tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1"
        - "tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1"
        - "tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1"
        - "tests/scripts/dev_tools/test_blast_radius_extraction_rules.py"
        - "tests/scripts/dev_tools/test_blast_radius_extraction.py"
        - "tests/scripts/dev_tools/test_blast_radius_token_shapes.py"
        - "tests/scripts/dev_tools/test_blast_radius_verification_integrity.py"
      modules: []
      shared_surfaces: []
      contracts:
        - "Get-PathTokenKind"
        - "RECOGNIZED_PATH_EXTENSIONS"
        - "classify_path_token"
      source: "declared"
      computed_at: "10/08/2026 22:41:39"
  - issue_num: 798
    feature_folder: "docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/agents/orchestrator.md"
        - ".claude/hooks/validate-bash.ps1"
        - ".claude/hooks/validate-orchestrator-output.ps1"
        - ".claude/lib/orchestrator-state/OrchestratorState.psm1"
        - ".claude/rules/orchestrator-state.md"
        - ".claude/skills/orchestrate/SKILL.md"
        - "docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/**"
        - "docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/plan.2026-10-08T17-24.md"
        - "docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/research/research.2026-10-08T17-28.md"
        - "docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/spec.md"
        - "docs/features/potential/promoted/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/agents/orchestrator.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/skills/orchestrate/SKILL.md"
        - "extensions/drm-copilot/src/lib/validate/orchestrator-state-core.ts"
        - "pyproject.toml"
        - "scripts/__init__.py"
        - "scripts/dev_tools/__init__.py"
        - "scripts/dev_tools/plan_gate_observability.py"
        - "scripts/dev_tools/skill_bundle_contract.py"
        - "scripts/dev_tools/validate_orchestration_artifacts.py"
        - "scripts/dev_tools/validate_orchestrator_state.py"
        - "tests/__init__.py"
        - "tests/conftest.py"
        - "tests/fixtures/orchestrator_state_remediation_loop_backcompat/no_remediation_loop.json"
        - "tests/scripts/__init__.py"
        - "tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1"
        - "tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1"
        - "tests/scripts/dev_tools/__init__.py"
        - "tests/scripts/dev_tools/test_claude_rules_frontmatter.py"
        - "tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py"
        - "tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py"
        - "tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py"
        - "tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py"
        - "tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py"
        - "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py"
        - "tests/scripts/dev_tools/test_skill_bundle_contract_repo.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_codex_topology_cli.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts.py"
        - "tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py"
      modules: []
      shared_surfaces:
        - "scripts/dev_tools/validate_orchestration_artifacts.py"
        - "scripts/dev_tools/validate_orchestrator_state.py"
      contracts: []
      source: "declared"
      computed_at: "10/08/2026 22:48:52"
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
| P1 | 797 | prepared | C3 | bug/blast-radius-path-extractor-misses-real-plan-writes-797 | docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/plan.2026-10-08T17-24.md |
| P2 | 794 | prepared | C2 | bug/parallel-cohorts-split-words-drops-tokens-after-first-newline-794 | docs/features/active/2026-09-30-parallel-cohorts-split-words-drops-tokens-after-first-newline-794/plan.2026-10-08T17-25.md |
| P3 | 793 | prepared | C2 | bug/epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793 | docs/features/active/2026-09-30-epic-orchestrator-state-validator-crashes-on-unhashable-merge-status-793/plan.2026-10-08T13-57.md |
| P4 | 798 | prepared | C3 | bug/orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798 | docs/features/active/2026-09-30-orchestration-validator-last-updated-undocumented-and-file-path-invocation-fails-798/plan.2026-10-08T17-24.md |
| P5 | 849 | proposed |  | bug/parallel-items-fail-completion-on-promotion-receipts-849 |  |
| P6 | 843 | proposed |  | bug/parallel-model-routing-admitted-item-source-and-absent-band-test-843 |  |
| P7 | 790 | prepared | C3 | bug/issue-507-python-push-down-divergence-follow-ups-790 | docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/plan.2026-10-08T13-56.md |
| P8 | 791 | prepared | C3 | bug/issue-763-parallel-skill-cli-port-follow-ups-791 | docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/plan.2026-10-08T13-56.md |
| P9 | 796 | prepared | C3 | bug/duplicated-string-comparators-outside-pr-context-796 | docs/features/active/2026-09-30-duplicated-string-comparators-outside-pr-context-796/plan.2026-10-08T17-25.md |
| P10 | 844 | proposed |  | bug/handoff-failure-cause-fallback-and-name-gaps-844 |  |
| P11 | 845 | proposed |  | bug/npm-token-guard-comparison-false-positive-and-stale-docstring-845 |  |
| P12 | 842 | proposed |  | bug/cleanup-worktrees-scan-root-derivation-follow-ups-842 |  |
| P13 | 848 | proposed |  | bug/root-format-check-fails-on-test-fixtures-848 |  |
| P14 | 847 | proposed |  | bug/powershell-aggregate-line-coverage-below-floor-847 |  |
| P15 | 841 | proposed |  | bug/ci-gate-vacuous-on-empty-check-list-841 |  |
| P16 | 824 | proposed |  | bug/issue-823-tier-rule-adoption-follow-ups-824 |  |
| P17 | 543 | prepared | C3 | bug/epic-planner-topology-receipt-gate-543 | docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/plan.2026-10-08T13-56.md |
| P18 | 846 | proposed |  | bug/bug-burndown-2026-09-29-review-nits-846 |  |
