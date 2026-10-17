# Validator Tail Placement (issue #928)

Timestamp: 2026-10-16T02-05
Command: awk 'NF{a[++n]=$0} END{for(i=1;i<=n;i++) if(index(a[i],"try { $")==1) for(j=i-1;j<=n;j++) print a[j]}' <file> (run per file over the eight AC1 validators via SCRATCH/928/tail_placement.sh)
EXIT_CODE: 0

Output Summary: For each of the eight files exactly five nonblank lines print, in order: (1) the S1 tail line containing `exit $dependencyDecision.ExitCode` (for validate-required-artifact-output.ps1, the closing `}` of the argument check); (2) the `try {` line; (3) the `catch {` line (SubagentStopReportAndHaltLine for executor, orchestrator, planner, required-artifact; the literal ending `Report it to the operator and halt.` for discovery, pr-author, prd-feature, task-researcher); (4) the `if (-not` line; (5) `exit 0`. Result: PASS for all eight.

## .claude/hooks/validate-discovery-artifact-gate.ps1

```text
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
try { $result = Invoke-DiscoveryArtifactGateValidation }
catch { Exit-SubagentStopBlock -Message ('DISCOVERY_ARTIFACT_GATE_BLOCKED: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + 'This condition is not repairable by the subagent. Report it to the operator and halt.') }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

## .claude/hooks/validate-executor-output.ps1

```text
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
try { $result = Invoke-ExecutorOutputValidation }
catch { Exit-SubagentStopBlock -Message ('validate-executor-output: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + $script:SubagentStopReportAndHaltLine) }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

## .claude/hooks/validate-orchestrator-output.ps1

```text
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
try { $result = Invoke-OrchestratorOutputValidation -CheckpointPath $CheckpointPath -ArtifactType $ArtifactType }
catch { Exit-SubagentStopBlock -Message ('ORCHESTRATOR_CHECKPOINT_UNRESOLVED: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + $script:SubagentStopReportAndHaltLine) }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

## .claude/hooks/validate-planner-output.ps1

```text
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
try { $result = Invoke-PlannerOutputValidation }
catch { Exit-SubagentStopBlock -Message ('validate-planner-output: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + $script:SubagentStopReportAndHaltLine) }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

## .claude/hooks/validate-pr-author-output.ps1

```text
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
try { $decision = Get-PrAuthorOutputDecision }
catch { Exit-SubagentStopBlock -Message ('PR_AUTHOR_OUTPUT_MISSING: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + 'This condition is not repairable by the subagent. Report it to the operator and halt.') }
if (-not $decision['allowed']) { Exit-SubagentStopBlock -Message $decision['reason'] }
exit 0
```

## .claude/hooks/validate-prd-feature-output.ps1

```text
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
try { $result = Invoke-PrdFeatureOutputValidation }
catch { Exit-SubagentStopBlock -Message ('validate-prd-feature-output: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + 'This condition is not repairable by the subagent. Report it to the operator and halt.') }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

## .claude/hooks/validate-required-artifact-output.ps1

```text
}
try { $result = Invoke-RequiredArtifactOutputValidation -AgentName $AgentName -RequiredArtifact $RequiredArtifact }
catch { Exit-SubagentStopBlock -Message ('validate-required-artifact-output: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + $script:SubagentStopReportAndHaltLine) }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```

## .claude/hooks/validate-task-researcher-output.ps1

```text
if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }
try { $result = Invoke-TaskResearcherOutputValidation }
catch { Exit-SubagentStopBlock -Message ('validate-task-researcher-output: validator error: ' + ([string]$_.Exception.Message -split "`r?`n")[0] + '; the gate fails closed.' + "`n" + 'This condition is not repairable by the subagent. Report it to the operator and halt.') }
if (-not $result.Ok) { Exit-SubagentStopBlock -Message $result.Message }
exit 0
```
