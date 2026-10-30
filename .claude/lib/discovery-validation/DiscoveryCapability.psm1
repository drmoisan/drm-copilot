<#
.SYNOPSIS
    Native host capability observation for discovery agents: registration, handler hashes and the harmless sentinel.

.DESCRIPTION
    Every native capability probe (Claude Code, Codex, GitHub Copilot) takes its
    observation from this module. The probe reads the host's hook registration
    (`.claude/settings.json`, `.codex/config.toml` or `.github/hooks/discovery.json`),
    confirms that the start, tool and stop handlers are registered for the four
    discovery agent names and the controlled tools, hashes the configuration and
    every handler, and reads the host observations the native PreToolUse gate
    recorded while the discovery-capability-sentinel agent ran: a sentinel tool call
    that carried the agent identity and was consumed by the sentinel MCP tool, and
    the denied sentinel shell command from the same agent. Consumption is the
    exclusive `<record>.json.consumed` latch the MCP server writes beside the
    observation and never a rewrite of the record: the gate writes the record once
    with state `issued`, and the probe accepts it only when the latch beside it names
    the same observation_ref. The result is a `capability-attestation`-shaped document
    whose status is derived, never supplied: `supported` requires every control,
    every handler and observation evidence for attribution and the denied sentinel.
    No in-process decision, caller Boolean or repository text can substitute for
    these observations; the gateway alone writes the protected attestation.

.NOTES
    Issue #980. Compatible with PowerShell 7+. Depends only on the sibling
    DiscoveryEncoding, DiscoveryAuthority, DiscoveryPayload and DiscoveryObservation modules.
    CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'DiscoveryEncoding.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryAuthority.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryPayload.psm1') -ErrorAction Stop
Import-Module (Join-Path $PSScriptRoot 'DiscoveryObservation.psm1') -ErrorAction Stop

$script:CapabilitySchema = 'urn:drm-copilot:discovery:2.0.0:capability-attestation'
$script:CapabilityAttestationFile = 'capability-attestation.json'
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

function ConvertTo-DiscoveryObservationInstant {
    <#
    .SYNOPSIS
        Returns a UTC instant from a parsed observation timestamp (string or DateTime), or $null when unreadable.
    #>
    [CmdletBinding()]
    [OutputType([datetime])]
    param([Parameter(Mandatory = $false)][AllowNull()][object]$Value)

    if ($Value -is [datetime]) { return $Value.ToUniversalTime() }
    $parsed = [datetime]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    if ($Value -is [string] -and [datetime]::TryParseExact($Value, "yyyy-MM-dd'T'HH:mm:ss'Z'", [System.Globalization.CultureInfo]::InvariantCulture, $styles, [ref]$parsed)) { return $parsed }
    return $null
}

function Get-DiscoveryConsumedLatch {
    <#
    .SYNOPSIS
        Reads the exclusive `.consumed` latch beside a one-use record through the ReadText seam.
    .DESCRIPTION
        The MCP server consumes a sentinel grant by creating `<record>.json.consumed`
        with a JSON object naming the record's observation_ref; the record itself is
        never rewritten. Returns the parsed latch as a hashtable, or $null when the
        latch is absent, unreadable or not a JSON object.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory = $true)][hashtable]$Store,
        [Parameter(Mandatory = $true)][string]$Path
    )

    try {
        $text = Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @($Path)
        $latch = $(if ($null -ne $text) { ConvertFrom-Json -InputObject $text -AsHashtable -Depth 4 } else { $null })
    } catch { $latch = $null }
    if ($latch -is [hashtable]) { return $latch }
    return $null
}

