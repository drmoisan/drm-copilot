<#
.SYNOPSIS
    Denies parallel mutations without valid root authority and persona provenance.

.DESCRIPTION
    PreToolUse hook. Reads native Codex stdin, resolves the surface-specific
    SubagentStart attestation, and validates that only a forced parallel persona
    carrying one fresh root authority identity may mutate parallel state.
    Mutation inputs must bind to that same parallel identity.
#>
[CmdletBinding()]
param()

. (Join-Path $PSScriptRoot 'codex-authority-store.ps1')
. (Join-Path $PSScriptRoot 'parallel-hook-common.ps1')

$script:ParallelRootPersonas = @('parallel-planner', 'parallel-orchestrator')

function Get-CodexParallelRootAttestationKey {
    <#
    .SYNOPSIS
        Derives the established transcript-bound attestation key.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $TranscriptPath
    )

    return Get-CodexAuthoritySha256 -Text $TranscriptPath
}

function Test-CodexParallelScopedInput {
    <#
    .SYNOPSIS
        Identifies a tool input that explicitly addresses the parallel surface.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param([Parameter(Mandatory)][AllowNull()] $ToolInput)

    if ($null -eq $ToolInput) {
        return $false
    }
    foreach ($field in @('surface', 'route_id')) {
        if ($ToolInput.PSObject.Properties.Name -contains $field -and
            [string]$ToolInput.$field -eq 'parallel') {
            return $true
        }
    }
    if ($ToolInput.PSObject.Properties.Name -contains 'artifact_type' -and
        [string]$ToolInput.artifact_type -match '^parallel-') {
        return $true
    }
    return @($ToolInput.PSObject.Properties.Name) -contains 'mutation'
}

function Get-CodexParallelMutationIdentity {
    <#
    .SYNOPSIS
        Resolves the parallel identity supplied by a mutation-shaped input.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowNull()] $ToolInput)

    if ($null -eq $ToolInput) {
        return ''
    }
    foreach ($field in @('parallel_identity', 'mutation_identity')) {
        if ($ToolInput.PSObject.Properties.Name -contains $field) {
            return ([string]$ToolInput.$field).Trim()
        }
    }
    if ($ToolInput.PSObject.Properties.Name -contains 'mutation' -and
        $null -ne $ToolInput.mutation) {
        foreach ($field in @('parallel_identity', 'mutation_identity')) {
            if ($ToolInput.mutation.PSObject.Properties.Name -contains $field) {
                return ([string]$ToolInput.mutation.$field).Trim()
            }
        }
    }
    return ''
}

function Get-CodexParallelRootError {
    <#
    .SYNOPSIS
        Returns stable provenance errors for one parsed native payload.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] $ToolInput,
        [Parameter(Mandatory)] $Payload,
        [AllowNull()][AllowEmptyString()][string] $AttestationRaw
    )

    $agentType = [string]$Payload.agent_type
    $isParallelAgent = $script:ParallelRootPersonas -contains $agentType
    if (-not $isParallelAgent -and -not (Test-CodexParallelScopedInput -ToolInput $ToolInput)) {
        return
    }
    if ([string]::IsNullOrWhiteSpace($AttestationRaw)) {
        return "$agentType has no matching parallel SubagentStart attestation"
    }

    try {
        $attestation = $AttestationRaw | ConvertFrom-Json -ErrorAction Stop
    } catch {
        return 'the parallel routing attestation is malformed JSON'
    }
    if ($script:ParallelRootPersonas -notcontains [string]$attestation.agent_type -or
        [string]$attestation.agent_type -ne $agentType -or
        [string]$attestation.agent_id -ne [string]$Payload.agent_id) {
        return 'the parallel routing attestation identity does not match the active persona'
    }
    if ([string]$attestation.surface -ne 'parallel' -or
        $attestation.provenance_valid -isnot [bool] -or
        -not [bool]$attestation.provenance_valid -or
        $attestation.root_authorized -isnot [bool] -or
        -not [bool]$attestation.root_authorized) {
        return 'the forced parallel persona lacks valid root-session authority'
    }
    $expectedPersona = if ([string]$attestation.root_entry_kind -eq 'parallel-plan') {
        'parallel-planner'
    } elseif ([string]$attestation.root_entry_kind -in @('parallel-run', 'parallel-orchestrate')) {
        'parallel-orchestrator'
    } else {
        ''
    }
    if ([string]::IsNullOrWhiteSpace($expectedPersona) -or $agentType -cne $expectedPersona) {
        return 'the root parallel entry does not authorize the active forced persona'
    }
    if ($attestation.routing_valid -isnot [bool] -or
        -not [bool]$attestation.routing_valid -or
        -not [string]::IsNullOrWhiteSpace([string]$attestation.profile_validation_error) -or
        [string]$attestation.expected_model -cne 'gpt-5.6-sol' -or
        [string]$attestation.actual_model -cne 'gpt-5.6-sol' -or
        [string]$attestation.profile_model -cne 'gpt-5.6-sol' -or
        [string]$attestation.expected_reasoning_effort -cne 'ultra' -or
        [string]$attestation.actual_reasoning_effort -cne 'ultra') {
        return 'the forced parallel persona lacks exact Sol/Ultra routing authority'
    }
    if ($attestation.PSObject.Properties.Name -notcontains 'fallback_used' -or
        $attestation.fallback_used -isnot [bool] -or
        [bool]$attestation.fallback_used) {
        return 'the parallel routing attestation does not prove no-fallback routing'
    }
    $parallelIdentity = ([string]$attestation.parallel_identity).Trim()
    $mutationAuthorityIdentity = ([string]$attestation.mutation_identity).Trim()
    if ([string]::IsNullOrWhiteSpace($parallelIdentity) -or
        $parallelIdentity -cne $mutationAuthorityIdentity) {
        return 'the parallel routing attestation lacks one shared parallel mutation identity'
    }

    $isMutation = @($ToolInput.PSObject.Properties.Name) -contains 'mutation'
    if ($isMutation) {
        $mutationIdentity = Get-CodexParallelMutationIdentity -ToolInput $ToolInput
        if ([string]::IsNullOrWhiteSpace($mutationIdentity) -or
            $mutationIdentity -cne $parallelIdentity) {
            return 'the mutation identity does not match the authorized parallel identity'
        }
    }
    return
}

