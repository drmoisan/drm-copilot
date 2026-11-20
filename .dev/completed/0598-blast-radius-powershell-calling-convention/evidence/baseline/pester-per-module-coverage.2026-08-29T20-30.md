# Per-module Pester line-coverage baseline — issue #598

Timestamp: 2026-08-29T20-30
Task: [P0-T10]

Command:
`pwsh -NoProfile -Command "$x = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'); foreach ($p in $x.report.package) { foreach ($s in @($p.sourcefile)) { $c = @($s.counter) | Where-Object { $_.type -eq 'LINE' }; if ($c) { '{0}|{1}|{2}|{3}' -f $p.name, $s.name, $c.covered, $c.missed } } }"`

This is the same command and the same report shape that `[P10-T5]` uses. It reads the coverage file
produced by `[P0-T7]`, and was run before any batch gate overwrote that file.

Field order per row: package directory | source file name | covered lines | missed lines.

EXIT_CODE: 0

Total rows printed: 88.

Output Summary: all 88 rows are recorded below. The absolute workspace-root prefix
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7/` has been stripped
from the package field so the rows are portable; the field is otherwise verbatim.

## The 27 `.claude/lib` module rows

These are the rows keyed by the 27 module file names in the plan's batch table.

```
.claude/lib/blast-radius|BlastRadius.psm1|109|0
.claude/lib/blast-radius|BlastRadiusConfig.psm1|80|0
.claude/lib/blast-radius|BlastRadiusExtraction.psm1|85|0
.claude/lib/blast-radius|BlastRadiusGlob.psm1|69|0
.claude/lib/blast-radius|BlastRadiusNormalization.psm1|50|0
.claude/lib/blast-radius|BlastRadiusTokenShape.psm1|19|0
.claude/lib/blast-radius|BlastRadiusValidation.psm1|96|3
.claude/lib/codex-routing|CodexDeployment.psm1|67|0
.claude/lib/codex-routing|CodexTopology.psm1|108|0
.claude/lib/discovery-validation|DiscoveryValidation.psm1|102|6
.claude/lib/hook-payload|HookPayload.psm1|99|4
.claude/lib/mermaid|MermaidGrammar.psm1|141|1
.claude/lib/mermaid|MermaidLineScanner.psm1|163|0
.claude/lib/mermaid|MermaidMarkdownFences.psm1|79|0
.claude/lib/mermaid|MermaidValidation.psm1|147|2
.claude/lib/model-routing|ModelRouting.psm1|46|0
.claude/lib/orchestrator-state|OrchestratorState.psm1|108|0
.claude/lib/orchestrator-state|OrchestratorStateCheckpointValue.psm1|65|0
.claude/lib/orchestrator-state|OrchestratorStateCodexModelReceipts.psm1|80|0
.claude/lib/orchestrator-state|OrchestratorStateCodexTopologyReceipts.psm1|80|0
.claude/lib/orchestrator-state|OrchestratorStateCompletion.psm1|96|0
.claude/lib/orchestrator-state|OrchestratorStateCompletionChecks.psm1|98|1
.claude/lib/orchestrator-state|OrchestratorStateModelReceipts.psm1|90|0
.claude/lib/orchestrator-state|OrchestratorStateReceipts.psm1|112|0
.claude/lib/orchestrator-state|OrchestratorStateRoutingContract.psm1|105|1
.claude/lib/orchestrator-state|OrchestratorStateRoutingMatrix.psm1|73|0
.claude/lib/orchestrator-state|OrchestratorStateUnconditional.psm1|28|0
```

Count by directory: `blast-radius` 7, `codex-routing` 2, `discovery-validation` 1, `hook-payload` 1,
`mermaid` 4, `model-routing` 1, `orchestrator-state` 11. Total 27.

## The remaining 61 rows

```
.claude/hooks|check-powershell-test-purity.ps1|51|4
.claude/hooks|check-python-test-purity.ps1|56|4
.claude/hooks|enforce-checkpoint-monotonic.ps1|90|4
.claude/hooks|enforce-completion-consistency.ps1|116|11
.claude/hooks|enforce-completion-helpers.ps1|40|3
.claude/hooks|enforce-discovery-artifact-gate.ps1|59|3
.claude/hooks|enforce-epic-invocation-origin.ps1|60|7
.claude/hooks|enforce-epic-merge-gate.ps1|108|4
.claude/hooks|enforce-epic-wave-barrier.ps1|90|1
.claude/hooks|enforce-epic-worktree-removal-gate.ps1|89|4
.claude/hooks|enforce-evidence-locations.ps1|36|4
.claude/hooks|enforce-feature-folder-order.ps1|41|4
.claude/hooks|enforce-mermaid-validation.ps1|73|6
.claude/hooks|enforce-model-routing-receipt.ps1|38|3
.claude/hooks|enforce-orchestration-preimplementation-gate-helpers.ps1|112|6
.claude/hooks|enforce-orchestration-preimplementation-gate-modes.ps1|130|2
.claude/hooks|enforce-orchestration-preimplementation-gate.ps1|132|18
.claude/hooks|enforce-parallel-abandon-gate.ps1|43|4
.claude/hooks|enforce-parallel-cohort-barrier-helpers.ps1|77|0
.claude/hooks|enforce-parallel-cohort-barrier.ps1|65|1
.claude/hooks|enforce-parallel-drift-gate-helpers.ps1|66|0
.claude/hooks|enforce-parallel-drift-gate.ps1|103|1
.claude/hooks|enforce-parallel-worktree-removal-gate.ps1|64|4
.claude/hooks|enforce-powershell-batch-budget.ps1|86|4
.claude/hooks|enforce-pr-author-skill-helpers.ps1|61|3
.claude/hooks|enforce-pr-author-skill.epic-base-branch.ps1|21|2
.claude/hooks|enforce-pr-author-skill.ps1|46|4
.claude/hooks|enforce-prd-feature-before-planner.ps1|95|9
.claude/hooks|enforce-promotion-mcp-only.ps1|47|4
.claude/hooks|enforce-python-batch-budget.ps1|86|4
.claude/hooks|persist-session-id.ps1|33|5
.claude/hooks|validate-bash.ps1|37|5
.claude/hooks|validate-discovery-artifact-gate.ps1|56|5
.claude/hooks|validate-orchestrator-output.ps1|104|6
.claude/hooks|validate-planner-output.ps1|107|7
.codex/hooks|check-powershell-test-purity.ps1|62|0
.codex/hooks|check-python-test-purity.ps1|67|0
.codex/hooks|codex-pretooluse-file-mapping.ps1|101|0
.codex/hooks|enforce-checkpoint-monotonic.ps1|103|1
.codex/hooks|enforce-completion-consistency.ps1|136|0
.codex/hooks|enforce-completion-helpers.ps1|33|10
.codex/hooks|enforce-epic-child-worktree-binding.ps1|153|7
.codex/hooks|enforce-epic-planning-only.ps1|126|9
.codex/hooks|enforce-evidence-locations.ps1|41|0
.codex/hooks|enforce-orchestration-preimplementation-gate-helpers.ps1|112|6
.codex/hooks|enforce-orchestration-preimplementation-gate-modes.ps1|130|2
.codex/hooks|enforce-orchestration-preimplementation-gate.ps1|137|25
.codex/hooks|enforce-powershell-batch-budget.ps1|84|3
.codex/hooks|enforce-python-batch-budget.ps1|84|3
.codex/hooks|record-subagent-routing-attestation.ps1|103|89
scripts/dev-tools|Invoke-FullRelease.ps1|95|9
scripts/dev-tools|Invoke-FullReleaseFlow.ps1|115|7
scripts/dev-tools|Invoke-MarketplacePublish.ps1|56|6
scripts/dev-tools|Invoke-ReleaseReconciliation.ps1|24|3
scripts/dev-tools|Invoke-ReleaseTagPush.ps1|75|2
scripts/dev-tools|Invoke-ReleaseVerification.ps1|56|9
scripts/dev-tools|Invoke-ReleaseVerificationHelpers.ps1|29|0
scripts/dev-tools|new-claude-worktree-session.ps1|46|29
scripts/powershell|Publish-DrmCopilotExtension.ps1|109|7
scripts/powershell/PoshQC|PoshQC.ScanConfig.psm1|44|2
scripts/powershell/PoshQC|PoshQC.Testing.psm1|202|0
```

## Acceptance evaluation

The artifact contains a row for each of the 27 module file names listed in the plan's batch table,
keyed by the enclosing `package` directory path. No module is recorded as
`NO BASELINE COVERAGE ROW`.
