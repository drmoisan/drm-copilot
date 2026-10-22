<#
.SYNOPSIS
    Native SubagentStart attestation decisions for discovery specialists.

.DESCRIPTION
    Every native discovery SubagentStart adapter (Claude Code, Codex, GitHub
    Copilot) takes its decision from this module. A start event whose agent type
    is not a discovery specialist is skipped, so ordinary and epic starts keep
    their existing attestation path. For a discovery specialist the module
    resolves the explicit `discovery-invocation` receipt through the protected
    store and the trusted parent launch context: the attested host, session and
    parent must match the record, the activation must be active and bound to the
    same workspace and profile, exactly one prepared invocation must name the
    launched agent type, the actual role, model, effort and agent-profile hash
    must equal the deployment the root prepared, the runtime pins must equal the
    session's supported capability attestation, and a specialist may not launch
    another specialist. Only then is the `start-attestation` recorded and the
    invocation moved to `started`; no PreToolUse grant can bind before that.

    Nothing in the start payload can supply identity or authority beyond the agent
    identifier the host assigned; orchestrator checkpoints are never read or
    written. Store access flows through injected seams; no process is invoked.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding, DiscoveryAuthority, DiscoveryPayload and DiscoveryStartRecord modules.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryPayload.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryStartRecord.psm1') -ErrorAction Stop

$script:CapabilityAttestationFile = 'capability-attestation.json'
$script:RuntimeKeys = @('build_sha256', 'package_version', 'policy_sha256', 'policy_version', 'schema_version')
$script:CorrelationIdPattern = '^[A-Za-z0-9][A-Za-z0-9._:-]*$'

function Get-DiscoveryStartOutcome {
    <#
    .SYNOPSIS
        Builds one start outcome (skip, deny or attest) with its code and reason.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('skip', 'deny', 'attest')][string]$Decision,
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$Reason,
        [Parameter(Mandatory = $false)][AllowNull()][object]$Attestation = $null,
        [Parameter(Mandatory = $false)][AllowNull()][string]$AttestationPath = $null,
        [Parameter(Mandatory = $false)][AllowNull()][object]$Invocation = $null
    )

    return [pscustomobject]@{ Decision = $Decision; Code = $Code; Reason = $Reason; Attestation = $Attestation; AttestationPath = $AttestationPath; Invocation = $Invocation }
}

function Read-DiscoveryStoreJson {
    <#
    .SYNOPSIS
        Reads one JSON object from the store, returning $null for a missing or unreadable record.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][hashtable]$Store,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $text = Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @($Path)
    if ($null -eq $text) { return $null }
    try { $record = ConvertFrom-Json -InputObject ([string]$text) -Depth 16 } catch { return $null }
    if ($record -isnot [System.Management.Automation.PSCustomObject]) { return $null }
    return $record
}

function Find-DiscoveryPreparedInvocation {
    <#
    .SYNOPSIS
        Finds the prepared discovery invocations the root bound to AgentType in the attested session.
    .DESCRIPTION
        Enumerates `<session>/invocations/*/invocation.json` and keeps every
        `discovery-invocation` record whose host, session and parent equal the
        principal's, whose state is `prepared` and whose deployment names AgentType.
        An unreadable record is skipped so a corrupt neighbour cannot admit a start.
    .OUTPUTS
        [pscustomobject] Count, Record, Directory, Text (the single match, or $null members).
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][string]$AgentType,
        [Parameter(Mandatory = $true)][hashtable]$Store
    )

    $directory = "$(Get-DiscoverySessionDirectory -Location $Location -SessionId $Principal.SessionId)/invocations"
    $bindings = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in @(Invoke-DiscoveryStoreSeam -Seam $Store.ListEntries -Arguments @($directory))) {
        $path = "$directory/$entry/invocation.json"
        $text = Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @($path)
        if ($null -eq $text) { continue }
        try { $record = ConvertFrom-Json -InputObject ([string]$text) -Depth 16 } catch { continue }
        if ($record -isnot [System.Management.Automation.PSCustomObject]) { continue }
        $names = @($record.PSObject.Properties.Name)
        $missing = @(@('artifact_kind', 'host', 'session_id', 'parent_agent_id', 'state', 'deployment') | Where-Object { $names -notcontains $_ })
        if ($missing.Count -gt 0 -or $record.deployment -isnot [System.Management.Automation.PSCustomObject]) { continue }
        $bound = ($record.artifact_kind -eq 'discovery-invocation') -and ($record.host -eq $Principal.HostName) -and
        ($record.session_id -eq $Principal.SessionId) -and ($record.parent_agent_id -eq $Principal.ParentAgentId) -and
        ($record.state -eq 'prepared') -and ([string]$record.deployment.agent_name -ceq $AgentType)
        if ($bound) { $bindings.Add([pscustomobject]@{ Record = $record; Directory = "$directory/$entry"; Text = [string]$text }) }
    }
    if ($bindings.Count -ne 1) { return [pscustomobject]@{ Count = $bindings.Count; Record = $null; Directory = $null; Text = $null } }
    return [pscustomobject]@{ Count = 1; Record = $bindings[0].Record; Directory = $bindings[0].Directory; Text = $bindings[0].Text }
}

