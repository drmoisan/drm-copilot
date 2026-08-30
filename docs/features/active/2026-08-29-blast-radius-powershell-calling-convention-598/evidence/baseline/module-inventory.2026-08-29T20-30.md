# `.claude/lib` module inventory and help-block probe — issue #598

Timestamp: 2026-08-29T20-30
Task: [P0-T4]

Command:
`pwsh -NoProfile -Command "Get-ChildItem -Path '.claude/lib' -Filter '*.psm1' -File -Recurse | Sort-Object FullName | ForEach-Object { $l = @(Get-Content -LiteralPath $_.FullName); $t = @($l | ForEach-Object { $_.Trim() }); $s = 1 + [array]::IndexOf($t, 'Set-StrictMode -Version Latest'); $c = 1 + [array]::IndexOf($t, '#>'); '{0}|{1}|{2}|{3}' -f $_.Name, $l.Count, $s, $c }"`

Field order per row: module file name | total lines | 1-based line of the trimmed
`Set-StrictMode -Version Latest` anchor | 1-based line of the first trimmed `#>` closing fence.

EXIT_CODE: 0

Output Summary:

```
BlastRadius.psm1|493|52|50
BlastRadiusConfig.psm1|471|33|31
BlastRadiusExtraction.psm1|472|38|36
BlastRadiusGlob.psm1|429|36|34
BlastRadiusNormalization.psm1|295|32|30
BlastRadiusTokenShape.psm1|187|54|52
BlastRadiusValidation.psm1|372|35|33
CodexDeployment.psm1|312|41|39
CodexTopology.psm1|392|52|50
DiscoveryValidation.psm1|500|54|52
HookPayload.psm1|494|42|40
MermaidGrammar.psm1|491|33|31
MermaidLineScanner.psm1|488|35|33
MermaidMarkdownFences.psm1|298|37|35
MermaidValidation.psm1|496|42|40
ModelRouting.psm1|229|23|21
OrchestratorState.psm1|488|32|30
OrchestratorStateCheckpointValue.psm1|383|28|26
OrchestratorStateCodexModelReceipts.psm1|297|27|25
OrchestratorStateCodexTopologyReceipts.psm1|298|30|28
OrchestratorStateCompletion.psm1|432|49|47
OrchestratorStateCompletionChecks.psm1|416|38|36
OrchestratorStateModelReceipts.psm1|366|24|22
OrchestratorStateReceipts.psm1|408|32|30
OrchestratorStateRoutingContract.psm1|428|50|48
OrchestratorStateRoutingMatrix.psm1|377|38|36
OrchestratorStateUnconditional.psm1|166|42|40
```

## Acceptance evaluation

- Row count: 27. Matches the 27 modules enumerated in the plan's batch table.
- Third field greater than 1 for every row: the minimum observed value is 23
  (`ModelRouting.psm1`), so every module carries a located `Set-StrictMode -Version Latest` anchor.
- Fourth field greater than 1 and less than the third field for every row: each row's fourth field is
  exactly its third field minus 2, so every module's leading comment-based-help block closes two
  lines above its `Set-StrictMode` anchor. The missing-help-block branch of `[P0-T4]` does not fire
  and no module name is reported under it.
- `DiscoveryValidation.psm1` second field: 500, confirming zero headroom against the 500-line cap.

## Cross-check against the plan's line-count table

Every second field equals the line count the plan's batch table records for the same module,
including `DiscoveryValidation.psm1` at 500, `MermaidValidation.psm1` at 496,
`HookPayload.psm1` at 494, `BlastRadius.psm1` at 493, `MermaidGrammar.psm1` at 491, and both
`OrchestratorState.psm1` and `MermaidLineScanner.psm1` at 488.
