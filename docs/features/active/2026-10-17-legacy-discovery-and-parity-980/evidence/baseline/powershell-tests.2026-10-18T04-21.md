# powershell-tests

Timestamp: 2026-10-18T04-21
Command: sh SCRATCH/issue-980-powershell-baseline.sh tests
EXIT_CODE: 0
Output Summary: 11310 passed, 0 failed, 0 errors, 10 skipped; 17730/19142 lines (92.623550%); branches not measured.

Working directory: .
Started: 2026-10-18T04:06:44.630934+00:00
Duration seconds: 909.059
Phase: P0 baseline; no implementation repair is performed by this command.

## Captured output

```text
PowerShell=7.6.7

Name             Version
----             -------
Pester           5.9.0
Pester           5.6.1
PSScriptAnalyzer 1.25.0
PSScriptAnalyzer 1.24.0
PSScriptAnalyzer 1.22.0
Pester           3.4.0

WARNING: Scan configuration 'config/poshqc-scan.json' folder 'tests/powershell' does not exist under root '.'; skipping.
Code coverage population: source=config; files=215

Starting discovery in 410 files.
Discovery found 11320 tests in 26.5s.
Starting code coverage.
Running tests.
[+] .\tests\scripts\host-tools.manifest.Tests.ps1 910ms (521ms|266ms)
[+] .\tests\scripts\ci\CiChangeScope.Tests.ps1 398ms (217ms|136ms)
[+] .\tests\scripts\ci\CiDocsOnlyPathsConfig.Tests.ps1 101ms (43ms|45ms)
[+] .\tests\scripts\ci\Invoke-CiChangeScope.Tests.ps1 319ms (238ms|61ms)
[+] .\tests\scripts\ci\Invoke-CiChangeScopeMergeBase.Tests.ps1 217ms (135ms|61ms)
[+] .\tests\scripts\claude-hooks\check-powershell-test-purity.Tests.ps1 156ms (98ms|35ms)
[+] .\tests\scripts\claude-hooks\check-python-test-purity.Tests.ps1 126ms (68ms|44ms)
[+] .\tests\scripts\claude-hooks\CleanupWorktreeManifestGateMatrix.Tests.ps1 3.26s (3.08s|149ms)
[+] .\tests\scripts\claude-hooks\enforce-checkpoint-monotonic.Tests.ps1 177ms (94ms|61ms)
[+] .\tests\scripts\claude-hooks\enforce-completion-consistency-codex.Tests.ps1 222ms (184ms|25ms)
[+] .\tests\scripts\claude-hooks\enforce-completion-consistency.DefaultReader.Tests.ps1 127ms (88ms|28ms)
[+] .\tests\scripts\claude-hooks\enforce-completion-consistency.EditSemantics.Tests.ps1 175ms (96ms|65ms)
[+] .\tests\scripts\claude-hooks\enforce-completion-consistency.EditTarget.Tests.ps1 119ms (69ms|35ms)
[+] .\tests\scripts\claude-hooks\enforce-completion-consistency.FailClosed.Tests.ps1 112ms (66ms|34ms)
[+] .\tests\scripts\claude-hooks\enforce-completion-consistency.Payload.Tests.ps1 151ms (67ms|50ms)
[+] .\tests\scripts\claude-hooks\enforce-completion-consistency.Tests.ps1 564ms (343ms|183ms)
[+] .\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.Tests.ps1 357ms (196ms|132ms)
[+] .\tests\scripts\claude-hooks\enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 162ms (106ms|43ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-invocation-origin.Tests.ps1 242ms (140ms|81ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-merge-gate.Authorization.Tests.ps1 550ms (490ms|45ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 155ms (72ms|66ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-merge-gate.Coverage.Tests.ps1 223ms (190ms|23ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-merge-gate.DocsOnly.Tests.ps1 454ms (379ms|43ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-merge-gate.ItemResolution.Tests.ps1 403ms (346ms|39ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-merge-gate.MergeQueue.Tests.ps1 859ms (769ms|67ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-merge-gate.Tests.ps1 867ms (688ms|140ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-merge-gate.TriggerScoping.Tests.ps1 549ms (452ms|79ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-merge-gate.WorktreeResolution.Tests.ps1 563ms (507ms|41ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-wave-barrier.FolderResolution.Tests.ps1 328ms (249ms|57ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-wave-barrier.Tests.ps1 334ms (235ms|63ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-wave-barrier.WorktreeResolution.Tests.ps1 270ms (224ms|29ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1 299ms (252ms|32ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 1.23s (1.13s|70ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1 225ms (185ms|28ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.Tests.ps1 831ms (687ms|106ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 209ms (160ms|32ms)
[+] .\tests\scripts\claude-hooks\enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1 282ms (231ms|38ms)
[+] .\tests\scripts\claude-hooks\enforce-evidence-locations.Tests.ps1 144ms (65ms|57ms)
[+] .\tests\scripts\claude-hooks\enforce-feature-folder-order.Tests.ps1 415ms (298ms|70ms)
[+] .\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 353ms (292ms|43ms)
REPORT: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 launches check-powershell-test-purity.ps1
REPORT: tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 launches a.ps1, x.ps1
REPORT: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 launches enforce-x.ps1, gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 launches enforce-parallel-worktree-removal-gate.ps1
REPORT: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 launches enforce-promotion-mcp-only.ps1
REPORT: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 launches *(.codex/hooks)
REPORT: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 launches validate-bash.ps1, enforce-epic-wave-barrier.ps1, *(.codex/hooks)
REPORT: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 launches enforce-orchestration-preimplementation-gate.ps1, codex-pretooluse-file-mapping.ps1, enforce-completion-consistency.ps1, *(.codex/hooks)
REPORT: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1 launches enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 launches enforce-epic-child-worktree-binding.ps1
REPORT: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 launches enforce-epic-planning-only.ps1, enforce-epic-wave-barrier.ps1, enforce-epic-merge-gate.ps1, enforce-epic-worktree-removal-gate.ps1
REPORT: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 launches enforce-orchestration-preimplementation-gate.ps1, enforce-python-batch-budget.ps1, enforce-powershell-batch-budget.ps1, codex-pretooluse-file-mapping.ps1, validate-feature-review-coverage.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 loads validate-bash.ps1, enforce-promotion-mcp-only.ps1, enforce-pr-author-skill.ps1, enforce-orchestration-preimplementation-gate.ps1, check-python-test-purity.ps1, enforce-python-batch-budget.ps1, check-powershell-test-purity.ps1, enforce-powershell-batch-budget.ps1, enforce-evidence-locations.ps1, enforce-feature-folder-order.ps1, enforce-checkpoint-monotonic.ps1, enforce-completion-consistency.ps1, enforce-prd-feature-before-planner.ps1, enforce-epic-invocation-origin.ps1, enforce-mermaid-validation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 loads check-powershell-test-purity.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 loads check-python-test-purity.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 loads enforce-orchestration-preimplementation-gate-epic-resolution.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 loads enforce-orchestration-preimplementation-gate-helpers.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 loads enforce-orchestration-preimplementation-gate-helpers.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1 loads enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 loads enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-promotion-mcp-only.Issue824.Tests.ps1 loads enforce-promotion-mcp-only.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1 loads enforce-python-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 loads enforce-python-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/feature-review-coverage-thresholds.Tests.ps1 loads feature-review-coverage-thresholds.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-consumers.Issue824.Tests.ps1 loads validate-bash.ps1, enforce-orchestration-preimplementation-gate.ps1, enforce-epic-merge-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation-operands.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation.Issue824.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 loads enforce-promotion-mcp-only.ps1, enforce-orchestration-preimplementation-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 loads enforce-epic-worktree-removal-gate.ps1, enforce-parallel-worktree-removal-gate.ps1, enforce-epic-merge-gate.ps1, enforce-promotion-mcp-only.ps1, enforce-orchestration-preimplementation-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-payload.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-scanner.Issue824.Tests.ps1 loads hook-command-scanner.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 loads hook-command-scanner.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/persist-session-id.Tests.ps1 loads persist-session-id.ps1
REPORT-VARIABLE-LOAD: tests/scripts/claude-hooks/validate-bash.Tests.ps1 loads validate-bash.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 loads enforce-python-batch-budget.ps1, enforce-powershell-batch-budget.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1 loads *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 loads enforce-evidence-locations.ps1, enforce-checkpoint-monotonic.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1 loads enforce-powershell-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 loads enforce-epic-wave-barrier.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 loads enforce-orchestration-preimplementation-gate.ps1, codex-pretooluse-file-mapping.ps1, enforce-completion-consistency.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1 loads enforce-python-batch-budget.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 loads check-python-test-purity.ps1, check-powershell-test-purity.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 loads enforce-epic-planning-only.ps1, enforce-epic-wave-barrier.ps1, enforce-epic-merge-gate.ps1, enforce-epic-worktree-removal-gate.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/epic-provenance.Tests.ps1 loads authorize-root-epic-invocation.ps1, record-subagent-routing-attestation.ps1, enforce-epic-root-invocation.ps1, enforce-codex-model-routing.ps1, validate-codex-subagent-routing.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 loads hook-command-invocation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 loads hook-command-scanner.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 loads enforce-orchestration-preimplementation-gate.ps1, enforce-python-batch-budget.ps1, enforce-powershell-batch-budget.ps1, codex-pretooluse-file-mapping.ps1, validate-feature-review-coverage.ps1, *(.codex/hooks)
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 loads record-subagent-routing-attestation.ps1, enforce-codex-model-routing.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/subagent-attestation-command.Tests.ps1 loads record-subagent-routing-attestation.ps1
REPORT-VARIABLE-LOAD: tests/scripts/codex-hooks/subagent-attestation-persistence.Tests.ps1 loads record-subagent-routing-attestation.ps1, authorize-root-epic-invocation.ps1
[+] .\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 118.84s (101.59s|407ms)
[+] .\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 478ms (384ms|72ms)
[+] .\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1 134ms (94ms|27ms)
[+] .\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 185ms (146ms|27ms)
[+] .\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Probe.Tests.ps1 285ms (235ms|37ms)
[+] .\tests\scripts\claude-hooks\enforce-gate-suites.EpicStateIsolation.Tests.ps1 520ms (429ms|74ms)
[+] .\tests\scripts\claude-hooks\enforce-mermaid-validation.Tests.ps1 757ms (654ms|77ms)
[+] .\tests\scripts\claude-hooks\enforce-model-routing-receipt.EpicScope.Tests.ps1 223ms (184ms|27ms)
[+] .\tests\scripts\claude-hooks\enforce-model-routing-receipt.Tests.ps1 230ms (172ms|42ms)
[+] .\tests\scripts\claude-hooks\enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 526ms (462ms|42ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 359ms (266ms|77ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 209ms (160ms|33ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.ChainEscape.Tests.ps1 150ms (79ms|57ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.OperandNormalization.Tests.ps1 232ms (135ms|82ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 50ms (18ms|22ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 366ms (274ms|69ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 508ms (328ms|132ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 79ms (42ms|26ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.PathNotLocal.Tests.ps1 695ms (500ms|182ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate-targets.Tests.ps1 953ms (752ms|181ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1 2.22s (2.09s|116ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.C1bCoverage.Tests.ps1 121ms (80ms|29ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 3.22s (3.01s|169ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 739ms (664ms|60ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1 860ms (798ms|51ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandBypass.Tests.ps1 230ms (197ms|24ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1 706ms (637ms|54ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Parity.Tests.ps1 748ms (622ms|102ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.Tests.ps1 541ms (451ms|69ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 679ms (607ms|45ms)
[+] .\tests\scripts\claude-hooks\enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1 378ms (291ms|59ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.Tests.ps1 263ms (179ms|61ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 160ms (112ms|31ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1 253ms (181ms|53ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Payload.Tests.ps1 157ms (111ms|34ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.Tests.ps1 440ms (297ms|110ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-cohort-barrier.WorktreeResolution.Tests.ps1 219ms (170ms|36ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-drift-gate-helpers.Tests.ps1 242ms (177ms|48ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-drift-gate.FolderResolution.Tests.ps1 257ms (182ms|55ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-drift-gate.Tests.ps1 545ms (387ms|111ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-drift-gate.WorktreeResolution.Tests.ps1 199ms (160ms|27ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 395ms (343ms|38ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1 1.27s (1.18s|69ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.Tests.ps1 949ms (819ms|102ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 182ms (139ms|30ms)
[+] .\tests\scripts\claude-hooks\enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1 326ms (268ms|47ms)
[+] .\tests\scripts\claude-hooks\enforce-powershell-batch-budget-routing.Tests.ps1 299ms (189ms|90ms)
[+] .\tests\scripts\claude-hooks\enforce-powershell-batch-budget.Tests.ps1 276ms (178ms|71ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-command-allowlist.Tests.ps1 469ms (402ms|53ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.BodyNumber.Tests.ps1 889ms (820ms|55ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.DocsOnly.Decision.Tests.ps1 1.3s (1.22s|70ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.DocsOnly.Exemption.Tests.ps1 879ms (820ms|45ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.DocsOnly.Tests.ps1 646ms (570ms|58ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.Tests.ps1 1.21s (1.12s|63ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 305ms (258ms|36ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.EpicScope.Tests.ps1 752ms (687ms|53ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.Issue824.Tests.ps1 1.53s (1.45s|61ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.ItemArtifactRoot.Tests.ps1 1.96s (1.87s|70ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 1.19s (1.15s|31ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.Payload.Tests.ps1 367ms (309ms|46ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.TargetResolution.Tests.ps1 550ms (497ms|40ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.Tests.ps1 1.88s (1.71s|132ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.TriggerScoping.Tests.ps1 1.28s (1.17s|85ms)
[+] .\tests\scripts\claude-hooks\enforce-pr-author-skill.WorktreeResolution.Tests.ps1 2.08s (2.02s|46ms)
[+] .\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CallTarget.Tests.ps1 194ms (146ms|35ms)
[+] .\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1 240ms (188ms|39ms)
[+] .\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 463ms (360ms|62ms)
[+] .\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 327ms (271ms|43ms)
[+] .\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 396ms (332ms|50ms)
[+] .\tests\scripts\claude-hooks\enforce-prd-feature-before-planner.Tests.ps1 495ms (370ms|102ms)
[+] .\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Issue824.Tests.ps1 1.18s (1.08s|79ms)
[+] .\tests\scripts\claude-hooks\enforce-promotion-mcp-only.Tests.ps1 267ms (190ms|60ms)
[+] .\tests\scripts\claude-hooks\enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 212ms (163ms|34ms)
[+] .\tests\scripts\claude-hooks\enforce-python-batch-budget-routing.Tests.ps1 291ms (211ms|59ms)
[+] .\tests\scripts\claude-hooks\enforce-python-batch-budget.Tests.ps1 258ms (174ms|58ms)
[+] .\tests\scripts\claude-hooks\feature-folder-resolution.Tests.ps1 248ms (133ms|93ms)
[+] .\tests\scripts\claude-hooks\feature-review-coverage-thresholds.Tests.ps1 138ms (69ms|57ms)
[+] .\tests\scripts\claude-hooks\hook-command-consumers.Issue824.Tests.ps1 1.28s (1.18s|78ms)
[+] .\tests\scripts\claude-hooks\hook-command-invocation-operands.Tests.ps1 1.11s (1s|89ms)
[+] .\tests\scripts\claude-hooks\hook-command-invocation.Issue824.Tests.ps1 1.53s (1.3s|203ms)
[+] .\tests\scripts\claude-hooks\hook-command-invocation.Issue824Regression.Tests.ps1 2.93s (2.81s|89ms)
[+] .\tests\scripts\claude-hooks\hook-command-invocation.Tests.ps1 405ms (295ms|90ms)
[+] .\tests\scripts\claude-hooks\hook-command-parser.AcceptanceCases.Tests.ps1 505ms (434ms|55ms)
[+] .\tests\scripts\claude-hooks\hook-command-payload.Tests.ps1 925ms (775ms|131ms)
[+] .\tests\scripts\claude-hooks\hook-command-scanner.Issue824.Tests.ps1 173ms (71ms|73ms)
[+] .\tests\scripts\claude-hooks\hook-command-scanner.Tests.ps1 261ms (140ms|96ms)
[+] .\tests\scripts\claude-hooks\hook-dependency-failure.Claude.Tests.ps1 8.66s (8.07s|273ms)
[+] .\tests\scripts\claude-hooks\hook-dependency-failure.SpecialCases.Tests.ps1 3.37s (1.57s|59ms)
[+] .\tests\scripts\claude-hooks\hook-dependency-guard.Tests.ps1 99ms (54ms|32ms)
[+] .\tests\scripts\claude-hooks\hook-docs-only-diff.BoundedNative.Tests.ps1 178ms (132ms|34ms)
[+] .\tests\scripts\claude-hooks\hook-docs-only-diff.MergeExemption.Tests.ps1 1.05s (950ms|81ms)
[+] .\tests\scripts\claude-hooks\hook-docs-only-diff.Tests.ps1 204ms (114ms|72ms)
[+] .\tests\scripts\claude-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 2.75s (2.67s|60ms)
[+] .\tests\scripts\claude-hooks\persist-session-id.Tests.ps1 177ms (123ms|40ms)
[+] .\tests\scripts\claude-hooks\premortem-section.Tests.ps1 119ms (66ms|43ms)
[+] .\tests\scripts\claude-hooks\PreToolUsePayload.Contract.Tests.ps1 317ms (176ms|119ms)
[+] .\tests\scripts\claude-hooks\PreToolUseSchema.Contract.Tests.ps1 576ms (534ms|31ms)
[+] .\tests\scripts\claude-hooks\session-root-reads-850.Constraints.Tests.ps1 1.4s (1.37s|26ms)
[+] .\tests\scripts\claude-hooks\subagentstop-envelope-orchestrator-family.Registration.Tests.ps1 461ms (414ms|36ms)
[+] .\tests\scripts\claude-hooks\subagentstop-envelope.Tests.ps1 418ms (275ms|112ms)
[+] .\tests\scripts\claude-hooks\subagentstop-uncaught-error.Tests.ps1 1.06s (991ms|54ms)
[+] .\tests\scripts\claude-hooks\validate-bash.Tests.ps1 300ms (193ms|87ms)
[+] .\tests\scripts\claude-hooks\validate-bash.TriggerScoping.Tests.ps1 225ms (169ms|40ms)
[+] .\tests\scripts\claude-hooks\validate-discovery-artifact-gate.Dispatch.Tests.ps1 101ms (66ms|23ms)
[+] .\tests\scripts\claude-hooks\validate-discovery-artifact-gate.Tests.ps1 787ms (674ms|89ms)
[+] .\tests\scripts\claude-hooks\validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 97ms (51ms|34ms)
[+] .\tests\scripts\claude-hooks\validate-executor-output.Envelope.Tests.ps1 220ms (179ms|29ms)
[+] .\tests\scripts\claude-hooks\validate-executor-output.Preflight.Tests.ps1 293ms (207ms|68ms)
[+] .\tests\scripts\claude-hooks\validate-executor-output.Reentry.Tests.ps1 196ms (139ms|37ms)
[+] .\tests\scripts\claude-hooks\validate-executor-output.Tests.ps1 213ms (136ms|60ms)
[+] .\tests\scripts\claude-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 947ms (794ms|129ms)
[+] .\tests\scripts\claude-hooks\validate-feature-review-coverage.Issue824.Tests.ps1 246ms (175ms|53ms)
[+] .\tests\scripts\claude-hooks\validate-feature-review-coverage.Tests.ps1 410ms (317ms|74ms)
[+] .\tests\scripts\claude-hooks\validate-feature-review-coverage.ThresholdsGuard.Tests.ps1 360ms (320ms|28ms)
[+] .\tests\scripts\claude-hooks\validate-orchestrator-output-resolution.Tests.ps1 586ms (541ms|34ms)
[+] .\tests\scripts\claude-hooks\validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 678ms (601ms|61ms)
[+] .\tests\scripts\claude-hooks\validate-orchestrator-output.Envelope.Tests.ps1 627ms (574ms|34ms)
[+] .\tests\scripts\claude-hooks\validate-orchestrator-output.human-interaction.Tests.ps1 305ms (259ms|35ms)
[+] .\tests\scripts\claude-hooks\validate-orchestrator-output.model-routing.Tests.ps1 487ms (440ms|32ms)
[+] .\tests\scripts\claude-hooks\validate-orchestrator-output.Reentry.Tests.ps1 500ms (451ms|36ms)
[+] .\tests\scripts\claude-hooks\validate-orchestrator-output.Tests.ps1 589ms (511ms|59ms)
[+] .\tests\scripts\claude-hooks\validate-orchestrator-output.WaveBarrier.Tests.ps1 462ms (418ms|32ms)
[+] .\tests\scripts\claude-hooks\validate-orchestrator-output.WorktreeResolution.Tests.ps1 837ms (777ms|46ms)
[+] .\tests\scripts\claude-hooks\validate-planner-output.Coverage.Tests.ps1 262ms (212ms|39ms)
[+] .\tests\scripts\claude-hooks\validate-planner-output.PreMortem.Tests.ps1 172ms (116ms|47ms)
[+] .\tests\scripts\claude-hooks\validate-planner-output.Reentry.Tests.ps1 147ms (101ms|35ms)
[+] .\tests\scripts\claude-hooks\validate-planner-output.Tests.ps1 375ms (229ms|127ms)
[+] .\tests\scripts\claude-hooks\validate-pr-author-output.Coverage.Tests.ps1 306ms (214ms|81ms)
[+] .\tests\scripts\claude-hooks\validate-pr-author-output.Tests.ps1 437ms (360ms|42ms)
[+] .\tests\scripts\claude-hooks\validate-prd-feature-output.Coverage.Tests.ps1 623ms (580ms|31ms)
[+] .\tests\scripts\claude-hooks\validate-prd-feature-output.Tests.ps1 265ms (169ms|80ms)
[+] .\tests\scripts\claude-hooks\validate-required-artifact-output.Envelope.Tests.ps1 274ms (220ms|44ms)
[+] .\tests\scripts\claude-hooks\validate-required-artifact-output.Reentry.Tests.ps1 123ms (89ms|24ms)
[+] .\tests\scripts\claude-hooks\validate-required-artifact-output.Tests.ps1 98ms (52ms|35ms)
[+] .\tests\scripts\claude-hooks\validate-task-researcher-output.Coverage.Tests.ps1 940ms (807ms|115ms)
[+] .\tests\scripts\claude-hooks\validate-task-researcher-output.PreMortem.Tests.ps1 137ms (97ms|30ms)
[+] .\tests\scripts\claude-hooks\validate-task-researcher-output.Tests.ps1 239ms (142ms|78ms)
[+] .\tests\scripts\claude-lib\ClaudeLibModuleConvention.Tests.ps1 1.12s (1.06s|47ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadius.Conflict.Tests.ps1 897ms (774ms|91ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadius.HistoricalRuns.Tests.ps1 47.72s (47.68s|33ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadius.KeyPartition.Tests.ps1 76ms (27ms|36ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadius.Manifest.Tests.ps1 63ms (25ms|26ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadius.Parity.Tests.ps1 2.94s (2.75s|143ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadius.Regression452.Tests.ps1 1.02s (919ms|64ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadius.Tests.ps1 827ms (688ms|112ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadius.TruthTable.Tests.ps1 615ms (533ms|63ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadius.Validation.Tests.ps1 851ms (739ms|92ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusConfig.Tests.ps1 345ms (188ms|123ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.OverlappingPairs.Tests.ps1 678ms (633ms|35ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.PathOverlap.Tests.ps1 1.02s (944ms|60ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusConflict.Tests.ps1 689ms (630ms|37ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusExtraction.Path.Tests.ps1 296ms (156ms|109ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusExtraction.Tests.ps1 122ms (45ms|57ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusGlob.RegexCache.Tests.ps1 101ms (55ms|32ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusGlob.Tests.ps1 237ms (97ms|109ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusNormalization.Tests.ps1 693ms (618ms|56ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusScheduling.PairCost.Tests.ps1 291ms (254ms|26ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusScheduling.Tests.ps1 2.02s (1.9s|84ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusTokenShape.Tests.ps1 245ms (107ms|110ms)
[+] .\tests\scripts\claude-lib\blast-radius\BlastRadiusWriteIntent.Tests.ps1 1.59s (1.52s|54ms)
[+] .\tests\scripts\claude-lib\ci-gate\CiGate.Manifest.Tests.ps1 41ms (10ms|22ms)
[+] .\tests\scripts\claude-lib\ci-gate\Invoke-CiGateParser.Tests.ps1 262ms (150ms|77ms)
[+] .\tests\scripts\claude-lib\ci-gate\Invoke-MergeConfirmationParser.Tests.ps1 113ms (72ms|30ms)
[+] .\tests\scripts\claude-lib\ci-gate\MergeConfirmationParser.Manifest.Tests.ps1 50ms (18ms|23ms)
[+] .\tests\scripts\claude-lib\cleanup-manifest\CleanupWorktreeManifest.Tests.ps1 100ms (39ms|46ms)
[+] .\tests\scripts\claude-lib\codex-routing\CodexDeployment.GeneratedFamilies.Parity.Tests.ps1 85ms (50ms|25ms)
[+] .\tests\scripts\claude-lib\codex-routing\CodexDeployment.Parity.Tests.ps1 178ms (103ms|59ms)
[+] .\tests\scripts\claude-lib\codex-routing\CodexRouting.Manifest.Tests.ps1 63ms (21ms|32ms)
[+] .\tests\scripts\claude-lib\codex-routing\CodexTopology.Parity.Tests.ps1 191ms (123ms|52ms)
[+] .\tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.Manifest.Tests.ps1 57ms (23ms|24ms)
[+] .\tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.Tests.ps1 234ms (142ms|73ms)
[+] .\tests\scripts\claude-lib\discovery-validation\DiscoveryValidation.VersionFloor.Tests.ps1 102ms (38ms|48ms)
[+] .\tests\scripts\claude-lib\hook-payload\HookPayload.Tests.ps1 287ms (130ms|117ms)
[+] .\tests\scripts\claude-lib\mermaid\MermaidGrammar.Tests.ps1 372ms (200ms|148ms)
[+] .\tests\scripts\claude-lib\mermaid\MermaidLineScanner.Tests.ps1 351ms (198ms|128ms)
[+] .\tests\scripts\claude-lib\mermaid\MermaidMarkdownFences.Tests.ps1 179ms (85ms|76ms)
[+] .\tests\scripts\claude-lib\mermaid\MermaidValidation.Tests.ps1 446ms (331ms|94ms)
[+] .\tests\scripts\claude-lib\mermaid\MermaidValidationAcceptMatrix.Tests.ps1 318ms (244ms|51ms)
[+] .\tests\scripts\claude-lib\model-routing\Get-ComplexityFloor.Tests.ps1 115ms (36ms|62ms)
[+] .\tests\scripts\claude-lib\model-routing\ModelRouting.Manifest.Tests.ps1 48ms (17ms|21ms)
[+] .\tests\scripts\claude-lib\model-routing\ModelRouting.Parity.Tests.ps1 110ms (52ms|44ms)
[+] .\tests\scripts\claude-lib\model-routing\Resolve-DelegationModel.Tests.ps1 133ms (66ms|53ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Manifest.Tests.ps1 165ms (128ms|26ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.Tests.ps1 815ms (662ms|126ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorState.ValueContract.Tests.ps1 81ms (49ms|22ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Backcompat.Tests.ps1 645ms (593ms|41ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Parity.Tests.ps1 386ms (258ms|92ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateBlockedReason.Tests.ps1 143ms (86ms|43ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCheckpointValue.Tests.ps1 199ms (94ms|87ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexModelReceipts.Tests.ps1 279ms (204ms|61ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexTopologyReceipts.Tests.ps1 282ms (202ms|64ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCompletion.Tests.ps1 1.01s (926ms|68ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCompletionChecks.Tests.ps1 226ms (139ms|68ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1 187ms (147ms|26ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateEpicWaveBarrier.Tests.ps1 141ms (80ms|43ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Parity.Tests.ps1 505ms (413ms|61ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateIssueAdoption.Tests.ps1 572ms (471ms|82ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateModelReceipts.Tests.ps1 176ms (109ms|51ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStatePromotionType.Parity.Tests.ps1 206ms (136ms|45ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateReceipts.Tests.ps1 196ms (124ms|57ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationAccounting.Tests.ps1 435ms (271ms|135ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationLoop.Backcompat.Tests.ps1 749ms (675ms|60ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRemediationLoop.Parity.Tests.ps1 698ms (555ms|126ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRoutingContract.Tests.ps1 375ms (295ms|56ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateRoutingMatrix.Tests.ps1 179ms (98ms|64ms)
[+] .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateUnconditional.Tests.ps1 260ms (205ms|41ms)
[+] .\tests\scripts\claude-lib\parallel-drift\Invoke-ParallelDriftDetection.Tests.ps1 1.1s (1.01s|71ms)
[+] .\tests\scripts\claude-lib\parallel-drift\ParallelDrift.Manifest.Tests.ps1 50ms (17ms|23ms)
[+] .\tests\scripts\claude-lib\parallel-drift\ParallelDrift.Parity.Tests.ps1 1.28s (1.22s|50ms)
[+] .\tests\scripts\claude-lib\parallel-drift\ParallelDrift.Tests.ps1 989ms (936ms|42ms)
[+] .\tests\scripts\claude-lib\parallel-drift\ParallelDriftHalt.Tests.ps1 143ms (76ms|55ms)
[+] .\tests\scripts\claude-lib\project-file-merge\ProjectFileMerge.Manifest.Tests.ps1 67ms (17ms|39ms)
[+] .\tests\scripts\claude-lib\project-file-merge\ProjectFileMerge.Tests.ps1 243ms (185ms|43ms)
[+] .\tests\scripts\claude-lib\project-file-merge\ProjectFileMergeGrammar.Tests.ps1 104ms (45ms|47ms)
What if: Performing the operation "Write the merged project file" on target ".\tests\fixtures\project_file_merge\whatif-never-written.csproj".
[+] .\tests\scripts\claude-lib\project-file-merge\Resolve-MergeableConflict.Tests.ps1 306ms (247ms|29ms)
[+] .\tests\scripts\claude-lib\requirements\GeneratedDocumentCounters.Tests.ps1 60ms (9ms|29ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\EpicScopeReadiness.Tests.ps1 120ms (36ms|42ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.RunTarget.Tests.ps1 182ms (135ms|27ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\EpicScopeResolution.Tests.ps1 506ms (418ms|73ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.PrNumber.Tests.ps1 198ms (157ms|32ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\WorktreeItemResolution.Tests.ps1 331ms (248ms|68ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Manifest.Tests.ps1 123ms (71ms|41ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\WorktreeResolution.Tests.ps1 423ms (307ms|96ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Record.Tests.ps1 460ms (375ms|69ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Signal.Tests.ps1 111ms (53ms|46ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\WorktreeRunResolution.Tests.ps1 304ms (222ms|62ms)
[+] .\tests\scripts\claude-lib\worktree-resolution\WorktreeTargetResolution.Tests.ps1 670ms (563ms|87ms)
[+] .\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1 126ms (89ms|27ms)
[+] .\tests\scripts\claude-runtime\claude-architecture-doc.Tests.ps1 66ms (26ms|31ms)
[+] .\tests\scripts\claude-runtime\claude-runtime-structure.Tests.ps1 67ms (35ms|23ms)
[+] .\tests\scripts\claude-runtime\claude-settings.Tests.ps1 126ms (83ms|34ms)
[+] .\tests\scripts\claude-runtime\enforcement-hooks-checkpoint-path-explicit.Tests.ps1 6s (5.97s|26ms)
[+] .\tests\scripts\claude-runtime\enforcement-hooks-no-python-invocation.Tests.ps1 8.09s (8s|72ms)
[+] .\tests\scripts\claude-runtime\hook-dependency-guard-completeness.Tests.ps1 44.28s (43.43s|772ms)
[+] .\tests\scripts\claude-runtime\hook-import-failure-exemptions.Guard.Tests.ps1 30.28s (30.23s|35ms)
[+] .\tests\scripts\claude-runtime\hook-imported-modules-no-stdout.Tests.ps1 47.53s (47.45s|52ms)
[+] .\tests\scripts\claude-runtime\legacy-discovery-agent-roles.Tests.ps1 108ms (39ms|56ms)
[+] .\tests\scripts\claude-runtime\test-name-uniqueness.Tests.ps1 7.54s (7.5s|32ms)
[+] .\tests\scripts\codex-hooks\codex-batch-budget-hooks.Tests.ps1 331ms (248ms|70ms)
[+] .\tests\scripts\codex-hooks\codex-batch-budget-route-parity.Tests.ps1 174ms (101ms|60ms)
[+] .\tests\scripts\codex-hooks\codex-bundle-hook-probe.Tests.ps1 14.14s (14.1s|34ms)
[+] .\tests\scripts\codex-hooks\codex-completion-consistency-hook.Tests.ps1 125ms (82ms|30ms)
[+] .\tests\scripts\codex-hooks\codex-detached-head-transport.Tests.ps1 277ms (228ms|37ms)
[+] .\tests\scripts\codex-hooks\codex-epic-child-launch-attestation.Coverage.Tests.ps1 91ms (58ms|23ms)
[+] .\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1 607ms (550ms|47ms)
[+] .\tests\scripts\codex-hooks\codex-evidence-and-checkpoint-hooks.Tests.ps1 304ms (195ms|91ms)
[+] .\tests\scripts\codex-hooks\codex-planning-only-hook.Tests.ps1 113ms (56ms|35ms)
[+] .\tests\scripts\codex-hooks\codex-planning-only-registry.Tests.ps1 282ms (192ms|77ms)
[+] .\tests\scripts\codex-hooks\codex-powershell-batch-budget-routing.Tests.ps1 274ms (141ms|112ms)
[+] .\tests\scripts\codex-hooks\codex-preimplementation-gate-absolute-paths.Tests.ps1 403ms (308ms|79ms)
[+] .\tests\scripts\codex-hooks\codex-pretooluse-file-mapping.Tests.ps1 211ms (118ms|72ms)
[+] .\tests\scripts\codex-hooks\codex-pretooluse-integration.Tests.ps1 32.15s (32.11s|30ms)
[+] .\tests\scripts\codex-hooks\codex-pretooluse-transport.Tests.ps1 25.23s (25.12s|95ms)
[+] .\tests\scripts\codex-hooks\codex-python-batch-budget-routing.Tests.ps1 290ms (194ms|69ms)
[+] .\tests\scripts\codex-hooks\codex-test-purity-hooks.Tests.ps1 277ms (184ms|78ms)
[+] .\tests\scripts\codex-hooks\codex-worktree-binding-hook.Tests.ps1 170ms (110ms|44ms)
[+] .\tests\scripts\codex-hooks\enforce-codex-model-routing.Coverage.Tests.ps1 293ms (233ms|48ms)
[+] .\tests\scripts\codex-hooks\enforce-completion-consistency-default-reader.Tests.ps1 114ms (73ms|32ms)
[+] .\tests\scripts\codex-hooks\enforce-completion-consistency-edit-semantics.Tests.ps1 172ms (108ms|52ms)
[+] .\tests\scripts\codex-hooks\enforce-completion-consistency-edit-target.Tests.ps1 137ms (83ms|43ms)
[+] .\tests\scripts\codex-hooks\enforce-completion-consistency-epic-scope.Tests.ps1 89ms (43ms|36ms)
[+] .\tests\scripts\codex-hooks\enforce-completion-consistency-fail-closed.Tests.ps1 112ms (70ms|31ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-merge-gate-authorization.Tests.ps1 580ms (502ms|62ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-merge-gate-command.Tests.ps1 301ms (239ms|36ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-merge-gate-decision-surface.Tests.ps1 327ms (265ms|45ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-merge-gate-docs-only.Tests.ps1 433ms (374ms|49ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-merge-gate-merge-queue.Tests.ps1 810ms (705ms|88ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-merge-gate-trigger-scoping.Tests.ps1 323ms (270ms|41ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-root-invocation.Coverage.Tests.ps1 169ms (126ms|31ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-wave-barrier.Coverage.Tests.ps1 356ms (292ms|50ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 430ms (351ms|62ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-issue824.Tests.ps1 1.32s (1.23s|77ms)
[+] .\tests\scripts\codex-hooks\enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 282ms (210ms|59ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1 1.92s (1.77s|127ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 2.46s (2.34s|99ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1 583ms (445ms|116ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope-targets.Tests.ps1 883ms (809ms|60ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 126ms (83ms|31ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1 1.16s (1.04s|105ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 311ms (235ms|56ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 347ms (206ms|111ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 203ms (132ms|56ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-operand-bypass.Tests.ps1 190ms (158ms|24ms)
[+] .\tests\scripts\codex-hooks\enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 740ms (656ms|67ms)
[+] .\tests\scripts\codex-hooks\enforce-promotion-mcp-only-decision-surface.Tests.ps1 326ms (263ms|45ms)
[+] .\tests\scripts\codex-hooks\enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 208ms (161ms|33ms)
[+] .\tests\scripts\codex-hooks\epic-child-launch-attestation.Tests.ps1 119ms (65ms|44ms)
[+] .\tests\scripts\codex-hooks\epic-child-launch-hardening.Tests.ps1 321ms (275ms|34ms)
[+] .\tests\scripts\codex-hooks\epic-child-worktree-launcher.Tests.ps1 224ms (148ms|60ms)
[+] .\tests\scripts\codex-hooks\epic-execution-gates.Tests.ps1 4.79s (4.67s|87ms)
[+] .\tests\scripts\codex-hooks\epic-provenance.Tests.ps1 267ms (196ms|57ms)
[+] .\tests\scripts\codex-hooks\epic-wave-launch-binding.Tests.ps1 181ms (121ms|49ms)
[+] .\tests\scripts\codex-hooks\feature-folder-resolution.Tests.ps1 265ms (137ms|107ms)
[+] .\tests\scripts\codex-hooks\feature-review-coverage-floor-parity.Tests.ps1 218ms (184ms|24ms)
[+] .\tests\scripts\codex-hooks\feature-review-coverage-thresholds.Tests.ps1 110ms (57ms|43ms)
[+] .\tests\scripts\codex-hooks\hook-command-invocation.Tests.ps1 411ms (298ms|93ms)
[+] .\tests\scripts\codex-hooks\hook-command-scanner.Tests.ps1 276ms (150ms|104ms)
[+] .\tests\scripts\codex-hooks\hook-dependency-failure.Codex.Tests.ps1 4.45s (4.12s|143ms)
[+] .\tests\scripts\codex-hooks\hook-dependency-guard.Tests.ps1 98ms (46ms|39ms)
[+] .\tests\scripts\codex-hooks\hook-docs-only-diff.Tests.ps1 578ms (495ms|71ms)
[+] .\tests\scripts\codex-hooks\hook-import-failure-exemptions.FailClosed.Tests.ps1 334ms (299ms|25ms)
[+] .\tests\scripts\codex-hooks\legacy-codex-hook-contracts.Tests.ps1 12.12s (12.03s|77ms)
[+] .\tests\scripts\codex-hooks\model-profile-attestation.Tests.ps1 128ms (91ms|27ms)
[+] .\tests\scripts\codex-hooks\subagent-attestation-command.Tests.ps1 280ms (237ms|33ms)
[+] .\tests\scripts\codex-hooks\subagent-attestation-persistence.Tests.ps1 397ms (314ms|68ms)
[+] .\tests\scripts\codex-hooks\validate-bash-decision-surface.Tests.ps1 463ms (359ms|75ms)
[+] .\tests\scripts\codex-hooks\validate-bash-trigger-scoping.Tests.ps1 148ms (105ms|33ms)
[+] .\tests\scripts\codex-hooks\validate-codex-subagent-routing.Coverage.Tests.ps1 196ms (142ms|40ms)
[+] .\tests\scripts\codex-hooks\validate-feature-review-coverage.Coverage.Tests.ps1 636ms (534ms|86ms)
[+] .\tests\scripts\codex-scripts\codex-routing-cli-common.Tests.ps1 213ms (111ms|81ms)
[+] .\tests\scripts\codex-scripts\Resolve-CodexRouting.Parity.Tests.ps1 8.26s (8.15s|91ms)
[+] .\tests\scripts\dev-tools\activate.Tests.ps1 307ms (182ms|102ms)
[+] .\tests\scripts\dev-tools\agents-attribution.Tests.ps1 34ms (4ms|20ms)
[+] .\tests\scripts\dev-tools\bootstrap-host.Tests.ps1 827ms (789ms|26ms)
[+] .\tests\scripts\dev-tools\Enter-DrmCopilotShell.Tests.ps1 80ms (24ms|42ms)
[+] .\tests\scripts\dev-tools\HostBootstrap.Invoke.Tests.ps1 1.85s (1.68s|143ms)
What if: Performing the operation "Set RunOnce bootstrap resume command" on target "HKCEXTERNAL_PATH".
[+] .\tests\scripts\dev-tools\HostBootstrap.Tests.ps1 514ms (408ms|86ms)
[+] .\tests\scripts\dev-tools\HostBootstrapWorkspace.Tests.ps1 429ms (327ms|81ms)
What if: Performing the operation "Set environment variable" on target "Process environment variable DRM847_UNSET_PROBE".
[+] .\tests\scripts\dev-tools\HostTooling.Tests.ps1 246ms (157ms|74ms)
[+] .\tests\scripts\dev-tools\HostVerification.Invoke.Tests.ps1 429ms (351ms|66ms)
[+] .\tests\scripts\dev-tools\HostVerification.Tests.ps1 472ms (366ms|87ms)
[+] .\tests\scripts\dev-tools\Invoke-FullRelease.Tests.ps1 731ms (604ms|104ms)
[+] .\tests\scripts\dev-tools\Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 349ms (282ms|39ms)
[+] .\tests\scripts\dev-tools\Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1 134ms (54ms|65ms)
[+] .\tests\scripts\dev-tools\Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 421ms (343ms|62ms)
[+] .\tests\scripts\dev-tools\Invoke-FullReleaseFlow.MergeWait.Tests.ps1 588ms (529ms|46ms)
[+] .\tests\scripts\dev-tools\Invoke-FullReleaseFlow.Tests.ps1 391ms (305ms|69ms)
[+] .\tests\scripts\dev-tools\Invoke-MarketplacePublish.Tests.ps1 392ms (277ms|96ms)
[+] .\tests\scripts\dev-tools\Invoke-ReleaseReconciliation.Tests.ps1 70ms (26ms|35ms)
[+] .\tests\scripts\dev-tools\Invoke-ReleaseTagPush.Tests.ps1 765ms (638ms|106ms)
Publish verification for tag 'mcp-server-v0.0.2' returned 'NO_RUN'. No run started for the tag ref. With the ref-based publish guard in place, re-dispatch non-destructively with "gh workflow run publish-mcp-npm.yml --ref" against the tag; that consumes no version number. Delete-and-re-push of the tag is precondition-gated and runbook-only.
Publish verification for tag 'mcp-server-v0.0.2' returned 'STEP_SKIPPED'. The job concluded success but the publish step was skipped, so the publish guard did not match and the version is NOT consumed. Fix the guard or the trigger, then re-dispatch.
Publish verification for tag 'mcp-server-v0.0.2' returned 'UNRESOLVED'. The publish step succeeded but the version did not appear on the registry within the polling budget. This is most likely registry propagation delay. Re-run the verifier before concluding, and do NOT retry the publish.
[+] .\tests\scripts\dev-tools\Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 277ms (221ms|46ms)
[+] .\tests\scripts\dev-tools\Invoke-ReleaseVerification.Tests.ps1 581ms (487ms|68ms)
[+] .\tests\scripts\dev-tools\Invoke-ReleaseVerificationHelpers.Tests.ps1 99ms (29ms|55ms)
What if: Performing the operation "Update section content" on target "## Feature Docs".
[+] .\tests\scripts\dev-tools\link-feature-docs.Tests.ps1 262ms (169ms|79ms)
[+] .\tests\scripts\dev-tools\link-parent-child.Tests.ps1 476ms (378ms|84ms)
What if: Performing the operation "Create worktree grouping directory" on target "/parent/auth-wt".
[+] .\tests\scripts\dev-tools\new-claude-worktree-session.Tests.ps1 270ms (125ms|114ms)
[+] .\tests\scripts\dev-tools\new-potential-entry.TemplateRoot.Tests.ps1 209ms (167ms|32ms)
[+] .\tests\scripts\dev-tools\new-potential-entry.Tests.ps1 440ms (310ms|104ms)
[+] .\tests\scripts\dev-tools\post-codex-worktree-session.Tests.ps1 197ms (144ms|37ms)
What if: Performing the operation "Create output directory" on target "EXTERNAL_PATH".
What if: Performing the operation "npm ci" on target "EXTERNAL_PATH".
What if: Performing the operation "compile extension project" on target "EXTERNAL_PATH".
What if: Performing the operation "npx vsce package" on target "EXTERNAL_PATH".
What if: Performing the operation "code --install-extension" on target "EXTERNAL_PATH".
What if: Performing the operation "Create output directory" on target "EXTERNAL_PATH".
What if: Performing the operation "npm ci" on target "EXTERNAL_PATH".
What if: Performing the operation "compile extension project" on target "EXTERNAL_PATH".
What if: Performing the operation "npx vsce package" on target "EXTERNAL_PATH".
What if: Performing the operation "code --install-extension" on target "EXTERNAL_PATH".
[+] .\tests\scripts\dev-tools\publish-sideloaded-extension.Tests.ps1 460ms (367ms|61ms)
actionlint not found; downloading local copy into tools/actionlint/bin...
Downloading httpEXTERNAL_PATH ...
[+] .\tests\scripts\dev-tools\run-actionlint.Tests.ps1 854ms (730ms|98ms)
[+] .\tests\scripts\dev-tools\SideloadedExtensionPublish.Invoke.Tests.ps1 605ms (543ms|49ms)
[+] .\tests\scripts\dev-tools\SideloadedExtensionPublish.Tests.ps1 479ms (389ms|72ms)
[+] .\tests\scripts\dev-tools\sync-agents-from-instructions.Tests.ps1 462ms (370ms|70ms)
[+] .\tests\scripts\dev-tools\tree.Tests.ps1 336ms (216ms|92ms)
[+] .\tests\scripts\dev-tools\verify-host.Tests.ps1 203ms (148ms|45ms)
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : DanMoisan
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: Package
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : DanMoisan
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Packaging to \repo\artifacts\vsix\drm-copilot-0.0.2-20261018-001648.vsix...

[5/5] Package complete. Install locally with:
      code --install-extension "\repo\artifacts\vsix\drm-copilot-0.0.2-20261018-001648.vsix"
      Marketplace upload and the release tag are performed by CI
      (.github/workflows/publish-extension.yml) after the bump PR merges.
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : DanMoisan
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm install...
  Running npm run compile...

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : DanMoisan
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm run compile...

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : DanMoisan
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm install...
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : DanMoisan
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm run compile...
drm-copilot package script - mode: DryRun
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : DanMoisan
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 2
    docs/internal.md

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
drm-copilot package script - mode: Package
Extension directory: /repo/ext

[1/5] Validating manifest...
  Publisher : DanMoisan
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Build skipped (-SkipBuild).

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Packaging to \repo\artifacts\vsix\drm-copilot-0.0.2-20261018-001648.vsix...
drm-copilot package script - mode: DryRun
Extension directory: .\extensions\drm-copilot

[1/5] Validating manifest...
  Publisher : DanMoisan
  Name      : drm-copilot
  Version   : 0.0.2

[2/5] Building extension...
  Running npm run compile...

[3/5] Listing files to be packaged...
  Files to ship: 1

[4/5] Dry-run complete. No package performed.
[5/5] To produce a .vsix, re-run with -Package.
      Marketplace upload and tagging are performed by CI after the version-bump PR merges.
[+] .\tests\scripts\powershell\Publish-DrmCopilotExtension.Tests.ps1 503ms (408ms|75ms)
[+] .\tests\scripts\powershell\PoshQC\Get-PoshQCFileList.Excludes.Tests.ps1 59ms (18ms|22ms)
Already formatted: /repo/test.ps1
Formatted: /repo/test.ps1
Already formatted: /repo/test.ps1
PSScriptAnalyzer passed: no findings under /repo
PSScriptAnalyzer passed: no findings under /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
No Pester test files found under configured paths for root /repo
Code coverage population: source=settings; files=1
No Pester test files found under configured paths for root /repo
Code coverage population: source=settings; files=1
Code coverage population: source=settings; files=1
Code coverage population: source=settings; files=1
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Comprehensive.Tests.ps1 1.24s (1.05s|160ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Coverage.Tests.ps1 292ms (244ms|34ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.CoverageConfig.Tests.ps1 171ms (119ms|38ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.CoverageMerge.Tests.ps1 165ms (125ms|29ms)
No PowerShell files found under .\tests\scripts\powershell\PoshQC
[+] .\tests\scripts\powershell\PoshQC\PoshQC.EntryPoints.Tests.ps1 148ms (76ms|60ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.ModuleCoverage.Tests.ps1 103ms (56ms|36ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.RunSettings.Tests.ps1 213ms (152ms|46ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.ScanConfig.Tests.ps1 114ms (59ms|45ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.ScanFolders.Tests.ps1 327ms (243ms|66ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Shard.Tests.ps1 238ms (147ms|66ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingCommands.Tests.ps1 170ms (104ms|52ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingCoveragePruning.Tests.ps1 133ms (97ms|26ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeConfigPaths.Tests.ps1 110ms (73ms|26ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingInvokeSummary.Tests.ps1 81ms (40ms|32ms)
Coverage file not found; skipping Koverage output: .\tests\scripts\powershell\PoshQC\poshqc-testing-line98-missing-coverage-392.xml
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingSeamDefaults.Tests.ps1 115ms (74ms|28ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.TestingShard.Tests.ps1 125ms (81ms|33ms)
[+] .\tests\scripts\powershell\PoshQC\PoshQC.Tests.ps1 222ms (162ms|44ms)
[+] .\tests\scripts\workflows\CiChangeScopeWorkflow.Tests.ps1 339ms (237ms|84ms)
[+] .\tests\scripts\workflows\CiWorkflow.Tests.ps1 107ms (62ms|35ms)
[+] .\tests\scripts\workflows\PoshQcWorkflow.Tests.ps1 111ms (60ms|39ms)
[+] .\tests\scripts\workflows\PublishMcpNpmWorkflow.Tests.ps1 122ms (64ms|40ms)
[+] .\tests\scripts\workflows\VerifyPublishedReleasesWorkflow.Tests.ps1 55ms (14ms|31ms)
Tests completed in 602.7s
Tests Passed: 11310, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 91.83% / 0%. 28,075 analyzed Commands in 215 Files.
```