function Get-DiscoveryDeploymentMismatch {
    <#
    .SYNOPSIS
        Compares the launched agent against the deployment and binding the root prepared.
    .DESCRIPTION
        Returns $null when every leg agrees, otherwise an object with Code (RECEIPT,
        ROLE, MODEL, EFFORT, PROFILE or BINDING) and Reason. Model and effort are
        compared only when the host exposes them; the agent profile name must always
        equal the launched agent type and the invocation's workspace binding must
        equal the current activation.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Record,
        [Parameter(Mandatory = $true)][pscustomobject]$Activation,
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][string]$AgentType,
        [Parameter(Mandatory = $true)][pscustomobject]$AgentProfile,
        [Parameter(Mandatory = $false)][AllowNull()][string]$ActualModel,
        [Parameter(Mandatory = $false)][AllowNull()][string]$ActualReasoningEffort
    )

    $names = @($Record.PSObject.Properties.Name)
    foreach ($required in @('schema_version', 'invocation_id', 'role', 'workspace', 'runtime', 'capability_ref', 'production_write_count')) {
        if ($names -notcontains $required) { return [pscustomobject]@{ Code = 'RECEIPT'; Reason = "the protected invocation record lacks '$required'" } }
    }
    if ([string]$Record.schema_version -ne '2.0.0' -or [string]$Record.invocation_id -notmatch $script:CorrelationIdPattern -or [int]$Record.production_write_count -ne 0) {
        return [pscustomobject]@{ Code = 'RECEIPT'; Reason = 'the protected invocation record is not a schema 2.0.0 discovery-invocation with zero production writes' }
    }
    $role = Get-DiscoveryAgentRole -AgentType $AgentType
    if ([string]$Record.role -cne $role) {
        return [pscustomobject]@{ Code = 'ROLE'; Reason = "agent type $AgentType acts as $role but the invocation was prepared for role $($Record.role)" }
    }
    $deployment = $Record.deployment
    # A [string] parameter renders an absent value as ''; an empty value means the host exposed none.
    if (-not [string]::IsNullOrEmpty($ActualModel) -and $ActualModel -cne [string]$deployment.model) {
        return [pscustomobject]@{ Code = 'MODEL'; Reason = "the agent started with model $ActualModel but the invocation was prepared for $($deployment.model)" }
    }
    if (-not [string]::IsNullOrEmpty($ActualReasoningEffort) -and $ActualReasoningEffort -cne [string]$deployment.reasoning_effort) {
        return [pscustomobject]@{ Code = 'EFFORT'; Reason = "the agent profile declares reasoning effort $ActualReasoningEffort but the invocation was prepared for $($deployment.reasoning_effort)" }
    }
    if ([string]$AgentProfile.ProfileName -cne $AgentType -or [string]$AgentProfile.ProfileSha256 -notmatch '^[0-9a-f]{64}$') {
        return [pscustomobject]@{ Code = 'PROFILE'; Reason = "the agent profile at $($AgentProfile.ProfilePath) does not declare the launched agent $AgentType" }
    }
    if (-not [string]::IsNullOrEmpty([string]$AgentProfile.ProfileModel) -and [string]::IsNullOrEmpty($ActualModel) -and [string]$AgentProfile.ProfileModel -cne [string]$deployment.model) {
        return [pscustomobject]@{ Code = 'MODEL'; Reason = "the agent profile declares model $($AgentProfile.ProfileModel) but the invocation was prepared for $($deployment.model)" }
    }
    $sameBinding = ([string]$Record.workspace.workspace_sha256 -eq $Location.WorkspaceSha256) -and
    ([string]$Record.workspace.profile_path -eq [string]$Activation.profile_path) -and
    ([string]$Record.workspace.profile_sha256 -eq [string]$Activation.profile_sha256) -and
    ([string]$Record.runtime.schema_version -eq [string]$Activation.schema_version)
    if (-not $sameBinding) {
        return [pscustomobject]@{ Code = 'BINDING'; Reason = 'the invocation is bound to another workspace, profile or schema than the current activation' }
    }
    return $null
}