function Find-CodexParallelRootAttestation {
    <#
    .SYNOPSIS
        Resolves one exact parallel attestation by transcript or agent identity.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)] $Payload,
        [Parameter(Mandatory)][string] $RepositoryRoot
    )

    $sessionId = [string]$Payload.session_id
    if ([string]::IsNullOrWhiteSpace($sessionId)) {
        return ''
    }
    $stateRoot = Get-CodexAuthorityStateRoot `
        -RepositoryRoot $RepositoryRoot `
        -SessionId $sessionId `
        -Surface parallel
    $transcriptPath = [string]$Payload.transcript_path
    if (-not [string]::IsNullOrWhiteSpace($transcriptPath)) {
        $key = Get-CodexParallelRootAttestationKey -TranscriptPath $transcriptPath
        $path = Get-CodexAuthorityAttestationPath `
            -RepositoryRoot $RepositoryRoot `
            -SessionId $sessionId `
            -AttestationKey $key `
            -Surface parallel
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            return Get-Content -Raw -LiteralPath $path
        }
    }
    if (-not (Test-Path -LiteralPath $stateRoot -PathType Container)) {
        return ''
    }
    foreach ($path in Get-ChildItem -LiteralPath $stateRoot -Filter 'codex-routing-attestation.*.json' -File) {
        try {
            $raw = Get-Content -Raw -LiteralPath $path.FullName
            $attestation = $raw | ConvertFrom-Json -ErrorAction Stop
            if ([string]$attestation.agent_id -eq [string]$Payload.agent_id) {
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

$payloadRaw = [Console]::In.ReadToEnd()
try {
    $payload = ConvertFrom-CodexParallelHookPayload `
        -PayloadRaw $payloadRaw `
        -HookName 'enforce-parallel-root-invocation'
    $repositoryRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $attestationRaw = Find-CodexParallelRootAttestation `
        -Payload $payload `
        -RepositoryRoot $repositoryRoot
    $result = Invoke-CodexParallelHookValidation `
        -HookName 'enforce-parallel-root-invocation' `
        -ReasonCode 'PARALLEL_INVOCATION_ORIGIN_BLOCKED' `
        -PayloadRaw $payloadRaw `
        -Validator {
        param($toolInput, $parsedPayload)
        Get-CodexParallelRootError `
            -ToolInput $toolInput `
            -Payload $parsedPayload `
            -AttestationRaw $attestationRaw
    }
    exit (Write-CodexParallelHookResult -Result $result)
} catch {
    [Console]::Error.WriteLine([string]$_)
    exit 2
}