function Get-DiscoverySessionObservation {
    <#
    .SYNOPSIS
        Reads every parseable host-observation record of the session from the protected store, with its consumer latch.
    .DESCRIPTION
        Entries that cannot be read or parsed are skipped; an absent directory yields
        an empty list. Records are returned as hashtables keyed by the schema names
        plus the reader-side entry `consumed_latch`: the sibling `<name>.consumed`
        the sentinel MCP tool writes when it consumes the grant, read by path through
        the same ReadText seam, as a hashtable when it parses as a JSON object and
        otherwise $null.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory = $true)][pscustomobject]$Location,
        [Parameter(Mandatory = $true)][string]$SessionId,
        [Parameter(Mandatory = $true)][hashtable]$Store
    )

    $directory = Get-DiscoveryObservationDirectory -Location $Location -SessionId $SessionId
    $names = @()
    try { $names = @(Invoke-DiscoveryStoreSeam -Seam $Store.ListEntries -Arguments @($directory)) } catch { $names = @() }
    $records = [System.Collections.Generic.List[object]]::new()
    # Each entry is one observation file; unreadable or non-object entries carry no evidence.
    foreach ($name in @($names | Where-Object { $_ -is [string] -and $_.EndsWith('.json') })) {
        try {
            $text = Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @("$directory/$name")
            $record = $(if ($null -ne $text) { ConvertFrom-Json -InputObject $text -AsHashtable -Depth 8 } else { $null })
        } catch { $record = $null }
        if ($record -is [hashtable] -and [string]$record['artifact_kind'] -eq 'host-observation') {
            # The latch is the consumption marker; it is attached here so the evidence derivation never touches the store.
            $record['consumed_latch'] = Get-DiscoveryConsumedLatch -Store $Store -Path "$directory/$name.consumed"
            $records.Add($record)
        }
    }
    return $records.ToArray()
}

function Get-DiscoveryObservationEvidence {
    <#
    .SYNOPSIS
        Derives trusted_attribution and forbidden_tools_denied from the session's host observations.
    .DESCRIPTION
        trusted_attribution holds only for a sentinel-tool observation that carries a
        non-empty agent_id, the sentinel agent type, state `issued` beside a consumer
        latch (`consumed_latch`, the parsed `<record>.json.consumed` the sentinel MCP
        tool writes) whose observation_ref equals the record's, the hash of the
        registered tool handler and an observed_at within TtlSeconds of Now. A record
        rewritten as `consumed`, a missing latch or a latch naming another observation
        is reported as not consumed, because the record is never rewritten and only
        the latch beside it proves consumption. forbidden_tools_denied holds only for
        a SHELL deny observation from the same agent_id. Every rejected or missing
        observation yields one deficiency message.
    .OUTPUTS
        [pscustomobject] TrustedAttribution, ForbiddenDenied, Deficiencies, SentinelRef, ShellRef.
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][object[]]$Observations,
        [Parameter(Mandatory = $true)][AllowNull()][AllowEmptyString()][string]$ToolHandlerSha256,
        [Parameter(Mandatory = $true)][datetime]$Now,
        [Parameter(Mandatory = $true)][int]$TtlSeconds
    )

    $deficiencies = [System.Collections.Generic.List[object]]::new()
    $accepted = $null
    $candidates = @($Observations | Where-Object { [string]$_['code'] -ceq 'SENTINEL' -and [string]$_['tool'] -ceq 'discovery_capability_sentinel' })
    if ($candidates.Count -eq 0) { $deficiencies.Add([pscustomobject]@{ Control = 'trusted_attribution'; Message = 'no sentinel tool observation was recorded for this session' }) }
    # Each sentinel-tool observation must pass every check; the first that does supplies the attributed agent.
    foreach ($candidate in $candidates) {
        $reference = [string]$candidate['observation_ref']
        $observedAt = ConvertTo-DiscoveryObservationInstant -Value $candidate['observed_at']
        $problem = $null
        # Consumption is proved by the latch alone: present and naming this record, or absent, or naming another record.
        $latch = $candidate['consumed_latch']
        $latchState = $(if ($latch -isnot [hashtable]) { 'absent' } elseif ([string]$latch['observation_ref'] -ceq $reference) { 'present' } else { 'names another observation' })
        if ([string]::IsNullOrWhiteSpace([string]$candidate['agent_id']) -or [string]$candidate['agent_type'] -cne 'discovery-capability-sentinel') { $problem = 'carries no sentinel agent identity' }
        elseif ([string]$candidate['state'] -cne 'issued' -or $latchState -ne 'present') { $problem = "was not consumed by the sentinel tool (state $([string]$candidate['state']), latch $latchState)" }
        elseif ([string]::IsNullOrEmpty($ToolHandlerSha256) -or [string]$candidate['handler_sha256'] -cne $ToolHandlerSha256) { $problem = 'was recorded by a tool handler whose hash differs from the registered handler' }
        elseif ($null -eq $observedAt -or ($Now.ToUniversalTime() - $observedAt).TotalSeconds -gt $TtlSeconds -or $observedAt -gt $Now.ToUniversalTime()) { $problem = 'is stale' }
        if ($null -eq $problem) { if ($null -eq $accepted) { $accepted = $candidate } }
        else { $deficiencies.Add([pscustomobject]@{ Control = 'trusted_attribution'; Message = "sentinel observation $reference $problem" }) }
    }
    $shell = $null
    if ($null -ne $accepted) {
        $shell = @($Observations | Where-Object { [string]$_['code'] -ceq 'SHELL' -and [string]$_['decision'] -ceq 'deny' -and [string]$_['agent_id'] -ceq [string]$accepted['agent_id'] }) | Select-Object -First 1
    }
    if ($null -eq $shell) { $deficiencies.Add([pscustomobject]@{ Control = 'forbidden_tools_denied'; Message = 'no SHELL deny observation from the attributed sentinel agent was recorded' }) }
    return [pscustomobject]@{
        TrustedAttribution = ($null -ne $accepted)
        ForbiddenDenied    = ($null -ne $shell)
        Deficiencies       = @($deficiencies)
        SentinelRef        = $(if ($null -ne $accepted) { [string]$accepted['observation_ref'] } else { $null })
        ShellRef           = $(if ($null -ne $shell) { [string]$shell['observation_ref'] } else { $null })
    }
}

