# Scope Baseline ([P0-T3])

Timestamp: 2026-11-03T11-47
Command: git merge-base origin/main HEAD; git diff --name-only MERGE_BASE HEAD; git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary: MERGE_BASE resolved; 113 paths changed since MERGE_BASE, all under docs/features/; 0 paths end in .py/.ts/.tsx/.js/.mjs/.cjs; none of the four target directories exists.

MERGE_BASE: 715241396b557ce198e44f5c4b606fbcd9082c3c

## git diff --name-only MERGE_BASE HEAD

```text
docs/features/active/2026-10-30-docs-authoring-workflow-1037/evidence/other/preflight-fixes.2026-10-31T05-28.md
docs/features/active/2026-10-30-docs-authoring-workflow-1037/evidence/other/preflight-fixes.2026-10-31T05-44.md
docs/features/active/2026-10-30-docs-authoring-workflow-1037/evidence/other/preflight-status.2026-10-31T16-43.md
docs/features/active/2026-10-30-docs-authoring-workflow-1037/issue.md
docs/features/active/2026-10-30-docs-authoring-workflow-1037/plan.2026-10-30T18-59.md
docs/features/active/2026-10-30-docs-authoring-workflow-1037/research/2026-10-30T23-33-docs-authoring-workflow-research.md
docs/features/active/2026-10-30-docs-authoring-workflow-1037/spec.md
docs/features/active/2026-10-30-docs-authoring-workflow-1037/user-story.md
docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/evidence/other/preflight-fixes.2026-10-30T21-29.md
docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/evidence/other/preflight-fixes.2026-10-31T04-51.md
docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/evidence/other/preflight-fixes.2026-10-31T05-07.md
docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/evidence/other/preflight-status.2026-10-31T16-43.md
docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/issue.md
docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/plan.2026-10-30T16-51.md
docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/research/2026-10-30T20-59-docs-coverage-ledger-and-receipt-research.md
docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/research/2026-10-30T22-40-docs-coverage-ledger-and-receipt-powershell-addendum.md
docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/spec.md
docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/user-story.md
docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/other/preflight-fixes.2026-10-30T23-37.md
docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/other/preflight-fixes.2026-10-30T23-50.md
docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/evidence/other/preflight-status.2026-10-31T16-43.md
docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/issue.md
docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/plan.2026-10-30T18-40.md
docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/research/research.2026-10-30.md
docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/spec.md
docs/features/active/2026-10-30-docs-enforcement-and-ci-1034/user-story.md
docs/features/active/2026-10-30-docs-mcp-tools-1036/evidence/other/preflight-fixes.2026-10-31T04-57.md
docs/features/active/2026-10-30-docs-mcp-tools-1036/evidence/other/preflight-status.2026-10-31T16-43.md
docs/features/active/2026-10-30-docs-mcp-tools-1036/issue.md
docs/features/active/2026-10-30-docs-mcp-tools-1036/plan.2026-10-30T18-58.md
docs/features/active/2026-10-30-docs-mcp-tools-1036/research/orchestrator-confirmations.2026-10-30T23-30.md
docs/features/active/2026-10-30-docs-mcp-tools-1036/research/research.2026-10-30T23-05.md
docs/features/active/2026-10-30-docs-mcp-tools-1036/spec.md
docs/features/active/2026-10-30-docs-mcp-tools-1036/user-story.md
docs/features/active/2026-10-30-docs-page-quality-checker-1021/evidence/other/preflight-fixes.2026-10-30T20-49.md
docs/features/active/2026-10-30-docs-page-quality-checker-1021/evidence/other/preflight-fixes.2026-10-31T04-28.md
docs/features/active/2026-10-30-docs-page-quality-checker-1021/evidence/other/preflight-fixes.2026-10-31T04-37.md
docs/features/active/2026-10-30-docs-page-quality-checker-1021/issue.md
docs/features/active/2026-10-30-docs-page-quality-checker-1021/plan.2026-10-30T16-13.md
docs/features/active/2026-10-30-docs-page-quality-checker-1021/research/2026-10-30T22-45-docs-page-quality-checker-powershell-design-addendum-research.md
docs/features/active/2026-10-30-docs-page-quality-checker-1021/research/research.2026-10-30T20-35.md
docs/features/active/2026-10-30-docs-page-quality-checker-1021/spec.md
docs/features/active/2026-10-30-docs-page-quality-checker-1021/user-story.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/other/preflight-fixes.2026-10-30T20-41.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/other/preflight-fixes.2026-10-30T22-23.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/other/preflight-fixes.2026-10-31T16-00.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/other/preflight-status.2026-10-31T16-43.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/issue.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/plan.2026-10-30T16-08.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/research/2026-10-30T20-30-docs-profile-and-artifact-schemas-research.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/research/2026-10-30T21-45-docs-profile-powershell-design-addendum-research.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/research/2026-10-30T22-35-docs-profile-amendment-d3-d5-addendum-research.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md
docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/user-story.md
docs/features/active/2026-10-30-docs-reference-generator-1024/evidence/other/preflight-fixes.2026-10-30T21-32.md
docs/features/active/2026-10-30-docs-reference-generator-1024/evidence/other/preflight-fixes.2026-10-30T21-49.md
docs/features/active/2026-10-30-docs-reference-generator-1024/evidence/other/preflight-fixes.2026-10-30T23-39.md
docs/features/active/2026-10-30-docs-reference-generator-1024/evidence/other/preflight-fixes.2026-10-31T16-26.md
docs/features/active/2026-10-30-docs-reference-generator-1024/evidence/other/preflight-status.2026-10-31T16-43.md
docs/features/active/2026-10-30-docs-reference-generator-1024/issue.md
docs/features/active/2026-10-30-docs-reference-generator-1024/plan.2026-10-30T16-54.md
docs/features/active/2026-10-30-docs-reference-generator-1024/research/2026-10-30T22-39-docs-reference-powershell-addendum-research.md
docs/features/active/2026-10-30-docs-reference-generator-1024/research/research.2026-10-30T20-59.md
docs/features/active/2026-10-30-docs-reference-generator-1024/spec.md
docs/features/active/2026-10-30-docs-reference-generator-1024/user-story.md
docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/evidence/other/preflight-fixes.2026-10-31T05-21.md
docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/evidence/other/preflight-status.2026-10-31T16-43.md
docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/issue.md
docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/plan.2026-10-30T18-38.md
docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/research/research.2026-10-30T22-48.md
docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/spec.md
docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/user-story.md
docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/evidence/other/preflight-fixes.2026-10-30T21-37.md
docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/evidence/other/preflight-fixes.2026-10-30T23-31.md
docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/evidence/other/preflight-fixes.2026-10-31T04-29.md
docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/evidence/other/preflight-status.2026-10-31T16-43.md
docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/issue.md
docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/plan.2026-10-30T16-46.md
docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/research/2026-10-30T20-47-docs-surface-analyzers-python-config-research.md
docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/research/2026-10-30T22-40-docs-surface-analyzers-python-config-powershell-addendum.md
docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/spec.md
docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/user-story.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/other/preflight-fixes.2026-10-30T23-42.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/other/preflight-fixes.2026-10-31T04-28.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/other/preflight-fixes.2026-10-31T04-44.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/other/preflight-fixes.2026-10-31T16-24.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/other/preflight-status.2026-10-31T16-43.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/issue.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/plan.2026-10-30T18-39.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/research/2026-10-30T22-45-docs-surface-analyzers-typescript-dotnet-research.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/spec.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/user-story.md
docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/evidence/other/preflight-fixes.2026-10-31T05-32.md
docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/evidence/other/preflight-status.2026-10-31T16-43.md
docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/issue.md
docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/plan.2026-10-30T18-59.md
docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/research/research.2026-10-30T23-29.md
docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/spec.md
docs/features/active/2026-10-30-documentation-estate-template-and-onboarding-1038/user-story.md
docs/features/epics/documentation-estate-tooling/epic-kickoff.md
docs/features/epics/documentation-estate-tooling/epic.md
docs/features/potential/promoted/2026-10-30-docs-authoring-workflow.md
docs/features/potential/promoted/2026-10-30-docs-coverage-ledger-and-receipt.md
docs/features/potential/promoted/2026-10-30-docs-enforcement-and-ci.md
docs/features/potential/promoted/2026-10-30-docs-mcp-tools.md
docs/features/potential/promoted/2026-10-30-docs-page-quality-checker.md
docs/features/potential/promoted/2026-10-30-docs-profile-and-artifact-schemas.md
docs/features/potential/promoted/2026-10-30-docs-reference-generator.md
docs/features/potential/promoted/2026-10-30-docs-surface-analyzer-python-native.md
docs/features/potential/promoted/2026-10-30-docs-surface-analyzers-python-config.md
docs/features/potential/promoted/2026-10-30-docs-surface-analyzers-typescript-dotnet.md
docs/features/potential/promoted/2026-10-30-documentation-estate-template-and-onboarding.md
docs/features/potential/promoted/2026-10-30-documentation-estate-tooling.md
```

## git status --porcelain --untracked-files=all

```text
 M docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/plan.2026-10-30T16-08.md
?? docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/baseline/baseline-plan-validation.2026-11-03T11-47.md
?? docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/baseline/baseline-scope.2026-11-03T11-47.md
?? docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/evidence/baseline/phase0-instructions-read.2026-11-03T11-47.md
```

## Target directory existence

- `.claude/lib/docs`: does not exist
- `schemas/docs`: does not exist
- `examples/docs`: does not exist
- `tests/scripts/claude-lib/docs`: does not exist

No listed path ends in .py, .ts, .tsx, .js, .mjs, or .cjs (count: 0).
