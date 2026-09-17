# Changed-File Inventory Against the Merge Base

Timestamp: 2026-09-17T08:43:20-04:00
Command: git status --porcelain -uall ; git diff --name-only d93e2916c51c4d8ba61670c84b5702adb2c17a9d
EXIT_CODE: 0
Output Summary: After removing every path beginning with docs/features/ and every path in the [P0-T4] Pre-existing drift paths set (none), the union of the two listings contains exactly the ten Scope Boundary paths and no others. No Split suite path was recorded ([P3-T9]: none). No Python file appears in either listing.

## Raw listing 1 — git status --porcelain -uall (verbatim)

```text
 M .claude/lib/worktree-resolution/WorktreeResolution.psm1
 M docs/features/active/2026-09-13-target-worktree-resolution-module-669/plan.2026-09-13T20-45.md
 M extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeResolution.psm1
 M tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1
 M tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/batch-budget-reset.window-c.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/final-pester-junit.2026-09-13T22-00.xml
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/final-powershell-coverage.mcp.2026-09-13T22-00.xml
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/final-powershell-coverage.selfhosted.2026-09-13T22-00.xml
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/bundle-mirror-hashes.post-format.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/coverage-delta.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/final-poshqc-analyze.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/final-poshqc-format.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/final-poshqc-selfhosted-coverage.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/final-poshqc-test-mcp.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/mcp-coverage-path-determination.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/scope-boundary.2026-09-13T22-00.md
?? docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/toolchain-single-pass.2026-09-13T22-00.md
```

## Raw listing 2 — git diff --name-only d93e2916c51c4d8ba61670c84b5702adb2c17a9d (verbatim)

```text
.claude/lib/worktree-resolution/WorktreeResolution.psm1
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/issue.md
docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/plan.2026-09-13T20-49.md
docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/research/2026-09-13T21-30-collect-pr-context-explicit-target-research.md
docs/features/active/2026-09-13-collect-pr-context-explicit-target-675/spec.md
docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/issue.md
docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/plan.2026-09-13T20-46.md
docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/research/2026-09-13T21-10-epic-merge-gate-authorization-record-research.md
docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/spec.md
docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/issue.md
docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/plan.2026-09-13T20-48.md
docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/research/2026-09-13T22-10-false-approval-elimination-research.md
docs/features/active/2026-09-13-false-approval-elimination-pr-author-model-routing-673/spec.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-1-delta.2026-09-13T21-50.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-2-delta.2026-09-13T22-40.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-3-delta.2026-09-13T22-37.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/evidence/other/preflight-round-4-delta.2026-09-13T23-05.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/issue.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/plan.2026-09-13T20-47.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/research/2026-09-13T21-05-prd-feature-gate-target-resolution-research.md
docs/features/active/2026-09-13-prd-feature-gate-target-resolution-672/spec.md
docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/issue.md
docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/plan.2026-09-13T20-46.md
docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/research/2026-09-13T21-15-preimplementation-gate-worktree-selector-671-research.md
docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-acceptance-criteria-counts.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-batch-budget-state.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-merge-base.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-poshqc-analyze.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-poshqc-format.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-poshqc-parity-pytest.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-poshqc-selfhosted-test.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/baseline-poshqc-test-mcp.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/baseline/phase0-instructions-read.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/baseline-pester-junit.2026-09-13T22-00.xml
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/baseline-powershell-coverage.mcp.2026-09-13T22-00.xml
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/baseline-powershell-coverage.selfhosted.2026-09-13T22-00.xml
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/batch-budget-reset.window-a.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/other/batch-budget-reset.window-b.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/bundle-mirror-hashes.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/coverage-path-exclusion-check.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/coverage-xml-structure.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/module-line-counts.file1.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/module-line-counts.file2.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/poshqc-observed-success-output.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/qa-gates/suite-line-counts.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/regression-testing/convention-and-python-guard.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/regression-testing/manifest-suite.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/regression-testing/poshqc-parity-pytest.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/regression-testing/ruling-b-state-read-absence.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/regression-testing/worktree-resolution-suite.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/evidence/regression-testing/worktree-target-resolution-suite.2026-09-13T22-00.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/issue.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/plan.2026-09-13T20-45.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/research/2026-09-13T21-15-target-worktree-resolution-module-research.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/spec.md
docs/features/active/2026-09-13-target-worktree-resolution-module-669/user-story.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/issue.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/plan.2026-09-13T20-48.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/research/2026-09-13T22-15-taskmaster-push-down-and-resume-research.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/runbooks/confirm-taskmaster-run-resume.runbook.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/runbooks/reload-vscode-window-for-mcp-payload.runbook.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/spec.md
docs/features/active/2026-09-13-taskmaster-push-down-and-resume-674/user-story.md
docs/features/epics/worktree-scoped-state-resolution/epic-kickoff.md
docs/features/epics/worktree-scoped-state-resolution/epic.md
docs/features/potential/promoted/2026-09-13-collect-pr-context-explicit-target.md
docs/features/potential/promoted/2026-09-13-epic-merge-gate-authorization-record.md
docs/features/potential/promoted/2026-09-13-false-approval-elimination-pr-author-model-routing.md
docs/features/potential/promoted/2026-09-13-prd-feature-gate-target-resolution.md
docs/features/potential/promoted/2026-09-13-preimplementation-gate-worktree-selector.md
docs/features/potential/promoted/2026-09-13-target-worktree-resolution-module.md
docs/features/potential/promoted/2026-09-13-taskmaster-push-down-and-resume.md
docs/features/potential/promoted/2026-09-17-worktree-scoped-state-resolution.md
extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeResolution.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1
tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1
```

The `docs/features/` entries outside this feature folder are the epic's sibling feature folders and promoted
records, which were committed on the epic integration branch after the merge base; none is a code or test change.

## Removal set applied

1. Every path beginning with `docs/features/` (both listings).
2. Every path in the `Pre-existing drift paths:` line of evidence/baseline/baseline-poshqc-format.2026-09-13T22-00.md: none.

## Reduced union (10 paths)

```text
.claude/lib/worktree-resolution/WorktreeResolution.psm1
.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeResolution.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1
tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1
tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
```

Comparison with the plan's Scope Boundary: identical set (10 of 10), no extra path. Split suite path
recorded by [P3-T9]: none. Python files in either listing: none.
