# Scope listing (P0-T2 remediation baseline; CYCLE_HEAD is the HEAD value)

Timestamp: 2026-11-04T14-35
Command: git merge-base origin/epic/documentation-estate-tooling-integration HEAD; git rev-parse HEAD; git diff --name-only MERGE_BASE HEAD; git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary: MERGE_BASE=a94dea9a4be0743f00ff78de095c51e14d513b20; HEAD=e74802a41de95eef3c9b17d16d2c276d504dbc69; 110 paths in the MERGE_BASE name listing; 3 porcelain entries.

## git diff --name-only MERGE_BASE HEAD

```text
.claude/lib/docs/DocsAnalyzerDotnetApi.psm1
.claude/lib/docs/DocsAnalyzerDotnetConfig.psm1
.claude/lib/docs/DocsAnalyzerDotnetHttp.psm1
.claude/lib/docs/DocsAnalyzerExtensionImport.psm1
.claude/lib/docs/DocsAnalyzerRegistry.psm1
.claude/lib/docs/DocsAnalyzerTypeScriptCli.psm1
.claude/lib/docs/DocsAnalyzerTypeScriptExports.psm1
.claude/lib/docs/DocsAnalyzerTypeScriptHttp.psm1
.claude/lib/docs/DocsCSharpMember.psm1
.claude/lib/docs/DocsCSharpSyntax.psm1
.claude/lib/docs/DocsCSharpTokens.psm1
.claude/lib/docs/DocsExtensionShape.psm1
.claude/lib/docs/DocsScannerCommon.psm1
.claude/lib/docs/DocsTypeScriptCliSupport.psm1
.claude/lib/docs/DocsTypeScriptHttpDeclaration.psm1
.claude/lib/docs/DocsTypeScriptHttpSupport.psm1
.claude/lib/docs/DocsTypeScriptSyntax.psm1
.claude/lib/docs/DocsTypeScriptTokens.psm1
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/code-review.2026-11-04T14-15.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/baseline/baseline-pester-coverage.2026-11-03T22-12.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/baseline/baseline-plan-validation.2026-11-03T21-43.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/baseline/baseline-poshqc-format.2026-11-03T21-49.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/baseline/baseline-pssa.2026-11-03T21-49.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/baseline/baseline-pushdown-contracts.2026-11-03T22-14.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/baseline/baseline-scope.2026-11-03T21-47.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/baseline/phase0-instructions-read.2026-11-03T21-43.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/other/bundle-mirror.2026-11-04T02-15.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/other/contract-reconciliation.2026-11-03T21-46.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/other/upstream-contract-check.2026-11-03T21-45.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/coverage-delta.2026-11-04T03-22.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-existing-gates.2026-11-04T02-27.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-existing-gates.2026-11-04T03-01.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-hygiene-and-size.2026-11-04T03-23.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-pester-coverage.2026-11-04T02-25.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-pester-coverage.2026-11-04T03-01.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-poshqc-format.2026-11-04T02-18.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-poshqc-format.2026-11-04T03-01.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-pssa.2026-11-04T02-19.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-pssa.2026-11-04T03-01.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-scope.2026-11-04T03-23.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/qa-token-scan.2026-11-04T03-23.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/qa-gates/self-review.2026-11-04T03-25.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/isolation-shuffled.2026-11-04T02-32.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/isolation-shuffled.2026-11-04T03-01.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/isolation-single-process.2026-11-04T03-22.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p1-scanner-common.2026-11-03T22-22.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p2-cs-tokens.2026-11-03T22-42.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p2-ts-jsx.2026-11-03T22-37.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p2-ts-tokens.2026-11-03T22-28.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p3-ts-cli.2026-11-03T23-17.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p3-ts-exports.2026-11-04T00-12.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p3-ts-http.2026-11-03T23-50.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p4-dotnet-api.2026-11-04T00-56.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p4-dotnet-config.2026-11-04T00-42.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p4-dotnet-http.2026-11-04T00-32.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p5-ext-merge.2026-11-04T01-52.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p5-ext-validation.2026-11-04T01-35.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p6-contract-determinism.2026-11-04T02-07.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p6-contract-elements.2026-11-04T02-14.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p6-existing-suites.2026-11-04T02-17.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p6-pushdown-contracts.2026-11-04T02-17.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p6-registry-rows.2026-11-04T02-00.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/p6-registry-suite.2026-11-04T02-00.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/regression-testing/post-integration-merge.2026-11-04T14-05.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/feature-audit.2026-11-04T14-15.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/plan.2026-10-30T18-39.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/policy-audit.2026-11-04T14-15.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/remediation-inputs.2026-11-04T14-15.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/remediation-plan.2026-11-04T14-15.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/spec.md
docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/user-story.md
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerDotnetApi.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerDotnetConfig.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerDotnetHttp.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerExtensionImport.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerRegistry.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerTypeScriptCli.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerTypeScriptExports.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsAnalyzerTypeScriptHttp.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsCSharpMember.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsCSharpSyntax.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsCSharpTokens.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsExtensionShape.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsScannerCommon.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsTypeScriptCliSupport.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsTypeScriptHttpDeclaration.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsTypeScriptHttpSupport.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsTypeScriptSyntax.psm1
extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/DocsTypeScriptTokens.psm1
extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json
tests/scripts/claude-lib/docs/Docs.ScannerTestSupport.psm1
tests/scripts/claude-lib/docs/DocsAnalyzerDotnetApi.Tests.ps1
tests/scripts/claude-lib/docs/DocsAnalyzerDotnetConfig.Tests.ps1
tests/scripts/claude-lib/docs/DocsAnalyzerDotnetHttp.Tests.ps1
tests/scripts/claude-lib/docs/DocsAnalyzerExtensionImport.Tests.ps1
tests/scripts/claude-lib/docs/DocsAnalyzerRegistry.TypeScriptDotnet.Tests.ps1
tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptCli.Tests.ps1
tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptExports.Tests.ps1
tests/scripts/claude-lib/docs/DocsAnalyzerTypeScriptHttp.Tests.ps1
tests/scripts/claude-lib/docs/DocsCSharpMember.Tests.ps1
tests/scripts/claude-lib/docs/DocsCSharpSyntax.Tests.ps1
tests/scripts/claude-lib/docs/DocsCSharpTokens.Tests.ps1
tests/scripts/claude-lib/docs/DocsExtensionShape.Tests.ps1
tests/scripts/claude-lib/docs/DocsScannerCommon.Tests.ps1
tests/scripts/claude-lib/docs/DocsScannerContract.Tests.ps1
tests/scripts/claude-lib/docs/DocsTypeScriptCliSupport.Tests.ps1
tests/scripts/claude-lib/docs/DocsTypeScriptHttpDeclaration.Tests.ps1
tests/scripts/claude-lib/docs/DocsTypeScriptHttpSupport.Tests.ps1
tests/scripts/claude-lib/docs/DocsTypeScriptSyntax.Tests.ps1
tests/scripts/claude-lib/docs/DocsTypeScriptTokens.Tests.ps1
```

## git status --porcelain --untracked-files=all

```text
 M docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/remediation-plan.2026-11-04T14-15.md
?? docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/baseline/phase0-instructions-read.2026-11-04T14-35.md
?? docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/evidence/other/preflight-fixes.2026-11-04T14-34.md
```