function Get-DiscoveryCapabilityMismatch {
    <#
    .SYNOPSIS
        Verifies the session's protected capability attestation against the invocation's pins.
    .DESCRIPTION
        The attestation referenced by the record must exist in the protected session
        directory, be `supported`, unexpired, bound to the same host, session and
        workspace, and carry exactly the runtime identity (package, schema, build,
        policy) the invocation was prepared with. Returns $null or an object with Code
        (CAPABILITY or RUNTIME) and Reason.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][pscustomobject]$Principal,
        [Parameter(Mandatory = $true)][pscustomobject]$Record,
        [Parameter(Mandatory = $true)][hashtable]$Store,
        [Parameter(Mandatory = $true)][datetime]$Now
    )

    $path = "$(Get-DiscoverySessionDirectory -Location $Location -SessionId $Principal.SessionId)/$($script:CapabilityAttestationFile)"
    $capability = Read-DiscoveryStoreJson -Store $Store -Path $path
    if ($null -eq $capability) {
        return [pscustomobject]@{ Code = 'CAPABILITY'; Reason = 'the session has no readable protected capability attestation' }
    }
    $names = @($capability.PSObject.Properties.Name)
    foreach ($required in @('artifact_kind', 'attestation_ref', 'status', 'host', 'session_id', 'workspace', 'runtime', 'expires_at')) {
        if ($names -notcontains $required) { return [pscustomobject]@{ Code = 'CAPABILITY'; Reason = "the capability attestation lacks '$required'" } }
    }
    $expires = ConvertTo-DiscoveryUtcInstant -Value $capability.expires_at
    if ($capability.artifact_kind -ne 'capability-attestation' -or [string]$capability.attestation_ref -cne [string]$Record.capability_ref) {
        return [pscustomobject]@{ Code = 'CAPABILITY'; Reason = "the capability attestation does not match the invocation reference $($Record.capability_ref)" }
    }
    if ($capability.status -ne 'supported' -or $null -eq $expires -or $expires -le $Now.ToUniversalTime()) {
        return [pscustomobject]@{ Code = 'CAPABILITY'; Reason = 'the capability attestation is not a current supported attestation' }
    }
    if ($capability.host -ne $Principal.HostName -or $capability.session_id -ne $Principal.SessionId -or [string]$capability.workspace.workspace_sha256 -ne $Location.WorkspaceSha256) {
        return [pscustomobject]@{ Code = 'CAPABILITY'; Reason = 'the capability attestation is bound to another host, session or workspace' }
    }
    $recordRuntime = $Record.runtime
    $capabilityRuntime = $capability.runtime
    foreach ($runtime in @($recordRuntime, $capabilityRuntime)) {
        if ($runtime -isnot [System.Management.Automation.PSCustomObject]) { return [pscustomobject]@{ Code = 'RUNTIME'; Reason = 'a runtime identity is not an object' } }
        $keys = @($runtime.PSObject.Properties.Name | Sort-Object)
        if (($keys -join ',') -ne ($script:RuntimeKeys -join ',')) { return [pscustomobject]@{ Code = 'RUNTIME'; Reason = 'a runtime identity does not carry exactly the five pinned keys' } }
    }
    foreach ($key in $script:RuntimeKeys) {
        if ([string]$recordRuntime.$key -cne [string]$capabilityRuntime.$key) {
            return [pscustomobject]@{ Code = 'RUNTIME'; Reason = "runtime pin $key of the invocation differs from the supported capability" }
        }
    }
    return $null
}

