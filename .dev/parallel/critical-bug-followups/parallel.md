---
parallel: 'critical-bug-followups'
mode: closed
max_concurrency: 4
created_at: '2026-08-28T15-20'
items:
  - issue_num: 573
    feature_folder: 'docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573'
    kind: bug
    state: prepared
    blast_radius:
      paths:
        - '../lib/hook-payload/HookPayload.psm1'
        - '.claude/**'
        - '.claude/hooks/enforce-epic-merge-gate.ps1'
        - '.claude/hooks/enforce-epic-worktree-removal-gate.ps1'
        - '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1'
        - '.claude/rules/parallel-orchestration.md'
        - '.claude/settings.json'
        - '.claude/settings.local.json'
        - '.claude/skills/cleanup-merged-worktrees/SKILL.md'
        - '.claude/skills/epic-orchestrate/SKILL.md'
        - '.claude/skills/parallel-orchestrate/SKILL.md'
        - '.codex/config.toml'
        - '.codex/hooks/enforce-epic-merge-gate.ps1'
        - '.codex/hooks/enforce-epic-worktree-removal-gate.ps1'
        - '.github/copilot-instructions.md'
        - '.github/instructions/*'
        - 'config/blast-radius.json'
        - 'docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/**'
        - 'docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/evidence/baseline/phase0-instructions-read.md'
        - 'docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/issue.md'
        - 'docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/research/research.2026-08-28T10-05.md'
        - 'docs/features/active/2026-08-28-epic-worktree-removal-gate-blocks-parallel-runs-573/spec.md'
        - 'docs/features/completed/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/rule-file-amendment.md'
        - 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1'
        - 'extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md'
        - 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md'
        - 'extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json'
        - 'extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-worktree-removal-gate.ps1'
        - 'pack-manifests/core.json'
        - 'parallel-orchestrate/SKILL.md'
        - 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
        - 'tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1'
        - 'tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1'
        - 'tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1'
        - 'tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py'
        - 'tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py'
      modules:
        - 'codex-runtime'
        - 'config'
        - 'poshqc'
      shared_surfaces:
        - '.claude/settings.json'
        - 'config/blast-radius.json'
        - 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
      contracts:
        - 'artifact_type'
        - 'critical-bug-fixes'
        - 'git'
        - 'pester.runsettings.psd1'
        - 'remove'
        - 'worktree'
      source: 'declared'
      computed_at: '2026-08-28T15:20:00Z'
  - issue_num: 574
    feature_folder: 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574'
    kind: bug
    state: prepared
    blast_radius:
      paths:
        - './src/lib/pr-context/collector-output.ts'
        - './src/lib/pr-context/pr-context-service-call.ts'
        - './src/lib/pr-context/summary-helpers.ts'
        - '.claude/hooks/enforce-pr-author-skill-helpers.ps1'
        - '.claude/hooks/enforce-pr-author-skill.ps1'
        - '.claude/hooks/enforce-python-batch-budget.ps1'
        - '.claude/skills/pr-context-artifacts/SKILL.md'
        - '.claude/state/python-batch-budget.default.json'
        - '.github/skills/pr-context-artifacts/SKILL.md'
        - 'W/artifacts/pr_context.appendix.txt'
        - 'W/artifacts/pr_context.summary.txt'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/**'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/**'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/file-line-counts.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/git-baseline.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/phase0-instructions-read.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/phase0-requirements-read.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/py-black.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/py-pr-context-coverage.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/py-pyright.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/py-pytest-coverage.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/py-ruff.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/python-batch-budget.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/ts-coverage.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/ts-format.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/ts-lint.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/ts-test-unit.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/baseline/ts-typecheck.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/changed-files.txt'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/collector-size.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/other/scope-files.txt'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/coverage-delta.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/file-size-compliance.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-py-black.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-py-pr-context-coverage.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-py-pyright.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-py-pytest-coverage.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-py-ruff.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-coverage.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-format.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-lint.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-test-unit.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/final-ts-typecheck.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/push-down-parity.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/scope-invariants.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/skill-copies-cross-check.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/qa-gates/ts-coverage-thresholds.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/fail-first-nodefs-boundary.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/fail-first-service-seam.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/pass-after-path-identity.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/py-pr-context-suite.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/readback-mutation-check-restored.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/evidence/regression-testing/readback-mutation-check.TIMESTAMP.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/issue.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/plan.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/research/2026-08-28T12-00-collect-pr-context-silent-write-failure-research.md'
        - 'docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/spec.md'
        - 'extensions/drm-copilot/package.json'
        - 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-context-artifacts/SKILL.md'
        - 'extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-context-artifacts/SKILL.md'
        - 'extensions/drm-copilot/resources/customizations/.github/skills/pr-context-artifacts/SKILL.md'
        - 'extensions/drm-copilot/src/lib/file-system.ts'
        - 'extensions/drm-copilot/src/lib/pr-context/collector-output.ts'
        - 'extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts'
        - 'extensions/drm-copilot/src/lib/pr-context/render.ts'
        - 'extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts'
        - 'extensions/drm-copilot/src/mcp-tools.ts'
        - 'extensions/drm-copilot/src/repo-automation-service-support.ts'
        - 'extensions/drm-copilot/test/extension.collect-pr-context.test.ts'
        - 'extensions/drm-copilot/test/extension.integration.test.ts'
        - 'extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts'
        - 'extensions/drm-copilot/test/lib/pr-context/collector-output-freshness.test.ts'
        - 'extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts'
        - 'extensions/drm-copilot/test/lib/pr-context/pr-context-service-call.test.ts'
        - 'extensions/drm-copilot/test/lib/pr-context/summary-helpers.test.ts'
        - 'extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts'
        - 'extensions/drm-copilot/test/mcp-server.test.ts'
        - 'extensions/drm-copilot/test/repo-automation-dispatch-pr-context-verification.test.ts'
        - 'extensions/drm-copilot/test/repo-automation-dispatch.test.ts'
        - 'research/2026-08-28T12-00-collect-pr-context-silent-write-failure-research.md'
        - 'scripts/dev_tools/pr_context/collector.py'
        - 'scripts/dev_tools/pr_context/collector_documents.py'
        - 'scripts/dev_tools/pr_context/summary_helpers.py'
        - 'src/**/*.ts'
        - 'src/lib/pr-context/collector-output.ts'
        - 'src/lib/pr-context/pr-context-service-call.ts'
        - 'src/lib/pr-context/summary-helpers.ts'
        - 'test/extension.collect-pr-context.test.ts'
        - 'test/extension.integration.test.ts'
        - 'test/lib/pr-context/collector-integration.test.ts'
        - 'test/lib/pr-context/collector-output-freshness.test.ts'
        - 'test/lib/pr-context/collector-output.test.ts'
        - 'test/lib/pr-context/pr-context-service-call.test.ts'
        - 'test/lib/pr-context/summary-helpers.test.ts'
        - 'test/repo-automation-dispatch-pr-context-verification.test.ts'
        - 'test/repo-automation-dispatch.test.ts'
        - 'tests/scripts/dev_tools/test_collect_pr_context.py'
        - 'tests/scripts/dev_tools/test_collect_pr_context_expected_exit.py'
        - 'tests/scripts/dev_tools/test_collect_pr_context_part2.py'
        - 'tests/scripts/dev_tools/test_collect_pr_context_part3.py'
        - 'tests/scripts/dev_tools/test_collect_pr_context_part4.py'
        - 'tests/scripts/dev_tools/test_plan_gate_parity.py'
        - 'tests/scripts/dev_tools/test_pr_context_freshness.py'
        - 'tests/scripts/dev_tools/test_pr_context_integration.py'
        - 'tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py'
        - 'tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py'
      modules: []
      shared_surfaces: []
      contracts:
        - 'Context'
        - 'Wrote'
        - 'appendix'
        - 'artifacts'
        - 'collector-integration.test.ts'
        - 'collector-output.test.ts'
        - 'context'
        - 'extension.integration.test.ts'
        - 'generated'
        - 'jest.config.cjs'
        - 'pr-context-service-call.test.ts'
        - 'summary'
        - 'summary-helpers.test.ts'
        - 'to:'
      source: 'declared'
      computed_at: '2026-08-28T15:20:00Z'
  - issue_num: 575
    feature_folder: 'docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575'
    kind: bug
    state: prepared
    blast_radius:
      paths:
        - './scripts/powershell/PoshQC/PoshQC.psd1'
        - '.github/workflows/publish-mcp-npm.yml'
        - '.github/workflows/verify-published-releases.yml'
        - 'docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md'
        - 'docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md:417'
        - 'docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/**'
        - 'docs/features/active/2026-08-28-release-poll-budgets-unpinned-and-isolation-evidence-proxy-level-575/spec.md'
        - 'docs/features/completed/2026-08-17-promotion-lifecycle-loses-promoted-record-487/evidence/other/documentation-corrections.2026-08-20T20-02.md'
        - 'evidence/qa-gates/network-isolated-suite.2026-08-26T02-36.md'
        - 'research/2026-08-28T15-00-release-poll-budgets-and-isolation-research.md'
        - 'scripts/dev-tools/Invoke-ReleaseTagPush.ps1'
        - 'scripts/dev-tools/Invoke-ReleaseVerification.ps1'
        - 'scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1'
        - 'scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:185'
        - 'scripts/powershell/PoshQC/PoshQC.Analyzer.psm1:64'
        - 'tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1'
        - 'tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1'
        - 'tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1'
        - 'tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1'
      modules:
        - 'poshqc'
        - 'powershell-dev-tools'
      shared_surfaces: []
      contracts: []
      source: 'declared'
      computed_at: '2026-08-28T15:20:00Z'
  - issue_num: 576
    feature_folder: 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576'
    kind: bug
    state: prepared
    blast_radius:
      paths:
        - '.claude/lib/blast-radius/BlastRadius.psm1'
        - '.claude/lib/blast-radius/BlastRadius.psm1:433'
        - '.claude/skills/parallel-add/SKILL.md'
        - '.claude/skills/parallel-plan/SKILL.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/**'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/bundle-parity.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/git-baseline.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/phase0-instructions-read.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/powershell-analyze.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/powershell-test-observable.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/powershell-test.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/python-coverage.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/python-format.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/python-full-test.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/python-lint.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/baseline/python-typecheck.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/other/bundle-parity-post-change.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/acceptance-criteria-signoff.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/final-powershell-analyze.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/final-powershell-format.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/final-powershell-test.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/final-python-format.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/final-python-lint.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/final-python-scoped-coverage.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/final-python-test.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/final-python-typecheck.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/final-qa-loop-outcome.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/parity-suites-unmodified.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/powershell-conflict-tests.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/powershell-file-size.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/push-down-parity.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/python-diff-review.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/python-parity-suite-unmodified.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/python-scoped-coverage.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/scope-verification.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/skill-literal-presence.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/regression-testing/fail-before.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/evidence/regression-testing/pass-after.2026-08-28T09-31.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/issue.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/research/2026-08-28T10-05-conflictresult-truthiness-always-true-research.md'
        - 'docs/features/active/2026-08-28-conflictresult-truthiness-always-true-576/spec.md'
        - 'extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadius.psm1'
        - 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md'
        - 'extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md'
        - 'parallel-add/SKILL.md'
        - 'parallel-plan/SKILL.md'
        - 'scripts/__init__.py'
        - 'scripts/dev_tools/__init__.py'
        - 'scripts/dev_tools/_blast_radius_conflicts.py'
        - 'tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1'
        - 'tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1:65'
        - 'tests/scripts/dev_tools/test_blast_radius_conflicts.py'
        - 'tests/scripts/dev_tools/test_blast_radius_invariants.py'
      modules: []
      shared_surfaces: []
      contracts:
        - 'ConflictResult'
      source: 'declared'
      computed_at: '2026-08-28T15:20:00Z'
---

# Parallel Run: critical-bug-followups

Four follow-up bugs filed from the completed `critical-bug-fixes` run (issues 573, 574,
575, 576). The items are thematically unrelated; ordering below is derived from computed
blast-radius contention only, and no dependency edge is declared anywhere in this document.

Each item carries its own prepared feature folder and approved atomic plan on its own
pushed feature branch, and opens its own pull request against `main`. There is no
integration branch.

## Derived conflict graph (generation 0)

| a | b | reason | evidence |
| --- | --- | --- | --- |
| 573 | 574 | path_overlap | `.claude/** ~ .claude/hooks/enforce-pr-author-skill-helpers.ps1` |
| 573 | 575 | module_overlap | `poshqc` |
| 573 | 576 | path_overlap | `.claude/** ~ .claude/lib/blast-radius/BlastRadius.psm1` |

All three edges are incident on issue 573, which yields two cohorts:

| cohort | item_keys |
| --- | --- |
| 0 | 573 |
| 1 | 574, 575, 576 |

`expected_conflict_components` is deliberately absent. The derived graph is a single
connected component, and asserting the derived result back at the diagnostic would be
circular. The per-edge triage is recorded in the planner completion report instead.

