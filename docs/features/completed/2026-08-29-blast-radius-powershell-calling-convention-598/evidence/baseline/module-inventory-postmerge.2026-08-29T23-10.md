# Post-merge module inventory and leading-help-block probe — issue #598

Timestamp: 2026-08-29T23-10
Task: [P0-T13]

Command:
`pwsh -NoProfile -Command "Get-ChildItem -Path '.claude/lib' -Filter '*.psm1' -File -Recurse | Sort-Object FullName | ForEach-Object { $l = @(Get-Content -LiteralPath $_.FullName); $t = @($l | ForEach-Object { $_.Trim() }); $s = 1 + [array]::IndexOf($t, 'Set-StrictMode -Version Latest'); $c = 1 + [array]::IndexOf($t, '#>'); '{0}|{1}|{2}|{3}' -f $_.Name, $l.Count, $s, $c }"`

EXIT_CODE: 0

Row format is `Name|LineCount|SetStrictModeLine|FirstClosingHelpFenceLine`.

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
DiscoveryValidation.psm1|500|53|51
HookPayload.psm1|494|42|40
MermaidGrammar.psm1|491|33|31
MermaidLineScanner.psm1|488|35|33
MermaidMarkdownFences.psm1|298|37|35
MermaidValidation.psm1|496|42|40
ModelRouting.psm1|229|23|21
OrchestratorState.psm1|499|33|31
OrchestratorStateCheckpointValue.psm1|385|29|27
OrchestratorStateCodexModelReceipts.psm1|297|27|25
OrchestratorStateCodexTopologyReceipts.psm1|298|30|28
OrchestratorStateCompletion.psm1|434|50|48
OrchestratorStateCompletionChecks.psm1|418|39|37
OrchestratorStateModelReceipts.psm1|368|25|23
OrchestratorStateReceipts.psm1|410|33|31
OrchestratorStateRoutingContract.psm1|428|50|48
OrchestratorStateRoutingMatrix.psm1|377|38|36
OrchestratorStateUnconditional.psm1|166|42|40
GeneratedDocumentCounters.psm1|32|1|6
```

Row count: 28.

## Acceptance evaluation

- **Exactly 28 rows.** The output above carries 28 rows. This is the post-merge figure; `[P0-T4]`
  recorded 27 against the pre-merge tree and remains correct for that tree.
- **The `GeneratedDocumentCounters.psm1` row.** Exactly one row names it, and that row is
  `GeneratedDocumentCounters.psm1|32|1|6`: second field `32`, third field `1`, fourth field `6`.
  The fourth field is greater than the third, which is the machine-readable form of the finding that
  this module's first `#>` follows rather than precedes its `Set-StrictMode -Version Latest` line.
  This is the one case the `[P0-T4]` stop-branch was written for. Its resolution is already fixed by
  the plan under "Decision: placement of the convention sentence in the 28th module", so this task
  records the finding and does not stop.
- **Every other row's fourth field is less than its third field.** Each of the other 27 rows shows a
  fourth field exactly two less than its third field, so all 27 place their first `#>` above their
  `Set-StrictMode -Version Latest` line. No other row triggers the stop-and-report branch.
- **No row's second field exceeds 500.** The maximum second field is `500`
  (`DiscoveryValidation.psm1`); the next largest are `499` (`OrchestratorState.psm1`) and `496`
  (`MermaidValidation.psm1`). None exceeds the 500-line cap in
  `.claude/rules/general-code-change.md`.

All four acceptance conditions hold.