function Get-DiscoveryStartDecision {
    <#
    .SYNOPSIS
        Decides one SubagentStart event for a native discovery adapter.
    .DESCRIPTION
        Order: envelope anomalies deny; a non-discovery agent type is skipped (the
        existing ordinary and epic attestation applies); a missing host agent
        identifier, a launching process that is itself an attested specialist, or an
        unattributed principal without a trusted parent denies; the protected
        activation must be active; exactly one prepared invocation must be bound to
        this host, session, parent and agent type; the record, deployment, agent
        profile and capability must agree; then the attestation is written
        exclusively and the invocation record moves to `started`.
    .PARAMETER AgentProfile
        The host's agent profile reading (ProfilePath, ProfileSha256, ProfileName,
        ProfileModel, ProfileReasoningEffort). When omitted the Markdown profile under
        the event's workspace is read through ReadBytes.
    .PARAMETER Store
        Seams ReadText, ListEntries, WriteText, ReplaceText; defaults to the real filesystem.
    .OUTPUTS
        [pscustomobject] Decision, Code, Reason, Attestation, AttestationPath, Invocation.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Normalized,
        [Parameter(Mandatory = $true)][hashtable]$Environment,
        [Parameter(Mandatory = $true)][hashtable]$HostEnvironment,
        [Parameter(Mandatory = $true)][string]$HandlerSha256,
        [Parameter(Mandatory = $false)][hashtable]$Store = (Get-DiscoveryStartStore),
        [Parameter(Mandatory = $false)][datetime]$Now = [datetime]::UtcNow,
        [Parameter(Mandatory = $false)][string]$Nonce = (Get-DiscoveryAuthorizationNonceText),
        [Parameter(Mandatory = $false)][AllowNull()][pscustomobject]$AgentProfile = $null,
        [Parameter(Mandatory = $false)][AllowNull()][string]$ActualModel = $null,
        [Parameter(Mandatory = $false)][AllowNull()][string]$ActualReasoningEffort = $null,
        [Parameter(Mandatory = $false)][AllowNull()][scriptblock]$ReadBytes = $null
    )

    if ($null -ne $Normalized.Anomaly) {
        return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'ENVELOPE' -Reason ('payload anomaly - ' + (Get-DiscoveryPayloadAnomalyReason -Code $Normalized.Anomaly) + '. The start attestation fails closed on an envelope it cannot read.')
    }
    $agentType = [string]$Normalized.AgentType
    $role = Get-DiscoveryAgentRole -AgentType $agentType
    if ($null -eq $role) {
        return Get-DiscoveryStartOutcome -Decision 'skip' -Code 'NOT_DISCOVERY_AGENT' -Reason 'the started agent is not a discovery specialist; the ordinary start attestation applies'
    }
    $agentId = [string]$Normalized.AgentId
    if ($agentId -notmatch $script:CorrelationIdPattern) {
        return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'IDENTITY' -Reason 'the native start event carries no agent identifier for the discovery specialist'
    }
    # A specialist that launches another specialist cannot expand authority.
    if (-not [string]::IsNullOrWhiteSpace([string]$Environment['DRM_DISCOVERY_AGENT_ID']) -or -not [string]::IsNullOrWhiteSpace([string]$Environment['DRM_DISCOVERY_AGENT_ROLE'])) {
        return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'NESTED' -Reason "discovery specialist $agentType was launched by an attested discovery agent; nested specialists are not attested"
    }
    $principal = Get-DiscoveryTrustedPrincipal -Normalized $Normalized -Environment $Environment
    if (-not $principal.Attributed -or $null -eq $principal.ParentAgentId) {
        $reason = $(if ($null -ne $principal.Reason) { $principal.Reason } else { 'the native host attested no parent agent for this launch' })
        return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'IDENTITY' -Reason "the launch context could not be attributed: $reason"
    }
    if ([string]::IsNullOrWhiteSpace([string]$Normalized.Cwd)) {
        return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'WORKSPACE' -Reason 'the native event carries no workspace directory'
    }
    try {
        $location = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot ([string]$Normalized.Cwd) -Platform $HostEnvironment.Platform `
            -UserHome $HostEnvironment.UserHome -LocalAppData $HostEnvironment.LocalAppData -XdgStateHome $HostEnvironment.XdgStateHome
    } catch {
        return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'WORKSPACE' -Reason $_.Exception.Message
    }
    $activation = Read-DiscoveryActivationState -Location $location -ReadText $Store.ReadText
    if ($activation.Status -ne 'active') {
        return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'ACTIVATION' -Reason "discovery is not active for this workspace ($($activation.Status): $($activation.Reason))"
    }
    $found = Find-DiscoveryPreparedInvocation -Location $location -Principal $principal -AgentType $agentType -Store $Store
    if ($found.Count -eq 0) {
        return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'NO_INVOCATION' -Reason "no prepared protected invocation binds agent type $agentType to parent $($principal.ParentAgentId) in this session"
    }
    if ($found.Count -gt 1) {
        return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'AMBIGUOUS' -Reason "$($found.Count) prepared invocations bind agent type $agentType in this session; the start cannot be attributed to one"
    }
    $record = $found.Record
    if ($null -eq $AgentProfile) {
        try {
            $readParameters = @{ HostName = $principal.HostName; AgentType = $agentType; WorkspaceRoot = [string]$Normalized.Cwd }
            if ($null -ne $ReadBytes) { $readParameters['ReadBytes'] = $ReadBytes }
            $AgentProfile = Read-DiscoveryAgentProfile @readParameters
        } catch {
            return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'PROFILE' -Reason "the agent profile could not be read: $($_.Exception.Message)"
        }
    }
    $mismatch = Get-DiscoveryDeploymentMismatch -Record $record -Activation $activation.Record -Location $location -AgentType $agentType `
        -AgentProfile $AgentProfile -ActualModel $ActualModel -ActualReasoningEffort $ActualReasoningEffort
    if ($null -ne $mismatch) { return Get-DiscoveryStartOutcome -Decision 'deny' -Code $mismatch.Code -Reason $mismatch.Reason }
    $mismatch = Get-DiscoveryCapabilityMismatch -Location $location -Principal $principal -Record $record -Store $Store -Now $Now
    if ($null -ne $mismatch) { return Get-DiscoveryStartOutcome -Decision 'deny' -Code $mismatch.Code -Reason $mismatch.Reason }
    $attestation = ConvertTo-DiscoveryStartAttestationRecord -Principal $principal -AgentId $agentId -AgentType $agentType -Record $record -AgentProfile $AgentProfile `
        -ActualModel $ActualModel -ActualReasoningEffort $ActualReasoningEffort -HandlerSha256 $HandlerSha256 -Now $Now -Nonce $Nonce
    $path = "$($found.Directory)/$(Get-DiscoveryStartAttestationFileName)"
    try {
        # The attestation is the exclusive latch; the record transition follows it.
        Invoke-DiscoveryStoreSeam -Seam $Store.WriteText -Arguments @($path, (($attestation | ConvertTo-Json -Depth 8) + "`n"))
        $startedText = ConvertTo-DiscoveryStartedInvocationText -Text $found.Text -AgentId $agentId -StartAttestationRef ([string]$attestation['start_attestation_ref'])
        Invoke-DiscoveryStoreSeam -Seam $Store.ReplaceText -Arguments @("$($found.Directory)/invocation.json", $startedText)
    } catch {
        return Get-DiscoveryStartOutcome -Decision 'deny' -Code 'STORE' -Reason "the start attestation could not be recorded: $($_.Exception.Message)"
    }
    return Get-DiscoveryStartOutcome -Decision 'attest' -Code 'ATTESTED' -Reason "attested $agentType as $role for invocation $($record.invocation_id)" -Attestation $attestation -AttestationPath $path -Invocation $record
}

