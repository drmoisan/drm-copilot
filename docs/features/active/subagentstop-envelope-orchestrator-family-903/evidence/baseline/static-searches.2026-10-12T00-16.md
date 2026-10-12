# Baseline Static Searches ([P0-T15])

Timestamp: 2026-10-12T00-16
Command: the [P6-T1] to [P6-T7] searches over S-PROD-5 (AC-13 over .claude/hooks/validate-orchestrator-output.ps1 only), run by <SCRATCHPAD>/static.sh 5 (rg invoked through the session rg binary)
EXIT_CODE: 0
Output Summary: All counts equal the planning-time values.

MATCHES-AC-7: 16
MATCHES-AC-8: 8
MATCHES-AC-9: 10
MATCHES-AC-13: 1
MATCHES-AC-13-TOKEN: 0
MATCHES-AC-14: 2 (lines 51 and 59)
MATCHES-AC-21: 1 (.claude/hooks/validate-executor-output.ps1:265)
MATCHES-AC-22: 0

Matching lines:
== AC-7
.claude/hooks/validate-executor-output.ps1:23:    Reads the hook payload from CLAUDE_HOOK_INPUT as JSON. Exits 0 to allow
.claude/hooks/validate-executor-output.ps1:186:        return @{ Ok = $false; Message = 'atomic-executor hook: CLAUDE_HOOK_INPUT is empty; cannot validate executor output.' }
.claude/hooks/validate-executor-output.ps1:193:        return @{ Ok = $false; Message = "atomic-executor hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" }
.claude/hooks/validate-executor-output.ps1:290:$result = Invoke-ExecutorOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
.claude/hooks/validate-planner-output.ps1:25:    Reads the hook payload from CLAUDE_HOOK_INPUT as JSON. Exits 0 to allow
.claude/hooks/validate-planner-output.ps1:357:        return @{ Ok = $false; Message = 'atomic-planner hook: CLAUDE_HOOK_INPUT is empty; cannot validate planner output.' }
.claude/hooks/validate-planner-output.ps1:364:        return @{ Ok = $false; Message = "atomic-planner hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" }
.claude/hooks/validate-planner-output.ps1:410:$result = Invoke-PlannerOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT
.claude/hooks/validate-orchestrator-output.ps1:31:    Reads the hook payload from CLAUDE_HOOK_INPUT as JSON. Exits 0 to allow
.claude/hooks/validate-orchestrator-output.ps1:351:        return @{ Ok = $false; Message = 'orchestrator hook: CLAUDE_HOOK_INPUT is empty; cannot validate orchestrator output.' }
.claude/hooks/validate-orchestrator-output.ps1:357:        return @{ Ok = $false; Message = "orchestrator hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" }
.claude/hooks/validate-orchestrator-output.ps1:460:$result = Invoke-OrchestratorOutputValidation -RawPayload $env:CLAUDE_HOOK_INPUT -CheckpointPath $CheckpointPath -ArtifactType $ArtifactType
.claude/hooks/validate-required-artifact-output.ps1:18:    Reads the hook payload from CLAUDE_HOOK_INPUT as JSON. Exits 0 to allow
.claude/hooks/validate-required-artifact-output.ps1:102:        return @{ Ok = $false; Message = "$AgentName hook: CLAUDE_HOOK_INPUT is empty; cannot validate required artifact output." }
.claude/hooks/validate-required-artifact-output.ps1:109:        return @{ Ok = $false; Message = "$AgentName hook: failed to parse CLAUDE_HOOK_INPUT as JSON: $($_.Exception.Message)" }
.claude/hooks/validate-required-artifact-output.ps1:163:    -RawPayload $env:CLAUDE_HOOK_INPUT `
MATCH_COUNT: 16 EXIT_CODE: 0
== AC-8
.claude/hooks/validate-executor-output.ps1:197:    if ($payload.PSObject.Properties.Name -contains 'output') {
.claude/hooks/validate-executor-output.ps1:198:        $agentOutput = $payload.output
.claude/hooks/validate-planner-output.ps1:368:    if ($null -ne $payload.PSObject.Properties['output']) {
.claude/hooks/validate-planner-output.ps1:369:        $agentOutput = $payload.output
.claude/hooks/validate-required-artifact-output.ps1:113:    if ($payload.PSObject.Properties.Name -contains 'output') {
.claude/hooks/validate-required-artifact-output.ps1:114:        $agentOutput = $payload.output
.claude/hooks/validate-orchestrator-output.ps1:361:    if ($payload.PSObject.Properties.Name -contains 'output') {
.claude/hooks/validate-orchestrator-output.ps1:362:        $agentOutput = $payload.output
MATCH_COUNT: 8 EXIT_CODE: 0
== AC-9
.claude/hooks/validate-orchestrator-output.ps1:462:    Write-Error $result.Message
.claude/hooks/validate-orchestrator-output.ps1:463:    exit 1
.claude/hooks/validate-planner-output.ps1:412:    Write-Error $result.Message
.claude/hooks/validate-planner-output.ps1:413:    exit 1
.claude/hooks/validate-required-artifact-output.ps1:158:    Write-Error 'validate-required-artifact-output hook: AgentName and at least one RequiredArtifact spec are required.'
.claude/hooks/validate-required-artifact-output.ps1:159:    exit 1
.claude/hooks/validate-required-artifact-output.ps1:167:    Write-Error $result.Message
.claude/hooks/validate-required-artifact-output.ps1:168:    exit 1
.claude/hooks/validate-executor-output.ps1:292:    Write-Error $result.Message
.claude/hooks/validate-executor-output.ps1:293:    exit 1
MATCH_COUNT: 10 EXIT_CODE: 0
== AC-13
431:        # One subprocess call now covers both --require-complete and
MATCH_COUNT: 1 EXIT_CODE: 0
== AC-13-TOKEN
MATCH_COUNT: 0 EXIT_CODE: 1
== AC-14
51:try { Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorState.psm1') -Force -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'OrchestratorState.psm1' -ErrorRecord $_ }
59:try { Import-Module (Join-Path $PSScriptRoot '../lib/orchestrator-state/OrchestratorState.psm1') -Force -Global -ErrorAction Stop } catch { Add-HookDependencyFailure -Name 'OrchestratorState.psm1' -ErrorRecord $_ }
MATCH_COUNT: 2 EXIT_CODE: 0
== AC-21
.claude/hooks/validate-executor-output.ps1:265:    $hasCommandEvidence = $agentOutput -match '(?i)(Commands Run|Command[s]?:|poetry run |npx |pwsh |git |mcp__drm-copilot__)'
MATCH_COUNT: 1 EXIT_CODE: 0
== AC-22
MATCH_COUNT: 0 EXIT_CODE: 1
