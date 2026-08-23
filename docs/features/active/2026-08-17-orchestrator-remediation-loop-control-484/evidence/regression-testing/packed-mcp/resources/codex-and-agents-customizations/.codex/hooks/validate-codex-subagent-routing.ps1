<#
.SYNOPSIS
    Requests continuation when a routed subagent stops without valid model or epic provenance.

.DESCRIPTION
    SubagentStop is a continuation mechanism, not a hard output rejection. This hook supplies the
    in-process backstop; the MCP checkpoint validator remains the authoritative completion gate.
#>
[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'codex-authority-store.ps1')

$script:CodexParallelStopPersonas = @('parallel-planner', 'parallel-orchestrator')

function ConvertFrom-CodexStopJson {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string] $Raw, [Parameter(Mandatory)][string] $Name)

    if ([string]::IsNullOrWhiteSpace($Raw)) {
        throw "MODEL_ROUTING_ATTESTATION_BLOCKED: $Name is empty."
    }
    try {
        return $Raw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "MODEL_ROUTING_ATTESTATION_BLOCKED: $Name is malformed JSON: $_"
    }
}

function Test-CodexStopGatedAgent {
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $AgentType)

    if ($AgentType -match '-c(?:1|2|3|4|3-elevated)$') {
        return $true
    }
    return @(
        'epic-planner', 'epic-orchestrator', 'parallel-planner',
        'parallel-orchestrator', 'orchestrator', 'atomic-planner',
        'atomic-executor', 'feature-review', 'feature-reviewer', 'task-researcher',
        'prd-feature', 'pr-author', 'python-typed-engineer', 'powershell-typed-engineer',
        'csharp-typed-engineer', 'typescript-engineer'
    ) -contains $AgentType
}

function Get-CodexStopContinuation {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)][string] $Reason,
        [Parameter(Mandatory)][bool] $AlreadyContinued
    )

    if ($AlreadyContinued) {
        return [ordered]@{
            continue      = $false
            stopReason    = $Reason
            systemMessage = $Reason
        }
    }
    return [ordered]@{
        decision = 'block'
        reason   = $Reason
    }
}

if (-not (Test-Path variable:script:LoadingCodexParallelAgentOutputHook)) {
    . (Join-Path $PSScriptRoot 'validate-parallel-agent-output.ps1')
}

function Invoke-CodexSubagentStopDecision {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string] $PayloadRaw,
        [AllowNull()][AllowEmptyString()][string] $AttestationRaw,
        [AllowNull()][AllowEmptyString()][string] $WorkspaceRoot = '',
        [AllowNull()][scriptblock] $ParallelOutputValidator
    )

    $payload = ConvertFrom-CodexStopJson -Raw $PayloadRaw -Name 'SubagentStop input'
    $agentType = [string]$payload.agent_type
    if (-not $agentType -or -not (Test-CodexStopGatedAgent -AgentType $agentType)) {
        return $null
    }
    $alreadyContinued = $payload.stop_hook_active -is [bool] -and [bool]$payload.stop_hook_active
    if ([string]::IsNullOrWhiteSpace($AttestationRaw)) {
        $marker = if (@('epic-planner', 'epic-orchestrator') -contains $agentType) {
            'EPIC_INVOCATION_ORIGIN_BLOCKED'
        } elseif ($agentType -in $script:CodexParallelStopPersonas) {
            'PARALLEL_INVOCATION_ORIGIN_BLOCKED'
        } else {
            'MODEL_ROUTING_ATTESTATION_BLOCKED'
        }
        $reason = '{0}: no SubagentStart attestation exists for ''{1}''.' -f $marker, $agentType
        return Get-CodexStopContinuation -Reason $reason -AlreadyContinued $alreadyContinued
    }

    $attestation = ConvertFrom-CodexStopJson -Raw $AttestationRaw -Name 'routing attestation'
    if ([string]$attestation.agent_id -ne [string]$payload.agent_id -or
        [string]$attestation.agent_type -ne $agentType) {
        return Get-CodexStopContinuation -Reason "MODEL_ROUTING_ATTESTATION_BLOCKED: attestation identity does not match '$agentType'." -AlreadyContinued $alreadyContinued
    }
    if (@('epic-planner', 'epic-orchestrator') -contains $agentType) {
        if ($attestation.provenance_valid -isnot [bool] -or -not [bool]$attestation.provenance_valid) {
            return Get-CodexStopContinuation -Reason "EPIC_INVOCATION_ORIGIN_BLOCKED: '$agentType' lacks valid root provenance." -AlreadyContinued $alreadyContinued
        }
    }
    if ($agentType -in $script:CodexParallelStopPersonas) {
        if ([string]$attestation.surface -cne 'parallel' -or
            $attestation.provenance_valid -isnot [bool] -or
            -not [bool]$attestation.provenance_valid -or
            $attestation.root_authorized -isnot [bool] -or
            -not [bool]$attestation.root_authorized) {
            return Get-CodexStopContinuation -Reason "PARALLEL_INVOCATION_ORIGIN_BLOCKED: '$agentType' lacks valid root provenance." -AlreadyContinued $alreadyContinued
        }
        if ([string]$attestation.actual_model -cne 'gpt-5.6-sol' -or
            [string]$attestation.expected_model -cne 'gpt-5.6-sol' -or
            [string]$attestation.profile_model -cne 'gpt-5.6-sol' -or
            [string]$attestation.actual_reasoning_effort -cne 'ultra' -or
            [string]$attestation.expected_reasoning_effort -cne 'ultra' -or
            $attestation.fallback_used -isnot [bool] -or
            [bool]$attestation.fallback_used -or
            [string]::IsNullOrWhiteSpace([string]$attestation.parallel_identity) -or
            [string]$attestation.parallel_identity -cne [string]$attestation.mutation_identity) {
            return Get-CodexStopContinuation -Reason "MODEL_ROUTING_ATTESTATION_BLOCKED: '$agentType' lacks exact Sol/Ultra no-fallback routing." -AlreadyContinued $alreadyContinued
        }
    }
    if ($attestation.routing_valid -isnot [bool] -or -not [bool]$attestation.routing_valid) {
        return Get-CodexStopContinuation -Reason "MODEL_ROUTING_ATTESTATION_BLOCKED: '$agentType' did not run under its recorded deployment model." -AlreadyContinued $alreadyContinued
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$payload.model) -and
        [string]$attestation.actual_model -ne [string]$payload.model) {
        return Get-CodexStopContinuation -Reason "MODEL_ROUTING_ATTESTATION_BLOCKED: stop model differs from the start attestation for '$agentType'." -AlreadyContinued $alreadyContinued
    }
    if ($agentType -in $script:CodexParallelStopPersonas -and
        $null -ne $ParallelOutputValidator) {
        if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
            throw 'PARALLEL_AGENT_OUTPUT_BLOCKED: workspace root is required.'
        }
        return & $ParallelOutputValidator $PayloadRaw $WorkspaceRoot
    }
    return $null
}

