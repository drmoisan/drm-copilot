---
parallel: "bug-burndown-2026-10-15"
mode: "closed"
max_concurrency: 15
created_at: "2026-10-15T11:39:07Z"
items:
  - issue_num: 543
    feature_folder: "docs/features/active/epic-planner-receipt-checks-key-gate-543"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/hooks/enforce-python-batch-budget.ps1"
        - "docs/features/active/epic-planner-receipt-checks-key-gate-543/**"
        - "docs/features/active/epic-planner-receipt-checks-key-gate-543/issue.md"
        - "docs/features/active/epic-planner-receipt-checks-key-gate-543/plan.2026-10-15T07-42.md"
        - "docs/features/active/epic-planner-receipt-checks-key-gate-543/research/research.2026-10-15T08-05.md"
        - "docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md"
        - "extensions/drm-copilot/jest.config.cjs"
        - "extensions/drm-copilot/package.json"
        - "extensions/drm-copilot/run-jest.cjs"
        - "extensions/drm-copilot/src/lib/validate/epic-planner-ready-features.ts"
        - "extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts"
        - "extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts"
        - "extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts"
        - "extensions/drm-copilot/src/mcp-tool-definitions.ts"
        - "extensions/drm-copilot/src/mcp-tool-inputs.ts"
        - "extensions/drm-copilot/test/lib/validate/epic-planner-readiness-integrity.test.ts"
        - "extensions/drm-copilot/test/lib/validate/epic-planner-ready-features.test.ts"
        - "extensions/drm-copilot/test/lib/validate/epic-planner-state-core.test.ts"
        - "extensions/drm-copilot/test/lib/validate/epic-planner-state-feature-receipts.test.ts"
        - "extensions/drm-copilot/test/lib/validate/epic-planner-state-launch-binding.test.ts"
        - "extensions/drm-copilot/test/lib/validate/orchestration-artifacts.test.ts"
        - "extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call.test.ts"
        - "extensions/drm-copilot/test/mcp-server-epic-validation.test.ts"
        - "extensions/drm-copilot/tsconfig.jest.json"
        - "extensions/drm-copilot/tsconfig.json"
        - "scripts/dev_tools/_epic_orchestrator_state_launch_binding.py"
        - "scripts/dev_tools/validate_epic_planner_state.py"
        - "scripts/dev_tools/validate_orchestration_artifacts.py"
        - "src/lib/validate/epic-planner-ready-features.ts"
        - "tests/scripts/dev_tools/test_epic_planner_readiness.py"
        - "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py"
        - "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py"
        - "tests/scripts/dev_tools/test_validate_epic_planner_state_feature_receipts.py"
        - "tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py"
        - "tests/scripts/dev_tools/test_validate_epic_planner_state.py"
      modules: []
      shared_surfaces:
        - "scripts/dev_tools/_epic_orchestrator_state_launch_binding.py"
        - "scripts/dev_tools/validate_epic_planner_state.py"
        - "scripts/dev_tools/validate_orchestration_artifacts.py"
      contracts:
        - "epic-planner-state"
        - "model_routing_receipt"
        - "topology_receipt"
      source: "declared"
      computed_at: "2026-10-15T12:45:19Z"
  - issue_num: 884
    feature_folder: "docs/features/active/untouched-files-coverage-verification-884"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "docs/features/active/subagentstop-envelope-feature-review-coverage-896/evidence/baseline/pester-coverage.2026-10-11T23-30.md"
        - "docs/features/active/subagentstop-envelope-feature-review-coverage-896/policy-audit.2026-10-12T11-25.md"
        - "docs/features/active/untouched-files-coverage-verification-884/**"
        - "docs/features/active/untouched-files-coverage-verification-884/evidence/other/ci-per-file-coverage.2026-10-15T11-47.md"
        - "docs/features/active/untouched-files-coverage-verification-884/issue.md"
        - "docs/features/potential/promoted/2026-10-08-powershell-aggregate-line-coverage-below-floor.md"
      modules: []
      shared_surfaces: []
      contracts: []
      source: "declared"
      computed_at: "2026-10-15T12:01:48Z"
  - issue_num: 927
    feature_folder: "docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/hooks/check-powershell-test-purity.ps1"
        - ".claude/hooks/enforce-batch-budget-route.ps1"
        - ".claude/hooks/enforce-epic-merge-gate-authorization.ps1"
        - ".claude/hooks/enforce-epic-merge-gate-resolution.ps1"
        - ".claude/hooks/enforce-epic-merge-gate.ps1"
        - ".claude/hooks/enforce-powershell-batch-budget.ps1"
        - ".claude/hooks/enforce-pr-author-skill-helpers.ps1"
        - ".claude/hooks/enforce-pr-author-skill.docs-only.ps1"
        - ".claude/hooks/enforce-pr-author-skill.ps1"
        - ".claude/hooks/hook-command-invocation.ps1"
        - ".claude/hooks/hook-command-payload.ps1"
        - ".claude/hooks/hook-docs-only-diff.ps1"
        - ".claude/settings.json"
        - ".codex/config.toml"
        - ".codex/hooks/enforce-epic-merge-gate.ps1"
        - ".codex/hooks/hook-docs-only-diff.ps1"
        - ".github/workflows/_poshqc.yml"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/**"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct-rerun.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage-direct.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/local-powershell-coverage.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-direct-xml-regenerated.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct-rerun.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit-direct.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-pester-junit.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run-rerun.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-direct-run.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-poshqc-test-invocation.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-xml-regenerated.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-ac-state.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-scope-before-stage.2026-10-12T19-50.md"
        - "docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/issue.md"
        - "docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/**"
        - "docs/features/completed/2026-07-10-poshqc-test-terminal-output-scan-config-344/evidence/regression-testing/junit-task-post.xml"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-resolution.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.docs-only.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/hook-docs-only-diff.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-docs-only-diff.ps1"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json"
        - "scripts/dev-tools/run-actionlint.ps1"
        - "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
        - "tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-epic-merge-gate.ItemResolution.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-epic-merge-gate.WorktreeResolution.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-pr-author-skill.DocsOnly.Tests.ps1"
        - "tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1"
        - "tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1"
        - "tests/scripts/claude-hooks/hook-docs-only-diff.MergeExemption.Tests.ps1"
        - "tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1"
        - "tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1"
        - "tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1"
        - "tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1"
        - "tests/scripts/codex-hooks/hook-docs-only-diff.Tests.ps1"
      modules:
        - "codex-runtime"
        - "poshqc"
        - "powershell-dev-tools"
      shared_surfaces:
        - ".claude/settings.json"
        - "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
      contracts:
        - "DOCS_ONLY_EXEMPTION_PR_UNRESOLVED"
        - "hook-docs-only-diff.ps1"
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 928
    feature_folder: "docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".agents/skills/translate-claude-to-codex/SKILL.md"
        - ".claude/agents/epic-orchestrator.md"
        - ".claude/hooks/enforce-epic-wave-barrier.ps1"
        - ".claude/hooks/enforce-powershell-batch-budget.ps1"
        - ".claude/hooks/subagentstop-envelope.ps1"
        - ".claude/hooks/validate-discovery-artifact-gate.ps1"
        - ".claude/hooks/validate-executor-output.ps1"
        - ".claude/hooks/validate-feature-review-coverage.ps1"
        - ".claude/hooks/validate-orchestrator-output.ps1"
        - ".claude/hooks/validate-planner-output.ps1"
        - ".claude/hooks/validate-pr-author-output.ps1"
        - ".claude/hooks/validate-prd-feature-output.ps1"
        - ".claude/hooks/validate-required-artifact-output.ps1"
        - ".claude/hooks/validate-task-researcher-output.ps1"
        - ".claude/settings.json"
        - ".claude/skills/epic-orchestrate/SKILL.md"
        - ".github/workflows/_poshqc.yml"
        - "docs/engineering/claude-code-architecture.md"
        - "docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/**"
        - "docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/research/research.2026-10-15T16-10.md"
        - "docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/spec.md"
        - "docs/features/archive/subagentstop-envelope-core-897/spec.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/subagentstop-envelope.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-executor-output.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-planner-output.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-pr-author-output.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-prd-feature-output.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-required-artifact-output.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/translate-claude-to-codex/SKILL.md"
        - "scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:182"
        - "tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1"
        - "tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1"
        - "tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1"
      modules:
        - "poshqc"
      shared_surfaces:
        - ".claude/settings.json"
      contracts:
        - "core.json"
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 929
    feature_folder: "docs/features/active/subagentstop-artifact-gates-review-notes-929"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/hooks/hook-dependency-guard.ps1"
        - ".claude/hooks/subagentstop-envelope.ps1"
        - ".claude/hooks/validate-discovery-artifact-gate.ps1"
        - ".claude/hooks/validate-planner-output.ps1"
        - ".claude/hooks/validate-pr-author-output.ps1"
        - ".claude/hooks/validate-prd-feature-output.ps1"
        - ".claude/hooks/validate-task-researcher-output.ps1"
        - "config/poshqc-coverage.json"
        - "docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/research/research.2026-10-08T14-00.md"
        - "docs/features/active/subagentstop-artifact-gates-review-notes-929/**"
        - "docs/features/active/subagentstop-artifact-gates-review-notes-929/issue.md"
        - "docs/features/active/subagentstop-artifact-gates-review-notes-929/research/research.2026-10-15T19-52.md"
        - "docs/features/active/subagentstop-artifact-gates-review-notes-929/spec.md"
        - "docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1"
        - "scripts/powershell/PoshQC/PoshQC.psd1"
        - "scripts/powershell/PoshQC/PoshQC.Testing.psm1"
        - "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
        - "tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1"
        - "tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1"
        - "tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1"
        - "tests/scripts/claude-hooks/validate-discovery-artifact-gate.Dispatch.Tests.ps1"
        - "tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1"
        - "tests/scripts/claude-hooks/validate-feature-review-coverage.E4.Helpers.ps1"
        - "tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1"
        - "tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1"
        - "tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1"
        - "tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1"
        - "tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1"
        - "tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1"
        - "tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1"
        - "tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1"
        - "tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py"
        - "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py"
      modules:
        - "config"
        - "poshqc"
      shared_surfaces:
        - "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
      contracts: []
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 930
    feature_folder: "docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/**"
        - "docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/issue.md"
        - "scripts/dev-tools/HostBootstrap.psm1"
        - "scripts/host-tools.manifest.json"
        - "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
        - "tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1"
      modules:
        - "poshqc"
        - "powershell-dev-tools"
      shared_surfaces:
        - "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
      contracts: []
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 931
    feature_folder: "docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".github/workflows/_poshqc.yml"
        - ".github/workflows/ci.yml"
        - ".vscode/tasks.json"
        - "config/poshqc-coverage.json"
        - "config/poshqc-scan.json"
        - "docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/**"
        - "docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/issue.md"
        - "docs/research/2026-07-09-active-features-delivery-status-audit.md"
        - "scripts/dev-tools/Invoke-FullReleaseFlow.ps1"
        - "tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py"
        - "tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1"
        - "tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1"
        - "tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1"
        - "tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1"
      modules:
        - "config"
        - "powershell-dev-tools"
      shared_surfaces: []
      contracts: []
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 932
    feature_folder: "docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "./src/lib/validate/plan-gate-observability.ts"
        - ".claude/agents/atomic-executor.md"
        - ".claude/agents/atomic-planner.md"
        - ".claude/hooks/check-python-test-purity.ps1"
        - ".claude/hooks/validate-bash.ps1"
        - ".claude/rules/plan-acceptance-gates.md"
        - ".claude/skills/atomic-plan-contract/SKILL.md"
        - ".codex/agents/atomic-executor-c1.toml"
        - ".codex/agents/atomic-executor-c2.toml"
        - ".codex/agents/atomic-executor-c3-elevated.toml"
        - ".codex/agents/atomic-executor-c3.toml"
        - ".codex/agents/atomic-executor-c4.toml"
        - ".codex/agents/atomic-executor.toml"
        - ".codex/agents/atomic-planner-c1.toml"
        - ".codex/agents/atomic-planner-c2.toml"
        - ".codex/agents/atomic-planner-c3-elevated.toml"
        - ".codex/agents/atomic-planner-c3.toml"
        - ".codex/agents/atomic-planner-c4.toml"
        - ".codex/agents/atomic-planner.toml"
        - "docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/**"
        - "docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/spec.md"
        - "extensions/drm-copilot/coverage/coverage-summary.json"
        - "extensions/drm-copilot/coverage/lcov.info"
        - "extensions/drm-copilot/jest.config.cjs"
        - "extensions/drm-copilot/node_modules/jest/package.json"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/rules/plan-acceptance-gates.md"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/skills/atomic-plan-contract/SKILL.md"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c1.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c2.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3-elevated.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c3.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor-c4.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-executor.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c1.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c2.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3-elevated.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c3.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner-c4.toml"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/atomic-planner.toml"
        - "extensions/drm-copilot/src/lib/validate/plan-gate-discrimination.ts"
        - "extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts"
        - "extensions/drm-copilot/test/lib/validate/plan-gate-observability-boundaries.test.ts"
        - "extensions/drm-copilot/test/lib/validate/plan-gate-parity.test.ts"
        - "extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts"
        - "extensions/drm-copilot/test/lib/validate/validate-orchestration-service-call-plan-gates.test.ts"
        - "scripts/dev_tools/plan_gate_discrimination.py"
        - "scripts/dev_tools/plan_gate_scratch.py"
        - "scripts/dev_tools/pr_context/git.py"
        - "src/lib/validate/plan-gate-discrimination.ts"
        - "src/lib/validate/plan-gate-scratch.ts"
        - "tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py"
        - "tests/scripts/dev_tools/test_plan_gate_parity.py"
        - "tests/scripts/dev_tools/test_plan_gate_scratch_docs.py"
        - "tests/scripts/dev_tools/test_plan_gate_scratch.py"
        - "tests/scripts/dev_tools/test_scratch_location_contracts.py"
      modules:
        - "codex-runtime"
      shared_surfaces: []
      contracts:
        - "!r"
        - "$SCRATCH"
        - "<SCRATCH>"
        - "PLAN_GATE_TASK_RE"
        - "SCRATCH"
        - "SCRATCHPAD"
        - "X_SCRATCH"
        - "[P#-T#]"
        - "_FENCE_RE"
        - "_window_join"
        - "is"
        - "issue-<digits>"
        - "issue-<issue-num>"
        - "issue-<n>-<yyyy-MM-ddTHH-mm>"
        - "plan_gate_commands.py"
        - "pythonRepr("
        - "repr()"
        - "windowJoin"
        - "{n}"
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 933
    feature_folder: "docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/**"
        - "docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/issue.md"
        - "docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/plan.2026-10-15T17-44.md"
        - "docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/research/research.2026-10-15T17-50.md"
        - "scripts/dev_tools/check_python_coverage_thresholds.py"
        - "tests/scripts/dev_tools/npm_token_guard_test_support.py"
        - "tests/scripts/dev_tools/test_workflow_npm_token_guard.py"
      modules: []
      shared_surfaces: []
      contracts: []
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 934
    feature_folder: "docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/**"
        - "extensions/drm-copilot/src/lib/subagent-tree/session-transcript-resolver.ts"
        - "extensions/drm-copilot/src/lib/subagent-tree/workspace-encoding.ts"
        - "extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts"
        - "extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts"
        - "src/lib/subagent-tree/session-transcript-resolver.ts"
        - "src/lib/subagent-tree/workspace-encoding.ts"
      modules: []
      shared_surfaces: []
      contracts: []
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 935
    feature_folder: "docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "config/poshqc-coverage.json"
        - "docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/**"
        - "docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/spec.md"
        - "tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1"
        - "tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1"
        - "tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1"
        - "tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1"
        - "tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1"
        - "tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1"
        - "tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1"
        - "tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1"
        - "tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1"
        - "tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1"
        - "tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1"
        - "tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1"
        - "tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1"
        - "tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1"
        - "tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1"
        - "tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1"
        - "tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1"
        - "tests/scripts/dev_tools/test_blast_radius_historical_runs.py"
      modules:
        - "config"
      shared_surfaces: []
      contracts:
        - "AC-5"
        - "REPORT-VARIABLE-LOAD:"
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 936
    feature_folder: "docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1"
        - ".claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1"
        - ".claude/hooks/validate-executor-output.ps1"
        - ".claude/lib/bash/compute-concurrency-batches.sh"
        - ".codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1"
        - ".codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1"
        - ".codex/hooks/validate-feature-review-coverage.ps1"
        - ".github/workflows/_poshqc.yml"
        - ".github/workflows/ci.yml"
        - "config/poshqc-coverage.json"
        - "docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/**"
        - "docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/issue.md"
        - "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
        - "tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1"
        - "tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1"
        - "tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1"
        - "tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1"
        - "tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1"
        - "tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1"
      modules:
        - "codex-runtime"
        - "config"
        - "poshqc"
      shared_surfaces:
        - "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
      contracts: []
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 937
    feature_folder: "docs/features/active/exempt-operand-unc-path-leg-937"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1"
        - ".claude/lib/worktree-resolution/WorktreeRunResolution.psm1"
        - ".codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1"
        - "docs/features/active/exempt-operand-unc-path-leg-937/**"
        - "extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1"
        - "extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1"
        - "tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1"
        - "tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1"
        - "tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1"
        - "tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1"
        - "tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1"
      modules:
        - "codex-runtime"
      shared_surfaces: []
      contracts:
        - "CHANGELOG.md"
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 938
    feature_folder: "docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - "docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/evidence/remediation-baseline/black-check-baseline.2026-09-30T11-59.md"
        - "docs/features/active/2026-10-11-argumentless-sort-ordering-and-comparator-coverage-gaps-889/evidence/baseline/ts-prettier-check.2026-10-12T15-03.md"
        - "docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/evidence/baseline/baseline-pytest-coverage.2026-10-11T10-38.md"
        - "docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/**"
        - "docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/issue.md"
        - "docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/plan.2026-10-15T17-45.md"
        - "docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/research/research.2026-10-15T12-00.md"
        - "extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts"
        - "tests/scripts/dev_tools/test_codex_handoff_contract_parity.py"
        - "tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py"
        - "tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py"
        - "tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py"
        - "tests/scripts/dev_tools/test_validate_orchestration_artifacts.py"
        - "tests/scripts/dev_tools/validate_orchestration_artifacts_test_support.py"
        - "tests/scripts/dev_tools/validate_orchestrator_state_test_support.py"
      modules: []
      shared_surfaces: []
      contracts: []
      source: "declared"
      computed_at: "2026-10-15T23:48:46Z"
  - issue_num: 940
    feature_folder: "docs/features/active/dependabot-bumps-types-vscode-past-engines-940"
    kind: "bug"
    state: "prepared"
    blast_radius:
      paths:
        - ".github/dependabot.yml"
        - ".github/workflows/_quality-checks.yml"
        - "docs/features/active/dependabot-bumps-types-vscode-past-engines-940/**"
        - "docs/features/active/dependabot-bumps-types-vscode-past-engines-940/evidence/baseline/phase0-instructions-read.md"
        - "docs/features/active/dependabot-bumps-types-vscode-past-engines-940/issue.md"
        - "docs/features/active/dependabot-bumps-types-vscode-past-engines-940/plan.2026-10-15T07-42.md"
        - "tests/scripts/dev_tools/test_dependabot_config_contract.py"
      modules: []
      shared_surfaces: []
      contracts: []
      source: "declared"
      computed_at: "2026-10-15T12:22:16Z"
---

# Parallel Run: bug-burndown-2026-10-15

Run branch: `parallel/bug-burndown-2026-10-15-plan`. Each item opens its own pull request against `main`; this branch is not an integration branch.

| group | issue_num | state | band | branch | plan-path |
| --- | --- | --- | --- | --- | --- |
| I01 | 927 | prepared | C3 | bug/pr-author-docs-only-exemption-hardening-927 | docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/plan.2026-10-15T07-41.md |
| I02 | 928 | prepared | C3 | bug/subagentstop-hook-uncaught-error-exits-1-928 | docs/features/active/2026-10-15-subagentstop-hook-uncaught-error-exits-1-928/plan.2026-10-15T15-44.md |
| I03 | 929 | prepared | C3 | bug/subagentstop-artifact-gates-review-notes-929 | docs/features/active/subagentstop-artifact-gates-review-notes-929/plan.2026-10-15T15-44.md |
| I04 | 930 | prepared | C2 | bug/host-bootstrap-does-not-install-poetry-930 | docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/plan.2026-10-15T15-45.md |
| I05 | 931 | prepared | C2 | bug/release-flow-waits-on-required-checks-only-931 | docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/plan.2026-10-15T15-45.md |
| I06 | 932 | prepared | C3 | bug/plan-validator-accepts-bare-scratch-paths-932 | docs/features/active/2026-10-15-plan-validator-accepts-bare-scratch-paths-932/plan.2026-10-15T15-45.md |
| I07 | 933 | prepared | C3 | bug/npm-token-guard-misses-append-assignment-933 | docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/plan.2026-10-15T17-44.md |
| I08 | 934 | prepared | C2 | bug/workspace-encoding-test-host-specific-paths-934 | docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/plan.2026-10-15T17-44.md |
| I09 | 935 | prepared | C3 | bug/hook-test-isolation-737-remainder-935 | docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/plan.2026-10-15T17-44.md |
| I10 | 936 | prepared | C2 | bug/hook-coverage-attribution-gaps-936 | docs/features/active/2026-10-15-hook-coverage-attribution-gaps-936/plan.2026-10-15T17-44.md |
| I11 | 937 | prepared | C3 | bug/exempt-operand-unc-path-leg-937 | docs/features/active/exempt-operand-unc-path-leg-937/plan.2026-10-15T17-45.md |
| I12 | 938 | prepared | C2 | bug/test-support-hygiene-793-skipif-938 | docs/features/active/2026-10-15-test-support-hygiene-793-skipif-938/plan.2026-10-15T17-45.md |
| I13 | 543 | prepared | C3 | bug/epic-planner-receipt-checks-key-gate-543 | docs/features/active/epic-planner-receipt-checks-key-gate-543/plan.2026-10-15T07-42.md |
| I14 | 884 | prepared | C1 | bug/untouched-files-coverage-verification-884 | docs/features/active/untouched-files-coverage-verification-884/plan.2026-10-15T07-41.md |
| I15 | 940 | prepared | C1 | bug/dependabot-bumps-types-vscode-past-engines-940 | docs/features/active/dependabot-bumps-types-vscode-past-engines-940/plan.2026-10-15T07-42.md |

## Scheduling (generation 0)

Get-BlastRadiusConflictEdge derived 20 conflict edges over the declared radii and returned 6 tolerated overlaps under the configured conflict_tolerance. The operator conflict policy for this run was then applied per edge, and every derived edge was classified as tolerated; no radius was narrowed. With no retained edge, compute-cohorts returns one cohort of all 15 items, and execution concurrency is bounded by max_concurrency 15. For each tolerated pair, the later-merging item merges origin/main and re-passes CI before it merges.

| pair | engine cost | engine hard | classification | rationale |
| --- | --- | --- | --- | --- |
| 543:929 | 8 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py (read or run by both). |
| 543:932 | 8 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): extensions/drm-copilot/jest.config.cjs (written by 932). |
| 927:928 | 26 | True | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): .claude/hooks/enforce-powershell-batch-budget.ps1 (read or run by both); .claude/settings.json (read or run by both); .github/workflows/_poshqc.yml (read or run by both). The engine marked the pair hard because a shared path is a configured shared surface, but neither item writes it. |
| 927:929 | 10 | True | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (read or run by both). The engine marked the pair hard because a shared path is a configured shared surface, but neither item writes it. |
| 927:930 | 12 | True | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (read or run by both). The engine marked the pair hard because a shared path is a configured shared surface, but neither item writes it. |
| 927:931 | 10 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): .github/workflows/_poshqc.yml (read or run by both). |
| 927:935 | 8 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 (written by 935). |
| 927:936 | 20 | True | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): .github/workflows/_poshqc.yml (read or run by both); scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (read or run by both). The engine marked the pair hard because a shared path is a configured shared surface, but neither item writes it. |
| 927:937 | 18 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 (written by 927); tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 (written by 927). |
| 928:929 | 66 | False | separable_writes | Both write .claude/hooks/validate-task-researcher-output.ps1 and its bundled mirror, in separate hunks: #928 wraps the validator entry call in a try/catch that blocks with exit 2; #929 NB-5 removes an alias in the same file (the #929 child reports the overlap is limited to the NB-5 hunk). #929 sequences its NB-4 helper extraction last and re-checks #928 call sites. Separable writes (a few minutes of merge work), not edits to the same rule. Tolerated; the later-merging item merges origin/main and re-passes CI. |
| 928:931 | 8 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): .github/workflows/_poshqc.yml (read or run by both). |
| 928:936 | 18 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): .claude/hooks/validate-executor-output.ps1 (written by 928); .github/workflows/_poshqc.yml (read or run by both). |
| 929:930 | 10 | True | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (read or run by both). The engine marked the pair hard because a shared path is a configured shared surface, but neither item writes it. |
| 929:931 | 10 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): config/poshqc-coverage.json (read or run by both). |
| 929:935 | 26 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): config/poshqc-coverage.json (read or run by both); tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 (written by 929); tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 (read or run by both). |
| 929:936 | 20 | True | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): config/poshqc-coverage.json (read or run by both); scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (read or run by both). The engine marked the pair hard because a shared path is a configured shared surface, but neither item writes it. |
| 930:936 | 10 | True | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): scripts/powershell/PoshQC/settings/pester.runsettings.psd1 (read or run by both). The engine marked the pair hard because a shared path is a configured shared surface, but neither item writes it. |
| 931:935 | 10 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): config/poshqc-coverage.json (read or run by both). |
| 931:936 | 26 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): .github/workflows/_poshqc.yml (read or run by both); .github/workflows/ci.yml (read or run by both); config/poshqc-coverage.json (read or run by both). |
| 935:936 | 18 | False | read_only_one_side | Every shared declared path is read or run only on at least one side (cost 0 under the operator conflict policy): config/poshqc-coverage.json (read or run by both); tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 (read or run by both). |

## Execution notes

- Operator priority: #927 and #940 launch first within cohort 0 and merge first. #927 adds the merge-gate docs-only allowance that later docs-only merges rely on.
- #927: execution must run on `bug/pr-author-docs-only-exemption-hardening-927` at `e589e0a6` or later (plan P0-T3).
- #934: the executor cannot delegate; after Phase 0 the item orchestrator hands the two Phase 1 test rewrites to typescript-engineer.
- #935: the item orchestrator runs plan task P7-T1 (main CI baseline counts, committed and pushed) before delegating execution; Phase 7 is orchestrator-owned.
- #936: remove the whole-line `DIRECTIVE: PREFLIGHT VALIDATION ONLY` from the plan before delegating execution (P0-T1 checks it).
- #937: at the baseline, fail-before and final CI checkpoints the plan stops with `HANDOFF: CI <stage> HEAD=<sha>`; the item orchestrator dispatches ci.yml and saves the run output before the executor resumes.
- #928 and #929 both edit `.claude/hooks/validate-task-researcher-output.ps1` and its bundled mirror in separate hunks; whichever merges second merges origin/main first and re-passes CI.
- #884 is evidence-only (no code change); its PR body carries Closes #884.
- Archive move: feature folders of closed issues are moving from docs/features/active/ to docs/features/archive/; plan steps accept either location.
