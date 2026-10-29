#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Tests for `.claude/lib/discovery-validation/DiscoveryCapability.psm1` (issue #980).
.DESCRIPTION
    Proves host registration parsing over the repository's actual Claude settings, Codex config
    and Copilot hook file, the agent-variant and controlled-tool matcher checks, the sentinel
    request text, and the derived capability observation: supported only with every control,
    every registered handler and a consumed, attributed sentinel observation pair recorded by the
    registered tool handler; a caller Boolean, a missing or disabled registration, a missing
    handler, a missing, identity-less, stale, unconsumed or hash-mismatched observation, an
    untrusted workspace or a missing activation yields unsupported. Observations are seeded into
    the in-memory store; no process, network or clock is touched.
#>

BeforeAll {
    $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../../..").Path
    $lib = Join-Path $script:RepoRoot '.claude/lib/discovery-validation'
    Import-Module (Join-Path $lib 'DiscoveryCapability.psm1') -Force
    Import-Module (Join-Path $lib 'DiscoveryObservation.psm1') -Force
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

    $script:ToolHandlers = @{ 'claude-code' = '.claude/hooks/enforce-discovery-artifact-gate.ps1'; 'codex' = '.codex/hooks/enforce-discovery-artifact-gate.ps1'; 'github-copilot' = '.github/hooks/discovery-pre-tool.ps1' }

    function Add-SentinelObservation {
        # Seeds the session's observation pair: the consumed sentinel tool call and the denied sentinel shell command.
        param([hashtable]$Store, [string]$HostName = 'claude-code', [hashtable]$Tool = @{}, [switch]$NoTool, [switch]$NoShell)
        $directory = Get-DiscoveryObservationDirectory -Location $script:GateLocation -SessionId 'session-alpha'
        $handlerSha256 = Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes((Join-Path $script:RepoRoot $script:ToolHandlers[$HostName])))
        $common = [ordered]@{
            '$schema' = 'urn:drm-copilot:discovery:2.0.0:host-observation'; schema_version = '2.0.0'; artifact_kind = 'host-observation'; host = $HostName; session_id = 'session-alpha'
            agent_id = 'agent-sentinel'; agent_type = 'discovery-capability-sentinel'; parent_agent_id = 'root'; tool_use_id_present = $true; handler_sha256 = $handlerSha256; observed_at = '2026-10-22T11:59:00Z'
        }
        if (-not $NoTool) {
            $record = [ordered]@{} + $common
            $record['id'] = 'observation-tool-alpha'; $record['observation_ref'] = 'observation-tool-alpha'; $record['tool_name'] = 'mcp__drm-copilot__discovery_capability_sentinel'
            $record['decision'] = 'allow'; $record['code'] = 'SENTINEL'; $record['tool'] = 'discovery_capability_sentinel'; $record['input_sha256'] = ('d' * 64); $record['expires_at'] = '2026-10-22T12:04:00Z'; $record['state'] = 'consumed'
            foreach ($key in $Tool.Keys) { $record[$key] = $Tool[$key] }
            $Store.Files["$directory/observation-tool-alpha.json"] = ($record | ConvertTo-Json -Depth 4)
        }
        if (-not $NoShell) {
            $record = [ordered]@{} + $common
            $record['id'] = 'observation-shell-alpha'; $record['observation_ref'] = 'observation-shell-alpha'; $record['tool_name'] = 'Bash'; $record['decision'] = 'deny'; $record['code'] = 'SHELL'
            $Store.Files["$directory/observation-shell-alpha.json"] = ($record | ConvertTo-Json -Depth 4)
        }
        return $Store
    }

    function Get-Observation {
        param([string]$HostName = 'claude-code', [scriptblock]$Reader = (Get-ProbeReader), [hashtable]$Store = (Add-SentinelObservation -Store (Get-GateStore -HostName $HostName) -HostName $HostName), [bool]$Trusted = $true)
        return Get-DiscoveryCapabilityObservation -HostName $HostName -WorkspaceRoot $script:GateWorkspaceRoot -SessionId 'session-alpha' -Nonce $script:GateNonce -Runtime $script:Runtime `
            -HostEnvironment $script:GateHostEnvironment -Store $Store -WorkspaceTrusted $Trusted -Now $script:GateNow -ReadBytes $Reader
    }

    function Get-FindingText { param([System.Collections.IDictionary]$Observation) return (@($Observation['findings'] | ForEach-Object { $_['message'] }) -join ' | ') }
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
    It 'names the harmless forbidden command that the gate recognises as the sentinel prefix for <HostName>' -ForEach @(@{ HostName = 'claude-code' }; @{ HostName = 'codex' }; @{ HostName = 'github-copilot' }) {
        $json = Get-DiscoverySentinelEnvelope -HostName $HostName -SessionId 'session-alpha' -SentinelId 'sentinel-1' -WorkspaceRoot $script:GateWorkspaceRoot
        $normalized = ConvertFrom-DiscoveryHostPayloadText -HostName $HostName -Text $json
        $normalized.Anomaly | Should -BeNullOrEmpty
        $normalized.ToolName | Should -Be 'Bash'
        $normalized.ToolInput.command | Should -Be (Get-DiscoverySentinelRequest -SentinelId 'sentinel-1')
        $normalized.ToolInput.command | Should -BeLike 'drm-copilot discovery capability probe sentinel-1:*must be denied*never executed'
        $normalized.ToolInput.command.StartsWith((Get-DiscoverySentinelCommandPrefix)) | Should -BeTrue
        (Get-Command -Module DiscoveryCapability).Name | Should -Not -Contain 'Get-DiscoverySentinelEnvironment'
    }
}

Describe 'observation evidence' {
    It 'reports <HostName> unsupported naming <Control> for <Name>' -ForEach @(
        @{ HostName = 'claude-code'; Name = 'no observation'; Seed = @{ NoTool = $true; NoShell = $true }; Control = 'trusted_attribution'; Text = 'no sentinel tool observation' }
        @{ HostName = 'claude-code'; Name = 'no observation'; Seed = @{ NoTool = $true; NoShell = $true }; Control = 'forbidden_tools_denied'; Text = 'no SHELL deny observation' }
        @{ HostName = 'codex'; Name = 'a Codex-shaped observation without agent_id'; Seed = @{ Tool = @{ agent_id = $null; agent_type = $null } }; Control = 'trusted_attribution'; Text = 'carries no sentinel agent identity' }
        @{ HostName = 'claude-code'; Name = 'a stale observation'; Seed = @{ Tool = @{ observed_at = '2026-10-22T10:00:00Z' } }; Control = 'trusted_attribution'; Text = 'is stale' }
        @{ HostName = 'github-copilot'; Name = 'a handler-hash mismatch'; Seed = @{ Tool = @{ handler_sha256 = ('f' * 64) } }; Control = 'trusted_attribution'; Text = 'hash differs' }
        @{ HostName = 'claude-code'; Name = 'an unconsumed sentinel grant'; Seed = @{ Tool = @{ state = 'issued' } }; Control = 'trusted_attribution'; Text = 'was not consumed' }
        @{ HostName = 'claude-code'; Name = 'a shell deny from another agent'; Seed = @{ NoShell = $true }; Control = 'forbidden_tools_denied'; Text = 'no SHELL deny observation' }
    ) {
        $store = Add-SentinelObservation -Store (Get-GateStore -HostName $HostName) -HostName $HostName @Seed
        $observation = Get-Observation -HostName $HostName -Store $store
        $observation['status'] | Should -Be 'unsupported'
        $observation['controls'][$Control] | Should -BeFalse
        Get-FindingText -Observation $observation | Should -BeLike "*Native control $Control is not proved:*$Text*"
        $observation['probe']['result'] | Should -Be 'unavailable'
        $observation['probe']['evidence_ref'] | Should -BeNullOrEmpty
    }

    It 'accepts a later valid observation when an earlier sentinel observation is rejected' {
        $store = Add-SentinelObservation -Store (Get-GateStore) -Tool @{ observation_ref = 'observation-tool-beta'; id = 'observation-tool-beta'; state = 'issued' }
        $store = Add-SentinelObservation -Store $store -NoShell
        $evidence = Get-DiscoveryObservationEvidence -Observations (Get-DiscoverySessionObservation -Location $script:GateLocation -SessionId 'session-alpha' -Store $store) `
            -ToolHandlerSha256 (Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes((Join-Path $script:RepoRoot $script:ToolHandlers['claude-code'])))) -Now $script:GateNow -TtlSeconds 3600
        $evidence.TrustedAttribution | Should -BeTrue
        $evidence.SentinelRef | Should -Be 'observation-tool-alpha'
        @($evidence.Deficiencies).Count | Should -Be 0
    }

    It 'skips unreadable and foreign observation entries and treats an unlistable directory as empty' {
        $store = Get-GateStore
        $directory = Get-DiscoveryObservationDirectory -Location $script:GateLocation -SessionId 'session-alpha'
        $store.Files["$directory/broken.json"] = '{not json'
        $store.Files["$directory/other.json"] = '{"artifact_kind":"root-grant"}'
        @(Get-DiscoverySessionObservation -Location $script:GateLocation -SessionId 'session-alpha' -Store $store).Count | Should -Be 0
        $store['ListEntries'] = { throw 'unavailable' }
        @(Get-DiscoverySessionObservation -Location $script:GateLocation -SessionId 'session-alpha' -Store $store).Count | Should -Be 0
    }

    It 'reports a future-dated or unreadable timestamp as stale' {
        foreach ($stamp in @('2026-10-22T12:30:00Z', 'not-a-time')) {
            $store = Add-SentinelObservation -Store (Get-GateStore) -Tool @{ observed_at = $stamp }
            Get-FindingText -Observation (Get-Observation -Store $store) | Should -BeLike '*is stale*'
        }
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
        $observation['probe']['sentinel_id'] | Should -Be 'observation-tool-alpha'
        $observation['probe']['evidence_ref'] | Should -Be 'observation-shell-alpha'
        $observation['workspace']['profile_sha256'] | Should -Be $script:GateProfileSha256
        $observation['expires_at'] | Should -Be '2026-10-22T13:00:00Z'
        @($observation.Keys | Sort-Object) -join ',' | Should -Be '$schema,artifact_kind,attestation_ref,configuration_sha256,controls,expires_at,findings,handlers,host,id,observed_at,probe,runtime,schema_version,session_id,status,workspace'
    }

    It 'reports unsupported for <Name>' -ForEach @(
        @{ Name = 'a missing registration file'; Reader = @{ Omit = @('.claude/settings.json') }; Trusted = $true; Control = 'hooks_enabled' }
        @{ Name = 'a registration without the discovery handlers'; Reader = @{ Replace = @{ '.claude/settings.json' = '{"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"pwsh x.ps1"}]}]}}' } }; Trusted = $true; Control = 'start_event' }
        @{ Name = 'a missing stop handler file'; Reader = @{ Omit = @('.claude/hooks/validate-discovery-artifact-gate.ps1') }; Trusted = $true; Control = 'stop_event' }
        @{ Name = 'a missing tool handler file, which leaves no hash to match the observation'; Reader = @{ Omit = @('.claude/hooks/enforce-discovery-artifact-gate.ps1') }; Trusted = $true; Control = 'trusted_attribution' }
        @{ Name = 'an untrusted workspace'; Reader = @{}; Trusted = $false; Control = 'workspace_trusted' }
    ) {
        $observation = Get-Observation -Reader (Get-ProbeReader @Reader) -Trusted $Trusted
        $observation['status'] | Should -Be 'unsupported' -Because $Name
        $observation['controls'][$Control] | Should -BeFalse
        @($observation['findings']).Count | Should -BeGreaterThan 0
        foreach ($finding in $observation['findings']) { $finding['severity'] | Should -Be 'error' }
    }

    It 'reports unsupported without a protected activation and never takes a caller capability claim' {
        $observation = Get-Observation -Store (Add-SentinelObservation -Store (Get-GateStore -NoActivation))
        $observation['status'] | Should -Be 'unsupported'
        ($observation['findings'] | ForEach-Object { $_['message'] }) -join ' ' | Should -BeLike '*No active protected activation*'
        $observation['probe']['result'] | Should -Be 'denied'
        (Get-Command Get-DiscoveryCapabilityObservation).Parameters.Keys | Should -Not -Contain 'Supported'
        (Get-Command Get-DiscoveryCapabilityObservation).Parameters.Keys | Should -Not -Contain 'SentinelDecision'
    }
}

Describe 'capability attestation persistence' {
    BeforeAll {
        $script:SessionAttestationPath = "$(Get-DiscoverySessionDirectory -Location $script:GateLocation -SessionId 'session-alpha')/capability-attestation.json"

        function Write-Attestation {
            param([hashtable]$Store, [string]$Nonce = $script:GateNonce)
            if (-not @($Store.Files.Keys | Where-Object { $_ -like '*/observations/*' })) { [void](Add-SentinelObservation -Store $Store) }
            $observation = Get-DiscoveryCapabilityObservation -HostName 'claude-code' -WorkspaceRoot $script:GateWorkspaceRoot -SessionId 'session-alpha' -Nonce $Nonce -Runtime $script:Runtime `
                -HostEnvironment $script:GateHostEnvironment -Store $Store -WorkspaceTrusted $true -Now $script:GateNow -ReadBytes (Get-ProbeReader)
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
