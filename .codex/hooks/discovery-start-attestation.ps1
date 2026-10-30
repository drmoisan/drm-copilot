<#
.SYNOPSIS
    Codex SubagentStart attestation for discovery specialists through the protected discovery store.

.DESCRIPTION
    Dot-sourced by record-subagent-routing-attestation.ps1. A Codex start whose agent
    type names a discovery specialist is attested against the explicit
    `discovery-invocation` receipt the root prepared in the protected store, through
    the shared DiscoveryStart module (published under .codex/lib/discovery-validation,
    or read from .claude/lib when this repository hosts itself). The result is
    projected into the schema-2 routing attestation the Codex PreToolUse gates
    already consume, with receipt_kind `discovery-invocation`, so an unattested or
    drifted specialist is denied before its first tool use. No orchestrator
    checkpoint, repository HEAD or epic receipt is read for a discovery start.
#>
[CmdletBinding()]
param()

$script:CodexDiscoveryAgentTypePattern = '^(legacy-parity-analyst|runtime-characterization-analyst|requirements-reconciler|migration-coverage-reviewer)(-c(1|2|3|4|3-elevated))?$'
$script:CodexDiscoveryStartPrefix = 'DISCOVERY_START_ATTESTATION_BLOCKED:'
$script:CodexDiscoveryStartModules = @('DiscoveryEncoding.psm1', 'DiscoveryAuthority.psm1', 'DiscoveryPayload.psm1', 'DiscoveryStartRecord.psm1', 'DiscoveryStart.psm1')

function Test-CodexDiscoveryAgentType {
    [CmdletBinding()]
    [OutputType([bool])]
    param([AllowNull()][AllowEmptyString()][string] $AgentType)

    return -not [string]::IsNullOrWhiteSpace($AgentType) -and $AgentType -cmatch $script:CodexDiscoveryAgentTypePattern
}

function Get-CodexDiscoveryStartModulePath {
    <#
    .SYNOPSIS
        Returns the published (.codex/lib) or self-hosting (.claude/lib) path of one helper module.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $ModuleName,
        [string] $ScriptRoot = $PSScriptRoot
    )

    $published = Join-Path $ScriptRoot "../lib/discovery-validation/$ModuleName"
    $selfHosted = Join-Path $ScriptRoot "../../.claude/lib/discovery-validation/$ModuleName"
    foreach ($candidate in @($published, $selfHosted)) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { return $candidate }
    }
    return $published
}

function Import-CodexDiscoveryStartModule {
    <#
    .SYNOPSIS
        Loads the shared discovery modules a discovery start needs; ordinary starts never load them.
    #>
    [CmdletBinding()]
    param([string] $ScriptRoot = $PSScriptRoot)

    foreach ($moduleName in $script:CodexDiscoveryStartModules) {
        Import-Module (Get-CodexDiscoveryStartModulePath -ModuleName $moduleName -ScriptRoot $ScriptRoot) -Force -Global -ErrorAction Stop
    }
}

