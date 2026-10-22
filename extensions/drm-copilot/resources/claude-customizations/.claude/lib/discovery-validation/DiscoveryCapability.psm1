<#
.SYNOPSIS
    Native host capability observation for discovery agents: registration, handler hashes and the harmless sentinel.

.DESCRIPTION
    Every native capability probe (Claude Code, Codex, GitHub Copilot) takes its
    observation from this module. The probe reads the host's hook registration
    (`.claude/settings.json`, `.codex/config.toml` or `.github/hooks/discovery.json`),
    confirms that the start, tool and stop handlers are registered for the four
    discovery agent names and the controlled tools, hashes the configuration and
    every handler, and runs the harmless forbidden-operation sentinel through the
    host's own PreToolUse adapter decision: an attested specialist attempting a
    shell command that must be denied and never executed. The result is a
    `capability-attestation`-shaped document whose status is derived, never
    supplied: `supported` requires every control, every handler and a denied
    sentinel with protected denial evidence. A caller Boolean or repository text
    cannot substitute for these observations; the gateway alone writes the
    protected attestation.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding, DiscoveryAuthority and DiscoveryPayload modules.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryPayload.psm1') -ErrorAction Stop

$script:CapabilitySchema = 'urn:drm-copilot:discovery:2.0.0:capability-attestation'
$script:DiscoveryAgentNames = @('legacy-parity-analyst', 'runtime-characterization-analyst', 'requirements-reconciler', 'migration-coverage-reviewer')
$script:ControlledToolNames = @('Bash', 'Write', 'mcp__drm-copilot__run_discovery_repo_inventory', 'Agent')
$script:ControlNames = @('workspace_trusted', 'hooks_enabled', 'trusted_attribution', 'start_event', 'tool_event', 'stop_event', 'forbidden_tools_denied')
$script:HandlerEvents = @('start', 'tool', 'stop')
$script:EventNames = @{ start = 'SubagentStart'; tool = 'PreToolUse'; stop = 'SubagentStop' }
# Per-host registration file, handler directory and the handler each lifecycle event names.
$script:HostLayout = @{
    'claude-code'    = @{ Configuration = '.claude/settings.json'; Directory = '.claude/hooks'; start = 'record-discovery-agent-start.ps1'; tool = 'enforce-discovery-artifact-gate.ps1'; stop = 'validate-discovery-artifact-gate.ps1' }
    'codex'          = @{ Configuration = '.codex/config.toml'; Directory = '.codex/hooks'; start = 'record-subagent-routing-attestation.ps1'; tool = 'enforce-discovery-artifact-gate.ps1'; stop = 'validate-discovery-agent-output.ps1' }
    'github-copilot' = @{ Configuration = '.github/hooks/discovery.json'; Directory = '.github/hooks'; start = 'discovery-agent-start.ps1'; tool = 'discovery-pre-tool.ps1'; stop = 'discovery-agent-stop.ps1' }
}

function Get-DiscoverySentinelRequest {
    <#
    .SYNOPSIS
        Returns the harmless sentinel command text the native hook must deny and never execute.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([Parameter(Mandatory = $true)][string]$SentinelId)

    return "drm-copilot discovery capability probe $SentinelId" + ': this command must be denied by the native hook and never executed'
}

function Get-DiscoverySentinelEnvelope {
    <#
    .SYNOPSIS
        Builds the host-shaped PreToolUse envelope of the sentinel: an attested specialist running a shell command.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('claude-code', 'codex', 'github-copilot')][string]$HostName,
        [Parameter(Mandatory = $true)][string]$SessionId,
        [Parameter(Mandatory = $true)][string]$SentinelId,
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot
    )

    $command = Get-DiscoverySentinelRequest -SentinelId $SentinelId
    if ($HostName -eq 'github-copilot') {
        $envelope = [ordered]@{ sessionId = $SessionId; hookEventName = 'PreToolUse'; toolName = 'Bash'; toolInput = [ordered]@{ command = $command }; cwd = $WorkspaceRoot; toolUseId = $SentinelId }
    } else {
        $envelope = [ordered]@{ session_id = $SessionId; hook_event_name = 'PreToolUse'; tool_name = 'Bash'; tool_input = [ordered]@{ command = $command }; cwd = $WorkspaceRoot; tool_use_id = $SentinelId }
    }
    return ($envelope | ConvertTo-Json -Compress -Depth 4)
}