function Get-DiscoveryAuthorizationNonceText {
    <#
    .SYNOPSIS
        Returns 20 lowercase hex characters from the platform random generator.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $bytes = [byte[]]::new(10)
    [System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
    return [Convert]::ToHexString($bytes).ToLowerInvariant()
}

function ConvertTo-DiscoveryStartHookOutput {
    <#
    .SYNOPSIS
        Renders a start outcome as the SubagentStart hook output, or $null when the hook stays silent.
    .DESCRIPTION
        A skipped or attested start produces no output. A denied start cannot stop the
        host from running the agent, so the output carries the reason as a system
        message and instructs the agent not to act; the PreToolUse adapter then denies
        every grant because no started invocation exists.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Outcome,
        [Parameter(Mandatory = $true)][string]$ReasonPrefix
    )

    if ($Outcome.Decision -ne 'deny') { return $null }
    return [ordered]@{
        systemMessage      = "$ReasonPrefix $($Outcome.Reason)"
        hookSpecificOutput = [ordered]@{
            hookEventName     = 'SubagentStart'
            additionalContext = "$ReasonPrefix no discovery tool grant is active for this agent. Do not read or mutate state; report the blocked start and stop."
        }
    }
}

Export-ModuleMember -Function `
    Find-DiscoveryPreparedInvocation, `
    Get-DiscoveryDeploymentMismatch, `
    Get-DiscoveryCapabilityMismatch, `
    Get-DiscoveryStartDecision, `
    Get-DiscoveryAuthorizationNonceText, `
    ConvertTo-DiscoveryStartHookOutput
