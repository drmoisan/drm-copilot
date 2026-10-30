#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Claude Code discovery capability probe (issue #980).
.DESCRIPTION
    .claude/hooks/discovery-capability-probe.ps1 is dot-sourced in-process; the registration and
    handler bytes are the repository's real files served under the fixture workspace root, and the
    protected store holds the host observations the PreToolUse gate recorded for the capability
    sentinel agent (seeded through the shared fixtures). Attribution is proved only from those
    records: a missing, identity-less, stale, unconsumed or hash-mismatched observation is
    unsupported. No file is written and no process, network or clock is touched.
#>

Describe 'discovery-capability-probe.ps1 (Claude Code)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.claude/hooks/discovery-capability-probe.ps1'
        . $script:UnderTest
        . (Join-Path $PSScriptRoot '../claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')

        function Get-RepoReader {
            param([string[]]$Omit = @())
            $root = $script:RepoRoot
            $prefix = $script:GateWorkspaceRoot + '/'
            $omitted = $Omit
            return {
                param([string]$Path)
                if (-not $Path.StartsWith($prefix)) { return $null }
                $relative = $Path.Substring($prefix.Length)
                if ($omitted -contains $relative) { return $null }
                $full = Join-Path $root $relative
                if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { return $null }
                return , [System.IO.File]::ReadAllBytes($full)
            }.GetNewClosure()
        }

        function Invoke-Probe {
            param([scriptblock]$Reader = (Get-RepoReader), [hashtable]$Store = (Add-GateSentinelObservation -Store (Get-GateStore)), [bool]$Trusted = $true)
            return Invoke-DiscoveryCapabilityProbe -WorkspaceRoot $script:GateWorkspaceRoot -SessionId 'session-alpha' -Nonce $script:GateNonce -WorkspaceTrusted $Trusted -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes $Reader -Now $script:GateNow
        }

        function Get-FindingText { param([System.Collections.IDictionary]$Observation) return (@($Observation['findings'] | ForEach-Object { $_['message'] }) -join ' | ') }
    }

    It 'observes the registered Claude handlers, hashes them and proves attribution from the recorded sentinel observation pair' {
        $observation = Invoke-Probe
        $observation['status'] | Should -Be 'supported' -Because (Get-FindingText -Observation $observation)
        $observation['host'] | Should -Be 'claude-code'
        @($observation['handlers'] | ForEach-Object { $_['path'] } | Sort-Object) | Should -Be @('.claude/hooks/enforce-discovery-artifact-gate.ps1', '.claude/hooks/record-discovery-agent-start.ps1', '.claude/hooks/validate-discovery-artifact-gate.ps1')
        $observation['configuration_sha256'] | Should -Be (Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes((Join-Path $script:RepoRoot '.claude/settings.json'))))
        $observation['controls']['trusted_attribution'] | Should -BeTrue
        $observation['controls']['forbidden_tools_denied'] | Should -BeTrue
        $observation['probe']['result'] | Should -Be 'denied'
        $observation['probe']['sentinel_id'] | Should -Be $script:GateSentinelToolRef
        $observation['probe']['evidence_ref'] | Should -Be $script:GateSentinelShellRef
        $observation['runtime']['build_sha256'] | Should -Match '^[0-9a-f]{64}$'
    }

    It 'accepts the caller runtime identity and reports unsupported for <Name>' -ForEach @(
        @{ Name = 'a missing tool handler'; Omit = @('.claude/hooks/enforce-discovery-artifact-gate.ps1'); Trusted = $true; Control = 'tool_event' }
        @{ Name = 'a missing settings file'; Omit = @('.claude/settings.json'); Trusted = $true; Control = 'hooks_enabled' }
        @{ Name = 'an untrusted workspace'; Omit = @(); Trusted = $false; Control = 'workspace_trusted' }
    ) {
        $observation = Invoke-Probe -Reader (Get-RepoReader -Omit $Omit) -Trusted $Trusted
        $observation['status'] | Should -Be 'unsupported' -Because $Name
        $observation['controls'][$Control] | Should -BeFalse
        $runtimeJson = '{"build_sha256":"' + ('e' * 64) + '","package_version":"2.0.0","policy_sha256":"' + ('f' * 64) + '","policy_version":2,"schema_version":"2.0.0"}'
        $runtime = Get-DiscoveryProbeRuntime -RuntimeJson $runtimeJson -WorkspaceRoot $script:GateWorkspaceRoot -ConfigurationPath '.claude/settings.json'
        $runtime['build_sha256'] | Should -Be ('e' * 64)
        # The installed runtime reports an integer policy version; the attestation must reproduce the type.
        $runtime['policy_version'] | Should -BeOfType [int]
        $observation['runtime']['policy_version'] | Should -BeOfType [int]
    }

    It 'reports unsupported naming <Control> for <Name>' -ForEach @(
        @{ Name = 'a session with no observation'; Seed = @{ NoTool = $true; NoShell = $true }; Control = 'trusted_attribution'; Text = 'no sentinel tool observation' }
        @{ Name = 'a session with no observation'; Seed = @{ NoTool = $true; NoShell = $true }; Control = 'forbidden_tools_denied'; Text = 'no SHELL deny observation' }
        @{ Name = 'an observation without agent_id'; Seed = @{ Tool = @{ agent_id = $null; agent_type = $null } }; Control = 'trusted_attribution'; Text = 'carries no sentinel agent identity' }
        @{ Name = 'a stale observation'; Seed = @{ Tool = @{ observed_at = '2026-10-22T10:00:00Z' } }; Control = 'trusted_attribution'; Text = 'is stale' }
        @{ Name = 'a handler-hash mismatch'; Seed = @{ Tool = @{ handler_sha256 = ('f' * 64) } }; Control = 'trusted_attribution'; Text = 'hash differs' }
        @{ Name = 'an unconsumed sentinel grant'; Seed = @{ NoLatch = $true }; Control = 'trusted_attribution'; Text = 'was not consumed' }
    ) {
        $observation = Invoke-Probe -Store (Add-GateSentinelObservation -Store (Get-GateStore) @Seed)
        $observation['status'] | Should -Be 'unsupported' -Because $Name
        $observation['controls'][$Control] | Should -BeFalse
        Get-FindingText -Observation $observation | Should -BeLike "*Native control $Control is not proved:*$Text*"
        $observation['probe']['result'] | Should -Be 'unavailable'
        $observation['probe']['evidence_ref'] | Should -BeNullOrEmpty
    }

    It 'reports unsupported when the workspace has no protected activation' {
        (Invoke-Probe -Store (Add-GateSentinelObservation -Store (Get-GateStore -NoActivation)))['status'] | Should -Be 'unsupported'
    }

    It 'persists the observation as the protected session capability attestation' {
        $store = Add-GateSentinelObservation -Store (Get-GateStore)
        $observation = Invoke-Probe -Store $store
        $path = "$(Get-DiscoverySessionDirectory -Location $script:GateLocation -SessionId 'session-alpha')/capability-attestation.json"
        @($store.Writes) | Should -Be @($path)
        (ConvertFrom-Json -InputObject $store.Files[$path] -Depth 16).attestation_ref | Should -Be $observation['attestation_ref']
    }
}