function Get-CodexDiscoveryStartAttestation {
    <#
    .SYNOPSIS
        Builds the schema-2 attestation of a Codex discovery start from the protected invocation.
    .DESCRIPTION
        The actual model comes from the SubagentStart payload and the actual effort and
        profile hash from the generated Codex profile; both must equal the deployment
        the root prepared. routing_valid is true only when the shared decision
        attested the start; discovery_code and discovery_reason carry the decision.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory)] $Payload,
        [Parameter(Mandatory)][string] $RepositoryRoot,
        [Parameter(Mandatory)][datetimeoffset] $Now,
        [AllowNull()][hashtable] $HostEnvironment = $null,
        [AllowNull()][hashtable] $Store = $null,
        [AllowNull()][string] $Nonce = $null,
        [AllowNull()] $AgentProfile = $null,
        [string] $HandlerPath = (Join-Path $PSScriptRoot 'record-subagent-routing-attestation.ps1')
    )

    $agentId = [string]$Payload.agent_id
    $agentType = [string]$Payload.agent_type
    $model = [string]$Payload.model
    if (-not $agentId -or -not $agentType -or -not $model) {
        throw "$($script:CodexDiscoveryStartPrefix) SubagentStart requires agent_id, agent_type, and model."
    }
    Import-CodexDiscoveryStartModule
    $profileValidationError = $null
    if ($null -eq $AgentProfile) {
        try { $AgentProfile = Get-CodexAgentProfileAttestation -RepositoryRoot $RepositoryRoot -AgentType $agentType } catch { $profileValidationError = [string]$_ }
    }
    $sharedProfile = $(if ($null -ne $AgentProfile) { ConvertTo-CodexSharedAgentProfile -AgentProfile $AgentProfile } else { $null })
    # The principal comes from the payload alone: Codex supplies no parent identifier, so the parent is the literal root.
    $normalized = [pscustomobject]@{
        HostName = 'codex'; Event = 'SubagentStart'; SessionId = [string]$Payload.session_id; AgentId = $agentId; AgentType = $agentType; ParentAgentId = $null
        ToolName = $null; ToolInput = $null; Cwd = $RepositoryRoot; ToolUseId = $null; Anomaly = $null
    }
    if ([string]::IsNullOrWhiteSpace($normalized.SessionId)) { $normalized.Anomaly = 'MissingSessionId' }
    $handlerSha256 = $(if (Test-Path -LiteralPath $HandlerPath -PathType Leaf) { Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes($HandlerPath)) } else { '0' * 64 })
    $parameters = @{ Normalized = $normalized; HandlerSha256 = $handlerSha256; Now = $Now.UtcDateTime; ActualModel = $model }
    $parameters['HostEnvironment'] = $(if ($null -ne $HostEnvironment) { $HostEnvironment } else { Get-DiscoveryTrustedHostEnvironment })
    if ($null -ne $Store) { $parameters['Store'] = $Store }
    if (-not [string]::IsNullOrEmpty($Nonce)) { $parameters['Nonce'] = $Nonce }
    if ($null -ne $sharedProfile) { $parameters['AgentProfile'] = $sharedProfile; $parameters['ActualReasoningEffort'] = $sharedProfile.ProfileReasoningEffort }
    $outcome = $(if ($null -eq $sharedProfile) {
            [pscustomobject]@{ Decision = 'deny'; Code = 'PROFILE'; Reason = "the agent profile could not be read: $profileValidationError"; Attestation = $null; AttestationPath = $null; Invocation = $null }
        } else { Get-DiscoveryStartDecision @parameters })
    $record = $outcome.Invocation
    $attested = ($outcome.Decision -eq 'attest')
    return [ordered]@{
        schema_version              = 2
        receipt_kind                = 'discovery-invocation'
        session_id                  = [string]$Payload.session_id
        turn_id                     = [string]$Payload.turn_id
        agent_id                    = $agentId
        agent_type                  = $agentType
        transcript_path             = [string]$Payload.transcript_path
        attestation_key             = Get-SubagentAttestationKey -TranscriptPath ([string]$Payload.transcript_path) -AgentId $agentId
        actual_model                = $model
        expected_model              = $(if ($null -ne $record) { [string]$record.deployment.model } else { '' })
        actual_reasoning_effort     = $(if ($null -ne $AgentProfile) { [string]$AgentProfile.profile_reasoning_effort } else { $null })
        expected_reasoning_effort   = $(if ($null -ne $record) { [string]$record.deployment.reasoning_effort } else { '' })
        profile_name                = $(if ($null -ne $AgentProfile) { [string]$AgentProfile.profile_name } else { $null })
        profile_model               = $(if ($null -ne $AgentProfile) { [string]$AgentProfile.profile_model } else { $null })
        profile_path                = $(if ($null -ne $AgentProfile) { [string]$AgentProfile.profile_path } else { $null })
        profile_sha256              = $(if ($null -ne $AgentProfile) { [string]$AgentProfile.profile_sha256 } else { $null })
        profile_validation_error    = $profileValidationError
        routing_valid               = $attested
        launch_authority_valid      = $attested
        root_authorized             = $null
        root_entry_kind             = $null
        root_epic_reference         = $null
        root_kickoff_path           = $null
        authority_repository_sha256 = Get-CodexAuthorityRepositoryKey -RepositoryRoot $RepositoryRoot
        provenance_valid            = $true
        enforcement_marker          = $(if ($attested) { $null } else { 'DISCOVERY_START_ATTESTATION_BLOCKED' })
        invocation_id               = $(if ($null -ne $record) { [string]$record.invocation_id } else { $null })
        start_attestation_ref       = $(if ($attested) { [string]$outcome.Attestation['start_attestation_ref'] } else { $null })
        discovery_code              = $outcome.Code
        discovery_reason            = $outcome.Reason
        recorded_at                 = $Now.ToUniversalTime().ToString('o')
    }
}

function Get-CodexDiscoveryStartCommandOutput {
    <#
    .SYNOPSIS
        Returns the SubagentStart stdout for a discovery attestation, or $null when the start was attested.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary] $Attestation,
        [Parameter(Mandatory)][string] $AttestationPath
    )

    if ([bool]$Attestation.routing_valid) { return $null }
    return [ordered]@{
        systemMessage      = "$($script:CodexDiscoveryStartPrefix) $($Attestation.discovery_reason) Attestation: $AttestationPath"
        hookSpecificOutput = [ordered]@{
            hookEventName     = 'SubagentStart'
            additionalContext = "$($script:CodexDiscoveryStartPrefix) no discovery tool grant is active for this agent. Do not read or mutate state; report the blocked start and stop."
        }
    } | ConvertTo-Json -Compress -Depth 5
}