function Get-DiscoveryHostRegistration {
    <#
    .SYNOPSIS
        Parses a host registration text into event entries (Event, Matcher, Command).
    .DESCRIPTION
        Claude settings and Copilot hook files are JSON: an event maps to groups
        (`matcher` plus `hooks[]`) or directly to hook objects. A hook object names
        its handler through `powershell`, `bash` or `command`, read in that order, so
        the documented Copilot shape (`version` 1 with `powershell` and `bash`) and
        the Claude `command` shape both parse. The Codex file is TOML scanned line by
        line: a `[[hooks.<Event>]]` table starts a group, `matcher` sets its regex and
        each `command` names a handler. Parsed is $false when the text cannot be read
        as the host's format.
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
                if ($hook -isnot [System.Management.Automation.PSCustomObject]) { continue }
                # The first present handler key wins: the Copilot shape names powershell and bash, the Claude shape names command.
                $command = $null
                foreach ($key in @('powershell', 'bash', 'command')) {
                    if ($null -ne $hook.PSObject.Properties[$key] -and -not [string]::IsNullOrWhiteSpace([string]$hook.$key)) { $command = [string]$hook.$key; break }
                }
                if ($null -ne $command) { $entries.Add([pscustomobject]@{ Event = $eventProperty.Name; Matcher = $matcher; Command = $command }) }
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
        file exists), trusted_attribution and forbidden_tools_denied (proved only
        from the session's host observations recorded by the native PreToolUse gate
        while the capability sentinel agent ran; see Get-DiscoveryObservationEvidence),
        workspace_trusted (supplied by the host probe, which the host only runs inside
        a trusted workspace). The protected activation supplies the workspace binding;
        without one the status is unsupported. A session without observations is
        unsupported, so a supported result requires the session the sentinel ran in.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('claude-code', 'codex', 'github-copilot')][string]$HostName,
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][string]$SessionId,
        [Parameter(Mandatory = $true)][string]$Nonce,
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$Runtime,
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
    # The workspace binding comes from the protected activation, never from the caller.
    $location = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot $WorkspaceRoot -Platform $HostEnvironment.Platform -UserHome $HostEnvironment.UserHome -LocalAppData $HostEnvironment.LocalAppData -XdgStateHome $HostEnvironment.XdgStateHome
    # Attribution and the forbidden-tool deny are proved only from what the gate observed for the sentinel agent.
    $toolHandler = @($handlers | Where-Object { $_['event'] -eq 'tool' }) | Select-Object -First 1
    $observations = @(Get-DiscoverySessionObservation -Location $location -SessionId $SessionId -Store $Store)
    $evidence = Get-DiscoveryObservationEvidence -Observations $observations -ToolHandlerSha256 $(if ($null -ne $toolHandler) { [string]$toolHandler['sha256'] } else { $null }) -Now $Now -TtlSeconds $TtlSeconds
    $controls['trusted_attribution'] = $evidence.TrustedAttribution
    $controls['forbidden_tools_denied'] = $evidence.ForbiddenDenied
    $denied = $evidence.TrustedAttribution -and $evidence.ForbiddenDenied
    $probe = [ordered]@{
        sentinel_id  = $(if ($null -ne $evidence.SentinelRef) { $evidence.SentinelRef } else { "sentinel-$Nonce" })
        result       = $(if ($denied) { 'denied' } else { 'unavailable' })
        evidence_ref = $(if ($denied) { $evidence.ShellRef } else { $null })
    }
    foreach ($deficiency in $evidence.Deficiencies) {
        $findings.Add([ordered]@{ code = 'DISCOVERY_ENFORCEMENT_UNAVAILABLE'; severity = 'error'; artifact_path = $null; pointer = '/controls'; related_ids = @(); related_paths = @(); message = "Native control $($deficiency.Control) is not proved: $($deficiency.Message)."; next_action = 'Run the discovery-capability-sentinel agent in this session, then re-run the capability probe with the same session.' })
    }
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
    if (-not $denied) { $findings.Add([ordered]@{ code = 'DISCOVERY_ENFORCEMENT_UNAVAILABLE'; severity = 'error'; artifact_path = $null; pointer = '/probe'; related_ids = @(); related_paths = @(); message = "Sentinel $($probe['sentinel_id']) has no attributed denial in the recorded host observations."; next_action = 'Confirm the native hook denies forbidden operations and records protected evidence.' }) }
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

