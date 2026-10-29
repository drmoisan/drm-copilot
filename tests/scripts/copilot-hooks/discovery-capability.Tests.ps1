#Requires -Version 7.0
#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }

<#
.SYNOPSIS
    Behavioral tests for the GitHub Copilot discovery capability probe and the .github/hooks/discovery.json registration (issue #980).
.DESCRIPTION
    .github/hooks/discovery-capability-probe.ps1 is dot-sourced in-process; the registration and
    handler bytes are the repository's real files served under the fixture workspace root and the
    protected store holds the host observations the Copilot PreToolUse gate recorded for the
    capability sentinel agent (seeded through the shared fixtures). Attribution is proved only
    from those records. No file is written and no process, network or clock is touched.
#>

Describe 'discovery-capability-probe.ps1 (GitHub Copilot)' {
    BeforeAll {
        $script:RepoRoot = (Resolve-Path "$PSScriptRoot/../../..").Path
        $script:UnderTest = Join-Path $script:RepoRoot '.github/hooks/discovery-capability-probe.ps1'
        . $script:UnderTest
        . (Join-Path $script:RepoRoot 'tests/scripts/claude-lib/discovery-validation/DiscoveryGate.TestSupport.ps1')

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
            param([scriptblock]$Reader = (Get-RepoReader), [bool]$Trusted = $true, [hashtable]$Store = (Add-GateSentinelObservation -Store (Get-GateStore -HostName 'github-copilot') -HostName 'github-copilot'))
            return Invoke-DiscoveryCapabilityProbe -WorkspaceRoot $script:GateWorkspaceRoot -SessionId 'session-alpha' -Nonce $script:GateNonce -WorkspaceTrusted $Trusted -HostEnvironment $script:GateHostEnvironment -Store $Store -ReadBytes $Reader -Now $script:GateNow
        }

        function Get-FindingText { param([System.Collections.IDictionary]$Observation) return (@($Observation['findings'] | ForEach-Object { $_['message'] }) -join ' | ') }
    }

    It 'persists the observation as the protected session capability attestation' {
        $store = Add-GateSentinelObservation -Store (Get-GateStore -HostName 'github-copilot') -HostName 'github-copilot'
        $observation = Invoke-Probe -Store $store
        $path = "$(Get-DiscoverySessionDirectory -Location $script:GateLocation -SessionId 'session-alpha')/capability-attestation.json"
        @($store.Writes) | Should -Be @($path)
        (ConvertFrom-Json -InputObject $store.Files[$path] -Depth 16).attestation_ref | Should -Be $observation['attestation_ref']
    }

    It 'observes the registered Copilot handlers from discovery.json and proves attribution from the recorded sentinel observation pair' {
        $observation = Invoke-Probe
        $observation['status'] | Should -Be 'supported' -Because (Get-FindingText -Observation $observation)
        $observation['host'] | Should -Be 'github-copilot'
        @($observation['handlers'] | ForEach-Object { $_['path'] } | Sort-Object) | Should -Be @('.github/hooks/discovery-agent-start.ps1', '.github/hooks/discovery-agent-stop.ps1', '.github/hooks/discovery-pre-tool.ps1')
        $observation['controls']['trusted_attribution'] | Should -BeTrue
        $observation['controls']['forbidden_tools_denied'] | Should -BeTrue
        $observation['probe']['result'] | Should -Be 'denied'
        $observation['probe']['sentinel_id'] | Should -Be 'observation-tool-alpha'
        $observation['probe']['evidence_ref'] | Should -Be 'observation-shell-alpha'
    }

    It 'reports unsupported naming <Control> for <Name>' -ForEach @(
        @{ Name = 'a session with no observation'; Seed = @{ NoTool = $true; NoShell = $true }; Control = 'trusted_attribution'; Text = 'no sentinel tool observation' }
        @{ Name = 'a session with no observation'; Seed = @{ NoTool = $true; NoShell = $true }; Control = 'forbidden_tools_denied'; Text = 'no SHELL deny observation' }
        @{ Name = 'an observation without agent_id'; Seed = @{ Tool = @{ agent_id = $null; agent_type = $null } }; Control = 'trusted_attribution'; Text = 'carries no sentinel agent identity' }
        @{ Name = 'a stale observation'; Seed = @{ Tool = @{ observed_at = '2026-10-22T10:00:00Z' } }; Control = 'trusted_attribution'; Text = 'is stale' }
        @{ Name = 'a handler-hash mismatch'; Seed = @{ Tool = @{ handler_sha256 = ('f' * 64) } }; Control = 'trusted_attribution'; Text = 'hash differs' }
        @{ Name = 'an unconsumed sentinel grant'; Seed = @{ Tool = @{ state = 'issued' } }; Control = 'trusted_attribution'; Text = 'was not consumed' }
    ) {
        $observation = Invoke-Probe -Store (Add-GateSentinelObservation -Store (Get-GateStore -HostName 'github-copilot') -HostName 'github-copilot' @Seed)
        $observation['status'] | Should -Be 'unsupported' -Because $Name
        $observation['controls'][$Control] | Should -BeFalse
        Get-FindingText -Observation $observation | Should -BeLike "*Native control $Control is not proved:*$Text*"
        $observation['probe']['result'] | Should -Be 'unavailable'
        $observation['probe']['evidence_ref'] | Should -BeNullOrEmpty
    }

    It 'reports unsupported when Workspace Trust is not granted or the registration file is absent' {
        (Invoke-Probe -Trusted $false)['controls']['workspace_trusted'] | Should -BeFalse
        $observation = Invoke-Probe -Reader (Get-RepoReader -Omit @('.github/hooks/discovery.json'))
        $observation['status'] | Should -Be 'unsupported'
        $observation['controls']['hooks_enabled'] | Should -BeFalse
    }

    It 'registers the four Copilot hooks with Windows command variants and no Claude matcher' {
        $registration = Get-Content -Raw -LiteralPath (Join-Path $script:RepoRoot '.github/hooks/discovery.json') | ConvertFrom-Json
        @($registration.hooks.PSObject.Properties.Name | Sort-Object) | Should -Be @('PreToolUse', 'SubagentStart', 'SubagentStop')
        $hooks = @($registration.hooks.PSObject.Properties | ForEach-Object { $_.Value })
        $hooks.Count | Should -Be 4
        foreach ($hook in $hooks) {
            $hook.type | Should -Be 'command'
            $hook.command | Should -BeLike 'pwsh -NoProfile -File .github/hooks/*.ps1'
            $hook.windows | Should -Be $hook.command
            @($hook.PSObject.Properties.Name) | Should -Not -Contain 'matcher'
            Test-Path -LiteralPath (Join-Path $script:RepoRoot ($hook.command -replace '^pwsh -NoProfile -File ', '')) | Should -BeTrue
        }
    }
}
