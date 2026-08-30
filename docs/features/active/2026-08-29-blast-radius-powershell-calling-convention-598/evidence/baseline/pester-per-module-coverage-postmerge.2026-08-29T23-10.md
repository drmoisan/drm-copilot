# Post-merge per-module Pester coverage rows — issue #598

Timestamp: 2026-08-29T23-10
Task: [P0-T18]

Command:
`pwsh -NoProfile -Command "$x = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'); foreach ($p in $x.report.package) { foreach ($s in @($p.sourcefile)) { $c = @($s.counter) | Where-Object { $_.type -eq 'LINE' }; if ($c) { '{0}|{1}|{2}|{3}' -f $p.name, $s.name, $c.covered, $c.missed } } }"`

This is the same command as `[P0-T10]`. It reads the coverage file that `[P0-T16]` produced, and it
ran before any batch gate overwrote that file, per sequencing constraint 8.

EXIT_CODE: 0

Row format is `PackageDirectoryPath|SourceFileName|LineCovered|LineMissed`. The command printed 88
rows. Every row is reproduced below verbatim except that the workspace-root prefix
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7/` is abbreviated to
`<WT>/` for readability; that abbreviation is applied uniformly and changes no field value.

Output Summary:

```
<WT>/.claude/hooks|check-powershell-test-purity.ps1|51|4
<WT>/.claude/hooks|check-python-test-purity.ps1|56|4
<WT>/.claude/hooks|enforce-checkpoint-monotonic.ps1|90|4
<WT>/.claude/hooks|enforce-completion-consistency.ps1|116|11
<WT>/.claude/hooks|enforce-completion-helpers.ps1|40|3
<WT>/.claude/hooks|enforce-discovery-artifact-gate.ps1|59|3
<WT>/.claude/hooks|enforce-epic-invocation-origin.ps1|60|7
<WT>/.claude/hooks|enforce-epic-merge-gate.ps1|108|4
<WT>/.claude/hooks|enforce-epic-wave-barrier.ps1|90|1
<WT>/.claude/hooks|enforce-epic-worktree-removal-gate.ps1|89|4
<WT>/.claude/hooks|enforce-evidence-locations.ps1|36|4
<WT>/.claude/hooks|enforce-feature-folder-order.ps1|41|4
<WT>/.claude/hooks|enforce-mermaid-validation.ps1|73|6
<WT>/.claude/hooks|enforce-model-routing-receipt.ps1|38|3
<WT>/.claude/hooks|enforce-orchestration-preimplementation-gate-helpers.ps1|112|6
<WT>/.claude/hooks|enforce-orchestration-preimplementation-gate-modes.ps1|130|2
<WT>/.claude/hooks|enforce-orchestration-preimplementation-gate.ps1|132|18
<WT>/.claude/hooks|enforce-parallel-abandon-gate.ps1|43|4
<WT>/.claude/hooks|enforce-parallel-cohort-barrier-helpers.ps1|77|0
<WT>/.claude/hooks|enforce-parallel-cohort-barrier.ps1|65|1
<WT>/.claude/hooks|enforce-parallel-drift-gate-helpers.ps1|66|0
<WT>/.claude/hooks|enforce-parallel-drift-gate.ps1|103|1
<WT>/.claude/hooks|enforce-parallel-worktree-removal-gate.ps1|64|4
<WT>/.claude/hooks|enforce-powershell-batch-budget.ps1|86|4
<WT>/.claude/hooks|enforce-pr-author-skill-helpers.ps1|61|3
<WT>/.claude/hooks|enforce-pr-author-skill.epic-base-branch.ps1|21|2
<WT>/.claude/hooks|enforce-pr-author-skill.ps1|46|4
<WT>/.claude/hooks|enforce-prd-feature-before-planner.ps1|95|9
<WT>/.claude/hooks|enforce-promotion-mcp-only.ps1|47|4
<WT>/.claude/hooks|enforce-python-batch-budget.ps1|86|4
<WT>/.claude/hooks|persist-session-id.ps1|33|5
<WT>/.claude/hooks|validate-bash.ps1|37|5
<WT>/.claude/hooks|validate-discovery-artifact-gate.ps1|56|5
<WT>/.claude/hooks|validate-orchestrator-output.ps1|104|6
<WT>/.claude/hooks|validate-planner-output.ps1|181|7
<WT>/.claude/lib/blast-radius|BlastRadius.psm1|109|0
<WT>/.claude/lib/blast-radius|BlastRadiusConfig.psm1|80|0
<WT>/.claude/lib/blast-radius|BlastRadiusExtraction.psm1|85|0
<WT>/.claude/lib/blast-radius|BlastRadiusGlob.psm1|69|0
<WT>/.claude/lib/blast-radius|BlastRadiusNormalization.psm1|50|0
<WT>/.claude/lib/blast-radius|BlastRadiusTokenShape.psm1|19|0
<WT>/.claude/lib/blast-radius|BlastRadiusValidation.psm1|96|3
<WT>/.claude/lib/codex-routing|CodexDeployment.psm1|67|0
<WT>/.claude/lib/codex-routing|CodexTopology.psm1|108|0
<WT>/.claude/lib/discovery-validation|DiscoveryValidation.psm1|103|6
<WT>/.claude/lib/hook-payload|HookPayload.psm1|99|4
<WT>/.claude/lib/mermaid|MermaidGrammar.psm1|141|1
<WT>/.claude/lib/mermaid|MermaidLineScanner.psm1|163|0
<WT>/.claude/lib/mermaid|MermaidMarkdownFences.psm1|79|0
<WT>/.claude/lib/mermaid|MermaidValidation.psm1|147|2
<WT>/.claude/lib/model-routing|ModelRouting.psm1|46|0
<WT>/.claude/lib/orchestrator-state|OrchestratorState.psm1|109|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateCheckpointValue.psm1|66|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateCodexModelReceipts.psm1|80|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateCodexTopologyReceipts.psm1|80|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateCompletion.psm1|97|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateCompletionChecks.psm1|99|1
<WT>/.claude/lib/orchestrator-state|OrchestratorStateModelReceipts.psm1|91|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateReceipts.psm1|113|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateRoutingContract.psm1|105|1
<WT>/.claude/lib/orchestrator-state|OrchestratorStateRoutingMatrix.psm1|73|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateUnconditional.psm1|28|0
<WT>/.codex/hooks|check-powershell-test-purity.ps1|62|0
<WT>/.codex/hooks|check-python-test-purity.ps1|67|0
<WT>/.codex/hooks|codex-pretooluse-file-mapping.ps1|101|0
<WT>/.codex/hooks|enforce-checkpoint-monotonic.ps1|103|1
<WT>/.codex/hooks|enforce-completion-consistency.ps1|136|0
<WT>/.codex/hooks|enforce-completion-helpers.ps1|33|10
<WT>/.codex/hooks|enforce-epic-child-worktree-binding.ps1|153|7
<WT>/.codex/hooks|enforce-epic-planning-only.ps1|126|9
<WT>/.codex/hooks|enforce-evidence-locations.ps1|41|0
<WT>/.codex/hooks|enforce-orchestration-preimplementation-gate-helpers.ps1|112|6
<WT>/.codex/hooks|enforce-orchestration-preimplementation-gate-modes.ps1|130|2
<WT>/.codex/hooks|enforce-orchestration-preimplementation-gate.ps1|137|25
<WT>/.codex/hooks|enforce-powershell-batch-budget.ps1|84|3
<WT>/.codex/hooks|enforce-python-batch-budget.ps1|84|3
<WT>/.codex/hooks|record-subagent-routing-attestation.ps1|103|89
<WT>/scripts/dev-tools|Invoke-FullRelease.ps1|95|9
<WT>/scripts/dev-tools|Invoke-FullReleaseFlow.ps1|115|7
<WT>/scripts/dev-tools|Invoke-MarketplacePublish.ps1|56|6
<WT>/scripts/dev-tools|Invoke-ReleaseReconciliation.ps1|24|3
<WT>/scripts/dev-tools|Invoke-ReleaseTagPush.ps1|75|2
<WT>/scripts/dev-tools|Invoke-ReleaseVerification.ps1|56|9
<WT>/scripts/dev-tools|Invoke-ReleaseVerificationHelpers.ps1|29|0
<WT>/scripts/dev-tools|new-claude-worktree-session.ps1|46|29
<WT>/scripts/powershell|Publish-DrmCopilotExtension.ps1|109|7
<WT>/scripts/powershell/PoshQC|PoshQC.ScanConfig.psm1|44|2
<WT>/scripts/powershell/PoshQC|PoshQC.Testing.psm1|202|0
```

GeneratedDocumentCounters.psm1: NO COVERAGE ROW — absent from CodeCoverage.Path in scripts/powershell/PoshQC/settings/pester.runsettings.psd1, which spec.md places out of scope

## Coverage-row coverage of the batch table

Exactly 27 rows are keyed by a `<WT>/.claude/lib/...` package directory path. Each of the 27 module
file names the batch table lists for batches B01 through B27 has one such row:

| Batch | Module file name | Package directory key | Covered | Missed |
| --- | --- | --- | --- | --- |
| B01 | `DiscoveryValidation.psm1` | `<WT>/.claude/lib/discovery-validation` | 103 | 6 |
| B02 | `OrchestratorState.psm1` | `<WT>/.claude/lib/orchestrator-state` | 109 | 0 |
| B03 | `OrchestratorStateCheckpointValue.psm1` | `<WT>/.claude/lib/orchestrator-state` | 66 | 0 |
| B04 | `OrchestratorStateCompletion.psm1` | `<WT>/.claude/lib/orchestrator-state` | 97 | 0 |
| B05 | `OrchestratorStateCompletionChecks.psm1` | `<WT>/.claude/lib/orchestrator-state` | 99 | 1 |
| B06 | `OrchestratorStateReceipts.psm1` | `<WT>/.claude/lib/orchestrator-state` | 113 | 0 |
| B07 | `OrchestratorStateModelReceipts.psm1` | `<WT>/.claude/lib/orchestrator-state` | 91 | 0 |
| B08 | `OrchestratorStateCodexModelReceipts.psm1` | `<WT>/.claude/lib/orchestrator-state` | 80 | 0 |
| B09 | `OrchestratorStateCodexTopologyReceipts.psm1` | `<WT>/.claude/lib/orchestrator-state` | 80 | 0 |
| B10 | `OrchestratorStateRoutingContract.psm1` | `<WT>/.claude/lib/orchestrator-state` | 105 | 1 |
| B11 | `OrchestratorStateRoutingMatrix.psm1` | `<WT>/.claude/lib/orchestrator-state` | 73 | 0 |
| B12 | `OrchestratorStateUnconditional.psm1` | `<WT>/.claude/lib/orchestrator-state` | 28 | 0 |
| B13 | `BlastRadius.psm1` | `<WT>/.claude/lib/blast-radius` | 109 | 0 |
| B14 | `BlastRadiusConfig.psm1` | `<WT>/.claude/lib/blast-radius` | 80 | 0 |
| B15 | `BlastRadiusExtraction.psm1` | `<WT>/.claude/lib/blast-radius` | 85 | 0 |
| B16 | `BlastRadiusGlob.psm1` | `<WT>/.claude/lib/blast-radius` | 69 | 0 |
| B17 | `BlastRadiusNormalization.psm1` | `<WT>/.claude/lib/blast-radius` | 50 | 0 |
| B18 | `BlastRadiusTokenShape.psm1` | `<WT>/.claude/lib/blast-radius` | 19 | 0 |
| B19 | `BlastRadiusValidation.psm1` | `<WT>/.claude/lib/blast-radius` | 96 | 3 |
| B20 | `MermaidGrammar.psm1` | `<WT>/.claude/lib/mermaid` | 141 | 1 |
| B21 | `MermaidLineScanner.psm1` | `<WT>/.claude/lib/mermaid` | 163 | 0 |
| B22 | `MermaidMarkdownFences.psm1` | `<WT>/.claude/lib/mermaid` | 79 | 0 |
| B23 | `MermaidValidation.psm1` | `<WT>/.claude/lib/mermaid` | 147 | 2 |
| B24 | `ModelRouting.psm1` | `<WT>/.claude/lib/model-routing` | 46 | 0 |
| B25 | `CodexDeployment.psm1` | `<WT>/.claude/lib/codex-routing` | 67 | 0 |
| B26 | `CodexTopology.psm1` | `<WT>/.claude/lib/codex-routing` | 108 | 0 |
| B27 | `HookPayload.psm1` | `<WT>/.claude/lib/hook-payload` | 99 | 4 |

## The B28 module

A search for `GeneratedDocumentCounters` across the 88 printed rows returns zero matches, so
`.claude/lib/requirements/GeneratedDocumentCounters.psm1` produced no coverage row. This is the
condition the plan records under "Recorded condition: the 28th module is outside the coverage
denominator": the module is absent from `CodeCoverage.Path` in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, which `spec.md` lists under
"Out of scope / non-goals", so the entry is not added here. The absence is recorded explicitly above
rather than silently omitted. `[P10-T12]` records it in the spec's `### Execution deviations`
subsection as a follow-up for the owner of `pester.runsettings.psd1`.

## Acceptance evaluation

- The artifact contains a row for each of the 27 module file names the batch table lists excluding
  `GeneratedDocumentCounters.psm1`, keyed by the enclosing `package` directory path. The mapping
  table above names all 27 with their keys.
- The artifact carries the explicit line
  `GeneratedDocumentCounters.psm1: NO COVERAGE ROW — absent from CodeCoverage.Path in scripts/powershell/PoshQC/settings/pester.runsettings.psd1, which spec.md places out of scope`.
- No other module lacks a row, so no `NO BASELINE COVERAGE ROW` entry is required and there is
  nothing of that kind to report to the caller.

All three acceptance conditions hold. These rows are the comparands for `[P10-T5]`.