function Find-CodexStopAttestationRaw {
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $StateRoot, [Parameter(Mandatory)][string] $AgentId)

    if (-not (Test-Path -LiteralPath $StateRoot -PathType Container)) {
        return ''
    }
    foreach ($path in Get-ChildItem -LiteralPath $StateRoot -Filter 'codex-routing-attestation.*.json' -File) {
        try {
            $raw = Get-Content -Raw -LiteralPath $path.FullName
            $value = $raw | ConvertFrom-Json -ErrorAction Stop
            if ([string]$value.agent_id -eq $AgentId) {
                return $raw
            }
        } catch {
            continue
        }
    }
    return ''
}

if ($MyInvocation.InvocationName -eq '.') {
    return
}

try {
    $payloadRaw = [Console]::In.ReadToEnd()
    $payload = ConvertFrom-CodexStopJson -Raw $payloadRaw -Name 'SubagentStop input'
    $repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $sessionId = [string]$payload.session_id
    if ([string]::IsNullOrWhiteSpace($sessionId)) {
        throw 'MODEL_ROUTING_ATTESTATION_BLOCKED: SubagentStop session_id is empty.'
    }
    $surface = if ([string]$payload.agent_type -in $script:CodexParallelStopPersonas) {
        'parallel'
    } else {
        'epic'
    }
    $stateRoot = Get-CodexAuthorityStateRoot `
        -RepositoryRoot $repositoryRoot `
        -SessionId $sessionId `
        -Surface $surface
    $attestationRaw = Find-CodexStopAttestationRaw -StateRoot $stateRoot -AgentId ([string]$payload.agent_id)
    $decisionArguments = @{
        PayloadRaw     = $payloadRaw
        AttestationRaw = $attestationRaw
    }
    if ([string]$payload.agent_type -in $script:CodexParallelStopPersonas) {
        $decisionArguments['WorkspaceRoot'] = $repositoryRoot
        $decisionArguments['ParallelOutputValidator'] = {
            param($StopPayloadRaw, $WorkspaceRoot)
            Invoke-CodexParallelAgentOutputDecision `
                -PayloadRaw $StopPayloadRaw `
                -WorkspaceRoot $WorkspaceRoot
        }
    }
    $decision = Invoke-CodexSubagentStopDecision @decisionArguments
    if ($null -ne $decision) {
        $decision | ConvertTo-Json -Compress -Depth 5 | Write-Output
    }
    exit 0
} catch {
    [Console]::Error.WriteLine([string]$_)
    exit 2
}
