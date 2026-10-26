#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Tests for `.claude/lib/discovery-validation/DiscoveryCapability.psm1` (issue #980).
.DESCRIPTION
    Proves host registration parsing over the repository's actual Claude settings, Codex config
    and Copilot hook file, the agent-variant and controlled-tool matcher checks, the sentinel
    envelope and environment, and the derived capability observation: supported only with every
    control, every registered handler and a denied sentinel with protected evidence; a caller
    Boolean, a missing or disabled registration, a missing handler, an allowed or unavailable
    sentinel, an untrusted workspace or a missing activation yields unsupported. The sentinel is a
    script-block seam; no process, network or clock is touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    Import-Module (Join-Path $lib 'DiscoveryCapability.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryStart.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthorization.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryPayload.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryAuthority.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryEncoding.psm1') -Force
    . (Join-Path $PSScriptRoot 'DiscoveryGate.TestSupport.ps1')
    $script:Roles = @('legacy-parity-analyst', 'runtime-characterization-analyst', 'requirements-reconciler', 'migration-coverage-reviewer')
    $script:Runtime = [ordered]@{ build_sha256 = ('b' * 64); package_version = '2.0.0'; policy_sha256 = ('c' * 64); policy_version = '2.0.0'; schema_version = '2.0.0' }

    function Get-RepoText { param([string]$Relative) return [System.IO.File]::ReadAllText((Join-Path $script:RepoRoot $Relative)) }

    function Get-ProbeReader {
        # Serves the repository's real registration and handler bytes under the fixture workspace root; Omit removes paths.
        param([string[]]$Omit = @(), [hashtable]$Replace = @{})
        $root = $script:RepoRoot
        $prefix = $script:GateWorkspaceRoot + '/'
        $omitted = $Omit
        $replaced = $Replace
        return {
            param([string]$Path)
            if (-not $Path.StartsWith($prefix)) { return $null }
            $relative = $Path.Substring($prefix.Length)
            if ($omitted -contains $relative) { return $null }
            if ($replaced.ContainsKey($relative)) { return , [System.Text.Encoding]::UTF8.GetBytes([string]$replaced[$relative]) }
            $full = Join-Path $root $relative
            if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { return $null }
            return , [System.IO.File]::ReadAllBytes($full)
        }.GetNewClosure()
    }

    $script:DenySentinel = { param([string]$EnvelopeJson, [hashtable]$Environment) [pscustomobject]@{ Decision = 'deny'; Code = 'SHELL'; Text = "deny:$($Environment['DRM_DISCOVERY_AGENT_ID']):$EnvelopeJson" } }

    function Get-Observation {
        param([string]$HostName = 'claude-code', [scriptblock]$Sentinel = $script:DenySentinel, [scriptblock]$Reader = (Get-ProbeReader), [hashtable]$Store = (Get-GateStore -HostName $HostName), [bool]$Trusted = $true)
        return Get-DiscoveryCapabilityObservation -HostName $HostName -WorkspaceRoot $script:GateWorkspaceRoot -SessionId 'session-alpha' -Nonce $script:GateNonce -Runtime $script:Runtime `
            -SentinelDecision $Sentinel -HostEnvironment $script:GateHostEnvironment -Store $Store -WorkspaceTrusted $Trusted -Now $script:GateNow -ReadBytes $Reader
    }
}

Describe 'host registration parsing' {
    It 'registers the <Event> handler of <HostName> for every discovery agent or controlled tool' -ForEach @(
        @{ HostName = 'claude-code'; File = '.claude/settings.json'; Event = 'SubagentStart'; Handler = 'record-discovery-agent-start.ps1'; Kind = 'agents' }
        @{ HostName = 'claude-code'; File = '.claude/settings.json'; Event = 'PreToolUse'; Handler = 'enforce-discovery-artifact-gate.ps1'; Kind = 'tools' }
        @{ HostName = 'claude-code'; File = '.claude/settings.json'; Event = 'SubagentStop'; Handler = 'validate-discovery-artifact-gate.ps1'; Kind = 'agents' }
        @{ HostName = 'claude-code'; File = '.claude/settings.json'; Event = 'PreToolUse'; Handler = 'enforce-discovery-planning-gate.ps1'; Kind = 'planning' }
        @{ HostName = 'codex'; File = '.codex/config.toml'; Event = 'SubagentStart'; Handler = 'record-subagent-routing-attestation.ps1'; Kind = 'variants' }
        @{ HostName = 'codex'; File = '.codex/config.toml'; Event = 'PreToolUse'; Handler = 'enforce-discovery-artifact-gate.ps1'; Kind = 'tools' }
        @{ HostName = 'codex'; File = '.codex/config.toml'; Event = 'PreToolUse'; Handler = 'enforce-discovery-planning-gate.ps1'; Kind = 'planning' }
        @{ HostName = 'codex'; File = '.codex/config.toml'; Event = 'SubagentStop'; Handler = 'validate-discovery-agent-output.ps1'; Kind = 'agents' }
        @{ HostName = 'codex'; File = '.codex/config.toml'; Event = 'SubagentStop'; Handler = 'validate-codex-subagent-routing.ps1'; Kind = 'variants' }
        @{ HostName = 'github-copilot'; File = '.github/hooks/discovery.json'; Event = 'SubagentStart'; Handler = 'discovery-agent-start.ps1'; Kind = 'agents' }
        @{ HostName = 'github-copilot'; File = '.github/hooks/discovery.json'; Event = 'PreToolUse'; Handler = 'discovery-pre-tool.ps1'; Kind = 'tools' }
        @{ HostName = 'github-copilot'; File = '.github/hooks/discovery.json'; Event = 'PreToolUse'; Handler = 'discovery-planning.ps1'; Kind = 'planning' }
        @{ HostName = 'github-copilot'; File = '.github/hooks/discovery.json'; Event = 'SubagentStop'; Handler = 'discovery-agent-stop.ps1'; Kind = 'agents' }
    ) {
        $registration = Get-DiscoveryHostRegistration -HostName $HostName -ConfigurationText (Get-RepoText $File)
        $registration.Parsed | Should -BeTrue
        $admitted = switch ($Kind) {
            'agents' { $script:Roles }
            'variants' { @($script:Roles + @('legacy-parity-analyst-c3', 'migration-coverage-reviewer-c3-elevated')) }
            'tools' { @('Bash', 'Write', 'mcp__drm-copilot__run_discovery_repo_inventory', 'Agent') }
            'planning' { @('Agent') }
        }
        Test-DiscoveryHandlerRegistered -Registration $registration -Event $Event -HandlerName $Handler -Admitted $admitted | Should -BeTrue
    }

    It 'rejects a handler whose matcher excludes an agent and reports unparseable text' {
        $registration = Get-DiscoveryHostRegistration -HostName 'claude-code' -ConfigurationText '{"hooks":{"SubagentStop":[{"matcher":"atomic-planner","hooks":[{"type":"command","command":"pwsh x.ps1"}]}]}}'
        Test-DiscoveryHandlerRegistered -Registration $registration -Event 'SubagentStop' -HandlerName 'x.ps1' -Admitted @('legacy-parity-analyst') | Should -BeFalse
        Test-DiscoveryHandlerRegistered -Registration $registration -Event 'SubagentStop' -HandlerName 'x.ps1' -Admitted @('atomic-planner') | Should -BeTrue
        (Get-DiscoveryHostRegistration -HostName 'claude-code' -ConfigurationText '{not json').Parsed | Should -BeFalse
        (Get-DiscoveryHostRegistration -HostName 'claude-code' -ConfigurationText '').Parsed | Should -BeFalse
        (Get-DiscoveryHostRegistration -HostName 'codex' -ConfigurationText "[model]`nname = 'x'`n").Parsed | Should -BeFalse
    }
}

Describe 'sentinel' {
    It 'names the harmless forbidden command and attests a probe specialist for <HostName>' -ForEach @(@{ HostName = 'claude-code' }; @{ HostName = 'codex' }; @{ HostName = 'github-copilot' }) {
        $json = Get-DiscoverySentinelEnvelope -HostName $HostName -SessionId 'session-alpha' -SentinelId 'sentinel-1' -WorkspaceRoot $script:GateWorkspaceRoot
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName $HostName -Text $json
        $normalized.Anomaly | Should -BeNullOrEmpty
        $normalized.ToolName | Should -Be 'Bash'
        $normalized.ToolInput.command | Should -Be (Get-DiscoverySentinelRequest -SentinelId 'sentinel-1')
        $normalized.ToolInput.command | Should -BeLike 'drm-copilot discovery capability probe sentinel-1:*must be denied*never executed'
        $environment = Get-DiscoverySentinelEnvironment -HostName $HostName -SessionId 'session-alpha' -SentinelId 'sentinel-1'
        (Get-DiscoveryTrustedPrincipal -Normalized $normalized -Environment $environment).Attributed | Should -BeTrue
        (Get-DiscoveryPreToolDecision -Normalized $normalized -Environment $environment -HostEnvironment $script:GateHostEnvironment -HandlerSha256 ('9' * 64) -Store (Get-GateStore -HostName $HostName) -Now $script:GateNow -Nonce $script:GateNonce).Code | Should -Be 'SHELL'
    }
}

Describe 'capability observation' {
    It 'reports <HostName> supported with three hashed handlers, seven controls and denied probe evidence' -ForEach @(@{ HostName = 'claude-code' }; @{ HostName = 'codex' }; @{ HostName = 'github-copilot' }) {
        $observation = Get-Observation -HostName $HostName
        $observation['status'] | Should -Be 'supported' -Because (($observation['findings'] | ForEach-Object { $_['message'] }) -join '; ')
        @($observation['handlers']).Count | Should -Be 3
        @($observation['handlers'] | ForEach-Object { $_['event'] } | Sort-Object) | Should -Be @('start', 'stop', 'tool')
        foreach ($handler in $observation['handlers']) { $handler['sha256'] | Should -Be (Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes((Join-Path $script:RepoRoot $handler['path'])))) }
        @($observation['controls'].Values | Where-Object { -not $_ }).Count | Should -Be 0
        $observation['probe']['result'] | Should -Be 'denied'
        $observation['probe']['evidence_ref'] | Should -Match '^probe-[0-9a-f]{64}$'
        $observation['workspace']['profile_sha256'] | Should -Be $script:GateProfileSha256
        $observation['expires_at'] | Should -Be '2026-10-22T13:00:00Z'
        @($observation.Keys | Sort-Object) -join ',' | Should -Be '$schema,artifact_kind,attestation_ref,configuration_sha256,controls,expires_at,findings,handlers,host,id,observed_at,probe,runtime,schema_version,session_id,status,workspace'
    }

    It 'reports unsupported for <Name>' -ForEach @(
        @{ Name = 'a missing registration file'; Reader = @{ Omit = @('.claude/settings.json') }; Sentinel = $null; Store = $null; Trusted = $true; Control = 'hooks_enabled' }
        @{ Name = 'a registration without the discovery handlers'; Reader = @{ Replace = @{ '.claude/settings.json' = '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"pwsh x.ps1"}]}]}}' } }; Sentinel = $null; Store = $null; Trusted = $true; Control = 'start_event' }
        @{ Name = 'a missing stop handler file'; Reader = @{ Omit = @('.claude/hooks/validate-discovery-artifact-gate.ps1') }; Sentinel = $null; Store = $null; Trusted = $true; Control = 'stop_event' }
        @{ Name = 'an allowed sentinel'; Reader = @{}; Sentinel = { [pscustomobject]@{ Decision = 'allow'; Code = 'READ_ONLY'; Text = 'allow' } }; Store = $null; Trusted = $true; Control = 'forbidden_tools_denied' }
        @{ Name = 'a sentinel denied without attribution'; Reader = @{}; Sentinel = { [pscustomobject]@{ Decision = 'deny'; Code = 'IDENTITY'; Text = 'deny' } }; Store = $null; Trusted = $true; Control = 'trusted_attribution' }
        @{ Name = 'an unavailable sentinel'; Reader = @{}; Sentinel = { throw 'adapter unavailable' }; Store = $null; Trusted = $true; Control = 'forbidden_tools_denied' }
        @{ Name = 'an untrusted workspace'; Reader = @{}; Sentinel = $null; Store = $null; Trusted = $false; Control = 'workspace_trusted' }
    ) {
        $parameters = @{ Reader = (Get-ProbeReader @Reader); Trusted = $Trusted }
        if ($null -ne $Sentinel) { $parameters['Sentinel'] = $Sentinel }
        $observation = Get-Observation @parameters
        $observation['status'] | Should -Be 'unsupported' -Because $Name
        $observation['controls'][$Control] | Should -BeFalse
        @($observation['findings']).Count | Should -BeGreaterThan 0
        foreach ($finding in $observation['findings']) { $finding['severity'] | Should -Be 'error' }
    }

    It 'reports unsupported without a protected activation and never takes a caller capability claim' {
        $observation = Get-Observation -Store (Get-GateStore -NoActivation)
        $observation['status'] | Should -Be 'unsupported'
        ($observation['findings'] | ForEach-Object { $_['message'] }) -join ' ' | Should -BeLike '*No active protected activation*'
        $observation['probe']['result'] | Should -Be 'denied'
        (Get-Command Get-DiscoveryCapabilityObservation).Parameters.Keys | Should -Not -Contain 'Supported'
    }
}

Describe 'capability attestation persistence' {
    BeforeAll {
        $script:SessionAttestationPath = "$(Get-DiscoverySessionDirectory -Location $script:GateLocation -SessionId 'session-alpha')/capability-attestation.json"

        function Write-Attestation {
            param([hashtable]$Store, [string]$Nonce = $script:GateNonce)
            $observation = Get-DiscoveryCapabilityObservation -HostName 'claude-code' -WorkspaceRoot $script:GateWorkspaceRoot -SessionId 'session-alpha' -Nonce $Nonce -Runtime $script:Runtime `
                -SentinelDecision $script:DenySentinel -HostEnvironment $script:GateHostEnvironment -Store $Store -WorkspaceTrusted $true -Now $script:GateNow -ReadBytes (Get-ProbeReader)
            $path = Write-DiscoveryCapabilityAttestation -Observation $observation -WorkspaceRoot $script:GateWorkspaceRoot -HostEnvironment $script:GateHostEnvironment -Store $Store
            return [pscustomobject]@{ Observation = $observation; Path = $path }
        }
    }

    It 'writes the observation exclusively into the protected session partition' {
        $store = Get-GateStore
        $written = Write-Attestation -Store $store
        $written.Path | Should -Be $script:SessionAttestationPath
        @($store.Writes) | Should -Be @($script:SessionAttestationPath)
        $store.Directories | Should -Contain (Split-Path $script:SessionAttestationPath -Parent).Replace('\', '/')
        $record = ConvertFrom-Json -InputObject $store.Files[$script:SessionAttestationPath] -Depth 16
        $record.artifact_kind | Should -Be 'capability-attestation'
        $record.attestation_ref | Should -Be $written.Observation['attestation_ref']
        $record.status | Should -Be 'supported'
        @($record.PSObject.Properties.Name | Sort-Object) -join ',' | Should -Be (@($written.Observation.Keys | Sort-Object) -join ',')
    }

    It 'satisfies the start-time capability check that reads only the protected copy' {
        $store = Get-GateStore
        $written = Write-Attestation -Store $store
        $principal = [pscustomobject]@{ HostName = 'claude-code'; SessionId = 'session-alpha' }
        $record = [pscustomobject]@{ capability_ref = $written.Observation['attestation_ref']; runtime = [pscustomobject]$script:Runtime }
        Get-DiscoveryCapabilityMismatch -Location $script:GateLocation -Principal $principal -Record $record -Store $store -Now $script:GateNow | Should -BeNullOrEmpty
        $stale = [pscustomobject]@{ capability_ref = 'capability-other'; runtime = [pscustomobject]$script:Runtime }
        (Get-DiscoveryCapabilityMismatch -Location $script:GateLocation -Principal $principal -Record $stale -Store $store -Now $script:GateNow).Code | Should -Be 'CAPABILITY'
    }

    It 'replaces the earlier record of the same session on a later probe' {
        $store = Get-GateStore
        $first = Write-Attestation -Store $store
        $second = Write-Attestation -Store $store -Nonce 'fedcba9876543210fedc'
        $second.Observation['id'] | Should -Not -Be $first.Observation['id']
        @($store.Writes).Count | Should -Be 2
        (ConvertFrom-Json -InputObject $store.Files[$script:SessionAttestationPath] -Depth 16).id | Should -Be $second.Observation['id']
    }

    It 'keeps the first record when the store offers no replacement seam' {
        $store = Get-GateStore
        $store.Remove('ReplaceText')
        $first = Write-Attestation -Store $store
        { Write-Attestation -Store $store -Nonce 'fedcba9876543210fedc' } | Should -Throw '*exists*'
        (ConvertFrom-Json -InputObject $store.Files[$script:SessionAttestationPath] -Depth 16).id | Should -Be $first.Observation['id']
    }
}