function Write-DiscoveryCapabilityAttestation {
    <#
    .SYNOPSIS
        Persists an observation as the session's protected capability attestation and returns its path.
    .DESCRIPTION
        The doctor, the agent preparation and the start attestation read only the protected
        session copy at `<sessions>/<session>/capability-attestation.json`, so a probe that
        only prints its observation leaves every control unverifiable. The record is written
        exclusively on first observation and replaced on a later probe of the same session
        when the store offers ReplaceText; a store without it keeps the first record.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$Observation,
        [Parameter(Mandatory = $true)][string]$WorkspaceRoot,
        [Parameter(Mandatory = $true)][hashtable]$HostEnvironment,
        [Parameter(Mandatory = $true)][hashtable]$Store
    )

    $location = Resolve-DiscoveryAuthorityLocation -WorkspaceRoot $WorkspaceRoot -Platform $HostEnvironment.Platform -UserHome $HostEnvironment.UserHome -LocalAppData $HostEnvironment.LocalAppData -XdgStateHome $HostEnvironment.XdgStateHome
    $directory = Get-DiscoverySessionDirectory -Location $location -SessionId ([string]$Observation['session_id'])
    $path = "$directory/$($script:CapabilityAttestationFile)"
    $text = (($Observation | ConvertTo-Json -Depth 8) + "`n")
    Invoke-DiscoveryStoreSeam -Seam $Store.EnsureDirectory -Arguments @($directory)
    # A re-probe of the same session replaces its earlier record; the exclusive write guards the first.
    $existing = Invoke-DiscoveryStoreSeam -Seam $Store.ReadText -Arguments @($path)
    if ($null -ne $existing -and $Store.ContainsKey('ReplaceText')) {
        Invoke-DiscoveryStoreSeam -Seam $Store.ReplaceText -Arguments @($path, $text)
    } else {
        Invoke-DiscoveryStoreSeam -Seam $Store.WriteText -Arguments @($path, $text)
    }
    return $path
}

Export-ModuleMember -Function `
    Get-DiscoverySentinelRequest, `
    Get-DiscoverySentinelEnvelope, `
    Get-DiscoverySessionObservation, `
    Get-DiscoveryObservationEvidence, `
    Get-DiscoveryHostRegistration, `
    Test-DiscoveryHandlerRegistered, `
    Get-DiscoveryCapabilityObservation, `
    Write-DiscoveryCapabilityAttestation