function Get-DiscoverySentinelEnvironment {
    <#
    .SYNOPSIS
        Returns the attested DRM_DISCOVERY_* table under which the sentinel runs as a probe specialist.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][string]$HostName,
        [Parameter(Mandatory = $true)][string]$SessionId,
        [Parameter(Mandatory = $true)][string]$SentinelId
    )

    return @{
        DRM_DISCOVERY_HOST            = $HostName
        DRM_DISCOVERY_SESSION_ID      = $SessionId
        DRM_DISCOVERY_PARENT_AGENT_ID = "root-$SentinelId"
        DRM_DISCOVERY_PARENT_ROLE     = $null
        DRM_DISCOVERY_AGENT_ID        = "probe-$SentinelId"
        DRM_DISCOVERY_AGENT_ROLE      = 'legacy-parity-analyst'
    }
}

function Get-DiscoveryHostRegistration {
    <#
    .SYNOPSIS
        Parses a host registration text into event entries (Event, Matcher, Command).
    .DESCRIPTION
        Claude settings and Copilot hook files are JSON: an event maps to groups
        (`matcher` plus `hooks[]`) or directly to hook objects. The Codex file is TOML
        scanned line by line: a `[[hooks.<Event>]]` table starts a group, `matcher`
        sets its regex and each `command` names a handler. Parsed is $false when the
        text cannot be read as the host's format.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('claude-code', 'codex', 'github-copilot')][string]$HostName,
        [Parameter(Mandatory = $false)][AllowNull()][AllowEmptyString()][string]$ConfigurationText
    )

    $entries = [System.Collections.Generic.List[object]]::new()
    if ([string]::IsNullOrWhiteSpace($ConfigurationText)) { return [pscustomobject]@{ Parsed = $false; Entries = @() } }
    if ($HostName -eq 'codex') {
        $currentEvent = $null
        $currentMatcher = $null
        foreach ($line in ($ConfigurationText -split "`r?`n")) {
            if ($line -match '^\[\[hooks\.(?<event>[A-Za-z]+)\]\]\s*$') { $currentEvent = $Matches['event']; $currentMatcher = $null; continue }
            if ($null -ne $currentEvent -and $line -match '^matcher\s*=\s*"(?<matcher>.+)"\s*$') { $currentMatcher = $Matches['matcher']; continue }
            if ($null -ne $currentEvent -and $line -match '^command\s*=\s*''(?<command>.+)''\s*$') {
                $entries.Add([pscustomobject]@{ Event = $currentEvent; Matcher = $currentMatcher; Command = $Matches['command'] })
            }
        }
        return [pscustomobject]@{ Parsed = ($entries.Count -gt 0); Entries = @($entries) }
    }
    try { $document = ConvertFrom-Json -InputObject $ConfigurationText -Depth 16 } catch { return [pscustomobject]@{ Parsed = $false; Entries = @() } }
    if ($document -isnot [System.Management.Automation.PSCustomObject] -or $null -eq $document.PSObject.Properties['hooks'] -or $document.hooks -isnot [System.Management.Automation.PSCustomObject]) {
        return [pscustomobject]@{ Parsed = $false; Entries = @() }
    }
    foreach ($eventProperty in $document.hooks.PSObject.Properties) {
        foreach ($item in @($eventProperty.Value)) {
            if ($item -isnot [System.Management.Automation.PSCustomObject]) { continue }
            $matcher = $(if ($null -ne $item.PSObject.Properties['matcher']) { [string]$item.matcher } else { $null })
            $hooks = $(if ($null -ne $item.PSObject.Properties['hooks']) { @($item.hooks) } else { @($item) })
            foreach ($hook in $hooks) {
                if ($hook -is [System.Management.Automation.PSCustomObject] -and $null -ne $hook.PSObject.Properties['command']) {
                    $entries.Add([pscustomobject]@{ Event = $eventProperty.Name; Matcher = $matcher; Command = [string]$hook.command })
                }
            }
        }
    }
    return [pscustomobject]@{ Parsed = $true; Entries = @($entries) }
}

function Test-DiscoveryHandlerRegistered {
    <#
    .SYNOPSIS
        True when Event registers HandlerName with a matcher that admits every name in Admitted (or no matcher).
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Registration,
        [Parameter(Mandatory = $true)][string]$Event,
        [Parameter(Mandatory = $true)][string]$HandlerName,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Admitted
    )

    $entries = @($Registration.Entries | Where-Object { $_.Event -eq $Event -and ([string]$_.Command).Contains($HandlerName) })
    if ($entries.Count -eq 0) { return $false }
    # The handler may be registered under several matcher groups; their union must admit every name.
    foreach ($name in $Admitted) {
        $covered = @($entries | Where-Object { [string]::IsNullOrEmpty($_.Matcher) -or $name -match $_.Matcher })
        if ($covered.Count -eq 0) { return $false }
    }
    return $true
}

