# Final per-module Pester coverage rows — issue #598

Timestamp: 2026-08-30T02-26
Task: [P10-T5]

Command:
`pwsh -NoProfile -Command "$x = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'); foreach ($p in $x.report.package) { foreach ($s in @($p.sourcefile)) { $c = @($s.counter) | Where-Object { $_.type -eq 'LINE' }; if ($c) { '{0}|{1}|{2}|{3}' -f $p.name, $s.name, $c.covered, $c.missed } } }"`

This is the same command and the same report shape as `[P0-T10]` and `[P0-T18]`. It reads the
coverage file produced by the `[P10-T3]` run.

EXIT_CODE: 0

Row format is `PackageDirectoryPath|SourceFileName|LineCovered|LineMissed`. The command printed 88
rows, the same row count as the `[P0-T18]` baseline. Every row is reproduced below verbatim except
that the workspace-root prefix
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-aee68cdb110fb5da7/` is abbreviated to
`<WT>/` for readability; that abbreviation is applied uniformly and changes no field value. It is
the same abbreviation the `[P0-T18]` artifact applies, so the two are directly comparable.

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
<WT>/.claude/lib/blast-radius|BlastRadius.psm1|110|0
<WT>/.claude/lib/blast-radius|BlastRadiusConfig.psm1|81|0
<WT>/.claude/lib/blast-radius|BlastRadiusExtraction.psm1|86|0
<WT>/.claude/lib/blast-radius|BlastRadiusGlob.psm1|70|0
<WT>/.claude/lib/blast-radius|BlastRadiusNormalization.psm1|51|0
<WT>/.claude/lib/blast-radius|BlastRadiusTokenShape.psm1|20|0
<WT>/.claude/lib/blast-radius|BlastRadiusValidation.psm1|97|3
<WT>/.claude/lib/codex-routing|CodexDeployment.psm1|68|0
<WT>/.claude/lib/codex-routing|CodexTopology.psm1|109|0
<WT>/.claude/lib/discovery-validation|DiscoveryValidation.psm1|103|6
<WT>/.claude/lib/hook-payload|HookPayload.psm1|100|4
<WT>/.claude/lib/mermaid|MermaidGrammar.psm1|142|1
<WT>/.claude/lib/mermaid|MermaidLineScanner.psm1|164|0
<WT>/.claude/lib/mermaid|MermaidMarkdownFences.psm1|80|0
<WT>/.claude/lib/mermaid|MermaidValidation.psm1|148|2
<WT>/.claude/lib/model-routing|ModelRouting.psm1|47|0
<WT>/.claude/lib/orchestrator-state|OrchestratorState.psm1|109|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateCheckpointValue.psm1|66|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateCodexModelReceipts.psm1|81|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateCodexTopologyReceipts.psm1|81|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateCompletion.psm1|97|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateCompletionChecks.psm1|99|1
<WT>/.claude/lib/orchestrator-state|OrchestratorStateModelReceipts.psm1|91|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateReceipts.psm1|113|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateRoutingContract.psm1|106|1
<WT>/.claude/lib/orchestrator-state|OrchestratorStateRoutingMatrix.psm1|74|0
<WT>/.claude/lib/orchestrator-state|OrchestratorStateUnconditional.psm1|29|0
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

## Comparison against the `[P0-T18]` post-merge baseline

The comparand is `evidence/baseline/pester-per-module-coverage-postmerge.2026-08-29T23-10.md`,
written by `[P0-T18]`. The pre-merge `[P0-T10]` rows are not the comparand.

Each of the 27 module file names the batch table lists, excluding `GeneratedDocumentCounters.psm1`,
has exactly one row keyed by its enclosing `package` directory path. The keys are used rather than
bare file names because the same file name occurs under more than one package elsewhere in this
report — `check-powershell-test-purity.ps1`, for example, appears under both `<WT>/.claude/hooks`
and `<WT>/.codex/hooks`.

| Batch | Package directory key | Source file | Baseline covered | Final covered | Change |
| --- | --- | --- | --- | --- | --- |
| B01 | `<WT>/.claude/lib/discovery-validation` | `DiscoveryValidation.psm1` | 103 | 103 | 0 |
| B02 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorState.psm1` | 109 | 109 | 0 |
| B03 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorStateCheckpointValue.psm1` | 66 | 66 | 0 |
| B04 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorStateCompletion.psm1` | 97 | 97 | 0 |
| B05 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorStateCompletionChecks.psm1` | 99 | 99 | 0 |
| B06 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorStateReceipts.psm1` | 113 | 113 | 0 |
| B07 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorStateModelReceipts.psm1` | 91 | 91 | 0 |
| B08 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorStateCodexModelReceipts.psm1` | 80 | 81 | +1 |
| B09 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorStateCodexTopologyReceipts.psm1` | 80 | 81 | +1 |
| B10 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorStateRoutingContract.psm1` | 105 | 106 | +1 |
| B11 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorStateRoutingMatrix.psm1` | 73 | 74 | +1 |
| B12 | `<WT>/.claude/lib/orchestrator-state` | `OrchestratorStateUnconditional.psm1` | 28 | 29 | +1 |
| B13 | `<WT>/.claude/lib/blast-radius` | `BlastRadius.psm1` | 109 | 110 | +1 |
| B14 | `<WT>/.claude/lib/blast-radius` | `BlastRadiusConfig.psm1` | 80 | 81 | +1 |
| B15 | `<WT>/.claude/lib/blast-radius` | `BlastRadiusExtraction.psm1` | 85 | 86 | +1 |
| B16 | `<WT>/.claude/lib/blast-radius` | `BlastRadiusGlob.psm1` | 69 | 70 | +1 |
| B17 | `<WT>/.claude/lib/blast-radius` | `BlastRadiusNormalization.psm1` | 50 | 51 | +1 |
| B18 | `<WT>/.claude/lib/blast-radius` | `BlastRadiusTokenShape.psm1` | 19 | 20 | +1 |
| B19 | `<WT>/.claude/lib/blast-radius` | `BlastRadiusValidation.psm1` | 96 | 97 | +1 |
| B20 | `<WT>/.claude/lib/mermaid` | `MermaidGrammar.psm1` | 141 | 142 | +1 |
| B21 | `<WT>/.claude/lib/mermaid` | `MermaidLineScanner.psm1` | 163 | 164 | +1 |
| B22 | `<WT>/.claude/lib/mermaid` | `MermaidMarkdownFences.psm1` | 79 | 80 | +1 |
| B23 | `<WT>/.claude/lib/mermaid` | `MermaidValidation.psm1` | 147 | 148 | +1 |
| B24 | `<WT>/.claude/lib/model-routing` | `ModelRouting.psm1` | 46 | 47 | +1 |
| B25 | `<WT>/.claude/lib/codex-routing` | `CodexDeployment.psm1` | 67 | 68 | +1 |
| B26 | `<WT>/.claude/lib/codex-routing` | `CodexTopology.psm1` | 108 | 109 | +1 |
| B27 | `<WT>/.claude/lib/hook-payload` | `HookPayload.psm1` | 99 | 100 | +1 |

No `covered` count decreased. Twenty rows rose by exactly 1 and seven held constant. There is no
`COVERAGE REGRESSION` entry to record and nothing of that kind to report to the caller.

The pattern is consistent with the change made. The seven rows that held constant are batches B01
through B07, whose guard line was already committed and therefore already covered when the
`[P0-T18]` baseline was taken. The twenty rows that rose by 1 are batches B08 through B27, whose
guard line `$ErrorActionPreference = 'Stop'` executes at module load and is newly counted. Batch B28
produces no row. Twenty rows rising by one accounts exactly for the +20 movement in the report-level
covered total that `[P10-T4]` recorded (7317 to 7337).

The 61 rows outside `<WT>/.claude/lib/` are byte-identical to their `[P0-T18]` counterparts. No file
outside the edited module set changed coverage.

## The B28 module

A search for `GeneratedDocumentCounters` across the 88 printed rows returns zero matches, so
`.claude/lib/requirements/GeneratedDocumentCounters.psm1` produced no coverage row, exactly as at
baseline. This is the condition the plan records under "Recorded condition: the 28th module is
outside the coverage denominator": the module is absent from `CodeCoverage.Path` in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, which `spec.md` lists under
"Out of scope / non-goals" and which `[P10-T9]` asserts unmodified. No coverage was lost for this
module, because none was measured before the change either. It is recorded here rather than
silently omitted, and `[P10-T12]` records it in the spec's `### Execution deviations` subsection as
a follow-up for the owner of that settings file.

## Acceptance evaluation

- The artifact contains a row for each of the 27 module file names the batch table lists excluding
  `GeneratedDocumentCounters.psm1`, keyed by the enclosing `package` directory path. The comparison
  table above names all 27 with their keys.
- For each of those 27, the final `covered` count is not lower than the `covered` count recorded for
  the same `package|sourcefile` key in `[P0-T18]`. Twenty rose by 1, seven are unchanged, none fell.
- The artifact carries the explicit line
  `GeneratedDocumentCounters.psm1: NO COVERAGE ROW — absent from CodeCoverage.Path in scripts/powershell/PoshQC/settings/pester.runsettings.psd1, which spec.md places out of scope`,
  matching the line recorded by `[P0-T18]`.
- No other module lacks a row, so no additional `NO COVERAGE ROW` entry is required and there is
  nothing of that kind to report to the caller.

All four acceptance conditions hold.
