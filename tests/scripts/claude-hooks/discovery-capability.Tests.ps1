#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the Claude Code discovery capability probe (issue #980).
.DESCRIPTION
    .claude/hooks/discovery-capability-probe.ps1 is dot-sourced in-process; the registration and
    handler bytes are the repository's real files served under the fixture workspace root, the
    protected store and host roots come from the shared fixtures, and the sentinel runs through
    the real PreToolUse adapter decision. No file is written, no process, network or clock is
    touched, and the sentinel command is never executed.
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
            param([scriptblock]$Reader = (Get-RepoReader), [hashtable]$Store = (Get-GateStore), [bool]$Trusted = $true)
            return Invoke-DiscoveryCapabilityProbe -WorkspaceRoot $script:GateWorkspaceRoot -SessionId 'session-alpha' -Nonce $script:GateNonce -WorkspaceTrusted $Trusted -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes $Reader -Now $script:GateNow
        }
    }

    It 'observes the registered Claude handlers, hashes them and denies the sentinel through the real adapter' {
        $observation = Invoke-Probe
        $observation['status'] | Should -Be 'supported' -Because (($observation['findings'] | ForEach-Object { $_['message'] }) -join '; ')
        $observation['host'] | Should -Be 'claude-code'
        @($observation['handlers'] | ForEach-Object { $_['path'] } | Sort-Object) | Should -Be @('.claude/hooks/enforce-discovery-artifact-gate.ps1', '.claude/hooks/record-discovery-agent-start.ps1', '.claude/hooks/validate-discovery-artifact-gate.ps1')
        $observation['configuration_sha256'] | Should -Be (Get-DiscoveryBytesSha256Hex -Bytes ([System.IO.File]::ReadAllBytes((Join-Path $script:RepoRoot '.claude/settings.json'))))
        $observation['probe']['result'] | Should -Be 'denied'
        $observation['controls']['trusted_attribution'] | Should -BeTrue
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

    It 'reports unsupported when the workspace has no protected activation' {
        (Invoke-Probe -Store (Get-GateStore -NoActivation))['status'] | Should -Be 'unsupported'
    }

    It 'persists the observation as the protected session capability attestation' {
        $store = Get-GateStore
        $observation = Invoke-Probe -Store $store
        $path = "$(Get-DiscoverySessionDirectory -Location $script:GateLocation -SessionId 'session-alpha')/capability-attestation.json"
        @($store.Writes) | Should -Be @($path)
        (ConvertFrom-Json -InputObject $store.Files[$path] -Depth 16).attestation_ref | Should -Be $observation['attestation_ref']
    }
}