function Get-DiscoveryCapabilityObservation {
    <#
    .SYNOPSIS
        Observes one host's discovery controls and returns the capability-attestation-shaped document.
    .DESCRIPTION
        Controls: hooks_enabled (the registration file is present and parseable and
        names a discovery handler), start_event, tool_event and stop_event (the
        handler is registered for the discovery agents or controlled tools and its
        file exists), trusted_attribution and forbidden_tools_denied (the sentinel
        decision attributed the probe specialist and denied the shell command with
        code SHELL), workspace_trusted (supplied by the host probe, which the host
        only runs inside a trusted workspace). The protected activation supplies the
        workspace binding; without one the status is unsupported.
    .PARAMETER SentinelDecision
        Script block `param([string]$EnvelopeJson, [hashtable]$Environment)` returning
        an object with Decision (allow or deny), Code and Text (the decision JSON).
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('claude-code', 'codex', 'github-copilot')][string]$HostName,
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$SessionId,
        [Parameter(Mandatory = $true)][string]$Nonce,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$Runtime,
        [Parameter(Mandatory = $true)][scriptblock]$SentinelDecision,
        [Parameter(Mandatory = $true)][hashtable]$HostEnvironment,
        [Parameter(Mandatory = $false)][hashtable]$Store = (Get-DiscoveryDefaultStore),
        [Parameter(Mandatory = $false)][bool]$WorkspaceTrusted = $true,
        [Parameter(Mandatory = $false)][datetime]$Now = [datetime]::UtcNow,
        [Parameter(Mandatory = $false)][int]$TtlSeconds = 3600,
        [Parameter(Mandatory = $false)][scriptblock]$ReadBytes = {
            param([string]$Path)
            if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
            return [System.IO.File]::ReadAllBytes($Path)
        }
    )

    $layout = $script:HostLayout[$HostName]
    $root = $WorkspaceRoot.TrimEnd('/', '\')
    $findings = [System.Collections.Generic.List[object]]::new()
    $controls = [ordered]@{}
    foreach ($name in $script:ControlNames) { $controls[$name] = $false }
    $controls['workspace_trusted'] = $WorkspaceTrusted
    $configurationBytes = & $ReadBytes "$root/$($layout.Configuration)"
    $configurationText = $null
    if ($null -ne $configurationBytes) {
        [byte[]]$configurationBytes = @($configurationBytes)
        try { $configurationText = [System.Text.UTF8Encoding]::new($false, $true).GetString($configurationBytes) } catch { $configurationText = $null }
    } else { [byte[]]$configurationBytes = @() }
    $registration = Get-DiscoveryHostRegistration -HostName $HostName -ConfigurationText $configurationText
    $handlers = [System.Collections.Generic.List[object]]::new()
    foreach ($lifecycle in $script:HandlerEvents) {
        $handlerName = $layout[$lifecycle]
        $admitted = $(if ($lifecycle -eq 'tool') { $script:ControlledToolNames } else { $script:DiscoveryAgentNames })
        $registered = $registration.Parsed -and (Test-DiscoveryHandlerRegistered -Registration $registration -Event $script:EventNames[$lifecycle] -HandlerName $handlerName -Admitted $admitted)
        $relativePath = "$($layout.Directory)/$handlerName"
        $bytes = & $ReadBytes "$root/$relativePath"
        if ($registered -and $null -ne $bytes) {
            $handlers.Add([ordered]@{ event = $lifecycle; path = $relativePath; sha256 = (Get-DiscoveryBytesSha256Hex -Bytes ([byte[]]@($bytes))) })
            $controls["$($lifecycle)_event"] = $true
        }
    }
    $controls['hooks_enabled'] = $registration.Parsed -and ($handlers.Count -gt 0)
    $sentinelId = "sentinel-$Nonce"
    $envelope = Get-DiscoverySentinelEnvelope -HostName $HostName -SessionId $SessionId -SentinelId $sentinelId -WorkspaceRoot $WorkspaceRoot
    $environment = Get-DiscoverySentinelEnvironment -HostName $HostName -SessionId $SessionId -SentinelId $sentinelId
    try { $decision = & $SentinelDecision $envelope $environment } catch { $decision = [pscustomobject]@{ Decision = 'unavailable'; Code = 'ERROR'; Text = [string]$_.Exception.Message } }
    $denied = ($null -ne $decision) -and ([string]$decision.Decision -eq 'deny')
    $controls['forbidden_tools_denied'] = $denied
    $controls['trusted_attribution'] = $denied -and ([string]$decision.Code -eq 'SHELL')
    $probe = [ordered]@{
        sentinel_id  = $sentinelId
        result       = $(if ($denied) { 'denied' } elseif ($null -ne $decision -and [string]$decision.Decision -eq 'allow') { 'allowed' } else { 'unavailable' })
        evidence_ref = $(if ($denied) { 'probe-' + (Get-DiscoverySha256Hex -Text ([string]$decision.Text)) } else { $null })
    }
    # The workspace binding comes from the protected activation, never from the caller.
    $location = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot $WorkspaceRoot -Platform $HostEnvironment.Platform -UserHome $HostEnvironment.UserHome -LocalAppData $HostEnvironment.LocalAppData -XdgStateHome $HostEnvironment.XdgStateHome
    $activation = Read-DiscoveryActivationState -Location $location -ReadText $Store.ReadText
    $workspace = [ordered]@{ workspace_root = $location.Workspace; workspace_sha256 = $location.WorkspaceSha256; profile_path = 'config/discovery.json'; profile_sha256 = ('0' * 64) }
    if ($activation.Status -eq 'active') {
        $workspace['profile_path'] = [string]$activation.Record.profile_path
        $workspace['profile_sha256'] = [string]$activation.Record.profile_sha256
    } else {
        $findings.Add([ordered]@{ code = 'DISCOVERY_ENFORCEMENT_UNAVAILABLE'; severity = 'error'; artifact_path = $null; pointer = '/workspace'; related_ids = @(); related_paths = @(); message = "No active protected activation binds this workspace ($($activation.Status))."; next_action = 'Initialize or configure discovery for this workspace, then re-run the capability probe.' })
    }
    foreach ($name in $script:ControlNames) {
        if (-not $controls[$name]) { $findings.Add([ordered]@{ code = 'DISCOVERY_ENFORCEMENT_UNAVAILABLE'; severity = 'error'; artifact_path = $null; pointer = '/controls'; related_ids = @(); related_paths = @(); message = "Native control $name is not available."; next_action = 'Enable the native hook controls for this host and re-run the capability probe.' }) }
    }
    foreach ($lifecycle in $script:HandlerEvents) {
        if (-not ($handlers | Where-Object { $_['event'] -eq $lifecycle })) { $findings.Add([ordered]@{ code = 'DISCOVERY_ENFORCEMENT_UNAVAILABLE'; severity = 'error'; artifact_path = $null; pointer = '/handlers'; related_ids = @(); related_paths = @(); message = "No $lifecycle hook handler was observed."; next_action = 'Install and register the discovery hook handlers and re-run the capability probe.' }) }
    }
    if (-not $denied) { $findings.Add([ordered]@{ code = 'DISCOVERY_ENFORCEMENT_UNAVAILABLE'; severity = 'error'; artifact_path = $null; pointer = '/probe'; related_ids = @(); related_paths = @(); message = "Sentinel $sentinelId was $($probe['result']) by the native hook."; next_action = 'Confirm the native hook denies forbidden operations and records protected evidence.' }) }
    $stamp = $Now.ToUniversalTime()
    return [ordered]@{
        '$schema'            = $script:CapabilitySchema
        schema_version       = '2.0.0'
        artifact_kind        = 'capability-attestation'
        id                   = "capability-$Nonce"
        attestation_ref      = "capability-$Nonce"
        workspace            = $workspace
        host                 = $HostName
        session_id           = $SessionId
        runtime              = $Runtime
        configuration_sha256 = Get-DiscoveryBytesSha256Hex -Bytes $configurationBytes
        handlers             = @($handlers)
        controls             = $controls
        probe                = $probe
        status               = $(if ($findings.Count -eq 0) { 'supported' } else { 'unsupported' })
        findings             = @($findings)
        observed_at          = $stamp.ToString("yyyy-MM-dd'T'HH:mm:ss'Z'")
        expires_at           = $stamp.AddSeconds($TtlSeconds).ToString("yyyy-MM-dd'T'HH:mm:ss'Z'")
    }
}

Export-ModuleMember -Function `
    Get-DiscoverySentinelRequest, `
    Get-DiscoverySentinelEnvelope, `
    Get-DiscoverySentinelEnvironment, `
    Get-DiscoveryHostRegistration, `
    Test-DiscoveryHandlerRegistered, `
    Get-DiscoveryCapabilityObservation
